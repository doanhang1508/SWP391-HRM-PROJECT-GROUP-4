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
(1, 'Admin', 'Quản trị viên toàn quyền hệ thống'),
(2, 'Manager', 'Quản lý nhân sự / Trưởng phòng'),
(3, 'Employee', 'Nhân viên thông thường');

-- Thêm hệ thống quyền hạn (Permissions) đầy đủ cho dự án HRM
INSERT INTO permissions (permission_id, permission_name, description, module) VALUES 
-- Nhóm Quản lý Người dùng
(1, 'USER_VIEW', 'Xem danh sách người dùng', 'USER'),
(2, 'USER_CREATE', 'Thêm mới người dùng', 'USER'),
(3, 'USER_EDIT', 'Chỉnh sửa thông tin người dùng', 'USER'),
(4, 'USER_DELETE', 'Khóa/Xóa người dùng', 'USER'),

-- Nhóm Quản lý Phân Quyền
(5, 'ROLE_VIEW', 'Xem danh sách vai trò và quyền', 'ROLE'),
(6, 'ROLE_EDIT', 'Chỉnh sửa vai trò và phân quyền', 'ROLE'),

-- Nhóm Quản lý Chấm công & Ngày phép
(7, 'ATTENDANCE_VIEW_ALL', 'Xem lịch sử chấm công của tất cả nhân viên', 'ATTENDANCE'),
(8, 'LEAVE_APPROVE', 'Duyệt đơn xin nghỉ phép', 'LEAVE'),

-- Nhóm Quản lý Lương
(9, 'PAYROLL_MANAGE', 'Tính và quản lý lương nhân viên', 'PAYROLL');

-- Phân quyền cho Admin (Có tất cả quyền từ 1 đến 9)
INSERT INTO role_permissions (role_id, permission_id) VALUES 
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6), (1, 7), (1, 8), (1, 9);

-- Phân quyền cho Manager (Quản lý được xem user, duyệt phép, xem chấm công tổng hợp)
INSERT INTO role_permissions (role_id, permission_id) VALUES 
(2, 1), (2, 7), (2, 8);

-- *Lưu ý: Employee không cần gán quyền vào bảng này vì họ chỉ dùng các chức năng cơ bản mặc định (VD: tự xem hồ sơ, tự chấm công)*

-- Thêm tài khoản mẫu (Mật khẩu: @123456)
INSERT INTO users (username, password, full_name, email, role_id) VALUES 
('admin', '@123456', 'Hệ Thống Admin', 'admin@hrm.com', 1),
('manager1', '@123456', 'Quản Lý Trần B', 'manager@hrm.com', 2),
('nhanvien1', '@123456', 'Nguyễn Văn A', 'nva@hrm.com', 3),
('nhanvien2', '@123456', 'Lê Thị C', 'ltc@hrm.com', 3);
