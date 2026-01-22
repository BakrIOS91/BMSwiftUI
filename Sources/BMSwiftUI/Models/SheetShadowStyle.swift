//
//  SheetShadowStyle.swift
//  BMSwiftUI
//
//  Created by bakr.mohamed on 22/01/2026.
//

import SwiftUI

public struct SheetShadowStyle {
    public var color: Color?
    public var radius: CGFloat?
    public var x: CGFloat?
    public var y: CGFloat?

    enum CodingKeys: String, CodingKey {
        case color
        case radius
        case x
        case y
    }

    public init(
        color: Color? = nil,
        radius: CGFloat? = nil,
        x: CGFloat? = nil,
        y: CGFloat? = nil
    ) {
        self.color = color
        self.radius = radius
        self.x = x
        self.y = y
    }

    public static let `default`: SheetShadowStyle = .init(
        color: .clear,
        radius: 0,
        x: 0,
        y: 0
    )
}
