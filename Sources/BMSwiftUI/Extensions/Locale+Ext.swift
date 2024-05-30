//
//  Locale+Ext.swift
//
//
//  Created by Bakr mohamed on 08/02/2024.
//

import Foundation
import SwiftUI

/// An extension to `Locale` providing additional functionality.
public extension Locale {
    /// An enumeration representing supported locales.
    enum SupportedLocale: String {
        // Arabic
        case ar = "ar"
        case ar_AE = "ar_AE" // Arabic (United Arab Emirates)
        case ar_BH = "ar_BH" // Arabic (Bahrain)
        case ar_DZ = "ar_DZ" // Arabic (Algeria)
        case ar_EG = "ar_EG" // Arabic (Egypt)
        case ar_IQ = "ar_IQ" // Arabic (Iraq)
        case ar_JO = "ar_JO" // Arabic (Jordan)
        case ar_KW = "ar_KW" // Arabic (Kuwait)
        case ar_LB = "ar_LB" // Arabic (Lebanon)
        case ar_LY = "ar_LY" // Arabic (Libya)
        case ar_MA = "ar_MA" // Arabic (Morocco)
        case ar_OM = "ar_OM" // Arabic (Oman)
        case ar_QA = "ar_QA" // Arabic (Qatar)
        case ar_SA = "ar_SA" // Arabic (Saudi Arabia)
        case ar_SD = "ar_SD" // Arabic (Sudan)
        case ar_SY = "ar_SY" // Arabic (Syria)
        case ar_TN = "ar_TN" // Arabic (Tunisia)
        case ar_YE = "ar_YE" // Arabic (Yemen)
        
        // English
        case en = "en"
        case en_AU = "en_AU" // English (Australia)
        case en_CA = "en_CA" // English (Canada)
        case en_GB = "en_GB" // English (United Kingdom)
        case en_US = "en_US" // English (United States)
        
        // German
        case de = "de"
        case de_DE = "de_DE" // German (Germany)
        case de_AT = "de_AT" // German (Austria)
        case de_CH = "de_CH" // German (Switzerland)
        
        // Spanish
        case es = "es"
        case es_ES = "es_ES" // Spanish (Spain)
        case es_MX = "es_MX" // Spanish (Mexico)
        
        // French
        case fr = "fr"
        case fr_CA = "fr_CA" // French (Canada)
        case fr_FR = "fr_FR" // French (France)
        
        // Other languages
        case ca_ES = "ca_ES" // Catalan (Spain)
        case cs_CZ = "cs_CZ" // Czech (Czech Republic)
        case da_DK = "da_DK" // Danish (Denmark)
        case el_GR = "el_GR" // Greek (Greece)
        case fi_FI = "fi_FI" // Finnish (Finland)
        case hi_IN = "hi_IN" // Hindi (India)
        case hr_HR = "hr_HR" // Croatian (Croatia)
        case hu_HU = "hu_HU" // Hungarian (Hungary)
        case id_ID = "id_ID" // Indonesian (Indonesia)
        case it_IT = "it_IT" // Italian (Italy)
        case ja_JP = "ja_JP" // Japanese (Japan)
        case ko_KR = "ko_KR" // Korean (South Korea)
        case ms_MY = "ms_MY" // Malay (Malaysia)
        case nb_NO = "nb_NO" // Norwegian Bokmål (Norway)
        case nl_NL = "nl_NL" // Dutch (Netherlands)
        case pl_PL = "pl_PL" // Polish (Poland)
        case pt_BR = "pt_BR" // Portuguese (Brazil)
        case pt_PT = "pt_PT" // Portuguese (Portugal)
        case ro_RO = "ro_RO" // Romanian (Romania)
        case ru_RU = "ru_RU" // Russian (Russia)
        case sk_SK = "sk_SK" // Slovak (Slovakia)
        case sv_SE = "sv_SE" // Swedish (Sweden)
        case th_TH = "th_TH" // Thai (Thailand)
        case tr_TR = "tr_TR" // Turkish (Turkey)
        case uk_UA = "uk_UA" // Ukrainian (Ukraine)
        case vi_VN = "vi_VN" // Vietnamese (Vietnam)
        case zh_CN = "zh_CN" // Chinese (China)
        case zh_HK = "zh_HK" // Chinese (Hong Kong)
        case zh_TW = "zh_TW" // Chinese (Taiwan)
        
        /// Returns the `Locale` object corresponding to the supported locale.
       public var locale: Locale {
            return Locale(identifier: self.rawValue)
        }
    }
    
    /// Returns the best matching locale based on the preferred localizations of the main bundle.
    static var bestMatching: Locale {
        if let identifier = Bundle.main.preferredLocalizations.first,
           let supportedLocale = SupportedLocale(rawValue: identifier.lowercased()){
            return Locale(identifier: supportedLocale.rawValue)
        } else {
            return Locale(identifier: SupportedLocale.en_US.rawValue)
        }
    }
    
    /// Returns the code of the best matching supported locale.
    static var supportedLocaleCode: String? {
        let bestMatchingIdentifier = Locale.bestMatching.identifier
        return SupportedLocale(rawValue: bestMatchingIdentifier)?.rawValue
    }
    
    // Determines if the given supported locale represents a right-to-left language.
    ///
    /// - Parameter locale: The supported locale.
    /// - Returns: `true` if the locale represents a right-to-left language; otherwise, `false`.
    static func isRTL(locale: SupportedLocale) -> Bool {
        switch locale {
            case .ar, .ar_AE, .ar_BH, .ar_DZ, .ar_EG, .ar_IQ, .ar_JO, .ar_KW, .ar_LB, .ar_LY, .ar_MA, .ar_OM, .ar_QA, .ar_SA, .ar_SD, .ar_SY, .ar_TN, .ar_YE:
                return true
            default:
                return false
        }
    }
    
    /// Returns the layout direction based on the locale.
    var layoutDirection: LayoutDirection {
        return Locale.isRTL(locale: SupportedLocale(rawValue: identifier.lowercased()) ?? .en)
        ? .rightToLeft
        : .leftToRight
    }
}
