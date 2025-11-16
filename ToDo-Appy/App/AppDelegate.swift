//
//  AppDelegate.swift
//  ToDo-Appy
//
//  Application delegate for handling push notifications and CloudKit changes
//  Manages app lifecycle events and background sync
//

import UIKit
import CloudKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    // MARK: - Properties

    var dataManager: DataManager?

    // MARK: - Application Lifecycle

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        print("🚀 ToDo-Appy launched")

        // Set up notification center delegate
        UNUserNotificationCenter.current().delegate = self

        // Register for remote notifications (CloudKit push)
        application.registerForRemoteNotifications()

        // Initialize data manager
        Task {
            dataManager = await DataManager.shared

            // Request notification permission
            let notificationService = await dataManager?.getNotificationService()
            let granted = await notificationService?.requestAuthorization() ?? false

            if granted {
                print("✅ Notification permission granted")
            }

            // Perform initial sync
            if let syncService = await dataManager?.getSyncService() {
                do {
                    try await syncService.syncAll()
                    print("✅ Initial sync completed")
                } catch {
                    print("⚠️ Initial sync failed: \(error.localizedDescription)")
                }
            }

            // Clean up old deleted items (30+ days)
            try? await dataManager?.cleanupOldDeletedItems()
        }

        return true
    }

    // MARK: - Remote Notifications (CloudKit Push)

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("📱 Registered for remote notifications: \(tokenString)")
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("❌ Failed to register for remote notifications: \(error.localizedDescription)")
    }

    /// Handle CloudKit push notifications for background sync
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        print("📨 Received remote notification")

        // Check if this is a CloudKit notification
        guard let notification = CKNotification(fromRemoteNotificationDictionary: userInfo) else {
            print("⚠️ Not a CloudKit notification")
            completionHandler(.noData)
            return
        }

        print("☁️ CloudKit notification received: \(notification.notificationType.rawValue)")

        // Handle different notification types
        switch notification.notificationType {
        case .query:
            if let queryNotification = notification as? CKQueryNotification {
                print("📊 Query notification for recordID: \(queryNotification.recordID?.recordName ?? "unknown")")
            }

        case .recordZone:
            if let zoneNotification = notification as? CKRecordZoneNotification {
                print("🗂️ Zone notification for zone: \(zoneNotification.recordZoneID?.zoneName ?? "unknown")")
            }

        case .database:
            if let databaseNotification = notification as? CKDatabaseNotification {
                print("💾 Database notification: \(databaseNotification.databaseScope.rawValue)")
            }

        @unknown default:
            print("⚠️ Unknown notification type")
        }

        // Trigger background sync
        Task {
            do {
                if let syncService = await dataManager?.getSyncService() {
                    try await syncService.syncAll()
                    print("✅ Background sync completed successfully")
                    completionHandler(.newData)
                } else {
                    print("⚠️ DataManager not available")
                    completionHandler(.noData)
                }
            } catch {
                print("❌ Background sync failed: \(error.localizedDescription)")
                completionHandler(.failed)
            }
        }
    }

    // MARK: - UNUserNotificationCenterDelegate

    /// Handle notification when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        print("🔔 Notification received while app in foreground")

        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }

    /// Handle notification tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo

        print("👆 User tapped notification")
        print("   Action: \(response.actionIdentifier)")

        // Extract task information
        guard let taskID = userInfo["taskID"] as? String else {
            print("⚠️ No taskID in notification")
            completionHandler()
            return
        }

        print("   Task ID: \(taskID)")

        // Handle different actions
        switch response.actionIdentifier {
        case "COMPLETE_ACTION":
            handleCompleteAction(taskID: taskID)

        case "SNOOZE_ACTION":
            handleSnoozeAction(taskID: taskID)

        case "VIEW_ACTION", UNNotificationDefaultActionIdentifier:
            handleViewAction(taskID: taskID)

        case UNNotificationDismissActionIdentifier:
            print("   User dismissed notification")

        default:
            print("   Unknown action: \(response.actionIdentifier)")
        }

        completionHandler()
    }

    // MARK: - Notification Action Handlers

    private func handleCompleteAction(taskID: String) {
        print("✅ Completing task: \(taskID)")

        Task {
            do {
                guard let dataManager = await dataManager else { return }

                // Fetch task
                let descriptor = FetchDescriptor<Task>(
                    predicate: #Predicate { $0.id == taskID }
                )
                let tasks = try await dataManager.fetch(descriptor)

                guard let task = tasks.first else {
                    print("⚠️ Task not found: \(taskID)")
                    return
                }

                // Mark as completed
                task.isCompleted = true
                task.completedAt = Date()
                task.updatedAt = Date()
                task.syncStatus = .pending

                try await dataManager.save()

                // Cancel notifications
                let notificationService = await dataManager.getNotificationService()
                await notificationService.cancelNotifications(for: task)

                // Trigger sync
                let syncService = await dataManager.getSyncService()
                try? await syncService.syncAll()

                print("✅ Task completed: \(task.title)")

            } catch {
                print("❌ Error completing task: \(error.localizedDescription)")
            }
        }
    }

    private func handleSnoozeAction(taskID: String) {
        print("⏰ Snoozing task: \(taskID)")

        Task {
            do {
                guard let dataManager = await dataManager else { return }

                // Fetch task
                let descriptor = FetchDescriptor<Task>(
                    predicate: #Predicate { $0.id == taskID }
                )
                let tasks = try await dataManager.fetch(descriptor)

                guard let task = tasks.first else {
                    print("⚠️ Task not found: \(taskID)")
                    return
                }

                // Snooze for 1 hour
                let notificationService = await dataManager.getNotificationService()
                if let newID = await notificationService.snoozeNotification(for: task, duration: 3600) {
                    task.notificationID = newID
                    task.syncStatus = .pending
                    try await dataManager.save()

                    print("⏰ Task snoozed: \(task.title)")
                }

            } catch {
                print("❌ Error snoozing task: \(error.localizedDescription)")
            }
        }
    }

    private func handleViewAction(taskID: String) {
        print("👁️ Viewing task: \(taskID)")

        // Post notification for view to handle navigation
        NotificationCenter.default.post(
            name: NSNotification.Name("NavigateToTask"),
            object: nil,
            userInfo: ["taskID": taskID]
        )
    }

    // MARK: - Background Fetch

    func applicationDidEnterBackground(_ application: UIApplication) {
        print("📴 App entered background")

        // Save any pending changes
        Task {
            try? await dataManager?.save()
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        print("📱 App will enter foreground")

        // Trigger sync when app returns to foreground
        Task {
            do {
                if let syncService = await dataManager?.getSyncService() {
                    try await syncService.syncAll()
                    print("✅ Foreground sync completed")
                }

                // Process offline queue
                if let syncQueue = await dataManager?.getSyncQueue(),
                   let syncService = await dataManager?.getSyncService() {
                    await syncQueue.processQueue(syncService: syncService)
                }
            } catch {
                print("⚠️ Foreground sync failed: \(error.localizedDescription)")
            }
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        print("💀 App will terminate")

        // Save any pending changes
        Task {
            try? await dataManager?.save()
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let navigateToTask = Notification.Name("NavigateToTask")
    static let syncCompleted = Notification.Name("SyncCompleted")
    static let syncFailed = Notification.Name("SyncFailed")
}
