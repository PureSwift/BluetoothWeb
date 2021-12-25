//
//  JSBluetoothRemoteGattCharacteristic.swift
//
//
//  Created by Alsey Coleman Miller on 25/12/21.
//

import Foundation
import JavaScriptKit

/**
 JavaScript Bluetooth GATT Descriptor
 
 The [`BluetoothRemoteGATTCharacteristic`](https://developer.mozilla.org/en-US/docs/Web/API/BluetoothRemoteGattDescriptor) interface of the [Web Bluetooth API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Bluetooth_API) represents a GATT Descriptor, which is a basic data element that provides further information about a peripheral’s service.
 */
public final class JSBluetoothRemoteGATTDescriptor: JSBridgedClass {
    
    public static let constructor = JSObject.global.BluetoothRemoteGATTDescriptor.function!
    
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
    
    public lazy var uuid: BluetoothUUID = .construct(from: jsObject.uuid)!
    
    // MARK: - Methods
    
    
}
