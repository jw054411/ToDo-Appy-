//
//  Tag.swift
//  ToDo-Appy
//
//  Tag model with SwiftData and CloudKit support
//  Represents a tag for organizing tasks
//

import Foundation
import SwiftData
import CloudKit

@Model
final class Tag {

    // MARK: - Properties

    var id: String
    var name: String
    var color: String  // Hex color code

    // MARK: - Relationships

    @Relationship(deleteRule: .nullify)
    var tasks: [Task] = []

    // MARK: - Status

    var isDeleted: Bool
    var deletedAt: Date?

    // MARK: - Metadata

    var createdAt: Date
    var updatedAt: Date

    // MARK: - Sync

    var syncStatus: SyncStatus
    var lastSyncedAt: Date?
    var cloudKitRecordID: String?

    // MARK: - Initialization

    init(name: String, color: String = "#8E8E93") {
        self.id = UUID().uuidString
        self.name = name
        self.color = color
        self.tasks = []
        self.isDeleted = false
        self.deletedAt = nil
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
            recordID = CKRecord.ID(recordName: ckRecordID)
        } else {
            recordID = CKRecord.ID(recordName: id)
        }

        let record = CKRecord(recordType: "CKTag", recordID: recordID)

        // Core properties
        record["id"] = id as CKRecordValue
        record["name"] = name as CKRecordValue
        record["color"] = color as CKRecordValue

        // Status
        record["isDeleted"] = (isDeleted ? 1 : 0) as CKRecordValue
        record["deletedAt"] = deletedAt as CKRecordValue?

        // Metadata
        record["createdAt"] = createdAt as CKRecordValue
        record["updatedAt"] = updatedAt as CKRecordValue
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

    /// Create SwiftData model from CloudKit record
    static func fromCKRecord(_ record: CKRecord, context: ModelContext) -> Tag? {
        guard let id = record["id"] as? String,
              let name = record["name"] as? String else {
            print("⚠️ Invalid CloudKit record - missing required fields")
            return nil
        }

        let color = record["color"] as? String ?? "#8E8E93"

        let tag = Tag(name: name, color: color)
        tag.id = id

        // Status
        tag.isDeleted = (record["isDeleted"] as? Int ?? 0) == 1
        tag.deletedAt = record["deletedAt"] as? Date

        // Metadata
        tag.createdAt = record["createdAt"] as? Date ?? Date()
        tag.updatedAt = record["updatedAt"] as? Date ?? Date()

        // Sync metadata
        tag.syncStatus = .synced
        tag.lastSyncedAt = Date()
        tag.cloudKitRecordID = record.recordID.recordName

        return tag
    }

    // MARK: - Actions

    /// Update tag and mark for sync
    func update() {
        updatedAt = Date()
        syncStatus = .pending
    }

    /// Soft delete tag
    func softDelete() {
        isDeleted = true
        deletedAt = Date()
        updatedAt = Date()
        syncStatus = .pending
    }

    /// Restore deleted tag
    func restore() {
        isDeleted = false
        deletedAt = nil
        updatedAt = Date()
        syncStatus = .pending
    }

    /// Get task count
    var taskCount: Int {
        tasks.filter { !$0.isDeleted }.count
    }

    /// Get active task count (not completed, not deleted)
    var activeTaskCount: Int {
        tasks.filter { !$0.isDeleted && !$0.isCompleted }.count
    }
}

// MARK: - Predefined Tags

extension Tag {
    /// Get default tags for initial setup
    static var defaultTags: [Tag] {
        [
            Tag(name: "Urgent", color: "#FF3B30"),
            Tag(name: "Important", color: "#FF9500"),
            Tag(name: "Low Priority", color: "#34C759"),
            Tag(name: "Later", color: "#8E8E93"),
            Tag(name: "Waiting", color: "#FFCC00"),
            Tag(name: "Quick Win", color: "#5856D6"),
            Tag(name: "Long Term", color: "#AF52DE"),
            Tag(name: "Review", color: "#007AFF")
        ]
    }

    /// Common context tags
    static var contextTags: [Tag] {
        [
            Tag(name: "@Home", color: "#5856D6"),
            Tag(name: "@Work", color: "#FF9500"),
            Tag(name: "@Errands", color: "#34C759"),
            Tag(name: "@Computer", color: "#007AFF"),
            Tag(name: "@Phone", color: "#FF3B30"),
            Tag(name: "@Offline", color: "#8E8E93")
        ]
    }
}

// MARK: - Hashable & Equatable

extension Tag: Hashable {
    static func == (lhs: Tag, rhs: Tag) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - CustomStringConvertible

extension Tag: CustomStringConvertible {
    var description: String {
        "Tag(id: \(id), name: \"\(name)\", color: \(color), tasks: \(taskCount))"
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
