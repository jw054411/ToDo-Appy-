import SwiftData
import Foundation

/// Actor responsible for seeding default data into the app
actor DataSeeder {

    /// Seed default categories on first launch
    /// - Parameter modelContext: SwiftData model context
    func seedDefaultCategories(modelContext: ModelContext) async {
        // Check if categories already exist
        let descriptor = FetchDescriptor<Category>()
        let existingCategories = try? modelContext.fetch(descriptor)

        guard existingCategories?.isEmpty ?? true else { return }

        // Create default categories with iOS-native colors
        let inbox = Category(
            name: "Inbox",
            colorHex: "#0A84FF",  // iOS Blue
            icon: "tray.fill"
        )

        let personal = Category(
            name: "Personal",
            colorHex: "#BF5AF2",  // iOS Purple
            icon: "person.fill"
        )

        let work = Category(
            name: "Work",
            colorHex: "#FF9F0A",  // iOS Orange
            icon: "briefcase.fill"
        )

        let shopping = Category(
            name: "Shopping",
            colorHex: "#32D74B",  // iOS Green
            icon: "cart.fill"
        )

        let health = Category(
            name: "Health",
            colorHex: "#FF453A",  // iOS Red
            icon: "heart.fill"
        )

        // Set sort order
        inbox.sortOrder = 0
        personal.sortOrder = 1
        work.sortOrder = 2
        shopping.sortOrder = 3
        health.sortOrder = 4

        // Insert categories
        modelContext.insert(inbox)
        modelContext.insert(personal)
        modelContext.insert(work)
        modelContext.insert(shopping)
        modelContext.insert(health)

        // Save context
        try? modelContext.save()
    }

    #if DEBUG
    /// Seed sample tasks for development/preview purposes
    /// - Parameter modelContext: SwiftData model context
    func seedSampleTasks(modelContext: ModelContext) async {
        // Only for development/preview
        let descriptor = FetchDescriptor<Task>()
        let existingTasks = try? modelContext.fetch(descriptor)

        guard existingTasks?.isEmpty ?? true else { return }

        // Get inbox category
        let categoryDescriptor = FetchDescriptor<Category>(
            predicate: #Predicate { $0.name == "Inbox" }
        )
        let inbox = try? modelContext.fetch(categoryDescriptor).first

        // Get work category
        let workDescriptor = FetchDescriptor<Category>(
            predicate: #Predicate { $0.name == "Work" }
        )
        let work = try? modelContext.fetch(workDescriptor).first

        // Get personal category
        let personalDescriptor = FetchDescriptor<Category>(
            predicate: #Predicate { $0.name == "Personal" }
        )
        let personal = try? modelContext.fetch(personalDescriptor).first

        let calendar = Calendar.current

        // Create sample tasks
        let task1 = Task(
            title: "Complete project proposal",
            taskDescription: "Finish the Q4 project proposal and send to team",
            dueDate: Date(),
            priority: .high,
            category: work
        )

        let task2 = Task(
            title: "Buy groceries",
            taskDescription: "Milk, eggs, bread, vegetables",
            dueDate: calendar.date(byAdding: .day, value: 1, to: Date()),
            priority: .medium,
            category: inbox
        )

        let task3 = Task(
            title: "Call dentist",
            taskDescription: "Schedule annual checkup",
            priority: .low,
            category: personal
        )

        let task4 = Task(
            title: "Review pull requests",
            taskDescription: "Review team's PRs before standup",
            dueDate: calendar.date(byAdding: .hour, value: -2, to: Date()),
            priority: .urgent,
            category: work
        )
        task4.markAsCompleted()

        let task5 = Task(
            title: "Weekly team meeting",
            taskDescription: "Every Monday at 10 AM",
            dueDate: Date(),
            priority: .medium,
            category: work,
            isRecurring: true
        )
        task5.recurrenceType = .weekly
        task5.recurrenceInterval = 1
        task5.recurrenceDaysOfWeek = [2]  // Monday

        // Create some subtasks
        let subtask1 = Task(
            title: "Research competitors",
            priority: .medium,
            category: work
        )
        let subtask2 = Task(
            title: "Draft outline",
            priority: .medium,
            category: work
        )
        subtask2.markAsCompleted()

        task1.subtasks = [subtask1, subtask2]

        // Insert tasks
        modelContext.insert(task1)
        modelContext.insert(task2)
        modelContext.insert(task3)
        modelContext.insert(task4)
        modelContext.insert(task5)
        modelContext.insert(subtask1)
        modelContext.insert(subtask2)

        // Create sample tags
        let urgentTag = Tag(name: "Urgent", colorHex: "#FF453A")
        let reviewTag = Tag(name: "Review", colorHex: "#0A84FF")

        task1.tags = [reviewTag]
        task4.tags = [urgentTag, reviewTag]

        modelContext.insert(urgentTag)
        modelContext.insert(reviewTag)

        // Save context
        try? modelContext.save()
    }
    #endif

    /// Clear all data (useful for testing/debugging)
    #if DEBUG
    func clearAllData(modelContext: ModelContext) async {
        // Delete all tasks
        let taskDescriptor = FetchDescriptor<Task>()
        if let tasks = try? modelContext.fetch(taskDescriptor) {
            tasks.forEach { modelContext.delete($0) }
        }

        // Delete all categories
        let categoryDescriptor = FetchDescriptor<Category>()
        if let categories = try? modelContext.fetch(categoryDescriptor) {
            categories.forEach { modelContext.delete($0) }
        }

        // Delete all tags
        let tagDescriptor = FetchDescriptor<Tag>()
        if let tags = try? modelContext.fetch(tagDescriptor) {
            tags.forEach { modelContext.delete($0) }
        }

        try? modelContext.save()
    }
    #endif
}
