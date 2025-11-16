import SwiftUI

/// DateBadge - Color-coded badge for displaying due dates
/// Color changes based on proximity (red=overdue, orange=today, blue=upcoming)
struct DateBadge: View {
    // MARK: - Properties

    let date: Date?
    let showTime: Bool

    // MARK: - Initializer

    init(date: Date?, showTime: Bool = false) {
        self.date = date
        self.showTime = showTime
    }

    // MARK: - Computed Properties

    private var dateStatus: DateStatus {
        guard let date = date else { return .none }

        let calendar = Calendar.current
        let now = Date()

        if calendar.isDateInToday(date) {
            return .today
        } else if date < now {
            return .overdue
        } else if calendar.isDateInTomorrow(date) {
            return .tomorrow
        } else if let daysUntil = calendar.dateComponents([.day], from: now, to: date).day,
                  daysUntil <= 7 {
            return .thisWeek
        } else {
            return .future
        }
    }

    private var displayText: String {
        guard let date = date else { return "No date" }

        let calendar = Calendar.current
        let dateFormatter = DateFormatter()

        switch dateStatus {
        case .none:
            return "No date"
        case .overdue:
            if calendar.isDateInYesterday(date) {
                return showTime ? "Yesterday \(formatTime(date))" : "Yesterday"
            } else {
                dateFormatter.dateFormat = showTime ? "MMM d, h:mm a" : "MMM d"
                return dateFormatter.string(from: date)
            }
        case .today:
            return showTime ? "Today \(formatTime(date))" : "Today"
        case .tomorrow:
            return showTime ? "Tomorrow \(formatTime(date))" : "Tomorrow"
        case .thisWeek:
            dateFormatter.dateFormat = showTime ? "EEEE, h:mm a" : "EEEE"
            return dateFormatter.string(from: date)
        case .future:
            dateFormatter.dateFormat = showTime ? "MMM d, h:mm a" : "MMM d"
            return dateFormatter.string(from: date)
        }
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: dateStatus.icon)
                .font(.system(size: 10, weight: .semibold))

            Text(displayText)
                .font(AppTypography.caption)
                .fontWeight(.medium)
        }
        .foregroundColor(dateStatus.color)
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, AppSpacing.xs)
        .background(dateStatus.color.opacity(0.15))
        .cornerRadius(AppCornerRadius.xs)
    }
}

// MARK: - Date Status

private enum DateStatus {
    case none
    case overdue
    case today
    case tomorrow
    case thisWeek
    case future

    var color: Color {
        switch self {
        case .none:
            return AppColors.textTertiary
        case .overdue:
            return AppColors.accentRed
        case .today:
            return AppColors.accentOrange
        case .tomorrow:
            return AppColors.accentYellow
        case .thisWeek:
            return AppColors.accentBlue
        case .future:
            return AppColors.accentPurple
        }
    }

    var icon: String {
        switch self {
        case .none:
            return "calendar"
        case .overdue:
            return "exclamationmark.triangle.fill"
        case .today:
            return "calendar.badge.clock"
        case .tomorrow:
            return "calendar.badge.plus"
        case .thisWeek:
            return "calendar"
        case .future:
            return "calendar"
        }
    }
}

// MARK: - Preview

#Preview("DateBadge") {
    ScrollView {
        VStack(spacing: AppSpacing.xl) {
            Text("Date Badges")
                .font(AppTypography.title1)
                .foregroundColor(AppColors.textPrimary)

            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Text("Date Statuses")
                    .font(AppTypography.title3)
                    .foregroundColor(AppColors.textPrimary)

                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    DateBadge(date: nil)
                    DateBadge(date: Calendar.current.date(byAdding: .day, value: -2, to: Date()))
                    DateBadge(date: Calendar.current.date(byAdding: .day, value: -1, to: Date()))
                    DateBadge(date: Date())
                    DateBadge(date: Calendar.current.date(byAdding: .day, value: 1, to: Date()))
                    DateBadge(date: Calendar.current.date(byAdding: .day, value: 3, to: Date()))
                    DateBadge(date: Calendar.current.date(byAdding: .day, value: 10, to: Date()))
                }
            }

            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Text("With Time")
                    .font(AppTypography.title3)
                    .foregroundColor(AppColors.textPrimary)

                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    DateBadge(date: Date(), showTime: true)
                    DateBadge(date: Calendar.current.date(byAdding: .day, value: 1, to: Date()), showTime: true)
                    DateBadge(date: Calendar.current.date(byAdding: .day, value: 3, to: Date()), showTime: true)
                }
            }
        }
        .padding(AppSpacing.screenPadding)
    }
    .background(AppColors.background)
}
