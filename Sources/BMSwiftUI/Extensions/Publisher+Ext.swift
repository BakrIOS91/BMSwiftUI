//
//  Publisher.swift
//
//  Created by Bakr mohamed on 08/02/2024.
//

import Foundation
import Combine

/// An extension to the `Publisher` protocol providing a method for mapping values to `Void`.
public extension Publisher {
    /// Maps each element of the upstream publisher to `Void`.
    ///
    /// - Returns: A publisher that replaces each element of the upstream publisher with `Void`.
    func mapToVoid() -> Publishers.Map<Self, Void> {
        map { _ in }
    }
}
