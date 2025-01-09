//
//  File.swift
//  BMSwiftUI
//
//  Created by Bakr mohamed on 03/11/2024.
//

import SwiftUI
#warning("Temp Disable untill Finalize")
public struct DeviceHelper {
    static func getScalingFactor() -> CGFloat {
        let nativeWidth = UIScreen.main.nativeBounds.width
        
        // Set scaling factor based on actual screen resolution in pixels
        if UIDevice.current.userInterfaceIdiom == .pad {
            return 1.5 // iPad scaling factor
        } else if nativeWidth <= 640 { // iPhone SE (1st, 2nd and 3rd gen), iPhone 5, 5s, 5c (640 x 1136)
            return 0.75 // Scale down for smaller iPhones
        } else if nativeWidth <= 750 { // iPhone 6, 6s, 7, 8 (750 x 1334)
            return 0.8 // Normal iPhone sizes
        } else if nativeWidth <= 1080 { // iPhone 6+/7+/8+ (1080 x 1920 / 1242 x 2208)
            return 0.85 // Slightly larger scaling for Plus models
        } else if nativeWidth <= 1125 { // iPhone X, XS (1125 x 2436)
            return 0.9 // Scaling for notch iPhones
        } else if nativeWidth <= 1242 { // iPhone XS Max (1242 x 2688)
            return 0.95 // Larger iPhone scaling
        } else if nativeWidth <= 1284 { // iPhone 12 Pro Max, 13 Pro Max (1284 x 2778)
            return 0.95 // Largest iPhones scaling
        } else {
            return 1.0 // Default scaling factor for newer iPhones not listed
        }
    }
}
