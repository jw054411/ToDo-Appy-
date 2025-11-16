# Agent 2: Data Models & Business Logic Specialist

**Role:** Create all SwiftData models, implement recurring task engine, and build the core business logic layer.

**Start:** After Agent 1 completes foundation
**Depends On:** Agent 1 (project structure, protocols, enums)
**Blocks:** Agent 3 (needs models), Agent 4 (needs models)
**Estimated Time:** 8-10 hours

---

## 🎯 Mission
Build production-ready SwiftData models with full CloudKit sync support, implement a robust recurring task engine, and create all business logic that powers the app.

---

## ✅ TODO List

### TASK 1: Pull Latest Code & Verify Setup
**Priority:** CRITICAL - Do this first
**Time:** 10 minutes

#### Subtasks:
- [ ] 1.1: Pull latest from branch
  - `git pull origin claude/free-todoist-alternative-01Reu5pLCB2jQtasTo9n8khh`
  - Verify Agent 1's commits are present

- [ ] 1.2: Verify foundation
  - [ ] Project builds successfully
  - [ ] Folder structure exists: `Models/`, `Models/Protocols/`, `Models/Enums/`
  - [ ] `Syncable.swift` exists
  - [ ] `SyncStatus.swift` exists
  - [ ] `Priority.swift` exists
  - [ ] `RecurrenceType.swift` exists
  - [ ] CloudKit container configured in entitlements

- [ ] 1.3: Review CloudKit schema
  - Open `Documentation/CLOUDKIT_SCHEMA.md`
  - Understand CKTask record structure (26 fields)
  - Understand CKCategory record structure (8 fields)
  - Understand CKTag record structure (6 fields)

**Acceptance Criteria:**
- ✅ Code compiles
- ✅ All Agent 1 deliverables present
- ✅ Ready to build models

---

### TASK 2: Create Task Model (Core Data Model)
**Priority:** CRITICAL - Most important model
**Time:** 2 hours

#### Subtasks:
- [ ] 2.1: Create Task.swift file
  - Location: `Models/Task.swift`
  - Import: SwiftUI, SwiftData, CloudKit, Foundation

- [ ] 2.2: Add @Model attribute and class declaration
  ```swift
  import SwiftUI
  import SwiftData
  import CloudKit
  import Foundation

  @Model
  final class Task {
      // Properties will be added in next steps
  }
  ```

- [ ] 2.3: Add core properties
  ```swift
  // Core Properties
  var id: String
  var title: String
  var taskDescription: String
  var isCompleted: Bool
  var createdAt: Date
  var updatedAt: Date
  var dueDate: Date?
  var priority: Priority
  var sortOrder: Int
  ```

- [ ] 2.4: Add recurring task properties
  ```swift
  // Recurring Task Properties
  var isRecurring: Bool
  var recurrenceType: RecurrenceType?
  var recurrenceInterval: Int
  var recurrenceEndDate: Date?
  var recurrenceDaysOfWeek: [Int]  // 1=Sunday, 2=Monday, etc.
  var recurrenceDayOfMonth: Int?   // 1-31
  var recurrenceMonthOfYear: Int?  // 1-12
  var parentRecurringTaskID: String?  // If this is a generated instance
  ```

- [ ] 2.5: Add reminder properties
  ```swift
  // Reminder Properties
  var hasReminder: Bool
  var reminderTime: Date?
  var reminderOffset: Int  // Minutes before due date
  var notificationID: String?  // Local notification identifier
  ```

- [ ] 2.6: Add sync metadata (conform to Syncable)
  ```swift
  // Sync Metadata
  var cloudKitRecordID: String?
  var lastSyncedAt: Date?
  var syncStatus: SyncStatus
  var isDeleted: Bool
  ```

- [ ] 2.7: Add relationships
  ```swift
  // Relationships
  var category: Category?
  @Relationship(deleteRule: .nullify, inverse: \Tag.tasks) var tags: [Tag]
  var parentTask: Task?
  @Relationship(deleteRule: .cascade) var subtasks: [Task]
  ```

- [ ] 2.8: Add computed properties
  ```swift
  // Computed Properties
  var isOverdue: Bool {
      guard let dueDate = dueDate, !isCompleted else { return false }
      return dueDate < Date() && !dueDate.isToday
  }

  var isToday: Bool {
      guard let dueDate = dueDate else { return false }
      return dueDate.isToday
  }

  var isTomorrow: Bool {
      guard let dueDate = dueDate else { return false }
      return dueDate.isTomorrow
  }

  var isUpcoming: Bool {
      guard let dueDate = dueDate else { return false }
      let weekFromNow = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
      return dueDate > Date() && dueDate <= weekFromNow
  }

  var subtaskProgress: Double {
      guard !subtasks.isEmpty else { return 0 }
      let completed = subtasks.filter { $0.isCompleted }.count
      return Double(completed) / Double(subtasks.count)
  }

  var hasSubtasks: Bool {
      !subtasks.isEmpty
  }

  var isRecurringInstance: Bool {
      parentRecurringTaskID != nil
  }
  ```

- [ ] 2.9: Add initializer
  ```swift
  init(
      title: String,
      taskDescription: String = "",
      dueDate: Date? = nil,
      priority: Priority = .none,
      category: Category? = nil,
      isRecurring: Bool = false
  ) {
      self.id = UUID().uuidString
      self.title = title
      self.taskDescription = taskDescription
      self.isCompleted = false
      self.createdAt = Date()
      self.updatedAt = Date()
      self.dueDate = dueDate
      self.priority = priority
      self.sortOrder = 0

      self.isRecurring = isRecurring
      self.recurrenceType = nil
      self.recurrenceInterval = 1
      self.recurrenceEndDate = nil
      self.recurrenceDaysOfWeek = []
      self.recurrenceDayOfMonth = nil
      self.recurrenceMonthOfYear = nil
      self.parentRecurringTaskID = nil

      self.hasReminder = false
      self.reminderTime = nil
      self.reminderOffset = 0
      self.notificationID = nil

      self.cloudKitRecordID = nil
      self.lastSyncedAt = nil
      self.syncStatus = .pending
      self.isDeleted = false

      self.category = category
      self.tags = []
      self.parentTask = nil
      self.subtasks = []
  }
  ```

- [ ] 2.10: Add helper methods
  ```swift
  func markAsCompleted() {
      isCompleted = true
      updatedAt = Date()
      syncStatus = .pending
  }

  func markAsIncomplete() {
      isCompleted = false
      updatedAt = Date()
      syncStatus = .pending
  }

  func updateTitle(_ newTitle: String) {
      title = newTitle
      updatedAt = Date()
      syncStatus = .pending
  }

  func softDelete() {
      isDeleted = true
      updatedAt = Date()
      syncStatus = .pending
  }
  ```

**Acceptance Criteria:**
- ✅ Task model compiles without errors
- ✅ All 40+ properties included
- ✅ Conforms to Syncable protocol
- ✅ Relationships properly defined
- ✅ Computed properties work correctly
- ✅ Initializer sets proper defaults

**Deliverable:** Commit `feat(models): create Task model with full SwiftData support`

---

### TASK 3: Create Category Model
**Priority:** HIGH - Needed for task organization
**Time:** 45 minutes

#### Subtasks:
- [ ] 3.1: Create Category.swift file
  - Location: `Models/Category.swift`

- [ ] 3.2: Implement Category model
  ```swift
  import SwiftUI
  import SwiftData
  import CloudKit
  import Foundation

  @Model
  final class Category {
      // Core Properties
      var id: String
      var name: String
      var colorHex: String
      var icon: String
      var sortOrder: Int
      var createdAt: Date
      var updatedAt: Date

      // Sync Metadata
      var cloudKitRecordID: String?
      var lastSyncedAt: Date?
      var syncStatus: SyncStatus
      var isDeleted: Bool

      // Relationships
      @Relationship(deleteRule: .nullify, inverse: \Task.category) var tasks: [Task]

      // Computed Properties
      var color: Color {
          Color(hex: colorHex) ?? .blue
      }

      var activeTaskCount: Int {
          tasks.filter { !$0.isCompleted && !$0.isDeleted }.count
      }

      init(name: String, colorHex: String, icon: String) {
          self.id = UUID().uuidString
          self.name = name
          self.colorHex = colorHex
          self.icon = icon
          self.sortOrder = 0
          self.createdAt = Date()
          self.updatedAt = Date()

          self.cloudKitRecordID = nil
          self.lastSyncedAt = nil
          self.syncStatus = .pending
          self.isDeleted = false

          self.tasks = []
      }

      func softDelete() {
          isDeleted = true
          updatedAt = Date()
          syncStatus = .pending
      }
  }
  ```

- [ ] 3.3: Add Color hex initializer extension
  - File: `Utilities/Extensions/Color+Extensions.swift`
  ```swift
  import SwiftUI

  extension Color {
      init?(hex: String) {
          var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
          hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

          var rgb: UInt64 = 0
          guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

          let r = Double((rgb & 0xFF0000) >> 16) / 255.0
          let g = Double((rgb & 0x00FF00) >> 8) / 255.0
          let b = Double(rgb & 0x0000FF) / 255.0

          self.init(red: r, green: g, blue: b)
      }

      func toHex() -> String {
          let components = UIColor(self).cgColor.components
          let r = Float(components?[0] ?? 0)
          let g = Float(components?[1] ?? 0)
          let b = Float(components?[2] ?? 0)
          return String(format: "#%02lX%02lX%02lX",
                       lroundf(r * 255),
                       lroundf(g * 255),
                       lroundf(b * 255))
      }
  }
  ```

**Acceptance Criteria:**
- ✅ Category model compiles
- ✅ Color hex conversion works
- ✅ Relationship to Task works
- ✅ Conforms to Syncable

**Deliverable:** Commit `feat(models): create Category model with color support`

---

### TASK 4: Create Tag Model
**Priority:** HIGH
**Time:** 30 minutes

#### Subtasks:
- [ ] 4.1: Create Tag.swift file
  - Location: `Models/Tag.swift`

- [ ] 4.2: Implement Tag model
  ```swift
  import SwiftUI
  import SwiftData
  import CloudKit
  import Foundation

  @Model
  final class Tag {
      // Core Properties
      var id: String
      var name: String
      var colorHex: String
      var createdAt: Date
      var updatedAt: Date

      // Sync Metadata
      var cloudKitRecordID: String?
      var lastSyncedAt: Date?
      var syncStatus: SyncStatus
      var isDeleted: Bool

      // Relationships (many-to-many with Task)
      var tasks: [Task]

      // Computed Properties
      var color: Color {
          Color(hex: colorHex) ?? .purple
      }

      var taskCount: Int {
          tasks.filter { !$0.isDeleted }.count
      }

      init(name: String, colorHex: String) {
          self.id = UUID().uuidString
          self.name = name
          self.colorHex = colorHex
          self.createdAt = Date()
          self.updatedAt = Date()

          self.cloudKitRecordID = nil
          self.lastSyncedAt = nil
          self.syncStatus = .pending
          self.isDeleted = false

          self.tasks = []
      }

      func softDelete() {
          isDeleted = true
          updatedAt = Date()
          syncStatus = .pending
      }
  }
  ```

**Acceptance Criteria:**
- ✅ Tag model compiles
- ✅ Many-to-many relationship with Task works
- ✅ Conforms to Syncable

**Deliverable:** Commit `feat(models): create Tag model with many-to-many relationships`

---

### TASK 5: Implement CloudKit Conversion Methods
**Priority:** CRITICAL - Agent 3 needs this
**Time:** 2 hours

#### Subtasks:
- [ ] 5.1: Add toCKRecord() method to Task
  - Location: `Models/Task.swift` (add as extension)
  ```swift
  extension Task: Syncable {
      func toCKRecord() -> CKRecord {
          let recordID = CKRecord.ID(recordName: id)
          let record = CKRecord(recordType: "CKTask", recordID: recordID)

          // Core fields
          record["id"] = id as CKRecordValue
          record["title"] = title as CKRecordValue
          record["taskDescription"] = taskDescription as CKRecordValue
          record["isCompleted"] = (isCompleted ? 1 : 0) as CKRecordValue
          record["createdAt"] = createdAt as CKRecordValue
          record["updatedAt"] = updatedAt as CKRecordValue
          record["dueDate"] = dueDate as CKRecordValue?
          record["priority"] = priority.rawValue as CKRecordValue
          record["categoryID"] = category?.id as CKRecordValue?
          record["sortOrder"] = sortOrder as CKRecordValue
          record["isDeleted"] = (isDeleted ? 1 : 0) as CKRecordValue

          // Recurring fields
          record["isRecurring"] = (isRecurring ? 1 : 0) as CKRecordValue
          record["recurrenceType"] = recurrenceType?.rawValue as CKRecordValue?
          record["recurrenceInterval"] = recurrenceInterval as CKRecordValue
          record["recurrenceEndDate"] = recurrenceEndDate as CKRecordValue?
          record["recurrenceDaysOfWeek"] = recurrenceDaysOfWeek as CKRecordValue
          record["recurrenceDayOfMonth"] = recurrenceDayOfMonth as CKRecordValue?
          record["recurrenceMonthOfYear"] = recurrenceMonthOfYear as CKRecordValue?
          record["parentRecurringTaskID"] = parentRecurringTaskID as CKRecordValue?

          // Reminder fields
          record["hasReminder"] = (hasReminder ? 1 : 0) as CKRecordValue
          record["reminderTime"] = reminderTime as CKRecordValue?
          record["reminderOffset"] = reminderOffset as CKRecordValue

          // Relationships (store as arrays of IDs)
          record["tagIDs"] = tags.map { $0.id } as CKRecordValue
          record["subtaskIDs"] = subtasks.map { $0.id } as CKRecordValue
          record["parentTaskID"] = parentTask?.id as CKRecordValue?

          return record
      }
  }
  ```

- [ ] 5.2: Add fromCKRecord() method to Task
  ```swift
  static func fromCKRecord(_ record: CKRecord) -> Task? {
      guard let id = record["id"] as? String,
            let title = record["title"] as? String else {
          return nil
      }

      let task = Task(title: title)
      task.id = id
      task.taskDescription = record["taskDescription"] as? String ?? ""
      task.isCompleted = (record["isCompleted"] as? Int ?? 0) == 1
      task.createdAt = record["createdAt"] as? Date ?? Date()
      task.updatedAt = record["updatedAt"] as? Date ?? Date()
      task.dueDate = record["dueDate"] as? Date
      task.priority = Priority(rawValue: record["priority"] as? Int ?? 0) ?? .none
      task.sortOrder = record["sortOrder"] as? Int ?? 0
      task.isDeleted = (record["isDeleted"] as? Int ?? 0) == 1

      // Recurring fields
      task.isRecurring = (record["isRecurring"] as? Int ?? 0) == 1
      if let recurrenceTypeString = record["recurrenceType"] as? String {
          task.recurrenceType = RecurrenceType(rawValue: recurrenceTypeString)
      }
      task.recurrenceInterval = record["recurrenceInterval"] as? Int ?? 1
      task.recurrenceEndDate = record["recurrenceEndDate"] as? Date
      task.recurrenceDaysOfWeek = record["recurrenceDaysOfWeek"] as? [Int] ?? []
      task.recurrenceDayOfMonth = record["recurrenceDayOfMonth"] as? Int
      task.recurrenceMonthOfYear = record["recurrenceMonthOfYear"] as? Int
      task.parentRecurringTaskID = record["parentRecurringTaskID"] as? String

      // Reminder fields
      task.hasReminder = (record["hasReminder"] as? Int ?? 0) == 1
      task.reminderTime = record["reminderTime"] as? Date
      task.reminderOffset = record["reminderOffset"] as? Int ?? 0

      // Sync metadata
      task.cloudKitRecordID = record.recordID.recordName
      task.lastSyncedAt = Date()
      task.syncStatus = .synced

      // Note: Relationships (category, tags, subtasks) will be resolved by Agent 3's sync service

      return task
  }
  ```

- [ ] 5.3: Add CloudKit conversion to Category
  - Add similar toCKRecord() and fromCKRecord() methods
  - Map all 8 fields from CloudKit schema

- [ ] 5.4: Add CloudKit conversion to Tag
  - Add similar toCKRecord() and fromCKRecord() methods
  - Map all 6 fields from CloudKit schema

- [ ] 5.5: Test CloudKit conversions
  - Create test file: `Tests/ModelTests.swift`
  - Test Task → CKRecord → Task round-trip
  - Test Category → CKRecord → Category round-trip
  - Test Tag → CKRecord → Tag round-trip
  - Ensure no data loss

**Acceptance Criteria:**
- ✅ All models can convert to CKRecord
- ✅ All models can be created from CKRecord
- ✅ Round-trip conversion preserves all data
- ✅ Agent 3 can use these methods for sync

**Deliverable:** Commit `feat(models): implement CloudKit record conversion methods`

---

### TASK 6: Create RecurrenceRule Helper Struct
**Priority:** HIGH - Needed for recurring task engine
**Time:** 45 minutes

#### Subtasks:
- [ ] 6.1: Create RecurrenceRule.swift
  - Location: `Models/RecurrenceRule.swift`

- [ ] 6.2: Implement RecurrenceRule struct
  ```swift
  import Foundation

  struct RecurrenceRule: Codable, Equatable {
      var type: RecurrenceType
      var interval: Int  // Every N days/weeks/months/years
      var endDate: Date?
      var daysOfWeek: [Int]  // For weekly: 1=Sun, 2=Mon, etc.
      var dayOfMonth: Int?   // For monthly: 1-31
      var monthOfYear: Int?  // For yearly: 1-12

      // Convenience initializers
      static func daily(interval: Int = 1, endDate: Date? = nil) -> RecurrenceRule {
          RecurrenceRule(
              type: .daily,
              interval: interval,
              endDate: endDate,
              daysOfWeek: [],
              dayOfMonth: nil,
              monthOfYear: nil
          )
      }

      static func weekly(
          interval: Int = 1,
          daysOfWeek: [Int],
          endDate: Date? = nil
      ) -> RecurrenceRule {
          RecurrenceRule(
              type: .weekly,
              interval: interval,
              endDate: endDate,
              daysOfWeek: daysOfWeek,
              dayOfMonth: nil,
              monthOfYear: nil
          )
      }

      static func monthly(
          interval: Int = 1,
          dayOfMonth: Int,
          endDate: Date? = nil
      ) -> RecurrenceRule {
          RecurrenceRule(
              type: .monthly,
              interval: interval,
              endDate: endDate,
              daysOfWeek: [],
              dayOfMonth: dayOfMonth,
              monthOfYear: nil
          )
      }

      static func yearly(
          interval: Int = 1,
          monthOfYear: Int,
          dayOfMonth: Int,
          endDate: Date? = nil
      ) -> RecurrenceRule {
          RecurrenceRule(
              type: .yearly,
              interval: interval,
              endDate: endDate,
              daysOfWeek: [],
              dayOfMonth: dayOfMonth,
              monthOfYear: monthOfYear
          )
      }

      // Validation
      var isValid: Bool {
          switch type {
          case .daily:
              return interval > 0
          case .weekly:
              return interval > 0 && !daysOfWeek.isEmpty && daysOfWeek.allSatisfy { $0 >= 1 && $0 <= 7 }
          case .monthly:
              return interval > 0 && dayOfMonth != nil && (1...31).contains(dayOfMonth!)
          case .yearly:
              return interval > 0 && monthOfYear != nil && (1...12).contains(monthOfYear!) && dayOfMonth != nil && (1...31).contains(dayOfMonth!)
          case .custom:
              return true
          }
      }
  }
  ```

**Acceptance Criteria:**
- ✅ RecurrenceRule struct compiles
- ✅ Convenience initializers work
- ✅ Validation logic correct
- ✅ Ready for use in RecurrenceEngine

**Deliverable:** Commit `feat(models): create RecurrenceRule helper struct`

---

### TASK 7: Build RecurrenceEngine Service
**Priority:** CRITICAL - Core feature
**Time:** 3 hours

#### Subtasks:
- [ ] 7.1: Create RecurrenceEngine.swift
  - Location: `Services/RecurrenceEngine.swift`

- [ ] 7.2: Create actor structure
  ```swift
  import Foundation
  import SwiftData

  actor RecurrenceEngine {

      init() {}

      // Core methods will be added in next steps
  }
  ```

- [ ] 7.3: Implement nextOccurrence() method
  ```swift
  func nextOccurrence(from date: Date, rule: RecurrenceRule) -> Date? {
      guard rule.isValid else { return nil }

      let calendar = Calendar.current
      var nextDate: Date?

      switch rule.type {
      case .daily:
          nextDate = calendar.date(byAdding: .day, value: rule.interval, to: date)

      case .weekly:
          // Find next occurrence based on days of week
          nextDate = findNextWeeklyOccurrence(from: date, rule: rule)

      case .monthly:
          nextDate = findNextMonthlyOccurrence(from: date, rule: rule)

      case .yearly:
          nextDate = findNextYearlyOccurrence(from: date, rule: rule)

      case .custom:
          // Handle custom patterns (can be extended)
          nextDate = nil
      }

      // Check if next occurrence exceeds end date
      if let endDate = rule.endDate, let next = nextDate, next > endDate {
          return nil
      }

      return nextDate
  }
  ```

- [ ] 7.4: Implement findNextWeeklyOccurrence()
  ```swift
  private func findNextWeeklyOccurrence(from date: Date, rule: RecurrenceRule) -> Date? {
      let calendar = Calendar.current
      let currentWeekday = calendar.component(.weekday, from: date)

      // Sort days of week
      let sortedDays = rule.daysOfWeek.sorted()

      // Try to find next day in current week
      if let nextDay = sortedDays.first(where: { $0 > currentWeekday }) {
          let daysToAdd = nextDay - currentWeekday
          return calendar.date(byAdding: .day, value: daysToAdd, to: date)
      }

      // No more days this week, move to next week(s)
      let weeksToAdd = rule.interval
      let firstDayNextCycle = sortedDays.first!
      let daysToAdd = (7 * weeksToAdd) - currentWeekday + firstDayNextCycle
      return calendar.date(byAdding: .day, value: daysToAdd, to: date)
  }
  ```

- [ ] 7.5: Implement findNextMonthlyOccurrence()
  ```swift
  private func findNextMonthlyOccurrence(from date: Date, rule: RecurrenceRule) -> Date? {
      guard let targetDay = rule.dayOfMonth else { return nil }

      let calendar = Calendar.current
      var components = calendar.dateComponents([.year, .month, .day], from: date)

      // Move to next month(s)
      components.month! += rule.interval
      components.day = targetDay

      // Handle month-end edge cases (e.g., Feb 31 → Feb 28/29)
      var nextDate = calendar.date(from: components)
      if nextDate == nil || calendar.component(.day, from: nextDate!) != targetDay {
          // Target day doesn't exist in this month, use last day of month
          components.day = 1
          components.month! += 1
          if let firstOfNextMonth = calendar.date(from: components) {
              nextDate = calendar.date(byAdding: .day, value: -1, to: firstOfNextMonth)
          }
      }

      return nextDate
  }
  ```

- [ ] 7.6: Implement findNextYearlyOccurrence()
  ```swift
  private func findNextYearlyOccurrence(from date: Date, rule: RecurrenceRule) -> Date? {
      guard let targetMonth = rule.monthOfYear,
            let targetDay = rule.dayOfMonth else { return nil }

      let calendar = Calendar.current
      var components = calendar.dateComponents([.year], from: date)

      components.year! += rule.interval
      components.month = targetMonth
      components.day = targetDay

      return calendar.date(from: components)
  }
  ```

- [ ] 7.7: Implement completeRecurringTask()
  ```swift
  func completeRecurringTask(task: Task, modelContext: ModelContext) async -> Task? {
      guard task.isRecurring,
            let recurrenceType = task.recurrenceType else {
          return nil
      }

      // Create recurrence rule from task properties
      let rule = RecurrenceRule(
          type: recurrenceType,
          interval: task.recurrenceInterval,
          endDate: task.recurrenceEndDate,
          daysOfWeek: task.recurrenceDaysOfWeek,
          dayOfMonth: task.recurrenceDayOfMonth,
          monthOfYear: task.recurrenceMonthOfYear
      )

      // Calculate next occurrence
      guard let nextDueDate = nextOccurrence(from: task.dueDate ?? Date(), rule: rule) else {
          // No more occurrences (reached end date)
          return nil
      }

      // Create new instance
      let newTask = Task(
          title: task.title,
          taskDescription: task.taskDescription,
          dueDate: nextDueDate,
          priority: task.priority,
          category: task.category,
          isRecurring: true
      )

      // Copy recurrence settings
      newTask.recurrenceType = task.recurrenceType
      newTask.recurrenceInterval = task.recurrenceInterval
      newTask.recurrenceEndDate = task.recurrenceEndDate
      newTask.recurrenceDaysOfWeek = task.recurrenceDaysOfWeek
      newTask.recurrenceDayOfMonth = task.recurrenceDayOfMonth
      newTask.recurrenceMonthOfYear = task.recurrenceMonthOfYear
      newTask.parentRecurringTaskID = task.parentRecurringTaskID ?? task.id

      // Copy tags
      newTask.tags = task.tags

      // Copy reminder settings
      newTask.hasReminder = task.hasReminder
      newTask.reminderOffset = task.reminderOffset
      if task.hasReminder {
          newTask.reminderTime = calculateReminderTime(for: nextDueDate, offset: task.reminderOffset)
      }

      // Insert into context
      modelContext.insert(newTask)

      return newTask
  }
  ```

- [ ] 7.8: Add helper methods
  ```swift
  private func calculateReminderTime(for dueDate: Date, offset: Int) -> Date {
      Calendar.current.date(byAdding: .minute, value: -offset, to: dueDate) ?? dueDate
  }

  func generateOccurrences(
      rule: RecurrenceRule,
      from startDate: Date,
      to endDate: Date,
      maxCount: Int = 100
  ) -> [Date] {
      var occurrences: [Date] = []
      var currentDate = startDate

      while occurrences.count < maxCount {
          if let nextDate = nextOccurrence(from: currentDate, rule: rule) {
              if nextDate > endDate { break }
              occurrences.append(nextDate)
              currentDate = nextDate
          } else {
              break
          }
      }

      return occurrences
  }
  ```

**Acceptance Criteria:**
- ✅ RecurrenceEngine compiles
- ✅ nextOccurrence() works for all recurrence types
- ✅ completeRecurringTask() creates new instance
- ✅ Edge cases handled (month-end, leap years)
- ✅ Actor-based for thread safety

**Deliverable:** Commit `feat(services): implement RecurrenceEngine with full pattern support`

---

### TASK 8: Write Model Unit Tests
**Priority:** HIGH - Ensure reliability
**Time:** 2 hours

#### Subtasks:
- [ ] 8.1: Create ModelTests.swift
  - Location: `Tests/ModelTests.swift`

- [ ] 8.2: Test Task model
  ```swift
  import XCTest
  @testable import ToDo_Appy

  final class TaskModelTests: XCTestCase {
      func testTaskCreation() {
          let task = Task(title: "Test Task")
          XCTAssertEqual(task.title, "Test Task")
          XCTAssertFalse(task.isCompleted)
          XCTAssertEqual(task.priority, .none)
      }

      func testTaskCompletion() {
          let task = Task(title: "Test")
          task.markAsCompleted()
          XCTAssertTrue(task.isCompleted)
      }

      func testTaskIsOverdue() {
          let task = Task(title: "Test")
          task.dueDate = Calendar.current.date(byAdding: .day, value: -2, to: Date())
          XCTAssertTrue(task.isOverdue)
      }

      func testTaskIsToday() {
          let task = Task(title: "Test")
          task.dueDate = Date()
          XCTAssertTrue(task.isToday)
      }

      // Add more tests...
  }
  ```

- [ ] 8.3: Test RecurrenceEngine
  ```swift
  final class RecurrenceEngineTests: XCTestCase {
      var engine: RecurrenceEngine!

      override func setUp() async throws {
          engine = RecurrenceEngine()
      }

      func testDailyRecurrence() async {
          let rule = RecurrenceRule.daily(interval: 1)
          let today = Date()
          let next = await engine.nextOccurrence(from: today, rule: rule)

          XCTAssertNotNil(next)
          // Verify next is tomorrow
          let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
          XCTAssertEqual(
              Calendar.current.startOfDay(for: next!),
              Calendar.current.startOfDay(for: tomorrow)
          )
      }

      func testWeeklyRecurrence() async {
          // Test every Monday
          let rule = RecurrenceRule.weekly(interval: 1, daysOfWeek: [2]) // 2 = Monday
          let today = Date()
          let next = await engine.nextOccurrence(from: today, rule: rule)

          XCTAssertNotNil(next)
          let weekday = Calendar.current.component(.weekday, from: next!)
          XCTAssertEqual(weekday, 2) // Should be Monday
      }

      func testMonthlyRecurrence() async {
          let rule = RecurrenceRule.monthly(interval: 1, dayOfMonth: 15)
          let today = Date()
          let next = await engine.nextOccurrence(from: today, rule: rule)

          XCTAssertNotNil(next)
          let day = Calendar.current.component(.day, from: next!)
          XCTAssertEqual(day, 15)
      }

      // Add more tests for edge cases...
  }
  ```

- [ ] 8.4: Test CloudKit conversions
  ```swift
  final class CloudKitConversionTests: XCTestCase {
      func testTaskToCKRecordConversion() {
          let task = Task(title: "Test Task", priority: .high)
          task.dueDate = Date()

          let record = task.toCKRecord()

          XCTAssertEqual(record["title"] as? String, "Test Task")
          XCTAssertEqual(record["priority"] as? Int, Priority.high.rawValue)
          XCTAssertNotNil(record["dueDate"])
      }

      func testTaskFromCKRecordConversion() {
          let recordID = CKRecord.ID(recordName: "test-id")
          let record = CKRecord(recordType: "CKTask", recordID: recordID)
          record["id"] = "test-id"
          record["title"] = "Test Task"
          record["priority"] = 3

          let task = Task.fromCKRecord(record)

          XCTAssertNotNil(task)
          XCTAssertEqual(task?.title, "Test Task")
          XCTAssertEqual(task?.priority, .high)
      }

      // Add round-trip test...
  }
  ```

- [ ] 8.5: Run all tests
  - ⌘U in Xcode
  - Verify all tests pass
  - Fix any failing tests

**Acceptance Criteria:**
- ✅ 20+ unit tests written
- ✅ All tests pass
- ✅ Models proven reliable
- ✅ Edge cases covered

**Deliverable:** Commit `test(models): add comprehensive unit tests for models and RecurrenceEngine`

---

### TASK 9: Create Default Data Seeder
**Priority:** MEDIUM - Helpful for development
**Time:** 30 minutes

#### Subtasks:
- [ ] 9.1: Create DataSeeder.swift
  - Location: `Services/DataSeeder.swift`

- [ ] 9.2: Implement default categories
  ```swift
  import SwiftData
  import Foundation

  actor DataSeeder {
      func seedDefaultCategories(modelContext: ModelContext) async {
          // Check if categories already exist
          let descriptor = FetchDescriptor<Category>()
          let existingCategories = try? modelContext.fetch(descriptor)

          guard existingCategories?.isEmpty ?? true else { return }

          // Create default categories
          let inbox = Category(name: "Inbox", colorHex: "#0A84FF", icon: "tray.fill")
          let personal = Category(name: "Personal", colorHex: "#BF5AF2", icon: "person.fill")
          let work = Category(name: "Work", colorHex: "#FF9F0A", icon: "briefcase.fill")
          let shopping = Category(name: "Shopping", colorHex: "#32D74B", icon: "cart.fill")
          let health = Category(name: "Health", colorHex: "#FF453A", icon: "heart.fill")

          modelContext.insert(inbox)
          modelContext.insert(personal)
          modelContext.insert(work)
          modelContext.insert(shopping)
          modelContext.insert(health)

          try? modelContext.save()
      }

      #if DEBUG
      func seedSampleTasks(modelContext: ModelContext) async {
          // Only for development/preview
          let descriptor = FetchDescriptor<Task>()
          let existingTasks = try? modelContext.fetch(descriptor)

          guard existingTasks?.isEmpty ?? true else { return }

          // Get inbox category
          let categoryDescriptor = FetchDescriptor<Category>(
              predicate: #Predicate { $0.name == "Inbox" }
          )
          let inbox = try? modelContext.fetch(categoryDescriptor).first

          // Create sample tasks
          let task1 = Task(title: "Complete project proposal", dueDate: Date(), priority: .high, category: inbox)
          let task2 = Task(title: "Buy groceries", dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()), priority: .medium, category: inbox)
          let task3 = Task(title: "Call dentist", priority: .low, category: inbox)

          modelContext.insert(task1)
          modelContext.insert(task2)
          modelContext.insert(task3)

          try? modelContext.save()
      }
      #endif
  }
  ```

**Acceptance Criteria:**
- ✅ Default categories created on first launch
- ✅ Sample data available for development
- ✅ Doesn't duplicate data

**Deliverable:** Commit `feat(services): add DataSeeder for default categories`

---

### TASK 10: Final Verification & Handoff
**Priority:** CRITICAL
**Time:** 20 minutes

#### Subtasks:
- [ ] 10.1: Verification checklist
  - [ ] All models compile without errors
  - [ ] Task model has 40+ properties
  - [ ] Category model complete
  - [ ] Tag model complete
  - [ ] CloudKit conversion methods work
  - [ ] RecurrenceEngine fully implemented
  - [ ] All unit tests pass (20+ tests)
  - [ ] DataSeeder works
  - [ ] Code is clean and well-commented

- [ ] 10.2: Build and test
  - [ ] Clean build (⌘⇧K)
  - [ ] Build succeeds (⌘B)
  - [ ] Run tests (⌘U) - all pass
  - [ ] No compiler warnings

- [ ] 10.3: Commit and push
  - Review all changes
  - Ensure commits are descriptive
  - Push to branch

- [ ] 10.4: Document handoff
  - Update `AGENT_COORDINATION.md`
  - Mark Agent 2 tasks complete
  - Signal Agent 3 & 4 can proceed

**Acceptance Criteria:**
- ✅ All models production-ready
- ✅ RecurrenceEngine fully functional
- ✅ Tests prove reliability
- ✅ Code pushed to remote
- ✅ Agent 3 can build sync service
- ✅ Agent 4 can build UI with these models

**Deliverable:** Commit `chore: verify data models and prepare for Agent 3 & 4`

---

## 📦 Deliverables Summary

At completion, you will have created:

### Models:
- ✅ `Task.swift` - Full model with 40+ properties
- ✅ `Category.swift` - Project/category model
- ✅ `Tag.swift` - Tag model with many-to-many
- ✅ `RecurrenceRule.swift` - Helper struct

### Services:
- ✅ `RecurrenceEngine.swift` - Recurring task logic
- ✅ `DataSeeder.swift` - Default data creation

### Extensions:
- ✅ `Color+Extensions.swift` - Hex color support

### Tests:
- ✅ `ModelTests.swift` - 20+ unit tests
- ✅ All tests passing

### Features Implemented:
- ✅ Complete SwiftData models
- ✅ CloudKit sync support (toCKRecord/fromCKRecord)
- ✅ Recurring tasks (daily, weekly, monthly, yearly)
- ✅ Subtask support
- ✅ Tag relationships
- ✅ Priority system
- ✅ Reminders metadata
- ✅ Soft delete support

---

## 🚨 Critical Notes

1. **Wait for Agent 1** to complete foundation before starting
2. **Do NOT build UI** - that's Agent 4's job
3. **Do NOT implement sync service** - that's Agent 3's job
4. **Focus on models and business logic only**
5. **Test thoroughly** - Agent 3 & 4 depend on this

---

## 🎯 Success Criteria

- [ ] All models compile and work
- [ ] CloudKit conversion methods functional
- [ ] RecurrenceEngine handles all patterns
- [ ] 20+ unit tests passing
- [ ] Code pushed to branch
- [ ] Agent 3 can start building DataSyncService
- [ ] Agent 4 can start building UI with these models

---

## 📞 Handoff to Other Agents

Once complete, signal to:
- **Agent 3:** Models ready - you can build DataSyncService using toCKRecord/fromCKRecord
- **Agent 4:** Models ready - you can build UI and ViewModels using Task/Category/Tag
- **Agent 5:** Business logic ready - you can reference RecurrenceEngine for advanced features

**ESTIMATED COMPLETION TIME: 8-10 hours**

Good luck! 🚀
