import SwiftUI
import Combine
import Foundation

/// Defines the underlying observation mechanism for the ViewModel.
public enum ViewModelMode {
    /// Modern iOS 17+ observation using the `@Observable` macro.
    /// When using this mode, you should also apply `@Observable` to your class.
    case observable
    
    /// Traditional `ObservableObject` pattern for backward compatibility.
    /// Automatically adds `@Published` to the `state` property and conforms to `ObservableObject`.
    case observed
}

/// A macro that transforms a class into a fully-functional BaseViewModel.
///
/// This macro eliminates boilerplate by automatically generating the necessary members 
/// for state management, Combine subscriptions, and protocol conformances.
///
/// ## Overview
///
/// `BMSwiftUI` provides a modern infrastructure for building SwiftUI applications. 
/// Using `@BaseViewModel` along with the built-in **Dependency Injection (DI)** system 
/// allows for highly decoupled and testable code.
///
/// ### Requirements
/// To use `@BaseViewModel`, your class **must** define the following nested members:
/// - `struct State` or `typealias State`: The data structure representing your view's state.
/// - `enum Action` or `typealias Action`: The events that trigger state changes.
/// - `func trigger(_ action: Action) -> ViewModelEffect`: The logic handling state transitions.
///
/// ### Generated Members
/// The macro adds the following implementations to your class:
/// - `public var state: State` (with `@Published` in `.observed` mode)
/// - `open var bindings: [Combine.AnyCancellable] { [] }`
/// - `public var cancelables: Set<Combine.AnyCancellable> = []`
/// - `public init(state: State)`: A standard initializer that calls `bind()`.
/// - `public final func bind()`: A method that stores `bindings` in `cancelables`.
/// - `extension YourClass: BaseViewModelProtocol, Identifiable`: Automatic protocol conformance.
/// - `extension YourClass: SwiftUI.ObservableObject`: Added only in `.observed` mode.
///
/// ## Usage Examples
///
/// ### 1. Modern Mode (iOS 17+)
/// Use `.observable` (default) combined with `@Observable`.
///
/// ```swift
/// @Observable
/// @BaseViewModel
/// final class CounterViewModel {
///     struct State { var count = 0 }
///     enum Action { case increment }
///     
///     func trigger(_ action: Action) -> ViewModelEffect {
///         switch action {
///         case .increment: 
///             state.count += 1
///             return .none
///         }
///     }
/// }
/// ```
///
/// ### 2. Observed Mode (Pre-iOS 17)
/// Use `.observed` for automatic `ObservableObject` support.
///
/// ```swift
/// @BaseViewModel(mode: .observed)
/// final class LegacyViewModel {
///     struct State { var total = 0.0 }
///     enum Action { case calculate }
///     
///     func trigger(_ action: Action) -> ViewModelEffect {
///         // logic here
///         return .none
///     }
/// }
/// ```
@attached(member, names: arbitrary)
@attached(memberAttribute)
@attached(extension, conformances: BaseViewModelProtocol, Identifiable, names: arbitrary)
public macro BaseViewModel(mode: ViewModelMode = .observable) = #externalMacro(module: "BMSwiftUIMacros", type: "BaseViewModelMacro")
