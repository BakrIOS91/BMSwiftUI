//
//  Preference.swift
//
//  Created by Bakr mohamed on 08/02/2024.
//

import Combine
import SwiftUI

/// A property wrapper for observing changes to preferences stored in the `Preferences` class.
@propertyWrapper
struct Preference<Value>: DynamicProperty {
    
    /// The observer object for publishing changes to the preference.
    @ObservedObject private var preferencesObserver: PublisherObservableObject
    
    /// The key path to the preference in the `Preferences` class.
    private let keyPath: ReferenceWritableKeyPath<Preferences, Value>
    
    /// The shared instance of the `Preferences` class.
    private let preferences: Preferences = .shared
    
    /// Initializes the preference wrapper with the specified key path.
    ///
    /// - Parameter keyPath: The key path to the preference in the `Preferences` class.
    init(
        _ keyPath: ReferenceWritableKeyPath<Preferences, Value>
    ) {
        self.keyPath = keyPath
        
        // Create a publisher that filters changes to the specified key path and maps them to void.
        let publisher = preferences
            .preferencesChangedSubject
            .filter { changedKeyPath in
                changedKeyPath == keyPath
            }
            .mapToVoid()
            .eraseToAnyPublisher()
        
        // Initialize the preferences observer with the publisher.
        self.preferencesObserver = .init(publisher: publisher)
    }
    
    /// The wrapped value of the preference.
    var wrappedValue: Value {
        get {
            preferences[keyPath: keyPath]
        }
        nonmutating set {
            preferences[keyPath: keyPath] = newValue
            
            // Send the changed key path through the preferences changed subject.
            preferences.preferencesChangedSubject.send(keyPath)
        }
    }
    
    /// A binding to the wrapped value of the preference.
    var projectedValue: Binding<Value> {
        Binding(
            get: { wrappedValue },
            set: { wrappedValue = $0 }
        )
    }
}

/// A class for managing user preferences.
public class Preferences {
    
    /// The shared instance of the `Preferences` class.
    static let shared = Preferences()
    
    /// Initializes a new instance of the `Preferences` class.
    private init() {}
    
    /// A subject for publishing changes to preferences.
    fileprivate var preferencesChangedSubject = PassthroughSubject<AnyKeyPath, Never>()
}
