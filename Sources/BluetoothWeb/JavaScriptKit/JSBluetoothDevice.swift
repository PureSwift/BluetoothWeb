//
//  JSBluetoothDevice.swift
//  
//
//  Created by Alsey Coleman Miller on 6/3/20.
//


import JavaScriptKit

/// JavaScript Bluetooth Device object.
public final class JSBluetoothDevice: JSBridgedClass {
    
    public static let constructor = JSObject.global.BluetoothDevice.function!
    
    // MARK: - Properties
    
    public let jsObject: JSObject
    
    // MARK: - Initialization

    public required convenience init?(from value: JSValue) {
        guard let object = value.object else { return nil }
        self.init(object)
    }

    /// Construct a `JSArray` from Array `JSObject`.
    /// Return `nil` if the object is not an Array.
    ///
    /// - Parameter object: A `JSObject` expected to be a JavaScript Array
    public convenience init?(_ jsObject: JSObject) {
        //guard Self.validate(jsObject) else { return nil }
        self.init(unsafelyWrapping: jsObject)
    }

    public required init(unsafelyWrapping jsObject: JSObject) {
        self.jsObject = jsObject
    }
    
    // MARK: - Accessors
    
    /// A string that uniquely identifies a device.
    public lazy var id: String = self.jsObject["id"].string ?? "Error"
    
    /// A string that provices a human-readable name for the device.
    public var name: String? {
        return self.jsObject.name.string
    }
    
    /// Interface of the Web Bluetooth API represents a GATT Server on a remote device.
    public lazy var gatt = self.jsObject.gatt.object.flatMap({ JSBluetoothRemoteGATTServer($0) })!
}

// MARK: - CustomStringConvertible

extension JSBluetoothDevice: CustomStringConvertible {
    
    public var description: String {
        return "JSBluetoothDevice(id: \(id), name: \(name ?? "nil"))"
    }
}

// MARK: - Identifiable

extension JSBluetoothDevice: Identifiable { }
