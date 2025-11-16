import SwiftUI

/// AppSpacing - Consistent spacing system based on 4pt grid
struct AppSpacing {
    // MARK: - Spacing Scale (4pt increments)

    /// Extra small spacing (4pt) - tight spacing between related elements
    static let xs: CGFloat = 4

    /// Small spacing (8pt) - compact spacing
    static let sm: CGFloat = 8

    /// Medium spacing (12pt) - default spacing for most elements
    static let md: CGFloat = 12

    /// Large spacing (16pt) - comfortable spacing
    static let lg: CGFloat = 16

    /// Extra large spacing (24pt) - section spacing
    static let xl: CGFloat = 24

    /// 2X large spacing (32pt) - major section spacing
    static let xxl: CGFloat = 32

    /// 3X large spacing (48pt) - screen padding
    static let xxxl: CGFloat = 48

    /// 4X large spacing (64pt) - large screen sections
    static let xxxxl: CGFloat = 64

    // MARK: - Semantic Spacing

    /// Standard padding for screen edges
    static let screenPadding: CGFloat = lg

    /// Padding for card content
    static let cardPadding: CGFloat = lg

    /// Spacing between sections
    static let sectionSpacing: CGFloat = xl

    /// Spacing between list items
    static let listItemSpacing: CGFloat = md

    /// Minimum tap target size (44pt per Apple HIG)
    static let minTapTarget: CGFloat = 44
}

/// AppCornerRadius - Consistent corner radius values
struct AppCornerRadius {
    /// Extra small radius (4pt) - subtle rounding
    static let xs: CGFloat = 4

    /// Small radius (8pt) - buttons, badges
    static let sm: CGFloat = 8

    /// Medium radius (12pt) - cards, inputs
    static let md: CGFloat = 12

    /// Large radius (16pt) - modals, sheets
    static let lg: CGFloat = 16

    /// Extra large radius (24pt) - special elements
    static let xl: CGFloat = 24

    /// Circular (1000pt) - fully rounded
    static let circle: CGFloat = 1000
}

/// AppShadow - Consistent shadow definitions
struct AppShadow {
    // MARK: - Shadow Styles

    /// Subtle shadow for elevated elements
    static let subtle = ShadowStyle(
        color: Color.black.opacity(0.1),
        radius: 4,
        x: 0,
        y: 2
    )

    /// Medium shadow for cards
    static let medium = ShadowStyle(
        color: Color.black.opacity(0.15),
        radius: 8,
        x: 0,
        y: 4
    )

    /// Strong shadow for modals and floating elements
    static let strong = ShadowStyle(
        color: Color.black.opacity(0.25),
        radius: 16,
        x: 0,
        y: 8
    )

    /// Glow effect for interactive elements
    static let glow = ShadowStyle(
        color: AppColors.accentBlue.opacity(0.3),
        radius: 12,
        x: 0,
        y: 0
    )
}

/// Helper struct to define shadow properties
struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - View Extensions

extension View {
    /// Apply subtle shadow
    func shadowSubtle() -> some View {
        self.shadow(
            color: AppShadow.subtle.color,
            radius: AppShadow.subtle.radius,
            x: AppShadow.subtle.x,
            y: AppShadow.subtle.y
        )
    }

    /// Apply medium shadow
    func shadowMedium() -> some View {
        self.shadow(
            color: AppShadow.medium.color,
            radius: AppShadow.medium.radius,
            x: AppShadow.medium.x,
            y: AppShadow.medium.y
        )
    }

    /// Apply strong shadow
    func shadowStrong() -> some View {
        self.shadow(
            color: AppShadow.strong.color,
            radius: AppShadow.strong.radius,
            x: AppShadow.strong.x,
            y: AppShadow.strong.y
        )
    }

    /// Apply glow effect
    func shadowGlow() -> some View {
        self.shadow(
            color: AppShadow.glow.color,
            radius: AppShadow.glow.radius,
            x: AppShadow.glow.x,
            y: AppShadow.glow.y
        )
    }
}

// MARK: - Preview

#Preview("Spacing & Layout") {
    ScrollView {
        VStack(alignment: .leading, spacing: AppSpacing.xl) {
            // Spacing Scale
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Text("Spacing Scale")
                    .font(AppTypography.title2)
                    .foregroundColor(AppColors.textPrimary)

                SpacingDemo(label: "XS (4pt)", spacing: AppSpacing.xs)
                SpacingDemo(label: "SM (8pt)", spacing: AppSpacing.sm)
                SpacingDemo(label: "MD (12pt)", spacing: AppSpacing.md)
                SpacingDemo(label: "LG (16pt)", spacing: AppSpacing.lg)
                SpacingDemo(label: "XL (24pt)", spacing: AppSpacing.xl)
                SpacingDemo(label: "XXL (32pt)", spacing: AppSpacing.xxl)
            }

            // Corner Radius
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Text("Corner Radius")
                    .font(AppTypography.title2)
                    .foregroundColor(AppColors.textPrimary)

                HStack(spacing: AppSpacing.md) {
                    CornerRadiusDemo(label: "XS", radius: AppCornerRadius.xs)
                    CornerRadiusDemo(label: "SM", radius: AppCornerRadius.sm)
                    CornerRadiusDemo(label: "MD", radius: AppCornerRadius.md)
                    CornerRadiusDemo(label: "LG", radius: AppCornerRadius.lg)
                }

                HStack(spacing: AppSpacing.md) {
                    CornerRadiusDemo(label: "XL", radius: AppCornerRadius.xl)
                    CornerRadiusDemo(label: "Circle", radius: AppCornerRadius.circle)
                }
            }

            // Shadows
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Text("Shadows")
                    .font(AppTypography.title2)
                    .foregroundColor(AppColors.textPrimary)

                HStack(spacing: AppSpacing.lg) {
                    ShadowDemo(label: "Subtle")
                        .shadowSubtle()

                    ShadowDemo(label: "Medium")
                        .shadowMedium()

                    ShadowDemo(label: "Strong")
                        .shadowStrong()
                }
            }
        }
        .padding(AppSpacing.screenPadding)
    }
    .background(AppColors.background)
}

// MARK: - Preview Components

private struct SpacingDemo: View {
    let label: String
    let spacing: CGFloat

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Text(label)
                .font(AppTypography.caption)
                .foregroundColor(AppColors.textSecondary)
                .frame(width: 80, alignment: .leading)

            Rectangle()
                .fill(AppColors.accentBlue)
                .frame(width: spacing, height: 20)

            Text("\(Int(spacing))pt")
                .font(AppTypography.monoSmall)
                .foregroundColor(AppColors.textTertiary)
        }
    }
}

private struct CornerRadiusDemo: View {
    let label: String
    let radius: CGFloat

    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            RoundedRectangle(cornerRadius: radius)
                .fill(AppColors.accentPurple)
                .frame(width: 60, height: 60)

            Text(label)
                .font(AppTypography.caption)
                .foregroundColor(AppColors.textSecondary)
        }
    }
}

private struct ShadowDemo: View {
    let label: String

    var body: some View {
        VStack {
            Text(label)
                .font(AppTypography.caption)
                .foregroundColor(AppColors.textPrimary)
        }
        .frame(width: 80, height: 60)
        .background(AppColors.backgroundSecondary)
        .cornerRadius(AppCornerRadius.md)
    }
}
