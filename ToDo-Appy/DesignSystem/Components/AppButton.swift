import SwiftUI

/// AppButton - Reusable button component with multiple styles
struct AppButton: View {
    // MARK: - Properties

    let title: String
    let icon: String?
    let style: ButtonStyle
    let action: () -> Void

    // MARK: - State

    @State private var isPressed = false

    // MARK: - Initializers

    init(
        _ title: String,
        icon: String? = nil,
        style: ButtonStyle = .primary,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }

    // MARK: - Body

    var body: some View {
        Button(action: {
            AppHaptics.medium()
            action()
        }) {
            HStack(spacing: AppSpacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }

                Text(title)
                    .font(AppTypography.bodyBold)
            }
            .foregroundColor(style.foregroundColor)
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.md)
            .frame(maxWidth: style.isFullWidth ? .infinity : nil)
            .background(style.backgroundColor)
            .cornerRadius(AppCornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.md)
                    .stroke(style.borderColor, lineWidth: style.borderWidth)
            )
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(AppAnimations.buttonPress, value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }
}

// MARK: - Button Style Enum

extension AppButton {
    enum ButtonStyle {
        case primary
        case secondary
        case destructive
        case ghost
        case outline

        var backgroundColor: Color {
            switch self {
            case .primary:
                return AppColors.accentBlue
            case .secondary:
                return AppColors.backgroundSecondary
            case .destructive:
                return AppColors.accentRed
            case .ghost:
                return Color.clear
            case .outline:
                return Color.clear
            }
        }

        var foregroundColor: Color {
            switch self {
            case .primary, .destructive:
                return .white
            case .secondary, .ghost, .outline:
                return AppColors.textPrimary
            }
        }

        var borderColor: Color {
            switch self {
            case .outline:
                return AppColors.separator
            default:
                return Color.clear
            }
        }

        var borderWidth: CGFloat {
            switch self {
            case .outline:
                return 1
            default:
                return 0
            }
        }

        var isFullWidth: Bool {
            switch self {
            case .primary, .destructive:
                return true
            default:
                return false
            }
        }
    }
}

// MARK: - Convenience Initializers

extension AppButton {
    /// Create a primary button
    static func primary(_ title: String, icon: String? = nil, action: @escaping () -> Void) -> AppButton {
        AppButton(title, icon: icon, style: .primary, action: action)
    }

    /// Create a secondary button
    static func secondary(_ title: String, icon: String? = nil, action: @escaping () -> Void) -> AppButton {
        AppButton(title, icon: icon, style: .secondary, action: action)
    }

    /// Create a destructive button
    static func destructive(_ title: String, icon: String? = nil, action: @escaping () -> Void) -> AppButton {
        AppButton(title, icon: icon, style: .destructive, action: action)
    }

    /// Create a ghost button
    static func ghost(_ title: String, icon: String? = nil, action: @escaping () -> Void) -> AppButton {
        AppButton(title, icon: icon, style: .ghost, action: action)
    }

    /// Create an outline button
    static func outline(_ title: String, icon: String? = nil, action: @escaping () -> Void) -> AppButton {
        AppButton(title, icon: icon, style: .outline, action: action)
    }
}

// MARK: - Preview

#Preview("AppButton Styles") {
    ScrollView {
        VStack(spacing: AppSpacing.lg) {
            Text("Button Styles")
                .font(AppTypography.title1)
                .foregroundColor(AppColors.textPrimary)

            VStack(spacing: AppSpacing.md) {
                AppButton.primary("Primary Button", icon: "plus.circle.fill") {
                    print("Primary tapped")
                }

                AppButton.secondary("Secondary Button", icon: "star.fill") {
                    print("Secondary tapped")
                }

                AppButton.destructive("Delete", icon: "trash.fill") {
                    print("Destructive tapped")
                }

                AppButton.ghost("Ghost Button") {
                    print("Ghost tapped")
                }

                AppButton.outline("Outline Button", icon: "arrow.right") {
                    print("Outline tapped")
                }
            }

            Divider()
                .background(AppColors.separator)
                .padding(.vertical, AppSpacing.md)

            VStack(spacing: AppSpacing.md) {
                Text("Without Icons")
                    .font(AppTypography.title3)
                    .foregroundColor(AppColors.textPrimary)

                AppButton.primary("Save") {
                    print("Save tapped")
                }

                AppButton.secondary("Cancel") {
                    print("Cancel tapped")
                }
            }
        }
        .padding(AppSpacing.screenPadding)
    }
    .background(AppColors.background)
}
