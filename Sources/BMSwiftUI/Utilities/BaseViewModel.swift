//
//  BaseViewModel.swift
//  BMSwiftUI
//
//  Created by Bakr mohamed on 25/01/2025.
//

import SwiftUI
import Combine

#if canImport(Observation)
import Observation
#endif

/// A protocol defining the requirements for a base view model.
/// Conforming types must be `AnyObject` (class-bound) and implement the `CancelableStore` protocol.
/// The `@MainActor` attribute ensures that all methods and properties are accessed on the main thread.
@MainActor
public protocol BaseViewModelProtocol: AnyObject, CancelableStore {
    /// The state type representing the view model's state.
    associatedtype State
    
    /// The action type representing the actions that can be triggered to modify the state.
    associatedtype Action
    
    /// The current state of the view model.
    var state: State { get set }
    
    /// Triggers an action to modify the state.
    /// - Parameter action: The action to be triggered.
    func trigger(_ action: Action) async
}

// MARK: - Modern BaseViewModel (iOS 17+)
// Uses the Observation framework for better performance and simpler syntax.

#if canImport(Observation)
@available(iOS 17.0, macOS 14.0, *)
@MainActor
@Observable
open class BaseViewModel<State, Action>: NSObject, BaseViewModelProtocol {
    /// The current state of the view model. Marked with @Observable macro.
    public var state: State
    
    /// A computed property that returns an array of `AnyCancellable` objects.
    /// This is used to store Combine subscriptions.
    open var bindings: [AnyCancellable] { [] }
    
    /// Initializes the view model with an initial state.
    /// - Parameter state: The initial state of the view model.
    public init(state: State) {
        self.state = state
        super.init()
        bind()
    }
    
    /// A final method that binds the Combine subscriptions.
    public final func bind() {
        bindings.forEach { $0.store(in: &cancelables) }
    }
    
    /// Triggers an action to modify the state.
    /// - Parameter action: The action to be triggered.
    open func trigger(_ action: Action) async {
        fatalError("Override!")
    }
}

@available(iOS 17.0, macOS 14.0, *)
extension BaseViewModel: Identifiable {
    /// A computed property that returns a unique `UUID` for the view model.
    public nonisolated var id: UUID {
        UUID()
    }
}
#endif
