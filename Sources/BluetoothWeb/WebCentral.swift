//
//  CentralManager.swift
//  
//
//  Created by Alsey Coleman Miller on 24/12/21.
//

import Foundation
import JavaScriptKit
// import Bluetooth

/// [Web Bluetooth API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Bluetooth_API)
public final class WebCentral { //: CentralManager {
    
    public static let shared: WebCentral? = {
        guard let jsBluetooth = JSBluetooth.shared else {
            return nil
        }
        let central = WebCentral(jsBluetooth)
        return central
    }()
    
    // MARK: - Properties
    
    internal let bluetooth: JSBluetooth
    
    private var cache = Cache()
    
    // MARK: - Initialization
    
    internal init(_ bluetooth: JSBluetooth) {
        self.bluetooth = bluetooth
    }
    
    // MARK: - Methods
    
    public var isAvailable: Bool {
        get async {
            await bluetooth.isAvailable
        }
    }
    
    public func scan(
        with services: Set<BluetoothUUID>
    ) async throws -> ScanData<Peripheral, Advertisement> {
        let device = try await bluetooth.requestDevice(services: Array(services))
        let peripheral = Peripheral(id: device.id)
        self.cache = Cache()
        self.cache.devices[peripheral] = device
        return ScanData(
            peripheral: Peripheral(id: device.id),
            date: Date(),
            rssi: -127,
            advertisementData: Advertisement(localName: device.name),
            isConnectable: true
        )
    }
    
    /// Connect to the specified device
    public func connect(to peripheral: Peripheral) async throws {
        guard let device = self.cache.devices[peripheral] else {
            throw CentralError.unknownPeripheral
        }
        try await device.remoteServer.connect()
    }
    
    /// Disconnect the specified device.
    public func disconnect(_ peripheral: Peripheral) {
        guard let device = self.cache.devices[peripheral] else {
            return
        }
        device.remoteServer.disconnect()
    }
    
    /// Disconnect all connected devices.
    public func disconnectAll() {
        self.cache.devices.values.forEach {
            $0.remoteServer.disconnect()
        }
    }
    
    /// Discover Services
    public func discoverServices(
        _ serviceUUIDs: Set<BluetoothUUID>,
        for peripheral: Peripheral
    ) async throws -> [Service<Peripheral, AttributeID>] {
        guard serviceUUIDs.isEmpty == false else {
            print("UUIDs are required for service discovery")
            return []
        }
        guard let device = self.cache.devices[peripheral] else {
            throw CentralError.unknownPeripheral
        }
        // discover
        var serviceObjects = [JSBluetoothRemoteGATTService]()
        serviceObjects.reserveCapacity(serviceUUIDs.count)
        for uuid in serviceUUIDs {
            let serviceObject = try await device.remoteServer.primaryService(for: uuid)
            serviceObjects.append(serviceObject)
        }
        let services = serviceObjects.map { serviceObject in
            Service(
                id: serviceObject.uuid,
                uuid: serviceObject.uuid,
                peripheral: peripheral,
                isPrimary: serviceObject.isPrimary
            )
        }
        // cache
        for (index, service) in services.enumerated() {
            let serviceObject = serviceObjects[index]
            self.cache.services[service] = serviceObject
        }
        return services
    }
    
    /// Discover Characteristics for service
    public func discoverCharacteristics(
        _ characteristicUUIDs: Set<BluetoothUUID>,
        for service: Service<Peripheral, AttributeID>
    ) async throws -> [Characteristic<Peripheral, AttributeID>] {
        guard characteristicUUIDs.isEmpty == false else {
            print("UUIDs are required for characteristic discovery")
            return []
        }
        guard let _ = self.cache.devices[service.peripheral] else {
            throw CentralError.unknownPeripheral
        }
        guard let serviceObject = self.cache.services[service] else {
            throw CentralError.invalidAttribute(service.uuid)
        }
        // discover
        var characteristicObjects = [JSBluetoothRemoteGATTCharacteristic]()
        characteristicObjects.reserveCapacity(characteristicUUIDs.count)
        for uuid in characteristicUUIDs {
            let characteristicObject = try await serviceObject.characteristic(for: uuid)
            characteristicObjects.append(characteristicObject)
        }
        let characteristics = characteristicObjects.map { characteristicObject in
            Characteristic(
                id: characteristicObject.uuid,
                uuid: characteristicObject.uuid,
                peripheral: service.peripheral, // TODO:
                properties: [] //characteristicObject.properties
            )
        }
        // cache
        for (index, characteristic) in characteristics.enumerated() {
            let characteristicObject = characteristicObjects[index]
            self.cache.characteristics[characteristic] = characteristicObject
        }
        return characteristics
    }
    
    /// Read Characteristic Value
    public func readValue(
        for characteristic: Characteristic<Peripheral, AttributeID>
    ) async throws -> Data {
        fatalError()
    }
    
    /// Write Characteristic Value
    public func writeValue(
        _ data: Data,
        for characteristic: Characteristic<Peripheral, AttributeID>,
        withResponse: Bool
    ) async throws {
        
    }
    
    /// Discover descriptors
    public func discoverDescriptors(
        for characteristic: Characteristic<Peripheral, AttributeID>
    ) async throws -> [Descriptor<Peripheral, AttributeID>] {
        fatalError()
    }
    
    /// Read descriptor
    public func readValue(
        for descriptor: Descriptor<Peripheral, AttributeID>
    ) async throws -> Data {
        fatalError()
    }
    
    /// Write descriptor
    public func writeValue(
        _ data: Data,
        for descriptor: Descriptor<Peripheral, AttributeID>
    ) async throws {
        
    }
    
    /// Start Notifications
    public func notify(
        for characteristic: Characteristic<Peripheral, AttributeID>
    ) async throws -> AsyncThrowingStream<Data, Error> {
        fatalError()
    }
    
    // Stop Notifications
    public func stopNotifications(for characteristic: Characteristic<Peripheral, AttributeID>) async throws {
        
    }
    
    /// Read MTU
    public func maximumTransmissionUnit(for peripheral: Peripheral) async throws -> MaximumTransmissionUnit {
        return .default
    }
}

// MARK: - Supporting Types

public extension WebCentral {
    
    struct Peripheral: Peer, Identifiable {
        
        public let id: String
    }
    
    typealias AttributeID = BluetoothUUID
    
    struct Advertisement: AdvertisementData {
        
        /// The local name of a peripheral.
        public let localName: String?
        
        /// The Manufacturer data of a peripheral.
        public var manufacturerData: ManufacturerSpecificData? { return nil }
        
        /// This value is available if the broadcaster (peripheral) provides its Tx power level in its advertising packet.
        /// Using the RSSI value and the Tx power level, it is possible to calculate path loss.
        public var txPowerLevel: Double? { return nil }
        
        /// Service-specific advertisement data.
        public var serviceData: [BluetoothUUID: Data]? { return nil }
        
        /// An array of service UUIDs
        public var serviceUUIDs: [BluetoothUUID]? { return nil }
        
        /// An array of one or more `BluetoothUUID`, representing Service UUIDs.
        public var solicitedServiceUUIDs: [BluetoothUUID]? { return nil }
    }
}

internal extension WebCentral {
    
    struct Cache {
        
        var devices = [Peripheral: JSBluetoothDevice]()
        
        var services = [Service<Peripheral, AttributeID>: JSBluetoothRemoteGATTService]()
        
        var characteristics = [Characteristic<Peripheral, AttributeID>: JSBluetoothRemoteGATTCharacteristic]()
    }
}

extension BluetoothUUID: ConvertibleToJSValue {
    
    /*
     Bluetooth Web API
     
     It must be a valid UUID alias (e.g. 0x1234), UUID (lowercase hex characters e.g. '00001234-0000-1000-8000-00805f9b34fb'), or recognized standard name from https://www.bluetooth.com/specifications/gatt/services e.g. 'alert_notification'.
     */
    public func jsValue() -> JSValue {
        switch self {
        case let .bit16(value):
            return .number(Double(value))
        case let .bit32(value):
            return .number(Double(value))
        case let .bit128(value):
            return .string(UUID(value).uuidString.lowercased())
        }
    }
}

extension BluetoothUUID: ConstructibleFromJSValue {
    
    public static func construct(from value: JSValue) -> BluetoothUUID? {
        switch value {
        case let .string(string):
            return BluetoothUUID(web: string.description)
        case let .number(number):
            return .bit16(UInt16(number))
        default:
            return nil
        }
    }
    
    public init?(web string: String) {
        var string = string.uppercased()
        let suffix = "-0000-1000-8000-00805F9B34FB"
        let prefix = "0000"
        if string.count == UUID.stringLength,
           string.hasSuffix(suffix),
            string.hasPrefix(prefix) {
            string.removeFirst(prefix.count)
            string.removeLast(suffix.count)
            guard string.count == 4, let number = UInt16(hexadecimal: string) else {
                return nil
            }
            self = .bit16(number)
        } else {
            self.init(rawValue: string)
        }
    }
}
