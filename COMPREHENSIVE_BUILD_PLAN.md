# ToDo-Appy: Comprehensive Build Plan
## Dark Mode Only • Slick GUI • Full-Featured Task Management

---

## 🎯 Project Vision

Build a **private, free, native Apple ecosystem task manager** that rivals Todoist with:
- **Dark mode only** - sleek, modern, battery-efficient interface
- **Slick animations** - smooth, delightful interactions
- **Smart reminders** - flexible notification system
- **Clean organization** - projects, tags, priorities, due dates
- **Recurring tasks** - daily, weekly, monthly, yearly patterns
- **Cross-platform** - seamless experience on iPhone, iPad, Mac
- **Privacy-first** - all data in your private iCloud, zero third-party servers

---

## 📋 50-Step Implementation Plan

### **PHASE 1: Foundation Setup** (Steps 1-3)

#### Step 1: Xcode Project Initialization
**Duration:** 30 minutes

**Actions:**
1. Create new Xcode project
   - Template: Multiplatform App
   - Name: ToDo-Appy
   - Organization ID: `com.personal.todoappy`
   - Language: Swift
   - Interface: SwiftUI
   - Storage: SwiftData
2. Set deployment targets:
   - iOS 17.0+
   - iPadOS 17.0+
   - macOS 14.0+
3. Create folder structure:
   ```
   ToDo-Appy/
   ├── App/
   │   ├── ToDoAppyApp.swift
   │   └── AppDelegate.swift
   ├── Models/
   ├── ViewModels/
   ├── Views/
   │   ├── iPhone/
   │   ├── iPad/
   │   └── Mac/
   ├── Services/
   ├── DesignSystem/
   ├── Utilities/
   └── Resources/
   ```

**Deliverables:**
- ✅ Clean Xcode project structure
- ✅ Build succeeds on all platforms

---

#### Step 2: Capabilities & Entitlements Configuration
**Duration:** 20 minutes

**Actions:**
1. Enable capabilities in Xcode:
   - ☑️ iCloud → CloudKit
   - ☑️ Push Notifications
   - ☑️ Background Modes → Remote notifications
   - ☑️ Background Modes → Background fetch
2. Create iCloud container: `iCloud.com.personal.todoappy`
3. Configure entitlements file:
   - Add CloudKit container identifier
   - Set default container
4. Configure Info.plist:
   - Add notification usage descriptions
   - Set appearance to dark mode only: `UIUserInterfaceStyle = Dark`

**Deliverables:**
- ✅ CloudKit container created in Developer Portal
- ✅ All capabilities enabled
- ✅ App forced to dark mode only

---

#### Step 3: CloudKit Schema Design
**Duration:** 1 hour

**Actions:**
1. Open CloudKit Dashboard
2. Select `iCloud.com.personal.todoappy` container
3. Switch to Development environment
4. Create Record Types:

**CKTask Record Type:**
```
id: String (Indexed, Queryable)
title: String (Indexed, Queryable, Sortable)
taskDescription: String
isCompleted: Int64 (0 or 1, Indexed)
createdAt: Date/Time (Indexed, Sortable)
updatedAt: Date/Time (Indexed, Sortable)
dueDate: Date/Time (Indexed, Sortable)
priority: Int64 (0-3, Indexed)
categoryID: String (Indexed, Queryable)
sortOrder: Int64 (Sortable)
isDeleted: Int64 (0 or 1, Indexed)

--- Recurring Task Fields ---
isRecurring: Int64 (0 or 1, Indexed)
recurrenceType: String (daily/weekly/monthly/yearly)
recurrenceInterval: Int64 (every X days/weeks/months)
recurrenceEndDate: Date/Time
recurrenceDaysOfWeek: List<Int64> (for weekly: 1=Sun, 2=Mon, etc.)
recurrenceDayOfMonth: Int64 (for monthly: 1-31)
recurrenceMonthOfYear: Int64 (for yearly: 1-12)
parentRecurringTaskID: String (for generated instances)

--- Reminder Fields ---
hasReminder: Int64 (0 or 1, Indexed)
reminderTime: Date/Time
reminderOffset: Int64 (minutes before due date)

--- Relationships ---
tagIDs: List<String>
subtaskIDs: List<String>
parentTaskID: String
```

**CKCategory Record Type:**
```
id: String (Indexed, Queryable)
name: String (Indexed, Queryable, Sortable)
colorHex: String
icon: String
sortOrder: Int64 (Sortable)
createdAt: Date/Time
updatedAt: Date/Time
isDeleted: Int64 (0 or 1, Indexed)
```

**CKTag Record Type:**
```
id: String (Indexed, Queryable)
name: String (Indexed, Queryable, Sortable)
colorHex: String
createdAt: Date/Time
updatedAt: Date/Time
isDeleted: Int64 (0 or 1, Indexed)
```

5. Create Custom Zone: `TasksZone`
6. Create Subscription: `TaskChanges` → Query subscription for all record types

**Deliverables:**
- ✅ CloudKit schema fully configured
- ✅ Indexes created for performance
- ✅ Push notification subscriptions active

---

### **PHASE 2: Data Layer** (Steps 4-8)

#### Step 4: Core Data Models
**Duration:** 2 hours

**Actions:**
1. Create `Models/Task.swift`:
   - All properties from CloudKit schema
   - SwiftData @Model attribute
   - Relationships to Category, Tags, Subtasks
   - Computed properties: `isOverdue`, `isToday`, `isUpcoming`
   - Validation logic in `init()`

2. Create `Models/Category.swift`:
   - All properties from CloudKit schema
   - One-to-many relationship with Tasks
   - Default categories: Personal, Work, Shopping, Health

3. Create `Models/Tag.swift`:
   - All properties from CloudKit schema
   - Many-to-many relationship with Tasks

4. Create `Models/RecurrenceRule.swift`:
   - Enum: `RecurrenceType` (daily, weekly, monthly, yearly, custom)
   - Enum: `DayOfWeek` (sunday...saturday)
   - Struct containing all recurrence parameters
   - Method: `nextOccurrence(after: Date) -> Date?`
   - Method: `generateInstances(from: Date, to: Date) -> [Date]`

**Deliverables:**
- ✅ All SwiftData models created
- ✅ Relationships properly configured
- ✅ Models compile without errors

---

#### Step 5: Sync Metadata Layer
**Duration:** 1 hour

**Actions:**
1. Add protocol `Syncable` to `Models/Protocols/Syncable.swift`:
   ```swift
   protocol Syncable {
       var cloudKitRecordID: String? { get set }
       var lastSyncedAt: Date? { get set }
       var syncStatus: SyncStatus { get set }
       var isDeleted: Bool { get set }
   }
   ```

2. Create enum `SyncStatus`:
   - synced, pending, syncing, conflict, error

3. Make all models conform to `Syncable`

4. Create extension methods:
   - `toCKRecord() -> CKRecord`
   - `static func fromCKRecord(_ record: CKRecord) -> Self?`

**Deliverables:**
- ✅ Sync metadata on all models
- ✅ CloudKit conversion methods ready

---

#### Step 6: SwiftData Container Setup
**Duration:** 1 hour

**Actions:**
1. Create `Services/DataManager.swift`:
   - Singleton actor
   - ModelContainer initialization
   - ModelContext management
   - Save/fetch/delete helper methods

2. Update `ToDoAppyApp.swift`:
   - Initialize ModelContainer
   - Pass container to environment

3. Create `Services/DataSeeder.swift`:
   - Method to create default categories
   - Method to create sample tasks (for development only)

**Deliverables:**
- ✅ SwiftData fully initialized
- ✅ App can create/read/update/delete local data

---

#### Step 7: Recurring Task Engine
**Duration:** 3 hours

**Actions:**
1. Create `Services/RecurrenceEngine.swift`:
   - Actor for thread safety

**Core Methods:**
```swift
// Calculate next occurrence based on recurrence rule
func nextOccurrence(
    from date: Date,
    rule: RecurrenceRule
) -> Date?

// Generate all occurrences between dates
func generateOccurrences(
    rule: RecurrenceRule,
    from: Date,
    to: Date
) -> [Date]

// Create next instance when current is completed
func completeRecurringTask(
    task: Task,
    completedAt: Date
) async -> Task?

// Handle edge cases
func adjustForMonthEnd(date: Date, targetDay: Int) -> Date
func skipWeekends(date: Date) -> Date

// Cleanup old completed instances
func pruneOldInstances(
    parentTaskID: String,
    keepDays: Int = 30
) async
```

2. Implement recurrence patterns:
   - **Daily:** Every N days
   - **Weekly:** Every N weeks on specific days (Mon, Wed, Fri)
   - **Monthly:** Every N months on day X OR last day
   - **Yearly:** Every N years on month X, day Y
   - **Custom:** Advanced patterns (every weekday, every other Friday, etc.)

3. Edge case handling:
   - Month-end dates (Feb 31 → Feb 28/29)
   - Timezone considerations
   - DST transitions
   - Skip weekends option
   - End date enforcement

**Deliverables:**
- ✅ Fully tested recurrence calculation
- ✅ Edge cases handled
- ✅ New task instances generated on completion

---

#### Step 8: Reminder/Notification Service
**Duration:** 2 hours

**Actions:**
1. Create `Services/NotificationService.swift`:
   - Actor for thread safety
   - Request notification permissions
   - Schedule/cancel notifications

**Core Methods:**
```swift
// Request user permission
func requestAuthorization() async -> Bool

// Schedule reminder for task
func scheduleReminder(
    for task: Task,
    at: Date
) async -> String?  // Returns notification ID

// Schedule reminder with offset (15min before due)
func scheduleReminder(
    for task: Task,
    minutesBefore: Int
) async -> String?

// Cancel reminder
func cancelReminder(notificationID: String) async

// Cancel all reminders for task
func cancelReminders(for task: Task) async

// Reschedule all pending reminders
func rescheduleAll() async

// Handle notification tap (open task)
func handleNotificationTap(taskID: String)

// Generate next recurring reminder when task completed
func handleRecurringTaskCompletion(task: Task) async
```

2. Notification content:
   - Title: Task title
   - Body: Due date/time or "Now due"
   - Sound: Default or custom
   - Badge: Update app icon badge count
   - Category: Actions (Complete, Snooze, View)

3. Notification actions:
   - Complete Task → Mark as done from notification
   - Snooze → Reschedule reminder (+15min, +1hr, +1day)
   - View → Open app to task detail

**Deliverables:**
- ✅ Notification service fully functional
- ✅ Reminders schedule/cancel correctly
- ✅ Recurring tasks get new reminders

---

### **PHASE 3: Design System** (Steps 9-12)

#### Step 9: Dark Mode Color Palette
**Duration:** 1.5 hours

**Actions:**
1. Create `DesignSystem/Colors.swift`:

**Color System:**
```swift
// Background Colors
static let background = Color(hex: "#000000")          // Pure black
static let backgroundSecondary = Color(hex: "#1C1C1E") // Dark gray
static let backgroundTertiary = Color(hex: "#2C2C2E")  // Medium gray
static let backgroundElevated = Color(hex: "#3A3A3C")  // Elevated surfaces

// Text Colors
static let textPrimary = Color(hex: "#FFFFFF")         // White
static let textSecondary = Color(hex: "#EBEBF5").opacity(0.6)
static let textTertiary = Color(hex: "#EBEBF5").opacity(0.3)

// Accent Colors (customizable)
static let accentBlue = Color(hex: "#0A84FF")          // iOS blue
static let accentPurple = Color(hex: "#BF5AF2")        // Vibrant purple
static let accentPink = Color(hex: "#FF375F")          // Hot pink
static let accentOrange = Color(hex: "#FF9F0A")        // Orange
static let accentGreen = Color(hex: "#32D74B")         // Success green
static let accentYellow = Color(hex: "#FFD60A")        // Warning yellow
static let accentRed = Color(hex: "#FF453A")           // Destructive red

// Priority Colors
static let priorityUrgent = accentRed
static let priorityHigh = accentOrange
static let priorityMedium = accentYellow
static let priorityLow = accentBlue

// Semantic Colors
static let success = accentGreen
static let warning = accentYellow
static let destructive = accentRed
static let link = accentBlue

// UI Element Colors
static let separator = Color(hex: "#38383A")
static let overlay = Color.black.opacity(0.4)
static let cardBackground = backgroundSecondary
static let inputBackground = backgroundTertiary
```

2. Create `DesignSystem/ColorExtensions.swift`:
   - Hex initializer for Color
   - Gradient presets for UI elements
   - Color utility methods

**Deliverables:**
- ✅ Complete dark mode color system
- ✅ Consistent colors across app
- ✅ Beautiful, high-contrast palette

---

#### Step 10: Typography System
**Duration:** 1 hour

**Actions:**
1. Create `DesignSystem/Typography.swift`:

**Font System:**
```swift
// Headings
static let largeTitle = Font.system(size: 34, weight: .bold)
static let title1 = Font.system(size: 28, weight: .bold)
static let title2 = Font.system(size: 22, weight: .bold)
static let title3 = Font.system(size: 20, weight: .semibold)

// Body Text
static let body = Font.system(size: 17, weight: .regular)
static let bodyEmphasized = Font.system(size: 17, weight: .semibold)
static let callout = Font.system(size: 16, weight: .regular)

// Small Text
static let subheadline = Font.system(size: 15, weight: .regular)
static let footnote = Font.system(size: 13, weight: .regular)
static let caption1 = Font.system(size: 12, weight: .regular)
static let caption2 = Font.system(size: 11, weight: .regular)

// Monospaced (for dates, numbers)
static let monoBody = Font.system(size: 17, weight: .regular, design: .monospaced)
static let monoCaption = Font.system(size: 12, weight: .regular, design: .monospaced)
```

**Text Styles:**
- Task title: `title3`, `textPrimary`
- Task description: `body`, `textSecondary`
- Due date: `caption1`, `monoCaption`, color based on proximity
- Category label: `caption2`, `textTertiary`
- Section headers: `title2`, `textPrimary`

**Deliverables:**
- ✅ Consistent typography system
- ✅ Readable, accessible fonts
- ✅ SF Pro properly configured

---

#### Step 11: Spacing & Layout System
**Duration:** 45 minutes

**Actions:**
1. Create `DesignSystem/Spacing.swift`:

**Spacing Scale:**
```swift
static let xxxs: CGFloat = 2
static let xxs: CGFloat = 4
static let xs: CGFloat = 8
static let sm: CGFloat = 12
static let md: CGFloat = 16
static let lg: CGFloat = 24
static let xl: CGFloat = 32
static let xxl: CGFloat = 48
static let xxxl: CGFloat = 64

// Semantic Spacing
static let cardPadding = md
static let sectionSpacing = lg
static let itemSpacing = sm
static let edgeInsets = md
```

2. Create `DesignSystem/Layout.swift`:
   - Screen breakpoints for iPad/Mac
   - Common layout constants
   - Corner radius values
   - Shadow definitions

**Deliverables:**
- ✅ Consistent spacing throughout app
- ✅ Clean, organized layouts

---

#### Step 12: Reusable Components
**Duration:** 3 hours

**Actions:**
Create components in `DesignSystem/Components/`:

1. **AppButton.swift** - Primary/secondary/destructive button styles
2. **AppTextField.swift** - Styled text input with dark mode
3. **AppCard.swift** - Elevated card container
4. **PriorityPicker.swift** - Color-coded priority selector
5. **DateTimePicker.swift** - Custom date/time picker UI
6. **TagPill.swift** - Rounded tag bubble with color
7. **LoadingSpinner.swift** - Animated activity indicator
8. **EmptyState.swift** - Empty list placeholder with icon/message
9. **SwipeActionsView.swift** - Custom swipe gesture handler
10. **FloatingActionButton.swift** - Circular FAB for adding tasks

**Each component includes:**
- Dark mode colors
- Smooth animations
- Haptic feedback
- Accessibility labels
- Preview examples

**Deliverables:**
- ✅ 10+ reusable UI components
- ✅ Consistent design language
- ✅ Slick, polished appearance

---

### **PHASE 4: Core UI - iPhone** (Steps 13-18)

#### Step 13: Tab Bar Navigation
**Duration:** 1 hour

**Actions:**
1. Create `Views/iPhone/MainTabView.swift`:

**Tabs:**
- **Inbox** (All tasks) - SF Symbol: `tray.fill`
- **Today** (Due today) - SF Symbol: `calendar.badge.clock`
- **Upcoming** (Next 7 days) - SF Symbol: `calendar`
- **Projects** (Categories) - SF Symbol: `folder.fill`
- **Tags** - SF Symbol: `tag.fill`

**Features:**
- Custom tab bar with dark background
- Badge counts for Today (overdue count in red)
- Haptic feedback on tab switch
- Smooth transition animations

**Deliverables:**
- ✅ Working tab navigation
- ✅ All tabs accessible

---

#### Step 14: Task List View (Core Screen)
**Duration:** 4 hours

**Actions:**
1. Create `Views/iPhone/TaskListView.swift`:

**Features:**
- List of tasks with sections (Overdue, Today, Upcoming, Completed)
- Pull-to-refresh for manual sync
- Search bar at top
- Filter button (priority, category, tags)
- Sort options (due date, priority, creation date, alphabetical)
- Empty state when no tasks
- Floating + button to add task
- Swipe actions on each row
- Smooth scroll performance with LazyVStack

**Layout:**
```
┌─────────────────────────┐
│  [Search Bar]      [⚙︎]  │
├─────────────────────────┤
│                         │
│  OVERDUE (2)            │
│  ○ Task 1      [!][📁]  │
│  ○ Task 2      [!][📁]  │
│                         │
│  TODAY (5)              │
│  ○ Task 3      [📁]     │
│  ✓ Task 4      [📁]     │
│                         │
│  UPCOMING (12)          │
│  ○ Task 5      [📁]     │
│                         │
│           [+]           │
└─────────────────────────┘
```

2. Create `ViewModels/TaskListViewModel.swift`:
   - Load tasks from SwiftData
   - Group by section
   - Handle search/filter/sort
   - Toggle completion
   - Delete tasks
   - Batch operations

**Deliverables:**
- ✅ Beautiful task list
- ✅ Search/filter/sort working
- ✅ Smooth scrolling

---

#### Step 15: Task Row Component
**Duration:** 2 hours

**Actions:**
1. Create `Views/Components/TaskRowView.swift`:

**Visual Design:**
```
┌─────────────────────────────────────────┐
│ [○] Task Title                [!] [📁]  │
│     Due: Today 3:00 PM        [🔁] [🔔] │
│     Project: Work • Design              │
└─────────────────────────────────────────┘
```

**Elements:**
- Checkbox (circle → checkmark animation)
- Task title (strikethrough when completed)
- Due date badge (color-coded: red=overdue, orange=today, blue=upcoming)
- Priority indicator (!, !!, !!!)
- Category/project name with color dot
- Tags as small pills
- Recurring indicator icon
- Reminder bell icon
- Tap to open detail
- Long press for context menu

**Swipe Actions:**
- **Right swipe:** Complete (green background)
- **Left swipe:**
  - Schedule (blue)
  - Edit (yellow)
  - Delete (red)

**Animations:**
- Checkbox animation: scale + rotation
- Completion: fade + strikethrough
- Swipe: smooth reveal with haptic
- Delete: slide out with bounce

**Deliverables:**
- ✅ Polished task row
- ✅ Smooth animations
- ✅ Swipe gestures working

---

#### Step 16: Task Editor/Detail View
**Duration:** 4 hours

**Actions:**
1. Create `Views/iPhone/TaskEditorView.swift`:

**Form Fields:**
```
┌─────────────────────────────────────┐
│  ✕                           [Save] │
├─────────────────────────────────────┤
│                                     │
│  [Checkbox] Task Title Input        │
│  ───────────────────────────────    │
│                                     │
│  📝 Description                     │
│  Multi-line text field...           │
│                                     │
│  📁 Project                         │
│  Work ▾                             │
│                                     │
│  📅 Due Date                        │
│  Today, 3:00 PM ▾                   │
│                                     │
│  [!] Priority                       │
│  ● Low  ● Medium  ● High  ● Urgent  │
│                                     │
│  🔁 Repeat                          │
│  Daily ▾                            │
│  Ends: Never ▾                      │
│                                     │
│  🔔 Remind Me                       │
│  ☑︎ 15 minutes before               │
│  ☑︎ At due time                     │
│  ☐ Custom...                        │
│                                     │
│  🏷 Tags                             │
│  [urgent] [client] [+]              │
│                                     │
│  📎 Subtasks (3)                    │
│  ○ Subtask 1                        │
│  ○ Subtask 2                        │
│  ✓ Subtask 3                        │
│  + Add subtask                      │
│                                     │
│  ──────────────────────────────     │
│                                     │
│  Created: Jan 15, 2025              │
│  Modified: Jan 16, 2025             │
│                                     │
│  [Delete Task]                      │
│                                     │
└─────────────────────────────────────┘
```

**Features:**
- Auto-save on field changes
- Keyboard shortcuts (⌘S to save)
- Input validation (title required)
- Date picker with natural language ("tomorrow", "next Monday")
- Recurring task picker with custom options
- Multiple reminder options
- Tag multi-select with create-new
- Inline subtask management
- Delete with confirmation alert
- Haptic feedback on saves

2. Create `ViewModels/TaskEditorViewModel.swift`:
   - Manage form state
   - Validate inputs
   - Save to SwiftData
   - Trigger sync
   - Schedule notifications

**Deliverables:**
- ✅ Full-featured task editor
- ✅ All fields working
- ✅ Beautiful, intuitive UI

---

#### Step 17: Recurring Task Picker
**Duration:** 2 hours

**Actions:**
1. Create `Views/Components/RecurrencePicker.swift`:

**Options:**
```
Never (default)
Daily
  └─ Every [1] day(s)
Weekly
  └─ Every [1] week(s) on:
     ☑︎ Mon ☐ Tue ☐ Wed ☑︎ Thu ☐ Fri ☐ Sat ☐ Sun
Monthly
  └─ Every [1] month(s) on:
     ● Day [15]
     ○ Last day of month
Yearly
  └─ Every [1] year(s) on:
     [January ▾] [15]
Custom...
```

**Custom Options:**
- Every weekday (Mon-Fri)
- Every weekend (Sat-Sun)
- First Monday of each month
- Last Friday of each month

**End Conditions:**
```
Repeat ends:
● Never
○ On date: [Jan 31, 2026]
○ After [10] occurrences
```

**Deliverables:**
- ✅ Full recurrence picker
- ✅ All common patterns supported
- ✅ Beautiful, easy to use

---

#### Step 18: Smart Filters & Search
**Duration:** 3 hours

**Actions:**
1. Create `Views/iPhone/FilterView.swift`:

**Filter Panel (slide up sheet):**
```
┌─────────────────────────────┐
│  Filters                 ✕  │
├─────────────────────────────┤
│                             │
│  PRIORITY                   │
│  ☐ Urgent                   │
│  ☐ High                     │
│  ☑︎ Medium                   │
│  ☑︎ Low                      │
│                             │
│  PROJECTS                   │
│  ☑︎ Work                     │
│  ☑︎ Personal                 │
│  ☐ Shopping                 │
│                             │
│  TAGS                       │
│  ☑︎ urgent                   │
│  ☐ client                   │
│  ☐ quick-win                │
│                             │
│  DUE DATE                   │
│  ☐ Overdue                  │
│  ☑︎ Today                    │
│  ☑︎ This week                │
│  ☐ This month               │
│  ☐ No due date              │
│                             │
│  STATUS                     │
│  ☑︎ Active                   │
│  ☐ Completed                │
│                             │
│  [Clear All]   [Apply]      │
└─────────────────────────────┘
```

2. Create `Views/Components/SearchBar.swift`:
   - Real-time search as you type
   - Debounced for performance
   - Search task title + description
   - Clear button
   - Recent searches dropdown

3. Smart Lists (pre-configured filters):
   - Inbox: All active tasks
   - Today: Due today or overdue
   - Upcoming: Due within 7 days
   - High Priority: Priority = High or Urgent
   - No Due Date: Tasks without due date
   - Completed: All completed tasks

**Deliverables:**
- ✅ Powerful filtering system
- ✅ Fast search
- ✅ Smart lists working

---

### **PHASE 5: Core UI - iPad & Mac** (Steps 19-22)

#### Step 19: iPad Split View Layout
**Duration:** 3 hours

**Actions:**
1. Create `Views/iPad/iPadMainView.swift`:

**Layout (2-column split):**
```
┌─────────────┬──────────────────────┐
│  SIDEBAR    │   TASK LIST          │
│             │                      │
│  📥 Inbox   │  [Search]       [⚙︎]  │
│  📅 Today   │  ──────────────────  │
│  📆 Upcoming│                      │
│             │  OVERDUE (2)         │
│  PROJECTS   │  ○ Task 1            │
│  📁 Work    │  ○ Task 2            │
│  📁 Personal│                      │
│  📁 Shopping│  TODAY (5)           │
│             │  ○ Task 3            │
│  TAGS       │  ✓ Task 4            │
│  🏷 urgent   │                      │
│  🏷 client   │           [+]        │
│             │                      │
│  [+ New]    │                      │
└─────────────┴──────────────────────┘
```

**Features:**
- Collapsible sidebar
- Sidebar width adjustable
- Tap list item → Update main pane
- Tap task → Show detail in sheet or 3rd column
- Drag tasks to projects (move category)
- Multi-select with keyboard (Shift+Click)

2. Optional 3-column layout (sidebar + list + detail):
```
┌──────────┬────────────┬──────────────┐
│ SIDEBAR  │ TASK LIST  │ TASK DETAIL  │
│          │            │              │
│ ...      │ ...        │ [Full editor]│
└──────────┴────────────┴──────────────┘
```

**Deliverables:**
- ✅ Beautiful iPad layout
- ✅ Responsive to orientation
- ✅ Multi-column working

---

#### Step 20: Mac 3-Pane Layout
**Duration:** 4 hours

**Actions:**
1. Create `Views/Mac/MacMainView.swift`:

**Layout:**
```
┌──────────────────────────────────────────────┐
│  File  Edit  View  Task  Window  Help       │
│  ═══════════════════════════════════════    │
│  [+ New Task]  [Search...]  [Filter] [Sync] │
├──────────┬──────────────┬──────────────────┤
│ SIDEBAR  │  TASK LIST   │  TASK DETAIL     │
│          │              │                  │
│ Inbox    │ [Sort: Due▾] │ ○ Task Title     │
│ Today    │ ────────────│ ─────────────    │
│ Upcoming │              │                  │
│          │ OVERDUE (2)  │ Due: Today 3 PM  │
│ PROJECTS │ ○ Task 1     │ Project: Work    │
│ Work     │ ○ Task 2     │ Priority: High   │
│ Personal │              │                  │
│          │ TODAY (5)    │ 📝 Description   │
│ TAGS     │ ○ Task 3     │ ...              │
│ urgent   │ ✓ Task 4     │                  │
│ client   │ ○ Task 5     │ 🔁 Repeats daily │
│          │              │ 🔔 Remind 15min  │
│ [+ New]  │              │                  │
│          │              │ 📎 Subtasks (0)  │
│          │              │                  │
│          │              │ [Delete Task]    │
└──────────┴──────────────┴──────────────────┘
```

**Mac-Specific Features:**
- Menu bar integration (File, Edit, View, Task, Window, Help)
- Toolbar with buttons
- Keyboard shortcuts (all standard Mac shortcuts)
- Context menus (right-click)
- Touch Bar support (if available)
- Focus mode (hide completed)
- Window state persistence

**Deliverables:**
- ✅ Native Mac app feel
- ✅ 3-pane layout
- ✅ Menu bar + toolbar

---

#### Step 21: Keyboard Shortcuts (Mac/iPad)
**Duration:** 2 hours

**Actions:**
1. Create `Utilities/KeyboardShortcuts.swift`:

**Essential Shortcuts:**
```
⌘N          New Task
⌘F          Search
⌘,          Preferences
Space       Complete/Uncomplete selected task
Delete      Delete selected task
⌘Delete     Delete without confirmation
Return      Edit selected task
⌘1..5       Switch to tab/list (Inbox, Today, etc.)
⌘↑/↓        Navigate tasks
⌘⇧N         New Project
⌘⇧T         New Tag
⌘⇧F         Toggle filters
⌘R          Refresh/Sync
⌘Z          Undo
⌘⇧Z         Redo
⌘A          Select all
⌘⇧A         Deselect all
⌘C          Copy task title
⌘V          Paste as new task
⌘D          Duplicate task
⌘⇧D         Duplicate with recurrence
⌘T          Set due date to today
⌘⇧T         Set due date to tomorrow
⌘1..4       Set priority (Low, Medium, High, Urgent)
⌘0          Remove priority
Esc         Close sheet/cancel edit
⌘W          Close window (Mac)
⌘Q          Quit app (Mac)
```

2. Discoverability:
   - Show shortcuts in menus
   - Keyboard shortcuts overlay (hold ⌘)
   - Settings panel with full list

**Deliverables:**
- ✅ 30+ keyboard shortcuts
- ✅ Power user friendly
- ✅ Standard Mac conventions

---

#### Step 22: Drag & Drop
**Duration:** 2 hours

**Actions:**
1. Implement drag & drop in lists:

**Features:**
- Drag task to reorder within list
- Drag task to project in sidebar (change category)
- Drag task to tag (add tag)
- Drag multiple tasks (multi-select first)
- Visual feedback while dragging
- Haptic feedback on drop
- Undo support

2. Mac-specific:
   - Drag task to Calendar.app (create event)
   - Drag task to Reminders.app (create reminder)
   - Drag text from other apps to create task

**Deliverables:**
- ✅ Smooth drag & drop
- ✅ Works across platforms

---

### **PHASE 6: Advanced Features** (Steps 23-28)

#### Step 23: Project/Category Management
**Duration:** 3 hours

**Actions:**
1. Create `Views/iPhone/ProjectListView.swift`:
   - List all categories/projects
   - Color-coded with icons
   - Task count per project
   - Tap to see project tasks
   - Add/edit/delete projects

2. Create `Views/Components/ProjectEditorView.swift`:

**Form:**
```
┌──────────────────────────┐
│  Edit Project       [Save]│
├──────────────────────────┤
│                          │
│  📝 Name                 │
│  Work                    │
│                          │
│  🎨 Color                │
│  ● Blue ○ Purple ○ Pink  │
│  ○ Green ○ Orange ○ Red  │
│                          │
│  🖼 Icon                  │
│  [Icon picker grid]      │
│                          │
│  [Delete Project]        │
│                          │
└──────────────────────────┘
```

**Features:**
- 12+ color options
- 100+ SF Symbol icons
- Validation (name required)
- Delete warning if tasks exist
- Option to move tasks or delete all

**Default Projects:**
- Inbox (can't delete)
- Personal
- Work
- Shopping
- Health

**Deliverables:**
- ✅ Full project management
- ✅ Beautiful customization

---

#### Step 24: Tag System
**Duration:** 2 hours

**Actions:**
1. Create `Views/iPhone/TagListView.swift`:
   - List all tags
   - Color-coded pills
   - Task count per tag
   - Add/edit/delete tags

2. Create `Views/Components/TagEditorView.swift`:
   - Name input
   - Color picker
   - Delete option

3. Create `Views/Components/TagSelectorView.swift`:
   - Multi-select tag list
   - Search tags
   - Create new inline
   - Used in task editor

**Deliverables:**
- ✅ Flexible tagging system
- ✅ Multi-select in editor

---

#### Step 25: Subtasks
**Duration:** 3 hours

**Actions:**
1. Update Task model:
   - Add `parentTaskID` relationship
   - Computed property: `subtasks: [Task]`
   - Computed property: `progress: Double` (% of subtasks completed)

2. Create `Views/Components/SubtaskListView.swift`:

**Embedded in TaskEditorView:**
```
📎 Subtasks (3 of 5 completed)
[▓▓▓▓▓▓▓░░░] 60%

○ Subtask 1
✓ Subtask 2
✓ Subtask 3
○ Subtask 4
✓ Subtask 5

[+ Add subtask]
```

**Features:**
- Inline adding
- Check/uncheck subtasks
- Reorder with drag
- Delete with swipe
- Progress bar
- Auto-complete parent when all subtasks done (optional setting)

3. TaskRowView update:
   - Show subtask progress: "3/5" badge or mini progress bar
   - Expandable to show subtasks inline

**Deliverables:**
- ✅ Nested subtasks
- ✅ Progress tracking
- ✅ Clean UI integration

---

#### Step 26: Quick Add Task
**Duration:** 2 hours

**Actions:**
1. Create `Views/Components/QuickAddView.swift`:

**Minimal sheet:**
```
┌──────────────────────────┐
│  Quick Add          [Add]│
├──────────────────────────┤
│                          │
│  ○ Task title here       │
│  ───────────────────     │
│                          │
│  📅 Due: Today     ▾     │
│  📁 Project: Inbox ▾     │
│  [!] Priority: None ▾    │
│                          │
│  [Advanced...]           │
└──────────────────────────┘
```

**Features:**
- Minimal fields (title required)
- Quick defaults (due today, inbox, no priority)
- Natural language parsing: "Call John tomorrow at 2pm #work !high"
  - Extracts due date: "tomorrow at 2pm"
  - Extracts project: #work → Work project
  - Extracts priority: !high → High priority
- Keyboard shortcuts (⌘Return to save)
- Advanced button → Full editor

2. Implement natural language parsing:
   - Due date keywords: today, tomorrow, Monday, next week, etc.
   - Project: #projectname
   - Priority: !low, !medium, !high, !urgent
   - Tags: @tagname
   - Recurrence: every day, every Monday, weekly, etc.

**Deliverables:**
- ✅ Fast task entry
- ✅ Smart parsing
- ✅ Saves time

---

#### Step 27: Batch Operations
**Duration:** 2 hours

**Actions:**
1. Create `Views/Components/SelectionBar.swift`:

**Bottom bar when tasks selected:**
```
┌──────────────────────────────────┐
│  [3 selected]                    │
│  [Complete] [Schedule] [Delete]  │
└──────────────────────────────────┘
```

**Features:**
- Multi-select mode toggle
- Select all / Deselect all
- Batch complete
- Batch reschedule (set due date for all)
- Batch change project
- Batch add tag
- Batch delete with confirmation

2. Implement in TaskListView:
   - Edit mode toggle button
   - Checkboxes appear on left
   - Selection state management
   - Confirm before destructive actions

**Deliverables:**
- ✅ Efficient bulk editing
- ✅ Clean UX

---

#### Step 28: Task Import/Export
**Duration:** 3 hours

**Actions:**
1. Create `Services/ImportExportService.swift`:

**Export Formats:**
- **JSON:** Full data export (tasks, projects, tags)
- **CSV:** Spreadsheet-friendly (task list)
- **Markdown:** Human-readable checklist
- **Todoist Format:** Import from Todoist backup

**Export Method:**
```swift
func exportTasks(
    format: ExportFormat,
    includeCompleted: Bool = false
) async -> URL?
```

**Import Formats:**
- **JSON:** Restore from backup
- **CSV:** Import from spreadsheet
- **Markdown:** Import markdown checklist (- [ ] Task)
- **Todoist:** Migrate from Todoist

**Import Method:**
```swift
func importTasks(
    from url: URL,
    format: ImportFormat
) async throws -> ImportResult
```

2. Create UI:
   - Settings → Import/Export
   - Export button → Share sheet
   - Import button → File picker
   - Preview before import
   - Duplicate detection
   - Merge strategy options

**Deliverables:**
- ✅ Full data portability
- ✅ Todoist migration path
- ✅ Backup/restore

---

### **PHASE 7: CloudKit Sync** (Steps 29-34)

#### Step 29: DataSyncService Implementation
**Duration:** 4 hours

**Actions:**
1. Create `Services/DataSyncService.swift`:

**Core Structure:**
```swift
actor DataSyncService {
    private let container: CKContainer
    private let privateDB: CKDatabase
    private let modelContext: ModelContext

    // Change token persistence
    private var taskZoneToken: CKServerChangeToken?
    private var categoryZoneToken: CKServerChangeToken?
    private var tagZoneToken: CKServerChangeToken?

    // Sync state
    private var isSyncing = false
    private var lastSyncDate: Date?

    init(container: CKContainer, modelContext: ModelContext)

    // Main sync methods
    func syncAll() async throws
    func syncToCloud() async throws    // Upload local changes
    func syncFromCloud() async throws  // Download remote changes
}
```

**Deliverables:**
- ✅ Actor-based service
- ✅ Thread-safe
- ✅ Ready for implementation

---

#### Step 30: Upload to Cloud
**Duration:** 3 hours

**Actions:**
Implement upload methods in DataSyncService:

```swift
// Upload all pending local changes
func syncToCloud() async throws {
    // 1. Fetch all tasks with syncStatus = .pending
    let pendingTasks = fetchPendingTasks()
    let pendingCategories = fetchPendingCategories()
    let pendingTags = fetchPendingTags()

    // 2. Convert to CKRecords
    let taskRecords = pendingTasks.map { $0.toCKRecord() }
    let categoryRecords = pendingCategories.map { $0.toCKRecord() }
    let tagRecords = pendingTags.map { $0.toCKRecord() }

    // 3. Batch upload (max 400 per batch)
    try await uploadInBatches(
        records: taskRecords + categoryRecords + tagRecords
    )

    // 4. Update sync status to .synced
    markAsSynced(pendingTasks + pendingCategories + pendingTags)

    // 5. Handle deletions (isDeleted = true)
    let deletedIDs = fetchDeletedRecordIDs()
    try await deleteFromCloud(recordIDs: deletedIDs)

    // 6. Permanently delete after successful cloud delete
    permanentlyDelete(deletedIDs)
}

private func uploadInBatches(records: [CKRecord]) async throws {
    let batches = records.chunked(into: 400)
    for batch in batches {
        let operation = CKModifyRecordsOperation(
            recordsToSave: batch,
            recordIDsToDelete: nil
        )
        operation.savePolicy = .changedKeys
        operation.modifyRecordsCompletionBlock = { saved, deleted, error in
            // Handle results
        }
        try await privateDB.add(operation)
    }
}
```

**Error Handling:**
- Network unavailable → Add to offline queue
- Conflict → Trigger conflict resolution
- Server error → Retry with exponential backoff
- Partial failure → Retry failed records only

**Deliverables:**
- ✅ Upload working
- ✅ Batch processing
- ✅ Error handling

---

#### Step 31: Download from Cloud
**Duration:** 3 hours

**Actions:**
Implement download methods:

```swift
func syncFromCloud() async throws {
    // 1. Fetch changes since last sync (using change tokens)
    let taskChanges = try await fetchChanges(
        in: taskZone,
        since: taskZoneToken
    )

    let categoryChanges = try await fetchChanges(
        in: categoryZone,
        since: categoryZoneToken
    )

    let tagChanges = try await fetchChanges(
        in: tagZone,
        since: tagZoneToken
    )

    // 2. Process changed records
    for record in taskChanges.changed {
        if let existingTask = findTask(cloudID: record.recordID) {
            // Update exists → Check for conflict
            if existingTask.updatedAt > record.updatedAt {
                // Local is newer → Conflict
                await resolveConflict(local: existingTask, remote: record)
            } else {
                // Remote is newer → Update local
                existingTask.updateFrom(record)
            }
        } else {
            // New record → Create local
            let newTask = Task.fromCKRecord(record)
            modelContext.insert(newTask)
        }
    }

    // 3. Process deletions
    for recordID in taskChanges.deleted {
        if let task = findTask(cloudID: recordID) {
            modelContext.delete(task)
        }
    }

    // 4. Save context
    try modelContext.save()

    // 5. Update change tokens
    taskZoneToken = taskChanges.newToken
    saveChangeToken(taskZoneToken, for: "taskZone")
}

private func fetchChanges(
    in zone: CKRecordZone,
    since token: CKServerChangeToken?
) async throws -> (
    changed: [CKRecord],
    deleted: [CKRecord.ID],
    newToken: CKServerChangeToken
) {
    // Use CKFetchRecordZoneChangesOperation
}
```

**Deliverables:**
- ✅ Download working
- ✅ Change tokens tracked
- ✅ Incremental sync

---

#### Step 32: Conflict Resolution
**Duration:** 2 hours

**Actions:**
1. Implement last-write-wins strategy:

```swift
func resolveConflict(
    local: Task,
    remote: CKRecord
) async {
    // Compare timestamps
    let localTime = local.updatedAt
    let remoteTime = remote.modificationDate ?? Date.distantPast

    if localTime > remoteTime {
        // Local wins → Upload local version
        local.syncStatus = .pending
        try? await syncToCloud()
    } else {
        // Remote wins → Update local
        local.updateFrom(remote)
        local.syncStatus = .synced
    }
}
```

2. Optional: User choice strategy (future enhancement):
   - Show conflict UI
   - Let user pick which version to keep
   - Merge fields manually

**Deliverables:**
- ✅ Conflicts resolved automatically
- ✅ No data loss

---

#### Step 33: Offline Queue & Retry
**Duration:** 2 hours

**Actions:**
1. Create `Services/SyncQueue.swift`:

```swift
actor SyncQueue {
    private var queue: [SyncOperation] = []
    private let maxRetries = 5

    struct SyncOperation {
        let id: UUID
        let type: OperationType
        let recordID: String
        var retryCount: Int = 0
        let createdAt: Date
    }

    enum OperationType {
        case create, update, delete
    }

    func enqueue(_ operation: SyncOperation)
    func processQueue() async
    func retry(_ operation: SyncOperation) async
    func removeFailed(olderThan days: Int)
}
```

2. Integrate with DataSyncService:
   - On network failure → Add to queue
   - On network restored → Process queue
   - Background processing every 15 minutes
   - Exponential backoff (1s, 2s, 4s, 8s, 16s)

3. Persist queue in UserDefaults or SwiftData

**Deliverables:**
- ✅ Offline support
- ✅ Automatic retry
- ✅ Resilient sync

---

#### Step 34: Push Notifications for Sync
**Duration:** 2 hours

**Actions:**
1. Create CloudKit subscriptions:

```swift
func setupSubscriptions() async throws {
    // Subscribe to all record changes in private DB
    let subscription = CKQuerySubscription(
        recordType: "CKTask",
        predicate: NSPredicate(value: true),
        options: [.firesOnRecordCreation, .firesOnRecordUpdate, .firesOnRecordDeletion]
    )

    let notification = CKSubscription.NotificationInfo()
    notification.shouldSendContentAvailable = true
    subscription.notificationInfo = notification

    try await privateDB.save(subscription)

    // Repeat for CKCategory and CKTag
}
```

2. Handle push notifications in AppDelegate:

```swift
func application(
    _ application: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable: Any],
    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
) {
    if let notification = CKNotification(fromRemoteNotificationDictionary: userInfo) {
        Task {
            try? await dataSyncService.syncFromCloud()
            completionHandler(.newData)
        }
    }
}
```

3. Enable background sync:
   - Background Modes → Remote notifications
   - Sync when push received
   - Silent push (no user interruption)

**Deliverables:**
- ✅ Real-time sync across devices
- ✅ Silent background updates
- ✅ Always in sync

---

### **PHASE 8: Widgets** (Steps 35-37)

#### Step 35: Small Widget (Task Count)
**Duration:** 2 hours

**Actions:**
1. Create Widget Extension target
2. Create `Widgets/TaskCountWidget.swift`:

**Design:**
```
┌─────────────┐
│  ToDo-Appy  │
│             │
│      5      │
│   Tasks Due │
│             │
│   3 Overdue │
└─────────────┘
```

**Features:**
- Shows count of tasks due today
- Shows overdue count (red if > 0)
- Deep link to Today view on tap
- Updates every 15 minutes
- Dark mode colors

**Deliverables:**
- ✅ Small widget working
- ✅ Updates automatically

---

#### Step 36: Medium Widget (Task List)
**Duration:** 2 hours

**Actions:**
1. Create `Widgets/TaskListWidget.swift`:

**Design:**
```
┌────────────────────────────┐
│  ToDo-Appy          Today  │
│                            │
│  ○ Task 1           3:00PM │
│  ○ Task 2           5:00PM │
│  ○ Task 3        Tomorrow  │
│  ○ Task 4         Jan 20   │
│                            │
│  + 8 more                  │
└────────────────────────────┘
```

**Features:**
- Shows up to 4 upcoming tasks
- Sorted by due date
- Tap task → Open in app
- Tap "+8 more" → Open full list
- Checkboxes not interactive (widget limitation)

**Deliverables:**
- ✅ Medium widget working
- ✅ Shows upcoming tasks

---

#### Step 37: Large Widget (Full Overview)
**Duration:** 2 hours

**Actions:**
1. Create `Widgets/OverviewWidget.swift`:

**Design:**
```
┌─────────────────────────────────┐
│  ToDo-Appy                      │
│                                 │
│  OVERDUE (2)                    │
│  ○ Task 1                       │
│  ○ Task 2                       │
│                                 │
│  TODAY (5)                      │
│  ○ Task 3              3:00 PM  │
│  ○ Task 4              5:00 PM  │
│                                 │
│  UPCOMING (12)                  │
│  ○ Task 5           Tomorrow    │
│  ○ Task 6           Jan 20      │
│                                 │
│  [View All]                     │
└─────────────────────────────────┘
```

**Features:**
- Grouped by section
- Shows up to 6 tasks
- Color-coded sections
- Deep links to each section

**Deliverables:**
- ✅ Large widget working
- ✅ Comprehensive overview

---

### **PHASE 9: Polish & Animations** (Steps 38-42)

#### Step 38: Animation System
**Duration:** 3 hours

**Actions:**
1. Create `DesignSystem/Animations.swift`:

**Predefined Animations:**
```swift
// Checkbox completion
static let checkboxTap = Animation.spring(
    response: 0.3,
    dampingFraction: 0.6,
    blendDuration: 0
)

// Task row swipe
static let swipeReveal = Animation.easeOut(duration: 0.25)

// List item insertion
static let itemInsert = Animation.spring(
    response: 0.4,
    dampingFraction: 0.8
)

// Sheet presentation
static let sheetSlide = Animation.spring(
    response: 0.35,
    dampingFraction: 0.85
)

// Delete animation
static let itemDelete = Animation.easeIn(duration: 0.2)

// Pull to refresh
static let pullToRefresh = Animation.linear(duration: 0.15)
```

2. Implement animations:
   - **Checkbox tap:** Scale + rotation (0.8x → 1.2x → 1.0x) + checkmark draw
   - **Task completion:** Fade + strikethrough animation
   - **Swipe actions:** Smooth reveal with color fill
   - **Delete:** Slide out + fade + scale down
   - **Add task:** Slide in from bottom
   - **List reorder:** Smooth position transition
   - **Tab switch:** Cross-fade
   - **Filter apply:** Smooth list refresh

3. Micro-interactions:
   - Button press: Scale down to 0.95
   - Toggle switch: Smooth slide
   - Text field focus: Subtle glow
   - Loading spinner: Smooth rotation

**Deliverables:**
- ✅ Buttery smooth animations
- ✅ Delightful interactions
- ✅ Professional feel

---

#### Step 39: Haptic Feedback
**Duration:** 1 hour

**Actions:**
1. Create `Utilities/HapticManager.swift`:

```swift
class HapticManager {
    static let shared = HapticManager()

    func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    func medium() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    func heavy() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }

    func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}
```

2. Add haptics to interactions:
   - Checkbox tap → `light()`
   - Task complete → `success()`
   - Task delete → `warning()`
   - Swipe action → `selection()`
   - Pull to refresh → `light()` when threshold reached
   - Drag & drop → `selection()` on move, `medium()` on drop
   - Button tap → `light()`
   - Error → `error()`

**Deliverables:**
- ✅ Tactile feedback throughout
- ✅ Enhanced UX

---

#### Step 40: Loading States & Skeletons
**Duration:** 2 hours

**Actions:**
1. Create `Views/Components/LoadingView.swift`:

**Skeleton Screens:**
```
┌─────────────────────────┐
│  ░░░░░░░░░░░░░░░  ░░░  │ ← Shimmering gray bars
│  ░░░░░░  ░░░░           │
│                         │
│  ░░░░░░░░░░░░░░░  ░░░  │
│  ░░░░░░░░  ░░           │
│                         │
│  ░░░░░░░░░░░░  ░░░░░   │
│  ░░░░  ░░░░             │
└─────────────────────────┘
```

**Features:**
- Shimmer animation (gradient sweep)
- Match layout of real content
- Smooth transition to real data
- Show while: initial load, sync in progress

2. Create loading indicators:
   - Pull-to-refresh spinner
   - Sync status indicator
   - Button loading state (spinner in button)
   - Full-screen loading (first launch)

**Deliverables:**
- ✅ Professional loading states
- ✅ No jarring blank screens

---

#### Step 41: Empty States
**Duration:** 1.5 hours

**Actions:**
1. Create `Views/Components/EmptyStateView.swift`:

**Design:**
```
┌─────────────────────────┐
│                         │
│          📝            │
│                         │
│   No tasks yet!         │
│   Tap + to get started  │
│                         │
└─────────────────────────┘
```

**Different states:**
- **Inbox empty:** "No tasks yet! Tap + to get started"
- **Today empty:** "Nothing due today! Enjoy your day"
- **Search no results:** "No tasks match your search"
- **Filter no results:** "No tasks match these filters"
- **Completed empty:** "No completed tasks yet"
- **Project empty:** "No tasks in this project"

**Features:**
- Relevant SF Symbol icon
- Friendly message
- Optional call-to-action button
- Subtle animation on appear

**Deliverables:**
- ✅ Friendly empty states
- ✅ Guides user actions

---

#### Step 42: App Icon & Launch Screen
**Duration:** 2 hours

**Actions:**
1. Design app icon:
   - Simple checkmark in circle
   - Dark background (black or dark blue)
   - Vibrant accent color (blue/purple/pink)
   - All sizes (1024×1024 master, auto-generate smaller)
   - Consistent with dark theme

2. Create launch screen:
   - App icon centered
   - Dark background
   - Minimal, matches app UI
   - Smooth transition to main screen

3. Generate assets:
   - Use Xcode asset catalog
   - Include all required sizes
   - macOS icon (ICNS)
   - iPad icon

**Deliverables:**
- ✅ Professional app icon
- ✅ Seamless launch experience

---

### **PHASE 10: Testing** (Steps 43-47)

#### Step 43: Unit Tests - Data Models
**Duration:** 3 hours

**Actions:**
1. Create `Tests/ModelTests.swift`:

**Test cases:**
```swift
// Task model tests
func testTaskCreation()
func testTaskCompletion()
func testTaskRecurrence()
func testTaskValidation()
func testTaskRelationships()

// Category model tests
func testCategoryCreation()
func testCategoryTaskRelationship()

// Tag model tests
func testTagCreation()
func testTagTaskRelationship()

// RecurrenceRule tests
func testDailyRecurrence()
func testWeeklyRecurrence()
func testMonthlyRecurrence()
func testYearlyRecurrence()
func testRecurrenceEndDate()
func testMonthEndEdgeCase()
```

2. Create `Tests/RecurrenceEngineTests.swift`:

**Test cases:**
```swift
func testNextOccurrenceDaily()
func testNextOccurrenceWeekly()
func testNextOccurrenceMonthly()
func testGenerateOccurrences()
func testCompleteRecurringTask()
func testMonthEndAdjustment()
func testWeekendSkip()
func testRecurrenceEndDate()
```

**Coverage goal:** 90%+ for models and business logic

**Deliverables:**
- ✅ Comprehensive model tests
- ✅ High code coverage

---

#### Step 44: Unit Tests - Services
**Duration:** 3 hours

**Actions:**
1. Create `Tests/DataSyncServiceTests.swift`:

**Test cases:**
```swift
func testUploadToCloud()
func testDownloadFromCloud()
func testConflictResolution()
func testOfflineQueue()
func testBatchOperations()
func testChangeTokenPersistence()
```

2. Create `Tests/NotificationServiceTests.swift`:

**Test cases:**
```swift
func testScheduleReminder()
func testCancelReminder()
func testReminderOffset()
func testRecurringReminder()
func testMultipleReminders()
```

3. Create `Tests/ImportExportServiceTests.swift`:

**Test cases:**
```swift
func testExportJSON()
func testImportJSON()
func testExportCSV()
func testImportCSV()
func testExportMarkdown()
func testTodoistImport()
```

**Deliverables:**
- ✅ Service layer fully tested
- ✅ Edge cases covered

---

#### Step 45: UI Tests - Critical Flows
**Duration:** 4 hours

**Actions:**
1. Create `UITests/TaskManagementTests.swift`:

**Test cases:**
```swift
func testCreateTask()
func testCompleteTask()
func testEditTask()
func testDeleteTask()
func testRecurringTaskCreation()
func testSubtaskCreation()
```

2. Create `UITests/NavigationTests.swift`:

**Test cases:**
```swift
func testTabNavigation()
func testSidebarNavigation()
func testSearchFlow()
func testFilterFlow()
func testProjectNavigation()
```

3. Create `UITests/SyncTests.swift`:

**Test cases:**
```swift
func testPullToRefresh()
func testOfflineMode()
func testSyncIndicator()
```

**Deliverables:**
- ✅ Critical user flows tested
- ✅ UI regressions caught

---

#### Step 46: Multi-Device Sync Testing
**Duration:** 3 hours

**Actions:**
1. Test sync scenarios:

**Test cases:**
- Create task on iPhone → Verify appears on iPad
- Edit task on Mac → Verify updates on iPhone
- Delete task on iPad → Verify removed on Mac
- Complete task on iPhone → Verify on all devices
- Create recurring task → Verify instances sync
- Offline create on iPhone + Online create on iPad → Verify both sync when online
- Conflict: Edit same task offline on two devices → Verify conflict resolution

2. Test edge cases:
   - Large dataset (1000+ tasks)
   - Rapid changes (create 100 tasks quickly)
   - Network interruption during sync
   - CloudKit quota exceeded (unlikely but handle gracefully)

3. Test across platforms:
   - iPhone + iPad
   - iPhone + Mac
   - iPad + Mac
   - All three simultaneously

**Deliverables:**
- ✅ Sync verified across devices
- ✅ Edge cases handled

---

#### Step 47: Performance & Accessibility Testing
**Duration:** 2 hours

**Actions:**
1. Performance testing:
   - Measure launch time (< 2 seconds)
   - Measure list scroll (60fps with 1000+ tasks)
   - Measure sync time (< 5 seconds for 100 changes)
   - Check memory usage (< 100MB idle)
   - Check battery drain (minimal background)

2. Accessibility testing:
   - VoiceOver: Navigate entire app
   - Dynamic Type: Test all size categories (XS to XXXL)
   - Color contrast: Verify WCAG AAA (7:1)
   - Reduce Motion: Disable animations gracefully
   - VoiceControl: All actions accessible

3. Tools:
   - Xcode Instruments (CPU, Memory, Energy)
   - Accessibility Inspector
   - Real device testing

**Deliverables:**
- ✅ Fast, responsive app
- ✅ Fully accessible

---

### **PHASE 11: Settings & Preferences** (Step 48)

#### Step 48: Settings Screen
**Duration:** 3 hours

**Actions:**
1. Create `Views/iPhone/SettingsView.swift`:

**Settings sections:**
```
┌──────────────────────────────┐
│  Settings                 ✕  │
├──────────────────────────────┤
│                              │
│  APPEARANCE                  │
│  Accent Color      Blue  ▾   │
│  App Icon          Default ▾ │
│                              │
│  TASKS                       │
│  Default Project   Inbox  ▾  │
│  Default Priority  None   ▾  │
│  Auto-complete parent        │
│    when all subtasks done ☑︎  │
│  Confirm before delete    ☑︎  │
│                              │
│  REMINDERS                   │
│  Default reminder  15min  ▾  │
│  Notification sound          │
│    Default               ▾   │
│  Badge count       Today  ▾  │
│                              │
│  SYNC                        │
│  Auto-sync              ☑︎    │
│  Sync frequency  15min   ▾   │
│  Last synced     2 min ago   │
│  [Sync Now]                  │
│                              │
│  DATA                        │
│  [Export Data]               │
│  [Import Data]               │
│  [Clear Completed Tasks]     │
│  Storage used    2.4 MB      │
│                              │
│  ABOUT                       │
│  Version         1.0.0       │
│  [Privacy Policy]            │
│  [Terms of Service]          │
│  [Keyboard Shortcuts]        │
│  [Send Feedback]             │
│                              │
└──────────────────────────────┘
```

2. Implement settings:
   - Store in UserDefaults
   - Apply changes immediately
   - Sync settings across devices (optional)

**Deliverables:**
- ✅ Full settings screen
- ✅ User preferences respected

---

### **PHASE 12: Deployment** (Steps 49-51)

#### Step 49: App Store Connect Setup
**Duration:** 2 hours

**Actions:**
1. Create App Store Connect listing:
   - App name: ToDo-Appy
   - Subtitle: Private, Free Task Manager
   - Category: Productivity
   - Age rating: 4+
   - Privacy policy URL

2. Prepare marketing assets:
   - Screenshots (all device sizes)
   - App preview video (optional)
   - App description
   - Keywords: todo, task manager, productivity, free, private, icloud
   - Support URL
   - Marketing URL

3. Description template:
```
ToDo-Appy: Your Private, Free Task Manager

FEATURES:
• Create, organize, and complete tasks
• Projects for clean organization
• Tags for flexible categorization
• Recurring tasks (daily, weekly, monthly, yearly)
• Smart reminders
• Beautiful dark mode interface
• Subtasks and task dependencies
• Search and powerful filtering
• Widgets for your home screen

PRIVACY-FIRST:
• All data stored in YOUR private iCloud
• No third-party servers
• No tracking, no ads
• Your data belongs to you

SEAMLESS SYNC:
• Automatic sync across iPhone, iPad, and Mac
• Works offline, syncs when online
• Real-time updates

COMPLETELY FREE:
• No subscriptions
• No in-app purchases
• No ads, ever

100% Native Apple Experience:
• SwiftUI interface
• Keyboard shortcuts on Mac/iPad
• Drag & drop support
• VoiceOver accessibility
• Handoff between devices
```

**Deliverables:**
- ✅ App Store listing ready
- ✅ Marketing materials prepared

---

#### Step 50: TestFlight Beta
**Duration:** 1 hour + 1-2 weeks testing

**Actions:**
1. Create TestFlight build:
   - Bump version to 1.0.0 (build 1)
   - Archive in Xcode
   - Upload to App Store Connect
   - Wait for processing (~30 min)

2. Invite beta testers:
   - Internal testers (immediate access)
   - External testers (requires Beta App Review)
   - 10-50 testers recommended

3. Collect feedback:
   - Monitor crash reports
   - Review tester feedback
   - Fix critical bugs
   - Release updated builds (1.0.0 build 2, 3, etc.)

4. Beta testing goals:
   - Verify sync works across devices
   - Catch UI bugs
   - Test on various device models
   - Verify notifications work
   - Check performance on older devices

**Duration:** 1-2 weeks of testing and iteration

**Deliverables:**
- ✅ Stable beta build
- ✅ Critical bugs fixed
- ✅ Ready for public release

---

#### Step 51: App Store Submission
**Duration:** 1 hour + 1-2 days review

**Actions:**
1. Final pre-flight:
   - Version: 1.0.0
   - All features complete
   - No known critical bugs
   - Privacy manifest included (if required)
   - Export compliance: No encryption beyond HTTPS (select "No")

2. Submit for review:
   - Click "Submit for Review"
   - Answer App Review questions
   - Add demo account if needed (not required for this app)
   - Review notes: "Private to-do list app using CloudKit for sync"

3. App Review timeline:
   - Usually 24-48 hours
   - May request changes/clarifications
   - Fix and resubmit if rejected

4. Launch:
   - Once approved, status = "Ready for Sale"
   - Manually release or auto-release
   - Monitor reviews
   - Respond to user feedback

**Deliverables:**
- ✅ App live on App Store!
- ✅ Users can download

---

## 🎨 Design Highlights

### Dark Mode Color Palette
- **Background:** Pure black (#000000) for OLED battery savings
- **Cards:** Dark gray (#1C1C1E) for depth
- **Accents:** Vibrant blues, purples, pinks
- **Text:** White with varying opacity for hierarchy

### Slick Animations
- **Spring physics:** Bouncy, natural feel
- **Timing:** Fast (200-400ms) for responsiveness
- **Easing:** Smooth curves, no jarring linear
- **Micro-interactions:** Every tap, swipe, drag

### Typography
- **SF Pro:** Apple's native font
- **Hierarchy:** Bold titles, regular body, light captions
- **Monospace:** Dates and numbers for alignment

---

## 🔄 Recurring Task Examples

| User Input | Pattern |
|------------|---------|
| "Every day" | Daily, interval: 1 |
| "Every 3 days" | Daily, interval: 3 |
| "Every Monday" | Weekly, interval: 1, days: [Monday] |
| "Every Mon, Wed, Fri" | Weekly, interval: 1, days: [Mon, Wed, Fri] |
| "Every 2 weeks" | Weekly, interval: 2, days: [current day] |
| "Every month on the 15th" | Monthly, interval: 1, day: 15 |
| "Every last day of month" | Monthly, interval: 1, day: last |
| "Every year on Jan 1" | Yearly, interval: 1, month: 1, day: 1 |

---

## 📱 Platform-Specific Features

### iPhone
- Tab bar navigation
- Single-column list
- Optimized for one-hand use
- Quick add with minimal taps

### iPad
- Split view (sidebar + list + detail)
- Multi-select with trackpad
- Drag & drop between panes
- Keyboard shortcuts

### Mac
- Three-pane layout
- Full menu bar
- Extensive keyboard shortcuts
- Context menus
- Touch Bar support

---

## 🎯 Key Differentiators from Todoist

| Feature | Todoist | ToDo-Appy |
|---------|---------|-----------|
| **Price** | $4/month or $48/year | **Free forever** |
| **Data Privacy** | Todoist servers | **Your private iCloud** |
| **Ads** | None (paid only) | **None, ever** |
| **Offline Mode** | Limited | **Full offline support** |
| **Recurring Tasks** | ✅ Yes | **✅ Yes** |
| **Projects** | ✅ Yes | **✅ Yes (called Projects)** |
| **Tags** | ✅ Yes (labels) | **✅ Yes** |
| **Subtasks** | ✅ Yes | **✅ Yes** |
| **Reminders** | ✅ Yes | **✅ Yes** |
| **Dark Mode** | ✅ Light + Dark | **✅ Dark only** |
| **Cross-platform** | All platforms | **Apple ecosystem only** |
| **Native App** | React Native | **100% Native SwiftUI** |

---

## 📊 Development Timeline

| Phase | Duration | Steps |
|-------|----------|-------|
| Phase 1: Foundation | 2 hours | 1-3 |
| Phase 2: Data Layer | 9 hours | 4-8 |
| Phase 3: Design System | 6 hours | 9-12 |
| Phase 4: iPhone UI | 16 hours | 13-18 |
| Phase 5: iPad/Mac UI | 11 hours | 19-22 |
| Phase 6: Advanced Features | 15 hours | 23-28 |
| Phase 7: CloudKit Sync | 16 hours | 29-34 |
| Phase 8: Widgets | 6 hours | 35-37 |
| Phase 9: Polish | 9.5 hours | 38-42 |
| Phase 10: Testing | 15 hours | 43-47 |
| Phase 11: Settings | 3 hours | 48 |
| Phase 12: Deployment | 4 hours + review time | 49-51 |

**Total Development Time:** ~112 hours (14 days @ 8 hrs/day)
**Total Calendar Time:** ~4-6 weeks (including testing and review)

---

## 🚀 Next Steps

1. **Review this plan** - Make sure it aligns with your vision
2. **Adjust priorities** - Any features to add/remove/change?
3. **Commit to timeline** - Ready to dedicate time to build?
4. **Start Phase 1** - I can begin implementation immediately

This is a comprehensive, production-ready plan. Every step is detailed, every feature is spec'd, and the end result will be a beautiful, private, free Todoist alternative that you own completely.

**Ready to build?** 🔨
