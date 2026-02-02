-- Relational schema for dynamic tables, fields, and records.
-- Designed for SQLite/PostgreSQL-style SQL (minor tweaks may be needed per engine).

-- Core table definitions (metadata).
CREATE TABLE data_table (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE table_field (
    id INTEGER PRIMARY KEY,
    table_id INTEGER NOT NULL REFERENCES data_table(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    data_type TEXT NOT NULL CHECK (
        data_type IN ('string', 'date', 'image', 'checkbox', 'number', 'choice', 'reference')
    ),
    choices_text TEXT,
    reference_table_id INTEGER REFERENCES data_table(id) ON DELETE SET NULL,
    position INTEGER NOT NULL DEFAULT 0,
    is_required INTEGER NOT NULL DEFAULT 0,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (table_id, name)
);

-- Records for each dynamic table.
CREATE TABLE table_record (
    id INTEGER PRIMARY KEY,
    table_id INTEGER NOT NULL REFERENCES data_table(id) ON DELETE CASCADE,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Field values for each record (EAV-style to support dynamic schemas).
CREATE TABLE record_value (
    id INTEGER PRIMARY KEY,
    record_id INTEGER NOT NULL REFERENCES table_record(id) ON DELETE CASCADE,
    field_id INTEGER NOT NULL REFERENCES table_field(id) ON DELETE CASCADE,
    value_text TEXT,
    value_number REAL,
    value_date TEXT,
    value_boolean INTEGER,
    value_blob BLOB,
    UNIQUE (record_id, field_id)
);

-- Helpful indexes.
CREATE INDEX idx_table_field_table_id ON table_field(table_id);
CREATE INDEX idx_table_record_table_id ON table_record(table_id);
CREATE INDEX idx_record_value_record_id ON record_value(record_id);
CREATE INDEX idx_record_value_field_id ON record_value(field_id);
