//
//  BlurEffect.swift
//  BMSwiftUI
//
//  Created by Bakr mohamed on 26/11/2024.
//
import SwiftUI

public struct BlurEffect: UIViewRepresentable {

    public func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView()
        let blur = UIBlurEffect(style: .extraLight)
        let animator = UIViewPropertyAnimator()
        animator.addAnimations { view.effect = blur }
        animator.fractionComplete = 0
        animator.stopAnimation(true)
        animator.finishAnimation(at: .start)
        return view
    }
    
    public func updateUIView(_ uiView: UIVisualEffectView, context: Context) { }
    
}

/// A transparent View that blurs its background
public struct BlurEffectView: View {
    
    let radius: CGFloat
    let opacity: CGFloat
    let backgroundColor: Color
    
    public init(radius: CGFloat, opacity: CGFloat, backgroundColor: Color) {
        self.radius = radius
        self.opacity = opacity
        self.backgroundColor = backgroundColor
    }
    
    @ViewBuilder
    public var body: some View {
        ZStack {
            BlurEffect().blur(radius: radius)
            backgroundColor.opacity(opacity)
        }
    }
    
}
