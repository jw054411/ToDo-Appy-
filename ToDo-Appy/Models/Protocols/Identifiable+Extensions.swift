//
//  Identifiable+Extensions.swift
//  ToDo-Appy
//
//  Created by Agent 1: Foundation & Setup Specialist
//  Extensions and protocols for identifiable models
//

import Foundation

/// Protocol for models that have timestamps
protocol Timestamped {
    var createdAt: Date { get set }
    var updatedAt: Date { get set }
}

/// Protocol for models that can be soft-deleted
protocol SoftDeletable {
    var isDeleted: Bool { get set }
}

/// Protocol for models that have a sort order
protocol Sortable {
    var sortOrder: Int { get set }
}

/// Protocol for models that can be categorized
protocol Categorizable {
    var categoryID: String? { get set }
}

/// Protocol for models that can be tagged
protocol Taggable {
    var tagIDs: [String] { get set }
}

// MARK: - Default Implementations

extension Timestamped {
    /// Update the updatedAt timestamp to now
    mutating func touch() {
        updatedAt = Date()
    }
}

extension SoftDeletable {
    /// Soft delete this item
    mutating func softDelete() {
        isDeleted = true
    }

    /// Restore a soft-deleted item
    mutating func restore() {
        isDeleted = false
    }
}
