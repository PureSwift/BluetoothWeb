//
//  CentralManager.swift
//  
//
//  Created by Alsey Coleman Miller on 24/12/21.
//

import Foundation

public final class WebCentral { //: CentralManager {
    
    public static let shared: WebCentral? = {
        guard let jsBluetooth = JSBluetooth.shared else {
            return nil
        }
        let central = WebCentral(jsBluetooth)
        return central
    }()
    
    internal let bluetooth: JSBluetooth
    
    internal init(_ bluetooth: JSBluetooth) {
        self.bluetooth = bluetooth
    }
    
    public var isAvailable: Bool {
        get async {
            await bluetooth.isAvailable
        }
    }
}
