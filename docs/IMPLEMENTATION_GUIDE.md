# Implementation Guide

## Overview

This guide provides step-by-step instructions for implementing ToDo Appy from scratch, including code examples and best practices.

## Phase 1: Project Setup

### Step 1: Create Xcode Project

1. Open Xcode 15+
2. Create new project
3. Select "Multiplatform App"
4. Project details:
   - Product Name: `ToDoAppy`
   - Team: Your developer account
   - Organization Identifier: `com.personal`
   - Interface: SwiftUI
   - Language: Swift
   - Storage: SwiftData
   - Include Tests: Yes

### Step 2: Enable Required Capabilities

**Target Settings → Signing & Capabilities:**

1. **Add iCloud Capability**
   - CloudKit
   - Key-Value Storage (optional)

2. **Add Background Modes**
   - Remote notifications
   - Background fetch

3. **Add Push Notifications**

### Step 3: Configure CloudKit Container

1. Open CloudKit Dashboard
2. Create container: `iCloud.com.personal.todoappy`
3. Create Custom Zones (via code during first launch)
4. Define Record Types (via code or dashboard):
   - Task
   - Category
   - Tag

### Step 4: Project Structure

Create the following folder structure:

```
ToDoAppy/
├── App/
│   ├── ToDoAppyApp.swift
│   ├── AppDelegate.swift
│   └── Config.swift
├── Models/
│   ├── Task.swift
│   ├── Category.swift
│   ├── Tag.swift
│   └── Supporting/
│       ├── Priority.swift
│       └── SyncStatus.swift
├── ViewModels/
│   ├── TaskListViewModel.swift
│   ├── TaskDetailViewModel.swift
│   └── CategoryViewModel.swift
├── Views/
│   ├── iOS/
│   │   ├── ContentView.swift
│   │   ├── TaskListView.swift
│   │   ├── TaskDetailView.swift
│   │   ├── TaskEditorView.swift
│   │   └── Components/
│   │       ├── TaskRowView.swift
│   │       ├── CategoryPickerView.swift
│   │       └── PriorityPickerView.swift
│   ├── macOS/
│   │   ├── SidebarView.swift
│   │   ├── ListPaneView.swift
│   │   └── DetailPaneView.swift
│   └── Shared/
│       ├── SettingsView.swift
│       └── Components/
├── Services/
│   ├── DataSyncService.swift
│   ├── CloudKitSetupService.swift
│   ├── NotificationService.swift
│   └── SyncQueue.swift
├── Utilities/
│   ├── Extensions/
│   │   ├── Date+Extensions.swift
│   │   └── Color+Extensions.swift
│   ├── CloudKitTransformer.swift
│   ├── DataValidator.swift
│   └── Logger+Extensions.swift
└── Resources/
    ├── Assets.xcassets
    └── Localizable.strings
```

## Phase 2: Data Layer Implementation

### Step 1: Create Data Models

**Task.swift** (see DATA_MODELS.md for complete implementation)

```swift
import SwiftData
import Foundation

@Model
final class Task {
    @Attribute(.unique) var id: UUID
    var title: String
    var taskDescription: String?
    var isCompleted: Bool
    var createdAt: Date
    var updatedAt: Date
    var dueDate: Date?
    var priorityRawValue: String?

    @Relationship(deleteRule: .nullify)
    var category: Category?

    var syncStatusRawValue: String

    init(title: String) {
        self.id = UUID()
        self.title = title
        self.isCompleted = false
        self.createdAt = Date()
        self.updatedAt = Date()
        self.syncStatusRawValue = "pending"
    }
}
```

### Step 2: Configure SwiftData Container

**ToDoAppyApp.swift:**

```swift
import SwiftUI
import SwiftData

@main
struct ToDoAppyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    let container: ModelContainer

    init() {
        do {
            let schema = Schema([
                Task.self,
                Category.self,
                Tag.self
            ])

            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                allowsSave: true
            )

            container = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )

            // Create default categories
            setupDefaultData()

        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)
                .environmentObject(AppState(container: container))
        }
    }

    private func setupDefaultData() {
        let context = ModelContext(container)

        // Check if categories exist
        let descriptor = FetchDescriptor<Category>()
        let existingCategories = try? context.fetch(descriptor)

        if existingCategories?.isEmpty ?? true {
            Category.createDefaults(in: context)
            try? context.save()
        }
    }
}
```

### Step 3: Create AppState

**AppState.swift:**

```swift
import SwiftUI
import SwiftData
import CloudKit

@Observable
class AppState {
    let container: ModelContainer
    let syncService: DataSyncService
    let notificationService: NotificationService

    var isSyncing: Bool = false
    var lastSyncDate: Date?
    var syncError: Error?

    init(container: ModelContainer) {
        self.container = container

        let modelContext = ModelContext(container)
        let cloudKitContainer = CKContainer(identifier: "iCloud.com.personal.todoappy")

        self.syncService = DataSyncService(
            container: cloudKitContainer,
            modelContext: modelContext
        )

        self.notificationService = NotificationService()

        Task {
            await setupCloudKit()
            await performInitialSync()
        }
    }

    private func setupCloudKit() async {
        do {
            let setupService = CloudKitSetupService()
            try await setupService.setupCloudKit()
        } catch {
            print("CloudKit setup error: \(error)")
        }
    }

    private func performInitialSync() async {
        isSyncing = true
        defer { isSyncing = false }

        do {
            try await syncService.syncFromCloud()
            lastSyncDate = Date()
        } catch {
            syncError = error
            print("Initial sync error: \(error)")
        }
    }

    func sync() async {
        isSyncing = true
        defer { isSyncing = false }

        do {
            // Upload pending changes
            try await syncService.batchSyncToCloud()

            // Download new changes
            try await syncService.syncFromCloud()

            lastSyncDate = Date()
            syncError = nil
        } catch {
            syncError = error
            print("Sync error: \(error)")
        }
    }
}
```

## Phase 3: View Layer Implementation

### Step 1: Main Content View

**ContentView.swift (iOS):**

```swift
import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appState: AppState

    @State private var selectedTab: Tab = .today

    enum Tab {
        case lists, today, search, settings
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            ListsView()
                .tabItem {
                    Label("Lists", systemImage: "list.bullet")
                }
                .tag(Tab.lists)

            TodayView()
                .tabItem {
                    Label("Today", systemImage: "calendar")
                }
                .tag(Tab.today)

            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(Tab.search)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(Tab.settings)
        }
    }
}
```

### Step 2: Task List View

**TaskListView.swift:**

```swift
import SwiftUI
import SwiftData

struct TaskListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tasks: [Task]

    @State private var showingAddTask = false
    @State private var searchText = ""

    init(predicate: Predicate<Task>? = nil, sort: [SortDescriptor<Task>] = []) {
        let defaultSort = [SortDescriptor(\Task.sortOrder)]
        _tasks = Query(
            filter: predicate,
            sort: sort.isEmpty ? defaultSort : sort
        )
    }

    var filteredTasks: [Task] {
        if searchText.isEmpty {
            return tasks.filter { !$0.isDeleted }
        } else {
            return tasks.filter { task in
                !task.isDeleted &&
                (task.title.localizedCaseInsensitiveContains(searchText) ||
                 (task.taskDescription?.localizedCaseInsensitiveContains(searchText) ?? false))
            }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if filteredTasks.isEmpty {
                    ContentUnavailableView(
                        "No Tasks",
                        systemImage: "checkmark.circle",
                        description: Text("Tap + to add a new task")
                    )
                } else {
                    ForEach(filteredTasks) { task in
                        NavigationLink(value: task) {
                            TaskRowView(task: task)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                deleteTask(task)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }

                            Button {
                                // Schedule task
                            } label: {
                                Label("Schedule", systemImage: "calendar")
                            }
                            .tint(.orange)

                            Button {
                                toggleCompletion(task)
                            } label: {
                                Label(
                                    task.isCompleted ? "Mark Incomplete" : "Complete",
                                    systemImage: task.isCompleted ? "circle" : "checkmark.circle.fill"
                                )
                            }
                            .tint(.green)
                        }
                    }
                }
            }
            .navigationTitle("Tasks")
            .searchable(text: $searchText, prompt: "Search tasks")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddTask = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                TaskEditorView(mode: .create)
            }
            .navigationDestination(for: Task.self) { task in
                TaskDetailView(task: task)
            }
        }
    }

    private func toggleCompletion(_ task: Task) {
        withAnimation {
            task.toggleCompletion()
            try? modelContext.save()
        }
    }

    private func deleteTask(_ task: Task) {
        withAnimation {
            task.markForDeletion()
            try? modelContext.save()
        }
    }
}
```

### Step 3: Task Row Component

**TaskRowView.swift:**

```swift
import SwiftUI

struct TaskRowView: View {
    let task: Task
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        HStack(spacing: 12) {
            // Completion button
            Button {
                toggleCompletion()
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(task.isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)

            // Task content
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.body)
                    .strikethrough(task.isCompleted)
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)

                HStack(spacing: 8) {
                    // Due date
                    if let dueDate = task.dueDate {
                        Label(
                            formatDueDate(dueDate),
                            systemImage: "calendar"
                        )
                        .font(.caption)
                        .foregroundStyle(dueDateColor(dueDate))
                    }

                    // Priority
                    if let priority = task.priority {
                        Label(
                            priority.displayName,
                            systemImage: "flag.fill"
                        )
                        .font(.caption)
                        .foregroundStyle(Color(hex: priority.color))
                    }

                    // Tags
                    if let tags = task.tags, !tags.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "tag.fill")
                                .font(.caption2)
                            Text(tags.map { $0.name }.joined(separator: ", "))
                                .font(.caption)
                                .lineLimit(1)
                        }
                        .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            // Category indicator
            if let category = task.category {
                Circle()
                    .fill(Color(hex: category.colorHex))
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }

    private func toggleCompletion() {
        withAnimation(.easeInOut(duration: 0.2)) {
            task.toggleCompletion()
            try? modelContext.save()
        }
    }

    private func formatDueDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today " + date.formatted(date: .omitted, time: .shortened)
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            return date.formatted(date: .abbreviated, time: .omitted)
        }
    }

    private func dueDateColor(_ date: Date) -> Color {
        if task.isCompleted {
            return .secondary
        } else if date < Date() {
            return .red
        } else if Calendar.current.isDateInToday(date) {
            return .orange
        } else {
            return .secondary
        }
    }
}
```

### Step 4: Task Editor View

**TaskEditorView.swift:**

```swift
import SwiftUI
import SwiftData

struct TaskEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState

    enum Mode {
        case create
        case edit(Task)
    }

    let mode: Mode

    @State private var title = ""
    @State private var description = ""
    @State private var dueDate: Date?
    @State private var hasDueDate = false
    @State private var reminderDate: Date?
    @State private var hasReminder = false
    @State private var priority: Priority?
    @State private var selectedCategory: Category?
    @State private var selectedTags: Set<Tag> = []

    @Query private var categories: [Category]
    @Query private var allTags: [Tag]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Task Title", text: $title)
                        .font(.headline)

                    TextField("Notes", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section {
                    Toggle("Due Date", isOn: $hasDueDate)

                    if hasDueDate {
                        DatePicker(
                            "Date",
                            selection: Binding(
                                get: { dueDate ?? Date() },
                                set: { dueDate = $0 }
                            ),
                            displayedComponents: [.date, .hourAndMinute]
                        )
                    }

                    Toggle("Reminder", isOn: $hasReminder)

                    if hasReminder {
                        DatePicker(
                            "Remind Me",
                            selection: Binding(
                                get: { reminderDate ?? Date() },
                                set: { reminderDate = $0 }
                            ),
                            displayedComponents: [.date, .hourAndMinute]
                        )
                    }
                }

                Section("Organization") {
                    Picker("Priority", selection: $priority) {
                        Text("None").tag(nil as Priority?)
                        ForEach(Priority.allCases, id: \.self) { priority in
                            HStack {
                                Circle()
                                    .fill(Color(hex: priority.color))
                                    .frame(width: 12, height: 12)
                                Text(priority.displayName)
                            }
                            .tag(priority as Priority?)
                        }
                    }

                    Picker("Category", selection: $selectedCategory) {
                        Text("None").tag(nil as Category?)
                        ForEach(categories.filter { !$0.isDeleted }, id: \.id) { category in
                            HStack {
                                if let iconName = category.iconName {
                                    Image(systemName: iconName)
                                }
                                Circle()
                                    .fill(Color(hex: category.colorHex))
                                    .frame(width: 12, height: 12)
                                Text(category.name)
                            }
                            .tag(category as Category?)
                        }
                    }

                    NavigationLink("Tags") {
                        TagSelectionView(selectedTags: $selectedTags)
                    }
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTask()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                loadExistingTask()
            }
        }
    }

    private var navigationTitle: String {
        switch mode {
        case .create:
            return "New Task"
        case .edit:
            return "Edit Task"
        }
    }

    private func loadExistingTask() {
        guard case .edit(let task) = mode else { return }

        title = task.title
        description = task.taskDescription ?? ""
        dueDate = task.dueDate
        hasDueDate = task.dueDate != nil
        reminderDate = task.reminderDate
        hasReminder = task.reminderDate != nil
        priority = task.priority
        selectedCategory = task.category
        selectedTags = Set(task.tags ?? [])
    }

    private func saveTask() {
        let task: Task

        switch mode {
        case .create:
            task = Task(
                title: title,
                description: description.isEmpty ? nil : description,
                dueDate: hasDueDate ? dueDate : nil,
                priority: priority,
                category: selectedCategory,
                reminderDate: hasReminder ? reminderDate : nil
            )
            modelContext.insert(task)

        case .edit(let existingTask):
            task = existingTask
            task.update(
                title: title,
                description: description.isEmpty ? nil : description,
                dueDate: hasDueDate ? dueDate : nil,
                priority: priority,
                category: selectedCategory,
                reminderDate: hasReminder ? reminderDate : nil
            )
        }

        // Update tags
        task.tags = Array(selectedTags)

        // Save context
        do {
            try modelContext.save()

            // Schedule notification if needed
            if hasReminder, let reminderDate = reminderDate {
                Task {
                    await appState.notificationService.scheduleNotification(for: task)
                }
            }

            // Sync to cloud
            Task {
                try await appState.syncService.syncToCloud(task)
            }

            dismiss()
        } catch {
            print("Error saving task: \(error)")
        }
    }
}
```

### Step 5: Task Detail View

**TaskDetailView.swift:**

```swift
import SwiftUI

struct TaskDetailView: View {
    @Bindable var task: Task
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appState: AppState

    @State private var showingEditor = false
    @State private var showingDeleteAlert = false

    var body: some View {
        List {
            Section {
                HStack {
                    Button {
                        task.toggleCompletion()
                        try? modelContext.save()
                    } label: {
                        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                            .font(.title)
                            .foregroundStyle(task.isCompleted ? .green : .secondary)
                    }
                    .buttonStyle(.plain)

                    Text(task.title)
                        .font(.title3)
                        .fontWeight(.semibold)
                }
            }

            if let description = task.taskDescription, !description.isEmpty {
                Section("Notes") {
                    Text(description)
                }
            }

            Section("Details") {
                if let dueDate = task.dueDate {
                    LabeledContent {
                        Text(dueDate, style: .date)
                            .foregroundStyle(task.isOverdue ? .red : .primary)
                    } label: {
                        Label("Due Date", systemImage: "calendar")
                    }
                }

                if let reminderDate = task.reminderDate {
                    LabeledContent {
                        Text(reminderDate, style: .date)
                    } label: {
                        Label("Reminder", systemImage: "bell")
                    }
                }

                if let priority = task.priority {
                    LabeledContent {
                        HStack {
                            Circle()
                                .fill(Color(hex: priority.color))
                                .frame(width: 12, height: 12)
                            Text(priority.displayName)
                        }
                    } label: {
                        Label("Priority", systemImage: "flag.fill")
                    }
                }

                if let category = task.category {
                    LabeledContent {
                        HStack {
                            if let iconName = category.iconName {
                                Image(systemName: iconName)
                                    .foregroundStyle(Color(hex: category.colorHex))
                            }
                            Text(category.name)
                        }
                    } label: {
                        Label("Category", systemImage: "folder.fill")
                    }
                }

                if let tags = task.tags, !tags.isEmpty {
                    LabeledContent {
                        Text(tags.map { $0.name }.joined(separator: ", "))
                    } label: {
                        Label("Tags", systemImage: "tag.fill")
                    }
                }
            }

            if let subtasks = task.subtasks, !subtasks.isEmpty {
                Section("Subtasks") {
                    ForEach(subtasks) { subtask in
                        HStack {
                            Image(systemName: subtask.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(subtask.isCompleted ? .green : .secondary)
                            Text(subtask.title)
                        }
                    }
                }
            }

            Section {
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    Label("Delete Task", systemImage: "trash")
                }
            }
        }
        .navigationTitle("Task Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    showingEditor = true
                }
            }
        }
        .sheet(isPresented: $showingEditor) {
            TaskEditorView(mode: .edit(task))
        }
        .alert("Delete Task", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteTask()
            }
        } message: {
            Text("Are you sure you want to delete this task?")
        }
    }

    private func deleteTask() {
        task.markForDeletion()
        try? modelContext.save()
    }
}
```

## Phase 4: Sync Implementation

### Step 1: Implement CloudKit Setup

See CLOUDKIT_SYNC.md for complete CloudKitSetupService implementation.

### Step 2: Implement Data Sync Service

See CLOUDKIT_SYNC.md for complete DataSyncService implementation.

### Step 3: Handle Push Notifications

**AppDelegate.swift:**

```swift
import UIKit
import CloudKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        application.registerForRemoteNotifications()
        requestNotificationPermissions()
        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        print("Successfully registered for remote notifications")
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("Failed to register for remote notifications: \(error)")
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        // Handle CloudKit notification
        let notification = CKNotification(fromRemoteNotificationDictionary: userInfo)

        if notification?.notificationType == .recordZone {
            // Trigger sync
            Task {
                // Get AppState from scene and trigger sync
                completionHandler(.newData)
            }
        } else {
            completionHandler(.noData)
        }
    }

    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permissions granted")
            } else if let error = error {
                print("Error requesting notification permissions: \(error)")
            }
        }
    }
}
```

## Phase 5: Testing

### Step 1: Unit Tests

**TaskTests.swift:**

```swift
import XCTest
import SwiftData
@testable import ToDoAppy

final class TaskTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!

    override func setUp() {
        super.setUp()

        let schema = Schema([Task.self, Category.self, Tag.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try! ModelContainer(for: schema, configurations: [config])
        context = ModelContext(container)
    }

    override func tearDown() {
        container = nil
        context = nil
        super.tearDown()
    }

    func testTaskCreation() {
        let task = Task(title: "Test Task")
        context.insert(task)

        XCTAssertEqual(task.title, "Test Task")
        XCTAssertFalse(task.isCompleted)
        XCTAssertNotNil(task.id)
    }

    func testTaskCompletion() {
        let task = Task(title: "Test Task")
        context.insert(task)

        task.toggleCompletion()

        XCTAssertTrue(task.isCompleted)
        XCTAssertNotNil(task.completedAt)
    }

    func testTaskWithCategory() {
        let category = Category(name: "Work", colorHex: "#FF0000")
        context.insert(category)

        let task = Task(title: "Test Task", category: category)
        context.insert(task)

        XCTAssertEqual(task.category?.name, "Work")
    }

    func testOverdueTask() {
        let task = Task(title: "Overdue Task")
        task.dueDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        context.insert(task)

        XCTAssertTrue(task.isOverdue)
    }
}
```

### Step 2: UI Tests

**TaskListUITests.swift:**

```swift
import XCTest

final class TaskListUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app.launch()
    }

    func testAddTask() {
        // Tap add button
        app.buttons["plus"].tap()

        // Enter task title
        let titleField = app.textFields["Task Title"]
        titleField.tap()
        titleField.typeText("Buy groceries")

        // Save task
        app.buttons["Save"].tap()

        // Verify task appears in list
        XCTAssertTrue(app.staticTexts["Buy groceries"].exists)
    }

    func testCompleteTask() {
        // Assuming a task exists
        let taskRow = app.staticTexts["Buy groceries"]
        XCTAssertTrue(taskRow.exists)

        // Tap completion circle
        app.buttons["circle"].firstMatch.tap()

        // Verify checkmark appears
        XCTAssertTrue(app.buttons["checkmark.circle.fill"].exists)
    }

    func testDeleteTask() {
        let taskRow = app.staticTexts["Buy groceries"]
        taskRow.swipeLeft()

        app.buttons["Delete"].tap()

        XCTAssertFalse(taskRow.exists)
    }
}
```

## Phase 6: Deployment

### Step 1: Prepare for TestFlight

1. Update version number (1.0.0)
2. Add App Icon (1024x1024)
3. Create screenshots for all device sizes
4. Write App Store description
5. Set privacy policy URL

### Step 2: Archive and Upload

1. Product → Archive
2. Distribute App → App Store Connect
3. Upload to TestFlight
4. Submit for external testing review

### Step 3: Beta Testing

1. Invite beta testers
2. Collect feedback
3. Fix bugs
4. Release new builds

## Best Practices

### 1. Error Handling

Always handle errors gracefully:

```swift
do {
    try modelContext.save()
} catch {
    Logger.data.error("Failed to save: \(error.localizedDescription)")
    // Show user-friendly error message
}
```

### 2. Performance

- Use lazy loading for large lists
- Implement pagination for completed tasks
- Debounce search input
- Use background contexts for heavy operations

### 3. Accessibility

- Provide meaningful accessibility labels
- Support Dynamic Type
- Test with VoiceOver
- Ensure sufficient color contrast

### 4. Security

- Never log sensitive user data
- Use proper iCloud entitlements
- Validate all user input
- Handle authentication errors

### 5. User Experience

- Provide immediate feedback for actions
- Show loading states
- Handle offline gracefully
- Implement undo functionality

---

**Last Updated:** 2025-11-15
