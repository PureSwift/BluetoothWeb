//
//  JSBluetoothRemoteGATTServer.swift
//  
//
//  Created by Alsey Coleman Miller on 6/3/20.
//


import JavaScriptKit

/// Represents a GATT Server on a remote device.
// https://developer.mozilla.org/en-US/docs/Web/API/BluetoothRemoteGATTServer
public final class JSBluetoothRemoteGATTServer {
    
    // MARK: - Properties
    
    internal let jsObject: JSObject
    
    // MARK: - Initialization

    internal init?(_ jsObject: JSObject) {
        self.jsObject = jsObject
    }
    
    // MARK: - Accessors
    
    public var isConnected: Bool {
        return jsObject.connected.boolean ?? false
    }
    
    // MARK: - Methods
    
    /// Causes the script execution environment to connect to this device.
    public func connect() async throws -> JSBluetoothRemoteGATTServer {
        /*
        guard let function = jsObject.connect.function
            else { fatalError("Missing function \(#function)") }
        let result = function.apply(this: jsObject)
        guard let promise = result.object.flatMap({ JSPromise<JSBluetoothRemoteGATTServer>($0) })
            else { fatalError("Invalid object \(result)") }
        return promise
         */
        fatalError()
    }
    
    /// Causes the script execution environment to disconnect from this device.
    public func disconnect() {
        /*
        guard let function = jsObject.disconnect.function
            else { fatalError("Missing function \(#function)") }
        function.apply(this: jsObject)
         */
        fatalError()
    }
    
    /// Returns a promise to the primary BluetoothGATTService offered by the bluetooth device for a specified BluetoothServiceUUID.
    ///
    /// - Parameter uuid: A Bluetooth service universally unique identifier for a specified device.
    public func getPrimaryService(_ uuid: String) async throws -> JSBluetoothRemoteGATTService {
        /*
        guard let function = jsObject.getPrimaryService.function
            else { fatalError("Missing function \(#function)") }
        let result = function.apply(this: jsObject, arguments: uuid)
        guard let value = result.object.flatMap({ JSPromise<JSBluetoothRemoteGATTService>($0) })
            else { fatalError("Invalid object \(result)") }
        return value
         */
        fatalError()
    }
}
