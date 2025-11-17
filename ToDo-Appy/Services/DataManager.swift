//
//  DataManager.swift
//  ToDo-Appy
//
//  Central SwiftData manager for app-wide data access
//  Provides singleton access to ModelContainer and ModelContext
//

import SwiftData
import Foundation

/// Singleton actor for managing SwiftData container and context
actor DataManager {

    // MARK: - Singleton

    static let shared = DataManager()

    // MARK: - Properties

    private(set) var modelContainer: ModelContainer!
    private(set) var modelContext: ModelContext!

    /// Shared sync service instance
    private(set) var syncService: DataSyncService!

    /// Shared notification service instance
    private(set) var notificationService: NotificationService!

    /// Shared import/export service instance
    private(set) var importExportService: ImportExportService!

    /// Shared sync queue instance
    private(set) var syncQueue: SyncQueue!

    // MARK: - Initialization

    private init() {
        setupContainer()
        setupServices()
    }

    // MARK: - Setup

    /// Set up SwiftData container with CloudKit integration
    private func setupContainer() {
        // Define schema with all models
        let schema = Schema([
            Task.self,
            Category.self,
            Tag.self
        ])

        // Configure model with CloudKit integration
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,  // Persist to disk
            allowsSave: true,
            cloudKitDatabase: .private("iCloud.com.personal.todoappy")
        )

        do {
            // Create container
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )

            // Create main context
            modelContext = ModelContext(modelContainer)

            // Configure context
            modelContext.autosaveEnabled = true

            print("✅ SwiftData container initialized successfully")
            print("📦 Schema: Task, Category, Tag")
            print("☁️ CloudKit: iCloud.com.personal.todoappy")

        } catch {
            fatalError("❌ Failed to initialize ModelContainer: \(error.localizedDescription)")
        }
    }

    /// Set up service instances
    private func setupServices() {
        // Initialize services with shared context
        syncService = DataSyncService(modelContext: modelContext)
        notificationService = NotificationService()
        importExportService = ImportExportService(modelContext: modelContext)
        syncQueue = SyncQueue()

        print("✅ Services initialized")
    }

    // MARK: - CRUD Operations

    /// Save changes to persistent storage
    func save() throws {
        try modelContext.save()
        print("💾 Context saved")
    }

    /// Fetch models using a descriptor
    func fetch<T: PersistentModel>(_ descriptor: FetchDescriptor<T>) throws -> [T] {
        return try modelContext.fetch(descriptor)
    }

    /// Insert a new model
    func insert<T: PersistentModel>(_ model: T) {
        modelContext.insert(model)
        print("➕ Inserted: \(T.self)")
    }

    /// Delete a model
    func delete<T: PersistentModel>(_ model: T) {
        modelContext.delete(model)
        print("🗑️ Deleted: \(T.self)")
    }

    // MARK: - Batch Operations

    /// Delete all models of a specific type
    func deleteAll<T: PersistentModel>(_ type: T.Type) throws {
        let descriptor = FetchDescriptor<T>()
        let models = try modelContext.fetch(descriptor)

        for model in models {
            modelContext.delete(model)
        }

        try save()
        print("🗑️ Deleted all \(models.count) \(T.self) instances")
    }

    /// Count models of a specific type
    func count<T: PersistentModel>(_ type: T.Type, predicate: Predicate<T>? = nil) throws -> Int {
        let descriptor = FetchDescriptor<T>(predicate: predicate)
        let models = try modelContext.fetch(descriptor)
        return models.count
    }

    // MARK: - Task-Specific Operations

    /// Get all active tasks (not deleted, not completed)
    func getActiveTasks() throws -> [Task] {
        let descriptor = FetchDescriptor<Task>(
            predicate: #Predicate { !$0.isDeleted && !$0.isCompleted },
            sortBy: [SortDescriptor(\Task.createdAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    /// Get tasks due today
    func getTasksDueToday() throws -> [Task] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!

        let descriptor = FetchDescriptor<Task>(
            predicate: #Predicate { task in
                !task.isDeleted &&
                !task.isCompleted &&
                task.dueDate != nil &&
                task.dueDate! >= today &&
                task.dueDate! < tomorrow
            },
            sortBy: [SortDescriptor(\Task.dueDate)]
        )
        return try modelContext.fetch(descriptor)
    }

    /// Get overdue tasks
    func getOverdueTasks() throws -> [Task] {
        let now = Date()

        let descriptor = FetchDescriptor<Task>(
            predicate: #Predicate { task in
                !task.isDeleted &&
                !task.isCompleted &&
                task.dueDate != nil &&
                task.dueDate! < now
            },
            sortBy: [SortDescriptor(\Task.dueDate)]
        )
        return try modelContext.fetch(descriptor)
    }

    /// Get high priority tasks
    func getHighPriorityTasks() throws -> [Task] {
        let descriptor = FetchDescriptor<Task>(
            predicate: #Predicate { task in
                !task.isDeleted &&
                !task.isCompleted &&
                (task.priority == .high || task.priority == .urgent)
            },
            sortBy: [SortDescriptor(\Task.priority, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    /// Get completed tasks
    func getCompletedTasks() throws -> [Task] {
        let descriptor = FetchDescriptor<Task>(
            predicate: #Predicate { $0.isCompleted && !$0.isDeleted },
            sortBy: [SortDescriptor(\Task.updatedAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    /// Get tasks by category
    func getTasks(for category: Category) throws -> [Task] {
        let categoryID = category.id

        let descriptor = FetchDescriptor<Task>(
            predicate: #Predicate { task in
                !task.isDeleted &&
                task.categoryID == categoryID
            },
            sortBy: [SortDescriptor(\Task.createdAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    /// Get tasks by tag
    func getTasks(for tag: Tag) throws -> [Task] {
        let tagID = tag.id

        let descriptor = FetchDescriptor<Task>(
            predicate: #Predicate { task in
                !task.isDeleted &&
                task.tags.contains { $0.id == tagID }
            },
            sortBy: [SortDescriptor(\Task.createdAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    // MARK: - Category Operations

    /// Get all categories
    func getAllCategories() throws -> [Category] {
        let descriptor = FetchDescriptor<Category>(
            predicate: #Predicate { !$0.isDeleted },
            sortBy: [SortDescriptor(\Category.name)]
        )
        return try modelContext.fetch(descriptor)
    }

    /// Find category by name
    func findCategory(named name: String) throws -> Category? {
        let descriptor = FetchDescriptor<Category>(
            predicate: #Predicate { $0.name == name && !$0.isDeleted }
        )
        return try modelContext.fetch(descriptor).first
    }

    // MARK: - Tag Operations

    /// Get all tags
    func getAllTags() throws -> [Tag] {
        let descriptor = FetchDescriptor<Tag>(
            predicate: #Predicate { !$0.isDeleted },
            sortBy: [SortDescriptor(\Tag.name)]
        )
        return try modelContext.fetch(descriptor)
    }

    /// Find tag by name
    func findTag(named name: String) throws -> Tag? {
        let descriptor = FetchDescriptor<Tag>(
            predicate: #Predicate { $0.name == name && !$0.isDeleted }
        )
        return try modelContext.fetch(descriptor).first
    }

    // MARK: - Cleanup Operations

    /// Permanently delete soft-deleted items older than 30 days
    func cleanupOldDeletedItems() throws {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -30, to: Date())!

        // Clean up tasks
        let taskDescriptor = FetchDescriptor<Task>(
            predicate: #Predicate { task in
                task.isDeleted &&
                task.deletedAt != nil &&
                task.deletedAt! < cutoffDate
            }
        )
        let tasksToDelete = try modelContext.fetch(taskDescriptor)

        for task in tasksToDelete {
            modelContext.delete(task)
        }

        // Clean up categories
        let categoryDescriptor = FetchDescriptor<Category>(
            predicate: #Predicate { category in
                category.isDeleted &&
                category.deletedAt != nil &&
                category.deletedAt! < cutoffDate
            }
        )
        let categoriesToDelete = try modelContext.fetch(categoryDescriptor)

        for category in categoriesToDelete {
            modelContext.delete(category)
        }

        // Clean up tags
        let tagDescriptor = FetchDescriptor<Tag>(
            predicate: #Predicate { tag in
                tag.isDeleted &&
                tag.deletedAt != nil &&
                tag.deletedAt! < cutoffDate
            }
        )
        let tagsToDelete = try modelContext.fetch(tagDescriptor)

        for tag in tagsToDelete {
            modelContext.delete(tag)
        }

        try save()

        let totalDeleted = tasksToDelete.count + categoriesToDelete.count + tagsToDelete.count
        if totalDeleted > 0 {
            print("🧹 Permanently deleted \(totalDeleted) items older than 30 days")
        }
    }

    // MARK: - Statistics

    /// Get database statistics
    func getStatistics() throws -> DatabaseStatistics {
        let totalTasks = try count(Task.self)
        let activeTasks = try count(Task.self, predicate: #Predicate { !$0.isDeleted && !$0.isCompleted })
        let completedTasks = try count(Task.self, predicate: #Predicate { $0.isCompleted && !$0.isDeleted })
        let deletedTasks = try count(Task.self, predicate: #Predicate { $0.isDeleted })

        let totalCategories = try count(Category.self)
        let activeCategories = try count(Category.self, predicate: #Predicate { !$0.isDeleted })

        let totalTags = try count(Tag.self)
        let activeTags = try count(Tag.self, predicate: #Predicate { !$0.isDeleted })

        return DatabaseStatistics(
            totalTasks: totalTasks,
            activeTasks: activeTasks,
            completedTasks: completedTasks,
            deletedTasks: deletedTasks,
            totalCategories: totalCategories,
            activeCategories: activeCategories,
            totalTags: totalTags,
            activeTags: activeTags
        )
    }

    struct DatabaseStatistics {
        let totalTasks: Int
        let activeTasks: Int
        let completedTasks: Int
        let deletedTasks: Int
        let totalCategories: Int
        let activeCategories: Int
        let totalTags: Int
        let activeTags: Int

        var description: String {
            """
            📊 Database Statistics:
            Tasks: \(totalTasks) total (\(activeTasks) active, \(completedTasks) completed, \(deletedTasks) deleted)
            Categories: \(totalCategories) total (\(activeCategories) active)
            Tags: \(totalTags) total (\(activeTags) active)
            """
        }
    }
}

// MARK: - Public Accessors for Services

extension DataManager {
    /// Get sync service
    func getSyncService() -> DataSyncService {
        return syncService
    }

    /// Get notification service
    func getNotificationService() -> NotificationService {
        return notificationService
    }

    /// Get import/export service
    func getImportExportService() -> ImportExportService {
        return importExportService
    }

    /// Get sync queue
    func getSyncQueue() -> SyncQueue {
        return syncQueue
    }
}
