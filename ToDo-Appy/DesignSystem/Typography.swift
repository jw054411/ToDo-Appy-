import SwiftUI

/// AppTypography - Consistent typography system for ToDo-Appy
/// Follows iOS Human Interface Guidelines with custom weights and sizes
struct AppTypography {
    // MARK: - Headings

    /// Large title for main screens (34pt, bold)
    static let largeTitle = Font.system(size: 34, weight: .bold)

    /// Title 1 for section headers (28pt, bold)
    static let title1 = Font.system(size: 28, weight: .bold)

    /// Title 2 for subsections (22pt, bold)
    static let title2 = Font.system(size: 22, weight: .bold)

    /// Title 3 for cards and components (20pt, semibold)
    static let title3 = Font.system(size: 20, weight: .semibold)

    // MARK: - Body

    /// Standard body text (17pt, regular)
    static let body = Font.system(size: 17, weight: .regular)

    /// Bold body text for emphasis (17pt, semibold)
    static let bodyBold = Font.system(size: 17, weight: .semibold)

    /// Callout text for secondary content (16pt, regular)
    static let callout = Font.system(size: 16)

    // MARK: - Small Text

    /// Subheadline for metadata (15pt, regular)
    static let subheadline = Font.system(size: 15)

    /// Footnote for annotations (13pt, regular)
    static let footnote = Font.system(size: 13)

    /// Caption for labels and hints (12pt, regular)
    static let caption = Font.system(size: 12)

    /// Extra small caption (10pt, regular)
    static let caption2 = Font.system(size: 10)

    // MARK: - Special Purpose

    /// Monospaced font for dates, times, and code (15pt, monospaced)
    static let mono = Font.system(size: 15, design: .monospaced)

    /// Small monospaced for compact displays (13pt, monospaced)
    static let monoSmall = Font.system(size: 13, design: .monospaced)

    /// Rounded font for friendly UI elements (17pt, rounded)
    static let rounded = Font.system(size: 17, design: .rounded)

    /// Large rounded for buttons (20pt, rounded, semibold)
    static let roundedLarge = Font.system(size: 20, weight: .semibold, design: .rounded)
}

// MARK: - Text Style Extension

extension Text {
    /// Apply large title style
    func largeTitle() -> Text {
        self.font(AppTypography.largeTitle)
    }

    /// Apply title 1 style
    func title1() -> Text {
        self.font(AppTypography.title1)
    }

    /// Apply title 2 style
    func title2() -> Text {
        self.font(AppTypography.title2)
    }

    /// Apply title 3 style
    func title3() -> Text {
        self.font(AppTypography.title3)
    }

    /// Apply body style
    func body() -> Text {
        self.font(AppTypography.body)
    }

    /// Apply bold body style
    func bodyBold() -> Text {
        self.font(AppTypography.bodyBold)
    }

    /// Apply callout style
    func callout() -> Text {
        self.font(AppTypography.callout)
    }

    /// Apply subheadline style
    func subheadline() -> Text {
        self.font(AppTypography.subheadline)
    }

    /// Apply footnote style
    func footnote() -> Text {
        self.font(AppTypography.footnote)
    }

    /// Apply caption style
    func caption() -> Text {
        self.font(AppTypography.caption)
    }

    /// Apply caption2 style
    func caption2() -> Text {
        self.font(AppTypography.caption2)
    }

    /// Apply monospaced style
    func mono() -> Text {
        self.font(AppTypography.mono)
    }

    /// Apply small monospaced style
    func monoSmall() -> Text {
        self.font(AppTypography.monoSmall)
    }

    /// Apply rounded style
    func rounded() -> Text {
        self.font(AppTypography.rounded)
    }

    /// Apply large rounded style
    func roundedLarge() -> Text {
        self.font(AppTypography.roundedLarge)
    }
}

// MARK: - Preview

#Preview("Typography Scale") {
    ScrollView {
        VStack(alignment: .leading, spacing: 24) {
            TypographySection(title: "Headings") {
                TypographySample(label: "Large Title", font: AppTypography.largeTitle)
                TypographySample(label: "Title 1", font: AppTypography.title1)
                TypographySample(label: "Title 2", font: AppTypography.title2)
                TypographySample(label: "Title 3", font: AppTypography.title3)
            }

            TypographySection(title: "Body") {
                TypographySample(label: "Body", font: AppTypography.body)
                TypographySample(label: "Body Bold", font: AppTypography.bodyBold)
                TypographySample(label: "Callout", font: AppTypography.callout)
            }

            TypographySection(title: "Small Text") {
                TypographySample(label: "Subheadline", font: AppTypography.subheadline)
                TypographySample(label: "Footnote", font: AppTypography.footnote)
                TypographySample(label: "Caption", font: AppTypography.caption)
                TypographySample(label: "Caption 2", font: AppTypography.caption2)
            }

            TypographySection(title: "Special") {
                TypographySample(label: "Mono", font: AppTypography.mono)
                TypographySample(label: "Mono Small", font: AppTypography.monoSmall)
                TypographySample(label: "Rounded", font: AppTypography.rounded)
                TypographySample(label: "Rounded Large", font: AppTypography.roundedLarge)
            }
        }
        .padding()
    }
    .background(AppColors.background)
}

// MARK: - Preview Components

private struct TypographySection<Content: View>: View {
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

            VStack(alignment: .leading, spacing: 8) {
                content
            }
        }
    }
}

private struct TypographySample: View {
    let label: String
    let font: Font

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(AppColors.textSecondary)

            Text("The quick brown fox jumps")
                .font(font)
                .foregroundColor(AppColors.textPrimary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.backgroundSecondary)
        .cornerRadius(8)
    }
}
