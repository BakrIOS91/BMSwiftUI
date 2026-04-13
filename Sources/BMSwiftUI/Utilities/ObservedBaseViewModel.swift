//
//  ObservedBaseViewModel.swift
//  BMSwiftUI
//
//  Created by Bakr mohamed on 25/01/2025.
//

import SwiftUI
import Combine

// MARK: - ObservedBaseViewModel (Pre-iOS 17)
// Uses the traditional ObservableObject pattern with @Published for backward compatibility.

@MainActor
open class ObservedBaseViewModel<State, Action>: NSObject, BaseViewModelProtocol, ObservableObject, Identifiable {
    /// The current state of the view model, wrapped in @Published to notify observers.
    @Published public var state: State

    /// A computed property that returns an array of `AnyCancellable` objects.
    open var bindings: [AnyCancellable] { [] }

    /// A stable unique identifier for this view model instance.
    public nonisolated let id: UUID = UUID()

    /// A registry for managing asynchronous tasks.
    private var tasks: [String: Task<Void, Never>] = [:]
    
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
    /// - Returns: A `ViewModelEffect` representing any side effects.
    @discardableResult
    @MainActor
    public final func trigger(_ action: Action) -> ViewModelEffect {
        let effect = onTrigger(action)
        handleEffect(effect)
        return effect
    }
    
    @MainActor
    private func handleEffect(_ effect: ViewModelEffect) {
        switch effect {
        case .none:
            break
        case .task(let operation):
            Task { @MainActor in
                await operation()
            }
        case .cancellableTask(let id, let cancelExisting, let operation):
            if cancelExisting {
                tasks[id]?.cancel()
            }
            tasks[id] = Task { @MainActor in
                await operation()
                if !Task.isCancelled {
                    tasks[id] = nil
                }
            }
        case .cancelTask(let id):
            tasks[id]?.cancel()
            tasks[id] = nil
        }
    }
    
    /// Internal method to be overridden by subclasses to handle actions.
    /// - Parameter action: The action to be handled.
    /// - Returns: A `ViewModelEffect` representing any side effects.
    @MainActor
    open func onTrigger(_ action: Action) -> ViewModelEffect {
        .none
    }
}

