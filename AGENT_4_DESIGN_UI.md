# Agent 4: Design System & iPhone UI Specialist

**Role:** Create a beautiful dark-mode-only design system and build the complete iPhone user interface.

**Start:** After Agent 2 completes models
**Depends On:** Agent 1 (project structure), Agent 2 (models)
**Works in Parallel With:** Agent 3, Agent 5
**Estimated Time:** 12-15 hours

---

## 🎯 Mission
Build a **slick, gorgeous, dark-mode-only** interface that rivals Todoist's design but feels more native and polished. Create reusable components and implement smooth animations throughout.

---

## ✅ TODO List

### TASK 1: Pull Code & Verify Setup (10 min)

- [ ] 1.1: Pull latest code
- [ ] 1.2: Verify Agent 1 & 2 deliverables present
- [ ] 1.3: Project builds successfully

---

### TASK 2: Create Dark Mode Color System (1.5 hrs)

#### Subtasks:
- [ ] 2.1: Create `DesignSystem/Colors.swift`

**Color palette (pure dark mode):**
```swift
import SwiftUI

struct AppColors {
    // Backgrounds
    static let background = Color(hex: "#000000")!           // Pure black (OLED)
    static let backgroundSecondary = Color(hex: "#1C1C1E")!  // Card background
    static let backgroundTertiary = Color(hex: "#2C2C2E")!   // Input backgrounds
    static let backgroundElevated = Color(hex: "#3A3A3C")!   // Floating elements

    // Text
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.6)
    static let textTertiary = Color.white.opacity(0.3)

    // Accent colors
    static let accentBlue = Color(hex: "#0A84FF")!
    static let accentPurple = Color(hex: "#BF5AF2")!
    static let accentPink = Color(hex: "#FF375F")!
    static let accentOrange = Color(hex: "#FF9F0A")!
    static let accentGreen = Color(hex: "#32D74B")!
    static let accentYellow = Color(hex: "#FFD60A")!
    static let accentRed = Color(hex: "#FF453A")!

    // Priority colors
    static let priorityUrgent = accentRed
    static let priorityHigh = accentOrange
    static let priorityMedium = accentYellow
    static let priorityLow = accentBlue

    // UI elements
    static let separator = Color(hex: "#38383A")!
    static let overlay = Color.black.opacity(0.4)
}
```

- [ ] 2.2: Add gradient presets
- [ ] 2.3: Test on device - verify OLED blacks

**Deliverable:** `feat(design): create dark-mode-only color system`

---

### TASK 3: Typography System (1 hr)

- [ ] 3.1: Create `DesignSystem/Typography.swift`

```swift
struct AppTypography {
    // Headings
    static let largeTitle = Font.system(size: 34, weight: .bold)
    static let title1 = Font.system(size: 28, weight: .bold)
    static let title2 = Font.system(size: 22, weight: .bold)
    static let title3 = Font.system(size: 20, weight: .semibold)

    // Body
    static let body = Font.system(size: 17, weight: .regular)
    static let bodyBold = Font.system(size: 17, weight: .semibold)
    static let callout = Font.system(size: 16)

    // Small
    static let subheadline = Font.system(size: 15)
    static let footnote = Font.system(size: 13)
    static let caption = Font.system(size: 12)

    // Monospaced (for dates/times)
    static let mono = Font.system(size: 15, design: .monospaced)
}
```

**Deliverable:** `feat(design): add typography system`

---

### TASK 4: Spacing & Layout Constants (45 min)

- [ ] 4.1: Create `DesignSystem/Spacing.swift`
- [ ] 4.2: Define spacing scale (4, 8, 12, 16, 24, 32, 48, 64)
- [ ] 4.3: Add corner radius values
- [ ] 4.4: Add shadow definitions

**Deliverable:** `feat(design): add spacing and layout system`

---

### TASK 5: Reusable UI Components (3 hrs)

Create in `DesignSystem/Components/`:

- [ ] 5.1: **AppButton.swift** - Primary/secondary/destructive button styles
- [ ] 5.2: **AppTextField.swift** - Styled text input
- [ ] 5.3: **AppCard.swift** - Elevated card container
- [ ] 5.4: **PriorityBadge.swift** - Color-coded priority indicator
- [ ] 5.5: **DateBadge.swift** - Due date display (color changes based on proximity)
- [ ] 5.6: **TagPill.swift** - Rounded tag bubble
- [ ] 5.7: **LoadingSpinner.swift** - Animated spinner
- [ ] 5.8: **EmptyStateView.swift** - Empty list placeholder
- [ ] 5.9: **CheckboxView.swift** - Animated checkbox (unchecked → checked)
- [ ] 5.10: **FloatingActionButton.swift** - Circular FAB for adding tasks

**Each component must have:**
- Dark mode colors
- Smooth animations
- Haptic feedback
- Preview code

**Deliverable:** `feat(design): add 10 reusable UI components`

---

### TASK 6: Animation System (1 hr)

- [ ] 6.1: Create `DesignSystem/Animations.swift`

```swift
struct AppAnimations {
    static let checkboxTap = Animation.spring(response: 0.3, dampingFraction: 0.6)
    static let swipeReveal = Animation.easeOut(duration: 0.25)
    static let itemInsert = Animation.spring(response: 0.4, dampingFraction: 0.8)
    static let sheetSlide = Animation.spring(response: 0.35, dampingFraction: 0.85)
    static let itemDelete = Animation.easeIn(duration: 0.2)
}
```

- [ ] 6.2: Add haptic feedback manager

**Deliverable:** `feat(design): add animation and haptic system`

---

### TASK 7: iPhone Tab Navigation (1 hr)

- [ ] 7.1: Create `Views/iPhone/MainTabView.swift`

**5 tabs:**
- Inbox (all tasks) - `tray.fill`
- Today (due today + overdue) - `calendar.badge.clock`
- Upcoming (next 7 days) - `calendar`
- Projects (categories) - `folder.fill`
- Tags - `tag.fill`

- [ ] 7.2: Custom tab bar styling (dark background)
- [ ] 7.3: Badge counts
- [ ] 7.4: Haptic on tab switch

**Deliverable:** `feat(ui): create iPhone tab navigation`

---

### TASK 8: Task List View (Core Screen) (4 hrs)

- [ ] 8.1: Create `Views/iPhone/TaskListView.swift`
- [ ] 8.2: Create `ViewModels/TaskListViewModel.swift`

**Features:**
- Sectioned list (Overdue, Today, Upcoming, Completed)
- Pull-to-refresh
- Search bar
- Filter button
- Sort options
- Empty states
- Floating + button
- LazyVStack for performance

**ViewModel:**
```swift
@Observable
class TaskListViewModel {
    var tasks: [Task] = []
    var searchText = ""
    var filterPriority: Priority?
    var filterCategory: Category?
    var sortOrder: SortOrder = .dueDate
    var isLoading = false

    func loadTasks() async { }
    func toggleCompletion(_ task: Task) { }
    func deleteTask(_ task: Task) { }
    func filteredAndSortedTasks() -> [Task] { }
}
```

**Deliverable:** `feat(ui): create task list view with filtering and search`

---

### TASK 9: Task Row Component (2 hrs)

- [ ] 9.1: Create `Views/Components/TaskRowView.swift`

**Visual design:**
```
┌─────────────────────────────────────────┐
│ [○] Task Title                [!] [📁]  │
│     Due: Today 3:00 PM        [🔁] [🔔] │
│     Project: Work • Design              │
└─────────────────────────────────────────┘
```

**Elements:**
- Animated checkbox
- Task title (strikes through when completed)
- Due date badge (red=overdue, orange=today, blue=upcoming)
- Priority indicator
- Category/project name with color dot
- Tags as pills
- Recurring icon
- Reminder bell icon

**Swipe actions:**
- Right swipe: Complete (green)
- Left swipe: Schedule (blue), Edit (yellow), Delete (red)

- [ ] 9.2: Smooth animations (checkbox, strikethrough, swipe)
- [ ] 9.3: Haptic feedback
- [ ] 9.4: Long press context menu

**Deliverable:** `feat(ui): create polished task row with swipe actions`

---

### TASK 10: Task Editor View (4 hrs)

- [ ] 10.1: Create `Views/iPhone/TaskEditorView.swift`
- [ ] 10.2: Create `ViewModels/TaskEditorViewModel.swift`

**Form fields:**
- Checkbox + Title input
- Multi-line description
- Project picker
- Due date/time picker
- Priority selector (4 buttons)
- Recurrence picker
- Reminder toggles
- Tag multi-select
- Subtask list (inline)
- Delete button

**Features:**
- Auto-save on changes
- Input validation (title required)
- Keyboard shortcuts (⌘S)
- Natural language date parsing ("tomorrow", "next Monday")

- [ ] 10.3: Implement recurrence picker component
- [ ] 10.4: Implement tag selector component
- [ ] 10.5: Implement subtask list component

**Deliverable:** `feat(ui): create full-featured task editor`

---

### TASK 11: Recurring Task Picker (2 hrs)

- [ ] 11.1: Create `Views/Components/RecurrencePicker.swift`

**Options:**
- Never (default)
- Daily (every N days)
- Weekly (select days: Mon, Tue, Wed, etc.)
- Monthly (day X or last day)
- Yearly (month X, day Y)
- Custom...

**End conditions:**
- Never
- On date
- After X occurrences

**Deliverable:** `feat(ui): create recurrence picker component`

---

### TASK 12: Search & Filter UI (2 hrs)

- [ ] 12.1: Create `Views/Components/SearchBar.swift`
- [ ] 12.2: Create `Views/iPhone/FilterView.swift` (slide-up sheet)

**Filter options:**
- Priority (multi-select)
- Projects (multi-select)
- Tags (multi-select)
- Due date range
- Status (active/completed)

- [ ] 12.3: Real-time search (debounced)
- [ ] 12.4: Filter badges in list header

**Deliverable:** `feat(ui): add search and filtering`

---

### TASK 13: Quick Add Task (1.5 hrs)

- [ ] 13.1: Create `Views/Components/QuickAddView.swift`

**Minimal sheet:**
- Title input
- Due date (quick picker: Today, Tomorrow, This Weekend, Next Week)
- Project (quick select)
- Priority (4 buttons)
- [Add] button

- [ ] 13.2: Natural language parsing
  - "Call John tomorrow at 2pm #work !high @urgent"
  - Extract date, project, priority, tags

**Deliverable:** `feat(ui): create quick add task sheet`

---

### TASK 14: Project Management UI (2 hrs)

- [ ] 14.1: Create `Views/iPhone/ProjectListView.swift`
- [ ] 14.2: Create `Views/Components/ProjectEditorView.swift`

**Features:**
- List all categories/projects
- Color-coded with icons
- Task count per project
- Tap to filter tasks
- Add/edit/delete projects
- Color picker (12 colors)
- Icon picker (SF Symbols grid)

**Deliverable:** `feat(ui): create project management views`

---

### TASK 15: Tag Management UI (1.5 hrs)

- [ ] 15.1: Create `Views/iPhone/TagListView.swift`
- [ ] 15.2: Create `Views/Components/TagEditorView.swift`

**Features:**
- List all tags with colors
- Task count per tag
- Create/edit/delete tags
- Multi-select in task editor

**Deliverable:** `feat(ui): create tag management views`

---

### TASK 16: Loading States & Empty States (1.5 hrs)

- [ ] 16.1: Skeleton screens (shimmering placeholder)
- [ ] 16.2: Loading spinner (pull-to-refresh, sync)
- [ ] 16.3: Empty state variations:
  - No tasks yet
  - No results found
  - No tasks today
  - No completed tasks

**Deliverable:** `feat(ui): add loading and empty states`

---

### TASK 17: Animations & Polish (2 hrs)

- [ ] 17.1: Checkbox animation (scale + rotation)
- [ ] 17.2: Task completion animation (fade + strikethrough)
- [ ] 17.3: Swipe action animations
- [ ] 17.4: Delete animation (slide out)
- [ ] 17.5: Add task animation (slide in from bottom)
- [ ] 17.6: List reorder animation
- [ ] 17.7: Tab switch animation (cross-fade)
- [ ] 17.8: Smooth scrolling optimizations

**Deliverable:** `feat(ui): add smooth animations throughout`

---

### TASK 18: Haptic Feedback Integration (1 hr)

Add haptics to:
- Checkbox tap (light)
- Task complete (success)
- Task delete (warning)
- Swipe action (selection)
- Pull-to-refresh trigger (light)
- Button tap (light)
- Error (error)

**Deliverable:** `feat(ui): integrate haptic feedback`

---

### TASK 19: Integrate Services (2 hrs)

- [ ] 19.1: Integrate DataSyncService
  - Pull-to-refresh triggers sync
  - Auto-sync on changes
  - Sync indicator in UI

- [ ] 19.2: Integrate NotificationService
  - Schedule reminders when enabled
  - Cancel when disabled
  - Update badge count

- [ ] 19.3: Integrate RecurrenceEngine
  - Complete recurring task → create next instance
  - Show recurrence info in UI

**Deliverable:** `feat(ui): integrate backend services`

---

### TASK 20: UI Testing (2 hrs)

Create `UITests/iPhoneUITests.swift`:

- [ ] 20.1: Test create task flow
- [ ] 20.2: Test complete task
- [ ] 20.3: Test edit task
- [ ] 20.4: Test delete task
- [ ] 20.5: Test search
- [ ] 20.6: Test filter
- [ ] 20.7: Test tab navigation
- [ ] 20.8: Test swipe actions

**Deliverable:** `test(ui): add UI tests for iPhone interface`

---

### TASK 21: Final Polish & Verification (1 hr)

- [ ] 21.1: Test on iPhone SE (small screen)
- [ ] 21.2: Test on iPhone Pro Max (large screen)
- [ ] 21.3: Test in landscape mode
- [ ] 21.4: Verify all animations smooth (60fps)
- [ ] 21.5: Verify no layout issues
- [ ] 21.6: Test VoiceOver accessibility
- [ ] 21.7: Test Dynamic Type (all sizes)

**Acceptance Criteria:**
- ✅ Beautiful, polished UI
- ✅ Smooth 60fps animations
- ✅ All features working
- ✅ Fully accessible
- ✅ No bugs or crashes

**Deliverable:** `chore: verify iPhone UI and polish`

---

## 📦 Deliverables Summary

### Design System:
- ✅ Complete dark-mode color palette
- ✅ Typography system
- ✅ Spacing & layout constants
- ✅ 10+ reusable components
- ✅ Animation presets
- ✅ Haptic feedback manager

### iPhone Views:
- ✅ Tab navigation
- ✅ Task list view
- ✅ Task row component
- ✅ Task editor
- ✅ Recurrence picker
- ✅ Search & filter
- ✅ Quick add
- ✅ Project management
- ✅ Tag management
- ✅ Loading/empty states

### Polish:
- ✅ Smooth animations everywhere
- ✅ Haptic feedback
- ✅ Service integration
- ✅ UI tests

---

## 🎯 Success Criteria

- [ ] Design system complete and consistent
- [ ] iPhone UI fully functional
- [ ] All animations smooth
- [ ] Services integrated
- [ ] Tests passing
- [ ] Accessible
- [ ] **Looks better than Todoist**

---

## 📞 Handoff

Once complete:
- **Agent 5:** Design system ready - you can use for iPad/Mac layouts

**ESTIMATED COMPLETION TIME: 12-15 hours**

Create something beautiful! 🎨✨
