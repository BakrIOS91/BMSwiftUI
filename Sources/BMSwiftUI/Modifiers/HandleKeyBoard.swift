//
//  File.swift
//  
//
//  Created by Bakr mohamed on 03/08/2024.
//

import SwiftUI

struct HandelKeyBoard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                TapGesture().onEnded {
                    #if canImport(UIKit)
                    UIApplication.shared.dismissKeyboard()
                    #endif
                }
            )
    }
}
