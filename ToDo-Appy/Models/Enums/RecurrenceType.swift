//
//  RecurrenceType.swift
//  ToDo-Appy
//
//  Created by Agent 1: Foundation & Setup Specialist
//  Represents recurring task frequency types
//

import Foundation

/// Frequency types for recurring tasks
enum RecurrenceType: String, Codable, CaseIterable {
    case daily
    case weekly
    case monthly
    case yearly
    case custom

    /// Human-readable name
    var displayName: String {
        rawValue.capitalized
    }

    /// Detailed description
    var description: String {
        switch self {
        case .daily:
            return "Repeats every day"
        case .weekly:
            return "Repeats every week"
        case .monthly:
            return "Repeats every month"
        case .yearly:
            return "Repeats every year"
        case .custom:
            return "Custom recurrence pattern"
        }
    }

    /// SF Symbol icon
    var sfSymbol: String {
        switch self {
        case .daily:
            return "calendar.day.timeline.left"
        case .weekly:
            return "calendar.badge.clock"
        case .monthly:
            return "calendar"
        case .yearly:
            return "calendar.badge.clock"
        case .custom:
            return "gearshape"
        }
    }
}
