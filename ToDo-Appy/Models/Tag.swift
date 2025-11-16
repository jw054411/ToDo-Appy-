import SwiftUI
import SwiftData
import CloudKit
import Foundation

@Model
final class Tag {
    // MARK: - Core Properties
    var id: String
    var name: String
    var colorHex: String
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Sync Metadata
    var cloudKitRecordID: String?
    var lastSyncedAt: Date?
    var syncStatus: SyncStatus
    var isDeleted: Bool

    // MARK: - Relationships
    // Many-to-many relationship with Task
    var tasks: [Task]

    // MARK: - Computed Properties
    var color: Color {
        Color(hex: colorHex) ?? .purple
    }

    var taskCount: Int {
        tasks.filter { !$0.isDeleted }.count
    }

    // MARK: - Initializer
    init(name: String, colorHex: String) {
        self.id = UUID().uuidString
        self.name = name
        self.colorHex = colorHex
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
extension Tag: Syncable {
    func toCKRecord() -> CKRecord {
        let recordID = CKRecord.ID(recordName: id)
        let record = CKRecord(recordType: "CKTag", recordID: recordID)

        // Core fields
        record["id"] = id as CKRecordValue
        record["name"] = name as CKRecordValue
        record["colorHex"] = colorHex as CKRecordValue
        record["createdAt"] = createdAt as CKRecordValue
        record["updatedAt"] = updatedAt as CKRecordValue
        record["isDeleted"] = (isDeleted ? 1 : 0) as CKRecordValue

        return record
    }

    static func fromCKRecord(_ record: CKRecord) -> Tag? {
        guard let id = record["id"] as? String,
              let name = record["name"] as? String,
              let colorHex = record["colorHex"] as? String else {
            return nil
        }

        let tag = Tag(name: name, colorHex: colorHex)
        tag.id = id
        tag.createdAt = record["createdAt"] as? Date ?? Date()
        tag.updatedAt = record["updatedAt"] as? Date ?? Date()
        tag.isDeleted = (record["isDeleted"] as? Int ?? 0) == 1

        // Sync metadata
        tag.cloudKitRecordID = record.recordID.recordName
        tag.lastSyncedAt = Date()
        tag.syncStatus = .synced

        return tag
    }
}
