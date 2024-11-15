//
//  Bundle+Ex.swift
//
//  Created by Bakr Mohamed on 01/08/2024.
//  Copyright © 2024 Link Development. All rights reserved.
//
import Foundation

public final class BundleToken {
    public static var kBundleKey: UInt8 = 0
    
    public static let bundle: Bundle = {
        // Use the main bundle for the project
        return Bundle.main
    }()
}

public extension Bundle {
    /// Override the main bundle class (once in the app life) to make the new localizedString function work
    static let onceAction: Void = {
        object_setClass(Bundle.main, Bundle.self)
    }()
    
    static func setLanguage(language: String) {
        Bundle.onceAction
        
        UserDefaults.standard.set([language], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj") else {
            return
        }
        
        if let languageBundle = Bundle(path: path) {
            objc_setAssociatedObject(Bundle.main, &BundleToken.kBundleKey, languageBundle, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            // Debug: List files in the bundle path
            do {
                let files = try FileManager.default.contentsOfDirectory(atPath: path)
                NSLog("Files in bundle path: \(files)")
            } catch {
                NSLog("Failed to list files in bundle path: \(error)")
            }
        } else {
            NSLog("Failed to create bundle for path: \(path)")
        }
    }
}
