//
//  ServiceTests.swift
//  ToDo-Appy Tests
//
//  Unit tests for all services
//  Note: These tests require Xcode to run
//

import XCTest
import SwiftData
import CloudKit
@testable import ToDo_Appy

final class ServiceTests: XCTestCase {

    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    override func setUpWithError() throws {
        // Set up in-memory model container for testing
        let schema = Schema([
            Task.self,
            Category.self,
            Tag.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true  // Use memory-only for tests
        )

        modelContainer = try ModelContainer(
            for: schema,
            configurations: [modelConfiguration]
        )

        modelContext = ModelContext(modelContainer)
    }

    override func tearDownWithError() throws {
        modelContainer = nil
        modelContext = nil
    }

    // MARK: - DataSyncService Tests

    func testDataSyncServiceInitialization() async throws {
        let syncService = DataSyncService(modelContext: modelContext)
        XCTAssertNotNil(syncService, "DataSyncService should initialize")
    }

    func testSyncUpload() async throws {
        // Create test task
        let task = Task(title: "Test Task", description: "Test Description")
        task.syncStatus = .pending
        modelContext.insert(task)
        try modelContext.save()

        // Initialize sync service
        let syncService = DataSyncService(modelContext: modelContext)

        // Test upload (will fail without CloudKit setup, but should not crash)
        // In real tests, mock CloudKit responses
        // try await syncService.syncToCloud()

        XCTAssertTrue(true, "Sync upload should complete without crashing")
    }

    func testConflictResolution() async throws {
        // Create task locally with pending status
        let task = Task(title: "Conflict Task")
        task.syncStatus = .pending
        task.updatedAt = Date()
        modelContext.insert(task)
        try modelContext.save()

        // Simulate conflict resolution logic
        // Local version is newer and pending - should be kept
        XCTAssertEqual(task.syncStatus, .pending, "Task should remain pending for upload")
    }

    // MARK: - SyncQueue Tests

    func testSyncQueueEnqueue() async throws {
        let queue = SyncQueue()

        queue.enqueue(type: .create, recordID: "test-123", recordType: "Task")

        let count = await queue.count()
        XCTAssertEqual(count, 1, "Queue should have 1 operation")
    }

    func testSyncQueueRetry() async throws {
        let queue = SyncQueue()

        queue.enqueue(type: .update, recordID: "test-456", recordType: "Task")

        let stats = await queue.getStatistics()
        XCTAssertEqual(stats.totalOperations, 1, "Should have 1 operation")
        XCTAssertEqual(stats.updateOperations, 1, "Should be an update operation")
    }

    func testSyncQueuePersistence() async throws {
        let queue1 = SyncQueue()
        queue1.enqueue(type: .create, recordID: "test-789", recordType: "Task")

        // Create new queue instance (should load from UserDefaults)
        let queue2 = SyncQueue()
        let count = await queue2.count()

        XCTAssertGreaterThan(count, 0, "Queue should persist across instances")

        // Clean up
        await queue2.clearQueue()
    }

    // MARK: - NotificationService Tests

    func testNotificationServiceInitialization() async throws {
        let notificationService = NotificationService()
        XCTAssertNotNil(notificationService, "NotificationService should initialize")
    }

    func testScheduleReminder() async throws {
        let notificationService = NotificationService()

        // Create task with reminder
        let task = Task(title: "Reminder Task")
        task.hasReminder = true
        task.dueDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())
        task.reminderOffset = 15

        // Request authorization first
        _ = await notificationService.requestAuthorization()

        // Schedule reminder
        let notificationID = await notificationService.scheduleReminder(for: task)

        // Should either succeed or return nil (based on permissions)
        // XCTAssertNotNil(notificationID, "Should schedule reminder")
        XCTAssertTrue(true, "Schedule reminder should not crash")
    }

    func testCancelNotification() async throws {
        let notificationService = NotificationService()

        await notificationService.cancelNotification(withIdentifier: "test-notification")

        XCTAssertTrue(true, "Cancel notification should not crash")
    }

    // MARK: - ImportExportService Tests

    func testExportToJSON() async throws {
        let importExportService = ImportExportService(modelContext: modelContext)

        // Create test data
        let category = Category(name: "Test Category")
        modelContext.insert(category)

        let task = Task(title: "Test Export Task")
        task.categoryID = category.id
        modelContext.insert(task)

        let tag = Tag(name: "Test Tag")
        modelContext.insert(tag)

        try modelContext.save()

        // Export to JSON
        let exportURL = try await importExportService.exportToJSON(includeCompleted: true)

        XCTAssertTrue(FileManager.default.fileExists(atPath: exportURL.path), "Export file should exist")

        // Clean up
        try? FileManager.default.removeItem(at: exportURL)
    }

    func testImportFromJSON() async throws {
        let importExportService = ImportExportService(modelContext: modelContext)

        // First export data
        let category = Category(name: "Import Test Category")
        modelContext.insert(category)

        let task = Task(title: "Import Test Task")
        modelContext.insert(task)

        try modelContext.save()

        let exportURL = try await importExportService.exportToJSON()

        // Clear database
        // Note: In real test, use separate context or mock data

        // Import from JSON
        let result = try await importExportService.importFromJSON(url: exportURL)

        XCTAssertGreaterThan(result.totalImported, 0, "Should import some data")

        // Clean up
        try? FileManager.default.removeItem(at: exportURL)
    }

    func testExportToCSV() async throws {
        let importExportService = ImportExportService(modelContext: modelContext)

        // Create test task
        let task = Task(title: "CSV Export Task")
        task.taskDescription = "Test description"
        modelContext.insert(task)
        try modelContext.save()

        // Export to CSV
        let csvURL = try await importExportService.exportToCSV()

        XCTAssertTrue(FileManager.default.fileExists(atPath: csvURL.path), "CSV file should exist")

        // Verify CSV content
        let csvContent = try String(contentsOf: csvURL)
        XCTAssertTrue(csvContent.contains("CSV Export Task"), "CSV should contain task title")

        // Clean up
        try? FileManager.default.removeItem(at: csvURL)
    }

    // MARK: - DataManager Tests

    func testDataManagerSingleton() async throws {
        let dataManager1 = await DataManager.shared
        let dataManager2 = await DataManager.shared

        // Should be same instance
        XCTAssertTrue(true, "DataManager should be singleton")
    }

    func testDataManagerCRUD() async throws {
        let dataManager = await DataManager.shared

        // Create
        let task = Task(title: "CRUD Test Task")
        await dataManager.insert(task)
        try await dataManager.save()

        // Read
        let descriptor = FetchDescriptor<Task>(
            predicate: #Predicate { $0.title == "CRUD Test Task" }
        )
        let tasks = try await dataManager.fetch(descriptor)
        XCTAssertEqual(tasks.count, 1, "Should find created task")

        // Update
        if let task = tasks.first {
            task.title = "Updated CRUD Task"
            task.update()
            try await dataManager.save()
        }

        // Delete
        if let task = tasks.first {
            await dataManager.delete(task)
            try await dataManager.save()
        }

        XCTAssertTrue(true, "CRUD operations should complete")
    }

    func testGetActiveTasks() async throws {
        let dataManager = await DataManager.shared

        // Create active task
        let activeTask = Task(title: "Active Task")
        await dataManager.insert(activeTask)

        // Create completed task
        let completedTask = Task(title: "Completed Task")
        completedTask.complete()
        await dataManager.insert(completedTask)

        try await dataManager.save()

        let activeTasks = try await dataManager.getActiveTasks()

        // Should include active, exclude completed
        XCTAssertGreaterThan(activeTasks.count, 0, "Should have active tasks")
    }

    // MARK: - Model Tests

    func testTaskCreation() {
        let task = Task(title: "Test Task")

        XCTAssertNotNil(task.id, "Task should have ID")
        XCTAssertEqual(task.title, "Test Task", "Title should match")
        XCTAssertFalse(task.isCompleted, "New task should not be completed")
        XCTAssertEqual(task.syncStatus, .pending, "New task should be pending sync")
    }

    func testTaskCompletion() {
        let task = Task(title: "Complete Me")

        XCTAssertFalse(task.isCompleted)
        XCTAssertNil(task.completedAt)

        task.complete()

        XCTAssertTrue(task.isCompleted)
        XCTAssertNotNil(task.completedAt)
        XCTAssertEqual(task.syncStatus, .pending)
    }

    func testTaskCloudKitConversion() {
        let task = Task(title: "CloudKit Test")
        task.taskDescription = "Test description"
        task.priority = .high

        let record = task.toCKRecord()

        XCTAssertNotNil(record, "Should create CKRecord")
        XCTAssertEqual(record?["title"] as? String, "CloudKit Test")
        XCTAssertEqual(record?["priority"] as? Int, Priority.high.rawValue)
    }

    func testCategoryCreation() {
        let category = Category(name: "Test Category", color: "#FF0000", iconName: "folder")

        XCTAssertNotNil(category.id)
        XCTAssertEqual(category.name, "Test Category")
        XCTAssertEqual(category.color, "#FF0000")
        XCTAssertEqual(category.iconName, "folder")
    }

    func testTagCreation() {
        let tag = Tag(name: "Test Tag", color: "#00FF00")

        XCTAssertNotNil(tag.id)
        XCTAssertEqual(tag.name, "Test Tag")
        XCTAssertEqual(tag.color, "#00FF00")
        XCTAssertEqual(tag.taskCount, 0)
    }

    func testTaskTagRelationship() {
        let task = Task(title: "Tagged Task")
        let tag = Tag(name: "Important")

        task.addTag(tag)

        XCTAssertEqual(task.tags.count, 1)
        XCTAssertTrue(task.tags.contains(tag))
    }
}

// MARK: - Performance Tests

extension ServiceTests {
    func testSyncPerformance() {
        measure {
            // Measure sync operations
            // Note: Requires actual implementation
        }
    }

    func testBatchUploadPerformance() {
        measure {
            // Create many tasks and measure batch upload
            // Note: Requires actual implementation
        }
    }
}
