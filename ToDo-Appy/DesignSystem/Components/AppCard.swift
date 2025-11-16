import SwiftUI

/// AppCard - Elevated card container for grouping content
struct AppCard<Content: View>: View {
    // MARK: - Properties

    let content: Content
    let padding: CGFloat
    let backgroundColor: Color
    let hasShadow: Bool

    // MARK: - Initializer

    init(
        padding: CGFloat = AppSpacing.cardPadding,
        backgroundColor: Color = AppColors.backgroundSecondary,
        hasShadow: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.backgroundColor = backgroundColor
        self.hasShadow = hasShadow
        self.content = content()
    }

    // MARK: - Body

    var body: some View {
        content
            .padding(padding)
            .background(backgroundColor)
            .cornerRadius(AppCornerRadius.md)
            .modifier(CardShadowModifier(hasShadow: hasShadow))
    }
}

// MARK: - Card Shadow Modifier

private struct CardShadowModifier: ViewModifier {
    let hasShadow: Bool

    func body(content: Content) -> some View {
        if hasShadow {
            content.shadowMedium()
        } else {
            content
        }
    }
}

// MARK: - Card Variants

extension AppCard {
    /// Create a card with subtle shadow
    static func elevated(@ViewBuilder content: () -> Content) -> AppCard {
        AppCard(hasShadow: true, content: content)
    }

    /// Create a compact card with less padding
    static func compact(@ViewBuilder content: () -> Content) -> AppCard {
        AppCard(padding: AppSpacing.md, content: content)
    }

    /// Create a card with custom background color
    static func colored(
        _ backgroundColor: Color,
        @ViewBuilder content: () -> Content
    ) -> AppCard {
        AppCard(backgroundColor: backgroundColor, content: content)
    }
}

// MARK: - Preview

#Preview("AppCard") {
    ScrollView {
        VStack(spacing: AppSpacing.xl) {
            Text("Card Components")
                .font(AppTypography.title1)
                .foregroundColor(AppColors.textPrimary)

            VStack(spacing: AppSpacing.lg) {
                // Standard Card
                AppCard {
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("Standard Card")
                            .font(AppTypography.title3)
                            .foregroundColor(AppColors.textPrimary)

                        Text("This is a standard card with default padding and no shadow.")
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }

                // Elevated Card
                AppCard.elevated {
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("Elevated Card")
                            .font(AppTypography.title3)
                            .foregroundColor(AppColors.textPrimary)

                        Text("This card has a subtle shadow for elevation.")
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }

                // Compact Card
                AppCard.compact {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(AppColors.accentYellow)

                        Text("Compact Card")
                            .font(AppTypography.bodyBold)
                            .foregroundColor(AppColors.textPrimary)
                    }
                }

                // Colored Card
                AppCard.colored(AppColors.backgroundTertiary) {
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("Colored Card")
                            .font(AppTypography.title3)
                            .foregroundColor(AppColors.textPrimary)

                        Text("This card uses a custom background color.")
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }

                // Card with Icon and Action
                AppCard {
                    HStack {
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text("Interactive Card")
                                .font(AppTypography.title3)
                                .foregroundColor(AppColors.textPrimary)

                            Text("Tap to perform action")
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppColors.textTertiary)
                    }
                }
                .onTapGesture {
                    AppHaptics.light()
                    print("Card tapped")
                }
            }
        }
        .padding(AppSpacing.screenPadding)
    }
    .background(AppColors.background)
}
