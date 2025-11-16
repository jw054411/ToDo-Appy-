import SwiftUI

/// Priority levels for tasks
enum Priority: Int, Codable, CaseIterable {
    case none = 0
    case low = 1
    case medium = 2
    case high = 3
    case urgent = 4

    var displayName: String {
        switch self {
        case .none: return "None"
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        case .urgent: return "Urgent"
        }
    }

    var color: Color {
        switch self {
        case .none: return AppColors.textTertiary
        case .low: return AppColors.priorityLow
        case .medium: return AppColors.priorityMedium
        case .high: return AppColors.priorityHigh
        case .urgent: return AppColors.priorityUrgent
        }
    }

    var icon: String {
        switch self {
        case .none: return "minus.circle"
        case .low: return "exclamationmark"
        case .medium: return "exclamationmark.2"
        case .high: return "exclamationmark.3"
        case .urgent: return "exclamationmark.triangle.fill"
        }
    }
}

/// PriorityBadge - Visual indicator for task priority
struct PriorityBadge: View {
    // MARK: - Properties

    let priority: Priority
    let style: BadgeStyle

    // MARK: - Initializer

    init(_ priority: Priority, style: BadgeStyle = .compact) {
        self.priority = priority
        self.style = style
    }

    // MARK: - Body

    var body: some View {
        Group {
            switch style {
            case .compact:
                compactBadge
            case .full:
                fullBadge
            case .icon:
                iconOnly
            }
        }
    }

    // MARK: - Badge Variants

    private var compactBadge: some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: priority.icon)
                .font(.system(size: 10, weight: .bold))

            Text(priority.displayName)
                .font(AppTypography.caption)
                .fontWeight(.semibold)
        }
        .foregroundColor(priority.color)
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, AppSpacing.xs)
        .background(priority.color.opacity(0.15))
        .cornerRadius(AppCornerRadius.xs)
    }

    private var fullBadge: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: priority.icon)
                .font(.system(size: 14, weight: .bold))

            Text(priority.displayName)
                .font(AppTypography.subheadline)
                .fontWeight(.semibold)
        }
        .foregroundColor(.white)
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
        .background(priority.color)
        .cornerRadius(AppCornerRadius.sm)
    }

    private var iconOnly: some View {
        Image(systemName: priority.icon)
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(priority.color)
    }
}

// MARK: - Badge Style

extension PriorityBadge {
    enum BadgeStyle {
        case compact  // Small badge with icon and text
        case full     // Full-sized badge with solid background
        case icon     // Icon only, no background
    }
}

// MARK: - Preview

#Preview("PriorityBadge") {
    ScrollView {
        VStack(spacing: AppSpacing.xl) {
            Text("Priority Badges")
                .font(AppTypography.title1)
                .foregroundColor(AppColors.textPrimary)

            // Compact Style
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Text("Compact Style")
                    .font(AppTypography.title3)
                    .foregroundColor(AppColors.textPrimary)

                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    PriorityBadge(.none, style: .compact)
                    PriorityBadge(.low, style: .compact)
                    PriorityBadge(.medium, style: .compact)
                    PriorityBadge(.high, style: .compact)
                    PriorityBadge(.urgent, style: .compact)
                }
            }

            // Full Style
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Text("Full Style")
                    .font(AppTypography.title3)
                    .foregroundColor(AppColors.textPrimary)

                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    PriorityBadge(.none, style: .full)
                    PriorityBadge(.low, style: .full)
                    PriorityBadge(.medium, style: .full)
                    PriorityBadge(.high, style: .full)
                    PriorityBadge(.urgent, style: .full)
                }
            }

            // Icon Only
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Text("Icon Only")
                    .font(AppTypography.title3)
                    .foregroundColor(AppColors.textPrimary)

                HStack(spacing: AppSpacing.lg) {
                    PriorityBadge(.none, style: .icon)
                    PriorityBadge(.low, style: .icon)
                    PriorityBadge(.medium, style: .icon)
                    PriorityBadge(.high, style: .icon)
                    PriorityBadge(.urgent, style: .icon)
                }
            }
        }
        .padding(AppSpacing.screenPadding)
    }
    .background(AppColors.background)
}
