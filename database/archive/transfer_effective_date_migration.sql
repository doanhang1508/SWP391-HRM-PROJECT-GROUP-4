-- =========================================================================
-- Migration: Transfer Effective Date Flow
-- Them trang thai COMPLETED va cot applied_at cho transfer_requests
-- MySQL 5.7+  |  Ngay: 2026-07-02
-- =========================================================================
-- Y nghia 2 trang thai:
--   APPROVED   = HR Manager da duyet cuoi, CHUA ap dung (cho effective_date)
--   COMPLETED  = Da den ngay hieu luc, he thong da cap nhat dept/pos/role/contract
-- =========================================================================

SET FOREIGN_KEY_CHECKS = 0;

-- BUOC 1: Mo rong ENUM status
ALTER TABLE transfer_requests
  MODIFY COLUMN status
    ENUM(
      'PENDING',
      'EMPLOYEE_CONFIRMED',
      'MANAGER_APPROVED',
      'APPROVED',
      'COMPLETED',
      'REJECTED',
      'EMPLOYEE_REJECTED',
      'CANCELLED'
    ) NOT NULL DEFAULT 'PENDING';

-- BUOC 2: Them cot applied_at (neu chua ton tai)
DROP PROCEDURE IF EXISTS sp_add_applied_at;
DELIMITER $$
CREATE PROCEDURE sp_add_applied_at()
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME   = 'transfer_requests'
          AND COLUMN_NAME  = 'applied_at'
    ) THEN
        ALTER TABLE transfer_requests
          ADD COLUMN applied_at TIMESTAMP NULL
            COMMENT 'Thoi diem he thong thuc su thuc thi doi phong ban/chuc vu/vai tro (NULL = chua ap dung)'
            AFTER updated_at;
        SELECT 'Column applied_at added.' AS info;
    ELSE
        SELECT 'Column applied_at already exists, skipping.' AS info;
    END IF;
END$$
DELIMITER ;
CALL sp_add_applied_at();
DROP PROCEDURE IF EXISTS sp_add_applied_at;

-- BUOC 3: Migrate data cu
-- Cac don dang o APPROVED truoc migration coi nhu da duoc ap dung roi
-- -> chuyen thanh COMPLETED, applied_at = thoi diem approved/updated/now
UPDATE transfer_requests
SET
    status     = 'COMPLETED',
    applied_at = COALESCE(approved_at, updated_at, NOW())
WHERE status = 'APPROVED';

SET FOREIGN_KEY_CHECKS = 1;

-- KIEM TRA KET QUA
SELECT COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE, COLUMN_COMMENT
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME   = 'transfer_requests'
  AND COLUMN_NAME IN ('status', 'applied_at')
ORDER BY ORDINAL_POSITION;
