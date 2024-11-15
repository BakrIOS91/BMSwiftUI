//
//  File.swift
//  BMSwiftUI
//
//  Created by Bakr mohamed on 12/11/2024.
//

import Foundation
import UIKit

extension UINavigationController: UIGestureRecognizerDelegate {
    open override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // Enable the gesture only if there is more than one view controller on the stack
        return viewControllers.count > 1
    }
}
