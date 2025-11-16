import Foundation
import SwiftData

/// Actor responsible for calculating recurrence patterns and managing recurring tasks
actor RecurrenceEngine {

    init() {}

    // MARK: - Core Methods

    /// Calculate the next occurrence date based on a recurrence rule
    /// - Parameters:
    ///   - date: The reference date to calculate from
    ///   - rule: The recurrence rule defining the pattern
    /// - Returns: The next occurrence date, or nil if no more occurrences (e.g., past end date)
    func nextOccurrence(from date: Date, rule: RecurrenceRule) -> Date? {
        guard rule.isValid else { return nil }

        let calendar = Calendar.current
        var nextDate: Date?

        switch rule.type {
        case .daily:
            nextDate = calendar.date(byAdding: .day, value: rule.interval, to: date)

        case .weekly:
            // Find next occurrence based on days of week
            nextDate = findNextWeeklyOccurrence(from: date, rule: rule)

        case .monthly:
            nextDate = findNextMonthlyOccurrence(from: date, rule: rule)

        case .yearly:
            nextDate = findNextYearlyOccurrence(from: date, rule: rule)

        case .custom:
            // Handle custom patterns (can be extended)
            nextDate = nil
        }

        // Check if next occurrence exceeds end date
        if let endDate = rule.endDate, let next = nextDate, next > endDate {
            return nil
        }

        return nextDate
    }

    /// Complete a recurring task and create the next instance
    /// - Parameters:
    ///   - task: The recurring task to complete
    ///   - modelContext: SwiftData model context for persistence
    /// - Returns: The newly created task instance, or nil if no more occurrences
    func completeRecurringTask(task: Task, modelContext: ModelContext) async -> Task? {
        guard task.isRecurring,
              let recurrenceType = task.recurrenceType else {
            return nil
        }

        // Create recurrence rule from task properties
        let rule = RecurrenceRule(
            type: recurrenceType,
            interval: task.recurrenceInterval,
            endDate: task.recurrenceEndDate,
            daysOfWeek: task.recurrenceDaysOfWeek,
            dayOfMonth: task.recurrenceDayOfMonth,
            monthOfYear: task.recurrenceMonthOfYear
        )

        // Calculate next occurrence
        guard let nextDueDate = nextOccurrence(from: task.dueDate ?? Date(), rule: rule) else {
            // No more occurrences (reached end date)
            return nil
        }

        // Create new instance
        let newTask = Task(
            title: task.title,
            taskDescription: task.taskDescription,
            dueDate: nextDueDate,
            priority: task.priority,
            category: task.category,
            isRecurring: true
        )

        // Copy recurrence settings
        newTask.recurrenceType = task.recurrenceType
        newTask.recurrenceInterval = task.recurrenceInterval
        newTask.recurrenceEndDate = task.recurrenceEndDate
        newTask.recurrenceDaysOfWeek = task.recurrenceDaysOfWeek
        newTask.recurrenceDayOfMonth = task.recurrenceDayOfMonth
        newTask.recurrenceMonthOfYear = task.recurrenceMonthOfYear
        newTask.parentRecurringTaskID = task.parentRecurringTaskID ?? task.id

        // Copy tags
        newTask.tags = task.tags

        // Copy reminder settings
        newTask.hasReminder = task.hasReminder
        newTask.reminderOffset = task.reminderOffset
        if task.hasReminder {
            newTask.reminderTime = calculateReminderTime(for: nextDueDate, offset: task.reminderOffset)
        }

        // Insert into context
        modelContext.insert(newTask)

        return newTask
    }

    /// Generate a list of occurrence dates for preview/planning purposes
    /// - Parameters:
    ///   - rule: The recurrence rule
    ///   - startDate: Start date for generation
    ///   - endDate: End date for generation
    ///   - maxCount: Maximum number of occurrences to generate (default: 100)
    /// - Returns: Array of occurrence dates
    func generateOccurrences(
        rule: RecurrenceRule,
        from startDate: Date,
        to endDate: Date,
        maxCount: Int = 100
    ) -> [Date] {
        var occurrences: [Date] = []
        var currentDate = startDate

        while occurrences.count < maxCount {
            if let nextDate = nextOccurrence(from: currentDate, rule: rule) {
                if nextDate > endDate { break }
                occurrences.append(nextDate)
                currentDate = nextDate
            } else {
                break
            }
        }

        return occurrences
    }

    // MARK: - Private Helper Methods

    /// Find the next weekly occurrence based on specified days of week
    private func findNextWeeklyOccurrence(from date: Date, rule: RecurrenceRule) -> Date? {
        let calendar = Calendar.current
        let currentWeekday = calendar.component(.weekday, from: date)

        // Sort days of week
        let sortedDays = rule.daysOfWeek.sorted()

        // Try to find next day in current week
        if let nextDay = sortedDays.first(where: { $0 > currentWeekday }) {
            let daysToAdd = nextDay - currentWeekday
            return calendar.date(byAdding: .day, value: daysToAdd, to: date)
        }

        // No more days this week, move to next week(s)
        let weeksToAdd = rule.interval
        let firstDayNextCycle = sortedDays.first!
        let daysToAdd = (7 * weeksToAdd) - currentWeekday + firstDayNextCycle
        return calendar.date(byAdding: .day, value: daysToAdd, to: date)
    }

    /// Find the next monthly occurrence on a specific day of the month
    private func findNextMonthlyOccurrence(from date: Date, rule: RecurrenceRule) -> Date? {
        guard let targetDay = rule.dayOfMonth else { return nil }

        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: date)

        // Move to next month(s)
        components.month! += rule.interval
        components.day = targetDay

        // Handle month-end edge cases (e.g., Feb 31 → Feb 28/29)
        var nextDate = calendar.date(from: components)
        if nextDate == nil || calendar.component(.day, from: nextDate!) != targetDay {
            // Target day doesn't exist in this month, use last day of month
            components.day = 1
            components.month! += 1
            if let firstOfNextMonth = calendar.date(from: components) {
                nextDate = calendar.date(byAdding: .day, value: -1, to: firstOfNextMonth)
            }
        }

        return nextDate
    }

    /// Find the next yearly occurrence on a specific month and day
    private func findNextYearlyOccurrence(from date: Date, rule: RecurrenceRule) -> Date? {
        guard let targetMonth = rule.monthOfYear,
              let targetDay = rule.dayOfMonth else { return nil }

        let calendar = Calendar.current
        var components = calendar.dateComponents([.year], from: date)

        components.year! += rule.interval
        components.month = targetMonth
        components.day = targetDay

        return calendar.date(from: components)
    }

    /// Calculate the reminder time based on due date and offset
    private func calculateReminderTime(for dueDate: Date, offset: Int) -> Date {
        Calendar.current.date(byAdding: .minute, value: -offset, to: dueDate) ?? dueDate
    }
}
