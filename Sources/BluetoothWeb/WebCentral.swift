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
public final class WebCentral: CentralManager {
    
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
    
    private var continuation = Continuation()
        
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
        guard device.remoteServer.isConnected else {
            throw CentralError.disconnected
        }
        // discover
        var services = [Service<Peripheral, AttributeID>: JSBluetoothRemoteGATTService]()
        services.reserveCapacity(serviceUUIDs.count)
        for uuid in serviceUUIDs.lazy.sorted(by: { $0.rawValue < $1.rawValue }) {
            do {
                let serviceObject = try await device.remoteServer.primaryService(for: uuid)
                let service = Service(
                    id: newAttributeID(for: peripheral),
                    uuid: serviceObject.uuid,
                    peripheral: peripheral,
                    isPrimary: serviceObject.isPrimary
                )
                services[service] = serviceObject
                // cache
                self.cache.services[service] = serviceObject
            }
            catch let error as JSError {
                if error.jsObject.NotFoundError != nil {
                    continue
                }
                throw error
            }
            catch let error as JSValue {
                if error.NotFoundError != nil {
                    continue
                }
                throw error
            }
            catch {
                throw error
            }
        }
        return services.keys.sorted(by: { $0.id < $1.id })
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
        guard let device = self.cache.devices[service.peripheral] else {
            throw CentralError.unknownPeripheral
        }
        guard device.remoteServer.isConnected else {
            throw CentralError.disconnected
        }
        guard let serviceObject = self.cache.services[service] else {
            throw CentralError.invalidAttribute(service.uuid)
        }
        // discover
        var characteristics = [Characteristic<Peripheral, AttributeID>: JSBluetoothRemoteGATTCharacteristic]()
        characteristics.reserveCapacity(characteristicUUIDs.count)
        for uuid in characteristicUUIDs.lazy.sorted(by: { $0.rawValue < $1.rawValue }) {
            do {
                let characteristicObject = try await serviceObject.characteristic(for: uuid)
                let characteristic = Characteristic(
                    id: newAttributeID(for: service.peripheral),
                    uuid: characteristicObject.uuid,
                    peripheral: service.peripheral,
                    properties: characteristicObject.properties.bitmask
                )
                characteristics[characteristic] = characteristicObject
                self.cache.characteristics[characteristic] = characteristicObject
            }
            catch let error as JSError {
                if error.jsObject.NotFoundError != nil {
                    continue
                }
                throw error
            }
            catch let error as JSValue {
                if error.NotFoundError != nil {
                    continue
                }
                throw error
            }
            catch {
                throw error
            }
        }
        return characteristics.keys.sorted(by: { $0.id < $1.id })
    }
    
    /// Read Characteristic Value
    public func readValue(
        for characteristic: Characteristic<Peripheral, AttributeID>
    ) async throws -> Data {
        guard let device = self.cache.devices[characteristic.peripheral] else {
            throw CentralError.unknownPeripheral
        }
        guard device.remoteServer.isConnected else {
            throw CentralError.disconnected
        }
        guard let characteristicObject = self.cache.characteristics[characteristic] else {
            throw CentralError.invalidAttribute(characteristic.uuid)
        }
        let dataView = try await characteristicObject.readValue()
        return Data(dataView)
    }
    
    /// Write Characteristic Value
    public func writeValue(
        _ data: Data,
        for characteristic: Characteristic<Peripheral, AttributeID>,
        withResponse: Bool
    ) async throws {
        guard let device = self.cache.devices[characteristic.peripheral] else {
            throw CentralError.unknownPeripheral
        }
        guard device.remoteServer.isConnected else {
            throw CentralError.disconnected
        }
        guard let characteristicObject = self.cache.characteristics[characteristic] else {
            throw CentralError.invalidAttribute(characteristic.uuid)
        }
        let dataView = JSDataView(data)
        if withResponse {
            try await characteristicObject.writeValueWithResponse(dataView)
        } else {
            try await characteristicObject.writeValueWithoutResponse(dataView)
        }
    }
    
    /// Discover descriptors
    public func discoverDescriptors(
        for characteristic: Characteristic<Peripheral, AttributeID>
    ) async throws -> [Descriptor<Peripheral, AttributeID>] {
        return []
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
        guard let device = self.cache.devices[characteristic.peripheral] else {
            throw CentralError.unknownPeripheral
        }
        guard device.remoteServer.isConnected else {
            throw CentralError.disconnected
        }
        guard let characteristicObject = self.cache.characteristics[characteristic] else {
            throw CentralError.invalidAttribute(characteristic.uuid)
        }
        let closure = JSClosure { values in
            self.recievedNotification(characteristic, values)
            return .undefined
        }
        try await characteristicObject.startNotifications()
        return AsyncThrowingStream<Data, Error> { [unowned self] continuation in
            self.continuation.notifications[characteristic] = (closure, continuation)
            characteristicObject.addEventListener(
                "characteristicvaluechanged",
                closure
            )
        }
    }
    
    // Stop Notifications
    public func stopNotifications(for characteristic: Characteristic<Peripheral, AttributeID>) async throws {
        guard let device = self.cache.devices[characteristic.peripheral] else {
            throw CentralError.unknownPeripheral
        }
        guard device.remoteServer.isConnected else {
            throw CentralError.disconnected
        }
        guard let characteristicObject = self.cache.characteristics[characteristic] else {
            throw CentralError.invalidAttribute(characteristic.uuid)
        }
        guard let (closure, continuation) = self.continuation.notifications[characteristic] else {
            assertionFailure("Missing notification continuation for \(characteristic.uuid)")
            return
        }
        characteristicObject.removeEventListener(
            "characteristicvaluechanged",
            closure
        )
        // stop registering for notification
        do { try await characteristicObject.stopNotifications() }
        catch {
            continuation.finish(throwing: error)
            throw error
        }
        continuation.finish(throwing: nil)
    }
    
    /// Read MTU
    public func maximumTransmissionUnit(for peripheral: Peripheral) async throws -> MaximumTransmissionUnit {
        return .default
    }
    
    // MARK: - Private Methods
    
    private func newAttributeID(for peripheral: Peripheral) -> AttributeID {
        return self.cache.attributeIDs[peripheral, default: Counter()].increment()
    }
    
    private func recievedNotification(
        _ characteristic: Characteristic<Peripheral, AttributeID>,
        _ values: [JSValue]
    ) {
        print(#function, characteristic.uuid, values)
        guard let (_, continuation) = self.continuation.notifications[characteristic] else {
            assertionFailure("Missing notification continuation for \(characteristic.uuid)")
            return
        }
        guard let dataView = values.first?.target.value.object.flatMap({ JSDataView(unsafelyWrapping: $0) }) else {
            assertionFailure("Missing notification continuation for \(characteristic.uuid)")
            return
        }
        let data = Data(dataView)
        continuation.yield(data)
    }
}

#if canImport(Darwin)
@available(*, deprecated, message: "Should not run on macOS")
public extension WebCentral {
    
    func scan(with services: Set<BluetoothUUID>, filterDuplicates: Bool) -> AsyncThrowingStream<ScanData<Peripheral, Advertisement>, Error> {
        fatalError("Should not run on macOS")
    }
    
    func stopScan() async {
        fatalError("Should not run on macOS")
    }
    
    func rssi(for peripheral: Peripheral) async throws -> RSSI {
        fatalError("Should not run on macOS")
    }
}
#endif

// MARK: - Supporting Types

public extension WebCentral {
    
    struct Peripheral: Peer, Identifiable {
        
        public let id: String
    }
    
    typealias AttributeID = UInt64
    
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
        
        var attributeIDs = [Peripheral: Counter]()
        
        var services = [Service<Peripheral, AttributeID>: JSBluetoothRemoteGATTService]()
        
        var characteristics = [Characteristic<Peripheral, AttributeID>: JSBluetoothRemoteGATTCharacteristic]()
    }
    
    struct Continuation {
        
        var notifications = [Characteristic<Peripheral, AttributeID> : (JSClosure, AsyncThrowingStream<Data, Error>.Continuation)]()
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

struct Counter: Equatable, Hashable, RawRepresentable {
    var rawValue: UInt64
    init(rawValue: UInt64 = 0) {
        self.rawValue = rawValue
    }
    mutating func increment() -> RawValue {
        let oldValue = rawValue
        if oldValue == .max {
            rawValue = 0
        } else {
            rawValue += 1
        }
        return oldValue
    }
}
