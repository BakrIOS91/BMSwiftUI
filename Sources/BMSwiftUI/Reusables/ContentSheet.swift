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
    case `default`(opacity: CGFloat)
    case blured(blur: CGFloat, opacity: CGFloat)
    case transparent
}

public enum TransitionEffect {
    case `default`
    case fade
}

public class TransparentHostingController<Content: View>: UIHostingController<Content> {
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
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
    var transitionEffect: TransitionEffect
    var onDismiss: () -> Void
    public var content: () -> Content
    
    init(
        isPresented: Binding<Bool>,
        transitionEffect: TransitionEffect,
        onDismiss: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._isPresented = isPresented
        self.transitionEffect = transitionEffect
        self.onDismiss = onDismiss
        self.content = content
    }
    
    public class Coordinator: NSObject, UIViewControllerTransitioningDelegate, UIAdaptivePresentationControllerDelegate {
        weak var sheetController: UIViewController?
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
            if context.coordinator.sheetController == nil {
                let sheetController = TransparentHostingController(rootView: content())
                sheetController.modalPresentationStyle = .overFullScreen
                sheetController.view.backgroundColor = .clear // Transparent background
                
                // Choose the desired transition effect
                let customTransitioningDelegate = CustomTransitioningDelegate(transitionEffect: transitionEffect)
                sheetController.transitioningDelegate = customTransitioningDelegate

                sheetController.presentationController?.delegate = context.coordinator
                context.coordinator.sheetController = sheetController
                uiViewController.present(sheetController, animated: true)
            }
        } else {
            // Dismiss only the sheet we are managing
            if let sheetController = context.coordinator.sheetController,
               uiViewController.presentedViewController == sheetController {
                uiViewController.dismiss(animated: true) {
                    self.onDismiss()
                    DispatchQueue.main.async {
                        self.isPresented = false
                    }
                }
                context.coordinator.sheetController = nil
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
        appendInSheetContainer: Bool = true,
        transitionEffect: TransitionEffect = .default,
        onTabDismissEnabled: Bool = true,
        backgroundColor: Color = .white.opacity(0.01),
        sheetBackgroundColor: Color = .white,
        sheetCorrnerRaduis: CGFloat = 20,
        backgroundStyle: SheetBackgroundStyle = .transparent,
        onDismiss: @escaping () -> Void = {},
        @ViewBuilder contentView: @escaping (Item) -> Destination
    ) -> some View {
        let isActive = Binding(
            get: { item.wrappedValue != nil },
            set: { value in if !value { item.wrappedValue = nil } }
        )
        
        return contentSheet(
            isPresented: isActive,
            appendInSheetContainer: appendInSheetContainer,
            transitionEffect: transitionEffect,
            onTabDismissEnabled: onTabDismissEnabled,
            backgroundColor: backgroundColor,
            sheetBackgroundColor: sheetBackgroundColor,
            sheetCorrnerRaduis: sheetCorrnerRaduis,
            backgroundStyle: backgroundStyle,
            onDismiss: onDismiss
        ) {
            item.wrappedValue.map(contentView)
        }
    }
    @ViewBuilder
    func contentSheet<Content: View>(
        isPresented: Binding<Bool>,
        appendInSheetContainer: Bool = true,
        transitionEffect: TransitionEffect = .default,
        onTabDismissEnabled: Bool = true,
        backgroundColor: Color = .white.opacity(0.01),
        sheetBackgroundColor: Color = .white,
        sheetCorrnerRaduis: CGFloat = 20,
        backgroundStyle: SheetBackgroundStyle = .transparent,
        onDismiss: @escaping () -> Void = {},
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        switch backgroundStyle {
        case .default, .transparent:
            self.background(
                TransparentSheet(
                    isPresented: isPresented,
                    transitionEffect: transitionEffect,
                    onDismiss: onDismiss,
                    content: {
                        if appendInSheetContainer {
                            SheetContainerView(
                                isModalPresented: isPresented,
                                onTabDismissEnabled: onTabDismissEnabled,
                                backgroundColor: backgroundColor,
                                sheetBackgroundStyle: backgroundStyle,
                                sheetBackgroundColor: sheetBackgroundColor,
                                sheetCorrnerRaduis: sheetCorrnerRaduis,
                                content
                            )
                        } else {
                            content()
                        }
                    }
                )
            )
        case let .blured(blur, opacity):
            self.background(
                TransparentSheet(
                    isPresented: isPresented,
                    transitionEffect: transitionEffect,
                    onDismiss: onDismiss,
                    content: {
                        if appendInSheetContainer {
                            SheetContainerView(
                                isModalPresented: isPresented,
                                onTabDismissEnabled: onTabDismissEnabled,
                                backgroundColor: backgroundColor,
                                sheetBackgroundStyle: backgroundStyle,
                                sheetBackgroundColor: sheetBackgroundColor,
                                sheetCorrnerRaduis: sheetCorrnerRaduis,
                                blureEffect: blur,
                                content
                            )
                        } else {
                            content()
                                .background(
                                    withAnimation(.easeInOut(duration: 0.3)){
                                        BlurEffectView(
                                            radius: blur,
                                            opacity: opacity,
                                            backgroundColor: .white
                                        )
                                    }
                                )
                        }
                    }
                )
            )
        }
    }
}

public struct SheetContainerView<Content: View>: View {
    @Preference(\.previewLocale) var previewLocale
    @Binding public var isModalPresented: Bool
    public var content: () -> Content
    
    @State private var backgroundColor: Color = .white.opacity(0.01)
    @State private var sheetBackgroundStyle: SheetBackgroundStyle
    
    @State private var onTabDismissEnabled: Bool = true
    @State private var opacityLevel: CGFloat = .zero
    @State private var blureEffect: CGFloat = .zero
    var sheetBackgroundColor: Color = .white
    var sheetCorrnerRaduis: CGFloat = 0

    public init(
        isModalPresented: Binding<Bool>,
        onTabDismissEnabled: Bool = true,
        backgroundColor: Color = .white.opacity(0.01),
        sheetBackgroundStyle: SheetBackgroundStyle,
        sheetBackgroundColor: Color = .white,
        sheetCorrnerRaduis: CGFloat = 0,
        opacityLevel: CGFloat = 0.1,
        blureEffect: CGFloat = 1,
        _ content: @escaping () -> Content
    ) {
        self._isModalPresented = isModalPresented
        self.onTabDismissEnabled = onTabDismissEnabled
        self.backgroundColor = backgroundColor
        self.sheetBackgroundStyle = sheetBackgroundStyle
        self.content = content
        self.opacityLevel = opacityLevel
        self.blureEffect = blureEffect
        self.sheetBackgroundColor = sheetBackgroundColor
        self.sheetCorrnerRaduis = sheetCorrnerRaduis
        
        print(sheetBackgroundColor,opacityLevel,blureEffect)
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack {
                WideSpacerView(.horizontal)
                content()
            }
            .background(
                sheetBackgroundColor
                    .setCornerRadius(sheetCorrnerRaduis)
                    .shadow(radius: 2)
            )
            
        }
        .background(
            Group{
                switch sheetBackgroundStyle {
                case let .default(opacity: opacity):
                    backgroundColor.opacity(opacity)
                case let .blured(blur: blur, opacity: opacity):
                    BlurEffectView(
                        radius: blur,
                        opacity: opacity,
                        backgroundColor: backgroundColor
                    )
                case .transparent:
                    backgroundColor.opacity(0)
                }
            }
            .onTapGesture {
                if onTabDismissEnabled {
                    backgroundColor = .clear
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isModalPresented = false
                    }
                }
            }
        )
        .ignoresSafeArea()
        
    }
}

#endif
