//
//  Optional+Ext.swift
//
//  Created by Bakr mohamed on 08/02/2024.
//

import Foundation

/// A protocol to represent any optional value.
public protocol AnyOptional {
    /// A boolean value indicating whether the optional is nil or not.
    var isNil: Bool { get }
}

/// An extension to `Optional` to conform to `AnyOptional`.
extension Optional: AnyOptional {
    /// A computed property indicating whether the optional is nil or not.
    public var isNil: Bool { self == nil }
}

/// An extension to `Optional` for collections.
public extension Optional where Wrapped: Collection {
    /// A computed property indicating whether the optional collection is empty or nil.
    var isEmptyOrNil: Bool { self?.isEmpty ?? true }
}
