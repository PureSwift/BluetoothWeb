//
//  JSBluetoothRemoteGATTServer.swift
//  
//
//  Created by Alsey Coleman Miller on 6/3/20.
//

import JavaScriptKit

/// Represents a GATT Server on a remote device.
// https://developer.mozilla.org/en-US/docs/Web/API/BluetoothRemoteGATTServer
public final class JSBluetoothRemoteGATTServer: JSBridgedClass {
    
    public static let constructor = JSObject.global.BluetoothRemoteGATTServer.function!
    
    // MARK: - Properties
    
    public let jsObject: JSObject
    
    // MARK: - Initialization

    public required init(unsafelyWrapping jsObject: JSObject) {
        self.jsObject = jsObject
    }
    
    public required init(unsafelyWrapping jsObject: JSObject,
                         device: JSBluetoothDevice) {
        self.jsObject = jsObject
        self.device = device
    }
    
    // MARK: - Accessors
    
    public private(set) weak var device: JSBluetoothDevice?
    
    public var isConnected: Bool {
        return jsObject.connected.boolean ?? false
    }
    
    // MARK: - Methods
    
    /// Causes the script execution environment to connect to this device.
    public func connect() async throws {
        guard let function = jsObject.connect.function
            else { fatalError("Missing function \(#function)") }
        let result = function.callAsFunction(this: jsObject)
        guard let promise = result.object.flatMap({ JSPromise($0) })
            else { fatalError("Invalid object \(result)") }
        let _ = try await promise.get()
    }
    
    /// Causes the script execution environment to disconnect from this device.
    public func disconnect() {
        guard let function = jsObject.disconnect.function
            else { fatalError("Missing function \(#function)") }
        let _ = function.callAsFunction(this: jsObject)
    }
    
    /// Returns a promise to the primary BluetoothGATTService offered by the bluetooth device for a specified BluetoothServiceUUID.
    ///
    /// - Parameter uuid: A Bluetooth service universally unique identifier for a specified device.
    public func primaryService(for uuid: BluetoothUUID) async throws -> JSBluetoothRemoteGATTService {
        guard let function = jsObject.getPrimaryService.function
            else { fatalError("Missing function \(#function)") }
        let result = function.callAsFunction(this: jsObject, uuid)
        guard let promise = result.object.flatMap({ JSPromise($0) })
            else { fatalError("Invalid object \(result)") }
        let value = try await promise.get()
        return value.object.flatMap({ JSBluetoothRemoteGATTService(unsafelyWrapping: $0) })!
    }
}
