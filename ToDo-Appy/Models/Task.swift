//
//  Task.swift
//  ToDo-Appy
//
//  Core Task model with SwiftData and CloudKit support
//  Represents a to-do item with full feature set
//

import Foundation
import SwiftData
import CloudKit

@Model
final class Task {

    // MARK: - Core Properties

    var id: String
    var title: String
    var taskDescription: String

    // MARK: - Status

    var isCompleted: Bool
    var completedAt: Date?
    var isDeleted: Bool
    var deletedAt: Date?

    // MARK: - Scheduling

    var dueDate: Date?
    var priority: Priority

    // MARK: - Relationships

    var categoryID: String?

    @Relationship(deleteRule: .nullify, inverse: \Tag.tasks)
    var tags: [Tag] = []

    var category: Category? {
        // This will be resolved via categoryID
        get { nil }
        set { categoryID = newValue?.id }
    }

    // MARK: - Reminders

    var hasReminder: Bool
    var reminderTime: Date?
    var reminderOffset: Int  // Minutes before due date
    var notificationID: String?

    // MARK: - Recurrence

    var isRecurring: Bool
    var recurrenceRule: String?  // JSON string of recurrence rules
    var parentTaskID: String?     // ID of original task if this is a recurrence

    // MARK: - Metadata

    var createdAt: Date
    var updatedAt: Date

    // MARK: - Sync

    var syncStatus: SyncStatus
    var lastSyncedAt: Date?
    var cloudKitRecordID: String?

    // MARK: - Attachments (future feature)

    // var attachments: [Attachment] = []

    // MARK: - Initialization

    init(
        title: String,
        description: String = "",
        dueDate: Date? = nil,
        priority: Priority = .none,
        categoryID: String? = nil
    ) {
        self.id = UUID().uuidString
        self.title = title
        self.taskDescription = description
        self.isCompleted = false
        self.completedAt = nil
        self.isDeleted = false
        self.deletedAt = nil
        self.dueDate = dueDate
        self.priority = priority
        self.categoryID = categoryID
        self.tags = []
        self.hasReminder = false
        self.reminderTime = nil
        self.reminderOffset = 15  // Default 15 minutes before
        self.notificationID = nil
        self.isRecurring = false
        self.recurrenceRule = nil
        self.parentTaskID = nil
        self.createdAt = Date()
        self.updatedAt = Date()
        self.syncStatus = .pending
        self.lastSyncedAt = nil
        self.cloudKitRecordID = nil
    }

    // MARK: - CloudKit Conversion

    /// Convert SwiftData model to CloudKit record
    func toCKRecord() -> CKRecord? {
        let recordID: CKRecord.ID

        if let ckRecordID = cloudKitRecordID {
            // Use existing CloudKit record ID
            recordID = CKRecord.ID(recordName: ckRecordID)
        } else {
            // Create new CloudKit record ID
            recordID = CKRecord.ID(recordName: id)
        }

        let record = CKRecord(recordType: "CKTask", recordID: recordID)

        // Core properties
        record["id"] = id as CKRecordValue
        record["title"] = title as CKRecordValue
        record["taskDescription"] = taskDescription as CKRecordValue

        // Status
        record["isCompleted"] = (isCompleted ? 1 : 0) as CKRecordValue
        record["completedAt"] = completedAt as CKRecordValue?
        record["isDeleted"] = (isDeleted ? 1 : 0) as CKRecordValue
        record["deletedAt"] = deletedAt as CKRecordValue?

        // Scheduling
        record["dueDate"] = dueDate as CKRecordValue?
        record["priority"] = priority.rawValue as CKRecordValue

        // Relationships
        record["categoryID"] = categoryID as CKRecordValue?
        record["tagIDs"] = tags.map { $0.id } as CKRecordValue

        // Reminders
        record["hasReminder"] = (hasReminder ? 1 : 0) as CKRecordValue
        record["reminderTime"] = reminderTime as CKRecordValue?
        record["reminderOffset"] = reminderOffset as CKRecordValue
        record["notificationID"] = notificationID as CKRecordValue?

        // Recurrence
        record["isRecurring"] = (isRecurring ? 1 : 0) as CKRecordValue
        record["recurrenceRule"] = recurrenceRule as CKRecordValue?
        record["parentTaskID"] = parentTaskID as CKRecordValue?

        // Metadata
        record["createdAt"] = createdAt as CKRecordValue
        record["updatedAt"] = updatedAt as CKRecordValue
import SwiftUI
import SwiftData
import CloudKit
import Foundation

@Model
final class Task {
    // MARK: - Core Properties
    var id: String
    var title: String
    var taskDescription: String
    var isCompleted: Bool
    var createdAt: Date
    var updatedAt: Date
    var dueDate: Date?
    var priority: Priority
    var sortOrder: Int

    // MARK: - Recurring Task Properties
    var isRecurring: Bool
    var recurrenceType: RecurrenceType?
    var recurrenceInterval: Int
    var recurrenceEndDate: Date?
    var recurrenceDaysOfWeek: [Int]  // 1=Sunday, 2=Monday, etc.
    var recurrenceDayOfMonth: Int?   // 1-31
    var recurrenceMonthOfYear: Int?  // 1-12
    var parentRecurringTaskID: String?  // If this is a generated instance

    // MARK: - Reminder Properties
    var hasReminder: Bool
    var reminderTime: Date?
    var reminderOffset: Int  // Minutes before due date
    var notificationID: String?  // Local notification identifier

    // MARK: - Sync Metadata
    var cloudKitRecordID: String?
    var lastSyncedAt: Date?
    var syncStatus: SyncStatus
    var isDeleted: Bool

    // MARK: - Relationships
    var category: Category?
    @Relationship(deleteRule: .nullify, inverse: \Tag.tasks) var tags: [Tag]
    var parentTask: Task?
    @Relationship(deleteRule: .cascade) var subtasks: [Task]

    // MARK: - Computed Properties
    var isOverdue: Bool {
        guard let dueDate = dueDate, !isCompleted else { return false }
        return dueDate < Date() && !dueDate.isToday
    }

    var isToday: Bool {
        guard let dueDate = dueDate else { return false }
        return dueDate.isToday
    }

    var isTomorrow: Bool {
        guard let dueDate = dueDate else { return false }
        return dueDate.isTomorrow
    }

    var isUpcoming: Bool {
        guard let dueDate = dueDate else { return false }
        let weekFromNow = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        return dueDate > Date() && dueDate <= weekFromNow
    }

    var subtaskProgress: Double {
        guard !subtasks.isEmpty else { return 0 }
        let completed = subtasks.filter { $0.isCompleted }.count
        return Double(completed) / Double(subtasks.count)
    }

    var hasSubtasks: Bool {
        !subtasks.isEmpty
    }

    var isRecurringInstance: Bool {
        parentRecurringTaskID != nil
    }

    // MARK: - Initializer
    init(
        title: String,
        taskDescription: String = "",
        dueDate: Date? = nil,
        priority: Priority = .none,
        category: Category? = nil,
        isRecurring: Bool = false
    ) {
        self.id = UUID().uuidString
        self.title = title
        self.taskDescription = taskDescription
        self.isCompleted = false
        self.createdAt = Date()
        self.updatedAt = Date()
        self.dueDate = dueDate
        self.priority = priority
        self.sortOrder = 0

        self.isRecurring = isRecurring
        self.recurrenceType = nil
        self.recurrenceInterval = 1
        self.recurrenceEndDate = nil
        self.recurrenceDaysOfWeek = []
        self.recurrenceDayOfMonth = nil
        self.recurrenceMonthOfYear = nil
        self.parentRecurringTaskID = nil

        self.hasReminder = false
        self.reminderTime = nil
        self.reminderOffset = 0
        self.notificationID = nil

        self.cloudKitRecordID = nil
        self.lastSyncedAt = nil
        self.syncStatus = .pending
        self.isDeleted = false

        self.category = category
        self.tags = []
        self.parentTask = nil
        self.subtasks = []
    }

    // MARK: - Helper Methods
    func markAsCompleted() {
        isCompleted = true
        updatedAt = Date()
        syncStatus = .pending
    }

    func markAsIncomplete() {
        isCompleted = false
        updatedAt = Date()
        syncStatus = .pending
    }

    func updateTitle(_ newTitle: String) {
        title = newTitle
        updatedAt = Date()
        syncStatus = .pending
    }

    func softDelete() {
        isDeleted = true
        updatedAt = Date()
        syncStatus = .pending
    }
}

// MARK: - Syncable Conformance
extension Task: Syncable {
    func toCKRecord() -> CKRecord {
        let recordID = CKRecord.ID(recordName: id)
        let record = CKRecord(recordType: "CKTask", recordID: recordID)

        // Core fields
        record["id"] = id as CKRecordValue
        record["title"] = title as CKRecordValue
        record["taskDescription"] = taskDescription as CKRecordValue
        record["isCompleted"] = (isCompleted ? 1 : 0) as CKRecordValue
        record["createdAt"] = createdAt as CKRecordValue
        record["updatedAt"] = updatedAt as CKRecordValue
        record["dueDate"] = dueDate as CKRecordValue?
        record["priority"] = priority.rawValue as CKRecordValue
        record["categoryID"] = category?.id as CKRecordValue?
        record["sortOrder"] = sortOrder as CKRecordValue
        record["isDeleted"] = (isDeleted ? 1 : 0) as CKRecordValue

        // Recurring fields
        record["isRecurring"] = (isRecurring ? 1 : 0) as CKRecordValue
        record["recurrenceType"] = recurrenceType?.rawValue as CKRecordValue?
        record["recurrenceInterval"] = recurrenceInterval as CKRecordValue
        record["recurrenceEndDate"] = recurrenceEndDate as CKRecordValue?
        record["recurrenceDaysOfWeek"] = recurrenceDaysOfWeek as CKRecordValue
        record["recurrenceDayOfMonth"] = recurrenceDayOfMonth as CKRecordValue?
        record["recurrenceMonthOfYear"] = recurrenceMonthOfYear as CKRecordValue?
        record["parentRecurringTaskID"] = parentRecurringTaskID as CKRecordValue?

        // Reminder fields
        record["hasReminder"] = (hasReminder ? 1 : 0) as CKRecordValue
        record["reminderTime"] = reminderTime as CKRecordValue?
        record["reminderOffset"] = reminderOffset as CKRecordValue

        // Relationships (store as arrays of IDs)
        record["tagIDs"] = tags.map { $0.id } as CKRecordValue
        record["subtaskIDs"] = subtasks.map { $0.id } as CKRecordValue
        record["parentTaskID"] = parentTask?.id as CKRecordValue?

        return record
    }

    /// Create SwiftData model from CloudKit record
    static func fromCKRecord(_ record: CKRecord, context: ModelContext) -> Task? {
        guard let id = record["id"] as? String,
              let title = record["title"] as? String else {
            print("⚠️ Invalid CloudKit record - missing required fields")
    static func fromCKRecord(_ record: CKRecord) -> Task? {
        guard let id = record["id"] as? String,
              let title = record["title"] as? String else {
            return nil
        }

        let task = Task(title: title)
        task.id = id

        // Core properties
        task.taskDescription = record["taskDescription"] as? String ?? ""

        // Status
        task.isCompleted = (record["isCompleted"] as? Int ?? 0) == 1
        task.completedAt = record["completedAt"] as? Date
        task.isDeleted = (record["isDeleted"] as? Int ?? 0) == 1
        task.deletedAt = record["deletedAt"] as? Date

        // Scheduling
        task.dueDate = record["dueDate"] as? Date
        task.priority = Priority(rawValue: record["priority"] as? Int ?? 0) ?? .none

        // Relationships
        task.categoryID = record["categoryID"] as? String

        // Tags will be linked separately using tagIDs
        // let tagIDs = record["tagIDs"] as? [String] ?? []

        // Reminders
        task.hasReminder = (record["hasReminder"] as? Int ?? 0) == 1
        task.reminderTime = record["reminderTime"] as? Date
        task.reminderOffset = record["reminderOffset"] as? Int ?? 15
        task.notificationID = record["notificationID"] as? String

        // Recurrence
        task.isRecurring = (record["isRecurring"] as? Int ?? 0) == 1
        task.recurrenceRule = record["recurrenceRule"] as? String
        task.parentTaskID = record["parentTaskID"] as? String

        // Metadata
        task.createdAt = record["createdAt"] as? Date ?? Date()
        task.updatedAt = record["updatedAt"] as? Date ?? Date()

        // Sync metadata
        task.syncStatus = .synced
        task.lastSyncedAt = Date()
        task.cloudKitRecordID = record.recordID.recordName

        return task
    }

    // MARK: - Computed Properties

    /// Check if task is overdue
    var isOverdue: Bool {
        guard let dueDate = dueDate, !isCompleted else { return false }
        return dueDate < Date()
    }

    /// Check if task is due today
    var isDueToday: Bool {
        guard let dueDate = dueDate, !isCompleted else { return false }

        let calendar = Calendar.current
        return calendar.isDateInToday(dueDate)
    }

    /// Check if task is due this week
    var isDueThisWeek: Bool {
        guard let dueDate = dueDate, !isCompleted else { return false }

        let calendar = Calendar.current
        let now = Date()
        guard let weekFromNow = calendar.date(byAdding: .day, value: 7, to: now) else {
            return false
        }

        return dueDate >= now && dueDate <= weekFromNow
    }

    /// Days until due (negative if overdue)
    var daysUntilDue: Int? {
        guard let dueDate = dueDate else { return nil }

        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: dueDate)
        return components.day
    }

    // MARK: - Actions

    /// Mark task as completed
    func complete() {
        isCompleted = true
        completedAt = Date()
        updatedAt = Date()
        syncStatus = .pending
    }

    /// Mark task as incomplete
    func uncomplete() {
        isCompleted = false
        completedAt = nil
        updatedAt = Date()
        syncStatus = .pending
    }

    /// Soft delete task
    func softDelete() {
        isDeleted = true
        deletedAt = Date()
        updatedAt = Date()
        syncStatus = .pending
    }

    /// Restore deleted task
    func restore() {
        isDeleted = false
        deletedAt = nil
        updatedAt = Date()
        syncStatus = .pending
    }

    /// Update task and mark for sync
    func update() {
        updatedAt = Date()
        syncStatus = .pending
    }

    /// Add a tag
    func addTag(_ tag: Tag) {
        if !tags.contains(where: { $0.id == tag.id }) {
            tags.append(tag)
            update()
        }
    }

    /// Remove a tag
    func removeTag(_ tag: Tag) {
        tags.removeAll { $0.id == tag.id }
        update()
    }
}

// MARK: - Hashable & Equatable

extension Task: Hashable {
    static func == (lhs: Task, rhs: Task) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - CustomStringConvertible

extension Task: CustomStringConvertible {
    var description: String {
        """
        Task(id: \(id), title: "\(title)", completed: \(isCompleted), \
        dueDate: \(dueDate?.formatted() ?? "none"), priority: \(priority.displayName))
        """
        task.taskDescription = record["taskDescription"] as? String ?? ""
        task.isCompleted = (record["isCompleted"] as? Int ?? 0) == 1
        task.createdAt = record["createdAt"] as? Date ?? Date()
        task.updatedAt = record["updatedAt"] as? Date ?? Date()
        task.dueDate = record["dueDate"] as? Date
        task.priority = Priority(rawValue: record["priority"] as? Int ?? 0) ?? .none
        task.sortOrder = record["sortOrder"] as? Int ?? 0
        task.isDeleted = (record["isDeleted"] as? Int ?? 0) == 1

        // Recurring fields
        task.isRecurring = (record["isRecurring"] as? Int ?? 0) == 1
        if let recurrenceTypeString = record["recurrenceType"] as? String {
            task.recurrenceType = RecurrenceType(rawValue: recurrenceTypeString)
        }
        task.recurrenceInterval = record["recurrenceInterval"] as? Int ?? 1
        task.recurrenceEndDate = record["recurrenceEndDate"] as? Date
        task.recurrenceDaysOfWeek = record["recurrenceDaysOfWeek"] as? [Int] ?? []
        task.recurrenceDayOfMonth = record["recurrenceDayOfMonth"] as? Int
        task.recurrenceMonthOfYear = record["recurrenceMonthOfYear"] as? Int
        task.parentRecurringTaskID = record["parentRecurringTaskID"] as? String

        // Reminder fields
        task.hasReminder = (record["hasReminder"] as? Int ?? 0) == 1
        task.reminderTime = record["reminderTime"] as? Date
        task.reminderOffset = record["reminderOffset"] as? Int ?? 0

        // Sync metadata
        task.cloudKitRecordID = record.recordID.recordName
        task.lastSyncedAt = Date()
        task.syncStatus = .synced

        // Note: Relationships (category, tags, subtasks) will be resolved by sync service

        return task
    }
}
