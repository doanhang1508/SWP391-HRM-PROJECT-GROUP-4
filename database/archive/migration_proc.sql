-- Migration: Payroll Tax & Insurance Base Fix
-- Dung stored procedure de kiem tra column truoc khi ALTER (tuong thich MySQL 8.0)

USE HRM_System;

DROP PROCEDURE IF EXISTS add_col_safe;

DELIMITER $$
CREATE PROCEDURE add_col_safe()
BEGIN
  -- Them is_bhxh_applied vao reward_disciplines
  IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'HRM_System'
      AND TABLE_NAME   = 'reward_disciplines'
      AND COLUMN_NAME  = 'is_bhxh_applied'
  ) THEN
    ALTER TABLE reward_disciplines
      ADD COLUMN is_bhxh_applied TINYINT(1) NOT NULL DEFAULT 0;
  END IF;

  -- Them is_taxable vao reward_disciplines
  IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'HRM_System'
      AND TABLE_NAME   = 'reward_disciplines'
      AND COLUMN_NAME  = 'is_taxable'
  ) THEN
    ALTER TABLE reward_disciplines
      ADD COLUMN is_taxable TINYINT(1) NOT NULL DEFAULT 1;
  END IF;

  -- Them insurance_base_amount vao payroll
  IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'HRM_System'
      AND TABLE_NAME   = 'payroll'
      AND COLUMN_NAME  = 'insurance_base_amount'
  ) THEN
    ALTER TABLE payroll
      ADD COLUMN insurance_base_amount DECIMAL(15,2) DEFAULT 0;
  END IF;

  -- Them taxable_income_base vao payroll
  IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'HRM_System'
      AND TABLE_NAME   = 'payroll'
      AND COLUMN_NAME  = 'taxable_income_base'
  ) THEN
    ALTER TABLE payroll
      ADD COLUMN taxable_income_base DECIMAL(15,2) DEFAULT 0;
  END IF;
END$$
DELIMITER ;

CALL add_col_safe();
DROP PROCEDURE IF EXISTS add_col_safe;

-- Cap nhat seed data
UPDATE reward_disciplines SET is_bhxh_applied = 0, is_taxable = 0 WHERE id = 1;

INSERT INTO reward_disciplines (id, name, type, description, apply_level, is_bhxh_applied, is_taxable, created_by)
VALUES (9, 'Thuong Nang suat', 'Reward', 'Thuong theo nang suat, mien BHXH va thue', 'Ca nhan', 0, 0, 1)
ON DUPLICATE KEY UPDATE is_bhxh_applied = 0, is_taxable = 0;

-- Verify
SELECT id, name, is_bhxh_applied, is_taxable FROM reward_disciplines ORDER BY id;
SELECT COLUMN_NAME, DATA_TYPE, COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'HRM_System'
  AND TABLE_NAME = 'payroll'
  AND COLUMN_NAME IN ('insurance_base_amount', 'taxable_income_base');
