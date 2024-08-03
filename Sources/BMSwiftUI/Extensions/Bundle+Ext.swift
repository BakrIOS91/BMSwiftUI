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
        return Bundle(for: BundleToken.self)
    }()
}

public final class BundleExtension: Bundle {
    public static var shared = BundleExtension()
    
    public override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        guard let bundle = objc_getAssociatedObject(self, &BundleToken.kBundleKey) as? Bundle else {
            return Bundle.main.localizedString(forKey: key, value: value, table: tableName)
        }
        
        // Fetch localized string from custom bundle
        let localizedString = bundle.localizedString(forKey: key, value: value, table: tableName)
        
        // Debug print
        print("Localized String: \(localizedString) for key: \(key)")
        return localizedString
    }
}

public extension Bundle {
    static private var appLanguageDefaultsKey: String = "kAppLanguage"
    static private var bundleType: String = "lproj"
    
    /// Override the main bundle class (once in the app life) to make the new localizedString function work
    static let onceAction: Void = {
        object_setClass(Bundle.main, BundleExtension.self)
    }()
    
    static func setLanguage(language: String) {
        Bundle.onceAction
        UserDefaults.standard.set([language], forKey: appLanguageDefaultsKey)
        UserDefaults.standard.synchronize()
        
        guard let path = Bundle.main.path(forResource: language, ofType: bundleType) else {
            print("Failed to find path for resource: \(language).\(bundleType)")
            return
        }
        
        if let languageBundle = Bundle(path: path) {
            objc_setAssociatedObject(Bundle.main, &BundleToken.kBundleKey, languageBundle, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            // Debug: List files in the bundle path
            do {
                let files = try FileManager.default.contentsOfDirectory(atPath: path)
                print("Files in bundle path: \(files)")
            } catch {
                print("Failed to list files in bundle path: \(error)")
            }
            
        } else {
            print("Failed to create bundle for path: \(path)")
        }
    }
}
