//
//  JSArrayBuffer.swift
//  
//
//  Created by Alsey Coleman Miller on 26/12/21.
//

import Foundation
import JavaScriptKit

/*
 The [`ArrayBuffer`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/ArrayBuffer) object is used to represent a generic, fixed-length raw binary data buffer.
 
 It is an array of bytes, often referred to in other languages as a "byte array". You cannot directly manipulate the contents of an ArrayBuffer; instead, you create one of the typed array objects or a DataView object which represents the buffer in a specific format, and use that to read and write the contents of the buffer.

 The `ArrayBuffer()` constructor creates a new ArrayBuffer of the given length in bytes. You can also get an array buffer from existing data, for example, from a Base64 string or from a local file.
 */
public final class JSArrayBuffer: JSBridgedClass {
    
    public static let constructor = JSObject.global.ArrayBuffer.function!
    
    // MARK: - Properties
    
    public let jsObject: JSObject
    
    // MARK: - Initialization

    public required init(unsafelyWrapping jsObject: JSObject) {
        self.jsObject = jsObject
    }
    
    public init(count: Int) {
        self.jsObject = Self.constructor.new(count)
    }
    
    // MARK: - Accessors
    
    /// The `byteLength` accessor property represents the length (in bytes) of the data.
    public var byteLength: Int {
        return jsObject.byteLength.number.flatMap({ Int($0) }) ?? 0
    }
}
