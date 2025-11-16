//
//  Color+Extensions.swift
//  ToDo-Appy
//
//  Created by Agent 1: Foundation & Setup Specialist
//  Color utilities and hex conversion for design system
//

import SwiftUI

extension Color {
    /// Initialize Color from hex string
    /// - Parameter hex: Hex color string (e.g., "#FF5733" or "FF5733")
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    /// Convert Color to hex string
    /// - Parameter includeAlpha: Whether to include alpha channel
    /// - Returns: Hex string (e.g., "#FF5733")
    func toHex(includeAlpha: Bool = false) -> String {
        guard let components = UIColor(self).cgColor.components else {
            return "#000000"
        }

        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        let a = Float(components.count >= 4 ? components[3] : 1.0)

        if includeAlpha {
            return String(format: "#%02lX%02lX%02lX%02lX",
                         lroundf(a * 255),
                         lroundf(r * 255),
                         lroundf(g * 255),
                         lroundf(b * 255))
        } else {
            return String(format: "#%02lX%02lX%02lX",
                         lroundf(r * 255),
                         lroundf(g * 255),
                         lroundf(b * 255))
        }
    }

    /// Lighten the color by a percentage
    /// - Parameter percentage: Amount to lighten (0.0 - 1.0)
    /// - Returns: Lightened color
    func lighter(by percentage: Double = 0.2) -> Color {
        return self.adjust(by: abs(percentage))
    }

    /// Darken the color by a percentage
    /// - Parameter percentage: Amount to darken (0.0 - 1.0)
    /// - Returns: Darkened color
    func darker(by percentage: Double = 0.2) -> Color {
        return self.adjust(by: -abs(percentage))
    }

    /// Adjust color brightness
    private func adjust(by percentage: Double) -> Color {
        let uiColor = UIColor(self)
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0

        guard uiColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a) else {
            return self
        }

        let newBrightness = max(min(b + CGFloat(percentage), 1.0), 0.0)
        return Color(hue: Double(h), saturation: Double(s), brightness: Double(newBrightness), opacity: Double(a))
    }

    /// Get complementary color
    var complementary: Color {
        let uiColor = UIColor(self)
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0

        guard uiColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a) else {
            return self
        }

        let newHue = fmod(h + 0.5, 1.0)
        return Color(hue: Double(newHue), saturation: Double(s), brightness: Double(b), opacity: Double(a))
    }
}

// MARK: - Predefined App Colors (Foundation for Agent 4 Design System)

extension Color {
    /// App-specific color palette
    /// Agent 4 will expand this in the DesignSystem/Colors.swift file

    static let appBackground = Color(hex: "#000000")
    static let appSurface = Color(hex: "#1C1C1E")
    static let appSurfaceSecondary = Color(hex: "#2C2C2E")

    static let appPrimary = Color(hex: "#007AFF")
    static let appSecondary = Color(hex: "#5856D6")

    static let appSuccess = Color(hex: "#34C759")
    static let appWarning = Color(hex: "#FF9500")
    static let appError = Color(hex: "#FF3B30")

    static let appTextPrimary = Color(hex: "#FFFFFF")
    static let appTextSecondary = Color(hex: "#98989D")
    static let appTextTertiary = Color(hex: "#48484A")
}
