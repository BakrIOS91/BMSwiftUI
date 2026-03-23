import Foundation
import Combine

/// A macro that transforms a class into a fully-functional Preferences store.
///
/// This macro eliminates boilerplate by automatically generating:
/// - `public static let shared`: A singleton instance.
/// - `public let preferencesChangedSubject`: A subject for change notifications.
/// - `PreferencesStore` conformance.

///
/// ## Overview
///
/// `@Preferences` is the recommended way to create custom preference stores in your app.
/// It works seamlessly with `@UserDefault` and `@Secure` property wrappers to provide
/// a type-safe, observable storage layer.
///
/// ## Usage
/// ```swift
/// @Preferences
/// class AppPreferences {
///     @UserDefault("my_key") var mySetting = "Default"
///     @Secure("secret_key") var apiToken: String?
/// }
/// ```
///
/// You can then use it in SwiftUI views with the simplified `@Preference` syntax:
/// ```swift
/// struct MyView: View {
///     @Preference(\AppPreferences.mySetting) var setting
///     
///     var body: some View {
///         Text(setting)
///     }
/// }
/// ```
@attached(member, names: arbitrary)
@attached(extension, conformances: PreferencesStore, names: arbitrary)
public macro Preferences() = #externalMacro(module: "BMSwiftUIMacros", type: "PreferencesMacro")

