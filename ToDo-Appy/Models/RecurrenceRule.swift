import Foundation

/// Represents a recurrence pattern for recurring tasks
struct RecurrenceRule: Codable, Equatable {
    var type: RecurrenceType
    var interval: Int  // Every N days/weeks/months/years
    var endDate: Date?
    var daysOfWeek: [Int]  // For weekly: 1=Sun, 2=Mon, etc.
    var dayOfMonth: Int?   // For monthly: 1-31
    var monthOfYear: Int?  // For yearly: 1-12

    // MARK: - Convenience Initializers

    /// Create a daily recurrence rule
    /// - Parameters:
    ///   - interval: Repeat every N days (default: 1 for daily)
    ///   - endDate: Optional end date for the recurrence
    /// - Returns: RecurrenceRule configured for daily recurrence
    static func daily(interval: Int = 1, endDate: Date? = nil) -> RecurrenceRule {
        RecurrenceRule(
            type: .daily,
            interval: interval,
            endDate: endDate,
            daysOfWeek: [],
            dayOfMonth: nil,
            monthOfYear: nil
        )
    }

    /// Create a weekly recurrence rule
    /// - Parameters:
    ///   - interval: Repeat every N weeks (default: 1 for weekly)
    ///   - daysOfWeek: Array of weekday numbers (1=Sunday, 2=Monday, ..., 7=Saturday)
    ///   - endDate: Optional end date for the recurrence
    /// - Returns: RecurrenceRule configured for weekly recurrence
    static func weekly(
        interval: Int = 1,
        daysOfWeek: [Int],
        endDate: Date? = nil
    ) -> RecurrenceRule {
        RecurrenceRule(
            type: .weekly,
            interval: interval,
            endDate: endDate,
            daysOfWeek: daysOfWeek,
            dayOfMonth: nil,
            monthOfYear: nil
        )
    }

    /// Create a monthly recurrence rule
    /// - Parameters:
    ///   - interval: Repeat every N months (default: 1 for monthly)
    ///   - dayOfMonth: Day of the month (1-31)
    ///   - endDate: Optional end date for the recurrence
    /// - Returns: RecurrenceRule configured for monthly recurrence
    static func monthly(
        interval: Int = 1,
        dayOfMonth: Int,
        endDate: Date? = nil
    ) -> RecurrenceRule {
        RecurrenceRule(
            type: .monthly,
            interval: interval,
            endDate: endDate,
            daysOfWeek: [],
            dayOfMonth: dayOfMonth,
            monthOfYear: nil
        )
    }

    /// Create a yearly recurrence rule
    /// - Parameters:
    ///   - interval: Repeat every N years (default: 1 for yearly)
    ///   - monthOfYear: Month of the year (1-12)
    ///   - dayOfMonth: Day of the month (1-31)
    ///   - endDate: Optional end date for the recurrence
    /// - Returns: RecurrenceRule configured for yearly recurrence
    static func yearly(
        interval: Int = 1,
        monthOfYear: Int,
        dayOfMonth: Int,
        endDate: Date? = nil
    ) -> RecurrenceRule {
        RecurrenceRule(
            type: .yearly,
            interval: interval,
            endDate: endDate,
            daysOfWeek: [],
            dayOfMonth: dayOfMonth,
            monthOfYear: monthOfYear
        )
    }

    // MARK: - Validation

    /// Validates that this recurrence rule is properly configured
    var isValid: Bool {
        switch type {
        case .daily:
            return interval > 0

        case .weekly:
            return interval > 0 && !daysOfWeek.isEmpty && daysOfWeek.allSatisfy { $0 >= 1 && $0 <= 7 }

        case .monthly:
            return interval > 0 && dayOfMonth != nil && (1...31).contains(dayOfMonth!)

        case .yearly:
            return interval > 0 &&
                   monthOfYear != nil && (1...12).contains(monthOfYear!) &&
                   dayOfMonth != nil && (1...31).contains(dayOfMonth!)

        case .custom:
            return true
        }
    }

    // MARK: - Display Helpers

    /// Human-readable description of the recurrence rule
    var description: String {
        var desc = ""

        switch type {
        case .daily:
            desc = interval == 1 ? "Daily" : "Every \(interval) days"

        case .weekly:
            let days = daysOfWeek.sorted().map { dayName(for: $0) }.joined(separator: ", ")
            desc = interval == 1 ? "Weekly on \(days)" : "Every \(interval) weeks on \(days)"

        case .monthly:
            if let day = dayOfMonth {
                desc = interval == 1 ? "Monthly on day \(day)" : "Every \(interval) months on day \(day)"
            }

        case .yearly:
            if let month = monthOfYear, let day = dayOfMonth {
                desc = interval == 1 ? "Yearly on \(monthName(for: month)) \(day)" : "Every \(interval) years on \(monthName(for: month)) \(day)"
            }

        case .custom:
            desc = "Custom recurrence"
        }

        if let end = endDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            desc += " until \(formatter.string(from: end))"
        }

        return desc
    }

    // MARK: - Private Helpers

    private func dayName(for weekday: Int) -> String {
        let days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        guard weekday >= 1 && weekday <= 7 else { return "" }
        return days[weekday - 1]
    }

    private func monthName(for month: Int) -> String {
        let months = ["January", "February", "March", "April", "May", "June",
                     "July", "August", "September", "October", "November", "December"]
        guard month >= 1 && month <= 12 else { return "" }
        return months[month - 1]
    }
}
