//
//  ContentSheet.swift
//
//
//  Created by Bakr mohamed on 29/05/2024.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
// Enum to represent the style of the sheet background
public enum SheetBackgroundStyle {
    case `default`  // Default style with a semi-transparent background
    case transparent  // Fully transparent background
}

// A UIHostingController subclass to present SwiftUI views with a transparent background
public class TransparentHostingController<Content: View>: UIHostingController<Content> {
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear  // Make the background clear
        modalPresentationStyle = .overCurrentContext  // Present over the current context
    }
}

// A UIViewControllerRepresentable to wrap a SwiftUI view in a transparent sheet
public struct TransparentSheet<Content: View>: UIViewControllerRepresentable {
    @Binding public var isPresented: Bool  // Binding to control the presentation state
    public let content: Content  // The content to be presented in the sheet
    
    // Create the initial UIViewController
    public func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()  // Return a plain UIViewController
    }
    
    // Update the UIViewController based on the isPresented state
    public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresented {
            if uiViewController.presentedViewController == nil {
                // If the sheet should be presented and no sheet is currently presented
                let hostingController = TransparentHostingController(rootView: content)
                hostingController.modalPresentationStyle = .overCurrentContext
                hostingController.presentationController?.delegate = context.coordinator
                
                // Debug statements to trace the presentation flow
                print("Presenting the sheet.")
                uiViewController.present(hostingController, animated: true, completion: nil)
            }
        } else {
            if let presentedViewController = uiViewController.presentedViewController {
                // If the sheet should be dismissed and a sheet is currently presented
                // Debug statements to trace the dismissal flow
                print("Dismissing the sheet.")
                presentedViewController.dismiss(animated: true, completion: nil)
            }
        }
    }
}

// Extension on View to add a method for presenting content sheets
public extension View {
    
    // Overloaded method to present a sheet with an optional item and custom content view
    func contentSheet<Item, Destination: View>(
        item: Binding<Item?>,
        backgroundStyle: SheetBackgroundStyle = .default,
        @ViewBuilder contentView: @escaping (Item) -> Destination
    ) -> some View {
        // Binding to track if the item is non-nil (i.e., the sheet should be presented)
        let isActive = Binding(
            get: { item.wrappedValue != nil },
            set: { value in if !value { item.wrappedValue = nil } }
        )
        
        // Call the main contentSheet method with the isActive binding and content view
        return contentSheet(isPresented: isActive, backgroundStyle: backgroundStyle) {
            item.wrappedValue.map(contentView)
        }
    }
    
    // Main method to present a sheet with a specified presentation state and content
    func contentSheet<Content: View>(
        isPresented: Binding<Bool>,
        backgroundStyle: SheetBackgroundStyle = .default,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        // Use a TransparentSheet to present the content wrapped in a SheetContainerView
        self.background(
            TransparentSheet(
                isPresented: isPresented,
                content: SheetContainerView(
                    isModalPresented: isPresented,
                    sheetBackgroundStyle: backgroundStyle,
                    content
                )
            )
        )
    }
}

// A container view to customize the appearance and behavior of the sheet content
public struct SheetContainerView<Content: View>: View {
    @Binding public var isModalPresented: Bool  // Binding to control the presentation state
    public var content: () -> Content  // The content to be presented in the sheet
    
    @State private var backgroundColor: Color = .white.opacity(0.01)  // Initial background color
    @State private var sheetBackgroundStyle: SheetBackgroundStyle  // The style of the sheet background
    
    // Initializer to set up the bindings and background style
    public init(isModalPresented: Binding<Bool>,
                sheetBackgroundStyle: SheetBackgroundStyle,
                _ content: @escaping () -> Content
    ) {
        self._isModalPresented = isModalPresented
        self.sheetBackgroundStyle = sheetBackgroundStyle
        self.content = content
    }
    
    public var body: some View {
        ZStack {
            // Background rectangle to handle tap gestures and background color
            Rectangle()
                .foregroundColor(.clear)
                .background(backgroundColor)
                .onAppear {
                    // Animate the background color change if the style is default
                    if sheetBackgroundStyle == .default {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                backgroundColor = .black.opacity(0.1)
                            }
                        }
                    }
                }
                .onTapGesture {
                    // Dismiss the sheet when the background is tapped
                    backgroundColor = .clear
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isModalPresented = false
                    }
                }
            
            VStack(spacing: 0) {
                Spacer()  // Spacer to push the content to the bottom
                
                VStack {
                    WideSpacerView(.horizontal)  // Add some horizontal spacing
                    content()  // The sheet content
                }
                .background(
                    Color.white
                        .cornerRadius(20)  // Rounded corners for the sheet
                        .shadow(radius: 2)  // Add a shadow for depth
                )
                
            }
        }
        .edgesIgnoringSafeArea(.bottom)  // Ignore safe area at the bottom
    }
}
