//
//  String+Extensions.swift
//  ToDo-Appy
//
//  Created by Agent 1: Foundation & Setup Specialist
//  String utilities for task management and validation
//

import Foundation

extension String {
    /// Check if string is empty or contains only whitespace
    var isBlank: Bool {
        return self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Trim whitespace and newlines
    var trimmed: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Check if string is a valid email
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }

    /// Truncate string to specified length with ellipsis
    /// - Parameters:
    ///   - length: Maximum length
    ///   - trailing: Trailing string (default "...")
    /// - Returns: Truncated string
    func truncated(to length: Int, trailing: String = "...") -> String {
        if self.count > length {
            return String(self.prefix(length)) + trailing
        }
        return self
    }

    /// Convert string to URL-safe slug
    var slugified: String {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-"))
        return self.lowercased()
            .components(separatedBy: allowed.inverted)
            .filter { !$0.isEmpty }
            .joined(separator: "-")
    }

    /// Extract hashtags from string (for future tag parsing)
    var hashtags: [String] {
        let pattern = "#(\\w+)"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return []
        }

        let matches = regex.matches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count))
        return matches.compactMap { match in
            guard let range = Range(match.range(at: 1), in: self) else { return nil }
            return String(self[range])
        }
    }

    /// Parse natural language date from string (basic implementation)
    /// Agent 2 or Agent 4 can expand this for advanced NLP parsing
    func parseDate() -> Date? {
        let lowercased = self.lowercased().trimmed

        switch lowercased {
        case "today":
            return Date()
        case "tomorrow":
            return Calendar.current.date(byAdding: .day, value: 1, to: Date())
        case "yesterday":
            return Calendar.current.date(byAdding: .day, value: -1, to: Date())
        default:
            // Try standard date parsing
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.date(from: self)
        }
    }

    /// Convert to title case
    var titleCased: String {
        return self.capitalized
    }

    /// Count words in string
    var wordCount: Int {
        let words = self.components(separatedBy: .whitespacesAndNewlines)
        return words.filter { !$0.isEmpty }.count
    }

    /// Check if string contains substring (case-insensitive)
    /// - Parameter substring: Substring to search for
    /// - Returns: True if contains
    func containsIgnoringCase(_ substring: String) -> Bool {
        return self.range(of: substring, options: .caseInsensitive) != nil
    }

    /// Extract priority from string (e.g., "!!" -> Priority.medium)
    var extractedPriority: Priority? {
        let exclamationCount = self.filter { $0 == "!" }.count
        switch exclamationCount {
        case 1:
            return .low
        case 2:
            return .medium
        case 3:
            return .high
        case 4...:
            return .urgent
        default:
            return nil
        }
    }

    /// Remove priority markers from string
    var withoutPriorityMarkers: String {
        return self.replacingOccurrences(of: "!", with: "").trimmed
    }
}

// MARK: - UUID Generation

extension String {
    /// Generate a UUID string
    static func uuid() -> String {
        return UUID().uuidString
    }
}
