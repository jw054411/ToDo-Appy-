//
//  NetworkMonitor.swift
//  ToDo-Appy
//
//  Network connectivity monitoring service
//  Tracks network status and triggers sync when connection is restored
//

import Foundation
import Network
import Combine

/// Observable network monitor using NWPathMonitor
@Observable
class NetworkMonitor {

    // MARK: - Properties

    /// Singleton instance for app-wide access
    static let shared = NetworkMonitor()

    /// Current network connectivity status
    private(set) var isConnected: Bool = false

    /// Network connection type
    private(set) var connectionType: ConnectionType = .unknown

    /// Network path monitor
    private let monitor: NWPathMonitor

    /// Dispatch queue for monitor callbacks
    private let queue = DispatchQueue(label: "com.todoappy.networkmonitor")

    /// Callbacks to trigger when network status changes
    private var statusChangeHandlers: [(Bool) -> Void] = []

    // MARK: - Types

    enum ConnectionType {
        case wifi
        case cellular
        case wiredEthernet
        case unknown

        var description: String {
            switch self {
            case .wifi: return "Wi-Fi"
            case .cellular: return "Cellular"
            case .wiredEthernet: return "Ethernet"
            case .unknown: return "Unknown"
            }
        }
    }

    // MARK: - Initialization

    private init() {
        monitor = NWPathMonitor()
        setupMonitoring()
    }

    // MARK: - Monitoring

    /// Start monitoring network status
    func startMonitoring() {
        monitor.start(queue: queue)
        print("📡 Network monitoring started")
    }

    /// Stop monitoring network status
    func stopMonitoring() {
        monitor.cancel()
        print("📡 Network monitoring stopped")
    }

    /// Set up path update handler
    private func setupMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }

            let wasConnected = self.isConnected
            self.isConnected = path.status == .satisfied

            // Determine connection type
            self.connectionType = self.determineConnectionType(from: path)

            // Log status changes
            if self.isConnected != wasConnected {
                DispatchQueue.main.async {
                    if self.isConnected {
                        print("✅ Network connected (\(self.connectionType.description))")
                        self.notifyConnectionRestored()
                    } else {
                        print("❌ Network disconnected")
                        self.notifyConnectionLost()
                    }
                }
            }
        }
    }

    /// Determine connection type from network path
    private func determineConnectionType(from path: NWPath) -> ConnectionType {
        if path.usesInterfaceType(.wifi) {
            return .wifi
        } else if path.usesInterfaceType(.cellular) {
            return .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            return .wiredEthernet
        } else {
            return .unknown
        }
    }

    // MARK: - Callbacks

    /// Register a callback for network status changes
    func onStatusChange(_ handler: @escaping (Bool) -> Void) {
        statusChangeHandlers.append(handler)
    }

    /// Notify all registered handlers of connection restored
    private func notifyConnectionRestored() {
        for handler in statusChangeHandlers {
            handler(true)
        }
    }

    /// Notify all registered handlers of connection lost
    private func notifyConnectionLost() {
        for handler in statusChangeHandlers {
            handler(false)
        }
    }

    // MARK: - Public Methods

    /// Check if currently connected
    func checkConnection() -> Bool {
        return isConnected
    }

    /// Get current connection type
    func getCurrentConnectionType() -> ConnectionType {
        return connectionType
    }

    /// Check if connection is expensive (cellular, metered wifi)
    func isConnectionExpensive() -> Bool {
        return connectionType == .cellular
    }

    /// Get connection quality description
    func getConnectionQuality() -> String {
        if !isConnected {
            return "No Connection"
        }

        switch connectionType {
        case .wifi, .wiredEthernet:
            return "Good"
        case .cellular:
            return "Cellular"
        case .unknown:
            return "Unknown"
        }
    }
}

// MARK: - Network Reachability Helper

extension NetworkMonitor {
    /// Wait for network connection with timeout
    /// Returns true if connected, false if timeout
    func waitForConnection(timeout: TimeInterval = 5.0) async -> Bool {
        if isConnected {
            return true
        }

        return await withCheckedContinuation { continuation in
            var completed = false
            var timeoutTask: Task<Void, Never>?

            // Set up connection handler
            let handler: (Bool) -> Void = { connected in
                if connected && !completed {
                    completed = true
                    timeoutTask?.cancel()
                    continuation.resume(returning: true)
                }
            }

            onStatusChange(handler)

            // Set up timeout
            timeoutTask = Task {
                try? await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                if !completed {
                    completed = true
                    continuation.resume(returning: false)
                }
            }
        }
    }
}

// MARK: - SwiftUI Integration

import SwiftUI

/// Environment key for network monitor
struct NetworkMonitorKey: EnvironmentKey {
    static let defaultValue = NetworkMonitor.shared
}

extension EnvironmentValues {
    var networkMonitor: NetworkMonitor {
        get { self[NetworkMonitorKey.self] }
        set { self[NetworkMonitorKey.self] = newValue }
    }
}

/// View modifier for network status monitoring
struct NetworkStatusModifier: ViewModifier {
    @State private var isConnected: Bool = true
    let monitor = NetworkMonitor.shared

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if !isConnected {
                    HStack {
                        Image(systemName: "wifi.slash")
                        Text("No Internet Connection")
                    }
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.red)
                    .cornerRadius(8)
                    .padding(.top, 8)
                }
            }
            .onAppear {
                monitor.startMonitoring()
                isConnected = monitor.isConnected

                monitor.onStatusChange { connected in
                    isConnected = connected
                }
            }
    }
}

extension View {
    /// Show network status banner
    func networkStatusBanner() -> some View {
        modifier(NetworkStatusModifier())
    }
}
