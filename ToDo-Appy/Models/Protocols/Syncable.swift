import Foundation
import CloudKit

/// Protocol for models that can sync with CloudKit
protocol Syncable {
    /// Unique identifier for the record
    var id: String { get set }

    /// CloudKit record ID
    var cloudKitRecordID: String? { get set }

    /// Last time this record was synced with CloudKit
    var lastSyncedAt: Date? { get set }

    /// Current sync status
    var syncStatus: SyncStatus { get set }

    /// Soft delete flag
    var isDeleted: Bool { get set }

    /// Convert this model to a CloudKit record
    func toCKRecord() -> CKRecord

    /// Create a model instance from a CloudKit record
    static func fromCKRecord(_ record: CKRecord) -> Self?
}
