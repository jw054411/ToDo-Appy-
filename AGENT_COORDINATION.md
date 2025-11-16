# Agent Coordination Guide

## 🎯 Mission
Build a **private, free, Todoist alternative** for Apple devices with automatic iCloud backup, dark mode only, and slick UI.

---

## 👥 5-Agent Team Structure

### **Agent 1: Foundation & Setup Specialist**
**Role:** Initialize Xcode project, configure CloudKit, set up structure
**Time:** 4-6 hours
**Blocks:** ALL other agents (must go first)
**Files:** `AGENT_1_FOUNDATION.md`

### **Agent 2: Data Models & Business Logic Specialist**
**Role:** Create SwiftData models, implement recurring task engine
**Time:** 8-10 hours
**Depends On:** Agent 1
**Blocks:** Agent 3, Agent 4
**Files:** `AGENT_2_DATA_MODELS.md`

### **Agent 3: Services & Sync Specialist**
**Role:** Build CloudKit sync, notifications, import/export, ensure data safety
**Time:** 10-12 hours
**Depends On:** Agent 1, Agent 2
**Works in Parallel With:** Agent 4, Agent 5
**Files:** `AGENT_3_SERVICES_SYNC.md`

### **Agent 4: Design System & iPhone UI Specialist**
**Role:** Create design system and build complete iPhone interface
**Time:** 12-15 hours
**Depends On:** Agent 1, Agent 2
**Works in Parallel With:** Agent 3, Agent 5
**Files:** `AGENT_4_DESIGN_UI.md`

### **Agent 5: Multi-Platform UI & Deployment Specialist**
**Role:** Build iPad/Mac UI, widgets, settings, deploy to App Store
**Time:** 10-12 hours
**Depends On:** Agent 1, Agent 2, Agent 4 (design system)
**Works in Parallel With:** Agent 3
**Files:** `AGENT_5_MULTIPLATFORM_DEPLOY.md`

---

## 📊 Development Timeline

```
Week 1:
Day 1:    Agent 1 completes foundation (4-6 hrs)
Day 2-3:  Agent 2 builds models (8-10 hrs)

Week 2 (Parallel Development):
Day 4-5:  Agent 3 builds services    (10-12 hrs)  ┐
Day 4-6:  Agent 4 builds iPhone UI   (12-15 hrs)  ├─ IN PARALLEL
Day 5-6:  Agent 5 builds iPad/Mac    (10-12 hrs)  ┘

Week 3-4:
Day 7-10: Integration testing (all agents)
Day 11-14: TestFlight beta testing
Day 15+:  App Store review (24-48 hrs)

TOTAL: ~2-3 weeks to App Store
```

---

## 🔄 Dependencies Graph

```
Agent 1 (Foundation)
    ↓
Agent 2 (Data Models)
    ↓
    ├─→ Agent 3 (Services) ──┐
    ├─→ Agent 4 (iPhone UI) ──┼─→ Agent 5 (Multi-Platform)
    └─────────────────────────┘
```

**Critical Path:**
Agent 1 → Agent 2 → Agent 4 (design system) → Agent 5 → Deployment

**Can run in parallel:**
- Agent 3 + Agent 4 (after Agent 2 done)
- Agent 3 + Agent 5 (after Agent 4 design system done)

---

## 📁 File Structure

```
ToDo-Appy/
├── App/
│   ├── ToDoAppyApp.swift              [Agent 1, updated by all]
│   └── AppDelegate.swift              [Agent 1, updated by Agent 3]
│
├── Models/                            [Agent 2]
│   ├── Task.swift
│   ├── Category.swift
│   ├── Tag.swift
│   ├── RecurrenceRule.swift
│   ├── Protocols/
│   │   └── Syncable.swift             [Agent 1]
│   └── Enums/
│       ├── SyncStatus.swift           [Agent 1]
│       ├── Priority.swift             [Agent 1]
│       └── RecurrenceType.swift       [Agent 1]
│
├── ViewModels/                        [Agent 4]
│   ├── TaskListViewModel.swift
│   └── TaskEditorViewModel.swift
│
├── Views/
│   ├── ContentView.swift              [Agent 1, placeholder]
│   ├── iPhone/                        [Agent 4]
│   │   ├── MainTabView.swift
│   │   ├── TaskListView.swift
│   │   ├── TaskEditorView.swift
│   │   ├── ProjectListView.swift
│   │   ├── TagListView.swift
│   │   ├── FilterView.swift
│   │   └── SettingsView.swift         [Agent 5]
│   ├── iPad/                          [Agent 5]
│   │   └── iPadMainView.swift
│   ├── Mac/                           [Agent 5]
│   │   └── MacMainView.swift
│   └── Components/                    [Agent 4]
│       ├── TaskRowView.swift
│       ├── RecurrencePicker.swift
│       ├── QuickAddView.swift
│       ├── SearchBar.swift
│       ├── SubtaskListView.swift      [Agent 5]
│       └── ... (10+ components)
│
├── Services/                          [Agent 3]
│   ├── DataSyncService.swift
│   ├── SyncQueue.swift
│   ├── NotificationService.swift
│   ├── ImportExportService.swift
│   ├── NetworkMonitor.swift
│   ├── DataManager.swift
│   ├── RecurrenceEngine.swift         [Agent 2]
│   └── DataSeeder.swift               [Agent 2]
│
├── DesignSystem/                      [Agent 4]
│   ├── Colors.swift
│   ├── Typography.swift
│   ├── Spacing.swift
│   ├── Animations.swift
│   └── Components/
│       ├── AppButton.swift
│       ├── AppCard.swift
│       ├── CheckboxView.swift
│       └── ... (10 components)
│
├── Utilities/                         [Mixed]
│   ├── KeyboardShortcuts.swift        [Agent 5]
│   ├── HapticManager.swift            [Agent 4]
│   └── Extensions/
│       ├── Date+Extensions.swift      [Agent 1]
│       └── Color+Extensions.swift     [Agent 2]
│
├── Widgets/                           [Agent 5]
│   ├── TaskCountWidget.swift
│   ├── TaskListWidget.swift
│   └── OverviewWidget.swift
│
├── Tests/                             [All agents test their work]
│   ├── ModelTests.swift               [Agent 2]
│   ├── RecurrenceEngineTests.swift    [Agent 2]
│   ├── ServiceTests.swift             [Agent 3]
│   └── CloudKitConversionTests.swift  [Agent 2]
│
├── UITests/                           [Agent 4, Agent 5]
│   ├── iPhoneUITests.swift
│   └── MultiPlatformUITests.swift
│
└── Documentation/
    ├── CLOUDKIT_SCHEMA.md             [Agent 1]
    ├── COMPREHENSIVE_BUILD_PLAN.md
    ├── AGENT_1_FOUNDATION.md
    ├── AGENT_2_DATA_MODELS.md
    ├── AGENT_3_SERVICES_SYNC.md
    ├── AGENT_4_DESIGN_UI.md
    ├── AGENT_5_MULTIPLATFORM_DEPLOY.md
    └── AGENT_COORDINATION.md          (this file)
```

---

## 🔧 Integration Points

### Between Agent 2 & Agent 3:
**Interface:** `Syncable` protocol, `toCKRecord()`, `fromCKRecord()`
- Agent 2 provides: Models with CloudKit conversion methods
- Agent 3 uses: Methods to sync with CloudKit

### Between Agent 2 & Agent 4:
**Interface:** SwiftData models
- Agent 2 provides: Task, Category, Tag models
- Agent 4 uses: Models in ViewModels and Views

### Between Agent 3 & Agent 4:
**Interface:** Service actors
- Agent 3 provides: DataSyncService, NotificationService
- Agent 4 integrates: Call sync on pull-to-refresh, schedule notifications

### Between Agent 4 & Agent 5:
**Interface:** Design system, reusable components
- Agent 4 provides: Colors, Typography, UI Components
- Agent 5 reuses: For iPad/Mac layouts

### Between Agent 3 & Agent 5:
**Interface:** ImportExportService
- Agent 3 provides: Export/import methods
- Agent 5 uses: In settings screen for data backup/restore

---

## ✅ Handoff Checklist

### Agent 1 → Agent 2
- [ ] Xcode project builds on all platforms
- [ ] CloudKit schema deployed to Development
- [ ] Folder structure created
- [ ] Protocols and enums defined
- [ ] Code pushed to branch

### Agent 2 → Agent 3 & Agent 4
- [ ] Task model with 40+ properties
- [ ] Category and Tag models
- [ ] CloudKit conversion methods (toCKRecord/fromCKRecord)
- [ ] RecurrenceEngine fully implemented
- [ ] All models have unit tests
- [ ] Code pushed to branch

### Agent 3 → Agent 4
- [ ] DataSyncService fully functional
- [ ] NotificationService working
- [ ] ImportExportService ready
- [ ] Offline queue implemented
- [ ] Service tests passing
- [ ] Code pushed to branch

### Agent 4 → Agent 5
- [ ] Design system complete (Colors, Typography, Spacing, Animations)
- [ ] 10+ reusable components
- [ ] iPhone UI fully functional
- [ ] Services integrated
- [ ] UI tests passing
- [ ] Code pushed to branch

### Agent 5 → App Store
- [ ] iPad UI complete
- [ ] Mac UI complete
- [ ] Widgets working
- [ ] Settings screen with export/import
- [ ] Keyboard shortcuts
- [ ] App icon and launch screen
- [ ] TestFlight tested
- [ ] App Store submitted

---

## 🚨 Critical Communication

### Daily Standups (Async)
Each agent posts progress:
- What I completed today
- What I'm working on next
- Any blockers or dependencies

### Merge Strategy
- Agent 1: Creates initial structure, pushes
- Agent 2: Pulls, adds models, pushes
- Agent 3, 4, 5: Pull latest, work in parallel, frequent pushes
- **Resolve conflicts immediately** - communicate if two agents touch same file

### Git Branch
All work on: `claude/free-todoist-alternative-01Reu5pLCB2jQtasTo9n8khh`

**Commit message format:**
```
feat(scope): description
test(scope): description
fix(scope): description
chore(scope): description

Examples:
feat(models): create Task model with CloudKit support
feat(ui): create task list view with filtering
test(services): add sync service unit tests
fix(sync): resolve conflict resolution edge case
chore: verify iPhone UI and polish
```

---

## 🎯 Success Metrics

### Agent 1:
- [✅] Project builds on iOS, iPad, Mac
- [✅] CloudKit schema deployed
- [✅] Capabilities configured

### Agent 2:
- [✅] All models with 90%+ test coverage
- [✅] RecurrenceEngine handles all patterns
- [✅] CloudKit conversion methods work

### Agent 3:
- [✅] Sync works bidirectionally
- [✅] Offline queue tested
- [✅] No data loss scenarios

### Agent 4:
- [✅] iPhone UI scores 9/10 on design
- [✅] 60fps animations
- [✅] Fully accessible (VoiceOver)

### Agent 5:
- [✅] iPad and Mac feel native
- [✅] Widgets beautiful and functional
- [✅] App approved by App Store

---

## 📝 Feature Checklist (All Agents)

### Core Features:
- [✅] Create, edit, delete tasks
- [✅] Complete/uncomplete tasks
- [✅] Due dates and times
- [✅] Priorities (none, low, medium, high, urgent)
- [✅] Projects/categories
- [✅] Tags (many-to-many)
- [✅] Recurring tasks (daily, weekly, monthly, yearly)
- [✅] Subtasks with progress tracking
- [✅] Reminders/notifications
- [✅] Search and filtering
- [✅] Sorting options

### Platform Features:
- [✅] iPhone tab navigation
- [✅] iPad split view
- [✅] Mac 3-pane layout with menu bar
- [✅] Keyboard shortcuts (30+)
- [✅] Drag & drop
- [✅] Widgets (small, medium, large)

### Data & Sync:
- [✅] Automatic CloudKit sync
- [✅] Offline mode with queue
- [✅] Conflict resolution
- [✅] Export to JSON/CSV
- [✅] Import from JSON
- [✅] Local SwiftData persistence

### Polish:
- [✅] Dark mode only
- [✅] Smooth animations (60fps)
- [✅] Haptic feedback
- [✅] Loading states
- [✅] Empty states
- [✅] Accessibility (VoiceOver, Dynamic Type)

### Advanced:
- [✅] Hierarchical projects (subprojects)
- [✅] Batch operations
- [✅] Natural language date parsing
- [✅] Quick add
- [✅] Multi-select
- [✅] Alternate app icons

---

## 🆘 Troubleshooting

### "CloudKit schema not found"
- Agent 1: Verify you're in Development environment
- Check container ID: `iCloud.com.personal.todoappy`

### "Models won't compile"
- Agent 2: Verify all Agent 1 protocols exist
- Check imports: SwiftUI, SwiftData, CloudKit

### "Sync not working"
- Agent 3: Check iCloud signed in on device/simulator
- Verify CloudKit permissions in Settings

### "UI components not found"
- Agent 5: Verify Agent 4's design system pushed
- Pull latest code

### "Tests failing"
- Run clean build (⌘⇧K)
- Delete DerivedData
- Restart Xcode

---

## 🎉 Final Integration

When all agents complete:

1. **Agent 1** does final verification:
   - All components integrated
   - Clean build on all platforms
   - All tests pass

2. **Create Pull Request** (optional, or merge to main)

3. **TestFlight Build:**
   - Agent 5 creates archive
   - Upload to App Store Connect
   - Invite testers

4. **Test Everything:**
   - Create tasks on iPhone → Verify syncs to Mac
   - Edit on iPad → Verify updates on iPhone
   - Test offline → Verify queues and syncs
   - Test recurring tasks
   - Test notifications
   - Test export/import

5. **App Store Submission:**
   - Agent 5 handles submission
   - Wait for review
   - Launch! 🚀

---

## 📊 Estimated Total Time

| Agent | Time | Work Type |
|-------|------|-----------|
| Agent 1 | 4-6 hrs | Sequential (must go first) |
| Agent 2 | 8-10 hrs | Sequential (after Agent 1) |
| Agent 3 | 10-12 hrs | **Parallel** (with 4 & 5) |
| Agent 4 | 12-15 hrs | **Parallel** (with 3 & 5) |
| Agent 5 | 10-12 hrs | **Parallel** (with 3, after 4 design system) |
| **Total** | **44-55 hrs** | **~2-3 weeks calendar time** |

---

## 🎯 End Goal

A **production-ready, beautiful, free, private task manager** that:
- Works on iPhone, iPad, and Mac
- Syncs automatically via iCloud
- Supports all Todoist features + more
- Never loses data (multiple backup layers)
- Looks better than Todoist
- Costs $0 forever

**Let's build it!** 🚀

---

## 📞 Contact Points

**Questions about:**
- Project structure, CloudKit → Ask Agent 1
- Models, recurring tasks → Ask Agent 2
- Sync, data safety, services → Ask Agent 3
- iPhone UI, design system → Ask Agent 4
- iPad/Mac, widgets, deployment → Ask Agent 5

**Conflicts or blockers:** Post in coordination thread immediately

**Ready to start:** Agent 1, you're up! 🎬
