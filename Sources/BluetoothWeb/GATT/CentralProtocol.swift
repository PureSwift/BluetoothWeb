//
//  Central.swift
//  GATT
//
//  Created by Alsey Coleman Miller on 4/3/16.
//  Copyright © 2016 PureSwift. All rights reserved.
//

#if swift(>=5.5)
import Foundation
// import Bluetooth

/// GATT Central Manager
///
/// Implementation varies by operating system and framework.
@available(macOS 10.5, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public protocol CentralManager {
    
    /// Central Peripheral Type
    associatedtype Peripheral: Peer
    
    /// Central Advertisement Type
    associatedtype Advertisement: AdvertisementData
    
    /// Central Attribute ID (Handle)
    associatedtype AttributeID: Hashable
    
    #if os(WASI)
    func scan(with services: Set<BluetoothUUID>) async throws -> ScanData<Peripheral, Advertisement>
    #else
    /// Scans for peripherals that are advertising services.
    func scan(
        with services: Set<BluetoothUUID>,
        filterDuplicates: Bool
    ) -> AsyncThrowingStream<ScanData<Peripheral, Advertisement>, Error>
    
    /// Stops scanning for peripherals.
    func stopScan() async
    #endif
    
    /// Connect to the specified device
    func connect(to peripheral: Peripheral) async throws
    
    /// Disconnect the specified device.
    func disconnect(_ peripheral: Peripheral) async
    
    /// Disconnect all connected devices.
    func disconnectAll() async
    
    /// Discover Services
    func discoverServices(
        _ services: Set<BluetoothUUID>,
        for peripheral: Peripheral
    ) async throws -> [Service<Peripheral, AttributeID>]
    
    /// Discover Characteristics for service
    func discoverCharacteristics(
        _ characteristics: Set<BluetoothUUID>,
        for service: Service<Peripheral, AttributeID>
    ) async throws -> [Characteristic<Peripheral, AttributeID>]
    
    /// Read Characteristic Value
    func readValue(
        for characteristic: Characteristic<Peripheral, AttributeID>
    ) async throws -> Data
    
    /// Write Characteristic Value
    func writeValue(
        _ data: Data,
        for characteristic: Characteristic<Peripheral, AttributeID>,
        withResponse: Bool
    ) async throws
    
    /// Discover descriptors
    func discoverDescriptors(
        for characteristic: Characteristic<Peripheral, AttributeID>
    ) async throws -> [Descriptor<Peripheral, AttributeID>]
    
    /// Read descriptor
    func readValue(
        for descriptor: Descriptor<Peripheral, AttributeID>
    ) async throws -> Data
    
    /// Write descriptor
    func writeValue(
        _ data: Data,
        for descriptor: Descriptor<Peripheral, AttributeID>
    ) async throws
    
    /// Start Notifications
    func notify(
        for characteristic: Characteristic<Peripheral, AttributeID>
    ) async throws -> AsyncThrowingStream<Data, Error>
    
    // Stop Notifications
    func stopNotifications(for characteristic: Characteristic<Peripheral, AttributeID>) async throws
    
    /// Read MTU
    func maximumTransmissionUnit(for peripheral: Peripheral) async throws -> MaximumTransmissionUnit
    
    #if !os(WASI)
    // Read RSSI
    func rssi(for peripheral: Peripheral) async throws -> RSSI
    #endif
}

#endif
