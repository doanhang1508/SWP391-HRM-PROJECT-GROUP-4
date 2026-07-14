USE HRM_System;

ALTER TABLE reward_disciplines ADD COLUMN IF NOT EXISTS is_bhxh_applied TINYINT(1) NOT NULL DEFAULT 0;
ALTER TABLE reward_disciplines ADD COLUMN IF NOT EXISTS is_taxable TINYINT(1) NOT NULL DEFAULT 1;

UPDATE reward_disciplines SET is_bhxh_applied = 0, is_taxable = 0 WHERE id = 1;

INSERT INTO reward_disciplines (id, name, type, description, apply_level, is_bhxh_applied, is_taxable, created_by)
VALUES (9, 'Thuong Nang suat', 'Reward', 'Thuong theo nang suat lao dong, mien BHXH va thue TNCN', 'Ca nhan', 0, 0, 1)
ON DUPLICATE KEY UPDATE is_bhxh_applied = 0, is_taxable = 0;

ALTER TABLE payroll ADD COLUMN IF NOT EXISTS insurance_base_amount DECIMAL(15,2) DEFAULT 0;
ALTER TABLE payroll ADD COLUMN IF NOT EXISTS taxable_income_base DECIMAL(15,2) DEFAULT 0;

SELECT id, name, is_bhxh_applied, is_taxable FROM reward_disciplines ORDER BY id;
DESCRIBE payroll;
