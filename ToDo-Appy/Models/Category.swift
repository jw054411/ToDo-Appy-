import SwiftUI
import SwiftData
import CloudKit
import Foundation

@Model
final class Category {
    // MARK: - Core Properties
    var id: String
    var name: String
    var colorHex: String
    var icon: String
    var sortOrder: Int
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Sync Metadata
    var cloudKitRecordID: String?
    var lastSyncedAt: Date?
    var syncStatus: SyncStatus
    var isDeleted: Bool

    // MARK: - Relationships
    @Relationship(deleteRule: .nullify, inverse: \Task.category) var tasks: [Task]

    // MARK: - Computed Properties
    var color: Color {
        Color(hex: colorHex) ?? .blue
    }

    var activeTaskCount: Int {
        tasks.filter { !$0.isCompleted && !$0.isDeleted }.count
    }

    // MARK: - Initializer
    init(name: String, colorHex: String, icon: String) {
        self.id = UUID().uuidString
        self.name = name
        self.colorHex = colorHex
        self.icon = icon
        self.sortOrder = 0
        self.createdAt = Date()
        self.updatedAt = Date()

        self.cloudKitRecordID = nil
        self.lastSyncedAt = nil
        self.syncStatus = .pending
        self.isDeleted = false

        self.tasks = []
    }

    // MARK: - Helper Methods
    func softDelete() {
        isDeleted = true
        updatedAt = Date()
        syncStatus = .pending
    }
}

// MARK: - Syncable Conformance
extension Category: Syncable {
    func toCKRecord() -> CKRecord {
        let recordID = CKRecord.ID(recordName: id)
        let record = CKRecord(recordType: "CKCategory", recordID: recordID)

        // Core fields
        record["id"] = id as CKRecordValue
        record["name"] = name as CKRecordValue
        record["colorHex"] = colorHex as CKRecordValue
        record["icon"] = icon as CKRecordValue
        record["sortOrder"] = sortOrder as CKRecordValue
        record["createdAt"] = createdAt as CKRecordValue
        record["updatedAt"] = updatedAt as CKRecordValue
        record["isDeleted"] = (isDeleted ? 1 : 0) as CKRecordValue

        return record
    }

    static func fromCKRecord(_ record: CKRecord) -> Category? {
        guard let id = record["id"] as? String,
              let name = record["name"] as? String,
              let colorHex = record["colorHex"] as? String,
              let icon = record["icon"] as? String else {
            return nil
        }

        let category = Category(name: name, colorHex: colorHex, icon: icon)
        category.id = id
        category.sortOrder = record["sortOrder"] as? Int ?? 0
        category.createdAt = record["createdAt"] as? Date ?? Date()
        category.updatedAt = record["updatedAt"] as? Date ?? Date()
        category.isDeleted = (record["isDeleted"] as? Int ?? 0) == 1

        // Sync metadata
        category.cloudKitRecordID = record.recordID.recordName
        category.lastSyncedAt = Date()
        category.syncStatus = .synced

        return category
    }
}
