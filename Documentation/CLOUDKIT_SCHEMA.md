# CloudKit Schema Documentation

## Overview
This document describes the CloudKit schema for ToDo-Appy. The schema is designed to support multi-platform task management with sync capabilities.

**Container ID:** `iCloud.com.personal.todoappy`
**Custom Zone:** `TasksZone`
**Environment:** Development (initially)

---

## Record Types

### 1. CKTask

**Description:** Represents a single task or to-do item.

#### Fields

| Field Name | Type | Indexed | Queryable | Sortable | Description |
|------------|------|---------|-----------|----------|-------------|
| `id` | String | ✅ | ✅ | ✅ | Unique identifier (UUID) |
| `title` | String | ✅ | ✅ | ✅ | Task title/name |
| `taskDescription` | String | ❌ | ❌ | ❌ | Detailed description |
| `isCompleted` | Int64 | ✅ | ❌ | ❌ | 0=incomplete, 1=complete |
| `createdAt` | Date/Time | ✅ | ❌ | ✅ | Creation timestamp |
| `updatedAt` | Date/Time | ✅ | ❌ | ✅ | Last modification timestamp |
| `dueDate` | Date/Time | ✅ | ❌ | ✅ | Optional due date |
| `priority` | Int64 | ✅ | ❌ | ❌ | 0=none, 1=low, 2=medium, 3=high, 4=urgent |
| `categoryID` | String | ✅ | ✅ | ❌ | Foreign key to CKCategory |
| `sortOrder` | Int64 | ❌ | ❌ | ✅ | Manual sort order within category |
| `isDeleted` | Int64 | ✅ | ❌ | ❌ | Soft delete flag (0=active, 1=deleted) |

**Recurring Task Fields:**

| Field Name | Type | Indexed | Description |
|------------|------|---------|-------------|
| `isRecurring` | Int64 | ✅ | 0=one-time, 1=recurring |
| `recurrenceType` | String | ❌ | daily/weekly/monthly/yearly/custom |
| `recurrenceInterval` | Int64 | ❌ | Repeat every N units |
| `recurrenceEndDate` | Date/Time | ❌ | Optional end date for recurrence |
| `recurrenceDaysOfWeek` | List<Int64> | ❌ | Days of week (1=Sun, 7=Sat) |
| `recurrenceDayOfMonth` | Int64 | ❌ | Day of month (1-31) |
| `recurrenceMonthOfYear` | Int64 | ❌ | Month of year (1-12) |
| `parentRecurringTaskID` | String | ❌ | Link to parent recurring task template |

**Reminder Fields:**

| Field Name | Type | Indexed | Description |
|------------|------|---------|-------------|
| `hasReminder` | Int64 | ✅ | 0=no reminder, 1=has reminder |
| `reminderTime` | Date/Time | ❌ | Absolute reminder time |
| `reminderOffset` | Int64 | ❌ | Minutes before due date |

**Relationship Fields:**

| Field Name | Type | Description |
|------------|------|-------------|
| `tagIDs` | List<String> | Array of tag IDs |
| `subtaskIDs` | List<String> | Array of subtask IDs |
| `parentTaskID` | String | Parent task ID (for subtasks) |

#### Sample Queries

```swift
// Get all incomplete tasks
let predicate = NSPredicate(format: "isCompleted == 0 AND isDeleted == 0")

// Get high priority tasks due today
let calendar = Calendar.current
let startOfDay = calendar.startOfDay(for: Date())
let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
let predicate = NSPredicate(format: "priority >= 3 AND dueDate >= %@ AND dueDate < %@ AND isDeleted == 0",
                           startOfDay as NSDate, endOfDay as NSDate)

// Get tasks in specific category
let predicate = NSPredicate(format: "categoryID == %@ AND isDeleted == 0", categoryID)

// Get recurring tasks
let predicate = NSPredicate(format: "isRecurring == 1 AND isDeleted == 0")
```

---

### 2. CKCategory

**Description:** Represents a task category/list.

#### Fields

| Field Name | Type | Indexed | Queryable | Sortable | Description |
|------------|------|---------|-----------|----------|-------------|
| `id` | String | ✅ | ✅ | ✅ | Unique identifier (UUID) |
| `name` | String | ✅ | ✅ | ✅ | Category name |
| `colorHex` | String | ❌ | ❌ | ❌ | Hex color code (e.g., "#FF5733") |
| `icon` | String | ❌ | ❌ | ❌ | SF Symbol name |
| `sortOrder` | Int64 | ❌ | ❌ | ✅ | Display order |
| `createdAt` | Date/Time | ❌ | ❌ | ❌ | Creation timestamp |
| `updatedAt` | Date/Time | ❌ | ❌ | ❌ | Last modification timestamp |
| `isDeleted` | Int64 | ✅ | ❌ | ❌ | Soft delete flag |

#### Default Categories

When app first launches, create these default categories:

```swift
[
    CKCategory(name: "Personal", colorHex: "#3B82F6", icon: "person.fill"),
    CKCategory(name: "Work", colorHex: "#EF4444", icon: "briefcase.fill"),
    CKCategory(name: "Shopping", colorHex: "#10B981", icon: "cart.fill"),
    CKCategory(name: "Health", colorHex: "#F59E0B", icon: "heart.fill")
]
```

#### Sample Queries

```swift
// Get all active categories sorted by sortOrder
let predicate = NSPredicate(format: "isDeleted == 0")
let sortDescriptor = NSSortDescriptor(key: "sortOrder", ascending: true)

// Find category by name
let predicate = NSPredicate(format: "name == %@ AND isDeleted == 0", categoryName)
```

---

### 3. CKTag

**Description:** Represents a reusable tag for tasks.

#### Fields

| Field Name | Type | Indexed | Queryable | Sortable | Description |
|------------|------|---------|-----------|----------|-------------|
| `id` | String | ✅ | ✅ | ✅ | Unique identifier (UUID) |
| `name` | String | ✅ | ✅ | ✅ | Tag name |
| `colorHex` | String | ❌ | ❌ | ❌ | Hex color code |
| `createdAt` | Date/Time | ❌ | ❌ | ❌ | Creation timestamp |
| `updatedAt` | Date/Time | ❌ | ❌ | ❌ | Last modification timestamp |
| `isDeleted` | Int64 | ✅ | ❌ | ❌ | Soft delete flag |

#### Sample Queries

```swift
// Get all active tags
let predicate = NSPredicate(format: "isDeleted == 0")

// Find tag by name
let predicate = NSPredicate(format: "name == %@ AND isDeleted == 0", tagName)

// Get tags for specific task (query from task's tagIDs)
let predicate = NSPredicate(format: "id IN %@ AND isDeleted == 0", task.tagIDs)
```

---

## Custom Zone

**Zone Name:** `TasksZone`

### Purpose
- Enables atomic batch operations
- Supports change token tracking for efficient delta sync
- Required for database subscriptions
- Allows zone-level backup/restore

### Usage
All CKTask, CKCategory, and CKTag records MUST be saved to this zone.

```swift
let zoneID = CKRecordZone.ID(zoneName: "TasksZone", ownerName: CKCurrentUserDefaultName)
let zone = CKRecordZone(zoneID: zoneID)

// Save records to zone
record.recordID = CKRecord.ID(recordName: uuid, zoneID: zoneID)
```

---

## Subscriptions

### 1. TaskChanges Subscription

**Type:** Query Subscription
**Record Type:** CKTask
**Zone:** TasksZone
**Predicate:** `TRUEPREDICATE` (fires for all records)
**Fires On:** Creation, Update, Deletion
**Notification:** Silent (content-available)

### 2. CategoryChanges Subscription

**Type:** Query Subscription
**Record Type:** CKCategory
**Zone:** TasksZone
**Predicate:** `TRUEPREDICATE`
**Fires On:** Creation, Update, Deletion
**Notification:** Silent

### 3. TagChanges Subscription

**Type:** Query Subscription
**Record Type:** CKTag
**Zone:** TasksZone
**Predicate:** `TRUEPREDICATE`
**Fires On:** Creation, Update, Deletion
**Notification:** Silent

### Purpose
These subscriptions enable real-time sync across devices. When a record changes on Device A, Device B receives a silent push notification and can fetch the changes.

---

## Indexes

### Performance Optimization

The following fields are indexed for query performance:

**CKTask:**
- `id` - Primary identifier lookups
- `title` - Search functionality
- `isCompleted` - Filtering complete/incomplete
- `createdAt` - Sort by creation time
- `updatedAt` - Sort by modification time
- `dueDate` - Sort and filter by due date
- `priority` - Filter by priority level
- `categoryID` - Filter tasks by category
- `isDeleted` - Exclude deleted items
- `isRecurring` - Filter recurring tasks
- `hasReminder` - Filter tasks with reminders

**CKCategory:**
- `id` - Primary identifier lookups
- `name` - Search and uniqueness
- `isDeleted` - Exclude deleted items

**CKTag:**
- `id` - Primary identifier lookups
- `name` - Search and uniqueness
- `isDeleted` - Exclude deleted items

---

## Setup Instructions

### Step 1: Access CloudKit Dashboard
1. Go to https://icloud.developer.apple.com/dashboard
2. Sign in with Apple Developer account
3. Select container: `iCloud.com.personal.todoappy`
4. Switch to **Development** environment

### Step 2: Create Record Types
1. Click "Schema" → "Record Types"
2. Create `CKTask` with all fields listed above
3. Create `CKCategory` with all fields listed above
4. Create `CKTag` with all fields listed above
5. For each field, set correct type and check appropriate boxes (Indexed, Queryable, Sortable)
6. Click "Save Changes"

### Step 3: Create Custom Zone
1. Click "Data" → "Zones"
2. Click "+" to add new zone
3. Name: `TasksZone`
4. Click "Create"

### Step 4: Create Subscriptions
1. Click "Subscriptions"
2. Create three query subscriptions as specified above
3. Ensure notification type is set to "Silent" (content-available)

### Step 5: Deploy to Production
1. When ready for production, go to Schema → "Deploy to Production"
2. Review changes carefully
3. Deploy schema (this is irreversible)
4. Switch app to production environment

---

## Testing

### Reset Development Data
```swift
// Delete all records in zone (for testing)
let zoneID = CKRecordZone.ID(zoneName: "TasksZone", ownerName: CKCurrentUserDefaultName)
let deleteZoneOperation = CKModifyRecordZonesOperation(recordZonesToSave: nil, recordZoneIDsToDelete: [zoneID])
database.add(deleteZoneOperation)

// Then recreate the zone
let zone = CKRecordZone(zoneID: zoneID)
let saveZoneOperation = CKModifyRecordZonesOperation(recordZonesToSave: [zone], recordZoneIDsToDelete: nil)
database.add(saveZoneOperation)
```

### Verify Schema in Dashboard
1. Go to CloudKit Dashboard
2. Click "Schema" → "Record Types"
3. Verify all 3 record types exist
4. Click each type and verify all fields
5. Check "Data" tab to see created records

---

## Migration Strategy

If schema changes are needed after production deployment:

1. **Add new fields:** Can be added anytime (existing records will have nil values)
2. **Rename fields:** NOT SUPPORTED - create new field and migrate data
3. **Delete fields:** NOT RECOMMENDED - mark as deprecated instead
4. **Change field type:** NOT SUPPORTED - create new field and migrate

---

## Notes for Agent 2 & 3

**Agent 2 (Data Models):**
- Use this schema as the source of truth for SwiftData model properties
- Map CloudKit field names to SwiftData property names
- Implement `Syncable` protocol to convert between SwiftData and CKRecord

**Agent 3 (Sync Service):**
- Use `TasksZone` for all operations
- Implement change token tracking for efficient delta sync
- Handle subscription notifications for real-time updates
- Implement conflict resolution (last-write-wins strategy)

---

## References

- [CloudKit Documentation](https://developer.apple.com/documentation/cloudkit)
- [CKRecord](https://developer.apple.com/documentation/cloudkit/ckrecord)
- [CKQuery](https://developer.apple.com/documentation/cloudkit/ckquery)
- [CKSubscription](https://developer.apple.com/documentation/cloudkit/cksubscription)
