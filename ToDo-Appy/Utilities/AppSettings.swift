//
//  AppSettings.swift
//  ToDo-Appy
//
//  Created by Agent 1: Foundation & Setup Specialist
//  Type-safe UserDefaults wrapper for app settings
//

import Foundation
import SwiftUI

/// Type-safe app settings manager
@MainActor
class AppSettings: ObservableObject {
    static let shared = AppSettings()

    private let defaults = UserDefaults.standard

    private init() {
        registerDefaults()
    }

    // MARK: - Onboarding

    @Published var hasCompletedOnboarding: Bool {
        didSet { defaults.set(hasCompletedOnboarding, forKey: UserDefaultsKeys.hasCompletedOnboarding) }
    }

    // MARK: - Sync

    @Published var lastSyncTimestamp: Date? {
        didSet { defaults.set(lastSyncTimestamp, forKey: UserDefaultsKeys.lastSyncTimestamp) }
    }

    // MARK: - View Preferences

    @Published var preferredViewMode: ViewMode {
        didSet { defaults.set(preferredViewMode.rawValue, forKey: UserDefaultsKeys.preferredViewMode) }
    }

    @Published var showCompletedTasks: Bool {
        didSet { defaults.set(showCompletedTasks, forKey: UserDefaultsKeys.showCompletedTasks) }
    }

    @Published var groupByCategory: Bool {
        didSet { defaults.set(groupByCategory, forKey: UserDefaultsKeys.groupByCategory) }
    }

    @Published var sortOrderPreference: SortOrder {
        didSet { defaults.set(sortOrderPreference.rawValue, forKey: UserDefaultsKeys.sortOrderPreference) }
    }

    // MARK: - Default Category

    @Published var defaultCategoryID: String? {
        didSet { defaults.set(defaultCategoryID, forKey: UserDefaultsKeys.defaultCategoryID) }
    }

    // MARK: - UI Preferences

    @Published var hapticsEnabled: Bool {
        didSet { defaults.set(hapticsEnabled, forKey: UserDefaultsKeys.hapticsEnabled) }
    }

    @Published var notificationSound: String {
        didSet { defaults.set(notificationSound, forKey: UserDefaultsKeys.notificationSound) }
    }

    // MARK: - Statistics

    @Published var firstLaunchDate: Date? {
        didSet { defaults.set(firstLaunchDate, forKey: UserDefaultsKeys.firstLaunchDate) }
    }

    @Published var totalTasksCreated: Int {
        didSet { defaults.set(totalTasksCreated, forKey: UserDefaultsKeys.totalTasksCreated) }
    }

    @Published var totalTasksCompleted: Int {
        didSet { defaults.set(totalTasksCompleted, forKey: UserDefaultsKeys.totalTasksCompleted) }
    }

    // MARK: - Initialization

    private func registerDefaults() {
        // Read current values from UserDefaults
        hasCompletedOnboarding = defaults.bool(forKey: UserDefaultsKeys.hasCompletedOnboarding)
        lastSyncTimestamp = defaults.object(forKey: UserDefaultsKeys.lastSyncTimestamp) as? Date

        // View preferences (with defaults)
        preferredViewMode = ViewMode(rawValue: defaults.string(forKey: UserDefaultsKeys.preferredViewMode) ?? "") ?? .list
        showCompletedTasks = defaults.object(forKey: UserDefaultsKeys.showCompletedTasks) as? Bool ?? true
        groupByCategory = defaults.object(forKey: UserDefaultsKeys.groupByCategory) as? Bool ?? false
        sortOrderPreference = SortOrder(rawValue: defaults.string(forKey: UserDefaultsKeys.sortOrderPreference) ?? "") ?? .dueDate

        // Default category
        defaultCategoryID = defaults.string(forKey: UserDefaultsKeys.defaultCategoryID)

        // UI preferences
        hapticsEnabled = defaults.object(forKey: UserDefaultsKeys.hapticsEnabled) as? Bool ?? true
        notificationSound = defaults.string(forKey: UserDefaultsKeys.notificationSound) ?? "default"

        // Statistics
        firstLaunchDate = defaults.object(forKey: UserDefaultsKeys.firstLaunchDate) as? Date
        if firstLaunchDate == nil {
            firstLaunchDate = Date()
        }

        totalTasksCreated = defaults.integer(forKey: UserDefaultsKeys.totalTasksCreated)
        totalTasksCompleted = defaults.integer(forKey: UserDefaultsKeys.totalTasksCompleted)
    }

    // MARK: - Helper Methods

    /// Increment tasks created counter
    func incrementTasksCreated() {
        totalTasksCreated += 1
    }

    /// Increment tasks completed counter
    func incrementTasksCompleted() {
        totalTasksCompleted += 1
    }

    /// Reset all settings to defaults
    func resetToDefaults() {
        hasCompletedOnboarding = false
        preferredViewMode = .list
        showCompletedTasks = true
        groupByCategory = false
        sortOrderPreference = .dueDate
        defaultCategoryID = nil
        hapticsEnabled = true
        notificationSound = "default"
        // Don't reset statistics
    }

    /// Clear all settings (including statistics)
    func clearAll() {
        resetToDefaults()
        firstLaunchDate = nil
        totalTasksCreated = 0
        totalTasksCompleted = 0
        lastSyncTimestamp = nil
    }

    // MARK: - Computed Properties

    /// Days since first launch
    var daysSinceFirstLaunch: Int {
        guard let firstLaunch = firstLaunchDate else { return 0 }
        return Calendar.current.dateComponents([.day], from: firstLaunch, to: Date()).day ?? 0
    }

    /// Completion rate (percentage)
    var completionRate: Double {
        guard totalTasksCreated > 0 else { return 0 }
        return (Double(totalTasksCompleted) / Double(totalTasksCreated)) * 100
    }

    // MARK: - Supporting Types

    enum ViewMode: String, CaseIterable {
        case list
        case grid

        var displayName: String {
            switch self {
            case .list: return "List"
            case .grid: return "Grid"
            }
        }

        var icon: String {
            switch self {
            case .list: return "list.bullet"
            case .grid: return "square.grid.2x2"
            }
        }
    }

    enum SortOrder: String, CaseIterable {
        case dueDate
        case priority
        case createdDate
        case title
        case manual

        var displayName: String {
            switch self {
            case .dueDate: return "Due Date"
            case .priority: return "Priority"
            case .createdDate: return "Created Date"
            case .title: return "Title"
            case .manual: return "Manual"
            }
        }

        var icon: String {
            switch self {
            case .dueDate: return "calendar"
            case .priority: return "exclamationmark.circle"
            case .createdDate: return "clock"
            case .title: return "textformat"
            case .manual: return "hand.point.up.braille"
            }
        }
    }
}

// MARK: - SwiftUI Environment

private struct AppSettingsKey: EnvironmentKey {
    static let defaultValue = AppSettings.shared
}

extension EnvironmentValues {
    var appSettings: AppSettings {
        get { self[AppSettingsKey.self] }
        set { self[AppSettingsKey.self] = newValue }
    }
}

// MARK: - Usage Examples

/*
 // In App:
 @StateObject private var settings = AppSettings.shared

 // Access settings:
 if settings.hasCompletedOnboarding {
     MainView()
 } else {
     OnboardingView()
 }

 // Modify settings:
 Button("Toggle View Mode") {
     settings.preferredViewMode = settings.preferredViewMode == .list ? .grid : .list
 }

 // Use in ViewModel:
 if AppSettings.shared.showCompletedTasks {
     // Include completed tasks in query
 }

 // Increment counters:
 AppSettings.shared.incrementTasksCreated()
 AppSettings.shared.incrementTasksCompleted()
 */
