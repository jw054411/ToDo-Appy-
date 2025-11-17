//
//  NotificationService.swift
//  ToDo-Appy
//
//  Notification service for scheduling and managing task reminders
//  Handles local notifications with actions and badge management
//

import UserNotifications
import Foundation

/// Actor-based notification service for thread-safe notification management
actor NotificationService {

    // MARK: - Properties

    private let center = UNUserNotificationCenter.current()

    /// Notification category identifiers
    private let taskReminderCategory = "TASK_REMINDER"
    private let taskDueCategory = "TASK_DUE"

    // MARK: - Initialization

    init() {
        Task {
            await setupNotificationCategories()
        }
    }

    // MARK: - Authorization

    /// Request notification permission from user
    /// Returns true if permission granted, false otherwise
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])

            if granted {
                print("✅ Notification permission granted")
            } else {
                print("❌ Notification permission denied by user")
            }

            return granted
        } catch {
            print("❌ Error requesting notification permission: \(error.localizedDescription)")
            return false
        }
    }

    /// Check current authorization status
    func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus
    }

    // MARK: - Notification Categories & Actions

    /// Set up notification categories with actions
    private func setupNotificationCategories() async {
        // Task reminder actions
        let completeAction = UNNotificationAction(
            identifier: "COMPLETE_ACTION",
            title: "Complete",
            options: .foreground
        )

        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE_ACTION",
            title: "Snooze 1 hour",
            options: []
        )

        let viewAction = UNNotificationAction(
            identifier: "VIEW_ACTION",
            title: "View",
            options: .foreground
        )

        // Task reminder category
        let reminderCategory = UNNotificationCategory(
            identifier: taskReminderCategory,
            actions: [completeAction, snoozeAction, viewAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )

        // Task due category (simpler actions)
        let dueCategory = UNNotificationCategory(
            identifier: taskDueCategory,
            actions: [completeAction, viewAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )

        center.setNotificationCategories([reminderCategory, dueCategory])
        print("✅ Notification categories configured")
    }

    // MARK: - Schedule Notifications

    /// Schedule a reminder notification for a task
    /// Returns the notification identifier if successful, nil otherwise
    func scheduleReminder(for task: Task) async -> String? {
        // Check if task has reminder enabled
        guard task.hasReminder else {
            print("⚠️ Task '\(task.title)' has no reminder enabled")
            return nil
        }

        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = task.title
        content.body = task.taskDescription.isEmpty ? "Task reminder" : task.taskDescription
        content.sound = .default
        content.badge = 1

        // Add task info for handling when notification is tapped
        content.userInfo = [
            "taskID": task.id,
            "taskTitle": task.title
        ]

        // Set category for actions
        content.categoryIdentifier = taskReminderCategory

        // Add priority indicator if high priority
        if task.priority == .high || task.priority == .urgent {
            content.subtitle = "⚠️ \(task.priority.displayName) Priority"
        }

        // Determine trigger time
        let triggerDate: Date

        if let reminderTime = task.reminderTime {
            // Use explicit reminder time
            triggerDate = reminderTime
        } else if let dueDate = task.dueDate {
            // Use offset from due date
            let offsetMinutes = task.reminderOffset > 0 ? -task.reminderOffset : -15 // Default 15 min before
            triggerDate = Calendar.current.date(
                byAdding: .minute,
                value: offsetMinutes,
                to: dueDate
            ) ?? dueDate
        } else {
            print("⚠️ Task '\(task.title)' has no due date or reminder time")
            return nil
        }

        // Only schedule future notifications
        guard triggerDate > Date() else {
            print("⚠️ Reminder time for '\(task.title)' is in the past, skipping")
            return nil
        }

        // Create calendar trigger
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: triggerDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        // Generate unique notification ID
        let notificationID = "task-\(task.id)-\(UUID().uuidString)"
        let request = UNNotificationRequest(identifier: notificationID, content: content, trigger: trigger)

        // Schedule the notification
        do {
            try await center.add(request)
            print("🔔 Scheduled reminder for '\(task.title)' at \(triggerDate.formatted())")
            return notificationID
        } catch {
            print("❌ Error scheduling notification: \(error.localizedDescription)")
            return nil
        }
    }

    /// Schedule due date notification (when task is actually due)
    func scheduleDueNotification(for task: Task) async -> String? {
        guard let dueDate = task.dueDate else { return nil }

        let content = UNMutableNotificationContent()
        content.title = "Task Due: \(task.title)"
        content.body = task.taskDescription.isEmpty ? "This task is due now" : task.taskDescription
        content.sound = .defaultCritical // More urgent sound
        content.badge = 1
        content.categoryIdentifier = taskDueCategory

        content.userInfo = [
            "taskID": task.id,
            "taskTitle": task.title,
            "isDue": true
        ]

        // Only schedule future notifications
        guard dueDate > Date() else { return nil }

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: dueDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let notificationID = "task-due-\(task.id)"
        let request = UNNotificationRequest(identifier: notificationID, content: content, trigger: trigger)

        do {
            try await center.add(request)
            print("🔔 Scheduled due notification for '\(task.title)' at \(dueDate.formatted())")
            return notificationID
        } catch {
            print("❌ Error scheduling due notification: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - Cancel Notifications

    /// Cancel a specific notification by identifier
    func cancelNotification(withIdentifier identifier: String) async {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        print("🔕 Cancelled notification: \(identifier)")
    }

    /// Cancel all notifications for a specific task
    func cancelNotifications(for task: Task) async {
        var identifiers: [String] = []

        // Cancel main reminder if exists
        if let notificationID = task.notificationID {
            identifiers.append(notificationID)
        }

        // Cancel due notification
        identifiers.append("task-due-\(task.id)")

        guard !identifiers.isEmpty else { return }

        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        print("🔕 Cancelled \(identifiers.count) notification(s) for task '\(task.title)'")
    }

    /// Cancel all pending notifications
    func cancelAllNotifications() async {
        center.removeAllPendingNotificationRequests()
        print("🔕 Cancelled all pending notifications")
    }

    // MARK: - Reschedule

    /// Reschedule all reminders for a list of tasks
    /// Useful after app updates or when restoring from backup
    func rescheduleAllReminders(tasks: [Task]) async {
        print("🔄 Rescheduling reminders for \(tasks.count) tasks...")

        var successCount = 0

        for task in tasks where task.hasReminder && !task.isCompleted && !task.isDeleted {
            // Cancel existing notifications
            await cancelNotifications(for: task)

            // Schedule new reminder
            if let newID = await scheduleReminder(for: task) {
                // Note: In a real app, you'd update task.notificationID here
                // task.notificationID = newID
                successCount += 1
            }

            // Also schedule due notification if applicable
            if task.dueDate != nil {
                _ = await scheduleDueNotification(for: task)
            }
        }

        print("✅ Rescheduled \(successCount) reminders")
    }

    // MARK: - Badge Management

    /// Update app badge count to show number of pending tasks
    func updateBadgeCount(_ count: Int) async {
        do {
            try await center.setBadgeCount(count)
            print("🔢 Badge count updated to \(count)")
        } catch {
            print("❌ Error updating badge count: \(error.localizedDescription)")
        }
    }

    /// Clear app badge
    func clearBadge() async {
        await updateBadgeCount(0)
    }

    // MARK: - Pending Notifications

    /// Get all pending notification requests
    func getPendingNotifications() async -> [UNNotificationRequest] {
        return await center.pendingNotificationRequests()
    }

    /// Get count of pending notifications
    func getPendingNotificationCount() async -> Int {
        let pending = await getPendingNotifications()
        return pending.count
    }

    /// Get pending notifications for a specific task
    func getPendingNotifications(for task: Task) async -> [UNNotificationRequest] {
        let allPending = await getPendingNotifications()
        return allPending.filter { request in
            if let taskID = request.content.userInfo["taskID"] as? String {
                return taskID == task.id
            }
            return false
        }
    }

    // MARK: - Delivered Notifications

    /// Get all delivered notifications (shown but not dismissed)
    func getDeliveredNotifications() async -> [UNNotification] {
        return await center.deliveredNotifications()
    }

    /// Remove all delivered notifications from notification center
    func removeAllDeliveredNotifications() async {
        center.removeAllDeliveredNotifications()
        print("🗑️ Removed all delivered notifications")
    }

    // MARK: - Snooze Functionality

    /// Snooze a task notification (reschedule for later)
    func snoozeNotification(for task: Task, duration: TimeInterval = 3600) async -> String? {
        // Cancel existing notification
        await cancelNotifications(for: task)

        // Create new notification for snooze time
        let snoozeDate = Date().addingTimeInterval(duration)

        let content = UNMutableNotificationContent()
        content.title = "Reminder: \(task.title)"
        content.body = task.taskDescription.isEmpty ? "Snoozed task reminder" : task.taskDescription
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = taskReminderCategory

        content.userInfo = [
            "taskID": task.id,
            "taskTitle": task.title,
            "isSnoozed": true
        ]

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: snoozeDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let notificationID = "task-snooze-\(task.id)-\(UUID().uuidString)"
        let request = UNNotificationRequest(identifier: notificationID, content: content, trigger: trigger)

        do {
            try await center.add(request)
            let durationMinutes = Int(duration / 60)
            print("⏰ Snoozed notification for '\(task.title)' for \(durationMinutes) minutes")
            return notificationID
        } catch {
            print("❌ Error snoozing notification: \(error.localizedDescription)")
            return nil
        }
    }
}

// MARK: - Task Protocol Extension

// Note: This assumes Task model has these properties
// The actual Task model should be defined in Models/Task.swift
extension Task {
    /// Check if task should have a notification
    var shouldScheduleNotification: Bool {
        return hasReminder && !isCompleted && !isDeleted && (reminderTime != nil || dueDate != nil)
    }
}
