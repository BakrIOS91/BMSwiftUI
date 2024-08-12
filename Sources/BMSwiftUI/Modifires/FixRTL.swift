//
//  FixRTL.swift
//  ServeBig
//
//  Created by Bakr mohamed on 12/08/2024.
//  Copyright © 2024 Link Development. All rights reserved.
//

import SwiftUI

struct FixRTLModifier: ViewModifier {
    @Environment(\.layoutDirection) var layoutDirection
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(x: layoutDirection == .rightToLeft ? -1 : 1, y: 1)
    }
}

extension View {
    func fixRTL() -> some View {
        modifier(FixRTLModifier())
    }
}
