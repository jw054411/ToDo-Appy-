import SwiftUI

/// CheckboxView - Animated checkbox with smooth transitions
struct CheckboxView: View {
    // MARK: - Properties

    @Binding var isChecked: Bool
    let style: CheckboxStyle
    let color: Color
    let onToggle: (() -> Void)?

    // MARK: - State

    @State private var scale: CGFloat = 1.0

    // MARK: - Initializer

    init(
        isChecked: Binding<Bool>,
        style: CheckboxStyle = .circle,
        color: Color = AppColors.accentGreen,
        onToggle: (() -> Void)? = nil
    ) {
        self._isChecked = isChecked
        self.style = style
        self.color = color
        self.onToggle = onToggle
    }

    // MARK: - Body

    var body: some View {
        Button(action: {
            withAnimation(AppAnimations.checkboxTap) {
                isChecked.toggle()
                scale = 1.2
            }

            AppHaptics.light()
            onToggle?()

            withAnimation(AppAnimations.checkboxTap.delay(0.1)) {
                scale = 1.0
            }
        }) {
            ZStack {
                // Unchecked state
                if !isChecked {
                    Image(systemName: style.uncheckedIcon)
                        .font(.system(size: style.iconSize, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                        .transition(.scale.combined(with: .opacity))
                }

                // Checked state
                if isChecked {
                    Image(systemName: style.checkedIcon)
                        .font(.system(size: style.iconSize, weight: .bold))
                        .foregroundColor(color)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .scaleEffect(scale)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Checkbox Style

extension CheckboxView {
    enum CheckboxStyle {
        case circle
        case square
        case checkmark

        var iconSize: CGFloat {
            switch self {
            case .circle: return 28
            case .square: return 24
            case .checkmark: return 22
            }
        }

        var uncheckedIcon: String {
            switch self {
            case .circle: return "circle"
            case .square: return "square"
            case .checkmark: return "circle"
            }
        }

        var checkedIcon: String {
            switch self {
            case .circle: return "checkmark.circle.fill"
            case .square: return "checkmark.square.fill"
            case .checkmark: return "checkmark.circle.fill"
            }
        }
    }
}

// MARK: - Task Checkbox with Strikethrough

struct TaskCheckbox: View {
    // MARK: - Properties

    @Binding var isChecked: Bool
    let title: String
    let color: Color

    // MARK: - Body

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            CheckboxView(
                isChecked: $isChecked,
                color: color
            )

            Text(title)
                .font(AppTypography.body)
                .foregroundColor(isChecked ? AppColors.textTertiary : AppColors.textPrimary)
                .strikethrough(isChecked, color: AppColors.textTertiary)
                .animation(AppAnimations.fade, value: isChecked)
        }
    }
}

// MARK: - Preview

#Preview("CheckboxView") {
    ScrollView {
        VStack(spacing: AppSpacing.xl) {
            Text("Checkboxes")
                .font(AppTypography.title1)
                .foregroundColor(AppColors.textPrimary)

            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                // Circle Style
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    Text("Circle Style")
                        .font(AppTypography.title3)
                        .foregroundColor(AppColors.textPrimary)

                    HStack(spacing: AppSpacing.lg) {
                        VStack(spacing: AppSpacing.sm) {
                            CheckboxView(
                                isChecked: .constant(false),
                                style: .circle
                            )
                            Text("Unchecked")
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }

                        VStack(spacing: AppSpacing.sm) {
                            CheckboxView(
                                isChecked: .constant(true),
                                style: .circle
                            )
                            Text("Checked")
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                }

                // Square Style
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    Text("Square Style")
                        .font(AppTypography.title3)
                        .foregroundColor(AppColors.textPrimary)

                    HStack(spacing: AppSpacing.lg) {
                        CheckboxView(
                            isChecked: .constant(false),
                            style: .square
                        )

                        CheckboxView(
                            isChecked: .constant(true),
                            style: .square
                        )
                    }
                }

                // Different Colors
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    Text("Colors")
                        .font(AppTypography.title3)
                        .foregroundColor(AppColors.textPrimary)

                    HStack(spacing: AppSpacing.lg) {
                        CheckboxView(
                            isChecked: .constant(true),
                            color: AppColors.accentGreen
                        )

                        CheckboxView(
                            isChecked: .constant(true),
                            color: AppColors.accentBlue
                        )

                        CheckboxView(
                            isChecked: .constant(true),
                            color: AppColors.accentPurple
                        )

                        CheckboxView(
                            isChecked: .constant(true),
                            color: AppColors.accentOrange
                        )
                    }
                }

                // Interactive Examples
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    Text("Interactive (Tap to Toggle)")
                        .font(AppTypography.title3)
                        .foregroundColor(AppColors.textPrimary)

                    AppCard {
                        VStack(alignment: .leading, spacing: AppSpacing.md) {
                            TaskCheckbox(
                                isChecked: .constant(false),
                                title: "Buy groceries",
                                color: AppColors.accentGreen
                            )

                            TaskCheckbox(
                                isChecked: .constant(true),
                                title: "Finish project report",
                                color: AppColors.accentGreen
                            )

                            TaskCheckbox(
                                isChecked: .constant(false),
                                title: "Call dentist for appointment",
                                color: AppColors.accentGreen
                            )
                        }
                    }
                }

                // Sizes Demo
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    Text("In Task List")
                        .font(AppTypography.title3)
                        .foregroundColor(AppColors.textPrimary)

                    VStack(spacing: 0) {
                        ForEach(0..<3) { index in
                            AppCard(padding: AppSpacing.md) {
                                HStack(spacing: AppSpacing.md) {
                                    CheckboxView(
                                        isChecked: .constant(index == 1),
                                        color: AppColors.accentGreen
                                    )

                                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                        Text("Task \(index + 1)")
                                            .font(AppTypography.bodyBold)
                                            .foregroundColor(index == 1 ? AppColors.textTertiary : AppColors.textPrimary)
                                            .strikethrough(index == 1)

                                        HStack(spacing: AppSpacing.sm) {
                                            DateBadge(date: Date())
                                            PriorityBadge(.high, style: .compact)
                                        }
                                    }

                                    Spacer()
                                }
                            }

                            if index < 2 {
                                Divider()
                                    .background(AppColors.separator)
                            }
                        }
                    }
                    .background(AppColors.backgroundSecondary)
                    .cornerRadius(AppCornerRadius.md)
                }
            }
        }
        .padding(AppSpacing.screenPadding)
    }
    .background(AppColors.background)
}
