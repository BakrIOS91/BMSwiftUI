import Foundation
import Combine
import Security

// MARK: - UserDefault

/// A property wrapper that provides type-safe access to `UserDefaults`.
///
/// It supports all `Codable` types and provides a `Combine` publisher for observing changes.
///
/// ### Example
/// ```swift
/// struct Settings {
///     @UserDefault("user_age")
///     var age: Int = 25
///
///     @UserDefault("is_premium")
///     var isPremium: Bool = false
/// }
/// ```
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
    
    /// The current value stored in `UserDefaults`.
    public var wrappedValue: Value {
        get { queue.sync { value } }
        set { queue.sync { value = newValue } }
    }
    
    /// Mutates the current value in-place using a closure.
    public func mutate(
        _ mutation: (inout Value) -> Void
    ) {
        queue.sync { mutation(&value) }
    }
    
    /// A publisher that emits the new value whenever it changes.
    public var publisher: AnyPublisher<Value, Never> {
        valueSubject.eraseToAnyPublisher()
    }
    
    /// Provides access to the `UserDefault` instance itself (e.g., to access the publisher).
    public var projectedValue: UserDefault<Value> {
        self
    }
    
    /// Initializes the property wrapper.
    /// - Parameters:
    ///   - wrappedValue: The default value to return if no value exists in storage.
    ///   - key: The key used to store the value in `UserDefaults`.
    ///   - container: The `UserDefaults` instance to use. Defaults to `.standard`.
    public init(
        wrappedValue: Value,
        _ key: String,
        container: UserDefaults = .standard
    ) {
        self.key = key
        self.defaultValue = wrappedValue
        self.container = container
    }
    
    private func decodeValue() -> Value {
        guard let data = container.data(forKey: key) else { return defaultValue }
        let value = try? JSONDecoder().decode(Value.self, from: data)
        return value ?? defaultValue
    }
    
    private func encodeValue(
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
}

public extension UserDefault where Value: ExpressibleByNilLiteral {
    /// Convenience initializer for optional values.
    convenience init(
        _ key: String,
        container: UserDefaults = .standard
    ) {
        self.init(wrappedValue: nil, key, container: container)
    }
}

// MARK: - Secure (Keychain)

/// A property wrapper that provide secure storage using the Apple Keychain.
///
/// Data is encrypted and stored securely. Supports all `Codable` types.
///
/// ### Example
/// ```swift
/// struct Account {
///     @Secure("api_token")
///     var token: String?
///
///     @Secure("user_credentials")
///     var credentials: Credentials?
/// }
/// ```
@propertyWrapper
public final class Secure<Value: Codable> {
    private let queue = DispatchQueue(label: "atomicSecure")
    private let key: String
    private let defaultValue: Value
    private lazy var valueSubject = CurrentValueSubject<Value, Never>(value)
    
    private var value: Value {
        get { decodeValue() }
        set { encodeValue(newValue) }
    }
    
    /// The current value stored in the Keychain.
    public var wrappedValue: Value {
        get { queue.sync { value } }
        set { queue.sync { value = newValue } }
    }
    
    /// A publisher that emits the new value whenever it changes.
    public var publisher: AnyPublisher<Value, Never> {
        valueSubject.eraseToAnyPublisher()
    }
    
    /// Provides access to the `Secure` instance itself.
    public var projectedValue: Secure<Value> {
        self
    }
    
    /// Initializes the property wrapper.
    /// - Parameters:
    ///   - wrappedValue: The default value to return if no value exists.
    ///   - key: The key used to store the value in the Keychain.
    public init(
        wrappedValue: Value,
        _ key: String
    ) {
        self.key = key
        self.defaultValue = wrappedValue
    }
    
    private func decodeValue() -> Value {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        guard status == errSecSuccess, let data = dataTypeRef as? Data else {
            return defaultValue
        }
        
        let value = try? JSONDecoder().decode(Value.self, from: data)
        return value ?? defaultValue
    }
    
    private func encodeValue(_ newValue: Value) {
        let data: Data?
        if let optional = newValue as? AnyOptional, optional.isNil {
            data = nil
        } else {
            data = try? JSONEncoder().encode(newValue)
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        if let data = data {
            let attributes: [String: Any] = [
                kSecValueData as String: data
            ]
            
            let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
            if status == errSecItemNotFound {
                var newQuery = query
                newQuery[kSecValueData as String] = data
                SecItemAdd(newQuery as CFDictionary, nil)
            }
        } else {
            SecItemDelete(query as CFDictionary)
        }
        
        valueSubject.send(newValue)
    }
}

public extension Secure where Value: ExpressibleByNilLiteral {
    /// Convenience initializer for optional secure values.
    convenience init(_ key: String) {
        self.init(wrappedValue: nil, key)
    }
}


