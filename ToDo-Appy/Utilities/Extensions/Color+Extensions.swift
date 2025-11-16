import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension Color {
    /// Initialize a Color from a hex string
    /// - Parameter hex: Hex string (with or without #, e.g., "#FF5733" or "FF5733")
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }

    /// Convert this Color to a hex string
    /// - Returns: Hex string with # prefix (e.g., "#FF5733")
    func toHex() -> String {
        #if canImport(UIKit)
        let components = UIColor(self).cgColor.components
        let r = Float(components?[0] ?? 0)
        let g = Float(components?[1] ?? 0)
        let b = Float(components?[2] ?? 0)
        #elseif canImport(AppKit)
        let nsColor = NSColor(self)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        nsColor.getRed(&r, green: &g, blue: &b, alpha: nil)
        #endif

        return String(format: "#%02lX%02lX%02lX",
                     lroundf(Float(r) * 255),
                     lroundf(Float(g) * 255),
                     lroundf(Float(b) * 255))
    }
}
