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

        return record
    }

    /// Create SwiftData model from CloudKit record
    static func fromCKRecord(_ record: CKRecord, context: ModelContext) -> Task? {
        guard let id = record["id"] as? String,
              let title = record["title"] as? String else {
            print("⚠️ Invalid CloudKit record - missing required fields")
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
    }
}
