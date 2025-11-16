//
//  AppDelegate.swift
//  ToDo-Appy
//
//  Created by Agent 1: Foundation & Setup Specialist
//  Purpose: Handle CloudKit notifications and app lifecycle events
//

import UIKit
import CloudKit

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Register for remote notifications to receive CloudKit updates
        application.registerForRemoteNotifications()

        print("✅ AppDelegate: Registered for remote notifications")
        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        print("✅ AppDelegate: Successfully registered for remote notifications")
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("❌ AppDelegate: Failed to register for remote notifications: \(error.localizedDescription)")
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        // CloudKit silent notifications come through here
        // Check if this is a CloudKit notification
        if let notification = CKNotification(fromRemoteNotificationDictionary: userInfo) {
            print("📩 AppDelegate: Received CloudKit notification: \(notification.notificationType.rawValue)")

            // TODO: Agent 3 will implement DataSyncService
            // For now, just acknowledge the notification
            // Future implementation:
            // dataSyncService.handleRemoteNotification(notification)

            completionHandler(.newData)
        } else {
            completionHandler(.noData)
        }
    }
}
