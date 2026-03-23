//
//  File.swift
//  BMSwiftUI
//
//  Created by Bakr mohamed on 06/01/2025.
//

import Foundation
import UIKit

public final class CustomTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    var transitionEffect : TransitionEffect
    
    init(transitionEffect: TransitionEffect) {
        self.transitionEffect = transitionEffect
    }
    
    public func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch transitionEffect {
        case .default:
            return nil
        case .fade:
            return FadeInAnimator()
        }
        
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch transitionEffect {
        case .default:
            return nil
        case .fade:
            return FadeOutAnimator()
        }
    }
}

public class FadeInAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.view(forKey: .to) else { return }
        let containerView = transitionContext.containerView

        // Set the initial frame of the toView
        toView.frame = containerView.bounds
        toView.alpha = 0
        containerView.addSubview(toView)

        // Animate to final opacity
        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       animations: {
            toView.alpha = 1
        }) { finished in
            transitionContext.completeTransition(finished)
        }
    }
}

public class FadeOutAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from) else { return }
        let containerView = transitionContext.containerView

        // Ensure the fromView is in the container view
        containerView.addSubview(fromView)

        // Animate the fade-out effect
        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       animations: {
            fromView.alpha = 0 // Fade out
        }) { finished in
            // Clean up the view and complete the transition
            fromView.removeFromSuperview()
            transitionContext.completeTransition(finished)
        }
    }
}
