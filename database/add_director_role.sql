-- ================================================================
-- THÊM ROLE GIÁM ĐỐC (Director) VÀO HỆ THỐNG
-- Chạy script này trên database HRM_System đã tồn tại
-- ================================================================
USE HRM_System;

-- 1. Thêm role Giám đốc
INSERT INTO roles (role_id, role_name, description) VALUES
(4, 'Director', 'Giám đốc - Quyền xem tổng quan toàn hệ thống');

-- 2. Phân quyền cho Giám đốc: xem tất cả, không chỉnh sửa
INSERT INTO role_permissions (role_id, permission_id) VALUES
(4, 2),   -- USER_VIEW
(4, 3),   -- ROLE_VIEW
(4, 5),   -- ROLE_PERMISSION_VIEW
(4, 7),   -- DEPARTMENT_VIEW
(4, 9),   -- POSITION_VIEW
(4, 11),  -- WORK_LOCATION_VIEW
(4, 13),  -- ATTENDANCE_VIEW
(4, 15),  -- LEAVE_VIEW
(4, 18),  -- PAYROLL_VIEW
(4, 20);  -- REPORT_VIEW

-- 3. Cập nhật tài khoản giam_doc sang role Giám đốc (4)
UPDATE users SET role_id = 4 WHERE username = 'giam_doc';
