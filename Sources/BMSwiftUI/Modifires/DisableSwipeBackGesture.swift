//
//  File.swift
//  BMSwiftUI
//
//  Created by Bakr mohamed on 13/01/2025.
//

import SwiftUI

public extension View {
    func gestureDisabledNavigation() -> some View {
        self.background(DisableSwipeBackGesture())
    }
}

public struct DisableSwipeBackGesture: UIViewControllerRepresentable {
    public func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        controller.view.backgroundColor = .clear
        return controller
    }

    public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        uiViewController.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
}
