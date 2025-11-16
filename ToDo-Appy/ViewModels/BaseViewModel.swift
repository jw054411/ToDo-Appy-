//
//  BaseViewModel.swift
//  ToDo-Appy
//
//  Created by Agent 1: Foundation & Setup Specialist
//  Base protocol and class for all ViewModels
//

import Foundation
import SwiftUI

/// Base protocol that all ViewModels should conform to
protocol BaseViewModel: ObservableObject {
    /// Indicates if the ViewModel is currently loading data
    var isLoading: Bool { get set }

    /// Current error message (if any)
    var errorMessage: String? { get set }

    /// Load initial data
    func load() async

    /// Refresh data
    func refresh() async
}

/// Default implementations for BaseViewModel
extension BaseViewModel {
    /// Show error message
    func showError(_ message: String) {
        errorMessage = message
    }

    /// Clear error message
    func clearError() {
        errorMessage = nil
    }

    /// Execute async task with loading state
    func executeTask(_ task: @escaping () async throws -> Void) async {
        isLoading = true
        clearError()

        do {
            try await task()
        } catch {
            showError(error.localizedDescription)
        }

        isLoading = false
    }
}

// MARK: - Loading State

/// Enum to represent different loading states
enum LoadingState: Equatable {
    case idle
    case loading
    case loaded
    case error(String)

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    var errorMessage: String? {
        if case .error(let message) = self { return message }
        return nil
    }
}

// MARK: - Common ViewModel Patterns

/// Protocol for ViewModels that manage a list of items
protocol ListViewModel: BaseViewModel {
    associatedtype Item

    var items: [Item] { get set }
    var filteredItems: [Item] { get }
    var searchText: String { get set }

    func filterItems()
}

/// Protocol for ViewModels that manage a single item
protocol DetailViewModel: BaseViewModel {
    associatedtype Item

    var item: Item? { get set }

    func save() async throws
    func delete() async throws
}
