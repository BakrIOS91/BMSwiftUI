//
//  Bundle+Ex.swift
//
//  Created by Bakr Mohamed on 01/08/2024.
//  Copyright © 2024 Link Development. All rights reserved.
//
import Foundation

//public final class BundleToken {
//    public static var kBundleKey: UInt8 = 0
//    
//    public static let bundle: Bundle = {
//        // Use the main bundle for the project
//        return Bundle.main
//    }()
//}
//
//public extension Bundle {
//    /// Override the main bundle class (once in the app life) to make the new localizedString function work
//    static let onceAction: Void = {
//        object_setClass(Bundle.main, Bundle.self)
//    }()
//    
//    static func setLanguage(language: String) {
//        Bundle.onceAction
//        
//        UserDefaults.standard.set([language], forKey: "AppleLanguages")
//        UserDefaults.standard.synchronize()
//        
//        guard let path = Bundle.main.path(forResource: language, ofType: "lproj") else {
//            return
//        }
//        
//        if let languageBundle = Bundle(path: path) {
//            objc_setAssociatedObject(Bundle.main, &BundleToken.kBundleKey, languageBundle, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//            
//            // Debug: List files in the bundle path
//            do {
//                let files = try FileManager.default.contentsOfDirectory(atPath: path)
//                NSLog("Files in bundle path: \(files)")
//            } catch {
//                NSLog("Failed to list files in bundle path: \(error)")
//            }
//        } else {
//            NSLog("Failed to create bundle for path: \(path)")
//        }
//    }
//}


import Foundation

public class LocalizedBundle: Bundle, @unchecked Sendable {
    private static var customLanguageBundle: Bundle?
    private static let lock = NSLock() // Synchronization lock

    public override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        LocalizedBundle.lock.lock()
        defer { LocalizedBundle.lock.unlock() }

        return LocalizedBundle.customLanguageBundle?.localizedString(forKey: key, value: value, table: tableName)
            ?? super.localizedString(forKey: key, value: value, table: tableName)
    }

    static func setLanguage(_ language: String) {
        LocalizedBundle.lock.lock()
        defer { LocalizedBundle.lock.unlock() }

        if let path = Bundle.main.path(forResource: language, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            LocalizedBundle.customLanguageBundle = bundle
        } else {
            LocalizedBundle.customLanguageBundle = nil // fallback to default
        }
    }
}

public extension Bundle {
    private static var onLanguageDispatchOnce: () = {
        object_setClass(Bundle.main, LocalizedBundle.self)
    }()
    
    static func switchLanguage(to language: String) {
        // Ensure the bundle swizzling is done once
        _ = self.onLanguageDispatchOnce
        LocalizedBundle.setLanguage(language)
    }
}
