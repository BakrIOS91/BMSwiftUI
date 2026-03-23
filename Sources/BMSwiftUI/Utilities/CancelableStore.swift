//
//  CancelableStore.swift
//  BMSwiftUI
//
//  Created by Bakr mohamed on 25/01/2025.
//

import Foundation
import Combine

// A private pointer used for associating the `CancelableBag` with the `CancelableStore` instance.
private var rawPointer = true

/// A private class used to store a set of `AnyCancellable` objects.
/// This class is used internally by the `CancelableStore` protocol to manage Combine subscriptions.
private class CancelableBag: NSObject {
    var cancelables = Set<AnyCancellable>()
}

/// A protocol that defines the requirements for a type that can store Combine subscriptions.
/// Conforming types must be `AnyObject` (class-bound) and provide a set of `AnyCancellable` objects.
public protocol CancelableStore: AnyObject {
    /// A set of `AnyCancellable` objects used to store Combine subscriptions.
    var cancelables: Set<AnyCancellable> { get set }
}

public extension CancelableStore {
    
    /// A helper method that synchronizes access to the `cancelableBag` property.
    /// This ensures thread-safe access to the `CancelableBag` instance.
    /// - Parameter action: A closure that performs the synchronized operation.
    /// - Returns: The result of the closure.
    private func synchronizedBag<T>(_ action: () -> T) -> T {
        objc_sync_enter(self)
        let result = action()
        objc_sync_exit(self)
        return result
    }
    
    /// A computed property that provides access to the `CancelableBag` instance.
    /// The `CancelableBag` is stored as an associated object using `objc_setAssociatedObject`.
    private var cancelableBag: CancelableBag {
        get {
            synchronizedBag {
                // Retrieve the `CancelableBag` instance associated with this object.
                if let cancelableBag = objc_getAssociatedObject(self, &rawPointer) as? CancelableBag {
                    return cancelableBag
                }
                // If no `CancelableBag` exists, create a new one and associate it with this object.
                let cancelableBag = CancelableBag()
                objc_setAssociatedObject(self, &rawPointer, cancelableBag, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return cancelableBag
            }
        }
        
        set {
            synchronizedBag {
                // Associate the new `CancelableBag` instance with this object.
                objc_setAssociatedObject(self, &rawPointer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    /// A computed property that provides access to the `cancelables` set stored in the `CancelableBag`.
    /// This property is thread-safe due to the use of `synchronizedBag`.
    var cancelables: Set<AnyCancellable> {
        get {
            cancelableBag.cancelables
        }
        
        set {
            cancelableBag.cancelables = newValue
        }
    }
}
