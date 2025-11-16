//
//  Category.swift
//  ToDo-Appy
//
//  Category model with SwiftData and CloudKit support
//  Represents a task category/project
//

import Foundation
import SwiftData
import CloudKit

@Model
final class Category {

    // MARK: - Properties

    var id: String
    var name: String
    var color: String  // Hex color code
    var iconName: String  // SF Symbol name

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

    init(name: String, color: String = "#007AFF", iconName: String = "folder.fill") {
        self.id = UUID().uuidString
        self.name = name
        self.color = color
        self.iconName = iconName
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

        let record = CKRecord(recordType: "CKCategory", recordID: recordID)

        // Core properties
        record["id"] = id as CKRecordValue
        record["name"] = name as CKRecordValue
        record["color"] = color as CKRecordValue
        record["iconName"] = iconName as CKRecordValue

        // Status
        record["isDeleted"] = (isDeleted ? 1 : 0) as CKRecordValue
        record["deletedAt"] = deletedAt as CKRecordValue?

        // Metadata
        record["createdAt"] = createdAt as CKRecordValue
        record["updatedAt"] = updatedAt as CKRecordValue

        return record
    }

    /// Create SwiftData model from CloudKit record
    static func fromCKRecord(_ record: CKRecord, context: ModelContext) -> Category? {
        guard let id = record["id"] as? String,
              let name = record["name"] as? String else {
            print("⚠️ Invalid CloudKit record - missing required fields")
            return nil
        }

        let color = record["color"] as? String ?? "#007AFF"
        let iconName = record["iconName"] as? String ?? "folder.fill"

        let category = Category(name: name, color: color, iconName: iconName)
        category.id = id

        // Status
        category.isDeleted = (record["isDeleted"] as? Int ?? 0) == 1
        category.deletedAt = record["deletedAt"] as? Date

        // Metadata
        category.createdAt = record["createdAt"] as? Date ?? Date()
        category.updatedAt = record["updatedAt"] as? Date ?? Date()

        // Sync metadata
        category.syncStatus = .synced
        category.lastSyncedAt = Date()
        category.cloudKitRecordID = record.recordID.recordName

        return category
    }

    // MARK: - Actions

    /// Update category and mark for sync
    func update() {
        updatedAt = Date()
        syncStatus = .pending
    }

    /// Soft delete category
    func softDelete() {
        isDeleted = true
        deletedAt = Date()
        updatedAt = Date()
        syncStatus = .pending
    }

    /// Restore deleted category
    func restore() {
        isDeleted = false
        deletedAt = nil
        updatedAt = Date()
        syncStatus = .pending
    }
}

// MARK: - Predefined Categories

extension Category {
    /// Get default categories for initial setup
    static var defaultCategories: [Category] {
        [
            Category(name: "Personal", color: "#007AFF", iconName: "person.fill"),
            Category(name: "Work", color: "#FF9500", iconName: "briefcase.fill"),
            Category(name: "Shopping", color: "#34C759", iconName: "cart.fill"),
            Category(name: "Health", color: "#FF3B30", iconName: "heart.fill"),
            Category(name: "Home", color: "#5856D6", iconName: "house.fill"),
            Category(name: "Study", color: "#AF52DE", iconName: "book.fill"),
            Category(name: "Finance", color: "#FFD700", iconName: "dollarsign.circle.fill"),
            Category(name: "Hobbies", color: "#FF2D55", iconName: "paintpalette.fill")
        ]
    }
}

// MARK: - Hashable & Equatable

extension Category: Hashable {
    static func == (lhs: Category, rhs: Category) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - CustomStringConvertible

extension Category: CustomStringConvertible {
    var description: String {
        "Category(id: \(id), name: \"\(name)\", color: \(color), icon: \(iconName))"
    }
}
