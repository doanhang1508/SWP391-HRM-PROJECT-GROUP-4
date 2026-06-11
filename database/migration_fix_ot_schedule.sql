-- ================================================================
-- MIGRATION: Cho phép nhiều ca/ngày (ca chính + ca OT)
-- Chạy script này trên database HRM_System đang chạy
-- ================================================================

USE HRM_System;

-- 1. Xóa UNIQUE constraint cũ (user_id, assigned_date) — chặn nhiều ca/ngày
ALTER TABLE shift_assignments DROP INDEX idx_user_date;

-- 2. Thêm INDEX thường (tìm kiếm nhanh)
ALTER TABLE shift_assignments ADD INDEX idx_user_date (user_id, assigned_date);

-- 3. Thêm UNIQUE mới (user_id, shift_id, assigned_date) — cho phép nhiều ca khác nhau cùng ngày
ALTER TABLE shift_assignments ADD UNIQUE KEY idx_user_shift_date (user_id, shift_id, assigned_date);

-- Xong! Giờ nhân viên có thể có Ca Hành Chính + Ca OT cùng ngày.
