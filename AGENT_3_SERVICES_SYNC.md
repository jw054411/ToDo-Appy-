# Agent 3: Services & Sync Specialist

**Role:** Build CloudKit sync service, notification service, import/export, and ensure bulletproof data safety with automatic backups.

**Start:** After Agent 2 completes data models
**Depends On:** Agent 1 (CloudKit schema), Agent 2 (models with toCKRecord/fromCKRecord)
**Blocks:** None (Agent 4 & 5 can work in parallel)
**Estimated Time:** 10-12 hours

---

## 🎯 Mission
Create production-grade services that ensure data is **ALWAYS safe, automatically backed up to iCloud, and never lost**. Implement robust sync, conflict resolution, offline support, and data export/import for additional safety.

---

## 🔒 **DATA SAFETY PRIORITY**

This app will be **MORE RELIABLE than Todoist** with:
- ✅ **Automatic iCloud backup** - Every change synced within seconds
- ✅ **Offline-first** - Works without internet, syncs when reconnected
- ✅ **Conflict resolution** - Never lose data even if editing on multiple devices
- ✅ **Soft delete** - Deleted items recoverable for 30 days
- ✅ **Export/import** - Manual JSON backup anytime
- ✅ **Local persistence** - SwiftData keeps local copy always
- ✅ **Retry queue** - Failed syncs automatically retry

---

## ✅ TODO List

### TASK 1: Pull Latest Code & Verify Setup
**Priority:** CRITICAL - Do this first
**Time:** 10 minutes

#### Subtasks:
- [ ] 1.1: Pull latest from branch
  - `git pull origin claude/free-todoist-alternative-01Reu5pLCB2jQtasTo9n8khh`
  - Verify Agent 1 & 2 commits present

- [ ] 1.2: Verify Agent 1 deliverables
  - [ ] CloudKit container configured
  - [ ] CloudKit schema exists (CKTask, CKCategory, CKTag)
  - [ ] Subscriptions created
  - [ ] AppDelegate.swift exists

- [ ] 1.3: Verify Agent 2 deliverables
  - [ ] Task model exists with toCKRecord/fromCKRecord
  - [ ] Category model exists with CloudKit conversion
  - [ ] Tag model exists with CloudKit conversion
  - [ ] RecurrenceEngine exists
  - [ ] All models compile

- [ ] 1.4: Test build
  - Clean build (⌘⇧K)
  - Build succeeds (⌘B)
  - Ready to add services

**Acceptance Criteria:**
- ✅ All prior work present and working
- ✅ Ready to build services

---

### TASK 2: Create DataSyncService (Core Sync Engine)
**Priority:** CRITICAL - Most important service
**Time:** 4 hours

#### Subtasks:
- [ ] 2.1: Create DataSyncService.swift
  - Location: `Services/DataSyncService.swift`
  - Import: CloudKit, SwiftData, Foundation

- [ ] 2.2: Create actor structure
  ```swift
  import CloudKit
  import SwiftData
  import Foundation

  actor DataSyncService {
      private let container: CKContainer
      private let privateDB: CKDatabase
      private let zone: CKRecordZone
      private let modelContext: ModelContext

      // State
      private var isSyncing = false
      private var lastSyncDate: Date?

      // Change tokens for incremental sync
      private var taskZoneToken: CKServerChangeToken?
      private var categoryZoneToken: CKServerChangeToken?
      private var tagZoneToken: CKServerChangeToken?

      init(modelContext: ModelContext) {
          self.container = CKContainer(identifier: "iCloud.com.personal.todoappy")
          self.privateDB = container.privateCloudDatabase
          self.zone = CKRecordZone(zoneName: "TasksZone")
          self.modelContext = modelContext

          // Load saved change tokens
          loadChangeTokens()
      }

      // Core sync methods will be added
  }
  ```

- [ ] 2.3: Implement syncAll() - Main sync orchestrator
  ```swift
  func syncAll() async throws {
      guard !isSyncing else {
          print("⚠️ Sync already in progress, skipping")
          return
      }

      isSyncing = true
      defer { isSyncing = false }

      print("🔄 Starting full sync...")

      do {
          // 1. Upload local changes first (to avoid conflicts)
          try await syncToCloud()

          // 2. Download remote changes
          try await syncFromCloud()

          // 3. Update sync timestamp
          lastSyncDate = Date()
          UserDefaults.standard.set(lastSyncDate, forKey: "lastSyncDate")

          print("✅ Sync completed successfully")

      } catch {
          print("❌ Sync failed: \(error.localizedDescription)")
          throw error
      }
  }
  ```

- [ ] 2.4: Implement syncToCloud() - Upload local changes
  ```swift
  func syncToCloud() async throws {
      print("⬆️ Uploading local changes to iCloud...")

      // Fetch all items with pending sync status
      let pendingTasks = try fetchPendingTasks()
      let pendingCategories = try fetchPendingCategories()
      let pendingTags = try fetchPendingTags()

      print("📤 Found \(pendingTasks.count) tasks, \(pendingCategories.count) categories, \(pendingTags.count) tags to upload")

      // Convert to CKRecords
      var records: [CKRecord] = []
      records.append(contentsOf: pendingTasks.map { $0.toCKRecord() })
      records.append(contentsOf: pendingCategories.map { $0.toCKRecord() })
      records.append(contentsOf: pendingTags.map { $0.toCKRecord() })

      // Upload in batches (CloudKit limit: 400 records per operation)
      try await uploadInBatches(records: records)

      // Mark as synced
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

      try modelContext.save()

      // Handle deletions
      try await handleDeletions()

      print("✅ Upload complete")
  }
  ```

- [ ] 2.5: Implement uploadInBatches()
  ```swift
  private func uploadInBatches(records: [CKRecord]) async throws {
      let batchSize = 400
      let batches = stride(from: 0, to: records.count, by: batchSize).map {
          Array(records[$0..<min($0 + batchSize, records.count)])
      }

      for (index, batch) in batches.enumerated() {
          print("📦 Uploading batch \(index + 1)/\(batches.count) (\(batch.count) records)")

          try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
              let operation = CKModifyRecordsOperation(recordsToSave: batch, recordIDsToDelete: nil)
              operation.savePolicy = .changedKeys  // Only upload changed fields
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
  ```

- [ ] 2.6: Implement syncFromCloud() - Download remote changes
  ```swift
  func syncFromCloud() async throws {
      print("⬇️ Downloading changes from iCloud...")

      // Fetch changes for each record type
      let taskChanges = try await fetchRecordZoneChanges(recordType: "CKTask", token: taskZoneToken)
      let categoryChanges = try await fetchRecordZoneChanges(recordType: "CKCategory", token: categoryZoneToken)
      let tagChanges = try await fetchRecordZoneChanges(recordType: "CKTag", token: tagZoneToken)

      print("📥 Downloaded \(taskChanges.changed.count) tasks, \(categoryChanges.changed.count) categories, \(tagChanges.changed.count) tags")

      // Process changed records
      try await processChangedRecords(tasks: taskChanges.changed, categories: categoryChanges.changed, tags: tagChanges.changed)

      // Process deletions
      try await processDeletions(taskChanges.deleted + categoryChanges.deleted + tagChanges.deleted)

      // Save new change tokens
      taskZoneToken = taskChanges.newToken
      categoryZoneToken = categoryChanges.newToken
      tagZoneToken = tagChanges.newToken
      saveChangeTokens()

      try modelContext.save()

      print("✅ Download complete")
  }
  ```

- [ ] 2.7: Implement fetchRecordZoneChanges()
  ```swift
  private func fetchRecordZoneChanges(
      recordType: String,
      token: CKServerChangeToken?
  ) async throws -> (changed: [CKRecord], deleted: [CKRecord.ID], newToken: CKServerChangeToken?) {

      var changedRecords: [CKRecord] = []
      var deletedRecordIDs: [CKRecord.ID] = []
      var newToken: CKServerChangeToken?

      let configuration = CKFetchRecordZoneChangesOperation.ZoneConfiguration()
      configuration.previousServerChangeToken = token

      let operation = CKFetchRecordZoneChangesOperation(
          recordZoneIDs: [zone.zoneID],
          configurationsByRecordZoneID: [zone.zoneID: configuration]
      )

      operation.recordWasChangedBlock = { recordID, result in
          switch result {
          case .success(let record):
              if record.recordType == recordType {
                  changedRecords.append(record)
              }
          case .failure(let error):
              print("⚠️ Error fetching record: \(error)")
          }
      }

      operation.recordWithIDWasDeletedBlock = { recordID, _ in
          deletedRecordIDs.append(recordID)
      }

      operation.recordZoneFetchResultBlock = { zoneID, result in
          switch result {
          case .success(let (serverChangeToken, _, _)):
              newToken = serverChangeToken
          case .failure(let error):
              print("⚠️ Zone fetch error: \(error)")
          }
      }

      try await withCheckedThrowingContinuation { continuation in
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
  ```

- [ ] 2.8: Implement conflict resolution
  ```swift
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

          if existingTask.syncStatus == .pending && localUpdatedAt > remoteUpdatedAt {
              // Local is newer and has unsyncedchanges - keep local, will upload later
              print("⚠️ Conflict detected for task '\(existingTask.title)' - keeping local changes")
              existingTask.syncStatus = .conflict
          } else {
              // Remote is newer - update from cloud
              updateTaskFromRecord(existingTask, record: record)
              existingTask.syncStatus = .synced
              existingTask.lastSyncedAt = Date()
              print("📝 Updated task: \(existingTask.title)")
          }
      } else {
          // New task from cloud - create locally
          if let newTask = Task.fromCKRecord(record) {
              modelContext.insert(newTask)
              print("➕ Created new task: \(newTask.title)")
          }
      }
  }

  private func updateTaskFromRecord(_ task: Task, record: CKRecord) {
      // Update all fields from CKRecord
      task.title = record["title"] as? String ?? task.title
      task.taskDescription = record["taskDescription"] as? String ?? ""
      task.isCompleted = (record["isCompleted"] as? Int ?? 0) == 1
      task.updatedAt = record["updatedAt"] as? Date ?? Date()
      task.dueDate = record["dueDate"] as? Date
      task.priority = Priority(rawValue: record["priority"] as? Int ?? 0) ?? .none
      // ... update all other fields
  }
  ```

**Acceptance Criteria:**
- ✅ DataSyncService compiles
- ✅ syncAll() orchestrates full sync
- ✅ Upload works with batching
- ✅ Download works with change tokens
- ✅ Conflict resolution implemented (last-write-wins with local priority)
- ✅ Data safety ensured

**Deliverable:** Commit `feat(services): implement DataSyncService with robust conflict resolution`

---

### TASK 3: Implement Offline Queue & Retry Logic
**Priority:** CRITICAL - For data safety
**Time:** 2 hours

#### Subtasks:
- [ ] 3.1: Create SyncQueue.swift
  - Location: `Services/SyncQueue.swift`

- [ ] 3.2: Implement SyncQueue actor
  ```swift
  import Foundation

  actor SyncQueue {
      struct SyncOperation: Codable {
          let id: UUID
          let operationType: OperationType
          let recordID: String
          let recordType: String
          var retryCount: Int
          let createdAt: Date
          var lastAttempt: Date?

          enum OperationType: String, Codable {
              case create, update, delete
          }
      }

      private var queue: [SyncOperation] = []
      private let maxRetries = 5
      private let userDefaults = UserDefaults.standard
      private let queueKey = "syncQueue"

      init() {
          loadQueue()
      }

      func enqueue(_ operation: SyncOperation) {
          queue.append(operation)
          saveQueue()
          print("📥 Queued operation: \(operation.operationType) \(operation.recordType) \(operation.recordID)")
      }

      func processQueue(syncService: DataSyncService) async {
          guard !queue.isEmpty else { return }

          print("🔄 Processing offline queue (\(queue.count) operations)...")

          var processedIDs: [UUID] = []

          for operation in queue {
              if operation.retryCount >= maxRetries {
                  print("❌ Operation \(operation.id) exceeded max retries, removing from queue")
                  processedIDs.append(operation.id)
                  continue
              }

              do {
                  // Attempt to sync
                  try await syncService.syncAll()
                  processedIDs.append(operation.id)
                  print("✅ Successfully processed operation \(operation.id)")
              } catch {
                  // Update retry count
                  if let index = queue.firstIndex(where: { $0.id == operation.id }) {
                      queue[index].retryCount += 1
                      queue[index].lastAttempt = Date()
                  }
                  print("⚠️ Retry \(operation.retryCount + 1)/\(maxRetries) for operation \(operation.id)")
              }
            }

          // Remove processed operations
          queue.removeAll { processedIDs.contains($0.id) }
          saveQueue()
      }

      func count() -> Int {
          queue.count
      }

      private func saveQueue() {
          if let encoded = try? JSONEncoder().encode(queue) {
              userDefaults.set(encoded, forKey: queueKey)
          }
      }

      private func loadQueue() {
          if let data = userDefaults.data(forKey: queueKey),
             let decoded = try? JSONDecoder().decode([SyncOperation].self, from: data) {
              queue = decoded
          }
      }
  }
  ```

- [ ] 3.3: Integrate with DataSyncService
  - Add SyncQueue property to DataSyncService
  - On network failure, add to queue
  - Process queue on app launch and network restore

- [ ] 3.4: Add network monitoring
  - File: `Services/NetworkMonitor.swift`
  - Use NWPathMonitor to detect connectivity
  - Trigger queue processing when network restored

**Acceptance Criteria:**
- ✅ Failed sync operations queued
- ✅ Automatic retry with exponential backoff
- ✅ Queue persisted across app launches
- ✅ **Data never lost even offline**

**Deliverable:** Commit `feat(services): add offline queue with automatic retry`

---

### TASK 4: Create NotificationService (Reminders)
**Priority:** HIGH
**Time:** 2 hours

#### Subtasks:
- [ ] 4.1: Create NotificationService.swift
  - Location: `Services/NotificationService.swift`

- [ ] 4.2: Implement NotificationService actor
  ```swift
  import UserNotifications
  import Foundation

  actor NotificationService {
      private let center = UNUserNotificationCenter.current()

      // Request permission
      func requestAuthorization() async -> Bool {
          do {
              let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
              print(granted ? "✅ Notification permission granted" : "❌ Notification permission denied")
              return granted
          } catch {
              print("❌ Error requesting notification permission: \(error)")
              return false
          }
      }

      // Schedule reminder for task
      func scheduleReminder(for task: Task) async -> String? {
          guard task.hasReminder else { return nil }

          let content = UNMutableNotificationContent()
          content.title = task.title
          content.body = task.taskDescription.isEmpty ? "Task is due" : task.taskDescription
          content.sound = .default
          content.badge = 1

          // Add task ID to userInfo for opening task when tapped
          content.userInfo = ["taskID": task.id]

          // Add actions
          content.categoryIdentifier = "TASK_REMINDER"

          // Determine trigger time
          let triggerDate: Date
          if let reminderTime = task.reminderTime {
              triggerDate = reminderTime
          } else if let dueDate = task.dueDate {
              // Use offset from due date
              triggerDate = Calendar.current.date(
                  byAdding: .minute,
                  value: -task.reminderOffset,
                  to: dueDate
              ) ?? dueDate
          } else {
              return nil
          }

          // Only schedule future notifications
          guard triggerDate > Date() else { return nil }

          let components = Calendar.current.dateComponents(
              [.year, .month, .day, .hour, .minute],
              from: triggerDate
          )
          let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

          let notificationID = "task-\(task.id)-\(UUID().uuidString)"
          let request = UNNotificationRequest(identifier: notificationID, content: content, trigger: trigger)

          do {
              try await center.add(request)
              print("🔔 Scheduled reminder for '\(task.title)' at \(triggerDate)")
              return notificationID
          } catch {
              print("❌ Error scheduling notification: \(error)")
              return nil
          }
      }

      // Cancel reminder
      func cancelReminder(notificationID: String) async {
          center.removePendingNotificationRequests(withIdentifiers: [notificationID])
          print("🔕 Cancelled reminder: \(notificationID)")
      }

      // Cancel all reminders for task
      func cancelReminders(for task: Task) async {
          guard let notificationID = task.notificationID else { return }
          await cancelReminder(notificationID: notificationID)
      }

      // Reschedule all pending reminders (useful after app update)
      func rescheduleAllReminders(tasks: [Task]) async {
          print("🔄 Rescheduling \(tasks.count) task reminders...")
          for task in tasks where task.hasReminder && !task.isCompleted {
              if let newID = await scheduleReminder(for: task) {
                  task.notificationID = newID
              }
          }
      }

      // Update badge count
      func updateBadgeCount(_ count: Int) {
          center.setBadgeCount(count)
      }
  }
  ```

- [ ] 4.3: Set up notification categories
  - Add to AppDelegate
  - Actions: Complete, Snooze, View
  - Handle actions

**Acceptance Criteria:**
- ✅ Notifications schedule correctly
- ✅ Reminders trigger at right time
- ✅ Can cancel/reschedule
- ✅ Badge count updates

**Deliverable:** Commit `feat(services): implement notification service for reminders`

---

### TASK 5: Create Import/Export Service (Manual Backup)
**Priority:** HIGH - Additional data safety
**Time:** 2 hours

#### Subtasks:
- [ ] 5.1: Create ImportExportService.swift
  - Location: `Services/ImportExportService.swift`

- [ ] 5.2: Implement export to JSON
  ```swift
  import Foundation
  import SwiftData

  actor ImportExportService {
      private let modelContext: ModelContext

      init(modelContext: ModelContext) {
          self.modelContext = modelContext
      }

      // Export all data to JSON
      func exportToJSON(includeCompleted: Bool = true) async throws -> URL {
          print("📤 Exporting data to JSON...")

          // Fetch all data
          let taskDescriptor = FetchDescriptor<Task>(
              predicate: includeCompleted ? nil : #Predicate { !$0.isCompleted }
          )
          let tasks = try modelContext.fetch(taskDescriptor)

          let categoryDescriptor = FetchDescriptor<Category>()
          let categories = try modelContext.fetch(categoryDescriptor)

          let tagDescriptor = FetchDescriptor<Tag>()
          let tags = try modelContext.fetch(tagDescriptor)

          // Create exportable structure
          let exportData = ExportData(
              version: "1.0",
              exportDate: Date(),
              tasks: tasks.map { TaskExportModel(from: $0) },
              categories: categories.map { CategoryExportModel(from: $0) },
              tags: tags.map { TagExportModel(from: $0) }
          )

          // Encode to JSON
          let encoder = JSONEncoder()
          encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
          encoder.dateEncodingStrategy = .iso8601
          let jsonData = try encoder.encode(exportData)

          // Save to file
          let filename = "TodoAppy-Backup-\(Date().ISO8601Format()).json"
          let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
          try jsonData.write(to: tempURL)

          print("✅ Exported \(tasks.count) tasks, \(categories.count) categories, \(tags.count) tags")
          return tempURL
      }

      // Import from JSON
      func importFromJSON(url: URL) async throws -> ImportResult {
          print("📥 Importing data from JSON...")

          let jsonData = try Data(contentsOf: url)
          let decoder = JSONDecoder()
          decoder.dateDecodingStrategy = .iso8601

          let importData = try decoder.decode(ExportData.self, from: jsonData)

          var result = ImportResult()

          // Import categories first
          for categoryData in importData.categories {
              let category = categoryData.toCategory()
              modelContext.insert(category)
              result.categoriesImported += 1
          }

          // Import tags
          for tagData in importData.tags {
              let tag = tagData.toTag()
              modelContext.insert(tag)
              result.tagsImported += 1
          }

          // Import tasks
          for taskData in importData.tasks {
              let task = taskData.toTask(modelContext: modelContext)
              modelContext.insert(task)
              result.tasksImported += 1
          }

          try modelContext.save()

          print("✅ Imported \(result.tasksImported) tasks, \(result.categoriesImported) categories, \(result.tagsImported) tags")
          return result
      }

      // Export to CSV (for spreadsheet compatibility)
      func exportToCSV() async throws -> URL {
          // Simple CSV with basic task info
          let descriptor = FetchDescriptor<Task>()
          let tasks = try modelContext.fetch(descriptor)

          var csvString = "Title,Description,Completed,Due Date,Priority,Category\n"

          for task in tasks {
              let fields = [
                  task.title.csvEscaped,
                  task.taskDescription.csvEscaped,
                  task.isCompleted ? "Yes" : "No",
                  task.dueDate?.ISO8601Format() ?? "",
                  task.priority.displayName,
                  task.category?.name ?? ""
              ]
              csvString += fields.joined(separator: ",") + "\n"
          }

          let filename = "TodoAppy-Export-\(Date().ISO8601Format()).csv"
          let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
          try csvString.write(to: tempURL, atomically: true, encoding: .utf8)

          print("✅ Exported \(tasks.count) tasks to CSV")
          return tempURL
      }
  }

  // Export data structures
  struct ExportData: Codable {
      let version: String
      let exportDate: Date
      let tasks: [TaskExportModel]
      let categories: [CategoryExportModel]
      let tags: [TagExportModel]
  }

  struct TaskExportModel: Codable {
      // All task fields for export
      let id: String
      let title: String
      let taskDescription: String
      // ... all other fields

      init(from task: Task) {
          self.id = task.id
          self.title = task.title
          self.taskDescription = task.taskDescription
          // ... copy all fields
      }

      func toTask(modelContext: ModelContext) -> Task {
          let task = Task(title: title)
          task.id = id
          task.taskDescription = taskDescription
          // ... restore all fields
          return task
      }
  }

  struct ImportResult {
      var tasksImported = 0
      var categoriesImported = 0
      var tagsImported = 0
  }

  extension String {
      var csvEscaped: String {
          "\"\(self.replacingOccurrences(of: "\"", with: "\"\""))\""
      }
  }
  ```

**Acceptance Criteria:**
- ✅ Export to JSON works (full data)
- ✅ Import from JSON works
- ✅ Export to CSV works (basic data)
- ✅ **Users can manually backup anytime**

**Deliverable:** Commit `feat(services): add import/export service for manual backups`

---

### TASK 6: Add Push Notification Handling
**Priority:** MEDIUM
**Time:** 1 hour

#### Subtasks:
- [ ] 6.1: Update AppDelegate.swift
  - Handle remote notifications
  - Trigger sync when CloudKit push received

- [ ] 6.2: Implement silent push handling
  ```swift
  func application(
      _ application: UIApplication,
      didReceiveRemoteNotification userInfo: [AnyHashable: Any],
      fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
  ) {
      // Check if this is a CloudKit notification
      if let notification = CKNotification(fromRemoteNotificationDictionary: userInfo) {
          print("🔔 Received CloudKit notification")

          Task {
              do {
                  // Trigger sync
                  if let syncService = /* get sync service */ {
                      try await syncService.syncAll()
                      completionHandler(.newData)
                  } else {
                      completionHandler(.noData)
                  }
              } catch {
                  completionHandler(.failed)
              }
          }
      } else {
          completionHandler(.noData)
      }
  }
  ```

**Acceptance Criteria:**
- ✅ App syncs when changes detected on other devices
- ✅ Silent background sync works
- ✅ Real-time sync across devices

**Deliverable:** Commit `feat(services): add push notification handling for real-time sync`

---

### TASK 7: Write Service Unit Tests
**Priority:** HIGH
**Time:** 2 hours

#### Subtasks:
- [ ] 7.1: Create ServiceTests.swift
  - Location: `Tests/ServiceTests.swift`

- [ ] 7.2: Test DataSyncService
  ```swift
  func testSyncUpload() async throws {
      // Create test task
      // Mark as pending
      // Call syncToCloud()
      // Verify uploaded to CloudKit
      // Verify marked as synced
  }

  func testSyncDownload() async throws {
      // Create record in CloudKit
      // Call syncFromCloud()
      // Verify task created locally
  }

  func testConflictResolution() async throws {
      // Create task locally with pending status
      // Create same task in CloudKit with older timestamp
      // Call sync
      // Verify local version kept (last-write-wins)
  }
  ```

- [ ] 7.3: Test SyncQueue
  - Test enqueue/dequeue
  - Test retry logic
  - Test persistence

- [ ] 7.4: Test NotificationService
  - Test scheduling
  - Test cancellation
  - Test badge updates

- [ ] 7.5: Run all tests
  - ⌘U in Xcode
  - All tests pass

**Acceptance Criteria:**
- ✅ 15+ service tests written
- ✅ All tests pass
- ✅ Services proven reliable

**Deliverable:** Commit `test(services): add comprehensive unit tests for sync and notifications`

---

### TASK 8: Create DataManager (SwiftData Helper)
**Priority:** MEDIUM
**Time:** 1 hour

#### Subtasks:
- [ ] 8.1: Create DataManager.swift
  - Location: `Services/DataManager.swift`

- [ ] 8.2: Implement singleton actor
  ```swift
  import SwiftData
  import Foundation

  actor DataManager {
      static let shared = DataManager()

      private(set) var modelContainer: ModelContainer!
      private(set) var modelContext: ModelContext!

      private init() {
          setupContainer()
      }

      private func setupContainer() {
          let schema = Schema([
              Task.self,
              Category.self,
              Tag.self
          ])

          let modelConfiguration = ModelConfiguration(
              schema: schema,
              isStoredInMemoryOnly: false,  // Persist to disk
              cloudKitDatabase: .private("iCloud.com.personal.todoappy")
          )

          do {
              modelContainer = try ModelContainer(
                  for: schema,
                  configurations: [modelConfiguration]
              )
              modelContext = ModelContext(modelContainer)
              print("✅ SwiftData container initialized")
          } catch {
              fatalError("Failed to initialize ModelContainer: \(error)")
          }
      }

      // CRUD helpers
      func save() throws {
          try modelContext.save()
      }

      func fetch<T: PersistentModel>(_ descriptor: FetchDescriptor<T>) throws -> [T] {
          try modelContext.fetch(descriptor)
      }

      func insert<T: PersistentModel>(_ model: T) {
          modelContext.insert(model)
      }

      func delete<T: PersistentModel>(_ model: T) {
          modelContext.delete(model)
      }
  }
  ```

**Acceptance Criteria:**
- ✅ DataManager singleton works
- ✅ SwiftData properly configured
- ✅ CloudKit integration enabled

**Deliverable:** Commit `feat(services): add DataManager for SwiftData operations`

---

### TASK 9: Implement Automatic Sync Triggers
**Priority:** HIGH
**Time:** 1 hour

#### Subtasks:
- [ ] 9.1: Add sync on app launch
  - Call syncAll() in App init

- [ ] 9.2: Add sync on app become active
  - Use ScenePhase to detect

- [ ] 9.3: Add periodic background sync
  - Use Timer to sync every 15 minutes (when app active)

- [ ] 9.4: Add sync after local changes
  - Trigger sync 2 seconds after any create/update/delete
  - Debounce to avoid excessive syncs

**Code example:**
```swift
@main
struct ToDoAppyApp: App {
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                Task {
                    try? await DataSyncService.shared.syncAll()
                }
            }
        }
    }
}
```

**Acceptance Criteria:**
- ✅ Sync happens automatically
- ✅ Data always up-to-date
- ✅ **User never manually syncs**

**Deliverable:** Commit `feat(services): add automatic sync triggers`

---

### TASK 10: Final Verification & Handoff
**Priority:** CRITICAL
**Time:** 20 minutes

#### Subtasks:
- [ ] 10.1: Verification checklist
  - [ ] DataSyncService compiles and works
  - [ ] Offline queue implemented
  - [ ] NotificationService works
  - [ ] Import/Export functional
  - [ ] Push notifications handled
  - [ ] All tests pass (15+ tests)
  - [ ] DataManager configured
  - [ ] Automatic sync triggers working

- [ ] 10.2: Test data safety
  - [ ] Create task → Verify syncs to iCloud
  - [ ] Turn off network → Create task → Verify queued
  - [ ] Turn on network → Verify task syncs
  - [ ] Export data → Verify JSON created
  - [ ] Test import → Verify data restored

- [ ] 10.3: Commit and push
  - Review all changes
  - Clean commits
  - Push to branch

**Acceptance Criteria:**
- ✅ All services production-ready
- ✅ Data safety proven
- ✅ Automatic backup working
- ✅ Code pushed to remote

**Deliverable:** Commit `chore: verify all services and data safety features`

---

## 📦 Deliverables Summary

At completion, you will have created:

### Core Services:
- ✅ `DataSyncService.swift` - CloudKit sync engine
- ✅ `SyncQueue.swift` - Offline queue with retry
- ✅ `NotificationService.swift` - Reminder scheduling
- ✅ `ImportExportService.swift` - Manual backup/restore
- ✅ `DataManager.swift` - SwiftData manager
- ✅ `NetworkMonitor.swift` - Network status tracking

### Features Implemented:
- ✅ **Automatic iCloud backup** - Every change synced
- ✅ **Offline support** - Works without internet
- ✅ **Conflict resolution** - Last-write-wins with local priority
- ✅ **Retry queue** - Failed syncs retry automatically
- ✅ **Export/Import** - Manual JSON/CSV backup
- ✅ **Push notifications** - Real-time sync across devices
- ✅ **Smart reminders** - Scheduled notifications
- ✅ **Data safety** - Multiple layers of protection

### Tests:
- ✅ 15+ service unit tests
- ✅ All tests passing

---

## 🔒 Data Safety Features Summary

Your data is protected by:

1. **Primary Backup: iCloud CloudKit**
   - Automatic sync every 2 seconds after changes
   - Encrypted in transit and at rest
   - Free tier (1GB storage, unlimited requests for personal use)

2. **Local Persistence: SwiftData**
   - Full copy of data always on device
   - Works offline indefinitely

3. **Offline Queue: Persistent Retry**
   - Failed syncs queued to UserDefaults
   - Automatic retry (up to 5 attempts)
   - Never lose changes

4. **Conflict Resolution: Smart Merge**
   - Last-write-wins (newest data kept)
   - Local pending changes prioritized
   - No data loss on conflicts

5. **Soft Delete: 30-Day Recovery**
   - Deleted items marked, not removed
   - Can be recovered within 30 days
   - Permanent delete after 30 days

6. **Manual Export: JSON/CSV Backup**
   - Export full database anytime
   - Human-readable JSON format
   - Import to restore

---

## 🚨 Critical Notes

1. **Data safety is the TOP PRIORITY**
2. **Test sync thoroughly** before marking complete
3. **Verify offline queue** works as expected
4. **Test import/export** with real data
5. **This service layer is mission-critical**

---

## 🎯 Success Criteria

- [ ] All services compile and work
- [ ] Sync works bidirectionally
- [ ] Offline mode fully functional
- [ ] Conflict resolution proven
- [ ] Export/import tested
- [ ] All tests pass
- [ ] **Data is provably safe and backed up**

---

## 📞 Handoff to Other Agents

Once complete, signal to:
- **Agent 4:** Services ready - you can integrate DataSyncService and NotificationService into UI
- **Agent 5:** Export ready - you can build settings UI with import/export buttons

**ESTIMATED COMPLETION TIME: 10-12 hours**

**Your users' data will be safer than Todoist!** 🔒🚀
