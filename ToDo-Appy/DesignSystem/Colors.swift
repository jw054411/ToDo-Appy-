import SwiftUI

/// AppColors - Dark-mode-only color palette for ToDo-Appy
/// Designed for OLED displays with pure black backgrounds and vibrant accents
struct AppColors {
    // MARK: - Backgrounds

    /// Pure black for OLED efficiency and aesthetic
    static let background = Color(hex: "#000000")!

    /// Card and section backgrounds
    static let backgroundSecondary = Color(hex: "#1C1C1E")!

    /// Input fields and tertiary surfaces
    static let backgroundTertiary = Color(hex: "#2C2C2E")!

    /// Elevated elements like floating buttons and modals
    static let backgroundElevated = Color(hex: "#3A3A3C")!

    // MARK: - Text

    /// Primary text color (white)
    static let textPrimary = Color.white

    /// Secondary text with reduced opacity
    static let textSecondary = Color.white.opacity(0.6)

    /// Tertiary text (hints, placeholders)
    static let textTertiary = Color.white.opacity(0.3)

    // MARK: - Accent Colors

    /// Primary blue accent
    static let accentBlue = Color(hex: "#0A84FF")!

    /// Purple accent for special features
    static let accentPurple = Color(hex: "#BF5AF2")!

    /// Pink accent for highlights
    static let accentPink = Color(hex: "#FF375F")!

    /// Orange accent for warnings
    static let accentOrange = Color(hex: "#FF9F0A")!

    /// Green accent for success states
    static let accentGreen = Color(hex: "#32D74B")!

    /// Yellow accent for attention
    static let accentYellow = Color(hex: "#FFD60A")!

    /// Red accent for errors and urgent items
    static let accentRed = Color(hex: "#FF453A")!

    // MARK: - Priority Colors

    /// Urgent priority (red)
    static let priorityUrgent = accentRed

    /// High priority (orange)
    static let priorityHigh = accentOrange

    /// Medium priority (yellow)
    static let priorityMedium = accentYellow

    /// Low priority (blue)
    static let priorityLow = accentBlue

    // MARK: - UI Elements

    /// Separator lines and borders
    static let separator = Color(hex: "#38383A")!

    /// Overlay for modals and sheets
    static let overlay = Color.black.opacity(0.4)

    // MARK: - Gradient Presets

    /// Vibrant gradient for headers and special UI elements
    static let gradientVibrant = LinearGradient(
        colors: [accentPurple, accentPink],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Subtle gradient for cards
    static let gradientSubtle = LinearGradient(
        colors: [backgroundSecondary, backgroundTertiary],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Success gradient (green)
    static let gradientSuccess = LinearGradient(
        colors: [accentGreen.opacity(0.3), accentGreen.opacity(0.1)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Warning gradient (orange/red)
    static let gradientWarning = LinearGradient(
        colors: [accentOrange.opacity(0.3), accentRed.opacity(0.1)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Info gradient (blue/purple)
    static let gradientInfo = LinearGradient(
        colors: [accentBlue.opacity(0.3), accentPurple.opacity(0.1)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Preview Helper

#Preview("Color Palette") {
    ScrollView {
        VStack(alignment: .leading, spacing: 24) {
            // Backgrounds
            ColorSection(title: "Backgrounds") {
                ColorSwatch(name: "Background", color: AppColors.background)
                ColorSwatch(name: "Secondary", color: AppColors.backgroundSecondary)
                ColorSwatch(name: "Tertiary", color: AppColors.backgroundTertiary)
                ColorSwatch(name: "Elevated", color: AppColors.backgroundElevated)
            }

            // Text
            ColorSection(title: "Text") {
                ColorSwatch(name: "Primary", color: AppColors.textPrimary)
                ColorSwatch(name: "Secondary", color: AppColors.textSecondary)
                ColorSwatch(name: "Tertiary", color: AppColors.textTertiary)
            }

            // Accents
            ColorSection(title: "Accents") {
                ColorSwatch(name: "Blue", color: AppColors.accentBlue)
                ColorSwatch(name: "Purple", color: AppColors.accentPurple)
                ColorSwatch(name: "Pink", color: AppColors.accentPink)
                ColorSwatch(name: "Orange", color: AppColors.accentOrange)
                ColorSwatch(name: "Green", color: AppColors.accentGreen)
                ColorSwatch(name: "Yellow", color: AppColors.accentYellow)
                ColorSwatch(name: "Red", color: AppColors.accentRed)
            }

            // Priorities
            ColorSection(title: "Priorities") {
                ColorSwatch(name: "Urgent", color: AppColors.priorityUrgent)
                ColorSwatch(name: "High", color: AppColors.priorityHigh)
                ColorSwatch(name: "Medium", color: AppColors.priorityMedium)
                ColorSwatch(name: "Low", color: AppColors.priorityLow)
            }
        }
        .padding()
    }
    .background(AppColors.background)
}

// MARK: - Preview Components

private struct ColorSection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)

            VStack(spacing: 8) {
                content
            }
        }
    }
}

private struct ColorSwatch: View {
    let name: String
    let color: Color

    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(width: 60, height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AppColors.separator, lineWidth: 1)
                )

            Text(name)
                .foregroundColor(AppColors.textPrimary)

            Spacer()

            Text(color.toHex() ?? "N/A")
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(AppColors.backgroundSecondary)
        .cornerRadius(8)
    }
}
