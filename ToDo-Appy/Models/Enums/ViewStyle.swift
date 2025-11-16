//
//  ViewStyle.swift
//  ToDo-Appy
//
//  Created by Agent 1: Foundation & Setup Specialist
//  View style options
//

import Foundation

/// View style for displaying tasks
enum ViewStyle: String, CaseIterable {
    case compact
    case comfortable
    case spacious

    var displayName: String {
        rawValue.capitalized
    }

    /// Row spacing for this view style
    var rowSpacing: Double {
        switch self {
        case .compact: return 4
        case .comfortable: return 8
        case .spacious: return 12
        }
    }

    /// Minimum row height
    var minRowHeight: Double {
        switch self {
        case .compact: return 44
        case .comfortable: return 60
        case .spacious: return 80
        }
    }
}
