//
//  File.swift
//  BMSwiftUI
//
//  Created by Bakr mohamed on 03/11/2024.
//

import SwiftUI

public struct DeviceHelper {
    /// Returns a scaling factor relative to iPhone 14 width (390pt).
    public static func getScalingFactor() -> CGFloat {
        let idiom = UIDevice.current.userInterfaceIdiom
        
        if idiom == .pad {
            return 1.5
        }
        
        let screenWidth = UIScreen.main.bounds.width
        let referenceWidth: CGFloat = 440  // iPhone 16 Pro max width in points
        
        // scale relative to baseline
        let scale = screenWidth / referenceWidth
        
        return min(scale, 1.1)
    }
}
