//
//  Environment.swift
//  ToDo-Appy
//
//  Created by Agent 1: Foundation & Setup Specialist
//  Environment configuration and detection
//

import Foundation

/// App environment configuration
enum Environment {
    case development
    case staging
    case production

    /// Current environment
    static var current: Environment {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }

    /// Whether running in debug mode
    static var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }

    /// Whether running in production
    static var isProduction: Bool {
        current == .production
    }

    /// Whether running in Xcode preview
    static var isPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

    /// Whether running in simulator
    static var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }

    /// Whether running on device
    static var isDevice: Bool {
        !isSimulator
    }

    /// Whether running tests
    static var isTesting: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }

    /// CloudKit environment
    var cloudKitEnvironment: String {
        switch self {
        case .development:
            return "Development"
        case .staging:
            return "Development" // Use development for staging
        case .production:
            return "Production"
        }
    }

    /// Enable verbose logging
    var verboseLogging: Bool {
        switch self {
        case .development:
            return true
        case .staging:
            return true
        case .production:
            return false
        }
    }

    /// Enable debug features
    var debugFeaturesEnabled: Bool {
        self != .production
    }
}

// MARK: - Device Info

enum DeviceInfo {
    /// Device model name
    static var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }

    /// iOS version
    static var osVersion: String {
        let os = ProcessInfo.processInfo.operatingSystemVersion
        return "\(os.majorVersion).\(os.minorVersion).\(os.patchVersion)"
    }

    /// App version
    static var appVersion: String {
        AppConstants.appVersion
    }

    /// Build number
    static var buildNumber: String {
        AppConstants.buildNumber
    }

    /// Full version string
    static var versionString: String {
        "\(appVersion) (\(buildNumber))"
    }

    /// Device name (e.g., "iPhone 15 Pro")
    static var deviceName: String {
        #if os(iOS)
        return UIDevice.current.name
        #elseif os(macOS)
        return Host.current().localizedName ?? "Mac"
        #else
        return "Unknown"
        #endif
    }

    /// System name (iOS/iPadOS/macOS)
    static var systemName: String {
        #if os(iOS)
        return UIDevice.current.systemName
        #elseif os(macOS)
        return "macOS"
        #else
        return "Unknown"
        #endif
    }
}
