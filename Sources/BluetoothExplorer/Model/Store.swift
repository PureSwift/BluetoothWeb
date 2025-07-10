//
//  Store.swift
//  BluetoothExplorer
//
//  Created by Alsey Coleman Miller on 6/9/19.
//  Copyright © 2019 Alsey Coleman Miller. All rights reserved.
//

import Foundation
import OpenCombineJS
import BluetoothWeb

final class Store: ObservableObject {
    
    typealias Central = WebCentral
    
    typealias Peripheral = Central.Peripheral
    
    typealias ScanData = BluetoothWeb.ScanData<Central.Peripheral, Central.Advertisement>
    
    typealias Service = BluetoothWeb.Service<Central.Peripheral, Central.AttributeID>
    
    typealias Characteristic = BluetoothWeb.Characteristic<Central.Peripheral, Central.AttributeID>
    
    typealias Descriptor = BluetoothWeb.Descriptor<Central.Peripheral, Central.AttributeID>
    
    // MARK: - Properties
    
    @Published
    private(set) var activity = [Peripheral: Bool]()
    
    @Published
    private(set) var scanResults = [Peripheral: ScanData]()
    
    @Published
    private(set) var connected = Set<Peripheral>()
    
    @Published
    private(set) var services = [Peripheral: [Service]]()
    
    @Published
    private(set) var characteristics = [Service: [Characteristic]]()
    
    @Published
    private(set) var descriptors = [Characteristic: [Descriptor]]()
    
    @Published
    private(set) var characteristicValues = [Characteristic: Cache<AttributeValue>]()
    
    @Published
    private(set) var descriptorValues = [Descriptor: Cache<AttributeValue>]()
    
    @Published
    private(set) var isNotifying = [Characteristic: Bool]()

    @Published
    private(set) var uuids = BluetoothUUID.assignedNumbers
    
    private var central: Central {
        guard let central = WebCentral.shared else {
            fatalError("Missing central")
        }
        return central
    }
    
    // MARK: - Initialization
    
    private init() { }
    
    static let shared = Store()
    
    // MARK: - Methods
    
    private func observeValues() {
        
    }
    
    func scan() async throws -> Peripheral {
        scanResults.removeAll(keepingCapacity: true)
        let scanData = try await central.scan(with: uuids)
        scanResults[scanData.peripheral] = scanData
        return scanData.peripheral
    }
    
    func connect(to peripheral: Central.Peripheral) async throws {
        activity[peripheral] = true
        defer { activity[peripheral] = false }
        try await central.connect(to: peripheral)
        connected.insert(peripheral)
    }
    
    func disconnect(_ peripheral: Central.Peripheral) {
        central.disconnect(peripheral)
    }
    
    @discardableResult
    func discoverServices(for peripheral: Central.Peripheral) async throws -> [Service] {
        activity[peripheral] = true
        defer { activity[peripheral] = false }
        let services = try await central.discoverServices(uuids, for: peripheral)
        self.services[peripheral] = services
        return services
    }
    
    @discardableResult
    func discoverCharacteristics(for service: Service) async throws -> [Characteristic] {
        activity[service.peripheral] = true
        defer { activity[service.peripheral] = false }
        let characteristics = try await central.discoverCharacteristics(uuids, for: service)
        self.characteristics[service] = characteristics
        return characteristics
    }
    
    @discardableResult
    func discoverDescriptors(for characteristic: Characteristic) async throws -> [Descriptor] {
        activity[characteristic.peripheral] = true
        defer { activity[characteristic.peripheral] = false }
        let includedServices = try await central.discoverDescriptors(for: characteristic)
        self.descriptors[characteristic] = includedServices
        return includedServices
    }
    
    @discardableResult
    func readValue(for characteristic: Characteristic) async throws -> AttributeValue {
        activity[characteristic.peripheral] = true
        defer { activity[characteristic.peripheral] = false }
        let data = try await central.readValue(for: characteristic)
        let value = AttributeValue(
            date: Date(),
            type: .read,
            data: data
        )
        self.characteristicValues[characteristic, default: .init(capacity: 5)].append(value)
        return value
    }
    
    func writeValue(_ data: Data, for characteristic: Characteristic, withResponse: Bool = true) async throws {
        activity[characteristic.peripheral] = true
        defer { activity[characteristic.peripheral] = false }
        try await central.writeValue(data, for: characteristic, withResponse: withResponse)
        let value = AttributeValue(
            date: Date(),
            type: .write,
            data: data
        )
        self.characteristicValues[characteristic, default: .init(capacity: 5)].append(value)
    }
    
    func notify(_ isEnabled: Bool, for characteristic: Characteristic) async throws {
        activity[characteristic.peripheral] = true
        defer { activity[characteristic.peripheral] = false }
        if isEnabled {
            let stream = try await central.notify(for: characteristic)
            isNotifying[characteristic] = isEnabled
            Task.detached(priority: .low) { [unowned self] in
                for try await notification in stream {
                    await self.notification(notification, for: characteristic)
                }
            }
        } else {
            // FIXME: stop notifications
            //try await central.stopNotifications(for: characteristic)
            isNotifying[characteristic] = false
        }
    }
    
    private func notification(_ data: Data, for characteristic: Characteristic) async {
        let value = AttributeValue(
            date: Date(),
            type: .notification,
            data: data
        )
        self.characteristicValues[characteristic, default: .init(capacity: 5)].append(value)
    }
    
    func readValue(for descriptor: Descriptor) async throws {
        activity[descriptor.peripheral] = true
        defer { activity[descriptor.peripheral] = false }
        let data = try await central.readValue(for: descriptor)
        let value = AttributeValue(
            date: Date(),
            type: .read,
            data: data
        )
        self.descriptorValues[descriptor, default: .init(capacity: 5)].append(value)
    }
    
    func writeValue(_ data: Data, for descriptor: Descriptor) async throws {
        activity[descriptor.peripheral] = true
        defer { activity[descriptor.peripheral] = false }
        try await central.writeValue(data, for: descriptor)
        let value = AttributeValue(
            date: Date(),
            type: .write,
            data: data
        )
        self.descriptorValues[descriptor, default: .init(capacity: 5)].append(value)
    }
}

extension Store {
    
    func readAllCharacteristics(for peripheral: Peripheral) async throws {
        let services = try await discoverServices(for: peripheral)
        for service in services {
            let characteristics = try await discoverCharacteristics(for: service)
            for characteristic in characteristics {
                guard characteristic.properties.contains(.read) else {
                    continue
                }
                try await readValue(for: characteristic)
            }
        }
    }
}
