import Database from 'better-sqlite3';
import path from 'path';
import { fileURLToPath } from 'url';
import fs from 'fs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Database path - create in project root for now
// In production, this could be ~/.life-tracker/data.db
const DB_DIR = path.join(__dirname, '../../data');
const DB_PATH = path.join(DB_DIR, 'life-tracker.db');

// Ensure data directory exists
if (!fs.existsSync(DB_DIR)) {
  fs.mkdirSync(DB_DIR, { recursive: true });
}

let db: Database.Database | null = null;

export function getDatabase(): Database.Database {
  if (!db) {
    db = new Database(DB_PATH);
    db.pragma('journal_mode = WAL');
    initializeSchema();
  }
  return db;
}

function initializeSchema(): void {
  const db = getDatabase();

  // Create tables
  db.exec(`
    -- Entity Types (project/tracker definitions)
    CREATE TABLE IF NOT EXISTS entity_types (
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
    CREATE TABLE IF NOT EXISTS entities (
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
    CREATE TABLE IF NOT EXISTS logs (
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
    CREATE TABLE IF NOT EXISTS tracker_entries (
      id TEXT PRIMARY KEY,
      entity_type_id TEXT NOT NULL,
      date TEXT NOT NULL,
      value TEXT NOT NULL, -- JSON (can be number, string, etc.)
      notes TEXT,
      created_at TEXT NOT NULL,
      FOREIGN KEY (entity_type_id) REFERENCES entity_types(id)
    );

    -- Reminders
    CREATE TABLE IF NOT EXISTS reminders (
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
    CREATE INDEX IF NOT EXISTS idx_entities_type ON entities(entity_type_id);
    CREATE INDEX IF NOT EXISTS idx_logs_entity ON logs(entity_id);
    CREATE INDEX IF NOT EXISTS idx_tracker_entries_type_date ON tracker_entries(entity_type_id, date);
    CREATE INDEX IF NOT EXISTS idx_reminders_due_date ON reminders(due_date);
  `);

  console.log('Database initialized successfully');
}

export function closeDatabase(): void {
  if (db) {
    db.close();
    db = null;
  }
}

// Utility function to generate unique IDs
export function generateId(prefix: string): string {
  const timestamp = Date.now();
  const random = Math.random().toString(36).substring(2, 9);
  return `${prefix}_${timestamp}_${random}`;
}

// Utility function to get current ISO timestamp
export function getCurrentTimestamp(): string {
  return new Date().toISOString();
}
