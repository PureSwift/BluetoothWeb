//
//  JSBluetoothCharacteristicProperties.swift
//  
//
//  Created by Alsey Coleman Miller on 25/12/21.
//

import JavaScriptKit
import Bluetooth
import GATT

/*
 The [`BluetoothCharacteristicProperties`](https://developer.mozilla.org/en-US/docs/Web/API/BluetoothCharacteristicProperties) interface of the [Web Bluetooth API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Bluetooth_API) provides the operations that are valid on the given [1BluetoothRemoteGATTCharacteristic1](https://developer.mozilla.org/en-US/docs/Web/API/BluetoothRemoteGATTCharacteristic).

 This interface is returned by calling [`BluetoothRemoteGATTCharacteristic.properties`](https://developer.mozilla.org/en-US/docs/Web/API/BluetoothRemoteGATTCharacteristic/properties).
 */
public final class JSBluetoothCharacteristicProperties: JSBridgedClass {
    
    public static var constructor: JSFunction? { JSObject.global.BluetoothCharacteristicProperties.function }
    
    // MARK: - Properties
    
    public let jsObject: JSObject
    
    public private(set) weak var characteristic: JSBluetoothRemoteGATTCharacteristic?
    
    // MARK: - Initialization

    public required init(unsafelyWrapping jsObject: JSObject) {
        self.jsObject = jsObject
    }
    
    public required init(unsafelyWrapping jsObject: JSObject, characteristic: JSBluetoothRemoteGATTCharacteristic) {
        self.jsObject = jsObject
        self.characteristic = characteristic
    }
    
    // MARK: - Accessors
    
    /// Returns a boolean that is `true` if signed writing to the characteristic value is permitted.
    public var authenticatedSignedWrites: Bool {
        return jsObject.authenticatedSignedWrites.boolean ?? false
    }
    
    /// Returns a boolean that is `true` if the broadcast of the characteristic value is permitted using the Server Characteristic Configuration Descriptor.
    public var broadcast: Bool {
        return jsObject.broadcast.boolean ?? false
    }
    
    /// Returns a boolean that is true if indications of the characteristic value with acknowledgement is permitted.
    public var indicate: Bool {
        return jsObject.indicate.boolean ?? false
    }
    
    /// Returns a boolean that is true if notifications of the characteristic value without acknowledgement is permitted.
    public var notify: Bool {
        return jsObject.notify.boolean ?? false
    }
    
    /// Returns a boolean that is true if the reading of the characteristic value is permitted.
    public var read: Bool {
        return jsObject.read.boolean ?? false
    }
    
    /// Returns a boolean that is true if reliable writes to the characteristic is permitted.
    public var reliableWrite: Bool {
        return jsObject.reliableWrite.boolean ?? false
    }
    
    /// Returns a boolean that is true if reliable writes to the characteristic descriptor is permitted.
    public var writableAuxiliaries: Bool {
        return jsObject.writableAuxiliaries.boolean ?? false
    }
    
    /// Returns a boolean that is true if the writing to the characteristic with response is permitted.
    public var write: Bool {
        return jsObject.write.boolean ?? false
    }
    
    /// Returns a boolean that is true if the writing to the characteristic without response is permitted.
    public var writeWithoutResponse: Bool {
        return jsObject.writeWithoutResponse.boolean ?? false
    }
}

extension GATT.CharacteristicProperties {
    
    init(_ jsValue: JSBluetoothCharacteristicProperties) {
        self.init()
        if jsValue.authenticatedSignedWrites {
            insert(.signedWrite)
        }
        if jsValue.broadcast {
            insert(.broadcast)
        }
        if jsValue.indicate {
            insert(.indicate)
        }
        if jsValue.notify {
            insert(.notify)
        }
        if jsValue.read {
            insert(.read)
        }
        if jsValue.write {
            insert(.write)
        }
        if jsValue.writeWithoutResponse {
            insert(.writeWithoutResponse)
        }
    }
}
