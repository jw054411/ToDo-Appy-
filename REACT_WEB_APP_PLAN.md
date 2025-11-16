# React Web App - Configurable Life Tracker

## Product Vision

A flexible, local-first web application for tracking everything in your life - from big projects (cars, rentals, home) to daily habits (water intake, exercise) with full configurability. Everything is customizable: create your own trackers, define your own fields, and organize your data your way.

---

## Core Principles

1. **Everything is Configurable** - No hard-coded tracking categories
2. **Local-First** - All data stored locally with SQLite
3. **Simple & Fast** - Clean UI, instant responses
4. **Flexible Data Model** - Adapt to any tracking need
5. **No Vendor Lock-in** - Your data, your control

---

## Feature Overview

### 1. Tab-Based Navigation
```
┌─────────────────────────────────────────┐
│  Projects  │  Trackers  │  Settings    │
└─────────────────────────────────────────┘
```

### 2. Projects Tab
**Purpose**: Track big, ongoing projects with maintenance logs and notes

**Examples**:
- **Cars**: Oil changes, tire rotations, repairs, parts inventory
- **Rentals**: Tenant info, maintenance history, expenses
- **Home**: Light bulbs (which room, type, when changed), HVAC filters, appliances

**Features**:
- Create unlimited project types
- Each project has:
  - Custom fields (text, number, date, dropdown)
  - Maintenance log (timestamped entries)
  - Future notes/reminders
  - Attachments (photos, receipts)
  - Cost tracking

**Sub-categories**:
- **Big Projects**: Major ongoing things (cars, properties)
- **Micro Projects**: Small stuff (light bulbs, filters, subscriptions)

### 3. Daily Trackers Tab
**Purpose**: Log daily habits and metrics

**Examples**:
- Water intake (oz/day)
- Exercise (minutes/day)
- Sleep hours
- Mood tracking
- Medication adherence
- Custom metrics (screen time, books read, etc.)

**Features**:
- Quick entry forms
- Visual trends/charts
- Streak tracking
- Daily/weekly/monthly views
- Goal setting

### 4. Settings Tab
**Purpose**: Configure everything

**Features**:
- Create/edit project types
- Define custom fields
- Create/edit tracker types
- Data export/import
- Backup management
- Theme customization

---

## Data Model Architecture

### Core Entities

#### 1. Entity Types (Meta-configuration)
```typescript
interface EntityType {
  id: string;
  name: string;
  type: 'project' | 'tracker';
  category: 'big' | 'micro' | 'daily' | null;
  icon: string;
  color: string;
  fieldDefinitions: FieldDefinition[];
  createdAt: Date;
  updatedAt: Date;
}

interface FieldDefinition {
  id: string;
  name: string;
  fieldType: 'text' | 'number' | 'date' | 'dropdown' | 'checkbox' | 'textarea';
  required: boolean;
  defaultValue?: any;
  options?: string[]; // for dropdown
  validations?: {
    min?: number;
    max?: number;
    pattern?: string;
  };
}
```

**Example Entity Types**:
- "Car" (project, big) - fields: make, model, year, VIN, license plate
- "Light Bulb" (project, micro) - fields: location, type, wattage, date_installed
- "Water Intake" (tracker, daily) - fields: ounces, time_of_day

#### 2. Entities (Actual instances)
```typescript
interface Entity {
  id: string;
  entityTypeId: string;
  name: string;
  fieldValues: Record<string, any>; // JSON object with field values
  createdAt: Date;
  updatedAt: Date;
  archivedAt?: Date;
}
```

**Examples**:
- Entity of type "Car": {name: "2015 Honda Civic", fieldValues: {make: "Honda", model: "Civic", year: 2015}}
- Entity of type "Light Bulb": {name: "Kitchen Ceiling", fieldValues: {location: "Kitchen", type: "LED 60W equivalent"}}

#### 3. Logs (Maintenance & Events)
```typescript
interface Log {
  id: string;
  entityId: string;
  logType: 'maintenance' | 'note' | 'cost' | 'reminder';
  title: string;
  description: string;
  date: Date;
  cost?: number;
  attachments?: string[];
  metadata?: Record<string, any>;
  createdAt: Date;
}
```

**Examples**:
- Car oil change log
- Light bulb replacement note
- Rental property expense

#### 4. Tracker Entries (Daily logs)
```typescript
interface TrackerEntry {
  id: string;
  entityTypeId: string; // which tracker (e.g., "Water Intake")
  date: Date; // date of tracking
  value: any; // the tracked value
  notes?: string;
  createdAt: Date;
}
```

**Examples**:
- Water intake: {date: "2025-11-16", value: 64, notes: "Felt hydrated"}
- Exercise: {date: "2025-11-16", value: 30, notes: "Morning run"}

#### 5. Reminders
```typescript
interface Reminder {
  id: string;
  entityId?: string; // optional link to project
  title: string;
  description?: string;
  dueDate: Date;
  recurring?: {
    frequency: 'daily' | 'weekly' | 'monthly' | 'yearly';
    interval: number;
  };
  completed: boolean;
  completedAt?: Date;
}
```

---

## UI/UX Design

### Layout Structure
```
┌─────────────────────────────────────────────────────┐
│  Life Tracker                          [⚙ Settings] │
├─────────────────────────────────────────────────────┤
│  [Projects]  [Trackers]                             │
├─────────────────────────────────────────────────────┤
│                                                      │
│  Content Area (changes based on active tab)         │
│                                                      │
│                                                      │
│                                                      │
└─────────────────────────────────────────────────────┘
```

### Projects View
```
┌─────────────────────────────────────────────────────┐
│  Big Projects                        [+ New Project]│
├─────────────────────────────────────────────────────┤
│  🚗 2015 Honda Civic                                │
│     Last maintenance: 2 weeks ago                    │
│     Next service: In 3 months                        │
├─────────────────────────────────────────────────────┤
│  🏠 123 Main St Rental                              │
│     Tenant: John Doe                                 │
│     Lease expires: Mar 2026                          │
├─────────────────────────────────────────────────────┤
│                                                      │
│  Micro Projects                      [+ New Micro]  │
├─────────────────────────────────────────────────────┤
│  💡 Kitchen Ceiling Light                           │
│     Type: LED 60W | Changed: 3 months ago           │
├─────────────────────────────────────────────────────┤
│  💡 Bathroom Vanity                                 │
│     Type: LED 40W | Changed: 1 year ago             │
└─────────────────────────────────────────────────────┘
```

### Project Detail View
```
┌─────────────────────────────────────────────────────┐
│  ← Back to Projects                                 │
├─────────────────────────────────────────────────────┤
│  🚗 2015 Honda Civic                    [Edit] [⋮]  │
├─────────────────────────────────────────────────────┤
│  Details                                             │
│  Make: Honda                                         │
│  Model: Civic                                        │
│  Year: 2015                                          │
│  VIN: 1HGBH41JXMN109186                             │
├─────────────────────────────────────────────────────┤
│  Maintenance Log                    [+ Add Entry]   │
├─────────────────────────────────────────────────────┤
│  Nov 1, 2025 - Oil Change                   $45.00  │
│  Changed oil and filter at 85,000 miles              │
├─────────────────────────────────────────────────────┤
│  Sep 15, 2025 - Tire Rotation              $30.00  │
│  Rotated all four tires                              │
├─────────────────────────────────────────────────────┤
│  Future Notes                          [+ Add Note] │
├─────────────────────────────────────────────────────┤
│  ⚠ Next oil change due at 90,000 miles              │
│  📅 Inspection due: March 2026                      │
└─────────────────────────────────────────────────────┘
```

### Trackers View
```
┌─────────────────────────────────────────────────────┐
│  Daily Trackers - Nov 16, 2025                      │
├─────────────────────────────────────────────────────┤
│  💧 Water Intake                                    │
│  [        64 oz       ] Target: 64 oz  ✓            │
│  ●●●●●●●○ (7-day streak)                            │
├─────────────────────────────────────────────────────┤
│  🏃 Exercise                                        │
│  [        30 min      ] Target: 30 min  ✓           │
│  ●●●●○○○ (4-day streak)                             │
├─────────────────────────────────────────────────────┤
│  😴 Sleep                                           │
│  [        7.5 hrs     ] Target: 8 hrs               │
│  ●●●●●●○ (6-day streak)                             │
├─────────────────────────────────────────────────────┤
│  [+ Add Tracker]                     [View Trends]  │
└─────────────────────────────────────────────────────┘
```

### Settings View
```
┌─────────────────────────────────────────────────────┐
│  Settings                                            │
├─────────────────────────────────────────────────────┤
│  Project Types                                       │
│  > Manage Big Project Types (3)                     │
│  > Manage Micro Project Types (2)                   │
├─────────────────────────────────────────────────────┤
│  Tracker Types                                       │
│  > Manage Daily Trackers (5)                        │
├─────────────────────────────────────────────────────┤
│  Data Management                                     │
│  > Export Data (JSON/CSV)                           │
│  > Import Data                                       │
│  > Backup Database                                   │
├─────────────────────────────────────────────────────┤
│  Appearance                                          │
│  > Theme: [Light ▼]                                 │
│  > Color Scheme: [Blue ▼]                           │
└─────────────────────────────────────────────────────┘
```

### Configuration UI (Create/Edit Entity Type)
```
┌─────────────────────────────────────────────────────┐
│  Create New Project Type                            │
├─────────────────────────────────────────────────────┤
│  Name: [Car                    ]                    │
│  Category: [○ Big  ○ Micro]                         │
│  Icon: [🚗 ▼]                                        │
│  Color: [🔵 ▼]                                       │
├─────────────────────────────────────────────────────┤
│  Custom Fields                      [+ Add Field]   │
├─────────────────────────────────────────────────────┤
│  1. Make          [Text     ▼]  [✓ Required]  [✕]  │
│  2. Model         [Text     ▼]  [✓ Required]  [✕]  │
│  3. Year          [Number   ▼]  [✓ Required]  [✕]  │
│  4. VIN           [Text     ▼]  [  Required]  [✕]  │
│  5. License Plate [Text     ▼]  [  Required]  [✕]  │
│  6. Mileage       [Number   ▼]  [  Required]  [✕]  │
├─────────────────────────────────────────────────────┤
│                          [Cancel]  [Save]           │
└─────────────────────────────────────────────────────┘
```

---

## Technical Architecture

### Frontend Stack
- **Framework**: React 18 with TypeScript
- **Build Tool**: Vite
- **State Management**: Context API + useReducer (or Zustand if needed)
- **Routing**: React Router v6
- **Forms**: React Hook Form
- **Validation**: Zod
- **Date Handling**: date-fns
- **Charts**: Recharts (for tracker trends)
- **Styling**: CSS Modules + Tailwind (or pure CSS)

### Database Layer
- **Database**: SQLite (better-sqlite3)
- **Location**: Local file system (`~/.life-tracker/data.db`)
- **Schema Migrations**: Simple version tracking in code
- **Backup**: Automatic daily backups to `~/.life-tracker/backups/`

### Database Schema (SQLite)

```sql
-- Entity Types (project/tracker definitions)
CREATE TABLE entity_types (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  type TEXT NOT NULL CHECK(type IN ('project', 'tracker')),
  category TEXT CHECK(category IN ('big', 'micro', 'daily')),
  icon TEXT,
  color TEXT,
  field_definitions TEXT, -- JSON
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);

-- Entities (actual project/tracker instances)
CREATE TABLE entities (
  id TEXT PRIMARY KEY,
  entity_type_id TEXT NOT NULL,
  name TEXT NOT NULL,
  field_values TEXT, -- JSON
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  archived_at TEXT,
  FOREIGN KEY (entity_type_id) REFERENCES entity_types(id)
);

-- Logs (maintenance, notes, costs)
CREATE TABLE logs (
  id TEXT PRIMARY KEY,
  entity_id TEXT NOT NULL,
  log_type TEXT NOT NULL CHECK(log_type IN ('maintenance', 'note', 'cost', 'reminder')),
  title TEXT NOT NULL,
  description TEXT,
  date TEXT NOT NULL,
  cost REAL,
  attachments TEXT, -- JSON array
  metadata TEXT, -- JSON
  created_at TEXT NOT NULL,
  FOREIGN KEY (entity_id) REFERENCES entities(id)
);

-- Tracker Entries (daily tracker data)
CREATE TABLE tracker_entries (
  id TEXT PRIMARY KEY,
  entity_type_id TEXT NOT NULL,
  date TEXT NOT NULL,
  value TEXT NOT NULL, -- JSON (can be number, string, etc.)
  notes TEXT,
  created_at TEXT NOT NULL,
  FOREIGN KEY (entity_type_id) REFERENCES entity_types(id)
);

-- Reminders
CREATE TABLE reminders (
  id TEXT PRIMARY KEY,
  entity_id TEXT,
  title TEXT NOT NULL,
  description TEXT,
  due_date TEXT NOT NULL,
  recurring_config TEXT, -- JSON
  completed INTEGER DEFAULT 0,
  completed_at TEXT,
  FOREIGN KEY (entity_id) REFERENCES entities(id)
);

-- Indexes for performance
CREATE INDEX idx_entities_type ON entities(entity_type_id);
CREATE INDEX idx_logs_entity ON logs(entity_id);
CREATE INDEX idx_tracker_entries_type_date ON tracker_entries(entity_type_id, date);
CREATE INDEX idx_reminders_due_date ON reminders(due_date);
```

### Application Architecture

```
src/
├── components/
│   ├── common/           # Reusable UI components
│   │   ├── Button.tsx
│   │   ├── Input.tsx
│   │   ├── Modal.tsx
│   │   └── Card.tsx
│   ├── projects/
│   │   ├── ProjectList.tsx
│   │   ├── ProjectCard.tsx
│   │   ├── ProjectDetail.tsx
│   │   └── MaintenanceLog.tsx
│   ├── trackers/
│   │   ├── TrackerList.tsx
│   │   ├── TrackerEntry.tsx
│   │   ├── TrackerChart.tsx
│   │   └── StreakIndicator.tsx
│   ├── settings/
│   │   ├── SettingsMenu.tsx
│   │   ├── EntityTypeEditor.tsx
│   │   └── FieldDefinitionEditor.tsx
│   └── layout/
│       ├── Header.tsx
│       ├── TabNavigation.tsx
│       └── Layout.tsx
├── services/
│   ├── database.ts       # SQLite connection & initialization
│   ├── entityTypes.ts    # CRUD for entity types
│   ├── entities.ts       # CRUD for entities
│   ├── logs.ts           # CRUD for logs
│   ├── trackers.ts       # CRUD for tracker entries
│   └── reminders.ts      # CRUD for reminders
├── hooks/
│   ├── useEntityTypes.ts
│   ├── useEntities.ts
│   ├── useLogs.ts
│   ├── useTrackers.ts
│   └── useReminders.ts
├── context/
│   ├── AppContext.tsx    # Global app state
│   └── SettingsContext.tsx
├── types/
│   └── index.ts          # TypeScript interfaces
├── utils/
│   ├── validation.ts
│   ├── formatting.ts
│   └── export.ts
├── App.tsx
└── main.tsx
```

---

## Implementation Roadmap

### Phase 1: Foundation (Week 1)
**Goal**: Basic app structure and database setup

- [ ] Set up React + Vite + TypeScript
- [ ] Configure SQLite database
- [ ] Create database schema and migrations
- [ ] Build basic tab navigation
- [ ] Create layout components
- [ ] Set up routing

**Deliverable**: Empty app shell with tabs and working database

### Phase 2: Projects MVP (Week 2)
**Goal**: Create and view basic projects

- [ ] Build entity types management (create/edit/delete project types)
- [ ] Implement field definition builder
- [ ] Create project CRUD operations
- [ ] Build project list view
- [ ] Build project detail view
- [ ] Add sample project types (Car, Light Bulb)

**Deliverable**: Can create custom project types and project instances

### Phase 3: Maintenance Logs (Week 3)
**Goal**: Track project history

- [ ] Build log entry form
- [ ] Create log list view
- [ ] Add cost tracking
- [ ] Implement filtering/sorting
- [ ] Add attachment support (file paths)
- [ ] Create future notes section

**Deliverable**: Full project maintenance tracking

### Phase 4: Daily Trackers (Week 4)
**Goal**: Track daily habits

- [ ] Create tracker type management
- [ ] Build quick entry forms
- [ ] Implement date-based entry storage
- [ ] Create calendar view
- [ ] Add streak calculation
- [ ] Build simple visualization (bar charts)

**Deliverable**: Working daily habit tracking

### Phase 5: Polish & Features (Week 5-6)
**Goal**: Make it production-ready

- [ ] Add search functionality
- [ ] Implement data export (JSON/CSV)
- [ ] Implement data import
- [ ] Add backup/restore
- [ ] Create reminder system
- [ ] Add theme support
- [ ] Polish UI/UX
- [ ] Add keyboard shortcuts
- [ ] Performance optimization

**Deliverable**: Polished, feature-complete app

### Phase 6: Advanced Features (Future)
- [ ] Multi-user support (with accounts)
- [ ] Cloud sync (optional)
- [ ] Mobile responsive design
- [ ] PWA capabilities (offline-first)
- [ ] Advanced reporting/analytics
- [ ] Recurring reminders
- [ ] Batch operations
- [ ] Data visualization dashboard
- [ ] Custom themes
- [ ] Plugin system

---

## Key User Flows

### Flow 1: Create a New Project Type
1. User goes to Settings
2. Clicks "Manage Big Project Types"
3. Clicks "+ Add Project Type"
4. Enters name (e.g., "Car")
5. Selects category (Big)
6. Chooses icon and color
7. Adds fields:
   - Make (Text, Required)
   - Model (Text, Required)
   - Year (Number, Required)
8. Clicks "Save"
9. New project type is available

### Flow 2: Add a New Project
1. User goes to Projects tab
2. Clicks "+ New Project"
3. Selects project type "Car"
4. Fills in fields:
   - Make: "Honda"
   - Model: "Civic"
   - Year: 2015
5. Clicks "Save"
6. Car appears in project list

### Flow 3: Log Maintenance
1. User opens "2015 Honda Civic" project
2. Scrolls to Maintenance Log
3. Clicks "+ Add Entry"
4. Fills in:
   - Title: "Oil Change"
   - Date: Nov 16, 2025
   - Description: "Changed oil and filter"
   - Cost: $45.00
5. Clicks "Save"
6. Entry appears in log

### Flow 4: Track Daily Habit
1. User goes to Trackers tab
2. Sees "Water Intake" tracker
3. Enters value: 64 oz
4. Sees checkmark (goal met!)
5. Streak counter increments
6. Chart updates with new data point

---

## Data Examples

### Example 1: Car Project Type
```json
{
  "id": "et_001",
  "name": "Car",
  "type": "project",
  "category": "big",
  "icon": "🚗",
  "color": "#3B82F6",
  "fieldDefinitions": [
    {
      "id": "fd_001",
      "name": "Make",
      "fieldType": "text",
      "required": true
    },
    {
      "id": "fd_002",
      "name": "Model",
      "fieldType": "text",
      "required": true
    },
    {
      "id": "fd_003",
      "name": "Year",
      "fieldType": "number",
      "required": true,
      "validations": {
        "min": 1900,
        "max": 2030
      }
    },
    {
      "id": "fd_004",
      "name": "VIN",
      "fieldType": "text",
      "required": false
    }
  ]
}
```

### Example 2: Car Entity Instance
```json
{
  "id": "e_001",
  "entityTypeId": "et_001",
  "name": "2015 Honda Civic",
  "fieldValues": {
    "fd_001": "Honda",
    "fd_002": "Civic",
    "fd_003": 2015,
    "fd_004": "1HGBH41JXMN109186"
  },
  "createdAt": "2025-11-16T10:00:00Z",
  "updatedAt": "2025-11-16T10:00:00Z"
}
```

### Example 3: Light Bulb Project Type (Micro)
```json
{
  "id": "et_002",
  "name": "Light Bulb",
  "type": "project",
  "category": "micro",
  "icon": "💡",
  "color": "#FCD34D",
  "fieldDefinitions": [
    {
      "id": "fd_005",
      "name": "Location",
      "fieldType": "text",
      "required": true
    },
    {
      "id": "fd_006",
      "name": "Type",
      "fieldType": "dropdown",
      "required": true,
      "options": ["LED 40W", "LED 60W", "LED 100W", "Incandescent", "CFL"]
    },
    {
      "id": "fd_007",
      "name": "Date Installed",
      "fieldType": "date",
      "required": true
    }
  ]
}
```

### Example 4: Water Intake Tracker Type
```json
{
  "id": "et_003",
  "name": "Water Intake",
  "type": "tracker",
  "category": "daily",
  "icon": "💧",
  "color": "#06B6D4",
  "fieldDefinitions": [
    {
      "id": "fd_008",
      "name": "Ounces",
      "fieldType": "number",
      "required": true,
      "validations": {
        "min": 0,
        "max": 200
      }
    },
    {
      "id": "fd_009",
      "name": "Target",
      "fieldType": "number",
      "required": false,
      "defaultValue": 64
    }
  ]
}
```

---

## Success Metrics

### User Experience
- Time to create new project type: < 2 minutes
- Time to log maintenance: < 30 seconds
- Time to enter daily tracker: < 10 seconds
- App load time: < 1 second

### Technical
- Database size: < 50MB for typical use (1000 entries)
- Query response time: < 100ms
- UI responsiveness: 60fps
- Bundle size: < 500KB

### Feature Adoption
- Average project types created: 5+
- Average projects tracked: 10+
- Daily tracker consistency: 3+ days/week
- User retention: 80%+ after 30 days

---

## Future Considerations

### Mobile App
- React Native version
- Shared data model
- Sync between devices

### Cloud Features
- Optional cloud backup
- Multi-device sync
- Sharing projects with family

### Integrations
- Export to Google Calendar (reminders)
- Import from CSV
- Photo attachments from phone

### AI Features
- Smart reminder suggestions
- Maintenance prediction (based on history)
- Cost analytics and trends
- Natural language entry ("Changed oil today for $45")

---

## Open Questions for Stakeholder

1. **Data Export**: What formats are most important? (CSV, JSON, PDF reports?)
2. **Photos**: Should we support inline photos or just file paths/links?
3. **Sharing**: Do you want to share data with family members?
4. **Reminders**: Desktop notifications? Email? Both?
5. **Cloud Sync**: Is this needed in v1, or local-only is fine?
6. **Mobile**: Should we plan for mobile from the start, or web-first?
7. **Recurring Trackers**: Should trackers have goals/targets built in?
8. **Tags**: Should projects/trackers support tags for filtering?

---

## Next Steps

1. **Review this plan** - Confirm the vision aligns with your needs
2. **Answer open questions** - Help prioritize features
3. **Approve roadmap** - Confirm phase priorities
4. **Start Phase 1** - Begin implementation once approved

---

*This is a living document. As we learn from building and using the app, we'll refine the plan.*
