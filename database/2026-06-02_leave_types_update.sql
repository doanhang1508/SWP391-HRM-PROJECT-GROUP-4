-- Update leave_types schema for Leave Type Management fields
ALTER TABLE leave_types
    MODIFY COLUMN type_name VARCHAR(255) NOT NULL,
    ADD COLUMN description VARCHAR(500) NULL AFTER type_name,
    ADD COLUMN max_days_per_year INT NULL AFTER paid_leave,
    ADD UNIQUE KEY uk_leave_types_type_name (type_name);
