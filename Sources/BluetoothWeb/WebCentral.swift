//
//  CentralManager.swift
//  
//
//  Created by Alsey Coleman Miller on 24/12/21.
//

import Foundation
// import Bluetooth

public final class WebCentral { //: CentralManager {
    
    public static let shared: WebCentral? = {
        guard let jsBluetooth = JSBluetooth.shared else {
            return nil
        }
        let central = WebCentral(jsBluetooth)
        return central
    }()
    
    internal let bluetooth: JSBluetooth
    
    internal init(_ bluetooth: JSBluetooth) {
        self.bluetooth = bluetooth
    }
    
    public var isAvailable: Bool {
        get async {
            await bluetooth.isAvailable
        }
    }
    
    public func scan() async throws -> ScanData<Peripheral, Advertisement> {
        let device = try await bluetooth.requestDevice()
        return ScanData(
            peripheral: Peripheral(id: device.id),
            date: Date(),
            rssi: -127,
            advertisementData: Advertisement(localName: device.name),
            isConnectable: true
        )
    }
}

public extension WebCentral {
    
    struct Peripheral: Peer, Identifiable {
        
        public let id: String
    }
    
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
