# Agent 5: Multi-Platform UI & Deployment Specialist

**Role:** Build iPad and Mac interfaces, create widgets, handle settings, and deploy to App Store.

**Start:** After Agent 4 completes design system
**Depends On:** Agent 1 (project), Agent 2 (models), Agent 4 (design system)
**Works in Parallel With:** Agent 3
**Estimated Time:** 10-12 hours

---

## 🎯 Mission
Extend the app to iPad and Mac with platform-specific interfaces, create beautiful widgets, build settings, and ship to the App Store. Make it work seamlessly across all Apple devices.

---

## ✅ TODO List

### TASK 1: Pull Code & Verify Setup (10 min)

- [ ] 1.1: Pull latest code
- [ ] 1.2: Verify Agent 4's design system present
- [ ] 1.3: Test iPhone UI works
- [ ] 1.4: Ready for multi-platform

---

### TASK 2: iPad Split View Layout (3 hrs)

- [ ] 2.1: Create `Views/iPad/iPadMainView.swift`

**Layout (2-column):**
```
┌─────────────┬──────────────────────┐
│  SIDEBAR    │   TASK LIST          │
│  (300pt)    │   (remainder)        │
│             │                      │
│  Inbox      │  Tasks view          │
│  Today      │  (reuse from iPhone) │
│  Upcoming   │                      │
│  Projects   │                      │
│  Tags       │                      │
└─────────────┴──────────────────────┘
```

- [ ] 2.2: Sidebar navigation
  - Smart lists (Inbox, Today, Upcoming)
  - Projects section (expandable)
  - Tags section (expandable)
  - + New button at bottom

- [ ] 2.3: Reuse iPhone TaskListView in detail pane
- [ ] 2.4: Responsive layout (portrait/landscape)
- [ ] 2.5: Collapsible sidebar

**Optional: 3-column layout (sidebar + list + detail):**
- Show task editor in 3rd column instead of sheet

- [ ] 2.6: Multi-select with Shift+Click
- [ ] 2.7: Drag & drop tasks to projects

**Deliverable:** `feat(ipad): create split view layout`

---

### TASK 3: Mac 3-Pane Layout (4 hrs)

- [ ] 3.1: Create `Views/Mac/MacMainView.swift`

**Layout:**
```
┌──────────────────────────────────────────────┐
│  File  Edit  View  Task  Window  Help       │
│  ────────────────────────────────────────    │
│  [+ New]  [Search...]  [Filter]  [Sync]     │
├──────────┬──────────────┬──────────────────┤
│ SIDEBAR  │  TASK LIST   │  TASK DETAIL     │
│ (200pt)  │  (300pt)     │  (remainder)     │
└──────────┴──────────────┴──────────────────┘
```

- [ ] 3.2: Menu bar integration
  - File: New Task (⌘N), Import, Export, Close (⌘W), Quit (⌘Q)
  - Edit: Undo, Redo, Cut, Copy, Paste, Select All
  - View: Show/Hide Sidebar, Show Completed, Refresh
  - Task: New Task, Complete, Delete, Duplicate
  - Window: Minimize, Zoom
  - Help: Documentation, Send Feedback

- [ ] 3.3: Toolbar with buttons
  - Standardized Mac toolbar
  - Customizable button set

- [ ] 3.4: 3-pane layout with splitters
- [ ] 3.5: Window state persistence (size, position)

**Deliverable:** `feat(mac): create 3-pane layout with menu bar`

---

### TASK 4: Keyboard Shortcuts (Mac/iPad) (2 hrs)

- [ ] 4.1: Create `Utilities/KeyboardShortcuts.swift`

**Essential shortcuts:**
```
⌘N          New Task
⌘F          Search
⌘,          Preferences
Space       Complete/Uncomplete
Delete      Delete task
⌘↑/↓        Navigate tasks
⌘1..5       Switch tabs/lists
⌘R          Refresh/Sync
⌘Z          Undo
⌘⇧Z         Redo
⌘A          Select all
⌘T          Set due date to today
⌘1..4       Set priority
⌘W          Close window
⌘Q          Quit
```

- [ ] 4.2: Implement in SwiftUI with `.keyboardShortcut()`
- [ ] 4.3: Show shortcuts in menus
- [ ] 4.4: Keyboard shortcut overlay (hold ⌘)

**Deliverable:** `feat(shortcuts): add 30+ keyboard shortcuts for Mac/iPad`

---

### TASK 5: Drag & Drop (2 hrs)

- [ ] 5.1: Drag task to reorder in list
- [ ] 5.2: Drag task to project in sidebar (change category)
- [ ] 5.3: Drag task to tag (add tag)
- [ ] 5.4: Drag multiple tasks (multi-select first)
- [ ] 5.5: Visual feedback during drag
- [ ] 5.6: Haptic feedback on drop (iPad)

**Mac-specific:**
- [ ] 5.7: Drag task to Calendar.app (create event)
- [ ] 5.8: Drag task to Reminders.app
- [ ] 5.9: Drag text from other apps → create task

**Deliverable:** `feat(interaction): add drag & drop support`

---

### TASK 6: Widgets (3 hrs)

Create Widget Extension target in Xcode.

#### Widget 1: Small (Task Count)
- [ ] 6.1: Create `Widgets/TaskCountWidget.swift`
```
┌─────────────┐
│  ToDo-Appy  │
│      5      │
│   Tasks Due │
│   3 Overdue │
└─────────────┘
```

#### Widget 2: Medium (Task List)
- [ ] 6.2: Create `Widgets/TaskListWidget.swift`
```
┌────────────────────────────┐
│  ToDo-Appy          Today  │
│  ○ Task 1           3:00PM │
│  ○ Task 2           5:00PM │
│  ○ Task 3        Tomorrow  │
│  + 8 more                  │
└────────────────────────────┘
```

#### Widget 3: Large (Full Overview)
- [ ] 6.3: Create `Widgets/OverviewWidget.swift`
```
┌─────────────────────────────────┐
│  ToDo-Appy                      │
│  OVERDUE (2)                    │
│  ○ Task 1                       │
│  TODAY (5)                      │
│  ○ Task 2              3:00 PM  │
│  ○ Task 3              5:00 PM  │
│  UPCOMING (12)                  │
│  ○ Task 4           Tomorrow    │
│  [View All]                     │
└─────────────────────────────────┘
```

- [ ] 6.4: Widget timeline provider (updates every 15 min)
- [ ] 6.5: Deep links to app
- [ ] 6.6: Dark mode styling

**Deliverable:** `feat(widgets): add small, medium, and large widgets`

---

### TASK 7: Settings Screen (2 hrs)

- [ ] 7.1: Create `Views/iPhone/SettingsView.swift`

**Settings sections:**
```
APPEARANCE
- Accent Color (Blue, Purple, Pink, Orange)
- App Icon (Default, Minimal, Gradient)

TASKS
- Default Project (picker)
- Default Priority (picker)
- Auto-complete parent when all subtasks done (toggle)
- Confirm before delete (toggle)

REMINDERS
- Default reminder offset (15min, 1hr, 1day)
- Notification sound (picker)
- Badge count (Today, All, None)

SYNC
- Auto-sync (toggle)
- Sync frequency (5min, 15min, 30min, Manual)
- Last synced: X minutes ago
- [Sync Now] button
- iCloud status indicator

DATA
- [Export All Data (JSON)]
- [Export Tasks (CSV)]
- [Import Data]
- [Clear Completed Tasks]
- Storage used: 2.4 MB

ABOUT
- Version: 1.0.0
- [Privacy Policy]
- [Terms of Service]
- [Keyboard Shortcuts]
- [Send Feedback]
- [Rate on App Store]
```

- [ ] 7.2: Integrate ImportExportService for data export/import
- [ ] 7.3: UserDefaults for settings persistence
- [ ] 7.4: iCloud sync status (connected, syncing, error)

**Deliverable:** `feat(settings): create comprehensive settings screen`

---

### TASK 8: Alternate App Icons (1 hr)

- [ ] 8.1: Design 3 app icons (or use variations)
  - Default (checkmark in circle, blue)
  - Minimal (simple check, black/white)
  - Gradient (colorful gradient background)

- [ ] 8.2: Add to Assets catalog
- [ ] 8.3: Implement icon switching in settings
```swift
UIApplication.shared.setAlternateIconName("MinimalIcon") { error in
    if let error = error {
        print("Error changing icon: \(error)")
    }
}
```

**Deliverable:** `feat(settings): add alternate app icons`

---

### TASK 9: App Icon & Launch Screen (1 hr)

- [ ] 9.1: Design app icon
  - Simple checkmark in circle
  - Dark background (black or dark blue)
  - Vibrant accent (blue/purple)
  - All sizes (1024×1024 master)

- [ ] 9.2: Create launch screen
  - App icon centered
  - Dark background
  - Smooth transition to main screen

- [ ] 9.3: Generate all required sizes
  - iPhone, iPad, Mac icons
  - App Store icon

**Deliverable:** `feat(assets): create app icon and launch screen`

---

### TASK 10: Advanced Features (2 hrs)

#### Batch Operations
- [ ] 10.1: Create `Views/Components/SelectionBar.swift`
- [ ] 10.2: Multi-select mode
- [ ] 10.3: Batch complete, reschedule, delete, change project

#### Subtasks UI
- [ ] 10.4: Create `Views/Components/SubtaskListView.swift`
- [ ] 10.5: Inline subtask editing in task editor
- [ ] 10.6: Progress bar (X of Y completed)
- [ ] 10.7: Expandable subtasks in task row

#### Projects/Subprojects
- [ ] 10.8: Hierarchical project structure (project → subproject)
- [ ] 10.9: Indent subprojects in sidebar
- [ ] 10.10: Drag projects to nest them

**Deliverable:** `feat(advanced): add batch operations, subtasks, and hierarchical projects`

---

### TASK 11: Testing & Polish (2 hrs)

- [ ] 11.1: Test on iPad (multiple sizes)
- [ ] 11.2: Test on Mac (different screen sizes)
- [ ] 11.3: Test widgets on home screen
- [ ] 11.4: Test keyboard shortcuts
- [ ] 11.5: Test drag & drop
- [ ] 11.6: Test export/import
- [ ] 11.7: Verify accessibility (VoiceOver, Dynamic Type)
- [ ] 11.8: Performance testing (large datasets)

**Deliverable:** `test(multiplatform): verify iPad, Mac, and widgets`

---

### TASK 12: App Store Assets (2 hrs)

- [ ] 12.1: Create screenshots (all device sizes)
  - iPhone 6.9", 6.7", 6.5"
  - iPad Pro 13", 12.9"
  - Mac

- [ ] 12.2: Create App Preview video (optional, 30sec max)
  - Show creating a task
  - Show completing tasks
  - Show projects and organization
  - Show sync across devices

- [ ] 12.3: Write App Store description
```
ToDo-Appy: Your Private, Free Task Manager

Never miss a task. Stay organized. Own your data.

FEATURES:
• Beautiful dark mode interface
• Projects and subprojects for organization
• Tags for flexible categorization
• Recurring tasks (daily, weekly, monthly, yearly)
• Smart reminders
• Subtasks and dependencies
• Powerful search and filtering
• Widgets for quick access

PRIVACY-FIRST:
• All data in YOUR private iCloud
• No third-party servers
• No tracking, no ads
• Your data belongs to you

SEAMLESS SYNC:
• Automatic sync across iPhone, iPad, and Mac
• Works offline, syncs when online
• Real-time updates across devices

COMPLETELY FREE:
• No subscriptions
• No in-app purchases
• No ads, ever

100% Native Apple Experience:
• SwiftUI interface
• Keyboard shortcuts
• Drag & drop support
• VoiceOver accessible
• Handoff between devices

More reliable than Todoist, more private, completely free.
```

- [ ] 12.4: Keywords: "todo, task manager, productivity, free, private, icloud, gtd, projects"
- [ ] 12.5: Support URL, Marketing URL
- [ ] 12.6: Privacy policy (simple: "All data stored in your private iCloud. We don't collect any data.")

**Deliverable:** `docs: create App Store marketing materials`

---

### TASK 13: App Store Connect Setup (1 hr)

- [ ] 13.1: Create app in App Store Connect
- [ ] 13.2: Fill in app information
  - Name: ToDo-Appy
  - Subtitle: Private, Free Task Manager
  - Category: Productivity
  - Age rating: 4+

- [ ] 13.3: Upload screenshots
- [ ] 13.4: Upload app preview video (if created)
- [ ] 13.5: Set pricing (Free)
- [ ] 13.6: App Store description

**Deliverable:** `chore: configure App Store Connect listing`

---

### TASK 14: TestFlight Beta (1 hr + 1-2 weeks testing)

- [ ] 14.1: Create archive in Xcode
  - Product → Archive
  - Version: 1.0.0, Build: 1

- [ ] 14.2: Upload to App Store Connect
  - Distribute App → App Store Connect
  - Wait for processing (~30 min)

- [ ] 14.3: Create TestFlight beta
  - Internal testers: Immediate access
  - External testers: Beta App Review required

- [ ] 14.4: Invite 10-50 beta testers
- [ ] 14.5: Collect feedback for 1-2 weeks
- [ ] 14.6: Fix bugs, release updated builds

**Critical testing:**
- Sync across multiple devices
- Offline mode
- Notifications
- Recurring tasks
- Import/export
- Performance with 1000+ tasks

**Deliverable:** `chore: launch TestFlight beta`

---

### TASK 15: App Store Submission (1 hr + review time)

- [ ] 15.1: Final pre-flight checklist
  - All features complete
  - No known critical bugs
  - Privacy manifest (if required)
  - Export compliance (No for this app)

- [ ] 15.2: Submit for review
  - Click "Submit for Review"
  - Answer questions
  - Review notes: "Private to-do list app using CloudKit for sync. All data stored in user's private iCloud, no third-party servers."

- [ ] 15.3: Wait for review (24-48 hours typical)
- [ ] 15.4: Fix any issues if rejected
- [ ] 15.5: Once approved → Release!

- [ ] 15.6: Post-launch monitoring
  - Monitor crash reports
  - Respond to reviews
  - Plan updates

**Deliverable:** `chore: submit to App Store and launch 🚀`

---

## 📦 Deliverables Summary

### Multi-Platform UI:
- ✅ iPad split view layout
- ✅ Mac 3-pane layout with menu bar
- ✅ Keyboard shortcuts (30+)
- ✅ Drag & drop support

### Widgets:
- ✅ Small widget (task count)
- ✅ Medium widget (task list)
- ✅ Large widget (overview)

### Features:
- ✅ Settings screen
- ✅ Import/export UI
- ✅ Batch operations
- ✅ Subtasks UI
- ✅ Hierarchical projects/subprojects
- ✅ Alternate app icons

### Deployment:
- ✅ App icon & launch screen
- ✅ App Store assets (screenshots, description)
- ✅ TestFlight beta
- ✅ App Store submission
- ✅ **Live on App Store!**

---

## 🎯 Success Criteria

- [ ] Works perfectly on iPhone, iPad, Mac
- [ ] Widgets functional and beautiful
- [ ] All keyboard shortcuts work
- [ ] Drag & drop smooth
- [ ] Settings complete with export/import
- [ ] TestFlight tested thoroughly
- [ ] App Store approved and live
- [ ] **Better than Todoist, completely free!**

---

## 📞 Final Handoff

Once complete:
- **Users:** Download from App Store!
- **Team:** App is live, monitor feedback and plan v1.1

**ESTIMATED COMPLETION TIME: 10-12 hours**

Ship it! 🚀📱💻
