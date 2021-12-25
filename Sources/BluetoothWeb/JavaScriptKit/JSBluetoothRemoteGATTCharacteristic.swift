//
//  JSBluetoothRemoteGattCharacteristic.swift
//  
//
//  Created by Alsey Coleman Miller on 25/12/21.
//

import Foundation
import JavaScriptKit

/**
 JavaScript Bluetooth GATT Characteristic
 
 The [`BluetoothRemoteGATTCharacteristic`](https://developer.mozilla.org/en-US/docs/Web/API/BluetoothRemoteGattCharacteristic) interface of the [Web Bluetooth API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Bluetooth_API) represents a GATT Characteristic, which is a basic data element that provides further information about a peripheral’s service.
 */
public final class JSBluetoothRemoteGATTCharacteristic: JSBridgedClass {
    
    public static let constructor = JSObject.global.BluetoothRemoteGATTCharacteristic.function!
    
    // MARK: - Properties
    
    public let jsObject: JSObject
    
    public private(set) weak var service: JSBluetoothRemoteGATTService?
    
    // MARK: - Initialization

    public required init(unsafelyWrapping jsObject: JSObject) {
        self.jsObject = jsObject
    }
    
    public required init(unsafelyWrapping jsObject: JSObject, service: JSBluetoothRemoteGATTService) {
        self.jsObject = jsObject
        self.service = service
    }
    
    // MARK: - Accessors

    public lazy var uuid: BluetoothUUID = .construct(from: jsObject.uuid)!
    
    // MARK: - Methods
    
    public func descriptor(for uuid: BluetoothUUID) async throws -> JSBluetoothRemoteGATTDescriptor {
        guard let function = jsObject.getDescriptor.function
            else { fatalError("Missing function \(#function)") }
        let result = function.callAsFunction(this: jsObject, uuid)
        guard let promise = result.object.flatMap({ JSPromise($0) })
            else { fatalError("Invalid object \(result)") }
        let value = try await promise.get()
        return value.object.flatMap({ JSBluetoothRemoteGATTDescriptor(unsafelyWrapping: $0, characteristic: self) })!
    }
}
