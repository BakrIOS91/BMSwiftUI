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
// A UIHostingController subclass to present SwiftUI views with a transparent background
public class TransparentHostingController<Content: View>: UIHostingController<Content> {
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear  // Make the background clear
        modalPresentationStyle = .overCurrentContext  // Present over the current context
    }
}

// A custom presentation controller to disable drag-to-dismiss
class NonDismissablePresentationController: UIPresentationController {
    override var shouldPresentInFullscreen: Bool {
        return true
    }
    
    override var shouldRemovePresentersView: Bool {
        return false
    }
    
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        presentedViewController.view.frame = containerView!.bounds
    }
    
    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        super.dismissalTransitionDidEnd(completed)
    }
    
     var canBeDismissed: Bool {
        return false
    }
}

// A UIViewControllerRepresentable to wrap a SwiftUI view in a transparent sheet
public struct TransparentSheet<Content: View>: UIViewControllerRepresentable {
    @Binding public var isPresented: Bool  // Binding to control the presentation state
    public let content: Content  // The content to be presented in the sheet
    
    // Coordinator class to manage the presentation and dismissal
    public class Coordinator: NSObject, UIViewControllerTransitioningDelegate, UIAdaptivePresentationControllerDelegate {
        var parent: TransparentSheet
        
        init(parent: TransparentSheet) {
            self.parent = parent
        }
        
        public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            // Ensure the update happens on the main thread
            DispatchQueue.main.async {
                self.parent.isPresented = false
            }
        }
        
        func presentationController(_ controller: UIPresentationController, willPresentWithAdaptiveStyle style: UIModalPresentationStyle) -> UIViewController? {
            return nil
        }
        
        public func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
            return false
        }
        
        public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
            return .none
        }
        
        public func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
            // Prevent dismissal by ignoring this delegate method
        }
    }
    
    // Create the coordinator
    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    // Create the initial UIViewController
    public func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        viewController.view.backgroundColor = .clear
        return viewController
    }
    
    // Update the UIViewController based on the isPresented state
    public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresented {
            // Allow re-presentation if the presented view controller is not a TransparentHostingController
            if uiViewController.presentedViewController == nil || !(uiViewController.presentedViewController is TransparentHostingController<Content>) {
                let hostingController = TransparentHostingController(rootView: content)
                hostingController.transitioningDelegate = context.coordinator
                hostingController.presentationController?.delegate = context.coordinator
                hostingController.modalPresentationStyle = .overCurrentContext
                
                debugPrint("Presenting the sheet.")
                uiViewController.present(hostingController, animated: true, completion: nil)
            }
        } else {
            if let presentedViewController = uiViewController.presentedViewController,
               presentedViewController is TransparentHostingController<Content> {
                presentedViewController.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    // Custom transition delegate to disable interactive dismissal
    public func makeUIViewControllerTransitioningDelegate() -> UIViewControllerTransitioningDelegate {
        return NonDismissableTransitionDelegate()
    }
}

// Custom transition delegate to disable interactive dismissal
class NonDismissableTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return NonDismissablePresentationController(presentedViewController: presented, presenting: presenting)
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
