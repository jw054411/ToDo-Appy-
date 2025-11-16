//
//  ImportExportService.swift
//  ToDo-Appy
//
//  Import/Export service for manual data backups
//  Supports JSON (full data) and CSV (basic data) formats
//

import Foundation
import SwiftData

/// Actor-based import/export service for manual backup and restore
actor ImportExportService {

    // MARK: - Properties

    private let modelContext: ModelContext

    // MARK: - Initialization

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Export to JSON

    /// Export all data to JSON format
    /// - Parameter includeCompleted: Whether to include completed tasks
    /// - Returns: URL to the exported JSON file in temporary directory
    func exportToJSON(includeCompleted: Bool = true) async throws -> URL {
        print("📤 Exporting data to JSON...")

        // Fetch all data
        let taskPredicate = includeCompleted ? nil : #Predicate<Task> { !$0.isCompleted }
        let taskDescriptor = FetchDescriptor<Task>(predicate: taskPredicate)
        let tasks = try modelContext.fetch(taskDescriptor)

        let categoryDescriptor = FetchDescriptor<Category>()
        let categories = try modelContext.fetch(categoryDescriptor)

        let tagDescriptor = FetchDescriptor<Tag>()
        let tags = try modelContext.fetch(tagDescriptor)

        print("📊 Exporting \(tasks.count) tasks, \(categories.count) categories, \(tags.count) tags")

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
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        encoder.dateEncodingStrategy = .iso8601
        let jsonData = try encoder.encode(exportData)

        // Save to file in temporary directory
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate, .withTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
        let timestamp = dateFormatter.string(from: Date()).replacingOccurrences(of: ":", with: "-")

        let filename = "TodoAppy-Backup-\(timestamp).json"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)

        try jsonData.write(to: tempURL, options: .atomic)

        print("✅ Exported to \(tempURL.path)")
        print("📦 File size: \(ByteCountFormatter.string(fromByteCount: Int64(jsonData.count), countStyle: .file))")

        return tempURL
    }

    // MARK: - Import from JSON

    /// Import data from JSON file
    /// - Parameter url: URL to the JSON backup file
    /// - Returns: Import result with statistics
    func importFromJSON(url: URL) async throws -> ImportResult {
        print("📥 Importing data from JSON...")

        // Read file
        let jsonData = try Data(contentsOf: url)
        print("📦 File size: \(ByteCountFormatter.string(fromByteCount: Int64(jsonData.count), countStyle: .file))")

        // Decode JSON
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let importData = try decoder.decode(ExportData.self, from: jsonData)

        print("📊 Found \(importData.tasks.count) tasks, \(importData.categories.count) categories, \(importData.tags.count) tags")
        print("📅 Backup created: \(importData.exportDate.formatted())")
        print("📝 Backup version: \(importData.version)")

        var result = ImportResult()

        // Import categories first (tasks depend on them)
        for categoryData in importData.categories {
            // Check if category already exists
            let descriptor = FetchDescriptor<Category>(
                predicate: #Predicate { $0.id == categoryData.id }
            )
            let existing = try modelContext.fetch(descriptor)

            if existing.isEmpty {
                let category = categoryData.toCategory()
                modelContext.insert(category)
                result.categoriesImported += 1
                print("➕ Imported category: \(category.name)")
            } else {
                result.categoriesSkipped += 1
                print("⏭️ Skipped existing category: \(categoryData.name)")
            }
        }

        // Import tags
        for tagData in importData.tags {
            let descriptor = FetchDescriptor<Tag>(
                predicate: #Predicate { $0.id == tagData.id }
            )
            let existing = try modelContext.fetch(descriptor)

            if existing.isEmpty {
                let tag = tagData.toTag()
                modelContext.insert(tag)
                result.tagsImported += 1
                print("➕ Imported tag: \(tag.name)")
            } else {
                result.tagsSkipped += 1
                print("⏭️ Skipped existing tag: \(tagData.name)")
            }
        }

        // Import tasks
        for taskData in importData.tasks {
            let descriptor = FetchDescriptor<Task>(
                predicate: #Predicate { $0.id == taskData.id }
            )
            let existing = try modelContext.fetch(descriptor)

            if existing.isEmpty {
                let task = taskData.toTask(modelContext: modelContext)
                modelContext.insert(task)
                result.tasksImported += 1
                print("➕ Imported task: \(task.title)")
            } else {
                result.tasksSkipped += 1
                print("⏭️ Skipped existing task: \(taskData.title)")
            }
        }

        // Save all changes
        try modelContext.save()

        print("✅ Import complete:")
        print("   Tasks: \(result.tasksImported) imported, \(result.tasksSkipped) skipped")
        print("   Categories: \(result.categoriesImported) imported, \(result.categoriesSkipped) skipped")
        print("   Tags: \(result.tagsImported) imported, \(result.tagsSkipped) skipped")

        return result
    }

    // MARK: - Export to CSV

    /// Export tasks to CSV format (simplified, spreadsheet-compatible)
    /// - Returns: URL to the exported CSV file
    func exportToCSV() async throws -> URL {
        print("📤 Exporting tasks to CSV...")

        let descriptor = FetchDescriptor<Task>()
        let tasks = try modelContext.fetch(descriptor)

        // CSV header
        var csvString = "ID,Title,Description,Completed,Due Date,Priority,Category,Tags,Created,Updated\n"

        // CSV rows
        for task in tasks {
            let fields = [
                task.id.csvEscaped,
                task.title.csvEscaped,
                task.taskDescription.csvEscaped,
                task.isCompleted ? "Yes" : "No",
                task.dueDate?.ISO8601Format() ?? "",
                task.priority.displayName,
                task.category?.name ?? "",
                task.tags.map { $0.name }.joined(separator: "; ").csvEscaped,
                task.createdAt.ISO8601Format(),
                task.updatedAt.ISO8601Format()
            ]
            csvString += fields.joined(separator: ",") + "\n"
        }

        // Save to file
        let timestamp = ISO8601DateFormatter().string(from: Date()).replacingOccurrences(of: ":", with: "-")
        let filename = "TodoAppy-Export-\(timestamp).csv"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)

        try csvString.write(to: tempURL, atomically: true, encoding: .utf8)

        print("✅ Exported \(tasks.count) tasks to CSV")
        print("📦 File: \(tempURL.path)")

        return tempURL
    }

    // MARK: - File Management

    /// Get list of all backup files in Documents directory
    func getBackupFiles() throws -> [URL] {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

        let files = try FileManager.default.contentsOfDirectory(
            at: documentsURL,
            includingPropertiesForKeys: [.creationDateKey, .fileSizeKey],
            options: [.skipsHiddenFiles]
        )

        // Filter for backup files
        let backupFiles = files.filter { url in
            url.lastPathComponent.hasPrefix("TodoAppy-Backup-") && url.pathExtension == "json"
        }

        // Sort by creation date (newest first)
        return backupFiles.sorted { url1, url2 in
            guard let date1 = try? url1.resourceValues(forKeys: [.creationDateKey]).creationDate,
                  let date2 = try? url2.resourceValues(forKeys: [.creationDateKey]).creationDate else {
                return false
            }
            return date1 > date2
        }
    }

    /// Delete a backup file
    func deleteBackup(at url: URL) throws {
        try FileManager.default.removeItem(at: url)
        print("🗑️ Deleted backup: \(url.lastPathComponent)")
    }

    /// Get total size of all backups
    func getTotalBackupSize() throws -> Int64 {
        let backups = try getBackupFiles()
        var totalSize: Int64 = 0

        for url in backups {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            if let size = attributes[.size] as? Int64 {
                totalSize += size
            }
        }

        return totalSize
    }
}

// MARK: - Export Data Structures

/// Root export data structure
struct ExportData: Codable {
    let version: String
    let exportDate: Date
    let tasks: [TaskExportModel]
    let categories: [CategoryExportModel]
    let tags: [TagExportModel]
}

/// Exportable task model
struct TaskExportModel: Codable {
    let id: String
    let title: String
    let taskDescription: String
    let isCompleted: Bool
    let priority: Int
    let dueDate: Date?
    let createdAt: Date
    let updatedAt: Date
    let categoryID: String?
    let tagIDs: [String]
    let hasReminder: Bool
    let reminderTime: Date?
    let reminderOffset: Int
    let isRecurring: Bool
    let recurrenceRule: String?

    init(from task: Task) {
        self.id = task.id
        self.title = task.title
        self.taskDescription = task.taskDescription
        self.isCompleted = task.isCompleted
        self.priority = task.priority.rawValue
        self.dueDate = task.dueDate
        self.createdAt = task.createdAt
        self.updatedAt = task.updatedAt
        self.categoryID = task.categoryID
        self.tagIDs = task.tags.map { $0.id }
        self.hasReminder = task.hasReminder
        self.reminderTime = task.reminderTime
        self.reminderOffset = task.reminderOffset
        self.isRecurring = task.isRecurring
        self.recurrenceRule = task.recurrenceRule
    }

    func toTask(modelContext: ModelContext) -> Task {
        let task = Task(title: title)
        task.id = id
        task.taskDescription = taskDescription
        task.isCompleted = isCompleted
        task.priority = Priority(rawValue: priority) ?? .none
        task.dueDate = dueDate
        task.createdAt = createdAt
        task.updatedAt = updatedAt
        task.categoryID = categoryID
        task.hasReminder = hasReminder
        task.reminderTime = reminderTime
        task.reminderOffset = reminderOffset
        task.isRecurring = isRecurring
        task.recurrenceRule = recurrenceRule
        task.syncStatus = .pending // Mark for sync after import

        // Note: Tags will need to be linked after all tags are imported
        // This should be done in a second pass

        return task
    }
}

/// Exportable category model
struct CategoryExportModel: Codable {
    let id: String
    let name: String
    let color: String
    let iconName: String
    let createdAt: Date

    init(from category: Category) {
        self.id = category.id
        self.name = category.name
        self.color = category.color
        self.iconName = category.iconName
        self.createdAt = category.createdAt
    }

    func toCategory() -> Category {
        let category = Category(name: name, color: color, iconName: iconName)
        category.id = id
        category.createdAt = createdAt
        category.syncStatus = .pending
        return category
    }
}

/// Exportable tag model
struct TagExportModel: Codable {
    let id: String
    let name: String
    let color: String
    let createdAt: Date

    init(from tag: Tag) {
        self.id = tag.id
        self.name = tag.name
        self.color = tag.color
        self.createdAt = tag.createdAt
    }

    func toTag() -> Tag {
        let tag = Tag(name: name, color: color)
        tag.id = id
        tag.createdAt = createdAt
        tag.syncStatus = .pending
        return tag
    }
}

// MARK: - Import Result

/// Result of an import operation
struct ImportResult {
    var tasksImported = 0
    var tasksSkipped = 0
    var categoriesImported = 0
    var categoriesSkipped = 0
    var tagsImported = 0
    var tagsSkipped = 0

    var totalImported: Int {
        tasksImported + categoriesImported + tagsImported
    }

    var totalSkipped: Int {
        tasksSkipped + categoriesSkipped + tagsSkipped
    }

    var description: String {
        """
        Import Results:
        ✅ Imported: \(totalImported) (\(tasksImported) tasks, \(categoriesImported) categories, \(tagsImported) tags)
        ⏭️ Skipped: \(totalSkipped) (\(tasksSkipped) tasks, \(categoriesSkipped) categories, \(tagsSkipped) tags)
        """
    }
}

// MARK: - String Extension for CSV

extension String {
    /// Escape string for CSV format
    var csvEscaped: String {
        // Wrap in quotes and escape existing quotes
        let escaped = self.replacingOccurrences(of: "\"", with: "\"\"")
        return "\"\(escaped)\""
    }
}
