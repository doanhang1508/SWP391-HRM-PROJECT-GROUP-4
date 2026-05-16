/* ================================================================
   DỰ ÁN: HUMAN RESOURCE MANAGEMENT (HRM)
   GIAI ĐOẠN: TUẦN 1 - QUẢN LÝ NGƯỜI DÙNG & PHÂN QUYỀN
   Mô tả: Script tự động xóa, tạo mới database và cung cấp
          bộ dữ liệu mẫu (Seed Data) chuẩn mực.
   ================================================================ */

-- 1. XÓA VÀ TẠO MỚI
DROP DATABASE IF EXISTS HRM_System;
CREATE DATABASE HRM_System CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE HRM_System;

-- 2. TẮT KIỂM TRA KHÓA NGOẠI
SET FOREIGN_KEY_CHECKS = 0;

-- =============================================================
-- BẢNG 1: VAI TRÒ (roles)
-- =============================================================
CREATE TABLE roles (
    role_id     INT          PRIMARY KEY AUTO_INCREMENT,
    role_name   VARCHAR(50)  NOT NULL UNIQUE,
    description VARCHAR(255),
    status      TINYINT(1)   NOT NULL DEFAULT 1   -- 1: Active, 0: Inactive
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================
-- BẢNG 2: NGƯỜI DÙNG (users)
-- Tạo TRƯỚC notifications vì notifications FK về bảng này
-- =============================================================
CREATE TABLE users (
    user_id    INT          PRIMARY KEY AUTO_INCREMENT,
    username   VARCHAR(50)  NOT NULL UNIQUE,
    password   VARCHAR(255) NOT NULL,
    full_name  VARCHAR(100),
    email      VARCHAR(100) UNIQUE,
    phone      VARCHAR(20),
    avatar_url VARCHAR(255),
    status     TINYINT(1)   NOT NULL DEFAULT 1,   -- 1: Active, 0: Locked
    role_id    INT,
    created_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_user_role FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================
-- BẢNG 3: QUYỀN HẠN (permissions)
-- =============================================================
CREATE TABLE permissions (
    permission_id   INT          PRIMARY KEY AUTO_INCREMENT,
    permission_name VARCHAR(100) NOT NULL UNIQUE,
    description     VARCHAR(255),
    module          VARCHAR(50)  -- Nhóm quyền: USER, ROLE, ATTENDANCE, LEAVE, PAYROLL, KPI
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================
-- BẢNG 4: PHÂN QUYỀN CHO VAI TRÒ (role_permissions)
-- =============================================================
CREATE TABLE role_permissions (
    role_id       INT NOT NULL,
    permission_id INT NOT NULL,
    PRIMARY KEY (role_id, permission_id),
    CONSTRAINT fk_rp_role FOREIGN KEY (role_id)       REFERENCES roles(role_id)       ON DELETE CASCADE,
    CONSTRAINT fk_rp_perm FOREIGN KEY (permission_id) REFERENCES permissions(permission_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================
-- BẢNG 5: THÔNG BÁO (notifications)
-- FIX: FK trỏ về users(user_id) thay vì employees(id) chưa tồn tại
-- =============================================================
CREATE TABLE notifications (
    id          INT          NOT NULL AUTO_INCREMENT,
    employee_id INT          NOT NULL,               -- Trỏ về users.user_id
    type        VARCHAR(30)  NOT NULL DEFAULT 'system',
    -- Các giá trị type hợp lệ:
    -- 'attendance' | 'leave' | 'overtime' | 'payroll'
    -- 'kpi' | 'training' | 'system' | 'announcement' | 'shift'
    title       VARCHAR(120) NOT NULL,
    body        VARCHAR(255) NOT NULL DEFAULT '',
    link        VARCHAR(255) DEFAULT NULL,
    is_read     TINYINT(1)   NOT NULL DEFAULT 0,
    created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX idx_employee_read (employee_id, is_read),
    INDEX idx_created       (created_at),
    CONSTRAINT fk_notif_user FOREIGN KEY (employee_id)
        REFERENCES users(user_id) ON DELETE CASCADE  -- FIX: users thay vì employees
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. BẬT LẠI KIỂM TRA KHÓA NGOẠI
SET FOREIGN_KEY_CHECKS = 1;


-- =============================================================
-- SEED DATA
-- Thứ tự insert: roles → users → permissions → role_permissions → notifications
-- =============================================================

-- ── Vai trò ──
INSERT INTO roles (role_id, role_name, description) VALUES
(1, 'Admin',    'Quản trị viên toàn quyền hệ thống'),
(2, 'Manager',  'Quản lý nhân sự / Trưởng phòng'),
(3, 'Employee', 'Nhân viên thông thường');

-- ── Tài khoản mẫu (phải insert TRƯỚC notifications) ──
-- Lưu ý: password thực tế cần hash (BCrypt). Để test dùng plain text tạm thời.
INSERT INTO users (user_id, username, password, full_name, email, role_id) VALUES
(1, 'admin',      '@123456', 'Hệ Thống Admin',   'admin@hrm.com',   1),
(2, 'manager1',   '@123456', 'Quản Lý Trần B',   'manager@hrm.com', 2),
(3, 'nhanvien1',  '@123456', 'Nguyễn Văn A',     'nva@hrm.com',     3),
(4, 'nhanvien2',  '@123456', 'Lê Thị C',         'ltc@hrm.com',     3);

-- ── Quyền hạn ──
INSERT INTO permissions (permission_id, permission_name, description, module) VALUES
-- Quản lý người dùng
(1, 'USER_VIEW',            'Xem danh sách người dùng',                     'USER'),
(2, 'USER_CREATE',          'Thêm mới người dùng',                          'USER'),
(3, 'USER_EDIT',            'Chỉnh sửa thông tin người dùng',               'USER'),
(4, 'USER_DELETE',          'Khóa / Xóa người dùng',                       'USER'),
-- Quản lý phân quyền
(5, 'ROLE_VIEW',            'Xem danh sách vai trò và quyền',               'ROLE'),
(6, 'ROLE_EDIT',            'Chỉnh sửa vai trò và phân quyền',              'ROLE'),
-- Chấm công & Nghỉ phép
(7, 'ATTENDANCE_VIEW_ALL',  'Xem lịch sử chấm công của tất cả nhân viên',   'ATTENDANCE'),
(8, 'LEAVE_APPROVE',        'Duyệt đơn xin nghỉ phép',                      'LEAVE'),
-- Lương
(9, 'PAYROLL_MANAGE',       'Tính và quản lý lương nhân viên',              'PAYROLL');

-- ── Phân quyền cho Admin (toàn bộ quyền 1–9) ──
INSERT INTO role_permissions (role_id, permission_id) VALUES
(1,1),(1,2),(1,3),(1,4),(1,5),(1,6),(1,7),(1,8),(1,9);

-- ── Phân quyền cho Manager ──
INSERT INTO role_permissions (role_id, permission_id) VALUES
(2,1),(2,7),(2,8);

-- Lưu ý: Employee không gán quyền vào bảng này;
-- họ chỉ dùng các chức năng mặc định (tự xem hồ sơ, tự chấm công...).

-- ── Thông báo mẫu (employee_id = 1 = admin, đã tồn tại ở trên) ──
INSERT INTO notifications (employee_id, type, title, body, link) VALUES
(1, 'leave',        'Đơn nghỉ phép được duyệt',      'HR đã duyệt đơn xin nghỉ 2 ngày của bạn.',      '/leave/detail?id=5'),
(1, 'payroll',      'Đã chuyển lương tháng 5/2026',   'Vui lòng kiểm tra phiếu lương trong hệ thống.', '/payroll/slip'),
(1, 'attendance',   'Quên chấm công ra — 13/05',      'Bạn chưa có dữ liệu chấm công ra ngày 13/05.',  '/attendance/correct'),
(1, 'system',       'Cập nhật chính sách làm việc',   'Nội quy mới có hiệu lực từ ngày 01/06/2026.',   '/announcements/12'),
(1, 'kpi',          'KPI tháng 5 đang ở mức 80%',     'Còn 16 ngày để hoàn thành mục tiêu tháng này.','/kpi/me');


