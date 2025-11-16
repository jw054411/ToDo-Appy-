// Core type definitions for the Life Tracker app

export type EntityTypeCategory = 'big' | 'micro' | 'daily';
export type EntityTypeType = 'project' | 'tracker';
export type FieldType = 'text' | 'number' | 'date' | 'dropdown' | 'checkbox' | 'textarea';
export type LogType = 'maintenance' | 'note' | 'cost' | 'reminder';
export type RecurringFrequency = 'daily' | 'weekly' | 'monthly' | 'yearly';

export interface FieldValidation {
  min?: number;
  max?: number;
  pattern?: string;
}

export interface FieldDefinition {
  id: string;
  name: string;
  fieldType: FieldType;
  required: boolean;
  defaultValue?: any;
  options?: string[]; // for dropdown
  validations?: FieldValidation;
}

export interface EntityType {
  id: string;
  name: string;
  type: EntityTypeType;
  category: EntityTypeCategory | null;
  icon: string;
  color: string;
  fieldDefinitions: FieldDefinition[];
  createdAt: string;
  updatedAt: string;
}

export interface Entity {
  id: string;
  entityTypeId: string;
  name: string;
  fieldValues: Record<string, any>; // JSON object with field values
  createdAt: string;
  updatedAt: string;
  archivedAt?: string;
}

export interface Log {
  id: string;
  entityId: string;
  logType: LogType;
  title: string;
  description: string;
  date: string;
  cost?: number;
  attachments?: string[];
  metadata?: Record<string, any>;
  createdAt: string;
}

export interface TrackerEntry {
  id: string;
  entityTypeId: string; // which tracker (e.g., "Water Intake")
  date: string; // date of tracking
  value: any; // the tracked value
  notes?: string;
  createdAt: string;
}

export interface RecurringConfig {
  frequency: RecurringFrequency;
  interval: number;
}

export interface Reminder {
  id: string;
  entityId?: string; // optional link to project
  title: string;
  description?: string;
  dueDate: string;
  recurring?: RecurringConfig;
  completed: boolean;
  completedAt?: string;
}

// Database table row types (with snake_case for SQLite)
export interface EntityTypeRow {
  id: string;
  name: string;
  type: string;
  category: string | null;
  icon: string;
  color: string;
  field_definitions: string; // JSON
  created_at: string;
  updated_at: string;
}

export interface EntityRow {
  id: string;
  entity_type_id: string;
  name: string;
  field_values: string; // JSON
  created_at: string;
  updated_at: string;
  archived_at?: string;
}

export interface LogRow {
  id: string;
  entity_id: string;
  log_type: string;
  title: string;
  description: string;
  date: string;
  cost?: number;
  attachments?: string; // JSON
  metadata?: string; // JSON
  created_at: string;
}

export interface TrackerEntryRow {
  id: string;
  entity_type_id: string;
  date: string;
  value: string; // JSON
  notes?: string;
  created_at: string;
}

export interface ReminderRow {
  id: string;
  entity_id?: string;
  title: string;
  description?: string;
  due_date: string;
  recurring_config?: string; // JSON
  completed: number; // SQLite boolean (0 or 1)
  completed_at?: string;
}
