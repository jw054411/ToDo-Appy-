//
//  NetworkMonitor.swift
//  ToDo-Appy
//
//  Created by Agent 1: Foundation & Setup Specialist
//  Monitor network connectivity status
//

import Foundation
import Network
import Combine

/// Monitor network connectivity and status
@MainActor
class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    /// Current network connection status
    @Published private(set) var isConnected: Bool = false

    /// Current connection type
    @Published private(set) var connectionType: ConnectionType = .unknown

    /// Whether connection is expensive (cellular)
    @Published private(set) var isExpensive: Bool = false

    /// Whether connection is constrained (low data mode)
    @Published private(set) var isConstrained: Bool = false

    private init() {
        startMonitoring()
    }

    /// Start monitoring network changes
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor [weak self] in
                guard let self = self else { return }

                self.isConnected = path.status == .satisfied
                self.isExpensive = path.isExpensive
                self.isConstrained = path.isConstrained
                self.connectionType = self.determineConnectionType(from: path)

                self.logConnectionChange()
            }
        }

        monitor.start(queue: queue)
    }

    /// Stop monitoring
    func stopMonitoring() {
        monitor.cancel()
    }

    /// Determine connection type from network path
    private func determineConnectionType(from path: NWPath) -> ConnectionType {
        if path.usesInterfaceType(.wifi) {
            return .wifi
        } else if path.usesInterfaceType(.cellular) {
            return .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            return .ethernet
        } else if path.status == .satisfied {
            return .other
        } else {
            return .none
        }
    }

    /// Log connection changes
    private func logConnectionChange() {
        if isConnected {
            Logger.network("Network connected: \(connectionType.displayName)")
            if isExpensive {
                Logger.network("Connection is expensive (cellular)")
            }
            if isConstrained {
                Logger.network("Connection is constrained (low data mode)")
            }
        } else {
            Logger.network("Network disconnected")
        }
    }

    // MARK: - Helper Properties

    /// Whether connected via WiFi
    var isWiFi: Bool {
        connectionType == .wifi
    }

    /// Whether connected via cellular
    var isCellular: Bool {
        connectionType == .cellular
    }

    /// Whether should sync (connected and not constrained)
    var shouldSync: Bool {
        isConnected && !isConstrained
    }

    /// Whether should download large files (WiFi or unlimited cellular)
    var shouldDownloadLargeFiles: Bool {
        isWiFi || (isCellular && !isExpensive && !isConstrained)
    }

    // MARK: - Connection Type

    enum ConnectionType: String {
        case wifi = "WiFi"
        case cellular = "Cellular"
        case ethernet = "Ethernet"
        case other = "Other"
        case none = "None"
        case unknown = "Unknown"

        var displayName: String {
            rawValue
        }

        var icon: String {
            switch self {
            case .wifi: return "wifi"
            case .cellular: return "antenna.radiowaves.left.and.right"
            case .ethernet: return "cable.connector"
            case .other: return "network"
            case .none, .unknown: return "wifi.slash"
            }
        }
    }
}

// MARK: - SwiftUI Environment

private struct NetworkMonitorKey: EnvironmentKey {
    static let defaultValue = NetworkMonitor.shared
}

extension EnvironmentValues {
    var networkMonitor: NetworkMonitor {
        get { self[NetworkMonitorKey.self] }
        set { self[NetworkMonitorKey.self] = newValue }
    }
}

// MARK: - Usage Examples

/*
 // In App or View:
 @StateObject private var networkMonitor = NetworkMonitor.shared

 // Check connection:
 if networkMonitor.isConnected {
     // Sync data
 }

 // Check connection type:
 if networkMonitor.isWiFi {
     // Download large files
 }

 // Show UI based on connection:
 if !networkMonitor.isConnected {
     Text("No internet connection")
         .foregroundColor(.red)
 }

 // Use in ViewModel:
 if NetworkMonitor.shared.shouldSync {
     await syncService.sync()
 }
 */
