//
//  JSDataView.swift
//  
//
//  Created by Alsey Coleman Miller on 25/12/21.
//

import Foundation
import JavaScriptKit

/*
 The [`DataView`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/DataView) view provides a low-level interface for reading and writing multiple number types in a binary `ArrayBuffer`, without having to care about the platform's endianness.
 */
public final class JSDataView: JSBridgedClass {
    
    public static let constructor = JSObject.global.DataView.function!
    
    // MARK: - Properties
    
    public let jsObject: JSObject
        
    // MARK: - Initialization

    public required init(unsafelyWrapping jsObject: JSObject) {
        self.jsObject = jsObject
    }
    
    public init(_ arrayBuffer: JSArrayBuffer) {
        self.jsObject = Self.constructor.new(arrayBuffer)
    }
    
    // MARK: - Accessors
    
    /// The `byteLength` accessor property represents the length (in bytes) of the data view.
    ///
    /// The `byteLength` property is an accessor property whose set accessor function is undefined, meaning that you can only read this property.
    /// The value is established when an DataView is constructed and cannot be changed. If the DataView is not specifying an offset or a byteLength,
    /// the `byteLength` of the referenced `ArrayBuffer` or `SharedArrayBuffer` will be returned.
    public var byteLength: Int {
        return jsObject.byteLength.number.flatMap({ Int($0) }) ?? 0
    }
    
    /// The offset (in bytes) of this view from the start of its ArrayBuffer. Fixed at construction time and thus read only.
    public var byteOffset: Int {
        return jsObject.byteOffset.number.flatMap({ Int($0) }) ?? 0
    }
    
    /// Gets an unsigned 8-bit integer (unsigned byte) at the specified byte offset from the start of the view.
    ///
    /// - Parameter byteOffset: The offset, in byte, from the start of the view where to read the data.
    /// - Returns: An unsigned 8-bit integer number.
    public func getUint8(_ byteOffset: Int) -> UInt8 {
        guard let function = jsObject.getUint8.function
            else { fatalError("Missing function \(#function)") }
        let result = function.callAsFunction(this: jsObject, byteOffset)
        return result.number.flatMap({ UInt8($0) }) ?? 0
    }
    
    
    /// Stores an unsigned 8-bit integer (byte) value at the specified byte offset from the start of the `DataView`.
    ///
    /// - Parameter byteOffset: The offset, in byte, from the start of the view where to store the data.
    /// - Parameter value: The value to set.
    public func setUint8(_ byteOffset: Int, _ value: UInt8) {
        guard let function = jsObject.setUint8.function
            else { fatalError("Missing function \(#function)") }
        let _ = function.callAsFunction(this: jsObject, byteOffset, value)
    }
}

// MARK: - Sequence

extension JSDataView: Sequence {
    
    public func makeIterator() -> IndexingIterator<JSDataView> {
        return IndexingIterator(_elements: self)
    }
}

// MARK: - Collection

extension JSDataView: MutableCollection {
    
    public subscript(index: Int) -> UInt8 {
        get { getUint8(index) }
        set { setUint8(index, newValue) }
    }
    
    public var count: Int {
        byteLength
    }
    
    public func index(after index: Int) -> Int {
        return index + 1
    }
    
    public var startIndex: Int {
        return 0
    }
    
    public var endIndex: Int {
        return count
    }
}

// MARK: - RandomAccessCollection

extension JSDataView: RandomAccessCollection {
    
    public subscript(bounds: Range<Int>) -> Slice<JSDataView> {
        return Slice<JSDataView>(base: self, bounds: bounds)
    }
}

// MARK: - Data

public extension JSDataView {
    
    /// Allocates a DataView from data.
    convenience init(_ data: Data) {
        let arrayBuffer = JSArrayBuffer(count: data.count)
        self.init(arrayBuffer)
        for (index, byte) in data.enumerated() {
            self[index] = byte
        }
    }
}
