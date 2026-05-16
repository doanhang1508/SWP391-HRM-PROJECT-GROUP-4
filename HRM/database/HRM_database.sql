/* DỰ ÁN: HUMAN RESOURCE MANAGEMENT (HRM)
GIAI ĐOẠN: TUẦN 1 - QUẢN LÝ NGƯỜI DÙNG & PHÂN QUYỀN
Mô tả: Script tự động xóa, tạo mới database và cung cấp bộ dữ liệu mẫu (Seed Data) chuẩn mực.
*/

-- 1. XÓA VÀ TẠO MỚI 
DROP DATABASE IF EXISTS HRM_System;
CREATE DATABASE HRM_System CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE HRM_System;

-- 2. TẮT KIỂM TRA KHÓA NGOẠI (Để tạo bảng trơn tru hơn)
SET FOREIGN_KEY_CHECKS = 0;

-- =============================================================
-- BẢNG 1: VAI TRÒ (Roles) 
-- =============================================================
CREATE TABLE roles (
    role_id INT PRIMARY KEY AUTO_INCREMENT,
    role_name VARCHAR(50) NOT NULL UNIQUE,      
    description VARCHAR(255),
    status TINYINT(1) DEFAULT 1                -- 1: Active, 0: Deactive
) ENGINE=InnoDB;

-- =============================================================
-- BẢNG 2: QUYỀN HẠN (Permissions)
-- =============================================================
CREATE TABLE permissions (
    permission_id INT PRIMARY KEY AUTO_INCREMENT,
    permission_name VARCHAR(100) NOT NULL UNIQUE, 
    description VARCHAR(255),
    module VARCHAR(50) -- Phân nhóm quyền (VD: USER, ROLE, ATTENDANCE, PAYROLL)
) ENGINE=InnoDB;

-- =============================================================
-- BẢNG 3: PHÂN QUYỀN CHO VAI TRÒ (Role_Permissions) 
-- =============================================================
CREATE TABLE role_permissions (
    role_id INT NOT NULL,
    permission_id INT NOT NULL,
    PRIMARY KEY (role_id, permission_id),
    FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE CASCADE,
    FOREIGN KEY (permission_id) REFERENCES permissions(permission_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- =============================================================
-- BẢNG 4: NGƯỜI DÙNG (Users) 
-- =============================================================
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,             
    full_name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    avatar_url VARCHAR(255),                    
    status TINYINT(1) DEFAULT 1,                
    role_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- 3. BẬT LẠI KIỂM TRA KHÓA NGOẠI
SET FOREIGN_KEY_CHECKS = 1;

-- =============================================================
-- DỮ LIỆU MẪU (SEED DATA) 
-- =============================================================

-- Thêm vai trò (Cố định ID để dễ map trong code)
INSERT INTO roles (role_id, role_name, description) VALUES 
(1, 'Admin',           'Quản trị viên toàn quyền hệ thống'),
(2, 'Manager',         'Quản lý nhân sự / Trưởng phòng'),
(3, 'Employee',        'Nhân viên thông thường'),
(4, 'HR Staff',        'Nhân viên phòng Nhân sự - hỗ trợ tuyển dụng, onboarding, quản lý hồ sơ'),
(5, 'Accountant',      'Kế toán - quản lý bảng lương, thuế, bảo hiểm'),
(6, 'Department Head', 'Trưởng bộ phận - quản lý nhân sự trong phòng ban');

-- Thêm hệ thống quyền hạn (Permissions) đầy đủ cho dự án HRM
INSERT INTO permissions (permission_id, permission_name, description, module) VALUES 
-- Nhóm Quản lý Người dùng (Feature 7-11)
(1,  'USER_VIEW',            'Xem danh sách người dùng',                  'USER'),
(2,  'USER_CREATE',          'Thêm mới người dùng',                       'USER'),
(3,  'USER_EDIT',            'Chỉnh sửa thông tin người dùng',            'USER'),
(4,  'USER_DELETE',          'Khóa/Xóa người dùng',                       'USER'),

-- Nhóm Quản lý Vai trò & Phân Quyền (Feature 12-16)
(5,  'ROLE_VIEW',            'Xem danh sách vai trò',                     'ROLE'),
(6,  'ROLE_EDIT',            'Chỉnh sửa vai trò và phân quyền',           'ROLE'),
(7,  'ROLE_PERMISSION_VIEW', 'Xem quyền hạn của vai trò',                 'ROLE'),
(8,  'ROLE_UPDATE_INFORMATION', 'Cập nhật thông tin vai trò',              'ROLE'),
(9,  'ROLE_TOGGLE_STATUS',   'Kích hoạt / Vô hiệu hóa vai trò',          'ROLE'),
(10, 'ROLE_PERMISSION_EDIT', 'Chỉnh sửa phân quyền cho vai trò',          'ROLE'),

-- Nhóm Quản lý Chấm công & Ngày phép
(11, 'ATTENDANCE_VIEW_ALL',  'Xem lịch sử chấm công của tất cả nhân viên','ATTENDANCE'),
(12, 'ATTENDANCE_CHECKIN',   'Chấm công vào/ra cho nhân viên',             'ATTENDANCE'),
(13, 'LEAVE_VIEW_ALL',       'Xem tất cả đơn xin nghỉ phép',              'LEAVE'),
(14, 'LEAVE_APPROVE',        'Duyệt đơn xin nghỉ phép',                   'LEAVE'),
(15, 'LEAVE_REQUEST',        'Gửi đơn xin nghỉ phép (nhân viên)',          'LEAVE'),

-- Nhóm Quản lý Lương & Tài chính
(16, 'PAYROLL_MANAGE',       'Tính và quản lý lương nhân viên',            'PAYROLL'),
(17, 'PAYROLL_VIEW',         'Xem bảng lương (chỉ xem)',                   'PAYROLL'),

-- Nhóm Báo cáo & Thống kê
(18, 'REPORT_VIEW',          'Xem báo cáo và thống kê hệ thống',          'REPORT'),
(19, 'REPORT_EXPORT',        'Xuất báo cáo (PDF, Excel)',                  'REPORT');

-- ══════════════════════════════════════════════════════════════
-- PHÂN QUYỀN CHO TỪNG VAI TRÒ
-- ══════════════════════════════════════════════════════════════

-- Admin (role_id = 1): Toàn quyền (tất cả 19 quyền)
INSERT INTO role_permissions (role_id, permission_id) VALUES 
(1,1),(1,2),(1,3),(1,4),(1,5),(1,6),(1,7),(1,8),(1,9),(1,10),
(1,11),(1,12),(1,13),(1,14),(1,15),(1,16),(1,17),(1,18),(1,19);

-- Manager (role_id = 2): Xem user, xem chấm công, duyệt phép, xem lương, xem báo cáo
INSERT INTO role_permissions (role_id, permission_id) VALUES 
(2,1),(2,11),(2,13),(2,14),(2,17),(2,18);

-- Employee (role_id = 3): Chỉ có quyền cơ bản (gửi đơn nghỉ phép)
INSERT INTO role_permissions (role_id, permission_id) VALUES 
(3,15);

-- HR Staff (role_id = 4): Quản lý user, xem vai trò, xem chấm công, xem đơn phép, báo cáo
INSERT INTO role_permissions (role_id, permission_id) VALUES 
(4,1),(4,2),(4,3),(4,4),(4,5),(4,7),(4,11),(4,12),(4,13),(4,14),(4,15),(4,18);

-- Accountant (role_id = 5): Xem user, quản lý lương, xem chấm công, xuất báo cáo
INSERT INTO role_permissions (role_id, permission_id) VALUES 
(5,1),(5,11),(5,16),(5,17),(5,18),(5,19);

-- Department Head (role_id = 6): Xem user, xem chấm công, duyệt phép, xem lương, báo cáo
INSERT INTO role_permissions (role_id, permission_id) VALUES 
(6,1),(6,11),(6,13),(6,14),(6,15),(6,17),(6,18);

-- ══════════════════════════════════════════════════════════════
-- TÀI KHOẢN MẪU (Mật khẩu: @123456)
-- ══════════════════════════════════════════════════════════════
INSERT INTO users (username, password, full_name, email, role_id) VALUES 
('admin',      '@123456', 'Hệ Thống Admin',       'admin@hrm.com',      1),
('manager1',   '@123456', 'Quản Lý Trần B',       'manager@hrm.com',    2),
('nhanvien1',  '@123456', 'Nguyễn Văn A',         'nva@hrm.com',        3),
('nhanvien2',  '@123456', 'Lê Thị C',             'ltc@hrm.com',        3),
('hr_staff1',  '@123456', 'Phạm Thị D (HR)',      'hr_staff@hrm.com',   4),
('ketoan1',    '@123456', 'Hoàng Văn E (Kế toán)','ketoan@hrm.com',     5),
('truongphong','@123456', 'Vũ Minh F (TP. Dev)',  'truongphong@hrm.com',6);
