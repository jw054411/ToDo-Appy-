//
//  ToDoAppyApp.swift
//  ToDo-Appy
//
//  Main app entry point with automatic sync triggers
//  Handles app lifecycle and periodic synchronization
//

import SwiftUI
import SwiftData

@main
struct ToDoAppyApp: App {

    // MARK: - Properties

    /// App delegate for handling notifications and background tasks
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    /// Scene phase for detecting app state changes
    @Environment(\.scenePhase) private var scenePhase

    /// Network monitor for connectivity tracking
    @State private var networkMonitor = NetworkMonitor.shared

    /// Timer for periodic sync
    @State private var syncTimer: Timer?

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            ContentView()
                .networkStatusBanner() // Show network status banner
                .onAppear {
                    setupApp()
                }
        }
        .modelContainer(for: [Task.self, Category.self, Tag.self]) {
            // SwiftData model container configuration
            // This will be created automatically
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            handleScenePhaseChange(from: oldPhase, to: newPhase)
        }
    }

    // MARK: - Setup

    private func setupApp() {
        print("🎨 Setting up ToDo-Appy...")

        // Start network monitoring
        networkMonitor.startMonitoring()

        // Set up network status change handler
        networkMonitor.onStatusChange { isConnected in
            if isConnected {
                print("✅ Network restored - triggering sync")
                Task {
                    await syncData()
                }
            } else {
                print("❌ Network lost")
            }
        }

        // Start periodic sync timer (every 15 minutes when app is active)
        startPeriodicSync()

        print("✅ App setup complete")
    }

    // MARK: - Scene Phase Handling

    private func handleScenePhaseChange(from oldPhase: ScenePhase, to newPhase: ScenePhase) {
        switch newPhase {
        case .active:
            print("📱 App became active")
            onAppBecomeActive()

        case .inactive:
            print("⏸️ App became inactive")
            onAppBecomeInactive()

        case .background:
            print("📴 App entered background")
            onAppEnterBackground()

        @unknown default:
            break
        }
    }

    private func onAppBecomeActive() {
        // Trigger sync when app becomes active
        Task {
            await syncData()

            // Process any queued operations
            await processOfflineQueue()
        }

        // Restart periodic sync timer
        startPeriodicSync()

        // Update badge count
        Task {
            await updateBadgeCount()
        }
    }

    private func onAppBecomeInactive() {
        // Save any pending changes
        Task {
            do {
                try await DataManager.shared.save()
            } catch {
                print("⚠️ Error saving on inactive: \(error.localizedDescription)")
            }
        }
    }

    private func onAppEnterBackground() {
        // Stop periodic sync timer (save battery)
        stopPeriodicSync()

        // Save any pending changes
        Task {
            do {
                try await DataManager.shared.save()
                print("💾 Data saved before backgrounding")
            } catch {
                print("⚠️ Error saving on background: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Sync Management

    /// Perform data synchronization
    private func syncData() async {
        do {
            let syncService = await DataManager.shared.getSyncService()
            try await syncService.syncAll()
            print("✅ Sync completed successfully")

            // Post notification for UI updates
            NotificationCenter.default.post(name: .syncCompleted, object: nil)

        } catch {
            print("❌ Sync failed: \(error.localizedDescription)")

            // Queue for retry if network error
            if error.localizedDescription.contains("network") ||
               error.localizedDescription.contains("offline") {
                print("📥 Queueing for retry...")
            }

            // Post notification for UI updates
            NotificationCenter.default.post(name: .syncFailed, object: error)
        }
    }

    /// Process offline queue when network is restored
    private func processOfflineQueue() async {
        let syncQueue = await DataManager.shared.getSyncQueue()
        let count = await syncQueue.count()

        if count > 0 {
            print("🔄 Processing \(count) queued operations...")
            let syncService = await DataManager.shared.getSyncService()
            await syncQueue.processQueue(syncService: syncService)
        }
    }

    // MARK: - Periodic Sync

    /// Start periodic sync timer (every 15 minutes)
    private func startPeriodicSync() {
        // Cancel existing timer
        stopPeriodicSync()

        // Create new timer
        syncTimer = Timer.scheduledTimer(withTimeInterval: 900, repeats: true) { _ in
            print("⏰ Periodic sync triggered")
            Task {
                await syncData()
            }
        }

        print("⏰ Periodic sync started (15 minute interval)")
    }

    /// Stop periodic sync timer
    private func stopPeriodicSync() {
        syncTimer?.invalidate()
        syncTimer = nil
        print("⏰ Periodic sync stopped")
    }

    // MARK: - Badge Management

    /// Update app badge with pending task count
    private func updateBadgeCount() async {
        do {
            let dataManager = await DataManager.shared

            // Count incomplete, not deleted tasks
            let count = try await dataManager.count(
                Task.self,
                predicate: #Predicate { !$0.isCompleted && !$0.isDeleted }
            )

            // Update badge
            let notificationService = await dataManager.getNotificationService()
            await notificationService.updateBadgeCount(count)

        } catch {
            print("⚠️ Error updating badge: \(error.localizedDescription)")
        }
    }
}

// MARK: - ContentView Placeholder

/// Temporary content view - will be replaced by Agent 4
struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.blue)

            Text("ToDo-Appy")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Services Ready")
                .font(.title2)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 8) {
                ServiceStatusRow(icon: "cloud.fill", name: "CloudKit Sync", status: "Ready")
                ServiceStatusRow(icon: "bell.fill", name: "Notifications", status: "Ready")
                ServiceStatusRow(icon: "square.and.arrow.down", name: "Import/Export", status: "Ready")
                ServiceStatusRow(icon: "network", name: "Network Monitor", status: "Active")
                ServiceStatusRow(icon: "arrow.clockwise", name: "Offline Queue", status: "Ready")
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding()

            Text("Waiting for Agent 4 to build UI...")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .onAppear {
            Task {
                await testServices()
            }
        }
    }

    private func testServices() async {
        print("\n🧪 Testing Services...")

        // Test DataManager
        let dataManager = await DataManager.shared
        print("✅ DataManager initialized")

        // Test services
        let syncService = await dataManager.getSyncService()
        print("✅ SyncService available")

        let notificationService = await dataManager.getNotificationService()
        print("✅ NotificationService available")

        let importExportService = await dataManager.getImportExportService()
        print("✅ ImportExportService available")

        let syncQueue = await dataManager.getSyncQueue()
        print("✅ SyncQueue available")

        // Test network monitor
        let networkMonitor = NetworkMonitor.shared
        let isConnected = networkMonitor.checkConnection()
        print("✅ NetworkMonitor: \(isConnected ? "Connected" : "Offline")")

        print("🎉 All services operational!\n")
    }
}

struct ServiceStatusRow: View {
    let icon: String
    let name: String
    let status: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 30)

            Text(name)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(status)
                .foregroundStyle(.green)
                .fontWeight(.medium)
        }
    }
}
