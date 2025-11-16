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

    static func fromCKRecord(_ record: CKRecord) -> Task? {
        guard let id = record["id"] as? String,
              let title = record["title"] as? String else {
            return nil
        }

        let task = Task(title: title)
        task.id = id
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
