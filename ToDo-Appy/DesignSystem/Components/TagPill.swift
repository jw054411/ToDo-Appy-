import SwiftUI

/// TagPill - Rounded pill for displaying tags
struct TagPill: View {
    // MARK: - Properties

    let name: String
    let color: Color
    let style: PillStyle
    let onRemove: (() -> Void)?

    // MARK: - Initializers

    init(
        _ name: String,
        color: Color = AppColors.accentBlue,
        style: PillStyle = .standard,
        onRemove: (() -> Void)? = nil
    ) {
        self.name = name
        self.color = color
        self.style = style
        self.onRemove = onRemove
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            if style == .withDot {
                Circle()
                    .fill(color)
                    .frame(width: 6, height: 6)
            }

            Text(name)
                .font(style.font)
                .fontWeight(.medium)
                .lineLimit(1)

            if let onRemove = onRemove {
                Button(action: {
                    AppHaptics.light()
                    onRemove()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(style.foregroundColor(for: color))
                }
            }
        }
        .foregroundColor(style.foregroundColor(for: color))
        .padding(.horizontal, style.horizontalPadding)
        .padding(.vertical, style.verticalPadding)
        .background(style.backgroundColor(for: color))
        .cornerRadius(style.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: style.cornerRadius)
                .stroke(style.borderColor(for: color), lineWidth: style.borderWidth)
        )
    }
}

// MARK: - Pill Style

extension TagPill {
    enum PillStyle {
        case standard   // Solid background
        case outline    // Border only
        case withDot    // Dot indicator + outline
        case compact    // Smaller size

        var font: Font {
            switch self {
            case .compact:
                return AppTypography.caption2
            default:
                return AppTypography.caption
            }
        }

        var horizontalPadding: CGFloat {
            switch self {
            case .compact:
                return AppSpacing.xs
            default:
                return AppSpacing.sm
            }
        }

        var verticalPadding: CGFloat {
            AppSpacing.xs
        }

        var cornerRadius: CGFloat {
            AppCornerRadius.circle
        }

        var borderWidth: CGFloat {
            switch self {
            case .outline, .withDot:
                return 1
            default:
                return 0
            }
        }

        func backgroundColor(for color: Color) -> Color {
            switch self {
            case .standard:
                return color.opacity(0.2)
            case .outline, .withDot:
                return Color.clear
            case .compact:
                return color.opacity(0.15)
            }
        }

        func foregroundColor(for color: Color) -> Color {
            color
        }

        func borderColor(for color: Color) -> Color {
            switch self {
            case .outline, .withDot:
                return color.opacity(0.5)
            default:
                return Color.clear
            }
        }
    }
}

// MARK: - Preview

#Preview("TagPill") {
    ScrollView {
        VStack(spacing: AppSpacing.xl) {
            Text("Tag Pills")
                .font(AppTypography.title1)
                .foregroundColor(AppColors.textPrimary)

            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                // Standard Style
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    Text("Standard Style")
                        .font(AppTypography.title3)
                        .foregroundColor(AppColors.textPrimary)

                    FlowLayout(spacing: AppSpacing.sm) {
                        TagPill("Work", color: AppColors.accentBlue)
                        TagPill("Personal", color: AppColors.accentPurple)
                        TagPill("Urgent", color: AppColors.accentRed)
                        TagPill("Ideas", color: AppColors.accentYellow)
                    }
                }

                // Outline Style
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    Text("Outline Style")
                        .font(AppTypography.title3)
                        .foregroundColor(AppColors.textPrimary)

                    FlowLayout(spacing: AppSpacing.sm) {
                        TagPill("Design", color: AppColors.accentPink, style: .outline)
                        TagPill("Development", color: AppColors.accentGreen, style: .outline)
                        TagPill("Marketing", color: AppColors.accentOrange, style: .outline)
                    }
                }

                // With Dot
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    Text("With Dot Indicator")
                        .font(AppTypography.title3)
                        .foregroundColor(AppColors.textPrimary)

                    FlowLayout(spacing: AppSpacing.sm) {
                        TagPill("Active", color: AppColors.accentGreen, style: .withDot)
                        TagPill("Pending", color: AppColors.accentYellow, style: .withDot)
                        TagPill("Done", color: AppColors.accentBlue, style: .withDot)
                    }
                }

                // Compact Style
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    Text("Compact Style")
                        .font(AppTypography.title3)
                        .foregroundColor(AppColors.textPrimary)

                    FlowLayout(spacing: AppSpacing.xs) {
                        TagPill("Small", color: AppColors.accentBlue, style: .compact)
                        TagPill("Tiny", color: AppColors.accentPurple, style: .compact)
                        TagPill("Mini", color: AppColors.accentPink, style: .compact)
                    }
                }

                // With Remove Button
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    Text("Removable Tags")
                        .font(AppTypography.title3)
                        .foregroundColor(AppColors.textPrimary)

                    FlowLayout(spacing: AppSpacing.sm) {
                        TagPill("Removable", color: AppColors.accentBlue) {
                            print("Removed")
                        }
                        TagPill("Click X", color: AppColors.accentPurple) {
                            print("Removed")
                        }
                    }
                }
            }
        }
        .padding(AppSpacing.screenPadding)
    }
    .background(AppColors.background)
}

// MARK: - Flow Layout Helper

/// Simple flow layout for tags
private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowLayoutResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowLayoutResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: result.positions[index], proposal: .unspecified)
        }
    }

    struct FlowLayoutResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: currentX, y: currentY))
                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }

            self.size = CGSize(
                width: maxWidth,
                height: currentY + lineHeight
            )
        }
    }
}
