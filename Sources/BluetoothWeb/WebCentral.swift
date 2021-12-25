//
//  CentralManager.swift
//  
//
//  Created by Alsey Coleman Miller on 24/12/21.
//

import Foundation

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
    
    public func scan() async throws -> AsyncThrowingStream<Peripheral, Error> {
        let device = try await bluetooth.requestDevice()
        print(device)
        return AsyncThrowingStream<Peripheral, Error> { continuation in
            Task {
                let devices = [device].compactMap { $0 } //await bluetooth.devices
                    .map { Peripheral(id: $0.id) }
                devices.forEach {
                    continuation.yield($0)
                }
                continuation.finish(throwing: nil)
            }
        }
    }
    
    public func scan() async throws -> [Peripheral] {
        guard let device = try await bluetooth.requestDevice() else {
            return []
        }
        return [device].map {
            Peripheral(id: $0.id)
            
        }
    }
}

public extension WebCentral {
    
    struct Peripheral: Equatable, Hashable, Identifiable { // Peer
        
        public let id: String
    }
}
