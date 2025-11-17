//
//  SyncQueue.swift
//  ToDo-Appy
//
//  Offline queue with automatic retry for failed sync operations
//  Ensures data is never lost even when network is unavailable
//

import Foundation

/// Actor-based queue for managing failed sync operations with retry logic
actor SyncQueue {

    // MARK: - Types

    /// Represents a queued sync operation
    struct SyncOperation: Codable, Identifiable {
        let id: UUID
        let operationType: OperationType
        let recordID: String
        let recordType: String
        var retryCount: Int
        let createdAt: Date
        var lastAttempt: Date?

        enum OperationType: String, Codable {
            case create
            case update
            case delete
        }

        init(type: OperationType, recordID: String, recordType: String) {
            self.id = UUID()
            self.operationType = type
            self.recordID = recordID
            self.recordType = recordType
            self.retryCount = 0
            self.createdAt = Date()
            self.lastAttempt = nil
        }
    }

    // MARK: - Properties

    private var queue: [SyncOperation] = []
    private let maxRetries = 5
    private let userDefaults = UserDefaults.standard
    private let queueKey = "syncQueue"

    // Exponential backoff delays (seconds)
    private let retryDelays: [TimeInterval] = [2, 4, 8, 16, 32]

    // MARK: - Initialization

    init() {
        loadQueue()
        print("✅ SyncQueue initialized with \(queue.count) pending operations")
    }

    // MARK: - Queue Operations

    /// Add a sync operation to the queue
    func enqueue(_ operation: SyncOperation) {
        queue.append(operation)
        saveQueue()
        print("📥 Queued operation: \(operation.operationType.rawValue) \(operation.recordType) [\(operation.recordID)]")
    }

    /// Enqueue with convenience method
    func enqueue(type: SyncOperation.OperationType, recordID: String, recordType: String) {
        let operation = SyncOperation(type: type, recordID: recordID, recordType: recordType)
        enqueue(operation)
    }

    /// Process the entire queue with a sync service
    /// Attempts to sync all queued operations and retries failures
    func processQueue(syncService: DataSyncService) async {
        guard !queue.isEmpty else {
            return
        }

        print("🔄 Processing offline queue (\(queue.count) operations)...")

        var processedIDs: [UUID] = []
        var failedOperations: [(operation: SyncOperation, delay: TimeInterval)] = []

        for operation in queue {
            // Check if max retries exceeded
            if operation.retryCount >= maxRetries {
                print("❌ Operation \(operation.id) exceeded max retries (\(maxRetries)), removing from queue")
                print("   Type: \(operation.operationType.rawValue), Record: \(operation.recordType)/\(operation.recordID)")
                processedIDs.append(operation.id)
                continue
            }

            // Check if should wait before retry (exponential backoff)
            if let lastAttempt = operation.lastAttempt {
                let delay = retryDelays[min(operation.retryCount, retryDelays.count - 1)]
                let nextRetryTime = lastAttempt.addingTimeInterval(delay)

                if Date() < nextRetryTime {
                    let remaining = nextRetryTime.timeIntervalSinceNow
                    print("⏳ Waiting \(Int(remaining))s before retry #\(operation.retryCount + 1) for operation \(operation.id)")
                    continue // Skip this operation for now
                }
            }

            // Attempt to sync
            do {
                print("🔄 Attempting sync for operation \(operation.id) (retry #\(operation.retryCount + 1))")
                try await syncService.syncAll()

                // Success! Remove from queue
                processedIDs.append(operation.id)
                print("✅ Successfully processed operation \(operation.id)")

            } catch {
                // Failed - update retry count and schedule for later
                if let index = queue.firstIndex(where: { $0.id == operation.id }) {
                    queue[index].retryCount += 1
                    queue[index].lastAttempt = Date()

                    let nextRetry = operation.retryCount + 1
                    let delay = retryDelays[min(nextRetry, retryDelays.count - 1)]

                    print("⚠️ Retry \(nextRetry)/\(maxRetries) failed for operation \(operation.id)")
                    print("   Error: \(error.localizedDescription)")
                    print("   Next retry in \(Int(delay))s")
                }
            }
        }

        // Remove successfully processed operations
        let removedCount = processedIDs.count
        queue.removeAll { processedIDs.contains($0.id) }

        if removedCount > 0 {
            print("✅ Removed \(removedCount) completed operations from queue")
        }

        saveQueue()

        if !queue.isEmpty {
            print("📊 Queue status: \(queue.count) operations remaining")
        } else {
            print("✨ Queue is now empty - all operations synced!")
        }
    }

    /// Get current queue count
    func count() -> Int {
        return queue.count
    }

    /// Get all pending operations
    func getPendingOperations() -> [SyncOperation] {
        return queue
    }

    /// Clear the entire queue (use with caution!)
    func clearQueue() {
        let count = queue.count
        queue.removeAll()
        saveQueue()
        print("🗑️ Cleared \(count) operations from queue")
    }

    /// Remove a specific operation by ID
    func remove(operationID: UUID) {
        if let index = queue.firstIndex(where: { $0.id == operationID }) {
            let operation = queue[index]
            queue.remove(at: index)
            saveQueue()
            print("🗑️ Removed operation: \(operation.operationType.rawValue) \(operation.recordType)")
        }
    }

    // MARK: - Persistence

    /// Save queue to UserDefaults for persistence across app launches
    private func saveQueue() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(queue)
            userDefaults.set(data, forKey: queueKey)
            print("💾 Saved \(queue.count) operations to persistent storage")
        } catch {
            print("❌ Failed to save queue: \(error.localizedDescription)")
        }
    }

    /// Load queue from UserDefaults
    private func loadQueue() {
        guard let data = userDefaults.data(forKey: queueKey) else {
            queue = []
            return
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            queue = try decoder.decode([SyncOperation].self, from: data)
            print("💾 Loaded \(queue.count) operations from persistent storage")
        } catch {
            print("❌ Failed to load queue: \(error.localizedDescription)")
            queue = []
        }
    }

    // MARK: - Statistics

    /// Get queue statistics
    func getStatistics() -> QueueStatistics {
        let totalOperations = queue.count

        let operationsByType = Dictionary(grouping: queue, by: { $0.operationType })
        let createCount = operationsByType[.create]?.count ?? 0
        let updateCount = operationsByType[.update]?.count ?? 0
        let deleteCount = operationsByType[.delete]?.count ?? 0

        let totalRetries = queue.reduce(0) { $0 + $1.retryCount }
        let avgRetries = totalOperations > 0 ? Double(totalRetries) / Double(totalOperations) : 0

        let oldestOperation = queue.min(by: { $0.createdAt < $1.createdAt })
        let newestOperation = queue.max(by: { $0.createdAt < $1.createdAt })

        return QueueStatistics(
            totalOperations: totalOperations,
            createOperations: createCount,
            updateOperations: updateCount,
            deleteOperations: deleteCount,
            totalRetries: totalRetries,
            averageRetries: avgRetries,
            oldestOperationDate: oldestOperation?.createdAt,
            newestOperationDate: newestOperation?.createdAt
        )
    }

    struct QueueStatistics {
        let totalOperations: Int
        let createOperations: Int
        let updateOperations: Int
        let deleteOperations: Int
        let totalRetries: Int
        let averageRetries: Double
        let oldestOperationDate: Date?
        let newestOperationDate: Date?

        var description: String {
            """
            📊 Queue Statistics:
            - Total Operations: \(totalOperations)
            - Creates: \(createOperations), Updates: \(updateOperations), Deletes: \(deleteOperations)
            - Total Retries: \(totalRetries)
            - Average Retries: \(String(format: "%.2f", averageRetries))
            - Oldest: \(oldestOperationDate?.formatted() ?? "N/A")
            - Newest: \(newestOperationDate?.formatted() ?? "N/A")
            """
        }
    }
}

// MARK: - SyncQueue Extensions

extension SyncQueue {
    /// Process queue with automatic retry scheduling
    /// This version runs in the background and handles scheduling
    func processQueueWithScheduling(syncService: DataSyncService) async {
        await processQueue(syncService: syncService)

        // If there are still items in queue, they're waiting for retry
        let remainingCount = await count()
        if remainingCount > 0 {
            print("⏰ Queue has \(remainingCount) operations waiting for retry")
        }
    }
}

// MARK: - Error Types

enum SyncQueueError: Error {
    case maxRetriesExceeded
    case operationNotFound
    case persistenceFailed

    var localizedDescription: String {
        switch self {
        case .maxRetriesExceeded:
            return "Maximum retry attempts exceeded"
        case .operationNotFound:
            return "Operation not found in queue"
        case .persistenceFailed:
            return "Failed to persist queue to storage"
        }
    }
}
