//
//  Preferences.swift
//
//
//  Created by Bakr mohamed on 04/08/2024.
//

import SwiftUI
import Combine

/// A utility class that triggers `ObservableObject` updates from a `Combine` publisher.
public final class PublisherObservableObject: ObservableObject {
    var subscriber: AnyCancellable?
    
    /// Initializes with a publisher.
    /// - Parameter publisher: A publisher that emits whenever the object should change.
    public init(publisher: AnyPublisher<Void, Never>) {
        subscriber = publisher
            .sink(receiveValue: { _ in
                // Send the objectWillChange notification after the view update has happened.
                DispatchQueue.main.async {
                    self.objectWillChange.send()
                }
            })
    }
}

/// A protocol that defines a store for preferences that can be observed.
///
/// Types conforming to this protocol can be used with the `@Preference` property wrapper.
public protocol PreferencesStore: ObservableObject {
    /// A shared instance of the store.
    static var shared: Self { get }
    
    /// A subject that emits the key path of the property that changed.
    var preferencesChangedSubject: PassthroughSubject<AnyKeyPath, Never> { get }
}

/// A property wrapper used in SwiftUI views to observe and modify preferences.
///
/// It automatically subscribes to changes in the specified `PreferencesStore` and updates the view.
///
/// ### Example
/// ```swift
/// struct MyView: View {
///     // Uses the default Preferences.shared
///     @Preference(\.previewLocale) var locale
///
///     // Uses a custom store (AppPreferences.shared is inferred)
///     @Preference(\AppPreferences.theme) var theme
///
///     var body: some View {
///         Text(theme)
///     }
/// }
/// ```
@propertyWrapper
public struct Preference<Value>: DynamicProperty {
    @ObservedObject private var preferencesObserver: PublisherObservableObject
    private let keyPath: AnyKeyPath
    private let getter: () -> Value
    private let setter: (Value) -> Void
    
    /// Initializes the property wrapper with a key path and an optional store.
    /// - Parameters:
    ///   - keyPath: The key path to the property in the store.
    ///   - store: The store instance. Defaults to `Store.shared`.
    public init<Store: PreferencesStore>(
        _ keyPath: ReferenceWritableKeyPath<Store, Value>,
        store: Store = Store.shared
    ) {
        self.keyPath = keyPath
        self.getter = { store[keyPath: keyPath] }
        self.setter = { newValue in
            store[keyPath: keyPath] = newValue
            store.preferencesChangedSubject.send(keyPath)
        }
        
        let publisher = store.preferencesChangedSubject
            .filter { $0 == keyPath }
            .mapToVoid()
            .eraseToAnyPublisher()
        self.preferencesObserver = .init(publisher: publisher)
    }
    
    /// The current value of the preference.
    public var wrappedValue: Value {
        get { getter() }
        nonmutating set { setter(newValue) }
    }
    
    /// A binding to the preference value.
    public var projectedValue: Binding<Value> {
        Binding(
            get: { wrappedValue },
            set: { wrappedValue = $0 }
        )
    }
}

/// A base implementation of `PreferencesStore`.
///
/// You can use this class directly for simple needs or use the `@Preferences` macro
/// to create your own specialized preference stores.
public final class Preferences: PreferencesStore {
    /// The shared singleton instance.
    public static let shared = Preferences()
    
    /// The subject for change notifications.
    public let preferencesChangedSubject = PassthroughSubject<AnyKeyPath, Never>()
    
    /// Internal initializer for the singleton.
    public init() {}
    
    /// Example preference: the locale used for previews.
    @UserDefault("kPreviewLocale")
    public var previewLocale: Locale?
}







