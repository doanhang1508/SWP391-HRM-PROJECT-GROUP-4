-- ================================================================
-- PAYROLL MIGRATION TONG HOP (MySQL Workbench compatible)
-- Tat ca cac buoc cua module Payroll Tax & Insurance fix
-- An toan chay nhieu lan (IF NOT EXISTS / ON DUPLICATE KEY)
-- ================================================================

USE HRM_System;
SET SQL_SAFE_UPDATES = 0;
SET NAMES utf8mb4;

-- ----------------------------------------------------------------
-- BUOC 1: Them cot is_bhxh_applied, is_taxable vao reward_disciplines
-- (dung stored procedure vi MySQL 8.0 khong co ADD COLUMN IF NOT EXISTS)
-- ----------------------------------------------------------------
DROP PROCEDURE IF EXISTS payroll_migration_step1;
DELIMITER $$
CREATE PROCEDURE payroll_migration_step1()
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'reward_disciplines' AND COLUMN_NAME = 'is_bhxh_applied'
    ) THEN
        ALTER TABLE reward_disciplines ADD COLUMN is_bhxh_applied TINYINT(1) NOT NULL DEFAULT 0;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'reward_disciplines' AND COLUMN_NAME = 'is_taxable'
    ) THEN
        ALTER TABLE reward_disciplines ADD COLUMN is_taxable TINYINT(1) NOT NULL DEFAULT 1;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'payroll' AND COLUMN_NAME = 'insurance_base_amount'
    ) THEN
        ALTER TABLE payroll ADD COLUMN insurance_base_amount DECIMAL(15,2) DEFAULT 0;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'payroll' AND COLUMN_NAME = 'taxable_income_base'
    ) THEN
        ALTER TABLE payroll ADD COLUMN taxable_income_base DECIMAL(15,2) DEFAULT 0;
    END IF;
END$$
DELIMITER ;

CALL payroll_migration_step1();
DROP PROCEDURE IF EXISTS payroll_migration_step1;

-- ----------------------------------------------------------------
-- BUOC 2: Cap nhat seed data reward_disciplines
-- ----------------------------------------------------------------

-- Thuong KPI: mien BHXH + mien Thue
UPDATE reward_disciplines SET is_bhxh_applied = 0, is_taxable = 0 WHERE id = 1;

-- Thuong Du an, Chuyen can: mien BHXH nhung chiu Thue (default is_taxable=1)
UPDATE reward_disciplines SET is_bhxh_applied = 0, is_taxable = 1 WHERE id IN (2, 3);

-- Ky luat: khong anh huong BHXH/Thue (default 0,1 la ok)
UPDATE reward_disciplines SET is_bhxh_applied = 0 WHERE id IN (4,5,6,7,8);

-- Them hoac cap nhat "Thuong Nang suat" (id=9) - ten dung tieng Viet
INSERT INTO reward_disciplines (id, name, type, description, apply_level, is_bhxh_applied, is_taxable, created_by)
VALUES (9, 'Thưởng Năng suất', 'Reward', 'Thưởng theo năng suất lao động, miễn BHXH và thuế TNCN', 'Cá nhân', 0, 0, 1)
ON DUPLICATE KEY UPDATE
    name            = 'Thưởng Năng suất',
    is_bhxh_applied = 0,
    is_taxable      = 0;

-- ----------------------------------------------------------------
-- BUOC 3: Reset auto_increment payroll neu can
-- (chi dat ve max+1 neu co du lieu, hoac ve 1 neu trong)
-- ----------------------------------------------------------------
SET @max_id = (SELECT IFNULL(MAX(payroll_id), 0) FROM payroll);
SET @next_id = @max_id + 1;
SET @stmt = CONCAT('ALTER TABLE payroll AUTO_INCREMENT = ', @next_id);
PREPARE reset_ai FROM @stmt;
EXECUTE reset_ai;
DEALLOCATE PREPARE reset_ai;

SET SQL_SAFE_UPDATES = 1;

-- ----------------------------------------------------------------
-- VERIFICATION: Kiem tra ket qua
-- ----------------------------------------------------------------
SELECT 'reward_disciplines' AS tbl, id, name, is_bhxh_applied, is_taxable FROM reward_disciplines ORDER BY id;

SELECT 'payroll columns' AS check_name, COLUMN_NAME, DATA_TYPE, COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'payroll'
  AND COLUMN_NAME IN ('insurance_base_amount', 'taxable_income_base', 'paid_by', 'paid_at', 'payment_note', 'approved_by');
