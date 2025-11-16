//
//  Syncable.swift
//  ToDo-Appy
//
//  Created by Agent 1: Foundation & Setup Specialist
//  Protocol for objects that sync with CloudKit
//

import Foundation
import CloudKit

/// Protocol that defines requirements for objects that sync with CloudKit
/// Agent 2 will implement this protocol on Task, Category, and Tag models
/// Agent 3 will use this protocol in the DataSyncService
protocol Syncable {
    /// CloudKit record ID for tracking
    var cloudKitRecordID: String? { get set }

    /// Last time this object was synced with CloudKit
    var lastSyncedAt: Date? { get set }

    /// Current sync status
    var syncStatus: SyncStatus { get set }

    /// Soft delete flag - true if deleted (for CloudKit sync)
    var isDeleted: Bool { get set }

    /// Convert this object to a CloudKit record
    /// - Returns: CKRecord representation of this object
    func toCKRecord() -> CKRecord

    /// Create an instance from a CloudKit record
    /// - Parameter record: The CKRecord to convert from
    /// - Returns: Instance of conforming type, or nil if conversion fails
    static func fromCKRecord(_ record: CKRecord) -> Self?
}

// MARK: - Helper Extensions

extension Syncable {
    /// Check if this object needs to be synced
    var needsSync: Bool {
        syncStatus == .pending || syncStatus == .error
    }

    /// Check if this object is currently syncing
    var isSyncing: Bool {
        syncStatus == .syncing
    }

    /// Check if this object has a conflict
    var hasConflict: Bool {
        syncStatus == .conflict
    }
}
