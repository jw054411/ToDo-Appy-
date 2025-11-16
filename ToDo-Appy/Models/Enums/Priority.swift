//
//  Priority.swift
//  ToDo-Appy
//
//  Created by Agent 1: Foundation & Setup Specialist
//  Represents task priority levels
//

import Foundation
import SwiftUI

/// Task priority levels matching CloudKit schema (0-4)
enum Priority: Int, Codable, CaseIterable {
    case none = 0
    case low = 1
    case medium = 2
    case high = 3
    case urgent = 4

    /// Human-readable name
    var displayName: String {
        switch self {
        case .none:
            return "None"
        case .low:
            return "Low"
        case .medium:
            return "Medium"
        case .high:
            return "High"
        case .urgent:
            return "Urgent"
        }
    }

    /// Color for UI display
    var color: Color {
        switch self {
        case .none:
            return .gray
        case .low:
            return .blue
        case .medium:
            return .yellow
        case .high:
            return .orange
        case .urgent:
            return .red
        }
    }

    /// Number of priority indicator icons to show (e.g., "!!!" for high)
    var iconCount: Int {
        switch self {
        case .none:
            return 0
        case .low:
            return 1
        case .medium:
            return 2
        case .high:
            return 3
        case .urgent:
            return 4
        }
    }

    /// Icon representation (exclamation marks)
    var iconRepresentation: String {
        String(repeating: "!", count: iconCount)
    }

    /// SF Symbol for priority
    var sfSymbol: String {
        switch self {
        case .none:
            return "minus.circle"
        case .low:
            return "exclamationmark.circle"
        case .medium:
            return "exclamationmark.2.circle"
        case .high:
            return "exclamationmark.3.circle"
        case .urgent:
            return "exclamationmark.triangle.fill"
        }
    }
}
