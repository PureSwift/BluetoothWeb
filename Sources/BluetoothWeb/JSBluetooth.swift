//
//  JSBluetooth.swift
//  
//
//  Created by Alsey Coleman Miller on 6/3/20.
//

import JavaScriptKit

/// JavaScript Bluetooth interface
/// 
/// - SeeAlso: [Web Bluetooth API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Bluetooth_API)
public final class JSBluetooth {
    
    // MARK: - Properties
    
    internal let jsObject: JSObject
    
    // MARK: - Initialization

    internal init?(_ jsObject: JSObject) {
        self.jsObject = jsObject
    }
    
    public static let shared: JSBluetooth? = JSObject.global
        .navigator.object?
        .bluetooth.object
        .flatMap { JSBluetooth($0) }
    
    // MARK: - Accessors
    
    /**
     Returns a Promise that resolved to a Boolean indicating whether the user-agent has the ability to support Bluetooth. Some user-agents let the user configure an option that affects what is returned by this value. If this option is set, that is the value returned by this method.
     */
    public var isAvailable: Bool {
        get async {
            guard let function = jsObject.getAvailability.function,
                  let promise = function.callAsFunction(this: jsObject).object.flatMap({ JSPromise($0) })
                else { return false }
            do { return try await promise.get().boolean ?? false }
            catch { return false }
        }
    }
    
    /**
     Returns a `Promise` that resolved to an array of `BluetoothDevice` which the origin already obtained permission for via a call to `Bluetooth.requestDevice()`.
     */
    public var devices: JSPromise {
        /*
        guard let function = jsObject.getDevices.function
            else { fatalError("Invalid function \(#function)") }
        */
       fatalError()
    }
    
    // MARK: - Methods
    
    /// Returns a Promise to a BluetoothDevice object with the specified options.
    /// If there is no chooser UI, this method returns the first device matching the criteria.
    ///
    /// - Returns: A Promise to a `BluetoothDevice` object.
    public func requestDevice() async -> JSBluetoothDevice {
        let options = RequestDeviceOptions(
            filters: nil,
            optionalServices: nil,
            acceptAllDevices: true
        )
        return await requestDevice(options: options)
    }
    
    /// Returns a Promise to a BluetoothDevice object with the specified options.
    /// If there is no chooser UI, this method returns the first device matching the criteria.
    ///
    /// - Returns: A Promise to a `BluetoothDevice` object.
    internal func requestDevice(
        options: RequestDeviceOptions
    ) async -> JSBluetoothDevice {
        
        // Bluetooth.requestDevice([options])
        // .then(function(bluetoothDevice) { ... })
        /*
        guard let function = jsObject.requestDevice.function
            else { fatalError("Invalid function \(#function)") }
        let result = function.apply(this: jsObject, arguments: options)
        guard let promise = result.object.flatMap({ JSPromise($0) })
            else { fatalError("Invalid object \(result)") }
        return promise
         */
        fatalError()
    }
}

// MARK: - Supporting Types

public extension JSBluetooth {
    
    struct ScanFilter: Equatable, Hashable, Codable {
                
        public var services: [String]?
        
        public var name: String?
        
        public var namePrefix: String?
        
        public init(services: [String]? = nil,
                    name: String? = nil,
                    namePrefix: String? = nil) {
            self.services = services
            self.name = name
            self.namePrefix = namePrefix
        }
    }
}

internal extension JSBluetooth {
    
    struct RequestDeviceOptions: Encodable {
        
        var filters: [ScanFilter]?
        
        var optionalServices: [String]?
        
        var acceptAllDevices: Bool?
    }
}

internal extension JSPromise {
    /// Wait for the promise to complete, returning (or throwing) its result.
    func get() async throws -> JSValue {
        return try await withUnsafeThrowingContinuation { [self] continuation in
                self.then(
                    success: {
                        continuation.resume(returning: $0)
                        return JSValue.undefined
                    },
                    failure: {
                        continuation.resume(throwing: $0)
                        return JSValue.undefined
                    }
                )
            }
    }
}
