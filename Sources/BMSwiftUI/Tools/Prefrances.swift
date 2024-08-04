//
//  Prefrances.swift
//
//
//  Created by Bakr mohamed on 04/08/2024.
//

import SwiftUI
import Combine

public final class PublisherObservableObject: ObservableObject {
    
    var subscriber: AnyCancellable?
    
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

@propertyWrapper
public struct Preference<Value>: DynamicProperty {
    
    @ObservedObject var preferencesObserver: PublisherObservableObject
    let keyPath: ReferenceWritableKeyPath<Preferences, Value>
    let preferences: Preferences = .shared
    
    init(
        _ keyPath: ReferenceWritableKeyPath<Preferences, Value>
    ) {
        self.keyPath = keyPath
        let publisher = preferences
            .preferencesChangedSubject
            .filter { changedKeyPath in
                changedKeyPath == keyPath
            }
            .mapToVoid()
            .eraseToAnyPublisher()
        self.preferencesObserver = .init(publisher: publisher)
    }
    
    public var wrappedValue: Value {
        get {
            preferences[keyPath: keyPath]
        }
        nonmutating set {
            preferences[keyPath: keyPath] = newValue
            preferences.preferencesChangedSubject.send(keyPath)
        }
    }
    
    public var projectedValue: Binding<Value> {
        Binding(
            get: { wrappedValue },
            set: { wrappedValue = $0 }
        )
    }
}

public final class Preferences {
    
    static let shared = Preferences()
    private init() {}
    
    /// Sends through the changed key path whenever a change occurs.
    var preferencesChangedSubject = PassthroughSubject<AnyKeyPath, Never>()
    
    @UserDefault("kPreviewLocale")
    var previewLocale: Locale?
}

