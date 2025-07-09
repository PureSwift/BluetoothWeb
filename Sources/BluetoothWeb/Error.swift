//
//  Error.swift
//  BluetoothWeb
//
//  Created by Alsey Coleman Miller on 7/9/25.
//

import JavaScriptKit

/// Bluetooth Web API Error
public struct BluetoothWebError: Error {
    
    public let name: String
    
    public let message: String
    
    public let stack: String?
    
    public let file: StaticString
    
    public let function: StaticString
}

internal extension BluetoothWebError {
    
    init(
        _ error: JSError,
        file: StaticString = #file,
        function: StaticString = #function
    ) {
        self.init(
            name: error.name,
            message: error.message,
            stack: error.stack,
            file: file,
            function: function
        )
    }
    
    init?(
        _ jsValue: JSValue,
        file: StaticString = #file,
        function: StaticString = #function
    ) {
        guard let error = JSError(from: jsValue) else {
            return nil
        }
        self.init(error)
    }
}

internal extension JSValue {
    
    func forceError(
        file: StaticString = #file,
        function: StaticString = #function
    ) -> BluetoothWebError {
        let error = JSError(from: self) ?? JSError(message: "Unknown error")
        return .init(error, file: file, function: function)
    }
}
