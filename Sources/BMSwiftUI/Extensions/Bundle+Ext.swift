//
//  Bundle+Ex.swift
//
//  Created by Bakr Mohamed on 01/08/2024.
//  Copyright © 2024 Link Development. All rights reserved.
//

import Foundation

private final class BundleToken {
    static var kBundleKey: UInt8 = 0
    
    static let bundle: Bundle = {
        // Use the main bundle for the project
        return Bundle.main
    }()
}

public final class BundleExtension: Bundle {
    public static let shared = BundleExtension()
    
    public override func localizedString(forKey key: String, value: String? = nil, table tableName: String? = nil) -> String {
        guard let bundle = objc_getAssociatedObject(self, &BundleToken.kBundleKey) as? Bundle else {
            return Bundle.main.localizedString(forKey: key, value: value, table: tableName)
        }
        
        // Fetch localized string from custom bundle
        let localizedString = bundle.localizedString(forKey: key, value: value, table: tableName)
        
        return localizedString
    }
}

public extension Bundle {
    /// Override the main bundle class (once in the app life) to make the new localizedString function work
    static let onceAction: Void = {
        object_setClass(Bundle.main, BundleExtension.self)
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
