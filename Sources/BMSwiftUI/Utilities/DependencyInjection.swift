//
//  DependencyInjection.swift
//  BMSwiftUI
//
//  Created by Bakr mohamed on 23/03/2026.
//

import Foundation

/// A protocol that defines a dependency and its default values for preview and test environments.
/// This allows for easy mocking and testing of services and clients.
///
/// ### Example
/// ```swift
/// struct CharactersClient {
///     var getCharacters: (_ pageIndex: Int, _ searchText: String) async -> Result<CharacterList?, APIError>
/// }
///
/// extension CharactersClient: TestDependencyKey {
///     static var previewValue: CharactersClient {
///         .init { _, _ in .success(.mock) }
///     }
///     static var testValue: CharactersClient {
///         .init { _, _ in .success(.mock) }
///     }
/// }
/// ```
public protocol TestDependencyKey {
    associatedtype Value
    static var previewValue: Value { get }
    static var testValue: Value { get }
}

/// A protocol that extends `TestDependencyKey` to include a live/production value.
/// Conforming to this protocol enables the dependency to be used in a live application.
///
/// ### Example
/// ```swift
/// extension CharactersClient: DependencyKey {
///     static var liveValue: CharactersClient {
///         .init { _, _ in await ChractersRequest.GetCharacters().performResult() }
///     }
/// }
/// ```
public protocol DependencyKey: TestDependencyKey {
    static var liveValue: Value { get }
}

/// A central registry for managing and resolving dependencies.
/// It supports subscripting by `TestDependencyKey` types for type-safe access.
public struct DependencyValues {
    @TaskLocal private static var currentOverride: DependencyValues?
    private static var global = DependencyValues()
    
    /// The shared instance of `DependencyValues`. 
    /// Note: Use `withDependencies` for thread-safe scoped overrides in tests.
    public static var shared: DependencyValues {
        get { currentOverride ?? global }
        set { global = newValue }
    }
    
    private var storage = [ObjectIdentifier: Any]()
    
    /// Whether the application is running in a SwiftUI preview.
    public static var isPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
    
    /// Whether the application is running in a test environment.
    public static var isTesting: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_TESTS"] == "1"
    }
    
    /// Accesses the dependency associated with the given key type.
    /// - Returns: The registered value, or a default value based on the current environment.
    ///
    /// ### Example
    /// ```swift
    /// extension DependencyValues {
    ///     var charactersClient: CharactersClient {
    ///         get { self[CharactersClient.self] }
    ///         set { self[CharactersClient.self] = newValue }
    ///     }
    /// }
    /// ```
    public subscript<K: TestDependencyKey>(key: K.Type) -> K.Value {
        get {
            if let value = storage[ObjectIdentifier(key)] as? K.Value {
                return value
            }
            
            if Self.isTesting {
                return K.testValue
            }
            
            if Self.isPreview {
                return K.previewValue
            }
            
            // Priority: Live (if available) -> Test
            if let liveKey = key as? any DependencyKey.Type,
               let liveValue = liveKey.liveValue as? K.Value {
                return liveValue
            }
            
            return K.testValue
        }
        set {
            storage[ObjectIdentifier(key)] = newValue
        }
    }
    
    /// Scopes dependencies to the given operation.
    /// - Parameters:
    ///   - update: A closure to update the dependencies for the scope.
    ///   - operation: The operation to perform within the dependency scope.
    /// - Returns: The result of the operation.
    public static func withDependencies<R>(
        _ update: (inout DependencyValues) -> Void,
        operation: () throws -> R
    ) rethrows -> R {
        var values = shared
        update(&values)
        return try $currentOverride.withValue(values) {
            try operation()
        }
    }
    
    /// Scopes dependencies to the given async operation.
    /// - Parameters:
    ///   - update: A closure to update the dependencies for the scope.
    ///   - operation: The operation to perform within the dependency scope.
    /// - Returns: The result of the operation.
    public static func withDependencies<R>(
        _ update: (inout DependencyValues) -> Void,
        operation: () async throws -> R
    ) async rethrows -> R {
        var values = shared
        update(&values)
        return try await $currentOverride.withValue(values) {
            try await operation()
        }
    }
}

/// A property wrapper that simplifies dependency injection in classes (e.g., ViewModels).
/// It resolves the dependency from the shared `DependencyValues` registry using a key path.
///
/// Example:
/// ```swift
/// class MyViewModel {
///     @Injected(\.myClient) var client: MyClient
/// }
/// ```
@propertyWrapper
public struct Injected<T> {
    private let keyPath: WritableKeyPath<DependencyValues, T>
    
    public var wrappedValue: T {
        get { DependencyValues.shared[keyPath: keyPath] }
        set { DependencyValues.shared[keyPath: keyPath] = newValue }
    }
    
    public init(_ keyPath: WritableKeyPath<DependencyValues, T>) {
        self.keyPath = keyPath
    }
}
