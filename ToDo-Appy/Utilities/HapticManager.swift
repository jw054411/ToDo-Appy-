//
//  HapticManager.swift
//  ToDo-Appy
//
//  Created by Agent 1: Foundation & Setup Specialist
//  Centralized haptic feedback management
//

import UIKit
import SwiftUI

/// Manager for haptic feedback throughout the app
@MainActor
class HapticManager {
    static let shared = HapticManager()

    private init() {}

    /// Check if haptics are enabled in user preferences
    private var isEnabled: Bool {
        UserDefaults.standard.bool(forKey: UserDefaultsKeys.hapticsEnabled)
    }

    // MARK: - Impact Feedback

    /// Light impact (e.g., selecting an item)
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        guard isEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    /// Medium impact (e.g., toggling a switch)
    func mediumImpact() {
        impact(.medium)
    }

    /// Heavy impact (e.g., deleting an item)
    func heavyImpact() {
        impact(.heavy)
    }

    /// Rigid impact (e.g., reaching a limit)
    func rigidImpact() {
        impact(.rigid)
    }

    /// Soft impact (e.g., subtle interaction)
    func softImpact() {
        impact(.soft)
    }

    // MARK: - Notification Feedback

    /// Success feedback (e.g., task completed)
    func success() {
        guard isEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    /// Warning feedback (e.g., validation error)
    func warning() {
        guard isEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }

    /// Error feedback (e.g., operation failed)
    func error() {
        guard isEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }

    // MARK: - Selection Feedback

    /// Selection changed feedback (e.g., picker value changed)
    func selectionChanged() {
        guard isEnabled else { return }
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    // MARK: - Common App Actions

    /// Feedback for task completion
    func taskCompleted() {
        success()
    }

    /// Feedback for task uncompleted
    func taskUncompleted() {
        mediumImpact()
    }

    /// Feedback for creating a new item
    func itemCreated() {
        mediumImpact()
    }

    /// Feedback for deleting an item
    func itemDeleted() {
        heavyImpact()
    }

    /// Feedback for button tap
    func buttonTap() {
        impact(.light)
    }

    /// Feedback for toggle switch
    func toggle() {
        mediumImpact()
    }

    /// Feedback for drag and drop
    func dragStart() {
        mediumImpact()
    }

    /// Feedback for drag and drop completion
    func dropCompleted() {
        success()
    }

    /// Feedback for swipe action
    func swipeAction() {
        mediumImpact()
    }

    /// Feedback for reaching end of list
    func reachedEnd() {
        rigidImpact()
    }

    /// Feedback for pull to refresh
    func refreshTriggered() {
        mediumImpact()
    }

    /// Feedback for sync completed
    func syncCompleted() {
        success()
    }

    /// Feedback for sync failed
    func syncFailed() {
        error()
    }
}

// MARK: - SwiftUI View Extension

extension View {
    /// Add haptic feedback on tap
    func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) -> some View {
        self.onTapGesture {
            HapticManager.shared.impact(style)
        }
    }

    /// Add success haptic on tap
    func successHaptic() -> some View {
        self.onTapGesture {
            HapticManager.shared.success()
        }
    }
}

// MARK: - Usage Examples

/*
 // In ViewModel or View:
 HapticManager.shared.taskCompleted()
 HapticManager.shared.itemDeleted()
 HapticManager.shared.success()

 // In SwiftUI View:
 Button("Complete") {
     HapticManager.shared.taskCompleted()
     completeTask()
 }

 // Using view modifier:
 Text("Tap me")
     .hapticFeedback(.medium)
 */
