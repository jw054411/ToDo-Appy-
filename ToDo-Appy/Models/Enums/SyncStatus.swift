import Foundation

/// Represents the sync status of a model with CloudKit
enum SyncStatus: Int, Codable, CaseIterable {
    /// Changes pending, not yet synced to CloudKit
    case pending = 0

    /// Currently syncing with CloudKit
    case syncing = 1

    /// Successfully synced with CloudKit
    case synced = 2

    /// Sync failed, needs retry
    case failed = 3

    /// Conflict detected during sync
    case conflict = 4

    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .syncing: return "Syncing"
        case .synced: return "Synced"
        case .failed: return "Failed"
        case .conflict: return "Conflict"
        }
    }

    var icon: String {
        switch self {
        case .pending: return "clock"
        case .syncing: return "arrow.triangle.2.circlepath"
        case .synced: return "checkmark.icloud"
        case .failed: return "exclamationmark.icloud"
        case .conflict: return "exclamationmark.triangle"
        }
    }
}
