import SwiftUI

/// EmptyStateView - Placeholder for empty lists and states
struct EmptyStateView: View {
    // MARK: - Properties

    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?

    // MARK: - Initializer

    init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            Spacer()

            VStack(spacing: AppSpacing.lg) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 64, weight: .light))
                    .foregroundColor(AppColors.textTertiary)

                // Title and Message
                VStack(spacing: AppSpacing.sm) {
                    Text(title)
                        .font(AppTypography.title2)
                        .foregroundColor(AppColors.textPrimary)
                        .multilineTextAlignment(.center)

                    Text(message)
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }

                // Action Button
                if let actionTitle = actionTitle, let action = action {
                    AppButton.primary(actionTitle, icon: "plus.circle.fill", action: action)
                        .padding(.top, AppSpacing.md)
                }
            }
            .padding(.horizontal, AppSpacing.xxl)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preset Empty States

extension EmptyStateView {
    /// Empty state for no tasks
    static func noTasks(action: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            icon: "checkmark.circle",
            title: "No Tasks Yet",
            message: "Create your first task to get started on your journey to productivity.",
            actionTitle: "Create Task",
            action: action
        )
    }

    /// Empty state for no results
    static var noResults: EmptyStateView {
        EmptyStateView(
            icon: "magnifyingglass",
            title: "No Results Found",
            message: "We couldn't find any tasks matching your search. Try different keywords."
        )
    }

    /// Empty state for no tasks today
    static var noTasksToday: EmptyStateView {
        EmptyStateView(
            icon: "sun.max",
            title: "All Clear Today",
            message: "You don't have any tasks scheduled for today. Enjoy your free time!"
        )
    }

    /// Empty state for no completed tasks
    static var noCompletedTasks: EmptyStateView {
        EmptyStateView(
            icon: "checkmark.circle.fill",
            title: "No Completed Tasks",
            message: "Complete some tasks to see them here. You've got this!"
        )
    }

    /// Empty state for no projects
    static func noProjects(action: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            icon: "folder",
            title: "No Projects",
            message: "Create a project to organize your tasks better.",
            actionTitle: "Create Project",
            action: action
        )
    }

    /// Empty state for no tags
    static func noTags(action: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            icon: "tag",
            title: "No Tags",
            message: "Create tags to categorize and filter your tasks.",
            actionTitle: "Create Tag",
            action: action
        )
    }

    /// Empty state for no upcoming tasks
    static var noUpcomingTasks: EmptyStateView {
        EmptyStateView(
            icon: "calendar",
            title: "No Upcoming Tasks",
            message: "Your schedule is clear for the next week. Time to plan ahead!"
        )
    }
}

// MARK: - Preview

#Preview("EmptyStateView") {
    ScrollView {
        VStack(spacing: AppSpacing.xxxl) {
            // No Tasks
            EmptyStateView.noTasks {
                print("Create task tapped")
            }
            .frame(height: 300)
            .background(AppColors.backgroundSecondary)
            .cornerRadius(AppCornerRadius.lg)

            // No Results
            EmptyStateView.noResults
                .frame(height: 300)
                .background(AppColors.backgroundSecondary)
                .cornerRadius(AppCornerRadius.lg)

            // No Tasks Today
            EmptyStateView.noTasksToday
                .frame(height: 300)
                .background(AppColors.backgroundSecondary)
                .cornerRadius(AppCornerRadius.lg)

            // Custom Empty State
            EmptyStateView(
                icon: "star.fill",
                title: "Custom Empty State",
                message: "This is a custom empty state with a custom icon and message.",
                actionTitle: "Take Action",
                action: {
                    print("Action tapped")
                }
            )
            .frame(height: 300)
            .background(AppColors.backgroundSecondary)
            .cornerRadius(AppCornerRadius.lg)
        }
        .padding(AppSpacing.screenPadding)
    }
    .background(AppColors.background)
}
