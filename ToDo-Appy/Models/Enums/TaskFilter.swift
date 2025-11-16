//
//  TaskFilter.swift
//  ToDo-Appy
//
//  Created by Agent 1: Foundation & Setup Specialist
//  Task filtering options
//

import Foundation

/// Task filter options for different views
enum TaskFilter: String, CaseIterable, Identifiable {
    var id: String { rawValue }

    case all
    case today
    case upcoming
    case overdue
    case completed
    case priority
    case noDueDate

    var displayName: String {
        switch self {
        case .all: return "All Tasks"
        case .today: return "Today"
        case .upcoming: return "Upcoming"
        case .overdue: return "Overdue"
        case .completed: return "Completed"
        case .priority: return "Priority"
        case .noDueDate: return "No Due Date"
        }
    }

    var icon: String {
        switch self {
        case .all: return "tray.fill"
        case .today: return "calendar.circle.fill"
        case .upcoming: return "calendar.badge.clock"
        case .overdue: return "exclamationmark.triangle.fill"
        case .completed: return "checkmark.circle.fill"
        case .priority: return "exclamationmark.3"
        case .noDueDate: return "calendar.badge.minus"
        }
    }

    var color: String {
        switch self {
        case .all: return "blue"
        case .today: return "green"
        case .upcoming: return "purple"
        case .overdue: return "red"
        case .completed: return "gray"
        case .priority: return "orange"
        case .noDueDate: return "gray"
        }
    }
}
