//
//  NavigationBarModifier.swift
//  ServeBig
//
//  Created by SherifAshraf on 08/08/2024.
//  Copyright © 2024 Link Development. All rights reserved.
//
import SwiftUI

public struct NavigationBarModifier: ViewModifier {
    private var backgroundColor: UIColor
    private var foregroundColor: UIColor
    private var backArrowColor: UIColor
    
    public init(backgroundColor: UIColor, foregroundColor: UIColor, backArrowColor: UIColor) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.backArrowColor = backArrowColor
    }

    public func body(content: Content) -> some View {
        content
            .onAppear {
                let appearance = UINavigationBarAppearance()
                
                // Custom background & title colors
                appearance.backgroundColor = backgroundColor
                appearance.titleTextAttributes = [.foregroundColor: foregroundColor]
                appearance.largeTitleTextAttributes = [.foregroundColor: foregroundColor]
                
                // Button tinting
                let buttonAppearance = UIBarButtonItemAppearance()
                buttonAppearance.normal.titleTextAttributes = [.foregroundColor: foregroundColor]
                
                // Custom back button icon
                let image = UIImage(systemName: "chevron.backward")!.withTintColor(backArrowColor, renderingMode: .alwaysOriginal)
                appearance.setBackIndicatorImage(image, transitionMaskImage: image)
                
                appearance.buttonAppearance = buttonAppearance
                appearance.backButtonAppearance = buttonAppearance
                appearance.doneButtonAppearance = buttonAppearance
                
                UINavigationBar.appearance().standardAppearance = appearance
                UINavigationBar.appearance().scrollEdgeAppearance = appearance
                UINavigationBar.appearance().compactAppearance = appearance
            }
    }
}

public extension View {
    func setNavigationBarStyle(backgroundColor: UIColor = .systemBackground, foregroundColor: UIColor = .white, backArrowColor: UIColor = .white) -> some View {
        self.modifier(NavigationBarModifier(backgroundColor: backgroundColor, foregroundColor: foregroundColor, backArrowColor: backArrowColor))
    }
}

