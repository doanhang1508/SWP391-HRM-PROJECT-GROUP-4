-- =====================================================
-- RESET PAYROLL DATA FOR TESTING
-- Chay file nay de xoa toan bo bang luong de test lai
-- WARNING: Khong chay tren production!
-- =====================================================

USE HRM_System;

-- Tat safe update mode (can thiet khi chay tren MySQL Workbench)
SET SQL_SAFE_UPDATES = 0;

-- Xoa toan bo bang luong
DELETE FROM payroll;

-- Bat lai safe update mode
SET SQL_SAFE_UPDATES = 1;

-- Reset auto_increment ve 1
ALTER TABLE payroll AUTO_INCREMENT = 1;

-- Verify: kiem tra da xoa het chua
SELECT COUNT(*) AS so_ban_ghi_con_lai FROM payroll;
