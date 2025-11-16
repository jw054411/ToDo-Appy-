//
//  AppError.swift
//  ToDo-Appy
//
//  Created by Agent 1: Foundation & Setup Specialist
//  Comprehensive error handling for the entire app
//

import Foundation

/// Main error type for the entire application
enum AppError: Error, LocalizedError, Identifiable {
    var id: String { localizedDescription }

    // MARK: - Data Errors
    case dataNotFound
    case invalidData
    case dataCorrupted
    case modelValidationFailed(String)
    case duplicateEntry

    // MARK: - CloudKit Errors
    case cloudKitNotAvailable
    case cloudKitAccountNotFound
    case cloudKitNetworkError
    case cloudKitSyncFailed(String)
    case cloudKitQuotaExceeded
    case cloudKitZoneNotFound
    case cloudKitRecordNotFound
    case cloudKitConflict

    // MARK: - Network Errors
    case noInternetConnection
    case networkTimeout
    case serverError(Int)
    case unknownNetworkError

    // MARK: - Validation Errors
    case emptyTitle
    case invalidDate
    case invalidURL
    case invalidEmail
    case invalidInput(String)

    // MARK: - Permission Errors
    case notificationPermissionDenied
    case cloudKitPermissionDenied

    // MARK: - File Errors
    case fileNotFound
    case fileReadError
    case fileWriteError
    case exportFailed
    case importFailed(String)

    // MARK: - Generic Errors
    case unknown(Error)
    case custom(String)

    // MARK: - LocalizedError Conformance

    var errorDescription: String? {
        switch self {
        // Data Errors
        case .dataNotFound:
            return "Data not found"
        case .invalidData:
            return "Invalid data format"
        case .dataCorrupted:
            return "Data is corrupted"
        case .modelValidationFailed(let reason):
            return "Validation failed: \(reason)"
        case .duplicateEntry:
            return "This entry already exists"

        // CloudKit Errors
        case .cloudKitNotAvailable:
            return "iCloud is not available"
        case .cloudKitAccountNotFound:
            return "No iCloud account found. Please sign in to iCloud in Settings."
        case .cloudKitNetworkError:
            return "Unable to connect to iCloud"
        case .cloudKitSyncFailed(let reason):
            return "Sync failed: \(reason)"
        case .cloudKitQuotaExceeded:
            return "iCloud storage quota exceeded"
        case .cloudKitZoneNotFound:
            return "iCloud zone not found"
        case .cloudKitRecordNotFound:
            return "Record not found in iCloud"
        case .cloudKitConflict:
            return "Sync conflict detected"

        // Network Errors
        case .noInternetConnection:
            return "No internet connection"
        case .networkTimeout:
            return "Request timed out"
        case .serverError(let code):
            return "Server error (\(code))"
        case .unknownNetworkError:
            return "Network error occurred"

        // Validation Errors
        case .emptyTitle:
            return "Title cannot be empty"
        case .invalidDate:
            return "Invalid date"
        case .invalidURL:
            return "Invalid URL"
        case .invalidEmail:
            return "Invalid email address"
        case .invalidInput(let field):
            return "Invalid \(field)"

        // Permission Errors
        case .notificationPermissionDenied:
            return "Notification permission denied. Enable in Settings."
        case .cloudKitPermissionDenied:
            return "iCloud permission denied"

        // File Errors
        case .fileNotFound:
            return "File not found"
        case .fileReadError:
            return "Unable to read file"
        case .fileWriteError:
            return "Unable to write file"
        case .exportFailed:
            return "Export failed"
        case .importFailed(let reason):
            return "Import failed: \(reason)"

        // Generic Errors
        case .unknown(let error):
            return error.localizedDescription
        case .custom(let message):
            return message
        }
    }

    var failureReason: String? {
        switch self {
        case .cloudKitAccountNotFound:
            return "You need to be signed in to iCloud to use sync features."
        case .noInternetConnection:
            return "Your device is not connected to the internet."
        case .cloudKitQuotaExceeded:
            return "Your iCloud storage is full. Free up space or upgrade your plan."
        case .notificationPermissionDenied:
            return "Reminders require notification permission."
        default:
            return nil
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .cloudKitAccountNotFound:
            return "Go to Settings > [Your Name] > iCloud and sign in."
        case .noInternetConnection:
            return "Check your WiFi or cellular connection and try again."
        case .cloudKitQuotaExceeded:
            return "Manage your iCloud storage in Settings > [Your Name] > iCloud > Manage Storage."
        case .notificationPermissionDenied:
            return "Enable notifications in Settings > ToDo-Appy > Notifications."
        case .emptyTitle:
            return "Enter a title for your task."
        case .invalidDate:
            return "Choose a valid date."
        default:
            return "Please try again."
        }
    }

    /// Icon to show in error UI
    var icon: String {
        switch self {
        case .cloudKitNotAvailable, .cloudKitAccountNotFound, .cloudKitNetworkError, .cloudKitSyncFailed, .cloudKitQuotaExceeded:
            return "icloud.slash"
        case .noInternetConnection, .networkTimeout, .unknownNetworkError:
            return "wifi.slash"
        case .notificationPermissionDenied:
            return "bell.slash"
        case .dataCorrupted, .invalidData:
            return "exclamationmark.triangle"
        case .fileNotFound, .fileReadError, .fileWriteError:
            return "doc.badge.exclamationmark"
        default:
            return "exclamationmark.circle"
        }
    }

    /// Whether this error should be logged
    var shouldLog: Bool {
        switch self {
        case .unknown, .dataCorrupted, .cloudKitConflict:
            return true
        default:
            return false
        }
    }

    /// Whether this error is recoverable
    var isRecoverable: Bool {
        switch self {
        case .dataCorrupted, .cloudKitZoneNotFound:
            return false
        default:
            return true
        }
    }
}

// MARK: - Error Handler

/// Global error handler for the app
@MainActor
class ErrorHandler: ObservableObject {
    @Published var currentError: AppError?
    @Published var showError: Bool = false

    static let shared = ErrorHandler()

    private init() {}

    /// Handle an error
    func handle(_ error: Error) {
        let appError: AppError

        if let err = error as? AppError {
            appError = err
        } else {
            appError = .unknown(error)
        }

        if appError.shouldLog {
            Logger.error("Error occurred: \(appError.localizedDescription)")
        }

        currentError = appError
        showError = true
    }

    /// Clear current error
    func clearError() {
        currentError = nil
        showError = false
    }
}

// MARK: - Result Extension

extension Result {
    /// Convert Result to AppError
    func mapError() -> Result<Success, AppError> {
        return mapError { error in
            if let appError = error as? AppError {
                return appError
            }
            return .unknown(error)
        }
    }
}
