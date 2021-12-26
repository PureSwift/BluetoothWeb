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
public final class JSBluetooth: JSBridgedClass {
    
    public static let constructor = JSObject.global.Bluetooth.function!
    
    // MARK: - Properties
    
    public let jsObject: JSObject
    
    // MARK: - Initialization
    
    public required init(unsafelyWrapping jsObject: JSObject) {
        self.jsObject = jsObject
    }
    
    public static let shared: JSBluetooth? = JSObject.global
        .navigator.object?
        .bluetooth.object
        .flatMap { JSBluetooth(unsafelyWrapping: $0) }
    
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
     
    - SeeAlso: [Web Bluetooth API](https://developer.mozilla.org/en-US/docs/Web/API/Bluetooth/getDevices)
     */
    public var devices: [JSBluetoothDevice] {
        get async {
            guard let function = jsObject.getDevices.function,
                  let promise = function.callAsFunction(this: jsObject).object.flatMap({ JSPromise($0) })
                else { fatalError("Invalid function \(#function)") }
            do {
                let result = try await promise.get()
                let array = JSArray(unsafelyWrapping: result.object!)
                return array.map { JSBluetoothDevice(unsafelyWrapping: $0.object!) }
            }
            catch {
                return []
            }
        }
    }
    
    // MARK: - Methods
    
    /// Returns a Promise to a BluetoothDevice object with the specified options.
    /// If there is no chooser UI, this method returns the first device matching the criteria.
    ///
    /// - Returns: A Promise to a `BluetoothDevice` object.
    public func requestDevice(services: [BluetoothUUID]) async throws -> JSBluetoothDevice {
        let options = RequestDeviceOptions(
            filters: nil,
            optionalServices: services,
            acceptAllDevices: true
        )
        return try await requestDevice(options: options)
    }
    
    /// Returns a Promise to a BluetoothDevice object with the specified options.
    /// If there is no chooser UI, this method returns the first device matching the criteria.
    ///
    /// - Returns: A Promise to a `BluetoothDevice` object.
    internal func requestDevice(
        options: RequestDeviceOptions
    ) async throws -> JSBluetoothDevice {
        
        // Bluetooth.requestDevice([options])
        // .then(function(bluetoothDevice) { ... })
        
        // TODO: Customize options
        let optionsArg: [String: ConvertibleToJSValue] = [
            "acceptAllDevices": true,
            "optionalServices": options.optionalServices ?? [] as [ConvertibleToJSValue]
        ]
        guard let function = jsObject.requestDevice.function
            else { fatalError("Invalid function \(#function)") }
        let result = function.callAsFunction(this: jsObject, arguments: [optionsArg])
        guard let promise = result.object.flatMap({ JSPromise($0) })
            else { fatalError("Invalid object \(result)") }
        return try await promise.get().object.flatMap({ JSBluetoothDevice(unsafelyWrapping: $0) })!
    }
}

// MARK: - Supporting Types

public extension JSBluetooth {
    
    struct ScanFilter: Equatable, Hashable, Codable {
                
        public var services: [BluetoothUUID]?
        
        public var name: String?
        
        public var namePrefix: String?
        
        public init(services: [BluetoothUUID]? = nil,
                    name: String? = nil,
                    namePrefix: String? = nil) {
            self.services = services
            self.name = name
            self.namePrefix = namePrefix
        }
    }
}

public extension JSBluetooth {
    
    struct RequestDeviceOptions: Encodable {
        
        var filters: [ScanFilter]?
        
        var optionalServices: [BluetoothUUID]?
        
        var acceptAllDevices: Bool?
    }
}

// MARK: - Extensions

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
                    let error: Error = $0.object.flatMap { JSError(unsafelyWrapping: $0) } ?? $0
                    continuation.resume(throwing: error)
                    return JSValue.undefined
                }
            )
        }
    }
}
