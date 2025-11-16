# Agent 1: Foundation & Setup Specialist

**Role:** Set up the Xcode project, configure capabilities, design CloudKit schema, and establish the foundation for all other agents.

**Start:** Immediately
**Blocks:** All other agents (they need the project structure)
**Estimated Time:** 4-6 hours

---

## 🎯 Mission
Create a production-ready Xcode project with proper configuration, CloudKit schema, and folder structure that enables parallel development by 4 other agents.

---

## ✅ TODO List

### TASK 1: Xcode Project Initialization
**Priority:** CRITICAL - Must complete first
**Time:** 45 minutes

#### Subtasks:
- [ ] 1.1: Create new Xcode project
  - Template: Multiplatform App
  - Product Name: `ToDo-Appy`
  - Organization Identifier: `com.personal.todoappy`
  - Bundle Identifier: `com.personal.todoappy`
  - Language: Swift
  - Interface: SwiftUI
  - Storage: SwiftData
  - Include Tests: YES
  - Include UI Tests: YES

- [ ] 1.2: Configure deployment targets
  - iOS: 17.0+
  - iPadOS: 17.0+
  - macOS: 14.0+
  - Verify in project settings → General → Deployment Info

- [ ] 1.3: Create folder structure
  ```
  ToDo-Appy/
  ├── App/
  │   ├── ToDoAppyApp.swift (already exists)
  │   └── AppDelegate.swift (create)
  ├── Models/
  │   └── Protocols/
  ├── ViewModels/
  ├── Views/
  │   ├── iPhone/
  │   ├── iPad/
  │   ├── Mac/
  │   └── Components/
  ├── Services/
  ├── DesignSystem/
  │   └── Components/
  ├── Utilities/
  └── Resources/
      └── Assets.xcassets/
  ```
  - Create physical folders in Finder
  - Add groups to Xcode matching folder structure
  - Verify groups are linked to actual folders (not virtual groups)

- [ ] 1.4: Configure Info.plist
  - Add key: `UIUserInterfaceStyle` = `Dark` (force dark mode only)
  - Add notification usage descriptions:
    - `NSUserNotificationsUsageDescription`: "ToDo-Appy needs notification permission to remind you about tasks."
  - Verify app supports iPhone, iPad, and Mac

- [ ] 1.5: Initial build test
  - Build for iOS Simulator → Should succeed
  - Build for Mac → Should succeed
  - Run on iOS Simulator → App launches with default "Hello, World"
  - Run on Mac → App launches

**Acceptance Criteria:**
- ✅ Project builds on all platforms without errors
- ✅ Folder structure matches specification exactly
- ✅ App forced to dark mode
- ✅ Ready for other agents to add code

**Deliverable:** Commit `feat(setup): initialize Xcode project with folder structure`

---

### TASK 2: Configure Capabilities & Entitlements
**Priority:** CRITICAL
**Time:** 30 minutes
**Depends On:** Task 1 complete

#### Subtasks:
- [ ] 2.1: Enable iCloud capability
  - Open project settings → Signing & Capabilities
  - Click "+ Capability" → iCloud
  - Check ✅ CloudKit
  - Verify entitlements file created: `ToDo-Appy.entitlements`

- [ ] 2.2: Create CloudKit container
  - In iCloud capability section
  - Click "+" under Containers
  - Enter: `iCloud.com.personal.todoappy`
  - Set as default container (checkbox)
  - This will create container in Apple Developer Portal

- [ ] 2.3: Enable Push Notifications
  - Click "+ Capability" → Push Notifications
  - Verify `aps-environment` added to entitlements

- [ ] 2.4: Enable Background Modes
  - Click "+ Capability" → Background Modes
  - Check ✅ Remote notifications
  - Check ✅ Background fetch

- [ ] 2.5: Verify entitlements file
  - Open `ToDo-Appy.entitlements`
  - Should contain:
    ```xml
    <key>com.apple.developer.icloud-container-identifiers</key>
    <array>
        <string>iCloud.com.personal.todoappy</string>
    </array>
    <key>com.apple.developer.icloud-services</key>
    <array>
        <string>CloudKit</string>
    </array>
    <key>com.apple.developer.ubiquity-container-identifiers</key>
    <array>
        <string>iCloud.com.personal.todoappy</string>
    </array>
    <key>aps-environment</key>
    <string>development</string>
    ```

- [ ] 2.6: Configure for macOS target
  - Select macOS target in project settings
  - Repeat steps 2.1-2.5 for macOS
  - Verify macOS also has entitlements file

**Acceptance Criteria:**
- ✅ iCloud capability enabled on all targets
- ✅ CloudKit container created and set as default
- ✅ Push notifications enabled
- ✅ Background modes configured
- ✅ Entitlements file valid

**Deliverable:** Commit `feat(config): enable iCloud, CloudKit, and push notifications`

---

### TASK 3: CloudKit Schema Design
**Priority:** CRITICAL - Agent 2 & 3 need this
**Time:** 90 minutes
**Depends On:** Task 2 complete (CloudKit container created)

#### Subtasks:
- [ ] 3.1: Access CloudKit Dashboard
  - Go to: https://icloud.developer.apple.com/dashboard
  - Sign in with Apple Developer account
  - Select container: `iCloud.com.personal.todoappy`
  - Switch to **Development** environment (top right)

- [ ] 3.2: Create CKTask Record Type
  - Click "Schema" → "Record Types"
  - Click "+" to add new type
  - Name: `CKTask`
  - Add fields (click "+ Add Field" for each):

  **Core Fields:**
  - `id` → String, Indexed, Queryable, Sortable
  - `title` → String, Indexed, Queryable, Sortable
  - `taskDescription` → String
  - `isCompleted` → Int64, Indexed
  - `createdAt` → Date/Time, Indexed, Sortable
  - `updatedAt` → Date/Time, Indexed, Sortable
  - `dueDate` → Date/Time, Indexed, Sortable
  - `priority` → Int64, Indexed (0=none, 1=low, 2=medium, 3=high, 4=urgent)
  - `categoryID` → String, Indexed, Queryable
  - `sortOrder` → Int64, Sortable
  - `isDeleted` → Int64, Indexed

  **Recurring Task Fields:**
  - `isRecurring` → Int64, Indexed
  - `recurrenceType` → String (daily/weekly/monthly/yearly/custom)
  - `recurrenceInterval` → Int64
  - `recurrenceEndDate` → Date/Time
  - `recurrenceDaysOfWeek` → List<Int64>
  - `recurrenceDayOfMonth` → Int64
  - `recurrenceMonthOfYear` → Int64
  - `parentRecurringTaskID` → String

  **Reminder Fields:**
  - `hasReminder` → Int64, Indexed
  - `reminderTime` → Date/Time
  - `reminderOffset` → Int64

  **Relationships:**
  - `tagIDs` → List<String>
  - `subtaskIDs` → List<String>
  - `parentTaskID` → String

  - Click "Save" when done

- [ ] 3.3: Create CKCategory Record Type
  - Click "+" to add new type
  - Name: `CKCategory`
  - Add fields:
    - `id` → String, Indexed, Queryable, Sortable
    - `name` → String, Indexed, Queryable, Sortable
    - `colorHex` → String
    - `icon` → String
    - `sortOrder` → Int64, Sortable
    - `createdAt` → Date/Time
    - `updatedAt` → Date/Time
    - `isDeleted` → Int64, Indexed
  - Click "Save"

- [ ] 3.4: Create CKTag Record Type
  - Click "+" to add new type
  - Name: `CKTag`
  - Add fields:
    - `id` → String, Indexed, Queryable, Sortable
    - `name` → String, Indexed, Queryable, Sortable
    - `colorHex` → String
    - `createdAt` → Date/Time
    - `updatedAt` → Date/Time
    - `isDeleted` → Int64, Indexed
  - Click "Save"

- [ ] 3.5: Create Custom Zone
  - Click "Data" → "Zones"
  - Click "+" to add new zone
  - Zone Name: `TasksZone`
  - Click "Create"
  - This enables change token tracking for efficient sync

- [ ] 3.6: Create Subscriptions
  - Click "Subscriptions"
  - Click "+" to add new subscription
  - **Subscription 1: Task Changes**
    - Name: `TaskChanges`
    - Type: Query
    - Record Type: `CKTask`
    - Zone: `TasksZone`
    - Predicate: `TRUEPREDICATE` (all records)
    - Check: Fires on Creation, Update, Deletion
    - Notification Type: Silent (content-available)
  - **Subscription 2: Category Changes**
    - Name: `CategoryChanges`
    - Type: Query
    - Record Type: `CKCategory`
    - Zone: `TasksZone`
    - Predicate: `TRUEPREDICATE`
    - Silent notification
  - **Subscription 3: Tag Changes**
    - Name: `TagChanges`
    - Type: Query
    - Record Type: `CKTag`
    - Zone: `TasksZone`
    - Predicate: `TRUEPREDICATE`
    - Silent notification

- [ ] 3.7: Document CloudKit Schema
  - Create file: `Documentation/CLOUDKIT_SCHEMA.md`
  - Document all record types with field names and types
  - Include index information
  - Add sample queries
  - This helps Agent 2 & 3 understand the schema

**Acceptance Criteria:**
- ✅ All 3 record types created in CloudKit Dashboard
- ✅ All fields added with correct types and indexes
- ✅ Custom zone `TasksZone` created
- ✅ 3 subscriptions configured for push notifications
- ✅ Schema documented in markdown file

**Deliverable:** Commit `feat(cloudkit): design and configure CloudKit schema`

---

### TASK 4: Create Base App Files
**Priority:** HIGH - Agent 4 needs this
**Time:** 45 minutes
**Depends On:** Task 1 complete

#### Subtasks:
- [ ] 4.1: Create AppDelegate.swift
  - File: `App/AppDelegate.swift`
  - Purpose: Handle CloudKit notifications
  - Code structure:
  ```swift
  import UIKit
  import CloudKit

  class AppDelegate: NSObject, UIApplicationDelegate {
      func application(
          _ application: UIApplication,
          didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
      ) -> Bool {
          // Register for remote notifications
          application.registerForRemoteNotifications()
          return true
      }

      func application(
          _ application: UIApplication,
          didReceiveRemoteNotification userInfo: [AnyHashable: Any],
          fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
      ) {
          // TODO: Agent 3 will implement CloudKit sync trigger
          completionHandler(.noData)
      }
  }
  ```

- [ ] 4.2: Update ToDoAppyApp.swift
  - Add AppDelegate adapter
  - Set up for dark mode
  - Code:
  ```swift
  import SwiftUI

  @main
  struct ToDoAppyApp: App {
      @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

      var body: some Scene {
          WindowGroup {
              ContentView()
                  .preferredColorScheme(.dark) // Force dark mode
          }
      }
  }
  ```

- [ ] 4.3: Create placeholder ContentView.swift
  - File: `Views/ContentView.swift`
  - Temporary placeholder until Agent 4 builds real UI
  - Code:
  ```swift
  import SwiftUI

  struct ContentView: View {
      var body: some View {
          VStack {
              Image(systemName: "checkmark.circle.fill")
                  .font(.system(size: 100))
                  .foregroundStyle(.blue)
              Text("ToDo-Appy")
                  .font(.largeTitle)
                  .fontWeight(.bold)
              Text("Foundation Ready ✓")
                  .font(.subheadline)
                  .foregroundStyle(.secondary)
          }
          .padding()
      }
  }

  #Preview {
      ContentView()
  }
  ```

**Acceptance Criteria:**
- ✅ App launches with placeholder UI
- ✅ AppDelegate registered
- ✅ Dark mode forced
- ✅ No build errors

**Deliverable:** Commit `feat(app): create AppDelegate and base app structure`

---

### TASK 5: Create Protocol Files & Utilities
**Priority:** MEDIUM - Agent 2 needs this
**Time:** 30 minutes
**Depends On:** Task 1 complete

#### Subtasks:
- [ ] 5.1: Create Syncable protocol
  - File: `Models/Protocols/Syncable.swift`
  - Code:
  ```swift
  import Foundation
  import CloudKit

  protocol Syncable {
      var cloudKitRecordID: String? { get set }
      var lastSyncedAt: Date? { get set }
      var syncStatus: SyncStatus { get set }
      var isDeleted: Bool { get set }

      func toCKRecord() -> CKRecord
      static func fromCKRecord(_ record: CKRecord) -> Self?
  }
  ```

- [ ] 5.2: Create SyncStatus enum
  - File: `Models/Enums/SyncStatus.swift`
  - Code:
  ```swift
  import Foundation

  enum SyncStatus: String, Codable {
      case synced
      case pending
      case syncing
      case conflict
      case error
  }
  ```

- [ ] 5.3: Create Priority enum
  - File: `Models/Enums/Priority.swift`
  - Code:
  ```swift
  import Foundation
  import SwiftUI

  enum Priority: Int, Codable, CaseIterable {
      case none = 0
      case low = 1
      case medium = 2
      case high = 3
      case urgent = 4

      var displayName: String {
          switch self {
          case .none: return "None"
          case .low: return "Low"
          case .medium: return "Medium"
          case .high: return "High"
          case .urgent: return "Urgent"
          }
      }

      var color: Color {
          switch self {
          case .none: return .gray
          case .low: return .blue
          case .medium: return .yellow
          case .high: return .orange
          case .urgent: return .red
          }
      }

      var iconCount: Int {
          switch self {
          case .none: return 0
          case .low: return 1
          case .medium: return 2
          case .high: return 3
          case .urgent: return 4
          }
      }
  }
  ```

- [ ] 5.4: Create RecurrenceType enum
  - File: `Models/Enums/RecurrenceType.swift`
  - Code:
  ```swift
  import Foundation

  enum RecurrenceType: String, Codable, CaseIterable {
      case daily
      case weekly
      case monthly
      case yearly
      case custom

      var displayName: String {
          rawValue.capitalized
      }
  }
  ```

- [ ] 5.5: Create Extensions folder with Date utilities
  - File: `Utilities/Extensions/Date+Extensions.swift`
  - Add helper methods:
    - `isToday`
    - `isTomorrow`
    - `isOverdue`
    - `startOfDay`
    - `endOfDay`
  - Code:
  ```swift
  import Foundation

  extension Date {
      var isToday: Bool {
          Calendar.current.isDateInToday(self)
      }

      var isTomorrow: Bool {
          Calendar.current.isDateInTomorrow(self)
      }

      var isOverdue: Bool {
          self < Date() && !isToday
      }

      var startOfDay: Date {
          Calendar.current.startOfDay(for: self)
      }

      var endOfDay: Date {
          var components = DateComponents()
          components.day = 1
          components.second = -1
          return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
      }
  }
  ```

**Acceptance Criteria:**
- ✅ All protocol files created
- ✅ All enum files created
- ✅ Date extensions working
- ✅ No build errors
- ✅ Agent 2 can reference these in models

**Deliverable:** Commit `feat(protocols): add Syncable protocol and core enums`

---

### TASK 6: Create README for Agents
**Priority:** MEDIUM
**Time:** 20 minutes
**Depends On:** All tasks complete

#### Subtasks:
- [ ] 6.1: Create `AGENT_COORDINATION.md`
  - Document project structure
  - List what each agent is responsible for
  - Define interfaces between agents
  - List dependencies

- [ ] 6.2: Create build instructions
  - How to build and run
  - Required Xcode version (15.0+)
  - Required macOS version (14.0+)
  - How to sign into iCloud in simulator

- [ ] 6.3: Document CloudKit setup
  - How to access CloudKit dashboard
  - Where to find schema
  - How to reset development data

**Acceptance Criteria:**
- ✅ Clear documentation for other agents
- ✅ Build instructions work
- ✅ CloudKit access documented

**Deliverable:** Commit `docs: add agent coordination guide`

---

### TASK 7: Final Verification & Handoff
**Priority:** CRITICAL
**Time:** 15 minutes
**Depends On:** All previous tasks

#### Subtasks:
- [ ] 7.1: Verification checklist
  - [ ] Project builds on iOS without errors
  - [ ] Project builds on macOS without errors
  - [ ] Project runs on iOS Simulator
  - [ ] Project runs on Mac
  - [ ] Dark mode is enforced (test by toggling system appearance)
  - [ ] CloudKit container visible in dashboard
  - [ ] All 3 record types exist with correct fields
  - [ ] All folder structure in place
  - [ ] All protocols and enums created
  - [ ] Git repository clean (all changes committed)

- [ ] 7.2: Create handoff checklist
  - Document what's complete
  - Document what's NOT done (expected to be done by other agents)
  - List files created
  - List CloudKit resources created

- [ ] 7.3: Push to branch
  - Ensure all commits are clean and descriptive
  - Push to: `claude/free-todoist-alternative-01Reu5pLCB2jQtasTo9n8khh`
  - Verify push successful

- [ ] 7.4: Notify other agents
  - Foundation is ready
  - They can pull latest code
  - CloudKit schema is live

**Acceptance Criteria:**
- ✅ All verification items pass
- ✅ Code pushed to remote
- ✅ Ready for parallel development by Agents 2-5

**Deliverable:** Commit `chore: verify foundation and prepare for parallel development`

---

## 📦 Deliverables Summary

At completion, you will have created:

### Code Files:
- ✅ Xcode project configured for iOS, iPadOS, macOS
- ✅ `App/AppDelegate.swift`
- ✅ `App/ToDoAppyApp.swift` (updated)
- ✅ `Views/ContentView.swift` (placeholder)
- ✅ `Models/Protocols/Syncable.swift`
- ✅ `Models/Enums/SyncStatus.swift`
- ✅ `Models/Enums/Priority.swift`
- ✅ `Models/Enums/RecurrenceType.swift`
- ✅ `Utilities/Extensions/Date+Extensions.swift`
- ✅ Complete folder structure

### CloudKit Resources:
- ✅ Container: `iCloud.com.personal.todoappy`
- ✅ Record Type: `CKTask` (26 fields)
- ✅ Record Type: `CKCategory` (8 fields)
- ✅ Record Type: `CKTag` (6 fields)
- ✅ Custom Zone: `TasksZone`
- ✅ 3 Subscriptions for push notifications

### Documentation:
- ✅ `Documentation/CLOUDKIT_SCHEMA.md`
- ✅ `AGENT_COORDINATION.md`

### Configuration:
- ✅ Capabilities: iCloud, CloudKit, Push Notifications, Background Modes
- ✅ Entitlements: Properly configured for all targets
- ✅ Info.plist: Dark mode forced, notification permissions

---

## 🚨 Critical Notes

1. **You MUST complete this work FIRST** before other agents can proceed
2. **Do NOT implement** data models, UI, or services - that's for other agents
3. **Focus on foundation only** - structure, configuration, schema
4. **Test thoroughly** - other agents depend on this being rock-solid
5. **Document everything** - other agents need clear guidance

---

## 🎯 Success Criteria

- [ ] Project builds and runs on all platforms
- [ ] CloudKit schema 100% complete and correct
- [ ] All folder structure in place
- [ ] All base protocols and enums created
- [ ] Code pushed to branch
- [ ] Other agents can start work immediately

---

## 📞 Handoff to Other Agents

Once complete, signal to:
- **Agent 2:** Data models ready - you can start building Task, Category, Tag models
- **Agent 3:** CloudKit schema ready - you can start building DataSyncService
- **Agent 4:** Project structure ready - you can start building design system and UI
- **Agent 5:** Foundation ready - you can prepare for multi-platform layouts

**ESTIMATED COMPLETION TIME: 4-6 hours**

Good luck! 🚀
