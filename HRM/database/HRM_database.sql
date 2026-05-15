/* DỰ ÁN: HUMAN RESOURCE MANAGEMENT (HRM)
GIAI ĐOẠN: TUẦN 1 - QUẢN LÝ NGƯỜI DÙNG & PHÂN QUYỀN
Mô tả: Script này tự động xóa và tạo mới database để đảm bảo cấu trúc luôn đồng bộ.
*/

-- 1. XÓA VÀ TẠO MỚI 
DROP DATABASE IF EXISTS HRM_System;
CREATE DATABASE HRM_System;
USE HRM_System;

-- 2. TẮT KIỂM TRA KHÓA NGOẠI (Để tạo bảng trơn tru hơn)
SET FOREIGN_KEY_CHECKS = 0;

-- =============================================================
-- BẢNG 1: VAI TRÒ (Roles) - Đáp ứng mục 12, 14, 15
-- =============================================================
CREATE TABLE roles (
    role_id INT PRIMARY KEY AUTO_INCREMENT,
    role_name VARCHAR(50) NOT NULL UNIQUE,      -- Admin, Manager, Employee...
    description VARCHAR(255),
    status TINYINT(1) DEFAULT 1                -- 1: Active, 0: Deactive
) ENGINE=InnoDB;

-- =============================================================
-- BẢNG 2: QUYỀN HẠN (Permissions) - Đáp ứng mục 13, 16
-- =============================================================
CREATE TABLE permissions (
    permission_id INT PRIMARY KEY AUTO_INCREMENT,
    permission_name VARCHAR(100) NOT NULL UNIQUE, -- VD: VIEW_USER, EDIT_ROLE...
    description VARCHAR(255)
) ENGINE=InnoDB;

-- =============================================================
-- BẢNG 3: PHÂN QUYỀN CHO VAI TRÒ (Role_Permissions) - Đáp ứng mục 13, 16
-- =============================================================
CREATE TABLE role_permissions (
    role_id INT NOT NULL,
    permission_id INT NOT NULL,
    PRIMARY KEY (role_id, permission_id),
    FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE CASCADE,
    FOREIGN KEY (permission_id) REFERENCES permissions(permission_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- =============================================================
-- BẢNG 4: NGƯỜI DÙNG (Users) - Đáp ứng mục 1-11
-- =============================================================
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,             -- Dùng cho Login, Forgot, Change pass
    full_name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    avatar_url VARCHAR(255),                    -- Phục vụ View Profile
    status TINYINT(1) DEFAULT 1,                -- Phục vụ Active/Deactive User
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

-- Thêm vai trò
INSERT INTO roles (role_name, description) VALUES 
('Admin', 'Quản trị viên toàn hệ thống'),
('Manager', 'Quản lý nhân sự'),
('Employee', 'Nhân viên');

-- Thêm quyền hạn cơ bản
INSERT INTO permissions (permission_name, description) VALUES 
('USER_CREATE', 'Quyền thêm mới người dùng'),
('USER_VIEW', 'Quyền xem danh sách người dùng'),
('ROLE_EDIT', 'Quyền chỉnh sửa vai trò');

-- Gán quyền cho Admin (Admin có tất cả quyền)
INSERT INTO role_permissions (role_id, permission_id) VALUES (1, 1), (1, 2), (1, 3);

-- Thêm tài khoản Admin mẫu (Mật khẩu: 123456)
INSERT INTO users (username, password, full_name, email, role_id) VALUES 
('admin', '123456', 'Hệ Thống Admin', 'admin@hrm.com', 1),
('nhanvien1', '123456', 'Nguyễn Văn A', 'nva@hrm.com', 3);
