import Foundation

/// Types of task recurrence patterns
enum RecurrenceType: String, Codable, CaseIterable {
    case daily = "daily"
    case weekly = "weekly"
    case monthly = "monthly"
    case yearly = "yearly"
    case custom = "custom"

    var displayName: String {
        switch self {
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        case .custom: return "Custom"
        }
    }

    var icon: String {
        switch self {
        case .daily: return "sun.max.fill"
        case .weekly: return "calendar.badge.clock"
        case .monthly: return "calendar"
        case .yearly: return "calendar.badge.plus"
        case .custom: return "gear"
        }
    }

    var description: String {
        switch self {
        case .daily: return "Repeats every day"
        case .weekly: return "Repeats every week"
        case .monthly: return "Repeats every month"
        case .yearly: return "Repeats every year"
        case .custom: return "Custom repeat pattern"
        }
    }
}
