//
//  Logger.swift
//  ToDo-Appy
//
//  Created by Agent 1: Foundation & Setup Specialist
//  Centralized logging utility for debugging and monitoring
//

import Foundation
import os.log

/// Centralized logger for the app
enum Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.personal.todoappy"

    // MARK: - Log Categories

    private static let generalLog = OSLog(subsystem: subsystem, category: "General")
    private static let dataLog = OSLog(subsystem: subsystem, category: "Data")
    private static let syncLog = OSLog(subsystem: subsystem, category: "Sync")
    private static let uiLog = OSLog(subsystem: subsystem, category: "UI")
    private static let networkLog = OSLog(subsystem: subsystem, category: "Network")
    private static let notificationLog = OSLog(subsystem: subsystem, category: "Notifications")

    // MARK: - General Logging

    /// Log informational message
    static func info(_ message: String, category: Category = .general, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .info, category: category, file: file, function: function, line: line)
    }

    /// Log debug message (only in debug builds)
    static func debug(_ message: String, category: Category = .general, file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        log(message, level: .debug, category: category, file: file, function: function, line: line)
        #endif
    }

    /// Log warning message
    static func warning(_ message: String, category: Category = .general, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .default, category: category, file: file, function: function, line: line)
    }

    /// Log error message
    static func error(_ message: String, category: Category = .general, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .error, category: category, file: file, function: function, line: line)
    }

    /// Log critical/fatal message
    static func critical(_ message: String, category: Category = .general, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .fault, category: category, file: file, function: function, line: line)
    }

    // MARK: - Specialized Logging

    /// Log data operation
    static func data(_ message: String, level: Level = .info) {
        log(message, level: level.osLogType, category: .data)
    }

    /// Log sync operation
    static func sync(_ message: String, level: Level = .info) {
        log(message, level: level.osLogType, category: .sync)
    }

    /// Log UI event
    static func ui(_ message: String, level: Level = .info) {
        log(message, level: level.osLogType, category: .ui)
    }

    /// Log network operation
    static func network(_ message: String, level: Level = .info) {
        log(message, level: level.osLogType, category: .network)
    }

    /// Log notification event
    static func notification(_ message: String, level: Level = .info) {
        log(message, level: level.osLogType, category: .notification)
    }

    // MARK: - Performance Logging

    /// Measure execution time of a block
    static func measure<T>(_ label: String, category: Category = .general, block: () throws -> T) rethrows -> T {
        let start = CFAbsoluteTimeGetCurrent()
        defer {
            let duration = (CFAbsoluteTimeGetCurrent() - start) * 1000
            debug("⏱️ \(label) took \(String(format: "%.2f", duration))ms", category: category)
        }
        return try block()
    }

    /// Measure execution time of an async block
    static func measureAsync<T>(_ label: String, category: Category = .general, block: () async throws -> T) async rethrows -> T {
        let start = CFAbsoluteTimeGetCurrent()
        defer {
            let duration = (CFAbsoluteTimeGetCurrent() - start) * 1000
            debug("⏱️ \(label) took \(String(format: "%.2f", duration))ms", category: category)
        }
        return try await block()
    }

    // MARK: - Private Helpers

    private static func log(_ message: String, level: OSLogType, category: Category, file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        let formattedMessage = "[\(fileName):\(line)] \(function) - \(message)"

        let log = category.osLog

        os_log("%{public}@", log: log, type: level, formattedMessage)

        // Also print to console in debug builds
        #if DEBUG
        let emoji = level.emoji
        print("\(emoji) [\(category.rawValue)] \(formattedMessage)")
        #endif
    }

    // MARK: - Supporting Types

    enum Category: String {
        case general = "General"
        case data = "Data"
        case sync = "Sync"
        case ui = "UI"
        case network = "Network"
        case notification = "Notification"

        var osLog: OSLog {
            switch self {
            case .general: return Logger.generalLog
            case .data: return Logger.dataLog
            case .sync: return Logger.syncLog
            case .ui: return Logger.uiLog
            case .network: return Logger.networkLog
            case .notification: return Logger.notificationLog
            }
        }
    }

    enum Level {
        case debug
        case info
        case warning
        case error
        case critical

        var osLogType: OSLogType {
            switch self {
            case .debug: return .debug
            case .info: return .info
            case .warning: return .default
            case .error: return .error
            case .critical: return .fault
            }
        }
    }
}

// MARK: - OSLogType Extension

private extension OSLogType {
    var emoji: String {
        switch self {
        case .debug: return "🔍"
        case .info: return "ℹ️"
        case .default: return "⚠️"
        case .error: return "❌"
        case .fault: return "🔥"
        default: return "📝"
        }
    }
}

// MARK: - Usage Examples

/*
 Logger.info("App launched")
 Logger.debug("User tapped button", category: .ui)
 Logger.error("Failed to save task", category: .data)
 Logger.sync("Starting CloudKit sync...")
 Logger.network("API request completed")

 // Measure performance
 let result = Logger.measure("Fetch tasks") {
     // expensive operation
     return fetchTasks()
 }

 // Async performance
 let tasks = await Logger.measureAsync("Fetch tasks from CloudKit") {
     return await cloudKitService.fetchTasks()
 }
 */
