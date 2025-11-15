# Technical Architecture

## System Overview

ToDo Appy is a multi-platform native Apple application built using SwiftUI for the presentation layer, SwiftData for local persistence, and CloudKit for cloud synchronization. The architecture follows MVVM (Model-View-ViewModel) pattern with a unidirectional data flow.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     Presentation Layer                      │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐             │
│  │   iOS    │    │   iPad   │    │   macOS  │             │
│  │  Views   │    │  Views   │    │  Views   │             │
│  └────┬─────┘    └────┬─────┘    └────┬─────┘             │
│       │               │               │                     │
│       └───────────────┴───────────────┘                     │
│                       │                                     │
└───────────────────────┼─────────────────────────────────────┘
                        │
┌───────────────────────┼─────────────────────────────────────┐
│               ViewModel Layer (Observable)                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  TaskListViewModel, TaskDetailViewModel, etc.      │   │
│  └─────────────────────┬───────────────────────────────┘   │
└────────────────────────┼─────────────────────────────────────┘
                         │
┌────────────────────────┼─────────────────────────────────────┐
│                 Service Layer                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   DataSync   │  │  Notification │  │   Export     │     │
│  │   Service    │  │   Service     │  │   Service    │     │
│  └──────┬───────┘  └──────────────┘  └──────────────┘     │
│         │                                                   │
└─────────┼───────────────────────────────────────────────────┘
          │
┌─────────┼───────────────────────────────────────────────────┐
│         │           Data Layer                              │
│  ┌──────┴─────────────────────────────────┐                │
│  │         SwiftData Container             │                │
│  │  ┌──────────┐  ┌──────────┐  ┌───────┐ │                │
│  │  │   Task   │  │ Category │  │  Tag  │ │                │
│  │  │  Model   │  │  Model   │  │ Model │ │                │
│  │  └──────────┘  └──────────┘  └───────┘ │                │
│  └─────────────────────────────────────────┘                │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              CloudKit Container                      │  │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐    │  │
│  │  │   CKTask   │  │ CKCategory │  │   CKTag    │    │  │
│  │  │   Record   │  │   Record   │  │   Record   │    │  │
│  │  └────────────┘  └────────────┘  └────────────┘    │  │
│  └──────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────┘
```

## Core Components

### 1. Presentation Layer (SwiftUI)

#### Platform-Specific Views

**iOS/iPadOS**
- Optimized for touch interaction
- Tab bar navigation for primary sections
- Modal sheets for task creation/editing
- Swipe gestures for quick actions
- Context menus for additional options

**macOS**
- Three-pane layout (Sidebar → List → Detail)
- Menu bar integration
- Keyboard shortcuts
- Toolbar customization
- Touch Bar support (if available)

#### Shared Views
```swift
// Core reusable components
- TaskRowView: Individual task display
- TaskEditorView: Task creation/editing form
- CategoryPickerView: Category selection
- PriorityPickerView: Priority selection
- DatePickerView: Due date selection
- TagInputView: Tag management
```

### 2. ViewModel Layer

#### Responsibilities
- Business logic execution
- Data transformation for UI
- User action handling
- State management
- Error handling and user feedback

#### Key ViewModels

**TaskListViewModel**
```swift
@Observable
class TaskListViewModel {
    private let dataService: DataSyncService
    private let modelContext: ModelContext

    var tasks: [Task] = []
    var filteredTasks: [Task] = []
    var selectedCategory: Category?
    var searchText: String = ""
    var sortOption: SortOption = .dueDate
    var filterOption: FilterOption = .all

    // CRUD operations
    func createTask(_ task: Task)
    func updateTask(_ task: Task)
    func deleteTask(_ task: Task)
    func toggleCompletion(_ task: Task)

    // Filtering and sorting
    func applyFilters()
    func applySorting()

    // Sync operations
    func syncWithCloud()
}
```

**TaskDetailViewModel**
```swift
@Observable
class TaskDetailViewModel {
    var task: Task
    var isEditing: Bool = false
    var isDirty: Bool = false

    func save()
    func cancel()
    func delete()
    func addSubtask()
    func addTag(_ tag: Tag)
}
```

### 3. Service Layer

#### DataSyncService

**Purpose:** Orchestrates synchronization between local SwiftData and CloudKit

```swift
actor DataSyncService {
    private let container: CKContainer
    private let database: CKDatabase
    private let modelContext: ModelContext

    // Sync operations
    func syncToCloud(_ task: Task) async throws
    func syncFromCloud() async throws
    func handleRemoteChange(_ notification: CKNotification)

    // Conflict resolution
    func resolveConflict(_ local: Task, _ remote: CKRecord) -> Task

    // Subscription management
    func setupSubscriptions() async throws
    func handleSubscriptionNotification(_ notification: CKQueryNotification)
}
```

#### NotificationService

**Purpose:** Manages local notifications for task reminders

```swift
class NotificationService {
    private let center = UNUserNotificationCenter.current()

    func requestAuthorization() async throws
    func scheduleNotification(for task: Task)
    func cancelNotification(for task: Task)
    func updateNotification(for task: Task)
}
```

#### ExportService

**Purpose:** Handles data export in various formats

```swift
class ExportService {
    func exportToJSON(_ tasks: [Task]) -> Data
    func exportToCSV(_ tasks: [Task]) -> Data
    func exportToCalendar(_ tasks: [Task]) -> ICSData
    func importFromJSON(_ data: Data) -> [Task]
}
```

### 4. Data Layer

#### SwiftData Models

**Task Model**
```swift
@Model
final class Task {
    @Attribute(.unique) var id: UUID
    var title: String
    var taskDescription: String?
    var isCompleted: Bool
    var createdAt: Date
    var updatedAt: Date
    var dueDate: Date?
    var completedAt: Date?
    var priority: Priority?
    var reminderDate: Date?

    // Relationships
    @Relationship(deleteRule: .nullify) var category: Category?
    @Relationship(deleteRule: .cascade) var subtasks: [Task]?
    @Relationship var tags: [Tag]?
    @Relationship(inverse: \Task.subtasks) var parentTask: Task?

    // CloudKit sync metadata
    var cloudKitRecordID: String?
    var lastSyncedAt: Date?
    var syncStatus: SyncStatus
    var changeToken: String?

    init(title: String,
         description: String? = nil,
         dueDate: Date? = nil,
         priority: Priority? = nil,
         category: Category? = nil) {
        self.id = UUID()
        self.title = title
        self.taskDescription = description
        self.isCompleted = false
        self.createdAt = Date()
        self.updatedAt = Date()
        self.dueDate = dueDate
        self.priority = priority
        self.category = category
        self.syncStatus = .pending
    }
}

enum Priority: String, Codable {
    case low, medium, high, urgent

    var color: Color {
        switch self {
        case .low: return .green
        case .medium: return .yellow
        case .high: return .orange
        case .urgent: return .red
        }
    }
}

enum SyncStatus: String, Codable {
    case synced      // In sync with cloud
    case pending     // Waiting to sync
    case syncing     // Currently syncing
    case conflict    // Conflict detected
    case error       // Sync error occurred
}
```

**Category Model**
```swift
@Model
final class Category {
    @Attribute(.unique) var id: UUID
    var name: String
    var colorHex: String
    var iconName: String?
    var sortOrder: Int
    var createdAt: Date

    @Relationship(deleteRule: .nullify, inverse: \Task.category)
    var tasks: [Task]?

    // CloudKit sync metadata
    var cloudKitRecordID: String?
    var lastSyncedAt: Date?
    var syncStatus: SyncStatus

    init(name: String, colorHex: String, iconName: String? = nil) {
        self.id = UUID()
        self.name = name
        self.colorHex = colorHex
        self.iconName = iconName
        self.sortOrder = 0
        self.createdAt = Date()
        self.syncStatus = .pending
    }
}
```

**Tag Model**
```swift
@Model
final class Tag {
    @Attribute(.unique) var id: UUID
    var name: String
    var createdAt: Date

    @Relationship var tasks: [Task]?

    // CloudKit sync metadata
    var cloudKitRecordID: String?
    var lastSyncedAt: Date?
    var syncStatus: SyncStatus

    init(name: String) {
        self.id = UUID()
        self.name = name
        self.createdAt = Date()
        self.syncStatus = .pending
    }
}
```

#### CloudKit Schema

**CKTask Record**
```swift
Record Type: Task
Fields:
- id: String (indexed)
- title: String
- taskDescription: String?
- isCompleted: Int64 (0 or 1)
- createdAt: Date/Time
- updatedAt: Date/Time (indexed)
- dueDate: Date/Time? (indexed)
- completedAt: Date/Time?
- priority: String?
- reminderDate: Date/Time?
- categoryID: String? (reference or ID)
- parentTaskID: String? (reference)
- tagIDs: List<String>

Indexes:
- updatedAt (for efficient sync queries)
- dueDate (for reminder queries)
- isCompleted (for filtering)
```

**CKCategory Record**
```swift
Record Type: Category
Fields:
- id: String (indexed)
- name: String
- colorHex: String
- iconName: String?
- sortOrder: Int64
- createdAt: Date/Time

Indexes:
- sortOrder
```

**CKTag Record**
```swift
Record Type: Tag
Fields:
- id: String (indexed)
- name: String (indexed)
- createdAt: Date/Time

Indexes:
- name (for search)
```

## Data Flow

### Creating a New Task

```
User Action (View)
    ↓
TaskDetailViewModel.save()
    ↓
SwiftData ModelContext.insert(task)
    ↓
SwiftData auto-save
    ↓
DataSyncService.syncToCloud(task)
    ↓
CloudKit CKDatabase.save(ckRecord)
    ↓
CloudKit Notification → Other Devices
    ↓
Other Devices: DataSyncService.handleRemoteChange()
    ↓
Other Devices: SwiftData update
    ↓
UI refresh via @Observable
```

### Syncing from Cloud

```
App Launch / Background Refresh
    ↓
DataSyncService.syncFromCloud()
    ↓
Fetch CKRecords with changes since last sync
    ↓
For each CKRecord:
    ├── Check if local Task exists
    ├── If exists: Compare timestamps
    │   ├── Remote newer: Update local
    │   ├── Local newer: Push to cloud
    │   └── Conflict: Resolve via strategy
    └── If not exists: Create local Task
    ↓
Update lastSyncedAt timestamp
    ↓
UI refresh
```

## Offline Support

### Strategy
1. **Write-Ahead:** All changes written to local SwiftData first
2. **Queue System:** Failed sync operations queued for retry
3. **Background Sync:** Periodic sync attempts when network available
4. **Conflict Resolution:** Last-write-wins with timestamp comparison

### Implementation
```swift
actor SyncQueue {
    private var pendingOperations: [SyncOperation] = []

    func enqueue(_ operation: SyncOperation)
    func processPendingOperations() async
    func retryFailedOperations() async
}

struct SyncOperation {
    let id: UUID
    let type: OperationType
    let recordID: String
    let timestamp: Date
    var retryCount: Int
    var lastError: Error?

    enum OperationType {
        case create, update, delete
    }
}
```

## Performance Optimization

### Data Loading
- **Lazy Loading:** Load tasks on-demand for large lists
- **Pagination:** Fetch completed tasks in chunks
- **Fetch Limits:** Limit initial fetch to recent tasks
- **Predicates:** Use efficient SwiftData predicates

### UI Rendering
- **List Virtualization:** SwiftUI List handles this automatically
- **Image Caching:** Cache category icons and symbols
- **Debouncing:** Debounce search input (300ms)
- **Animation Optimization:** Use .animation() sparingly

### Sync Optimization
- **Batch Operations:** Group multiple changes into single CloudKit save
- **Change Tokens:** Track last sync point to fetch only new changes
- **Selective Sync:** Only sync changed fields
- **Subscription:** Use CloudKit subscriptions for real-time updates

```swift
// Example: Batch sync optimization
actor BatchSyncCoordinator {
    private var batchWindow: TimeInterval = 2.0
    private var pendingChanges: [Task] = []
    private var syncTask: Task<Void, Error>?

    func scheduleSync(_ task: Task) async {
        pendingChanges.append(task)

        // Cancel existing scheduled sync
        syncTask?.cancel()

        // Schedule new batch sync after window
        syncTask = Task {
            try await Task.sleep(nanoseconds: UInt64(batchWindow * 1_000_000_000))
            await performBatchSync()
        }
    }

    private func performBatchSync() async {
        let changes = pendingChanges
        pendingChanges.removeAll()

        // Batch save to CloudKit
        let records = changes.map { convertToCloudKitRecord($0) }
        try await cloudKitDatabase.save(records)
    }
}
```

## Security & Privacy

### Data Encryption
- **At Rest:** SwiftData uses iOS data protection
- **In Transit:** CloudKit uses TLS 1.3
- **iCloud:** End-to-end encryption for private database

### Access Control
- **iCloud Account:** Required for sync
- **Private Database:** Only user can access their data
- **No Server:** No custom backend to secure

### Privacy Principles
- **No Analytics:** Zero telemetry or tracking
- **No Third-Party:** No external dependencies
- **Local First:** App fully functional offline
- **User Ownership:** User owns all data in their iCloud

## Error Handling

### Error Types
```swift
enum AppError: LocalizedError {
    case networkUnavailable
    case cloudKitUnavailable
    case syncConflict(Task, CKRecord)
    case invalidData
    case permissionDenied
    case quotaExceeded

    var errorDescription: String? {
        switch self {
        case .networkUnavailable:
            return "No internet connection. Changes will sync when online."
        case .cloudKitUnavailable:
            return "iCloud is unavailable. Please check your settings."
        case .syncConflict:
            return "A sync conflict occurred. Using most recent version."
        case .invalidData:
            return "Invalid data encountered."
        case .permissionDenied:
            return "Permission denied. Please enable iCloud in Settings."
        case .quotaExceeded:
            return "iCloud storage quota exceeded."
        }
    }
}
```

### Error Recovery
```swift
struct ErrorHandler {
    func handle(_ error: Error) async -> RecoveryAction {
        switch error {
        case let ckError as CKError:
            return await handleCloudKitError(ckError)
        case let appError as AppError:
            return handleAppError(appError)
        default:
            return .showAlert(error.localizedDescription)
        }
    }

    private func handleCloudKitError(_ error: CKError) async -> RecoveryAction {
        switch error.code {
        case .networkUnavailable, .networkFailure:
            return .queueForRetry
        case .notAuthenticated:
            return .promptForICloudSignIn
        case .quotaExceeded:
            return .showAlert("iCloud storage full")
        case .serverRecordChanged:
            return .resolveConflict
        default:
            return .showAlert(error.localizedDescription)
        }
    }
}

enum RecoveryAction {
    case queueForRetry
    case promptForICloudSignIn
    case showAlert(String)
    case resolveConflict
    case ignoreError
}
```

## Testing Strategy

### Unit Tests
- Model validation logic
- ViewModel business logic
- Service layer operations
- Sync conflict resolution
- Data transformations

### Integration Tests
- SwiftData CRUD operations
- CloudKit sync operations
- End-to-end sync flow
- Offline-to-online transition
- Error recovery scenarios

### UI Tests
- Critical user flows (create, edit, delete task)
- Multi-platform interactions
- Accessibility
- Performance benchmarks

## Deployment Architecture

### Development Environment
```
Developer Account: Personal
Bundle ID: com.personal.todoappy
Capabilities: iCloud, Push Notifications, Background Modes
CloudKit Container: iCloud.com.personal.todoappy
Environment: Development
```

### Production Environment
```
Environment: Production
CloudKit Container: iCloud.com.personal.todoappy
Distribution: TestFlight → App Store (optional)
```

## Scalability Considerations

### Current Scope (Personal Use)
- Single user
- Expected: < 10,000 tasks lifetime
- CloudKit free tier: Sufficient
- Performance: Optimized for personal load

### Future Scalability (If Needed)
- Pagination for large task lists
- Archive old completed tasks
- CloudKit public database for sharing
- Custom sync for heavy usage

## Technology Decisions

### Why SwiftData over Core Data?
- Modern Swift-first API
- Better SwiftUI integration
- Reduced boilerplate
- Macro-based models
- Still uses Core Data under the hood

### Why CloudKit over Custom Backend?
- Zero server maintenance
- Native iOS integration
- Automatic conflict resolution
- Built-in authentication (iCloud)
- Cost-effective (free tier)
- Privacy-focused (private database)

### Why SwiftUI over UIKit?
- Single codebase for all platforms
- Declarative, modern syntax
- Built-in state management
- Automatic layout adaptation
- Future-proof

## Monitoring & Debugging

### Development Tools
- Xcode Instruments for performance profiling
- CloudKit Dashboard for data inspection
- Console.app for logging
- Network Link Conditioner for offline testing

### Logging Strategy
```swift
import OSLog

extension Logger {
    private static let subsystem = "com.personal.todoappy"

    static let ui = Logger(subsystem: subsystem, category: "UI")
    static let data = Logger(subsystem: subsystem, category: "Data")
    static let sync = Logger(subsystem: subsystem, category: "Sync")
    static let network = Logger(subsystem: subsystem, category: "Network")
}

// Usage
Logger.sync.info("Starting sync operation")
Logger.sync.error("Sync failed: \(error.localizedDescription)")
```

---

**Last Updated:** 2025-11-15
