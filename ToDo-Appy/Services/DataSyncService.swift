//
//  DataSyncService.swift
//  ToDo-Appy
//
//  Core CloudKit synchronization service
//  Handles bidirectional sync, conflict resolution, and data safety
//

import CloudKit
import SwiftData
import Foundation

/// Actor-based sync service ensuring thread-safe CloudKit operations
actor DataSyncService {
    // MARK: - Properties

    private let container: CKContainer
    private let privateDB: CKDatabase
    private let zone: CKRecordZone
    private let modelContext: ModelContext

    // State management
    private var isSyncing = false
    private var lastSyncDate: Date?

    // Change tokens for incremental sync (delta sync)
    private var taskZoneToken: CKServerChangeToken?
    private var categoryZoneToken: CKServerChangeToken?
    private var tagZoneToken: CKServerChangeToken?

    // Constants
    private let containerIdentifier = "iCloud.com.personal.todoappy"
    private let zoneName = "TasksZone"
    private let batchSize = 400 // CloudKit limit per operation

    // MARK: - Initialization

    init(modelContext: ModelContext) {
        self.container = CKContainer(identifier: containerIdentifier)
        self.privateDB = container.privateCloudDatabase
        self.zone = CKRecordZone(zoneName: zoneName)
        self.modelContext = modelContext

        // Load saved change tokens from persistent storage
        loadChangeTokens()

        print("✅ DataSyncService initialized with container: \(containerIdentifier)")
    }

    // MARK: - Main Sync Orchestrator

    /// Main synchronization method - handles full bidirectional sync
    /// This is the primary entry point for all sync operations
    func syncAll() async throws {
        // Prevent concurrent sync operations
        guard !isSyncing else {
            print("⚠️ Sync already in progress, skipping")
            return
        }

        isSyncing = true
        defer { isSyncing = false }

        print("🔄 Starting full sync cycle...")

        do {
            // Step 1: Upload local changes first (to minimize conflicts)
            // This ensures our changes are saved before we pull remote updates
            try await syncToCloud()

            // Step 2: Download remote changes from CloudKit
            // Uses change tokens for efficient delta sync
            try await syncFromCloud()

            // Step 3: Update sync timestamp for tracking
            lastSyncDate = Date()
            UserDefaults.standard.set(lastSyncDate, forKey: "lastSyncDate")

            print("✅ Sync completed successfully at \(lastSyncDate!)")

        } catch {
            print("❌ Sync failed: \(error.localizedDescription)")
            throw error
        }
    }

    // MARK: - Upload to Cloud

    /// Upload local changes to CloudKit
    /// Handles batching for large datasets and marks records as synced
    func syncToCloud() async throws {
        print("⬆️ Uploading local changes to iCloud...")

        // Fetch all items with pending sync status
        let pendingTasks = try fetchPendingTasks()
        let pendingCategories = try fetchPendingCategories()
        let pendingTags = try fetchPendingTags()

        let totalCount = pendingTasks.count + pendingCategories.count + pendingTags.count

        guard totalCount > 0 else {
            print("✅ No pending changes to upload")
            return
        }

        print("📤 Found \(pendingTasks.count) tasks, \(pendingCategories.count) categories, \(pendingTags.count) tags to upload")

        // Convert SwiftData models to CloudKit records
        var records: [CKRecord] = []
        records.append(contentsOf: pendingTasks.compactMap { $0.toCKRecord() })
        records.append(contentsOf: pendingCategories.compactMap { $0.toCKRecord() })
        records.append(contentsOf: pendingTags.compactMap { $0.toCKRecord() })

        // Upload in batches to respect CloudKit limits
        try await uploadInBatches(records: records)

        // Mark all items as successfully synced
        for task in pendingTasks {
            task.syncStatus = .synced
            task.lastSyncedAt = Date()
        }
        for category in pendingCategories {
            category.syncStatus = .synced
            category.lastSyncedAt = Date()
        }
        for tag in pendingTags {
            tag.syncStatus = .synced
            tag.lastSyncedAt = Date()
        }

        // Persist sync status changes
        try modelContext.save()

        // Handle soft deletions
        try await handleDeletions()

        print("✅ Upload complete - \(records.count) records synced")
    }

    /// Upload records in batches to respect CloudKit operation limits
    private func uploadInBatches(records: [CKRecord]) async throws {
        guard !records.isEmpty else { return }

        // Split into batches of 400 records (CloudKit max)
        let batches = stride(from: 0, to: records.count, by: batchSize).map {
            Array(records[$0..<min($0 + batchSize, records.count)])
        }

        print("📦 Uploading \(batches.count) batch(es)...")

        for (index, batch) in batches.enumerated() {
            print("📦 Uploading batch \(index + 1)/\(batches.count) (\(batch.count) records)")

            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                let operation = CKModifyRecordsOperation(recordsToSave: batch, recordIDsToDelete: nil)

                // Only upload changed fields to save bandwidth
                operation.savePolicy = .changedKeys
                operation.qualityOfService = .userInitiated

                operation.modifyRecordsResultBlock = { result in
                    switch result {
                    case .success:
                        continuation.resume()
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }

                privateDB.add(operation)
            }
        }
    }

    // MARK: - Download from Cloud

    /// Download changes from CloudKit using incremental sync with change tokens
    func syncFromCloud() async throws {
        print("⬇️ Downloading changes from iCloud...")

        // Fetch changes for each record type using saved change tokens
        // This enables efficient delta sync (only new/changed records)
        let taskChanges = try await fetchRecordZoneChanges(recordType: "CKTask", token: taskZoneToken)
        let categoryChanges = try await fetchRecordZoneChanges(recordType: "CKCategory", token: categoryZoneToken)
        let tagChanges = try await fetchRecordZoneChanges(recordType: "CKTag", token: tagZoneToken)

        let changedCount = taskChanges.changed.count + categoryChanges.changed.count + tagChanges.changed.count
        let deletedCount = taskChanges.deleted.count + categoryChanges.deleted.count + tagChanges.deleted.count

        print("📥 Downloaded \(changedCount) changed records, \(deletedCount) deletions")

        // Process changed records (creates or updates local copies)
        try await processChangedRecords(
            tasks: taskChanges.changed,
            categories: categoryChanges.changed,
            tags: tagChanges.changed
        )

        // Process deletions (mark as deleted locally)
        try await processDeletions(taskChanges.deleted + categoryChanges.deleted + tagChanges.deleted)

        // Save new change tokens for next sync (enables delta sync)
        taskZoneToken = taskChanges.newToken
        categoryZoneToken = categoryChanges.newToken
        tagZoneToken = tagChanges.newToken
        saveChangeTokens()

        // Persist all changes to SwiftData
        try modelContext.save()

        print("✅ Download complete")
    }

    /// Fetch record zone changes from CloudKit with efficient delta sync
    private func fetchRecordZoneChanges(
        recordType: String,
        token: CKServerChangeToken?
    ) async throws -> (changed: [CKRecord], deleted: [CKRecord.ID], newToken: CKServerChangeToken?) {

        var changedRecords: [CKRecord] = []
        var deletedRecordIDs: [CKRecord.ID] = []
        var newToken: CKServerChangeToken?

        // Configure zone fetch with previous change token
        let configuration = CKFetchRecordZoneChangesOperation.ZoneConfiguration()
        configuration.previousServerChangeToken = token

        let operation = CKFetchRecordZoneChangesOperation(
            recordZoneIDs: [zone.zoneID],
            configurationsByRecordZoneID: [zone.zoneID: configuration]
        )

        // Handle changed records
        operation.recordWasChangedBlock = { recordID, result in
            switch result {
            case .success(let record):
                if record.recordType == recordType {
                    changedRecords.append(record)
                }
            case .failure(let error):
                print("⚠️ Error fetching record \(recordID): \(error.localizedDescription)")
            }
        }

        // Handle deleted records
        operation.recordWithIDWasDeletedBlock = { recordID, _ in
            deletedRecordIDs.append(recordID)
        }

        // Capture new change token for next sync
        operation.recordZoneFetchResultBlock = { zoneID, result in
            switch result {
            case .success(let (serverChangeToken, _, _)):
                newToken = serverChangeToken
            case .failure(let error):
                print("⚠️ Zone fetch error: \(error.localizedDescription)")
            }
        }

        // Execute operation and wait for completion
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            operation.fetchRecordZoneChangesResultBlock = { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            privateDB.add(operation)
        }

        return (changedRecords, deletedRecordIDs, newToken)
    }

    // MARK: - Conflict Resolution

    /// Process changed records with intelligent conflict resolution
    /// Strategy: Last-write-wins with local pending changes prioritized
    private func processChangedRecords(
        tasks: [CKRecord],
        categories: [CKRecord],
        tags: [CKRecord]
    ) async throws {

        // Process categories first (tasks depend on them)
        for record in categories {
            try await processCategory(record)
        }

        // Process tags
        for record in tags {
            try await processTag(record)
        }

        // Process tasks
        for record in tasks {
            try await processTask(record)
        }
    }

    /// Process a single task record with conflict detection
    private func processTask(_ record: CKRecord) async throws {
        let taskID = record["id"] as? String ?? record.recordID.recordName

        // Check if task exists locally
        let descriptor = FetchDescriptor<Task>(
            predicate: #Predicate { $0.id == taskID }
        )
        let existingTasks = try modelContext.fetch(descriptor)

        if let existingTask = existingTasks.first {
            // Task exists - check for conflict
            let localUpdatedAt = existingTask.updatedAt
            let remoteUpdatedAt = record["updatedAt"] as? Date ?? Date.distantPast

            // Conflict resolution: Prioritize local pending changes
            if existingTask.syncStatus == .pending && localUpdatedAt > remoteUpdatedAt {
                // Local is newer and has unsynced changes - keep local
                print("⚠️ Conflict detected for task '\(existingTask.title)' - keeping local changes (newer)")
                existingTask.syncStatus = .conflict
            } else {
                // Remote is newer or local is already synced - update from cloud
                updateTaskFromRecord(existingTask, record: record)
                existingTask.syncStatus = .synced
                existingTask.lastSyncedAt = Date()
                print("📝 Updated task: \(existingTask.title)")
            }
        } else {
            // New task from cloud - create locally
            if let newTask = Task.fromCKRecord(record, context: modelContext) {
                modelContext.insert(newTask)
                print("➕ Created new task from cloud: \(newTask.title)")
            }
        }
    }

    /// Update task from CloudKit record
    private func updateTaskFromRecord(_ task: Task, record: CKRecord) {
        task.title = record["title"] as? String ?? task.title
        task.taskDescription = record["taskDescription"] as? String ?? ""
        task.isCompleted = (record["isCompleted"] as? Int ?? 0) == 1
        task.updatedAt = record["updatedAt"] as? Date ?? Date()
        task.dueDate = record["dueDate"] as? Date
        task.priority = Priority(rawValue: record["priority"] as? Int ?? 0) ?? .none
        task.hasReminder = (record["hasReminder"] as? Int ?? 0) == 1
        task.reminderTime = record["reminderTime"] as? Date
        task.reminderOffset = record["reminderOffset"] as? Int ?? 0
        task.isRecurring = (record["isRecurring"] as? Int ?? 0) == 1
        task.recurrenceRule = record["recurrenceRule"] as? String
        task.categoryID = record["categoryID"] as? String
        // Note: Tags and attachments handled separately via relationships
    }

    /// Process category record
    private func processCategory(_ record: CKRecord) async throws {
        let categoryID = record["id"] as? String ?? record.recordID.recordName

        let descriptor = FetchDescriptor<Category>(
            predicate: #Predicate { $0.id == categoryID }
        )
        let existingCategories = try modelContext.fetch(descriptor)

        if let existingCategory = existingCategories.first {
            // Update existing
            existingCategory.name = record["name"] as? String ?? existingCategory.name
            existingCategory.color = record["color"] as? String ?? existingCategory.color
            existingCategory.iconName = record["iconName"] as? String ?? ""
            existingCategory.syncStatus = .synced
            existingCategory.lastSyncedAt = Date()
            print("📝 Updated category: \(existingCategory.name)")
        } else {
            // Create new
            if let newCategory = Category.fromCKRecord(record, context: modelContext) {
                modelContext.insert(newCategory)
                print("➕ Created new category from cloud: \(newCategory.name)")
            }
        }
    }

    /// Process tag record
    private func processTag(_ record: CKRecord) async throws {
        let tagID = record["id"] as? String ?? record.recordID.recordName

        let descriptor = FetchDescriptor<Tag>(
            predicate: #Predicate { $0.id == tagID }
        )
        let existingTags = try modelContext.fetch(descriptor)

        if let existingTag = existingTags.first {
            // Update existing
            existingTag.name = record["name"] as? String ?? existingTag.name
            existingTag.color = record["color"] as? String ?? existingTag.color
            existingTag.syncStatus = .synced
            existingTag.lastSyncedAt = Date()
            print("📝 Updated tag: \(existingTag.name)")
        } else {
            // Create new
            if let newTag = Tag.fromCKRecord(record, context: modelContext) {
                modelContext.insert(newTag)
                print("➕ Created new tag from cloud: \(newTag.name)")
            }
        }
    }

    /// Process deletion records (soft delete)
    private func processDeletions(_ deletedIDs: [CKRecord.ID]) async throws {
        guard !deletedIDs.isEmpty else { return }

        print("🗑️ Processing \(deletedIDs.count) deletions...")

        for recordID in deletedIDs {
            let id = recordID.recordName

            // Try to find and mark as deleted in all model types
            // Using soft delete to allow 30-day recovery

            // Check tasks
            let taskDescriptor = FetchDescriptor<Task>(
                predicate: #Predicate { $0.id == id }
            )
            if let task = try modelContext.fetch(taskDescriptor).first {
                task.isDeleted = true
                task.deletedAt = Date()
                print("🗑️ Soft deleted task: \(task.title)")
            }

            // Check categories
            let categoryDescriptor = FetchDescriptor<Category>(
                predicate: #Predicate { $0.id == id }
            )
            if let category = try modelContext.fetch(categoryDescriptor).first {
                category.isDeleted = true
                category.deletedAt = Date()
                print("🗑️ Soft deleted category: \(category.name)")
            }

            // Check tags
            let tagDescriptor = FetchDescriptor<Tag>(
                predicate: #Predicate { $0.id == id }
            )
            if let tag = try modelContext.fetch(tagDescriptor).first {
                tag.isDeleted = true
                tag.deletedAt = Date()
                print("🗑️ Soft deleted tag: \(tag.name)")
            }
        }
    }

    /// Handle deletion of locally deleted items
    private func handleDeletions() async throws {
        // Find all soft-deleted items that need CloudKit deletion
        let taskDescriptor = FetchDescriptor<Task>(
            predicate: #Predicate { $0.isDeleted && $0.syncStatus == .pending }
        )
        let deletedTasks = try modelContext.fetch(taskDescriptor)

        let categoryDescriptor = FetchDescriptor<Category>(
            predicate: #Predicate { $0.isDeleted && $0.syncStatus == .pending }
        )
        let deletedCategories = try modelContext.fetch(categoryDescriptor)

        let tagDescriptor = FetchDescriptor<Tag>(
            predicate: #Predicate { $0.isDeleted && $0.syncStatus == .pending }
        )
        let deletedTags = try modelContext.fetch(tagDescriptor)

        // Collect record IDs to delete
        var recordIDsToDelete: [CKRecord.ID] = []

        for task in deletedTasks {
            let recordID = CKRecord.ID(recordName: task.id, zoneID: zone.zoneID)
            recordIDsToDelete.append(recordID)
        }

        for category in deletedCategories {
            let recordID = CKRecord.ID(recordName: category.id, zoneID: zone.zoneID)
            recordIDsToDelete.append(recordID)
        }

        for tag in deletedTags {
            let recordID = CKRecord.ID(recordName: tag.id, zoneID: zone.zoneID)
            recordIDsToDelete.append(recordID)
        }

        guard !recordIDsToDelete.isEmpty else { return }

        print("🗑️ Deleting \(recordIDsToDelete.count) records from CloudKit...")

        // Delete from CloudKit
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: recordIDsToDelete)
            operation.qualityOfService = .userInitiated

            operation.modifyRecordsResultBlock = { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }

            privateDB.add(operation)
        }

        // Mark as synced
        for task in deletedTasks {
            task.syncStatus = .synced
        }
        for category in deletedCategories {
            category.syncStatus = .synced
        }
        for tag in deletedTags {
            tag.syncStatus = .synced
        }
    }

    // MARK: - Helper Methods

    /// Fetch tasks pending sync
    private func fetchPendingTasks() throws -> [Task] {
        let descriptor = FetchDescriptor<Task>(
            predicate: #Predicate { $0.syncStatus == .pending }
        )
        return try modelContext.fetch(descriptor)
    }

    /// Fetch categories pending sync
    private func fetchPendingCategories() throws -> [Category] {
        let descriptor = FetchDescriptor<Category>(
            predicate: #Predicate { $0.syncStatus == .pending }
        )
        return try modelContext.fetch(descriptor)
    }

    /// Fetch tags pending sync
    private func fetchPendingTags() throws -> [Tag] {
        let descriptor = FetchDescriptor<Tag>(
            predicate: #Predicate { $0.syncStatus == .pending }
        )
        return try modelContext.fetch(descriptor)
    }

    // MARK: - Change Token Persistence

    /// Save change tokens to UserDefaults for persistence across app launches
    private func saveChangeTokens() {
        if let taskToken = taskZoneToken {
            let data = try? NSKeyedArchiver.archivedData(withRootObject: taskToken, requiringSecureCoding: true)
            UserDefaults.standard.set(data, forKey: "taskZoneToken")
        }

        if let categoryToken = categoryZoneToken {
            let data = try? NSKeyedArchiver.archivedData(withRootObject: categoryToken, requiringSecureCoding: true)
            UserDefaults.standard.set(data, forKey: "categoryZoneToken")
        }

        if let tagToken = tagZoneToken {
            let data = try? NSKeyedArchiver.archivedData(withRootObject: tagToken, requiringSecureCoding: true)
            UserDefaults.standard.set(data, forKey: "tagZoneToken")
        }

        print("💾 Saved change tokens for delta sync")
    }

    /// Load change tokens from UserDefaults
    private func loadChangeTokens() {
        if let data = UserDefaults.standard.data(forKey: "taskZoneToken"),
           let token = try? NSKeyedUnarchiver.unarchivedObject(ofClass: CKServerChangeToken.self, from: data) {
            taskZoneToken = token
        }

        if let data = UserDefaults.standard.data(forKey: "categoryZoneToken"),
           let token = try? NSKeyedUnarchiver.unarchivedObject(ofClass: CKServerChangeToken.self, from: data) {
            categoryZoneToken = token
        }

        if let data = UserDefaults.standard.data(forKey: "tagZoneToken"),
           let token = try? NSKeyedUnarchiver.unarchivedObject(ofClass: CKServerChangeToken.self, from: data) {
            tagZoneToken = token
        }

        if taskZoneToken != nil || categoryZoneToken != nil || tagZoneToken != nil {
            print("💾 Loaded change tokens for delta sync")
        }
    }

    // MARK: - Public Status Methods

    /// Check if currently syncing
    func isSyncInProgress() -> Bool {
        return isSyncing
    }

    /// Get last sync date
    func getLastSyncDate() -> Date? {
        return lastSyncDate
    }
}

// MARK: - Supporting Types

/// Sync status for tracking record state
enum SyncStatus: Int, Codable {
    case pending = 0    // Needs to be synced
    case synced = 1     // Successfully synced
    case conflict = 2   // Conflict detected
}

/// Priority levels for tasks
enum Priority: Int, Codable {
    case none = 0
    case low = 1
    case medium = 2
    case high = 3
    case urgent = 4

    var displayName: String {
        switch self {
        case .none: return "None"
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        case .urgent: return "Urgent"
        }
    }
}
