//
//  JSBluetoothRemoteGATTService.swift
//  
//
//  Created by Alsey Coleman Miller on 6/4/20.
//

import JavaScriptKit

/**
 JavaScript Bluetooth GATT Service
 
 The [`BluetoothRemoteGATTService`](https://developer.mozilla.org/en-US/docs/Web/API/BluetoothRemoteGATTService) interface of the [Web Bluetooth API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Bluetooth_API) represents a service provided by a GATT server, including a device, a list of referenced services, and a list of the characteristics of this service.
 */
public final class JSBluetoothRemoteGATTService: JSBridgedClass {
    
    public static let constructor = JSObject.global.BluetoothRemoteGattService.function!
    
    // MARK: - Properties
    
    public let jsObject: JSObject
    
    // MARK: - Initialization
    
    public required init(unsafelyWrapping jsObject: JSObject) {
        self.jsObject = jsObject
    }
    
    // MARK: - Accessors
        
    public lazy var uuid: BluetoothUUID = .construct(from: jsObject.uuid)!
    
    public lazy var isPrimary: Bool = jsObject.isPrimary.boolean ?? false
    
    // MARK: - Methods
    
    public func characteristic(for uuid: BluetoothUUID) async throws -> JSBluetoothRemoteGATTCharacteristic {
        guard let function = jsObject.getCharacteristic.function
            else { fatalError("Missing function \(#function)") }
        let result = function.callAsFunction(this: jsObject, uuid)
        guard let promise = result.object.flatMap({ JSPromise($0) })
            else { fatalError("Invalid object \(result)") }
        let value = try await promise.get()
        return value.object.flatMap({ JSBluetoothRemoteGATTCharacteristic(unsafelyWrapping: $0, service: self) })!
    }
}
