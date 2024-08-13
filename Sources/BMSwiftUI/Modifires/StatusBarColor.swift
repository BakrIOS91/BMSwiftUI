//
//  StatusBarColor.swift
//  ServeBig
//
//  Created by Bakr mohamed on 28/07/2024.
//  Copyright © 2024 Link Development. All rights reserved.
//

import SwiftUI

public struct StatusColorModifier: ViewModifier {
    private var color: Color
    
    public init(color: Color) {
        self.color = color
    }
    
    public func body(content: Content) -> some View {
        ZStack {
            color
                .edgesIgnoringSafeArea(.top)
            
            content
                .background(Color.white)
        }
    }
}

public extension View {
    func setStatusBarColor(_ color: Color = .white) -> some View {
        self.modifier(StatusColorModifier(color: color))
    }
}
