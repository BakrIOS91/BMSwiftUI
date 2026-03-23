//
//  OnFirstAppear.swift
//  ServeBig
//
//  Created by Bakr mohamed on 11/08/2024.
//  Copyright © 2024 Link Development. All rights reserved.
//

import SwiftUI

public extension View {
    func onFirstAppear(perform action: @escaping () -> Void) -> some View {
        modifier(FirstAppearModifier(action: action))
    }
    
    func onFirstAppear(
            hasAppeared: Binding<Bool>,
            perform action: @escaping () -> Void
        ) -> some View {
            modifier(FirstAppearModifierTwo(hasAppeared: hasAppeared, action: action))
        }
}

public struct FirstAppearModifier: ViewModifier {
    @State private var hasAppeared = false
    let action: () -> Void
    
    public func body(content: Content) -> some View {
        content.onAppear {
            if !hasAppeared {
                hasAppeared = true
                action()
            }
        }
    }
}


public struct FirstAppearModifierTwo: ViewModifier {
    @Binding var hasAppeared: Bool
    let action: () -> Void

    public func body(content: Content) -> some View {
        content.onAppear {
            if !hasAppeared {
                hasAppeared = true
                action()
            }
        }
    }
}
