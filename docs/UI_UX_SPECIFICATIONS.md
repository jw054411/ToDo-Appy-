# UI/UX Specifications

## Design Philosophy

**Core Principles:**
- **Simplicity First:** Clean, uncluttered interface focusing on the task at hand
- **Native Feel:** Platform-specific patterns that feel natural on each device
- **Efficiency:** Quick task entry and management with minimal taps/clicks
- **Visual Hierarchy:** Clear distinction between task states and priorities
- **Accessibility:** Full VoiceOver support, Dynamic Type, high contrast modes

## Design System

### Color Palette

**Primary Colors:**
```swift
// Light Mode
Background: #FFFFFF
Secondary Background: #F5F5F5
Tertiary Background: #EEEEEE

Text Primary: #000000
Text Secondary: #666666
Text Tertiary: #999999

Accent: #007AFF (iOS Blue)
Success: #4CAF50
Warning: #FF9800
Error: #F44336

// Dark Mode
Background: #000000
Secondary Background: #1C1C1E
Tertiary Background: #2C2C2E

Text Primary: #FFFFFF
Text Secondary: #EBEBF5 (60% opacity)
Text Tertiary: #EBEBF5 (30% opacity)

Accent: #0A84FF
Success: #32D74B
Warning: #FF9F0A
Error: #FF453A
```

**Priority Colors:**
```swift
Low: #4CAF50 (Green)
Medium: #FFC107 (Yellow/Amber)
High: #FF9800 (Orange)
Urgent: #F44336 (Red)
```

**Category Colors (Defaults):**
```swift
Personal: #2196F3 (Blue)
Work: #FF9800 (Orange)
Shopping: #4CAF50 (Green)
Health: #F44336 (Red)
Home: #9C27B0 (Purple)
Learning: #00BCD4 (Cyan)
```

### Typography

```swift
// Using SF Pro (System Font)

Title (Large): .largeTitle (34pt, Bold)
Title: .title (28pt, Bold)
Title 2: .title2 (22pt, Bold)
Title 3: .title3 (20pt, Semibold)
Headline: .headline (17pt, Semibold)
Body: .body (17pt, Regular)
Callout: .callout (16pt, Regular)
Subheadline: .subheadline (15pt, Regular)
Footnote: .footnote (13pt, Regular)
Caption: .caption (12pt, Regular)
Caption 2: .caption2 (11pt, Regular)
```

### Spacing System

```swift
// Consistent spacing scale
XXS: 4pt
XS: 8pt
S: 12pt
M: 16pt
L: 24pt
XL: 32pt
XXL: 48pt
```

### Icons

**Icon System:** SF Symbols 5.0+

**Common Icons:**
```swift
Tasks: "checklist"
Add Task: "plus.circle.fill"
Complete: "checkmark.circle.fill"
Incomplete: "circle"
Calendar: "calendar"
Tag: "tag.fill"
Category: "folder.fill"
Priority: "flag.fill"
Search: "magnifyingglass"
Filter: "line.3.horizontal.decrease.circle"
Sort: "arrow.up.arrow.down"
Settings: "gear"
Sync: "arrow.triangle.2.circlepath"
Delete: "trash.fill"
Edit: "pencil"
More: "ellipsis.circle"
```

## Screen Layouts

### iPhone Layout

#### 1. Main Task List (Home)

```
┌─────────────────────────────────────┐
│  [Logo] ToDo Appy        [+ Add]    │ ← Navigation Bar
├─────────────────────────────────────┤
│                                     │
│  🔍 Search tasks...                 │ ← Search Bar
│                                     │
├─────────────────────────────────────┤
│  📋 Today  •  3 tasks               │ ← Smart List
├─────────────────────────────────────┤
│                                     │
│  ○ Buy groceries            🏪      │ ← Task Row
│    Due today at 5:00 PM             │
│                                     │
│  ○ Team meeting             💼      │
│    Due in 2 hours                   │
│                                     │
│  ✓ Morning workout          ❤️      │
│    Completed                        │
│                                     │
├─────────────────────────────────────┤
│  📁 Work  •  5 tasks                │ ← Category Section
├─────────────────────────────────────┤
│                                     │
│  ○ Finish presentation      🔴      │
│    Urgent • Due tomorrow            │
│                                     │
│  ○ Review code PR                   │
│    High • No due date               │
│                                     │
│                                     │
│  [Show 3 more...]                   │
│                                     │
└─────────────────────────────────────┘
│ [Lists] [Today] [Search] [Settings] │ ← Tab Bar
└─────────────────────────────────────┘
```

**Task Row Component:**
```
┌─────────────────────────────────────────────┐
│ ○  Buy groceries                      🏪    │
│    🗓 Today 5:00 PM • 🏷 groceries          │
│                                  [⋯ More]   │
└─────────────────────────────────────────────┘

Left: Completion circle
Center: Title, metadata (due date, tags)
Right: Category icon, more actions
```

#### 2. Task Detail/Edit Screen

```
┌─────────────────────────────────────┐
│  [< Back]              [Done]       │
├─────────────────────────────────────┤
│                                     │
│  ○  [Task Title Field]              │
│     Buy groceries for dinner        │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                     │
│  📝 Notes                           │
│  [Text editor...]                   │
│  Remember to get vegetables         │
│  and fruit                          │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                     │
│  🗓  Due Date                       │
│  Today at 5:00 PM          [Edit]   │
│                                     │
│  🔔 Reminder                        │
│  1 hour before             [Edit]   │
│                                     │
│  🚩 Priority                        │
│  Medium                    [Edit]   │
│                                     │
│  📁 Category                        │
│  Shopping                  [Edit]   │
│                                     │
│  🏷  Tags                           │
│  groceries, dinner         [Edit]   │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                     │
│  ✅ Subtasks (2 of 5)               │
│  ✓ Make shopping list               │
│  ○ Check pantry                     │
│  ○ Get reusable bags                │
│  [+ Add Subtask]                    │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                     │
│  [Delete Task]                      │
│                                     │
└─────────────────────────────────────┘
```

#### 3. Add/Quick Entry Sheet

```
┌─────────────────────────────────────┐
│         New Task                    │
│                           [Cancel]  │
├─────────────────────────────────────┤
│                                     │
│  [Task title...]                    │
│                                     │
│  🗓 [Due Date]  🚩 [Priority]       │
│                                     │
│  📁 [Category]  🏷 [Tags]           │
│                                     │
│              [Create]               │
│              [+ More Details]       │
│                                     │
└─────────────────────────────────────┘
```

#### 4. Categories/Lists View

```
┌─────────────────────────────────────┐
│  Lists                 [+ New]      │
├─────────────────────────────────────┤
│                                     │
│  📋 SMART LISTS                     │
│                                     │
│  📅 Today              3 →          │
│  ⭐ Important          5 →          │
│  📆 Upcoming           8 →          │
│  ✓  Completed         24 →          │
│  📥 All Tasks         40 →          │
│                                     │
│  📁 MY LISTS                        │
│                                     │
│  💼 Work              12 →          │
│  🏠 Personal           5 →          │
│  🛒 Shopping           3 →          │
│  ❤️  Health            2 →          │
│  📚 Learning           4 →          │
│                                     │
│  [+ Add New List]                   │
│                                     │
└─────────────────────────────────────┘
```

#### 5. Settings Screen

```
┌─────────────────────────────────────┐
│  [< Back]  Settings                 │
├─────────────────────────────────────┤
│                                     │
│  👤 ACCOUNT                         │
│  iCloud Sync          [✓ On]        │
│  john@example.com                   │
│  Last synced: 2 min ago             │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                     │
│  📱 PREFERENCES                     │
│  Default Category     [Personal →]  │
│  Default Priority     [Medium →]    │
│  Default Reminder     [None →]      │
│  Start of Week        [Monday →]    │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                     │
│  🔔 NOTIFICATIONS                   │
│  Allow Notifications  [✓ On]        │
│  Badge Icon           [✓ On]        │
│  Sound                [Default →]   │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                     │
│  🎨 APPEARANCE                      │
│  Theme                [System →]    │
│  App Icon             [Default →]   │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                     │
│  📊 DATA                            │
│  Export Data          [→]           │
│  Import Data          [→]           │
│  Clear Completed      [→]           │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                     │
│  ℹ️  ABOUT                          │
│  Version 1.0.0                      │
│  Privacy Policy       [→]           │
│  Support              [→]           │
│                                     │
└─────────────────────────────────────┘
```

### iPad Layout

#### Split View (Landscape)

```
┌──────────────────────────────────────────────────────────────────┐
│  [≡] ToDo Appy                                  [+ Add] [Search]  │
├────────────────┬────────────────────┬────────────────────────────┤
│                │                    │                            │
│  SMART LISTS   │  Today             │   Buy groceries            │
│  📅 Today   3  │  3 tasks           │                            │
│  ⭐ Important  │                    │   ○ [Complete]             │
│  📆 Upcoming   │  ○ Buy groceries   │                            │
│                │    Due 5:00 PM     │   📝 Notes                 │
│  MY LISTS      │                    │   Remember to get...       │
│  💼 Work    12 │  ○ Team meeting    │                            │
│  🏠 Personal 5 │    Due in 2 hrs    │   🗓  Due Date             │
│  🛒 Shopping 3 │                    │   Today at 5:00 PM         │
│  ❤️  Health  2 │  ✓ Morning workout │                            │
│  📚 Learning 4 │    Completed       │   🚩 Priority              │
│                │                    │   Medium                   │
│  TAGS          │                    │                            │
│  🏷 urgent     │                    │   📁 Category              │
│  🏷 work       │                    │   Shopping                 │
│  🏷 personal   │                    │                            │
│                │                    │   ✅ Subtasks (0/3)        │
│                │  [Sort ▼] [⋯]      │   ○ Make shopping list     │
│                │                    │   [+ Add Subtask]          │
│                │                    │                            │
│  [+ New List]  │                    │   [Delete Task]            │
│                │                    │                            │
│  Sidebar       │  List View         │   Detail View              │
│  (280pt)       │  (320pt)           │   (Remaining)              │
└────────────────┴────────────────────┴────────────────────────────┘
```

### macOS Layout

#### Main Window

```
┌────────────────────────────────────────────────────────────────────┐
│  ●●●  ToDo Appy           [🔍]              [+ Add Task]  [⚙️]     │
├────────────────┬──────────────────────┬────────────────────────────┤
│                │                      │                            │
│  SMART LISTS   │  📅 Today • 3 tasks  │   Buy groceries            │
│  📅 Today   3  │  ┌─────────────────  │                            │
│  ⭐ Important  │  │ 🗓 Sort: Due Date │   ☐ Mark Complete          │
│  📆 Upcoming   │  │ 🔽 Filter: All    │                            │
│  ✓  Completed  │  └─────────────────  │   📝 Notes                 │
│  📥 All        │                      │   ┌──────────────────────  │
│                │  Task List:          │   │ Remember to get fresh  │
│  MY LISTS      │                      │   │ vegetables and fruit   │
│  💼 Work    12 │  ☐ Buy groceries     │   └──────────────────────  │
│  🏠 Personal 5 │     🛒 Shopping       │                            │
│  🛒 Shopping 3 │     Due today 5 PM   │   🗓  Due Date             │
│  ❤️  Health  2 │     [Edit] [⋯]       │   Today at 5:00 PM  [📅]  │
│  📚 Learning 4 │                      │                            │
│                │  ☐ Team meeting      │   🔔 Reminder              │
│  TAGS          │     💼 Work           │   4:00 PM (1h before) [🔔] │
│  #urgent    2  │     Due in 2 hours   │                            │
│  #work      8  │     [Edit] [⋯]       │   🚩 Priority              │
│  #personal  5  │                      │   ○ Low ◉ Medium ○ High    │
│                │  ☑ Morning workout   │                            │
│                │     ❤️ Health         │   📁 Category              │
│  [+ New List]  │     Completed        │   🛒 Shopping         [▼]  │
│  [+ New Tag]   │     [Delete]         │                            │
│                │                      │   🏷  Tags                 │
│                │  [Show 10 more...]   │   groceries, dinner   [+]  │
│                │                      │                            │
│                │                      │   ✅ Subtasks (0/3)        │
│  Sidebar       │  List Pane           │   ☐ Make shopping list     │
│  (240pt min)   │  (300pt min)         │   ☐ Check pantry           │
│                │                      │   ☐ Get reusable bags      │
│                │                      │   [+ Add Subtask]          │
│                │                      │                            │
│                │                      │   Created: Nov 15, 2025    │
│                │                      │   Modified: Nov 15, 2025   │
│                │                      │                            │
│                │                      │   [⌫ Delete Task]          │
│                │                      │                            │
└────────────────┴──────────────────────┴────────────────────────────┘
```

#### Menu Bar

```
ToDo Appy
├── New Task (⌘N)
├── New List (⌘L)
├── ──────────
├── Settings (⌘,)
├── ──────────
├── Quit (⌘Q)

File
├── New Task (⌘N)
├── New List (⌘L)
├── ──────────
├── Export... (⌘E)
├── Import...
├── ──────────
├── Close Window (⌘W)

Edit
├── Undo (⌘Z)
├── Redo (⌘⇧Z)
├── ──────────
├── Cut (⌘X)
├── Copy (⌘C)
├── Paste (⌘V)
├── ──────────
├── Find (⌘F)
├── Find Next (⌘G)

View
├── Show Sidebar (⌘⌥S)
├── Show Detail (⌘⌥D)
├── ──────────
├── Sort By
│   ├── Due Date
│   ├── Priority
│   ├── Title
│   └── Created Date
├── Filter
│   ├── All Tasks
│   ├── Active
│   └── Completed
├── ──────────
├── Refresh (⌘R)

Task
├── Mark Complete (⌘K)
├── Set Due Date (⌘D)
├── Set Priority (⌘P)
├── Add Tag (⌘T)
├── ──────────
├── Delete (⌘⌫)

Window
├── Minimize (⌘M)
├── Zoom
├── ──────────
├── Bring All to Front

Help
├── ToDo Appy Help
├── ──────────
├── Report Issue
└── Privacy Policy
```

## Interactions & Animations

### Gestures (iOS/iPadOS)

**Swipe Actions on Task Row:**
```
← Left Swipe:
  [✓ Complete] [🗓 Schedule] [🗑 Delete]

→ Right Swipe:
  [📝 Edit] [🏷 Tag]
```

**Long Press:**
- Quick Actions Menu
- Drag to reorder (when sorting manually)

**Pull to Refresh:**
- Pull down on task list to sync with iCloud

**Pinch to Zoom:**
- (Future) Adjust text size locally

### Animations

**Task Completion:**
```swift
- Checkbox: Scale + fade to checkmark (0.3s, ease-in-out)
- Row: Fade opacity to 50% (0.2s, linear)
- Strikethrough: Animate from left to right (0.3s, ease-out)
- (Optional) Confetti effect for important tasks
```

**Task Creation:**
```swift
- Sheet slides up from bottom (iOS) or appears as modal (macOS)
- Spring animation (0.4s, spring dampening)
```

**Delete Animation:**
```swift
- Row slides out and fades (0.3s, ease-in)
- Remaining rows animate up to fill gap (0.2s, ease-out)
- Show undo toast for 5 seconds
```

**Sync Indicator:**
```swift
- Rotate continuously when syncing
- Fade in/out (0.2s)
- Color: Accent blue
```

### Keyboard Shortcuts (macOS/iPad)

```
Global:
⌘N - New Task
⌘F - Search
⌘, - Settings
⌘R - Refresh/Sync
⌘W - Close Window

Task Actions:
⌘K - Mark Complete
⌘D - Set Due Date
⌘P - Set Priority
⌘T - Add Tag
⌘⌫ - Delete Task

Navigation:
⌘1-9 - Switch between lists
↑↓ - Navigate tasks
⌘↑↓ - Move to first/last task
Return - Edit selected task
Space - Quick preview
Esc - Close detail/editor
```

## Accessibility

### VoiceOver Support

**Labels:**
```swift
// Task Row
"Buy groceries, incomplete, due today at 5 PM, shopping category, groceries tag"

// Complete Button
"Mark Buy groceries as complete"

// Priority Button
"Priority: Medium. Double tap to change"
```

**Hints:**
```swift
"Double tap to mark complete"
"Double tap to edit task"
"Swipe up or down to adjust priority"
```

### Dynamic Type

- Support all system text sizes
- Ensure UI adapts for larger text
- Maintain readability at all sizes
- Test at accessibility sizes (AX1-AX5)

### Color Contrast

- All text meets WCAG AAA standards (7:1 contrast)
- Priority colors have sufficient contrast
- High contrast mode support
- Test with Color Blindness simulator

### Reduce Motion

- Disable parallax effects
- Use fade instead of scale animations
- Remove confetti/celebration animations
- Instant transitions option

## Dark Mode

**Automatic Switching:**
- Follow system appearance by default
- Option to override in settings

**Dark Mode Colors:**
- Pure black backgrounds (#000000) for OLED
- Elevated surfaces use dark gray (#1C1C1E, #2C2C2E)
- Increase accent color brightness
- Reduce image/icon opacity slightly

## Empty States

### No Tasks
```
┌─────────────────────────────────────┐
│                                     │
│          ✨                         │
│                                     │
│     All Clear!                      │
│                                     │
│     No tasks for today.             │
│     Tap + to add a new task.        │
│                                     │
│          [+ Add Task]               │
│                                     │
└─────────────────────────────────────┘
```

### No Results (Search)
```
┌─────────────────────────────────────┐
│                                     │
│          🔍                         │
│                                     │
│     No Results                      │
│                                     │
│     No tasks found for "meeting"    │
│     Try a different search term.    │
│                                     │
└─────────────────────────────────────┘
```

### No Lists
```
┌─────────────────────────────────────┐
│                                     │
│          📋                         │
│                                     │
│     No Custom Lists                 │
│                                     │
│     Create lists to organize        │
│     your tasks by project or area.  │
│                                     │
│          [+ New List]               │
│                                     │
└─────────────────────────────────────┘
```

## Loading States

### Sync in Progress
```
┌─────────────────────────────────────┐
│  [↻ Syncing...]                     │
├─────────────────────────────────────┤
│  (Show skeleton loaders for tasks)  │
└─────────────────────────────────────┘
```

### Initial Load
```
┌─────────────────────────────────────┐
│                                     │
│          ○○○○○                      │
│                                     │
│     Loading your tasks...           │
│                                     │
└─────────────────────────────────────┘
```

## Error States

### Sync Error
```
┌─────────────────────────────────────┐
│  ⚠️  Sync Error                     │
│  Unable to sync with iCloud.        │
│  [Retry] [Dismiss]                  │
└─────────────────────────────────────┘
```

### Network Offline
```
┌─────────────────────────────────────┐
│  📡 Offline                         │
│  Changes will sync when online.     │
│  [Dismiss]                          │
└─────────────────────────────────────┘
```

## Widgets

### Small Widget (iOS/iPadOS)
```
┌──────────────────┐
│  Today           │
│                  │
│  ○ Buy groceries │
│  ○ Team meeting  │
│  ✓ Workout       │
│                  │
│  3 tasks         │
└──────────────────┘
```

### Medium Widget
```
┌─────────────────────────────────────┐
│  📅 Today • 3 tasks                 │
│                                     │
│  ○ Buy groceries         Due 5 PM   │
│  ○ Team meeting          Due 2 hrs  │
│  ✓ Morning workout       Completed  │
│                                     │
│  [+ Quick Add]                      │
└─────────────────────────────────────┘
```

### Large Widget
```
┌─────────────────────────────────────┐
│  📅 Today • 3 tasks                 │
│                                     │
│  ○ Buy groceries                    │
│    🛒 Shopping • Due today 5:00 PM  │
│                                     │
│  ○ Team meeting                     │
│    💼 Work • Due in 2 hours         │
│                                     │
│  ✓ Morning workout                  │
│    ❤️ Health • Completed            │
│                                     │
│  📋 Work • 5 tasks                  │
│  ○ Finish presentation              │
│  ○ Review code PR                   │
│                                     │
│  [+ Add Task]                       │
└─────────────────────────────────────┘
```

## Future Enhancements

### Apple Watch Complications
- Show task count for today
- Quick glance at next task
- Mark complete via Siri

### Lock Screen Widgets (iOS 16+)
- Circular: Task count
- Rectangular: Next task
- Inline: "3 tasks today"

### Live Activities (iOS 16+)
- Track timer for time-sensitive tasks
- Show countdown to due time

---

**Last Updated:** 2025-11-15
