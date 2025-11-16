import Foundation

extension Date {
    /// Check if this date is today
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    /// Check if this date is tomorrow
    var isTomorrow: Bool {
        Calendar.current.isDateInTomorrow(self)
    }

    /// Check if this date is yesterday
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }

    /// Check if this date is in the current week
    var isThisWeek: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }

    /// Check if this date is in the current month
    var isThisMonth: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .month)
    }

    /// Check if this date is in the current year
    var isThisYear: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .year)
    }

    /// Get the start of the day for this date
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    /// Get the end of the day for this date
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
    }

    /// Get a date representing the start of the week containing this date
    var startOfWeek: Date? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components)
    }

    /// Get a date representing the end of the week containing this date
    var endOfWeek: Date? {
        guard let startOfWeek = startOfWeek else { return nil }
        return Calendar.current.date(byAdding: .day, value: 6, to: startOfWeek)?.endOfDay
    }

    /// Get a date representing the start of the month containing this date
    var startOfMonth: Date? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components)
    }

    /// Get a date representing the end of the month containing this date
    var endOfMonth: Date? {
        guard let startOfMonth = startOfMonth else { return nil }
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfMonth)
    }

    /// Get a formatted string representation of this date
    func formatted(_ style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }

    /// Get a relative description of this date (e.g., "Today", "Yesterday", "Tomorrow")
    var relativeDescription: String {
        if isToday {
            return "Today"
        } else if isTomorrow {
            return "Tomorrow"
        } else if isYesterday {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: self)
        }
    }

    /// Check if this date is in the past
    var isPast: Bool {
        self < Date()
    }

    /// Check if this date is in the future
    var isFuture: Bool {
        self > Date()
    }
}
