//
//  UserDefault.swift
//
//  Created by Bakr mohamed on 08/02/2024.
//

import Foundation
import Combine

/// A property wrapper for accessing and observing values stored in UserDefaults.
@propertyWrapper
public final class UserDefault<Value: Codable> {
    private let queue = DispatchQueue(label: "atomicUserDefault")
    private let key: String
    private let defaultValue: Value
    private var container: UserDefaults
    private lazy var valueSubject = CurrentValueSubject<Value, Never>(value)
    
    private var value: Value {
        get { decodeValue() }
        set { encodeValue(newValue) }
    }
    
    /// The wrapped value of the UserDefault.
    public var wrappedValue: Value {
        get { queue.sync { value } }
        set { queue.sync { value = newValue } }
    }
    
    /// A publisher that emits the wrapped value when it changes.
    public var publisher: AnyPublisher<Value, Never> {
        valueSubject.eraseToAnyPublisher()
    }
    
    /// A projected value representing the UserDefault itself.
    public var projectedValue: UserDefault<Value> {
        self
    }
    
    /// Initializes the UserDefault property wrapper with a key, default value, and UserDefaults container.
    ///
    /// - Parameters:
    ///   - wrappedValue: The default value if the value is not found in UserDefaults.
    ///   - key: The key used to access the value in UserDefaults.
    ///   - container: The UserDefaults container. Default is standard UserDefaults.
    public init(
        wrappedValue: Value,
        _ key: String,
        container: UserDefaults = .standard
    ) {
        self.key = key
        self.defaultValue = wrappedValue
        self.container = container
    }
    
    /// Decodes the value from UserDefaults.
    ///
    /// - Returns: The decoded value from UserDefaults, or the default value if not found.
    public func decodeValue() -> Value {
        guard let data = container.data(forKey: key) else { return defaultValue }
        let value = try? JSONDecoder().decode(Value.self, from: data)
        return value ?? defaultValue
    }
    
    /// Encodes the value and updates UserDefaults.
    ///
    /// - Parameter newValue: The new value to be encoded and stored in UserDefaults.
    public func encodeValue(
        _ newValue: Value
    ) {
        if let optional = newValue as? AnyOptional, optional.isNil {
            container.removeObject(forKey: key)
        } else {
            let data = try? JSONEncoder().encode(newValue)
            container.setValue(data, forKey: key)
        }
        valueSubject.send(newValue)
    }
    
    /// Mutates the wrapped value atomically.
    ///
    /// - Parameter mutation: The mutation to apply to the wrapped value.
    public func mutate(
        _ mutation: (inout Value) -> Void
    ) {
        queue.sync { mutation(&value) }
    }
}

/// An extension providing convenience initializer for `UserDefault` with ExpressibleByNilLiteral values.
public extension UserDefault where Value: ExpressibleByNilLiteral {
    /// Initializes the UserDefault property wrapper with a key and UserDefaults container.
    ///
    /// - Parameters:
    ///   - key: The key used to access the value in UserDefaults.
    ///   - container: The UserDefaults container. Default is standard UserDefaults.
    convenience init(
        _ key: String,
        container: UserDefaults = .standard
    ) {
        self.init(wrappedValue: nil, key, container: container)
    }
}
