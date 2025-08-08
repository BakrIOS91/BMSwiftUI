//
//  Color+Ext.swift
//  BMSwiftUI
//
//  Created by Bakr mohamed on 08/08/2025.
//

import SwiftUI

public extension Color {
    
    /// Creates a SwiftUI `Color` from a single hexadecimal string.
    ///
    /// - Parameter hex: A 6-character hex string representing the color.
    ///                  Accepts optional `#` prefix (e.g., "#FF5733" or "FF5733").
    /// - Note: In **Debug** builds, logs an error if the provided hex string
    ///         is invalid. In that case, `.clear` will be used.
    ///
    /// Example:
    /// ```swift
    /// let red = Color(hex: "#FF0000")
    /// ```
    init(hex: String) {
        // Attempt to parse the hex into a SwiftUI Color
        guard let color = Color.parseHexColor(hex) else {
            #if DEBUG
            NSLog("Color log: Invalid hex color format -> \(hex)")
            #endif
            self = .clear // Fallback to clear if invalid
            return
        }
        self = color
    }
    
    /// Creates a SwiftUI `Color` that automatically adapts to the system's
    /// light or dark appearance using two hex strings.
    ///
    /// - Parameters:
    ///   - light: Hex string used when the system is in light mode.
    ///   - dark:  Hex string used when the system is in dark mode.
    /// - Note: In **Debug** builds, logs an error if the provided hex string
    ///         is invalid for either mode. Falls back to `.clear` in that case.
    ///
    /// Example:
    /// ```swift
    /// let adaptiveColor = Color(light: "#FFFFFF", dark: "#000000")
    /// ```
    init(light: String, dark: String) {
        // Use UIColor with dynamic provider to return light or dark color depending on system mode
        self = Color(UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                // Dark mode
                if let uiColor = Color.parseHexUIColor(dark) {
                    return uiColor
                } else {
                    #if DEBUG
                    NSLog("Color log: Invalid dark mode hex color format -> \(dark)")
                    #endif
                    return .clear
                }
            } else {
                // Light mode
                if let uiColor = Color.parseHexUIColor(light) {
                    return uiColor
                } else {
                    #if DEBUG
                    NSLog("Color log: Invalid light mode hex color format -> \(light)")
                    #endif
                    return .clear
                }
            }
        })
    }
    
    // MARK: - Private helpers
    
    /// Parses a hex string into a SwiftUI `Color`.
    ///
    /// - Parameter hex: Hex string to parse.
    /// - Returns: A `Color` if valid, otherwise `nil`.
    private static func parseHexColor(_ hex: String) -> Color? {
        guard let uiColor = parseHexUIColor(hex) else { return nil }
        return Color(uiColor)
    }
    
    /// Parses a hex string into a UIKit `UIColor`.
    ///
    /// - Parameter hex: Hex string to parse (must be 6 characters after optional `#` removal).
    /// - Returns: A `UIColor` if valid, otherwise `nil`.
    private static func parseHexUIColor(_ hex: String) -> UIColor? {
        // Remove `#` prefix if present
        let cleanedHex = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
        guard cleanedHex.count == 6 else { return nil }
        
        // Extract red, green, and blue hex pairs
        let rHex = String(cleanedHex.prefix(2))
        let gHex = String(cleanedHex.dropFirst(2).prefix(2))
        let bHex = String(cleanedHex.dropFirst(4))
        
        // Convert each hex pair to an Int
        guard let r = hexToInt(rHex),
              let g = hexToInt(gHex),
              let b = hexToInt(bHex) else {
            return nil
        }
        
        // Create UIColor from RGB values
        return UIColor(
            red: CGFloat(r) / 255.0,
            green: CGFloat(g) / 255.0,
            blue: CGFloat(b) / 255.0,
            alpha: 1.0
        )
    }
    
    /// Converts a 2-character hex string into an integer value (0–255).
    ///
    /// - Parameter hex: Two-character hex string (e.g., "FF").
    /// - Returns: An `Int` if valid, otherwise `nil`.
    private static func hexToInt(_ hex: String) -> Int? {
        let hexDigits = "0123456789abcdef"
        var result = 0
        
        for char in hex.lowercased() {
            // Ensure character is a valid hex digit
            guard let index = hexDigits.firstIndex(of: char) else { return nil }
            let digit = hexDigits.distance(from: hexDigits.startIndex, to: index)
            result = result * 16 + digit
        }
        
        return result
    }
}
