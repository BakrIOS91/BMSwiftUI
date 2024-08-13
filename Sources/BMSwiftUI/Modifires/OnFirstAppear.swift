//
//  OnFirstAppear.swift
//  ServeBig
//
//  Created by Bakr mohamed on 11/08/2024.
//  Copyright © 2024 Link Development. All rights reserved.
//

import SwiftUI
public struct OnFirstAppear: ViewModifier {
    private let perform: () -> Void
    
    @Binding private var firstTime: Bool
    
    public init(
        firstTime: Binding<Bool>,
        perform: @escaping () -> Void
    ) {
        self.perform = perform
        self._firstTime = firstTime
    }
    
    public func body(content: Content) -> some View {
        content.onAppear {
            if firstTime {
                firstTime = false
                perform()
            }
        }
    }
}

public extension View {
    func onFirstAppear (
        firstTime: Binding<Bool>,
        perform: @escaping () -> Void
    ) -> some View {
        modifier(
            OnFirstAppear(
                firstTime: firstTime,
                perform: perform
            )
        )
    }
}
