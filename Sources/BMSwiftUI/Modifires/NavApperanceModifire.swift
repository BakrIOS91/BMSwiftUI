//
//  NavApperanceModifire.swift
//  ApoApp
//
//  Created by Bakr mohamed on 29/05/2023.
//

import SwiftUI

// MARK: - NavigationConfigurator

struct NavigationConfigurator {
    var configure: (UINavigationController?) -> Void = { _ in }
}

// MARK: - Coordinator

extension NavigationConfigurator {
    /// Tracks navigationController changes and contigures it when it changes
    class Coordinator {
        var parent: NavigationConfigurator
        var observation: NSKeyValueObservation?

        init(
            _ parent: NavigationConfigurator
        ) {
            self.parent = parent
        }
        
        fileprivate func observeNavigationContollerChanges(
            from vc: ViewController,
            changeHandler: ((UINavigationController?) -> Void)?
        ) {
            observation = vc.observe(\.navigationControllerReference, options: [.new]) { _, change in
                changeHandler?(change.newValue!)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

// MARK: - UIViewControllerRepresentable

extension NavigationConfigurator: UIViewControllerRepresentable {

    // When we just created viewContoller, it wont contain navigationContoller
    // So we wait for it to configure
    func makeUIViewController(
        context: UIViewControllerRepresentableContext<NavigationConfigurator>
    ) -> UIViewController {
        let vc = ViewController()
        configure(vc.navigationController)
        context.coordinator.observeNavigationContollerChanges(from: vc) { navigationController in
            configure(navigationController)
        }
        return vc
    }
    
    // If we update viewContoller, and navigationContoller is missing at this point, just ignore
    func updateUIViewController(
        _ uiViewController: UIViewController,
        context: UIViewControllerRepresentableContext<NavigationConfigurator>
    ) {
        configure(uiViewController.navigationController)
    }
    
}

// MARK: - ViewController

private final class ViewController: UIViewController {
    @objc dynamic weak var navigationControllerReference: UINavigationController?
    
    override func viewWillAppear(
        _ animated: Bool
    ) {
        super.viewWillAppear(animated)
        
        navigationControllerReference = navigationController
    }
}

// MARK: - ViewModifier

struct NavAppearanceModifier: ViewModifier {
    
    let standard: UINavigationBarAppearance
    let tintColor: UIColor?
    
    init(
        titleTextAttributes: [NSAttributedString.Key: Any],
        largeTitleTextAttributes: [NSAttributedString.Key: Any],
        tintColor: UIColor?,
        shadowColor: UIColor?,
        backgroundColor: UIColor?,
        backImage: UIImage?
    ) {
        let standard = UINavigationBarAppearance()
        if backgroundColor == .clear || backgroundColor == nil {
            standard.configureWithTransparentBackground()
        } else {
            standard.configureWithDefaultBackground()
        }
        standard.backgroundColor = backgroundColor
        standard.titleTextAttributes = titleTextAttributes
        standard.largeTitleTextAttributes = largeTitleTextAttributes
        standard.shadowColor = shadowColor
        
        let button = UIBarButtonItemAppearance(style: .plain)
        button.normal.titleTextAttributes = [.foregroundColor: tintColor ?? .systemBlue]
        standard.buttonAppearance = button
          
        let done = UIBarButtonItemAppearance(style: .done)
        done.normal.titleTextAttributes = [.foregroundColor: tintColor ?? .systemBlue]
        standard.doneButtonAppearance = done
        
        standard.setBackIndicatorImage(backImage, transitionMaskImage: backImage)
        
        self.standard = standard
        self.tintColor = tintColor
    }
    
    func body(
        content: Content
    ) -> some View {
        content
            .background(
                NavigationConfigurator { nc in
                    nc?.navigationBar.standardAppearance = standard
                    nc?.navigationBar.compactAppearance = standard
                    nc?.navigationBar.scrollEdgeAppearance = standard
                    
                    if let tintColor = tintColor {
                        nc?.navigationBar.tintColor = tintColor
                    }
                }
            )
    }
}

