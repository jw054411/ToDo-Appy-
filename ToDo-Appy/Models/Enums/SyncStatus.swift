//
//  SyncStatus.swift
//  ToDo-Appy
//
//  Created by Agent 1: Foundation & Setup Specialist
//  Represents the sync state of a Syncable object
//

import Foundation

/// Represents the current synchronization status of an object with CloudKit
enum SyncStatus: String, Codable, CaseIterable {
    /// Object is fully synced with CloudKit
    case synced

    /// Object has local changes that need to be synced to CloudKit
    case pending

    /// Object is currently being synced
    case syncing

    /// Object has a sync conflict (different versions on device and cloud)
    case conflict

    /// Object encountered an error during sync
    case error

    /// Human-readable description
    var displayName: String {
        switch self {
        case .synced:
            return "Synced"
        case .pending:
            return "Pending Sync"
        case .syncing:
            return "Syncing..."
        case .conflict:
            return "Conflict"
        case .error:
            return "Sync Error"
        }
    }

    /// Icon name for UI display
    var iconName: String {
        switch self {
        case .synced:
            return "checkmark.icloud.fill"
        case .pending:
            return "clock.badge.exclamationmark"
        case .syncing:
            return "arrow.triangle.2.circlepath"
        case .conflict:
            return "exclamationmark.triangle.fill"
        case .error:
            return "xmark.icloud.fill"
        }
    }
}
