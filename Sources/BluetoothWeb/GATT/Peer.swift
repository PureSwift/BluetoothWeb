//
//  Peer.swift
//  GATT
//
//  Created by Alsey Coleman Miller on 4/2/16.
//  Copyright © 2016 PureSwift. All rights reserved.
//

/// Bluetooth LE Peer (Central, Peripheral)
public protocol Peer: Hashable, CustomStringConvertible {
    
    associatedtype ID: Hashable, CustomStringConvertible
    
    /// Unique identifier of the peer.
    var id: ID { get }
}

public extension Peer {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
    
    var description: String {
        return id.description
    }
}
