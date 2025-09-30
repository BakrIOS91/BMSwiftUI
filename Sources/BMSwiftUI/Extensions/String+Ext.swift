//
//  String+Ext.swift
//
//
//  Created by Bakr mohamed on 26/01/2024.
//

import SwiftUI

/// A set of helpful extensions for String manipulation and formatting.
public extension String {
    
    /// Converts the string into a `LocalizedStringKey` for localization purposes.
    var localizedStringKey: LocalizedStringKey {
        .init(self)
    }
    
    /// Formats the date represented by the string from one format to another.
    /// - Parameters:
    ///   - formateFrom: The original date format.
    ///   - formateTo: The desired date format.
    /// - Returns: A formatted date string.
    func formatDate(formateFrom: DateFormatter.Formats, formateTo: DateFormatter.Formats, locale: Locale = Locale.current) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formateFrom.rawValue
        
        // Set the appropriate time zone
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = locale
        
        if let date = dateFormatter.date(from: self) {
            dateFormatter.dateFormat = formateTo.rawValue
            return dateFormatter.string(from: date)
        }
        
        return self
    }
    
    /// Formats the date represented by the string and adds a specified duration.
    /// - Parameters:
    ///   - formateFrom: The original date format.
    ///   - formateTo: The desired date format.
    ///   - duration: The duration (in minutes) to add to the date.
    /// - Returns: A formatted date string with added duration.
    func formatDateWithDuration(formateFrom: DateFormatter.Formats, formateTo: DateFormatter.Formats, locale: Locale = Locale.current, duration: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formateFrom.rawValue
        
        // Set the appropriate time zone
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = locale
        
        if let date = dateFormatter.date(from: self) {
            let modifiedDate = Calendar.current.date(byAdding: .minute, value: duration, to: date)!
            dateFormatter.dateFormat = formateTo.rawValue
            let formattedDate = dateFormatter.string(from: modifiedDate)
            return formattedDate
        }
        
        return self
    }
    
    /// Capitalizes the first letter of the string.
    /// - Returns: A new string with the first letter capitalized.
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    /// Mutates the string to have its first letter capitalized.
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    /// Converts the string into a `URL`.
    /// - Returns: A URL object if the string represents a valid URL, otherwise `nil`.
    var toURL: URL? {
        return URL(string: self)
    }
    
    /// A static property representing the "Not Available" string.
    static var na: String {
        "N/A"
    }
    
    /// Replaces an empty string with the "Not Available" string.
    /// - Returns: The original string if not empty, otherwise "N/A".
    func replaceEmpty() -> String {
        if self.isEmpty {
            return "N/A"
        }
        
        return self
    }
    
    func toDouble() -> Double? {
        return Double(self)
    }
    
    func trimmed() -> String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    enum DigitLanguage {
        case english
        case arabic
    }

    func convertedDigits(_ target: DigitLanguage) -> String {
        let arabicToEnglish: [Character: Character] = [
            "٠": "0", "١": "1", "٢": "2", "٣": "3", "٤": "4",
            "٥": "5", "٦": "6", "٧": "7", "٨": "8", "٩": "9",
            "٫": "."
        ]
        
        let englishToArabic: [Character: Character] = [
            "0": "٠", "1": "١", "2": "٢", "3": "٣", "4": "٤",
            "5": "٥", "6": "٦", "7": "٧", "8": "٨", "9": "٩",
            ".": "٫"
        ]
        
        let map = target == .english ? arabicToEnglish : englishToArabic
        
        return self.map { map[$0] ?? $0 }.reduce("") { $0 + String($1) }
    }
    
    var permitOnlyEnglishCharacters: String {
        // Define allowed characters (English letters, numbers, and specific special characters)
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@.-_")
        
        // Filter the input string to include only allowed characters
        let filteredUnicodeScalars = self.unicodeScalars.filter { allowedCharacters.contains($0) }
        
        // Convert the filtered Unicode scalars back to a String
        return String(String.UnicodeScalarView(filteredUnicodeScalars))
    }
}
