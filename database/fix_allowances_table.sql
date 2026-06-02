-- ================================================================
-- PATCH: Sửa bảng allowances – thêm cột amount & apply_condition
-- Chạy script này nếu không muốn chạy lại toàn bộ HRM_database.sql
-- ================================================================

USE HRM_System;

-- Bước 1: Thêm cột amount (nếu chưa có)
ALTER TABLE allowances
    ADD COLUMN IF NOT EXISTS amount DECIMAL(15,2) NOT NULL DEFAULT 0 AFTER description,
    ADD COLUMN IF NOT EXISTS apply_condition VARCHAR(255) AFTER amount;

-- Bước 2: Xóa dữ liệu cũ (nếu có) và insert lại đúng
DELETE FROM allowances;

-- Bước 3: Insert seed data với đầy đủ cột
INSERT INTO allowances (allowance_id, allowance_name, description, amount, apply_condition) VALUES
(1, 'Ăn trưa',    'Phụ cấp ăn ca',              800000,  'Áp dụng cho tất cả nhân viên chính thức'),
(2, 'Đi lại',     'Phụ cấp xăng xe',             500000,  'Áp dụng cho nhân viên không ở trong ký túc xá'),
(3, 'Trách nhiệm','Cho quản đốc, tổ trưởng',    1000000,  'Áp dụng cho quản đốc và tổ trưởng'),
(4, 'Độc hại',    'Cho công nhân xưởng',          300000,  'Áp dụng cho công nhân làm việc trực tiếp tại xưởng'),
(5, 'Chuyên cần', 'Thưởng đi làm đầy đủ',        500000,  'Không nghỉ phép, không đi muộn trong tháng');

SELECT * FROM allowances;
