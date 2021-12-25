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
public final class JSBluetoothRemoteGATTService {
    
    // MARK: - Properties
    
    internal let jsObject: JSObject
    
    // MARK: - Initialization

    internal init?(_ jsObject: JSObject) {
        self.jsObject = jsObject
    }
    
    // MARK: - Accessors
    
    public lazy var isPrimary: Bool = jsObject.isPrimary.boolean ?? false
    
    public lazy var uuid: String = jsObject.uuid.string ?? ""
    
    // MARK: - Methods
    
    
}


