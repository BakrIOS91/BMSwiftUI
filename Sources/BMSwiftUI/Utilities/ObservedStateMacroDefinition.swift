import SwiftUI

/// A macro that generates a memberwise initializer for a struct or class.
///
/// This is particularly useful for ViewModel `State` structs to avoid manual boilerplate.
/// The generated initializer will be `public` or `internal` based on the parent's accessibility.
@attached(member, names: named(init))
public macro ObservedState() = #externalMacro(module: "BMSwiftUIMacros", type: "ObservedStateMacro")
