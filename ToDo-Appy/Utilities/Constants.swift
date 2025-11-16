//
//  Constants.swift
//  ToDo-Appy
//
//  Created by Agent 1: Foundation & Setup Specialist
//  App-wide constants and configuration values
//

import Foundation
import SwiftUI

// MARK: - App Constants

enum AppConstants {
    /// App name
    static let appName = "ToDo-Appy"

    /// App bundle identifier
    static let bundleIdentifier = "com.personal.todoappy"

    /// App version (read from Info.plist)
    static var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    /// Build number (read from Info.plist)
    static var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    /// Full version string
    static var versionString: String {
        "\(appVersion) (\(buildNumber))"
    }
}

// MARK: - CloudKit Constants

enum CloudKitConstants {
    /// CloudKit container identifier
    static let containerIdentifier = "iCloud.com.personal.todoappy"

    /// Custom zone name
    static let zoneName = "TasksZone"

    /// Record type names
    enum RecordType {
        static let task = "CKTask"
        static let category = "CKCategory"
        static let tag = "CKTag"
    }

    /// Subscription IDs
    enum SubscriptionID {
        static let taskChanges = "TaskChanges"
        static let categoryChanges = "CategoryChanges"
        static let tagChanges = "TagChanges"
    }

    /// Sync configuration
    enum Sync {
        /// How often to check for changes (seconds)
        static let syncInterval: TimeInterval = 60

        /// Batch size for fetching records
        static let fetchBatchSize = 100

        /// Maximum retry attempts
        static let maxRetryAttempts = 3

        /// Retry delay (seconds)
        static let retryDelay: TimeInterval = 2
    }
}

// MARK: - UI Constants

enum UIConstants {
    /// Default animation duration
    static let animationDuration: Double = 0.3

    /// Spring animation response
    static let springResponse: Double = 0.35

    /// Spring animation damping
    static let springDamping: Double = 0.7

    /// Corner radius values
    enum CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 24
    }

    /// Spacing values
    enum Spacing {
        static let xxs: CGFloat = 2
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    /// Icon sizes
    enum IconSize {
        static let small: CGFloat = 16
        static let medium: CGFloat = 24
        static let large: CGFloat = 32
        static let extraLarge: CGFloat = 48
    }

    /// Font sizes
    enum FontSize {
        static let caption: CGFloat = 12
        static let body: CGFloat = 16
        static let title: CGFloat = 20
        static let largeTitle: CGFloat = 28
    }

    /// List row height
    static let listRowHeight: CGFloat = 60

    /// Maximum task title length
    static let maxTaskTitleLength = 200

    /// Maximum task description length
    static let maxTaskDescriptionLength = 1000
}

// MARK: - Notification Constants

enum NotificationConstants {
    /// Notification category IDs
    enum CategoryID {
        static let taskReminder = "TASK_REMINDER"
        static let recurringTask = "RECURRING_TASK"
    }

    /// Notification action IDs
    enum ActionID {
        static let complete = "COMPLETE_ACTION"
        static let snooze = "SNOOZE_ACTION"
        static let delete = "DELETE_ACTION"
    }

    /// Default snooze duration (minutes)
    static let defaultSnoozeDuration: TimeInterval = 15 * 60

    /// Reminder time options (minutes before due date)
    static let reminderOptions: [Int] = [0, 5, 10, 15, 30, 60, 120, 1440] // 0 to 24 hours
}

// MARK: - UserDefaults Keys

enum UserDefaultsKeys {
    /// Has completed onboarding
    static let hasCompletedOnboarding = "hasCompletedOnboarding"

    /// Last sync timestamp
    static let lastSyncTimestamp = "lastSyncTimestamp"

    /// Preferred view mode (list/grid)
    static let preferredViewMode = "preferredViewMode"

    /// Default category ID
    static let defaultCategoryID = "defaultCategoryID"

    /// Sort order preference
    static let sortOrderPreference = "sortOrderPreference"

    /// Show completed tasks
    static let showCompletedTasks = "showCompletedTasks"

    /// Group tasks by category
    static let groupByCategory = "groupByCategory"

    /// Haptic feedback enabled
    static let hapticsEnabled = "hapticsEnabled"

    /// Notification sound
    static let notificationSound = "notificationSound"

    /// App theme (if we add light mode later)
    static let appTheme = "appTheme"

    /// First launch date
    static let firstLaunchDate = "firstLaunchDate"

    /// Total tasks created
    static let totalTasksCreated = "totalTasksCreated"

    /// Total tasks completed
    static let totalTasksCompleted = "totalTasksCompleted"
}

// MARK: - Date Format Constants

enum DateFormatConstants {
    static let shortDate = "MMM d"
    static let mediumDate = "MMM d, yyyy"
    static let longDate = "MMMM d, yyyy"
    static let shortTime = "h:mm a"
    static let mediumDateTime = "MMM d, h:mm a"
    static let fullDateTime = "MMMM d, yyyy 'at' h:mm a"
}

// MARK: - Export/Import Constants

enum ExportConstants {
    /// Supported export formats
    enum Format: String, CaseIterable {
        case json = "json"
        case csv = "csv"
        case markdown = "md"

        var displayName: String {
            switch self {
            case .json: return "JSON"
            case .csv: return "CSV"
            case .markdown: return "Markdown"
            }
        }

        var fileExtension: String {
            return rawValue
        }
    }

    /// Export file prefix
    static let filePrefix = "todoappy_export"

    /// Date format for export filename
    static let filenameDateFormat = "yyyy-MM-dd_HHmmss"
}

// MARK: - Feature Flags

enum FeatureFlags {
    /// Enable recurring tasks
    static let recurringTasksEnabled = true

    /// Enable subtasks
    static let subtasksEnabled = true

    /// Enable tags
    static let tagsEnabled = true

    /// Enable natural language input
    static let naturalLanguageEnabled = true

    /// Enable widgets
    static let widgetsEnabled = true

    /// Enable collaboration (future feature)
    static let collaborationEnabled = false

    /// Enable AI suggestions (future feature)
    static let aiSuggestionsEnabled = false

    /// Debug mode (shows extra info)
    static let debugMode = false
}

// MARK: - SF Symbols

enum SFSymbols {
    // Tasks
    static let task = "checkmark.circle"
    static let taskCompleted = "checkmark.circle.fill"
    static let subtask = "minus.circle"

    // Categories
    static let category = "folder"
    static let categoryFilled = "folder.fill"

    // Tags
    static let tag = "tag"
    static let tagFilled = "tag.fill"

    // Actions
    static let add = "plus"
    static let edit = "pencil"
    static let delete = "trash"
    static let search = "magnifyingglass"
    static let filter = "line.3.horizontal.decrease.circle"
    static let sort = "arrow.up.arrow.down"

    // Time
    static let calendar = "calendar"
    static let clock = "clock"
    static let reminder = "bell"
    static let reminderFilled = "bell.fill"

    // Priority
    static let priority = "exclamationmark.circle"
    static let priorityFilled = "exclamationmark.circle.fill"

    // Sync
    static let sync = "arrow.triangle.2.circlepath"
    static let cloud = "icloud"
    static let cloudFilled = "icloud.fill"

    // Settings
    static let settings = "gearshape"
    static let settingsFilled = "gearshape.fill"

    // Navigation
    static let back = "chevron.left"
    static let forward = "chevron.right"
    static let more = "ellipsis.circle"

    // Status
    static let error = "exclamationmark.triangle"
    static let warning = "exclamationmark.circle"
    static let info = "info.circle"
    static let success = "checkmark.circle"
}

// MARK: - Animation Constants

enum AnimationConstants {
    static let defaultSpring = Animation.spring(response: UIConstants.springResponse, dampingFraction: UIConstants.springDamping)

    static let quickSpring = Animation.spring(response: 0.25, dampingFraction: 0.8)

    static let bouncy = Animation.spring(response: 0.4, dampingFraction: 0.6)

    static let smooth = Animation.easeInOut(duration: UIConstants.animationDuration)

    static let fast = Animation.easeInOut(duration: 0.2)

    static let slow = Animation.easeInOut(duration: 0.5)
}

// MARK: - URL Constants

enum URLConstants {
    /// Privacy policy URL
    static let privacyPolicy = URL(string: "https://example.com/privacy")!

    /// Terms of service URL
    static let termsOfService = URL(string: "https://example.com/terms")!

    /// Support email
    static let supportEmail = "support@todoappy.com"

    /// App Store URL (update when published)
    static let appStore = URL(string: "https://apps.apple.com/app/todoappy/id000000000")

    /// GitHub repository (if open source)
    static let githubRepo = URL(string: "https://github.com/username/todoappy")
}
