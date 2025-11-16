//
//  MockDataService.swift
//  ToDo-Appy
//
//  Created by Agent 1: Foundation & Setup Specialist
//  Generate mock data for testing and previews
//

import Foundation

/// Service for generating mock/sample data
/// Agent 2 will update this with actual model instances
struct MockDataService {

    // MARK: - Sample Task Data

    static let sampleTaskTitles = [
        "Buy groceries",
        "Finish project proposal",
        "Call dentist for appointment",
        "Review pull requests",
        "Update documentation",
        "Plan weekend trip",
        "Clean apartment",
        "Pay utility bills",
        "Exercise for 30 minutes",
        "Read chapter 5",
        "Prepare presentation slides",
        "Fix bug in login flow",
        "Send email to client",
        "Water plants",
        "Schedule team meeting",
        "Review budget",
        "Backup computer",
        "Update resume",
        "Order new headphones",
        "Call mom",
    ]

    static let sampleDescriptions = [
        "Remember to check the fridge first",
        "Due by end of week",
        "Preferably morning appointment",
        "Focus on high priority items",
        "Include code examples",
        "Check weather forecast",
        "Focus on kitchen and bathroom",
        "Set up automatic payments",
        "Morning routine",
        "Take notes",
        "Use company template",
        "Check error logs",
        "Include quarterly report",
        "They look dry",
        "Send calendar invite",
        "Compare to last month",
        "Use Time Machine",
        "Add recent projects",
        "Wireless noise cancelling",
        "It's been too long",
    ]

    // MARK: - Sample Category Data

    static let sampleCategories = [
        (name: "Personal", colorHex: "#3B82F6", icon: "person.fill"),
        (name: "Work", colorHex: "#EF4444", icon: "briefcase.fill"),
        (name: "Shopping", colorHex: "#10B981", icon: "cart.fill"),
        (name: "Health", colorHex: "#F59E0B", icon: "heart.fill"),
        (name: "Finance", colorHex: "#8B5CF6", icon: "dollarsign.circle.fill"),
        (name: "Home", colorHex: "#EC4899", icon: "house.fill"),
        (name: "Learning", colorHex: "#6366F1", icon: "book.fill"),
        (name: "Projects", colorHex: "#14B8A6", icon: "folder.fill"),
    ]

    // MARK: - Sample Tag Data

    static let sampleTags = [
        (name: "urgent", colorHex: "#EF4444"),
        (name: "important", colorHex: "#F59E0B"),
        (name: "later", colorHex: "#6B7280"),
        (name: "someday", colorHex: "#9CA3AF"),
        (name: "waiting", colorHex: "#8B5CF6"),
        (name: "review", colorHex: "#3B82F6"),
        (name: "quick", colorHex: "#10B981"),
        (name: "focus", colorHex: "#F59E0B"),
    ]

    // MARK: - Random Generators

    /// Generate random task title
    static func randomTaskTitle() -> String {
        sampleTaskTitles.randomElement() ?? "Task"
    }

    /// Generate random task description
    static func randomDescription() -> String {
        sampleDescriptions.randomElement() ?? ""
    }

    /// Generate random category name and color
    static func randomCategory() -> (name: String, colorHex: String, icon: String) {
        sampleCategories.randomElement() ?? ("Personal", "#3B82F6", "person.fill")
    }

    /// Generate random tag name and color
    static func randomTag() -> (name: String, colorHex: String) {
        sampleTags.randomElement() ?? ("tag", "#6B7280")
    }

    /// Generate random future date (1-30 days)
    static func randomFutureDate() -> Date {
        let days = Int.random(in: 1...30)
        return Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
    }

    /// Generate random past date (1-30 days ago)
    static func randomPastDate() -> Date {
        let days = Int.random(in: 1...30)
        return Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
    }

    /// Generate random priority
    static func randomPriority() -> Priority {
        Priority.allCases.randomElement() ?? .none
    }

    /// Generate random recurrence type
    static func randomRecurrenceType() -> RecurrenceType {
        RecurrenceType.allCases.randomElement() ?? .daily
    }

    // MARK: - Batch Generators

    /// Generate array of random task titles
    static func generateTaskTitles(count: Int) -> [String] {
        var titles: [String] = []
        for _ in 0..<count {
            titles.append(randomTaskTitle())
        }
        return titles
    }

    /// Generate array of category data
    static func generateCategories() -> [(name: String, colorHex: String, icon: String)] {
        return sampleCategories
    }

    /// Generate array of tag data
    static func generateTags() -> [(name: String, colorHex: String)] {
        return sampleTags
    }

    // MARK: - Preview Data

    /// Generate preview data set for SwiftUI previews
    /// Agent 2 will implement this to return actual model instances
    static func previewDataSet() -> PreviewData {
        PreviewData(
            taskTitles: Array(sampleTaskTitles.prefix(5)),
            categories: Array(sampleCategories.prefix(4)),
            tags: Array(sampleTags.prefix(3))
        )
    }

    struct PreviewData {
        let taskTitles: [String]
        let categories: [(name: String, colorHex: String, icon: String)]
        let tags: [(name: String, colorHex: String)]
    }

    // MARK: - Test Scenarios

    /// Generate data for specific test scenarios
    enum TestScenario {
        case empty
        case few // 3-5 items
        case normal // 10-20 items
        case many // 50+ items

        var taskCount: Int {
            switch self {
            case .empty: return 0
            case .few: return Int.random(in: 3...5)
            case .normal: return Int.random(in: 10...20)
            case .many: return Int.random(in: 50...100)
            }
        }

        var categoryCount: Int {
            switch self {
            case .empty: return 0
            case .few: return 2
            case .normal: return 4
            case .many: return 8
            }
        }
    }

    /// Get task count for test scenario
    static func taskCount(for scenario: TestScenario) -> Int {
        scenario.taskCount
    }

    // MARK: - Realistic Data Patterns

    /// Generate realistic due date distribution
    static func realisticDueDateDistribution() -> [Date?] {
        var dates: [Date?] = []

        // 20% no due date
        dates.append(contentsOf: Array(repeating: nil, count: 20))

        // 30% today or overdue
        for _ in 0..<30 {
            dates.append(Date().adding(days: Int.random(in: -5...0)))
        }

        // 30% this week
        for _ in 0..<30 {
            dates.append(Date().adding(days: Int.random(in: 1...7)))
        }

        // 20% later
        for _ in 0..<20 {
            dates.append(Date().adding(days: Int.random(in: 8...30)))
        }

        return dates.shuffled()
    }

    /// Generate realistic priority distribution
    static func realisticPriorityDistribution() -> [Priority] {
        var priorities: [Priority] = []

        // 40% none
        priorities.append(contentsOf: Array(repeating: Priority.none, count: 40))

        // 30% low
        priorities.append(contentsOf: Array(repeating: Priority.low, count: 30))

        // 20% medium
        priorities.append(contentsOf: Array(repeating: Priority.medium, count: 20))

        // 8% high
        priorities.append(contentsOf: Array(repeating: Priority.high, count: 8))

        // 2% urgent
        priorities.append(contentsOf: Array(repeating: Priority.urgent, count: 2))

        return priorities.shuffled()
    }

    /// Generate realistic completion status distribution
    static func realisticCompletionDistribution(count: Int) -> [Bool] {
        var statuses: [Bool] = []

        // 30% completed
        let completedCount = Int(Double(count) * 0.3)
        statuses.append(contentsOf: Array(repeating: true, count: completedCount))

        // 70% incomplete
        let incompleteCount = count - completedCount
        statuses.append(contentsOf: Array(repeating: false, count: incompleteCount))

        return statuses.shuffled()
    }
}

// MARK: - Usage Examples

/*
 // In SwiftUI Preview:
 #Preview {
     TaskListView(tasks: MockDataService.previewDataSet().taskTitles)
 }

 // In Unit Test:
 func testTaskFiltering() {
     let priorities = MockDataService.realisticPriorityDistribution()
     // Test with realistic data
 }

 // Generate specific scenario:
 let taskCount = MockDataService.taskCount(for: .normal)
 let titles = MockDataService.generateTaskTitles(count: taskCount)

 // Random single items:
 let title = MockDataService.randomTaskTitle()
 let dueDate = MockDataService.randomFutureDate()
 let priority = MockDataService.randomPriority()
 */
