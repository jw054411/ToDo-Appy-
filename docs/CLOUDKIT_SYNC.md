# CloudKit Synchronization Strategy

## Overview

This document details the complete CloudKit synchronization implementation for ToDo Appy, including setup, real-time sync, conflict resolution, and error handling strategies.

## CloudKit Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                        User's Device                         │
│  ┌────────────────────────────────────────────────────────┐  │
│  │                Local SwiftData Store                   │  │
│  └────────────────┬───────────────────────────────────────┘  │
│                   │                                          │
│  ┌────────────────┴───────────────────────────────────────┐  │
│  │              DataSyncService (Actor)                   │  │
│  │  • Manages sync operations                             │  │
│  │  • Handles conflicts                                   │  │
│  │  • Queues failed operations                            │  │
│  └────────────────┬───────────────────────────────────────┘  │
└───────────────────┼──────────────────────────────────────────┘
                    │
                    │ HTTPS (TLS 1.3)
                    │
┌───────────────────┼──────────────────────────────────────────┐
│                   ▼         iCloud                           │
│  ┌──────────────────────────────────────────────────────┐   │
│  │      Private CloudKit Database Container            │   │
│  │                                                      │   │
│  │  ┌─────────────┐  ┌──────────────┐  ┌───────────┐  │   │
│  │  │   Task      │  │   Category   │  │    Tag    │  │   │
│  │  │   Zone      │  │    Zone      │  │   Zone    │  │   │
│  │  └─────────────┘  └──────────────┘  └───────────┘  │   │
│  │                                                      │   │
│  │  Change Notifications (Push/Silent Push)            │   │
│  └──────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────┘
                    │
                    │ Push Notifications
                    │
┌───────────────────▼──────────────────────────────────────────┐
│              Other User Devices                              │
│  iPhone, iPad, Mac                                           │
└──────────────────────────────────────────────────────────────┘
```

## CloudKit Setup

### 1. Container Configuration

**Container ID:** `iCloud.com.personal.todoappy`

**Capabilities Required:**
- iCloud
- Push Notifications
- Background Modes (Background fetch, Remote notifications)

### 2. Database Structure

We use the **Private Database** for all user data:
- Automatic authentication via iCloud account
- User-specific data isolation
- No need for custom user management
- Free tier sufficient for personal use

### 3. Custom Zone Setup

Create custom zones for better sync control:

```swift
import CloudKit

class CloudKitSetupService {
    private let container: CKContainer
    private let privateDatabase: CKDatabase

    // Custom zones for each record type
    let taskZoneID = CKRecordZone.ID(zoneName: "Tasks", ownerName: CKCurrentUserDefaultName)
    let categoryZoneID = CKRecordZone.ID(zoneName: "Categories", ownerName: CKCurrentUserDefaultName)
    let tagZoneID = CKRecordZone.ID(zoneName: "Tags", ownerName: CKCurrentUserDefaultName)

    init() {
        self.container = CKContainer(identifier: "iCloud.com.personal.todoappy")
        self.privateDatabase = container.privateCloudDatabase
    }

    func setupCloudKit() async throws {
        // Check iCloud account status
        let status = try await container.accountStatus()
        guard status == .available else {
            throw CloudKitError.iCloudUnavailable
        }

        // Create custom zones
        try await createCustomZones()

        // Set up subscriptions
        try await setupSubscriptions()

        // Initial sync
        try await performInitialSync()
    }

    private func createCustomZones() async throws {
        let zones = [
            CKRecordZone(zoneID: taskZoneID),
            CKRecordZone(zoneID: categoryZoneID),
            CKRecordZone(zoneID: tagZoneID)
        ]

        let (savedZones, _) = try await privateDatabase.modifyRecordZones(
            saving: zones,
            deleting: []
        )

        print("Created zones: \(savedZones.map { $0.zoneID.zoneName })")
    }

    private func setupSubscriptions() async throws {
        // Create subscriptions for each zone
        try await createSubscription(for: taskZoneID, recordType: "Task")
        try await createSubscription(for: categoryZoneID, recordType: "Category")
        try await createSubscription(for: tagZoneID, recordType: "Tag")
    }

    private func createSubscription(
        for zoneID: CKRecordZone.ID,
        recordType: String
    ) async throws {
        let subscription = CKRecordZoneSubscription(
            zoneID: zoneID,
            subscriptionID: "\(recordType)Subscription"
        )

        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notificationInfo

        do {
            _ = try await privateDatabase.save(subscription)
            print("Created subscription for \(recordType)")
        } catch let error as CKError where error.code == .serverRejectedRequest {
            // Subscription already exists
            print("Subscription for \(recordType) already exists")
        }
    }

    private func performInitialSync() async throws {
        // Fetch all existing records from CloudKit
        // This is called on first launch
        print("Performing initial sync...")
        // Implementation in DataSyncService
    }
}

enum CloudKitError: LocalizedError {
    case iCloudUnavailable
    case accountNotAvailable
    case networkUnavailable
    case quotaExceeded
    case unknownError(Error)

    var errorDescription: String? {
        switch self {
        case .iCloudUnavailable:
            return "iCloud is not available. Please sign in to iCloud in Settings."
        case .accountNotAvailable:
            return "iCloud account is not available."
        case .networkUnavailable:
            return "Network is unavailable. Changes will sync when online."
        case .quotaExceeded:
            return "iCloud storage quota exceeded."
        case .unknownError(let error):
            return "An error occurred: \(error.localizedDescription)"
        }
    }
}
```

## Sync Service Implementation

### Core Sync Service

```swift
import CloudKit
import SwiftData
import OSLog

actor DataSyncService {
    private let container: CKContainer
    private let privateDatabase: CKDatabase
    private let modelContext: ModelContext
    private let logger = Logger(subsystem: "com.personal.todoappy", category: "Sync")

    private let taskZoneID = CKRecordZone.ID(zoneName: "Tasks", ownerName: CKCurrentUserDefaultName)
    private let categoryZoneID = CKRecordZone.ID(zoneName: "Categories", ownerName: CKCurrentUserDefaultName)
    private let tagZoneID = CKRecordZone.ID(zoneName: "Tags", ownerName: CKCurrentUserDefaultName)

    // Change tokens for delta sync
    private var taskChangeToken: CKServerChangeToken?
    private var categoryChangeToken: CKServerChangeToken?
    private var tagChangeToken: CKServerChangeToken?

    // Sync queue for failed operations
    private var syncQueue: SyncQueue

    init(container: CKContainer, modelContext: ModelContext) {
        self.container = container
        self.privateDatabase = container.privateCloudDatabase
        self.modelContext = modelContext
        self.syncQueue = SyncQueue()

        // Load change tokens from UserDefaults
        loadChangeTokens()
    }

    // MARK: - Upload to CloudKit

    func syncToCloud(_ task: Task) async throws {
        guard task.syncStatus != .syncing else { return }

        task.syncStatus = .syncing

        do {
            let record = task.toCloudKitRecord(zoneID: taskZoneID)
            let savedRecord = try await privateDatabase.save(record)

            task.cloudKitRecordID = savedRecord.recordID.recordName
            task.lastSyncedAt = Date()
            task.syncStatus = .synced

            try modelContext.save()
            logger.info("Synced task to cloud: \(task.title)")

        } catch {
            task.syncStatus = .error
            logger.error("Failed to sync task: \(error.localizedDescription)")

            // Add to retry queue
            await syncQueue.enqueue(.init(
                id: UUID(),
                type: .update,
                recordID: task.id.uuidString,
                timestamp: Date(),
                retryCount: 0,
                lastError: error
            ))

            throw error
        }
    }

    func syncCategory(_ category: Category) async throws {
        guard category.syncStatus != .syncing else { return }

        category.syncStatus = .syncing

        do {
            let record = category.toCloudKitRecord(zoneID: categoryZoneID)
            let savedRecord = try await privateDatabase.save(record)

            category.cloudKitRecordID = savedRecord.recordID.recordName
            category.lastSyncedAt = Date()
            category.syncStatus = .synced

            try modelContext.save()
            logger.info("Synced category to cloud: \(category.name)")

        } catch {
            category.syncStatus = .error
            logger.error("Failed to sync category: \(error.localizedDescription)")
            throw error
        }
    }

    func syncTag(_ tag: Tag) async throws {
        guard tag.syncStatus != .syncing else { return }

        tag.syncStatus = .syncing

        do {
            let record = tag.toCloudKitRecord(zoneID: tagZoneID)
            let savedRecord = try await privateDatabase.save(record)

            tag.cloudKitRecordID = savedRecord.recordID.recordName
            tag.lastSyncedAt = Date()
            tag.syncStatus = .synced

            try modelContext.save()
            logger.info("Synced tag to cloud: \(tag.name)")

        } catch {
            tag.syncStatus = .error
            logger.error("Failed to sync tag: \(error.localizedDescription)")
            throw error
        }
    }

    // MARK: - Batch Upload

    func batchSyncToCloud() async throws {
        logger.info("Starting batch sync to cloud")

        // Fetch all pending tasks, categories, and tags
        let taskDescriptor = FetchDescriptor<Task>(
            predicate: #Predicate { $0.syncStatusRawValue == "pending" || $0.syncStatusRawValue == "error" }
        )
        let categoryDescriptor = FetchDescriptor<Category>(
            predicate: #Predicate { $0.syncStatusRawValue == "pending" || $0.syncStatusRawValue == "error" }
        )
        let tagDescriptor = FetchDescriptor<Tag>(
            predicate: #Predicate { $0.syncStatusRawValue == "pending" || $0.syncStatusRawValue == "error" }
        )

        let tasks = try modelContext.fetch(taskDescriptor)
        let categories = try modelContext.fetch(categoryDescriptor)
        let tags = try modelContext.fetch(tagDescriptor)

        // Sync categories first (tasks depend on them)
        for category in categories {
            try await syncCategory(category)
        }

        // Sync tags
        for tag in tags {
            try await syncTag(tag)
        }

        // Sync tasks
        for task in tasks {
            try await syncToCloud(task)
        }

        logger.info("Batch sync completed: \(tasks.count) tasks, \(categories.count) categories, \(tags.count) tags")
    }

    // MARK: - Download from CloudKit

    func syncFromCloud() async throws {
        logger.info("Starting sync from cloud")

        // Sync each record type
        try await syncCategoriesFromCloud()
        try await syncTagsFromCloud()
        try await syncTasksFromCloud()

        logger.info("Sync from cloud completed")
    }

    private func syncTasksFromCloud() async throws {
        let config = CKFetchRecordZoneChangesOperation.ZoneConfiguration()
        config.previousServerChangeToken = taskChangeToken

        let operation = CKFetchRecordZoneChangesOperation(
            recordZoneIDs: [taskZoneID],
            configurationsByRecordZoneID: [taskZoneID: config]
        )

        var changedRecords: [CKRecord] = []
        var deletedRecordIDs: [CKRecord.ID] = []
        var newChangeToken: CKServerChangeToken?

        operation.recordWasChangedBlock = { _, result in
            switch result {
            case .success(let record):
                changedRecords.append(record)
            case .failure(let error):
                self.logger.error("Failed to fetch record: \(error.localizedDescription)")
            }
        }

        operation.recordWithIDWasDeletedBlock = { recordID, _ in
            deletedRecordIDs.append(recordID)
        }

        operation.recordZoneChangeTokensUpdatedBlock = { _, token, _ in
            newChangeToken = token
        }

        operation.recordZoneFetchResultBlock = { _, result in
            switch result {
            case .success((let token, _, _)):
                newChangeToken = token
            case .failure(let error):
                self.logger.error("Zone fetch failed: \(error.localizedDescription)")
            }
        }

        try await privateDatabase.add(operation)

        // Process changed records
        for record in changedRecords {
            try await processTaskRecord(record)
        }

        // Process deleted records
        for recordID in deletedRecordIDs {
            try await processDeletedTask(recordID)
        }

        // Save new change token
        if let newChangeToken = newChangeToken {
            taskChangeToken = newChangeToken
            saveChangeTokens()
        }
    }

    private func syncCategoriesFromCloud() async throws {
        let config = CKFetchRecordZoneChangesOperation.ZoneConfiguration()
        config.previousServerChangeToken = categoryChangeToken

        let operation = CKFetchRecordZoneChangesOperation(
            recordZoneIDs: [categoryZoneID],
            configurationsByRecordZoneID: [categoryZoneID: config]
        )

        var changedRecords: [CKRecord] = []
        var deletedRecordIDs: [CKRecord.ID] = []
        var newChangeToken: CKServerChangeToken?

        operation.recordWasChangedBlock = { _, result in
            switch result {
            case .success(let record):
                changedRecords.append(record)
            case .failure(let error):
                self.logger.error("Failed to fetch category: \(error.localizedDescription)")
            }
        }

        operation.recordWithIDWasDeletedBlock = { recordID, _ in
            deletedRecordIDs.append(recordID)
        }

        operation.recordZoneChangeTokensUpdatedBlock = { _, token, _ in
            newChangeToken = token
        }

        try await privateDatabase.add(operation)

        // Process changed records
        for record in changedRecords {
            try await processCategoryRecord(record)
        }

        // Process deleted records
        for recordID in deletedRecordIDs {
            try await processDeletedCategory(recordID)
        }

        // Save new change token
        if let newChangeToken = newChangeToken {
            categoryChangeToken = newChangeToken
            saveChangeTokens()
        }
    }

    private func syncTagsFromCloud() async throws {
        let config = CKFetchRecordZoneChangesOperation.ZoneConfiguration()
        config.previousServerChangeToken = tagChangeToken

        let operation = CKFetchRecordZoneChangesOperation(
            recordZoneIDs: [tagZoneID],
            configurationsByRecordZoneID: [tagZoneID: config]
        )

        var changedRecords: [CKRecord] = []
        var deletedRecordIDs: [CKRecord.ID] = []
        var newChangeToken: CKServerChangeToken?

        operation.recordWasChangedBlock = { _, result in
            switch result {
            case .success(let record):
                changedRecords.append(record)
            case .failure(let error):
                self.logger.error("Failed to fetch tag: \(error.localizedDescription)")
            }
        }

        operation.recordWithIDWasDeletedBlock = { recordID, _ in
            deletedRecordIDs.append(recordID)
        }

        operation.recordZoneChangeTokensUpdatedBlock = { _, token, _ in
            newChangeToken = token
        }

        try await privateDatabase.add(operation)

        // Process changed records
        for record in changedRecords {
            try await processTagRecord(record)
        }

        // Process deleted records
        for recordID in deletedRecordIDs {
            try await processDeletedTag(recordID)
        }

        // Save new change token
        if let newChangeToken = newChangeToken {
            tagChangeToken = newChangeToken
            saveChangeTokens()
        }
    }

    // MARK: - Record Processing

    private func processTaskRecord(_ record: CKRecord) async throws {
        let recordID = record["id"] as? String ?? record.recordID.recordName

        // Check if task exists locally
        let descriptor = FetchDescriptor<Task>(
            predicate: #Predicate { $0.id.uuidString == recordID }
        )

        let existingTasks = try modelContext.fetch(descriptor)

        if let existingTask = existingTasks.first {
            // Task exists - check for conflict
            let localUpdated = existingTask.updatedAt
            let remoteUpdated = record["updatedAt"] as? Date ?? Date.distantPast

            if remoteUpdated > localUpdated {
                // Remote is newer - update local
                existingTask.updateFromCloudKit(record)
                logger.info("Updated local task from cloud: \(existingTask.title)")
            } else if localUpdated > remoteUpdated && existingTask.syncStatus == .pending {
                // Local is newer and pending - upload to cloud
                try await syncToCloud(existingTask)
                logger.info("Local task is newer, synced to cloud: \(existingTask.title)")
            } else {
                // Already in sync
                existingTask.syncStatus = .synced
                logger.debug("Task already in sync: \(existingTask.title)")
            }
        } else {
            // New task from cloud - create locally
            let newTask = CloudKitTransformer.createTask(from: record, context: modelContext)
            logger.info("Created new task from cloud: \(newTask.title)")
        }

        try modelContext.save()
    }

    private func processCategoryRecord(_ record: CKRecord) async throws {
        let recordID = record["id"] as? String ?? record.recordID.recordName

        let descriptor = FetchDescriptor<Category>(
            predicate: #Predicate { $0.id.uuidString == recordID }
        )

        let existing = try modelContext.fetch(descriptor)

        if let existingCategory = existing.first {
            existingCategory.updateFromCloudKit(record)
            logger.info("Updated category from cloud: \(existingCategory.name)")
        } else {
            let newCategory = CloudKitTransformer.createCategory(from: record, context: modelContext)
            logger.info("Created new category from cloud: \(newCategory.name)")
        }

        try modelContext.save()
    }

    private func processTagRecord(_ record: CKRecord) async throws {
        let recordID = record["id"] as? String ?? record.recordID.recordName

        let descriptor = FetchDescriptor<Tag>(
            predicate: #Predicate { $0.id.uuidString == recordID }
        )

        let existing = try modelContext.fetch(descriptor)

        if let existingTag = existing.first {
            existingTag.updateFromCloudKit(record)
            logger.info("Updated tag from cloud: \(existingTag.name)")
        } else {
            let newTag = CloudKitTransformer.createTag(from: record, context: modelContext)
            logger.info("Created new tag from cloud: \(newTag.name)")
        }

        try modelContext.save()
    }

    private func processDeletedTask(_ recordID: CKRecord.ID) async throws {
        let descriptor = FetchDescriptor<Task>(
            predicate: #Predicate { $0.cloudKitRecordID == recordID.recordName }
        )

        let tasks = try modelContext.fetch(descriptor)

        for task in tasks {
            modelContext.delete(task)
            logger.info("Deleted task from local store: \(task.title)")
        }

        try modelContext.save()
    }

    private func processDeletedCategory(_ recordID: CKRecord.ID) async throws {
        let descriptor = FetchDescriptor<Category>(
            predicate: #Predicate { $0.cloudKitRecordID == recordID.recordName }
        )

        let categories = try modelContext.fetch(descriptor)

        for category in categories {
            modelContext.delete(category)
            logger.info("Deleted category from local store: \(category.name)")
        }

        try modelContext.save()
    }

    private func processDeletedTag(_ recordID: CKRecord.ID) async throws {
        let descriptor = FetchDescriptor<Tag>(
            predicate: #Predicate { $0.cloudKitRecordID == recordID.recordName }
        )

        let tags = try modelContext.fetch(descriptor)

        for tag in tags {
            modelContext.delete(tag)
            logger.info("Deleted tag from local store: \(tag.name)")
        }

        try modelContext.save()
    }

    // MARK: - Change Token Management

    private func loadChangeTokens() {
        if let data = UserDefaults.standard.data(forKey: "taskChangeToken"),
           let token = try? NSKeyedUnarchiver.unarchivedObject(
               ofClass: CKServerChangeToken.self,
               from: data
           ) {
            taskChangeToken = token
        }

        if let data = UserDefaults.standard.data(forKey: "categoryChangeToken"),
           let token = try? NSKeyedUnarchiver.unarchivedObject(
               ofClass: CKServerChangeToken.self,
               from: data
           ) {
            categoryChangeToken = token
        }

        if let data = UserDefaults.standard.data(forKey: "tagChangeToken"),
           let token = try? NSKeyedUnarchiver.unarchivedObject(
               ofClass: CKServerChangeToken.self,
               from: data
           ) {
            tagChangeToken = token
        }
    }

    private func saveChangeTokens() {
        if let token = taskChangeToken,
           let data = try? NSKeyedArchiver.archivedData(
               withRootObject: token,
               requiringSecureCoding: true
           ) {
            UserDefaults.standard.set(data, forKey: "taskChangeToken")
        }

        if let token = categoryChangeToken,
           let data = try? NSKeyedArchiver.archivedData(
               withRootObject: token,
               requiringSecureCoding: true
           ) {
            UserDefaults.standard.set(data, forKey: "categoryChangeToken")
        }

        if let token = tagChangeToken,
           let data = try? NSKeyedArchiver.archivedData(
               withRootObject: token,
               requiringSecureCoding: true
           ) {
            UserDefaults.standard.set(data, forKey: "tagChangeToken")
        }
    }

    // MARK: - Push Notification Handling

    func handleRemoteNotification(_ userInfo: [AnyHashable: Any]) async throws {
        guard let notification = CKNotification(fromRemoteNotificationDictionary: userInfo) else {
            return
        }

        guard notification.notificationType == .recordZone else {
            return
        }

        logger.info("Received CloudKit notification, syncing from cloud")
        try await syncFromCloud()
    }
}
```

## Conflict Resolution

### Strategy: Last-Write-Wins with Timestamp

```swift
extension DataSyncService {
    func resolveConflict(local: Task, remote: CKRecord) async throws -> Task {
        let localUpdated = local.updatedAt
        let remoteUpdated = remote["updatedAt"] as? Date ?? Date.distantPast

        if remoteUpdated > localUpdated {
            // Remote wins
            local.updateFromCloudKit(remote)
            logger.info("Conflict resolved: Remote version accepted for \(local.title)")
            return local
        } else {
            // Local wins - sync to cloud
            try await syncToCloud(local)
            logger.info("Conflict resolved: Local version accepted for \(local.title)")
            return local
        }
    }
}
```

### Alternative: User Choice (Future Enhancement)

```swift
struct ConflictResolution {
    let local: Task
    let remote: CKRecord
    let strategy: ResolutionStrategy

    enum ResolutionStrategy {
        case useLocal
        case useRemote
        case merge
        case askUser
    }

    func resolve() async throws -> Task {
        switch strategy {
        case .useLocal:
            return local
        case .useRemote:
            local.updateFromCloudKit(remote)
            return local
        case .merge:
            return try await mergeChanges()
        case .askUser:
            // Present UI to user
            return try await presentConflictUI()
        }
    }

    private func mergeChanges() async throws -> Task {
        // Custom merge logic
        // Example: Keep latest values for each field
        if let remoteTitle = remote["title"] as? String,
           let remoteUpdated = remote["updatedAt"] as? Date,
           remoteUpdated > local.updatedAt {
            local.title = remoteTitle
        }

        // Merge tags
        if let remoteTagIDs = remote["tagIDs"] as? [String] {
            // Combine local and remote tags
        }

        return local
    }
}
```

## Sync Queue for Offline Support

```swift
actor SyncQueue {
    private var operations: [SyncOperation] = []
    private let maxRetries = 5
    private let logger = Logger(subsystem: "com.personal.todoappy", category: "SyncQueue")

    func enqueue(_ operation: SyncOperation) {
        operations.append(operation)
        logger.info("Enqueued sync operation: \(operation.id)")
        saveQueue()
    }

    func processQueue(with syncService: DataSyncService) async {
        guard !operations.isEmpty else { return }

        logger.info("Processing \(operations.count) queued operations")

        var processedIDs: [UUID] = []

        for operation in operations {
            do {
                try await process(operation, with: syncService)
                processedIDs.append(operation.id)
                logger.info("Successfully processed operation: \(operation.id)")
            } catch {
                logger.error("Failed to process operation: \(error.localizedDescription)")

                if operation.retryCount >= maxRetries {
                    // Max retries reached, remove from queue
                    processedIDs.append(operation.id)
                    logger.error("Max retries reached for operation: \(operation.id)")
                } else {
                    // Increment retry count
                    if let index = operations.firstIndex(where: { $0.id == operation.id }) {
                        operations[index].retryCount += 1
                        operations[index].lastError = error
                    }
                }
            }
        }

        // Remove processed operations
        operations.removeAll { processedIDs.contains($0.id) }
        saveQueue()
    }

    private func process(_ operation: SyncOperation, with syncService: DataSyncService) async throws {
        // Fetch the record and sync based on operation type
        // Implementation depends on operation type
    }

    private func saveQueue() {
        // Persist queue to UserDefaults or file
        if let encoded = try? JSONEncoder().encode(operations) {
            UserDefaults.standard.set(encoded, forKey: "syncQueue")
        }
    }

    private func loadQueue() {
        if let data = UserDefaults.standard.data(forKey: "syncQueue"),
           let decoded = try? JSONDecoder().decode([SyncOperation].self, from: data) {
            operations = decoded
        }
    }
}

struct SyncOperation: Codable {
    let id: UUID
    let type: OperationType
    let recordID: String
    let timestamp: Date
    var retryCount: Int
    var lastError: Error?

    enum OperationType: String, Codable {
        case create
        case update
        case delete
    }

    enum CodingKeys: String, CodingKey {
        case id, type, recordID, timestamp, retryCount
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(recordID, forKey: .recordID)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(retryCount, forKey: .retryCount)
    }
}
```

## Background Sync

### App Delegate Setup

```swift
import UIKit
import CloudKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Register for remote notifications
        application.registerForRemoteNotifications()
        return true
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        Task {
            do {
                // Handle CloudKit notification
                let syncService = DataSyncService(
                    container: CKContainer.default(),
                    modelContext: // Get from environment
                )
                try await syncService.handleRemoteNotification(userInfo)
                completionHandler(.newData)
            } catch {
                completionHandler(.failed)
            }
        }
    }
}
```

## Performance Optimizations

### 1. Batch Operations

```swift
func batchUpload(_ tasks: [Task]) async throws {
    let records = tasks.map { $0.toCloudKitRecord(zoneID: taskZoneID) }

    // CloudKit supports up to 400 records per batch
    let batchSize = 400
    let batches = stride(from: 0, to: records.count, by: batchSize).map {
        Array(records[$0..<min($0 + batchSize, records.count)])
    }

    for batch in batches {
        let (saved, _) = try await privateDatabase.modifyRecords(
            saving: batch,
            deleting: []
        )

        // Update local records with CloudKit IDs
        for record in saved {
            if let task = tasks.first(where: { $0.id.uuidString == record["id"] as? String }) {
                task.cloudKitRecordID = record.recordID.recordName
                task.syncStatus = .synced
            }
        }
    }
}
```

### 2. Incremental Sync

Always use change tokens to fetch only new/modified records since last sync.

### 3. Concurrent Operations

```swift
func syncAllToCloud() async throws {
    async let taskSync = batchSyncTasksToCloud()
    async let categorySync = batchSyncCategoriesToCloud()
    async let tagSync = batchSyncTagsToCloud()

    try await (taskSync, categorySync, tagSync)
}
```

## Testing Sync

### Unit Tests

```swift
import XCTest
@testable import ToDoAppy

class SyncTests: XCTestCase {
    func testLocalToCloudSync() async throws {
        // Create local task
        // Sync to cloud
        // Verify record exists in CloudKit
    }

    func testCloudToLocalSync() async throws {
        // Create CloudKit record
        // Trigger sync
        // Verify local task exists
    }

    func testConflictResolution() async throws {
        // Create task locally and remotely with different timestamps
        // Trigger sync
        // Verify correct version won
    }

    func testOfflineQueue() async throws {
        // Disable network
        // Create tasks
        // Re-enable network
        // Verify tasks synced
    }
}
```

### Integration Tests

Test with actual CloudKit development environment.

## Monitoring & Debugging

### CloudKit Dashboard

Monitor sync activity in CloudKit Dashboard:
- View record counts
- Check subscription status
- Inspect individual records
- View operation logs

### Logging

```swift
// Enable CloudKit verbose logging
UserDefaults.standard.set(true, forKey: "com.apple.coredata.cloudkit.verbose")
```

---

**Last Updated:** 2025-11-15
