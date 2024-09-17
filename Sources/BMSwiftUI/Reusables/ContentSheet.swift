//
//  ContentSheet.swift
//
//
//  Created by Bakr mohamed on 29/05/2024.
//
#if os(iOS)
import SwiftUI
import UIKit
// MARK: Detect if app in Preview Mode
public var isInPreview: Bool {
    return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
}

public enum SheetBackgroundStyle {
    case `default`
    case transparent
}

public class TransparentHostingController<Content: View>: UIHostingController<Content> {
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
//        modalPresentationStyle = .overCurrentContext
    }
}

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

public struct TransparentSheet<Content: View>: UIViewControllerRepresentable {
    @Binding public var isPresented: Bool
    public let content: Content
    
    public class Coordinator: NSObject, UIViewControllerTransitioningDelegate, UIAdaptivePresentationControllerDelegate {
        var parent: TransparentSheet
        
        init(parent: TransparentSheet) {
            self.parent = parent
        }
        
        public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
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
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    public func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        viewController.view.backgroundColor = .clear
        return viewController
    }
    
    public func updateUIViewController(_ uiViewController: UIViewController, context: Context){
        if isPresented {
            // Check if there is already a presented view controller
            if let presentedVC = uiViewController.presentedViewController {
                // Dismiss the existing presented view controller
                presentedVC.dismiss(animated: true, completion: {
                    // Present the new view controller after dismissal
                    let hostingController = TransparentHostingController(rootView: content)
                    hostingController.transitioningDelegate = context.coordinator
                    hostingController.presentationController?.delegate = context.coordinator
                    hostingController.modalPresentationStyle = .overCurrentContext
                    uiViewController.present(hostingController, animated: true, completion: nil)
                })
            } else {
                // If there is no presented view controller, present the new one
                let hostingController = TransparentHostingController(rootView: content)
                hostingController.transitioningDelegate = context.coordinator
                hostingController.presentationController?.delegate = context.coordinator
                hostingController.modalPresentationStyle = .overCurrentContext
                uiViewController.present(hostingController, animated: true, completion: nil)
            }
        } else {
            DispatchQueue.main.async {
                if let presentedViewController = uiViewController.presentedViewController {
                    presentedViewController.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    
    public func makeUIViewControllerTransitioningDelegate() -> UIViewControllerTransitioningDelegate {
        return NonDismissableTransitionDelegate()
    }
}

class NonDismissableTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return NonDismissablePresentationController(presentedViewController: presented, presenting: presenting)
    }
}

public extension View {
    func contentSheet<Item, Destination: View>(
        item: Binding<Item?>,
        backgroundStyle: SheetBackgroundStyle = .default,
        @ViewBuilder contentView: @escaping (Item) -> Destination
    ) -> some View {
        let isActive = Binding(
            get: { item.wrappedValue != nil },
            set: { value in if !value { item.wrappedValue = nil } }
        )
        
        return contentSheet(isPresented: isActive, backgroundStyle: backgroundStyle) {
            item.wrappedValue.map(contentView)
        }
    }
    
    func contentSheet<Content: View>(
        isPresented: Binding<Bool>,
        backgroundStyle: SheetBackgroundStyle = .default,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
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

public struct SheetContainerView<Content: View>: View {
    @Preference(\.previewLocale) var previewLocale
    @Binding public var isModalPresented: Bool
    public var content: () -> Content
    
    @State private var backgroundColor: Color = .white.opacity(0.01)
    @State private var sheetBackgroundStyle: SheetBackgroundStyle
    
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
            Rectangle()
                .foregroundColor(.clear)
                .background(backgroundColor)
                .onAppear {
                    if sheetBackgroundStyle == .default {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                backgroundColor = .black.opacity(0.1)
                            }
                        }
                    }
                }
                .onTapGesture {
                    backgroundColor = .clear
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isModalPresented = false
                    }
                }
            
            VStack(spacing: 0) {
                Spacer()
                
                VStack {
                    WideSpacerView(.horizontal)
                    content()
                }
                .background(
                    Color.white
                        .cornerRadius(20)
                        .shadow(radius: 2)
                )
                
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .environment(\.locale, previewLocale ?? Locale.current )
        .environment(\.layoutDirection, (previewLocale ?? Locale.current).layoutDirection)
        
    }
}
#endif
