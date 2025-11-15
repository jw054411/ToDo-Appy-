# Data Models & Schema Design

## Overview

This document provides detailed specifications for all data models used in ToDo Appy, including local SwiftData models, CloudKit schemas, and transformation logic.

## Entity Relationship Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                         Task                                │
├─────────────────────────────────────────────────────────────┤
│ PK  id: UUID                                                │
│     title: String                                           │
│     taskDescription: String?                                │
│     isCompleted: Bool                                       │
│     createdAt: Date                                         │
│     updatedAt: Date                                         │
│     dueDate: Date?                                          │
│     completedAt: Date?                                      │
│     priority: Priority?                                     │
│     reminderDate: Date?                                     │
│     sortOrder: Int                                          │
│                                                             │
│ FK  category: Category?                                     │
│ FK  parentTask: Task?                                       │
│     subtasks: [Task]?                                       │
│     tags: [Tag]?                                            │
│                                                             │
│     // Sync metadata                                        │
│     cloudKitRecordID: String?                               │
│     lastSyncedAt: Date?                                     │
│     syncStatus: SyncStatus                                  │
│     changeToken: String?                                    │
│     isDeleted: Bool                                         │
└──────────────┬──────────────────────┬───────────────────────┘
               │                      │
               │ Many-to-One          │ Many-to-Many
               ↓                      ↓
┌──────────────────────┐   ┌─────────────────────┐
│      Category        │   │        Tag          │
├──────────────────────┤   ├─────────────────────┤
│ PK  id: UUID         │   │ PK  id: UUID        │
│     name: String     │   │     name: String    │
│     colorHex: String │   │     createdAt: Date │
│     iconName: String?│   │                     │
│     sortOrder: Int   │   │ // Sync metadata    │
│     createdAt: Date  │   │ cloudKitRecordID    │
│                      │   │ lastSyncedAt        │
│ // Sync metadata     │   │ syncStatus          │
│ cloudKitRecordID     │   │ isDeleted           │
│ lastSyncedAt         │   └─────────────────────┘
│ syncStatus           │
│ isDeleted            │
│                      │
│     tasks: [Task]?   │
└──────────────────────┘
```

## SwiftData Models (Complete Implementation)

### Task Model

```swift
import SwiftData
import Foundation

@Model
final class Task {
    // MARK: - Primary Attributes

    @Attribute(.unique) var id: UUID
    var title: String
    var taskDescription: String?
    var isCompleted: Bool
    var sortOrder: Int

    // MARK: - Timestamps

    var createdAt: Date
    var updatedAt: Date
    var dueDate: Date?
    var completedAt: Date?
    var reminderDate: Date?

    // MARK: - Task Properties

    var priorityRawValue: String?
    var priority: Priority? {
        get {
            guard let raw = priorityRawValue else { return nil }
            return Priority(rawValue: raw)
        }
        set {
            priorityRawValue = newValue?.rawValue
        }
    }

    // MARK: - Relationships

    @Relationship(deleteRule: .nullify)
    var category: Category?

    @Relationship(deleteRule: .cascade, inverse: \Task.parentTask)
    var subtasks: [Task]?

    @Relationship(inverse: \Task.subtasks)
    var parentTask: Task?

    @Relationship
    var tags: [Tag]?

    // MARK: - Sync Metadata

    var cloudKitRecordID: String?
    var lastSyncedAt: Date?
    var syncStatusRawValue: String
    var syncStatus: SyncStatus {
        get { SyncStatus(rawValue: syncStatusRawValue) ?? .pending }
        set { syncStatusRawValue = newValue.rawValue }
    }
    var changeToken: String?
    var isDeleted: Bool

    // MARK: - Computed Properties

    var isOverdue: Bool {
        guard let dueDate = dueDate, !isCompleted else { return false }
        return dueDate < Date()
    }

    var isDueToday: Bool {
        guard let dueDate = dueDate else { return false }
        return Calendar.current.isDateInToday(dueDate)
    }

    var isDueSoon: Bool {
        guard let dueDate = dueDate, !isCompleted else { return false }
        let threeDaysFromNow = Calendar.current.date(byAdding: .day, value: 3, to: Date())!
        return dueDate <= threeDaysFromNow && dueDate >= Date()
    }

    var hasReminder: Bool {
        reminderDate != nil
    }

    var completionRate: Double {
        guard let subtasks = subtasks, !subtasks.isEmpty else { return 0 }
        let completed = subtasks.filter { $0.isCompleted }.count
        return Double(completed) / Double(subtasks.count)
    }

    // MARK: - Initialization

    init(
        title: String,
        description: String? = nil,
        dueDate: Date? = nil,
        priority: Priority? = nil,
        category: Category? = nil,
        reminderDate: Date? = nil,
        sortOrder: Int = 0
    ) {
        self.id = UUID()
        self.title = title
        self.taskDescription = description
        self.isCompleted = false
        self.createdAt = Date()
        self.updatedAt = Date()
        self.dueDate = dueDate
        self.priority = priority
        self.category = category
        self.reminderDate = reminderDate
        self.sortOrder = sortOrder
        self.syncStatusRawValue = SyncStatus.pending.rawValue
        self.isDeleted = false
    }

    // MARK: - Methods

    func toggleCompletion() {
        isCompleted.toggle()
        completedAt = isCompleted ? Date() : nil
        updatedAt = Date()
        syncStatus = .pending
    }

    func markForDeletion() {
        isDeleted = true
        updatedAt = Date()
        syncStatus = .pending
    }

    func addSubtask(_ subtask: Task) {
        if subtasks == nil {
            subtasks = []
        }
        subtasks?.append(subtask)
        subtask.parentTask = self
        updatedAt = Date()
        syncStatus = .pending
    }

    func removeSubtask(_ subtask: Task) {
        subtasks?.removeAll { $0.id == subtask.id }
        updatedAt = Date()
        syncStatus = .pending
    }

    func addTag(_ tag: Tag) {
        if tags == nil {
            tags = []
        }
        if !(tags?.contains(where: { $0.id == tag.id }) ?? false) {
            tags?.append(tag)
            updatedAt = Date()
            syncStatus = .pending
        }
    }

    func removeTag(_ tag: Tag) {
        tags?.removeAll { $0.id == tag.id }
        updatedAt = Date()
        syncStatus = .pending
    }

    func update(
        title: String? = nil,
        description: String? = nil,
        dueDate: Date? = nil,
        priority: Priority? = nil,
        category: Category? = nil,
        reminderDate: Date? = nil
    ) {
        if let title = title { self.title = title }
        if let description = description { self.taskDescription = description }
        if let dueDate = dueDate { self.dueDate = dueDate }
        if let priority = priority { self.priority = priority }
        if let category = category { self.category = category }
        if let reminderDate = reminderDate { self.reminderDate = reminderDate }

        self.updatedAt = Date()
        self.syncStatus = .pending
    }
}

// MARK: - Supporting Enums

enum Priority: String, Codable, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case urgent = "urgent"

    var displayName: String {
        rawValue.capitalized
    }

    var color: String {
        switch self {
        case .low: return "#4CAF50"      // Green
        case .medium: return "#FFC107"   // Yellow
        case .high: return "#FF9800"     // Orange
        case .urgent: return "#F44336"   // Red
        }
    }

    var sortOrder: Int {
        switch self {
        case .urgent: return 0
        case .high: return 1
        case .medium: return 2
        case .low: return 3
        }
    }
}

enum SyncStatus: String, Codable {
    case synced = "synced"
    case pending = "pending"
    case syncing = "syncing"
    case conflict = "conflict"
    case error = "error"

    var displayName: String {
        switch self {
        case .synced: return "Synced"
        case .pending: return "Pending Sync"
        case .syncing: return "Syncing..."
        case .conflict: return "Conflict"
        case .error: return "Sync Error"
        }
    }

    var iconName: String {
        switch self {
        case .synced: return "checkmark.icloud"
        case .pending: return "clock"
        case .syncing: return "arrow.triangle.2.circlepath"
        case .conflict: return "exclamationmark.triangle"
        case .error: return "xmark.icloud"
        }
    }
}
```

### Category Model

```swift
import SwiftData
import Foundation

@Model
final class Category {
    // MARK: - Primary Attributes

    @Attribute(.unique) var id: UUID
    var name: String
    var colorHex: String
    var iconName: String?
    var sortOrder: Int
    var createdAt: Date

    // MARK: - Relationships

    @Relationship(deleteRule: .nullify, inverse: \Task.category)
    var tasks: [Task]?

    // MARK: - Sync Metadata

    var cloudKitRecordID: String?
    var lastSyncedAt: Date?
    var syncStatusRawValue: String
    var syncStatus: SyncStatus {
        get { SyncStatus(rawValue: syncStatusRawValue) ?? .pending }
        set { syncStatusRawValue = newValue.rawValue }
    }
    var isDeleted: Bool

    // MARK: - Computed Properties

    var taskCount: Int {
        tasks?.filter { !$0.isDeleted }.count ?? 0
    }

    var completedTaskCount: Int {
        tasks?.filter { $0.isCompleted && !$0.isDeleted }.count ?? 0
    }

    var pendingTaskCount: Int {
        taskCount - completedTaskCount
    }

    var completionRate: Double {
        guard taskCount > 0 else { return 0 }
        return Double(completedTaskCount) / Double(taskCount)
    }

    // MARK: - Initialization

    init(
        name: String,
        colorHex: String,
        iconName: String? = nil,
        sortOrder: Int = 0
    ) {
        self.id = UUID()
        self.name = name
        self.colorHex = colorHex
        self.iconName = iconName
        self.sortOrder = sortOrder
        self.createdAt = Date()
        self.syncStatusRawValue = SyncStatus.pending.rawValue
        self.isDeleted = false
    }

    // MARK: - Methods

    func markForDeletion() {
        isDeleted = true
        syncStatus = .pending
    }

    func update(name: String? = nil, colorHex: String? = nil, iconName: String? = nil) {
        if let name = name { self.name = name }
        if let colorHex = colorHex { self.colorHex = colorHex }
        if let iconName = iconName { self.iconName = iconName }
        syncStatus = .pending
    }
}

// MARK: - Predefined Categories

extension Category {
    static let defaultCategories: [(name: String, color: String, icon: String)] = [
        ("Personal", "#2196F3", "person.fill"),
        ("Work", "#FF9800", "briefcase.fill"),
        ("Shopping", "#4CAF50", "cart.fill"),
        ("Health", "#F44336", "heart.fill"),
        ("Home", "#9C27B0", "house.fill"),
        ("Learning", "#00BCD4", "book.fill")
    ]

    static func createDefaults(in context: ModelContext) {
        for (index, category) in defaultCategories.enumerated() {
            let newCategory = Category(
                name: category.name,
                colorHex: category.color,
                iconName: category.icon,
                sortOrder: index
            )
            context.insert(newCategory)
        }
    }
}
```

### Tag Model

```swift
import SwiftData
import Foundation

@Model
final class Tag {
    // MARK: - Primary Attributes

    @Attribute(.unique) var id: UUID
    var name: String
    var createdAt: Date

    // MARK: - Relationships

    @Relationship
    var tasks: [Task]?

    // MARK: - Sync Metadata

    var cloudKitRecordID: String?
    var lastSyncedAt: Date?
    var syncStatusRawValue: String
    var syncStatus: SyncStatus {
        get { SyncStatus(rawValue: syncStatusRawValue) ?? .pending }
        set { syncStatusRawValue = newValue.rawValue }
    }
    var isDeleted: Bool

    // MARK: - Computed Properties

    var taskCount: Int {
        tasks?.filter { !$0.isDeleted }.count ?? 0
    }

    // MARK: - Initialization

    init(name: String) {
        self.id = UUID()
        self.name = name.lowercased().trimmingCharacters(in: .whitespaces)
        self.createdAt = Date()
        self.syncStatusRawValue = SyncStatus.pending.rawValue
        self.isDeleted = false
    }

    // MARK: - Methods

    func markForDeletion() {
        isDeleted = true
        syncStatus = .pending
    }
}
```

## CloudKit Schema Definitions

### CKTask Record Type

```json
{
  "recordType": "Task",
  "fields": [
    {
      "name": "id",
      "type": "STRING",
      "indexed": true,
      "required": true
    },
    {
      "name": "title",
      "type": "STRING",
      "required": true
    },
    {
      "name": "taskDescription",
      "type": "STRING"
    },
    {
      "name": "isCompleted",
      "type": "INT64",
      "required": true
    },
    {
      "name": "sortOrder",
      "type": "INT64",
      "required": true
    },
    {
      "name": "createdAt",
      "type": "DATE_TIME",
      "required": true,
      "indexed": true
    },
    {
      "name": "updatedAt",
      "type": "DATE_TIME",
      "required": true,
      "indexed": true
    },
    {
      "name": "dueDate",
      "type": "DATE_TIME",
      "indexed": true
    },
    {
      "name": "completedAt",
      "type": "DATE_TIME"
    },
    {
      "name": "reminderDate",
      "type": "DATE_TIME"
    },
    {
      "name": "priority",
      "type": "STRING"
    },
    {
      "name": "categoryID",
      "type": "STRING",
      "indexed": true
    },
    {
      "name": "parentTaskID",
      "type": "STRING",
      "indexed": true
    },
    {
      "name": "tagIDs",
      "type": "STRING_LIST"
    },
    {
      "name": "isDeleted",
      "type": "INT64",
      "required": true,
      "indexed": true
    }
  ],
  "indexes": [
    {
      "name": "updatedAt_index",
      "fields": ["updatedAt"]
    },
    {
      "name": "dueDate_index",
      "fields": ["dueDate", "isCompleted"]
    },
    {
      "name": "category_index",
      "fields": ["categoryID", "isDeleted"]
    }
  ]
}
```

### CKCategory Record Type

```json
{
  "recordType": "Category",
  "fields": [
    {
      "name": "id",
      "type": "STRING",
      "indexed": true,
      "required": true
    },
    {
      "name": "name",
      "type": "STRING",
      "required": true
    },
    {
      "name": "colorHex",
      "type": "STRING",
      "required": true
    },
    {
      "name": "iconName",
      "type": "STRING"
    },
    {
      "name": "sortOrder",
      "type": "INT64",
      "required": true
    },
    {
      "name": "createdAt",
      "type": "DATE_TIME",
      "required": true
    },
    {
      "name": "isDeleted",
      "type": "INT64",
      "required": true
    }
  ],
  "indexes": [
    {
      "name": "sortOrder_index",
      "fields": ["sortOrder"]
    }
  ]
}
```

### CKTag Record Type

```json
{
  "recordType": "Tag",
  "fields": [
    {
      "name": "id",
      "type": "STRING",
      "indexed": true,
      "required": true
    },
    {
      "name": "name",
      "type": "STRING",
      "required": true,
      "indexed": true
    },
    {
      "name": "createdAt",
      "type": "DATE_TIME",
      "required": true
    },
    {
      "name": "isDeleted",
      "type": "INT64",
      "required": true
    }
  ],
  "indexes": [
    {
      "name": "name_index",
      "fields": ["name"]
    }
  ]
}
```

## Model Transformations

### SwiftData → CloudKit

```swift
import CloudKit

extension Task {
    func toCloudKitRecord(zoneID: CKRecordZone.ID) -> CKRecord {
        let recordID = CKRecord.ID(
            recordName: cloudKitRecordID ?? id.uuidString,
            zoneID: zoneID
        )
        let record = CKRecord(recordType: "Task", recordID: recordID)

        record["id"] = id.uuidString
        record["title"] = title
        record["taskDescription"] = taskDescription
        record["isCompleted"] = isCompleted ? 1 : 0
        record["sortOrder"] = sortOrder
        record["createdAt"] = createdAt
        record["updatedAt"] = updatedAt
        record["dueDate"] = dueDate
        record["completedAt"] = completedAt
        record["reminderDate"] = reminderDate
        record["priority"] = priority?.rawValue
        record["categoryID"] = category?.id.uuidString
        record["parentTaskID"] = parentTask?.id.uuidString
        record["tagIDs"] = tags?.map { $0.id.uuidString }
        record["isDeleted"] = isDeleted ? 1 : 0

        return record
    }

    func updateFromCloudKit(_ record: CKRecord) {
        // Only update if CloudKit record is newer
        guard let recordUpdatedAt = record["updatedAt"] as? Date,
              recordUpdatedAt > updatedAt else {
            return
        }

        title = record["title"] as? String ?? title
        taskDescription = record["taskDescription"] as? String
        isCompleted = (record["isCompleted"] as? Int64 == 1)
        sortOrder = record["sortOrder"] as? Int ?? sortOrder
        createdAt = record["createdAt"] as? Date ?? createdAt
        updatedAt = recordUpdatedAt
        dueDate = record["dueDate"] as? Date
        completedAt = record["completedAt"] as? Date
        reminderDate = record["reminderDate"] as? Date

        if let priorityString = record["priority"] as? String {
            priority = Priority(rawValue: priorityString)
        }

        isDeleted = (record["isDeleted"] as? Int64 == 1)
        cloudKitRecordID = record.recordID.recordName
        lastSyncedAt = Date()
        syncStatus = .synced
    }
}

extension Category {
    func toCloudKitRecord(zoneID: CKRecordZone.ID) -> CKRecord {
        let recordID = CKRecord.ID(
            recordName: cloudKitRecordID ?? id.uuidString,
            zoneID: zoneID
        )
        let record = CKRecord(recordType: "Category", recordID: recordID)

        record["id"] = id.uuidString
        record["name"] = name
        record["colorHex"] = colorHex
        record["iconName"] = iconName
        record["sortOrder"] = sortOrder
        record["createdAt"] = createdAt
        record["isDeleted"] = isDeleted ? 1 : 0

        return record
    }

    func updateFromCloudKit(_ record: CKRecord) {
        name = record["name"] as? String ?? name
        colorHex = record["colorHex"] as? String ?? colorHex
        iconName = record["iconName"] as? String
        sortOrder = record["sortOrder"] as? Int ?? sortOrder
        isDeleted = (record["isDeleted"] as? Int64 == 1)
        cloudKitRecordID = record.recordID.recordName
        lastSyncedAt = Date()
        syncStatus = .synced
    }
}

extension Tag {
    func toCloudKitRecord(zoneID: CKRecordZone.ID) -> CKRecord {
        let recordID = CKRecord.ID(
            recordName: cloudKitRecordID ?? id.uuidString,
            zoneID: zoneID
        )
        let record = CKRecord(recordType: "Tag", recordID: recordID)

        record["id"] = id.uuidString
        record["name"] = name
        record["createdAt"] = createdAt
        record["isDeleted"] = isDeleted ? 1 : 0

        return record
    }

    func updateFromCloudKit(_ record: CKRecord) {
        name = record["name"] as? String ?? name
        isDeleted = (record["isDeleted"] as? Int64 == 1)
        cloudKitRecordID = record.recordID.recordName
        lastSyncedAt = Date()
        syncStatus = .synced
    }
}
```

### CloudKit → SwiftData

```swift
struct CloudKitTransformer {
    static func createTask(from record: CKRecord, context: ModelContext) -> Task {
        let task = Task(title: record["title"] as? String ?? "Untitled")

        task.id = UUID(uuidString: record["id"] as? String ?? "") ?? UUID()
        task.taskDescription = record["taskDescription"] as? String
        task.isCompleted = (record["isCompleted"] as? Int64 == 1)
        task.sortOrder = record["sortOrder"] as? Int ?? 0
        task.createdAt = record["createdAt"] as? Date ?? Date()
        task.updatedAt = record["updatedAt"] as? Date ?? Date()
        task.dueDate = record["dueDate"] as? Date
        task.completedAt = record["completedAt"] as? Date
        task.reminderDate = record["reminderDate"] as? Date

        if let priorityString = record["priority"] as? String {
            task.priority = Priority(rawValue: priorityString)
        }

        task.isDeleted = (record["isDeleted"] as? Int64 == 1)
        task.cloudKitRecordID = record.recordID.recordName
        task.lastSyncedAt = Date()
        task.syncStatus = .synced

        context.insert(task)
        return task
    }

    static func createCategory(from record: CKRecord, context: ModelContext) -> Category {
        let category = Category(
            name: record["name"] as? String ?? "Untitled",
            colorHex: record["colorHex"] as? String ?? "#000000"
        )

        category.id = UUID(uuidString: record["id"] as? String ?? "") ?? UUID()
        category.iconName = record["iconName"] as? String
        category.sortOrder = record["sortOrder"] as? Int ?? 0
        category.createdAt = record["createdAt"] as? Date ?? Date()
        category.isDeleted = (record["isDeleted"] as? Int64 == 1)
        category.cloudKitRecordID = record.recordID.recordName
        category.lastSyncedAt = Date()
        category.syncStatus = .synced

        context.insert(category)
        return category
    }

    static func createTag(from record: CKRecord, context: ModelContext) -> Tag {
        let tag = Tag(name: record["name"] as? String ?? "")

        tag.id = UUID(uuidString: record["id"] as? String ?? "") ?? UUID()
        tag.createdAt = record["createdAt"] as? Date ?? Date()
        tag.isDeleted = (record["isDeleted"] as? Int64 == 1)
        tag.cloudKitRecordID = record.recordID.recordName
        tag.lastSyncedAt = Date()
        tag.syncStatus = .synced

        context.insert(tag)
        return tag
    }
}
```

## Query Patterns

### Common SwiftData Queries

```swift
import SwiftData

struct TaskQueries {
    // Fetch all active (not deleted) tasks
    static var activeTasks: FetchDescriptor<Task> {
        var descriptor = FetchDescriptor<Task>(
            predicate: #Predicate { !$0.isDeleted }
        )
        descriptor.sortBy = [SortDescriptor(\Task.sortOrder)]
        return descriptor
    }

    // Fetch incomplete tasks
    static var incompleteTasks: FetchDescriptor<Task> {
        var descriptor = FetchDescriptor<Task>(
            predicate: #Predicate { !$0.isCompleted && !$0.isDeleted }
        )
        descriptor.sortBy = [SortDescriptor(\Task.dueDate)]
        return descriptor
    }

    // Fetch tasks due today
    static var tasksDueToday: FetchDescriptor<Task> {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        var descriptor = FetchDescriptor<Task>(
            predicate: #Predicate { task in
                task.dueDate != nil &&
                task.dueDate! >= startOfDay &&
                task.dueDate! < endOfDay &&
                !task.isCompleted &&
                !task.isDeleted
            }
        )
        descriptor.sortBy = [SortDescriptor(\Task.dueDate)]
        return descriptor
    }

    // Fetch overdue tasks
    static var overdueTasks: FetchDescriptor<Task> {
        let now = Date()
        var descriptor = FetchDescriptor<Task>(
            predicate: #Predicate { task in
                task.dueDate != nil &&
                task.dueDate! < now &&
                !task.isCompleted &&
                !task.isDeleted
            }
        )
        descriptor.sortBy = [SortDescriptor(\Task.dueDate)]
        return descriptor
    }

    // Fetch tasks by category
    static func tasks(in category: Category) -> FetchDescriptor<Task> {
        let categoryID = category.id
        var descriptor = FetchDescriptor<Task>(
            predicate: #Predicate { task in
                task.category?.id == categoryID && !task.isDeleted
            }
        )
        descriptor.sortBy = [SortDescriptor(\Task.sortOrder)]
        return descriptor
    }

    // Fetch tasks by tag
    static func tasks(with tag: Tag) -> FetchDescriptor<Task> {
        let tagID = tag.id
        var descriptor = FetchDescriptor<Task>(
            predicate: #Predicate { task in
                task.tags?.contains(where: { $0.id == tagID }) ?? false &&
                !task.isDeleted
            }
        )
        descriptor.sortBy = [SortDescriptor(\Task.updatedAt, order: .reverse)]
        return descriptor
    }

    // Fetch tasks pending sync
    static var pendingSyncTasks: FetchDescriptor<Task> {
        var descriptor = FetchDescriptor<Task>(
            predicate: #Predicate { task in
                task.syncStatusRawValue == "pending" ||
                task.syncStatusRawValue == "error"
            }
        )
        descriptor.sortBy = [SortDescriptor(\Task.updatedAt)]
        return descriptor
    }

    // Search tasks
    static func search(_ query: String) -> FetchDescriptor<Task> {
        var descriptor = FetchDescriptor<Task>(
            predicate: #Predicate { task in
                (task.title.localizedStandardContains(query) ||
                 (task.taskDescription?.localizedStandardContains(query) ?? false)) &&
                !task.isDeleted
            }
        )
        descriptor.sortBy = [SortDescriptor(\Task.updatedAt, order: .reverse)]
        return descriptor
    }
}
```

### CloudKit Queries

```swift
import CloudKit

struct CloudKitQueries {
    // Fetch all records modified since last sync
    static func changedRecords(
        since date: Date,
        recordType: String
    ) -> CKQuery {
        let predicate = NSPredicate(
            format: "updatedAt > %@",
            date as NSDate
        )
        return CKQuery(recordType: recordType, predicate: predicate)
    }

    // Fetch deleted records
    static func deletedRecords(recordType: String) -> CKQuery {
        let predicate = NSPredicate(format: "isDeleted == 1")
        return CKQuery(recordType: recordType, predicate: predicate)
    }

    // Fetch all active tasks
    static var activeTasks: CKQuery {
        let predicate = NSPredicate(format: "isDeleted == 0")
        return CKQuery(recordType: "Task", predicate: predicate)
    }
}
```

## Data Validation

```swift
struct DataValidator {
    enum ValidationError: LocalizedError {
        case emptyTitle
        case invalidDueDate
        case invalidPriority
        case invalidColor

        var errorDescription: String? {
            switch self {
            case .emptyTitle:
                return "Task title cannot be empty"
            case .invalidDueDate:
                return "Due date cannot be in the past"
            case .invalidPriority:
                return "Invalid priority value"
            case .invalidColor:
                return "Invalid color hex value"
            }
        }
    }

    static func validate(task: Task) throws {
        guard !task.title.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ValidationError.emptyTitle
        }

        if let dueDate = task.dueDate, let reminderDate = task.reminderDate {
            guard reminderDate <= dueDate else {
                throw ValidationError.invalidDueDate
            }
        }
    }

    static func validate(category: Category) throws {
        guard !category.name.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ValidationError.emptyTitle
        }

        guard category.colorHex.hasPrefix("#") && category.colorHex.count == 7 else {
            throw ValidationError.invalidColor
        }
    }

    static func validate(tag: Tag) throws {
        guard !tag.name.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ValidationError.emptyTitle
        }
    }
}
```

## Migration Strategy

### Version 1.0 (Initial Schema)
- Task, Category, Tag models as defined above

### Future Migrations

```swift
// Example: Adding recurring tasks in version 2.0
enum SchemaMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [SchemaV1.self, SchemaV2.self]
    }

    static var stages: [MigrationStage] {
        [migrateV1toV2]
    }

    static let migrateV1toV2 = MigrationStage.custom(
        fromVersion: SchemaV1.self,
        toVersion: SchemaV2.self,
        willMigrate: nil,
        didMigrate: { context in
            // Perform data transformation if needed
        }
    )
}
```

## Performance Considerations

### Indexes
- Index on `updatedAt` for sync queries
- Index on `dueDate` for reminder queries
- Index on `isCompleted` for filtering
- Composite index on `categoryID + isDeleted`

### Fetch Optimization
- Use batch fetching for large lists
- Implement pagination for completed tasks
- Use relationship prefetching when needed
- Limit initial fetch to recent tasks (last 30 days)

### Memory Management
- Use `@Query` with proper predicates
- Avoid loading all tasks at once
- Implement virtual scrolling for large lists
- Clear completed tasks older than 90 days

---

**Last Updated:** 2025-11-15
