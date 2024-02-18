//
//  View+Ext.swift
//  
//
//  Created by Bakr mohamed on 03/04/2023.
//
import SwiftUI

public extension View {
    #if canImport(UIKit)
    func hideKeyboard() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    #endif
    
    @ViewBuilder
    func isHidden(_ hidden: Bool, remove: Bool = false) -> some View {
        if hidden {
            if !remove {
                self.hidden()
            }
        } else {
            self
        }
    }
    
    /// Sets locale and layout direction
    ///
    /// Pay attention to back button in navigation view. It will require customization as it's image direction won't change on a current screen.
    @ViewBuilder
    func locale(
        _ locale: Locale
    ) -> some View {
        self.environment(\.layoutDirection, locale.layoutDirection)
            .environment(\.locale, locale)
    }
    
    @ViewBuilder func `if`<Content: View>(
        _ condition: Bool, transform: (Self) -> Content,
        transformElse: ((Self) -> Content)? = nil) -> some View {
           if condition {
               transform(self)
           } else {
               if let transformElse = transformElse {
                   transformElse(self)
               } else {
                   self
               }
           }
       }
    
    /// `if let` statement view modifier
    ///
    /// Example:
    ///
    ///     var color: Color?
    ///
    ///     var body: some View {
    ///         Text("Example")
    ///         .if(let: color) { $0.foregroundColor($1) }
    ///     }
    ///
    @ViewBuilder
    func `if`<Transform: View, T> (
        `let` optional: T?,
        @ViewBuilder transform: (Self, T) -> Transform
    ) -> some View {
        if let optional = optional {
            transform(self, optional)
        } else {
            self
        }
    }
    
    /// `if let else` statement view modifier
    ///
    /// Example:
    ///
    ///     var color: Color?
    ///
    ///     var body: some View {
    ///         Text("Example")
    ///         .if(let: color) {
    ///             $0.foregroundColor($1)
    ///         } else: {
    ///             $0.underline()
    ///         }
    ///
    @ViewBuilder
    func `if`<Transform: View, Fallback: View, T> (
        `let` optional: T?,
        @ViewBuilder transform: (Self, T) -> Transform,
        @ViewBuilder else fallbackTransform: (Self) -> Fallback
    ) -> some View {
        if let optional = optional {
            transform(self, optional)
        } else {
            fallbackTransform(self)
        }
    }
    
    
    /// Navigation view modifier
    ///
    /// Example:
    ///
    ///     @State private var nextScreenviewModel: ViewModel?
    ///
    ///     var body: some View {
    ///         Text("Example")
    ///         .navigation(item: $nextScreenviewModel) { NextScreenView(viewModel: $0) }
    ///     }
    ///
    func navigation<Item, Destination: View>(
        item: Binding<Item?>,
        @ViewBuilder destination: (Item) -> Destination
    ) -> some View {
        let isActive = Binding(
            get: { item.wrappedValue != nil },
            set: { value in if !value { item.wrappedValue = nil } }
        )
        return navigation(isActive: isActive) {
            item.wrappedValue.map(destination)
        }
    }
    
    /// Navigation view modifier
    ///
    /// Example:
    ///
    ///     @State private var isShowingView = false
    ///
    ///     var body: some View {
    ///         Text("Example")
    ///         .navigation(isActive: $isShowingView) { Text("Another screen") }
    ///     }
    ///
    func navigation<Destination: View>(
        isActive: Binding<Bool>,
        @ViewBuilder destination: () -> Destination
    ) -> some View {
        overlay(
            NavigationLink(
                destination: isActive.wrappedValue ? destination() : nil,
                isActive: isActive,
                label: { EmptyView() }
            )
        )
    }
    
    /// Reads view size with geometry reader
    func readSize(
        onChange: @escaping (CGSize) -> Void
    ) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
    
    /// Reads view frame with geometry reader
    func readFrame(
        space: CoordinateSpace,
        onChange: @escaping (CGRect) -> Void
    ) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: FramePreferenceKey.self, value: geometryProxy.frame(in: space))
            }
        )
            .onPreferenceChange(FramePreferenceKey.self, perform: onChange)
    }
    
    func cornerRadius(
        _ radius: CGFloat,
        corners: UIRectCorner
    ) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    
    func flippedVertically() -> some View {
        self.rotation3DEffect(.degrees(180), axis: (x: 1, y: 0, z: 0))
    }
    
    func flippedHorizontally() -> some View {
        self.rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
    }
    
    /// Sets navigation bar style when view appers
    ///
    /// - Warning:
    /// Use only once per navigation view
    func navigationBarStyle(
        titleTextAttributes: [NSAttributedString.Key: Any],
        largeTitleTextAttributes: [NSAttributedString.Key: Any],
        tintColor: UIColor?,
        shadowColor: UIColor?,
        backgroundColor: UIColor?,
        backButtonImage: UIImage?
    ) -> some View {
        self.modifier(
            NavAppearanceModifier(
                titleTextAttributes: titleTextAttributes,
                largeTitleTextAttributes: largeTitleTextAttributes,
                tintColor: tintColor,
                shadowColor: shadowColor,
                backgroundColor: backgroundColor,
                backImage: backButtonImage
            )
        )
    }
}

private struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(
        in rect: CGRect
    ) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

private struct SizePreferenceKey: PreferenceKey {
  static var defaultValue: CGSize = .zero
  static func reduce(
    value: inout CGSize,
    nextValue: () -> CGSize
  ) {}
}

private struct FramePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(
        value: inout CGRect,
        nextValue: () -> CGRect
    ) {}
}
