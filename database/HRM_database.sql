/* ================================================================
   DỰ ÁN: HUMAN RESOURCE MANAGEMENT (HRM)
   Mô tả: Script tự động xóa, tạo mới database và cung cấp
          bộ dữ liệu mẫu (Seed Data) chuẩn mực, hỗ trợ mô hình
          Sản xuất & Thương mại (Chấm công, Nghỉ phép, Tính lương).
   ================================================================ */

-- 1. XÓA VÀ TẠO MỚI DATABASE
DROP DATABASE IF EXISTS HRM_System;
CREATE DATABASE HRM_System CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE HRM_System;

-- 2. TẮT KIỂM TRA KHÓA NGOẠI
SET FOREIGN_KEY_CHECKS = 0;

-- =============================================================
-- NHÓM 1: DANH MỤC CƠ CẤU TỔ CHỨC & VAI TRÒ
-- =============================================================

-- BẢNG: departments (Phòng ban / Xưởng / Cửa hàng)
CREATE TABLE departments (
    department_id   INT          PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(100) NOT NULL UNIQUE,
    description     VARCHAR(255),
    status          TINYINT(1)   NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- BẢNG: positions (Chức vụ)
CREATE TABLE positions (
    position_id   INT          PRIMARY KEY AUTO_INCREMENT,
    position_name VARCHAR(100) NOT NULL UNIQUE,
    description   VARCHAR(255),
    status        TINYINT(1)   NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- BẢNG: roles (Vai trò hệ thống)
CREATE TABLE roles (
    role_id     INT          PRIMARY KEY AUTO_INCREMENT,
    role_name   VARCHAR(50)  NOT NULL UNIQUE,
    description VARCHAR(255),
    status      TINYINT(1)   NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- BẢNG: permissions (Quyền hạn hệ thống)
CREATE TABLE permissions (
    permission_id   INT          PRIMARY KEY AUTO_INCREMENT,
    permission_name VARCHAR(100) NOT NULL UNIQUE,
    description     VARCHAR(255),
    module          VARCHAR(50)  -- USER, ROLE, ATTENDANCE, LEAVE, PAYROLL, KPI
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- BẢNG: role_permissions (Phân quyền cho vai trò)
CREATE TABLE role_permissions (
    role_id       INT NOT NULL,
    permission_id INT NOT NULL,
    PRIMARY KEY (role_id, permission_id),
    CONSTRAINT fk_rp_role FOREIGN KEY (role_id)       REFERENCES roles(role_id)       ON DELETE CASCADE,
    CONSTRAINT fk_rp_perm FOREIGN KEY (permission_id) REFERENCES permissions(permission_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================
-- NHÓM 2: NGƯỜI DÙNG & HỒ SƠ NHÂN SỰ
-- =============================================================

-- BẢNG: users (Tài khoản người dùng đăng nhập)
CREATE TABLE users (
    user_id       INT          PRIMARY KEY AUTO_INCREMENT,
    username      VARCHAR(50)  NOT NULL UNIQUE,
    password      VARCHAR(255) NOT NULL,
    full_name     VARCHAR(100),
    email         VARCHAR(100) UNIQUE,
    phone         VARCHAR(20),
    avatar_url    VARCHAR(255),
    status        TINYINT(1)   NOT NULL DEFAULT 1,   -- 1: Active, 0: Locked
    role_id       INT,
    department_id INT,
    position_id   INT,
    created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_user_role FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE SET NULL,
    CONSTRAINT fk_user_dept FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE SET NULL,
    CONSTRAINT fk_user_pos  FOREIGN KEY (position_id) REFERENCES positions(position_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- BẢNG: employee_profiles (Hồ sơ nhân sự chi tiết)
CREATE TABLE employee_profiles (
    profile_id       INT          PRIMARY KEY AUTO_INCREMENT,
    user_id          INT          NOT NULL UNIQUE,
    dob              DATE,        -- Ngày sinh
    gender           TINYINT(1),  -- 1: Nam, 0: Nữ
    id_card          VARCHAR(20), -- CMND/CCCD
    address          VARCHAR(255),
    bank_account     VARCHAR(50),
    bank_name        VARCHAR(100),
    base_salary      DECIMAL(15,2) DEFAULT 0, -- Mức lương cơ bản (để tính lương)
    hire_date        DATE,        -- Ngày gia nhập
    contract_type    VARCHAR(50), -- Loại hợp đồng (Fulltime, Parttime, Thử việc)
    CONSTRAINT fk_profile_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================
-- NHÓM 3: CA KÍP & CHẤM CÔNG (ATTENDANCE)
-- =============================================================

-- BẢNG: shifts (Ca làm việc)
CREATE TABLE shifts (
    shift_id     INT          PRIMARY KEY AUTO_INCREMENT,
    shift_name   VARCHAR(50)  NOT NULL, -- VD: Ca Hành Chính, Ca 1, Ca 2
    start_time   TIME         NOT NULL,
    end_time     TIME         NOT NULL,
    break_start  TIME,
    break_end    TIME,
    working_days VARCHAR(50)  -- VD: "2,3,4,5,6,7"
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- BẢNG: attendance (Bảng chấm công hàng ngày)
CREATE TABLE attendance (
    attendance_id INT  PRIMARY KEY AUTO_INCREMENT,
    user_id       INT  NOT NULL,
    shift_id      INT  NOT NULL,
    work_date     DATE NOT NULL,
    check_in      TIME,
    check_out     TIME,
    status        VARCHAR(30) DEFAULT 'Present', -- Present, Absent, Late, Half-day
    overtime_hrs  DECIMAL(5,2) DEFAULT 0,        -- Giờ tăng ca thực tế
    created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_att_user  FOREIGN KEY (user_id)  REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_att_shift FOREIGN KEY (shift_id) REFERENCES shifts(shift_id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================
-- NHÓM 4: NGHỈ PHÉP (LEAVE MANAGEMENT)
-- =============================================================

-- BẢNG: leave_types (Loại nghỉ phép)
CREATE TABLE leave_types (
    leave_type_id INT          PRIMARY KEY AUTO_INCREMENT,
    type_name     VARCHAR(50)  NOT NULL, -- Phép năm, Nghỉ ốm, Thai sản...
    paid_leave    TINYINT(1)   DEFAULT 1 -- 1: Có lương, 0: Không lương
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- BẢNG: leave_requests (Đơn xin nghỉ phép)
CREATE TABLE leave_requests (
    request_id    INT          PRIMARY KEY AUTO_INCREMENT,
    user_id       INT          NOT NULL,
    leave_type_id INT          NOT NULL,
    start_date    DATE         NOT NULL,
    end_date      DATE         NOT NULL,
    total_days    DECIMAL(5,1) NOT NULL,
    reason        VARCHAR(255),
    status        VARCHAR(20)  DEFAULT 'Pending', -- Pending, Approved, Rejected
    approved_by   INT,         -- Người duyệt (Trưởng phòng/HR)
    created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_leave_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_leave_type FOREIGN KEY (leave_type_id) REFERENCES leave_types(leave_type_id) ON DELETE RESTRICT,
    CONSTRAINT fk_leave_approver FOREIGN KEY (approved_by) REFERENCES users(user_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================
-- NHÓM 5: TÍNH LƯƠNG (PAYROLL)
-- =============================================================

-- BẢNG: payroll (Bảng lương tháng)
CREATE TABLE payroll (
    payroll_id       INT           PRIMARY KEY AUTO_INCREMENT,
    user_id          INT           NOT NULL,
    month            INT           NOT NULL,
    year             INT           NOT NULL,
    base_salary      DECIMAL(15,2) NOT NULL DEFAULT 0,
    working_days     DECIMAL(5,1)  NOT NULL DEFAULT 0, -- Số ngày công thực tế
    allowances       DECIMAL(15,2) DEFAULT 0,          -- Tổng phụ cấp
    deductions       DECIMAL(15,2) DEFAULT 0,          -- Tổng khấu trừ (Phạt, tạm ứng)
    tax              DECIMAL(15,2) DEFAULT 0,          -- Thuế TNCN
    insurance        DECIMAL(15,2) DEFAULT 0,          -- Trích nộp BHXH
    net_salary       DECIMAL(15,2) NOT NULL,           -- Thực lĩnh
    status           VARCHAR(20)   DEFAULT 'Draft',    -- Draft, Approved, Paid
    created_at       TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_payroll_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================
-- NHÓM 6: THÔNG BÁO HỆ THỐNG
-- =============================================================
CREATE TABLE notifications (
    id          INT          NOT NULL AUTO_INCREMENT,
    user_id     INT          NOT NULL,
    type        VARCHAR(30)  NOT NULL DEFAULT 'system',
    title       VARCHAR(120) NOT NULL,
    body        VARCHAR(255) NOT NULL DEFAULT '',
    link        VARCHAR(255) DEFAULT NULL,
    is_read     TINYINT(1)   NOT NULL DEFAULT 0,
    created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX idx_user_read (user_id, is_read),
    INDEX idx_created   (created_at),
    CONSTRAINT fk_notif_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- 3. BẬT LẠI KIỂM TRA KHÓA NGOẠI
SET FOREIGN_KEY_CHECKS = 1;

-- =============================================================
-- SEED DATA (DỮ LIỆU MẪU)
-- =============================================================

-- ── 1. Departments & Positions ──
INSERT INTO departments (department_id, department_name, description) VALUES
(1, 'Ban Giám Đốc', 'Ban lãnh đạo công ty'),
(2, 'Phòng Hành Chính Nhân Sự', 'Quản lý nhân sự, lương, tuyển dụng'),
(3, 'Khối Sản Xuất', 'Nhà máy sản xuất chính'),
(4, 'Khối Thương Mại - Bán Hàng', 'Hệ thống chuỗi phân phối/cửa hàng');

INSERT INTO positions (position_id, position_name) VALUES
(1, 'Giám Đốc'),
(2, 'Trưởng Phòng'),
(3, 'Quản Đốc Nhà Máy'),
(4, 'Tổ Trưởng'),
(5, 'Cửa Hàng Trưởng'),
(6, 'Chuyên Viên'),
(7, 'Công Nhân'),
(8, 'Nhân Viên Bán Hàng');

-- ── 2. Roles & Permissions ──
INSERT INTO roles (role_id, role_name, description) VALUES
(1, 'Super Admin', 'Quản trị viên cấp cao toàn quyền'),
(2, 'HR Manager', 'Trưởng phòng Nhân sự'),
(3, 'C&B Specialist', 'Chuyên viên Lương và Phúc lợi'),
(4, 'Recruitment/Training', 'Chuyên viên Tuyển dụng/Đào tạo'),
(5, 'Factory Manager', 'Quản đốc nhà máy'),
(6, 'Team Leader', 'Tổ trưởng Khối Sản Xuất'),
(7, 'Store Manager', 'Cửa hàng trưởng'),
(8, 'Department Head', 'Trưởng phòng Khối Văn phòng'),
(9, 'Factory Worker', 'Công nhân nhà máy'),
(10, 'Sales/Store Staff', 'Nhân viên Bán hàng/Thương mại'),
(11, 'Office Staff', 'Nhân viên Văn phòng');

INSERT INTO permissions (permission_id, permission_name, description, module) VALUES
(1, 'USER_VIEW', 'Xem danh sách người dùng', 'USER'),
(2, 'USER_CREATE', 'Thêm mới người dùng', 'USER'),
(3, 'USER_EDIT', 'Sửa thông tin người dùng', 'USER'),
(4, 'USER_DELETE', 'Khóa/Xóa người dùng', 'USER'),
(5, 'ROLE_VIEW', 'Xem danh sách vai trò', 'ROLE'),
(6, 'ROLE_UPDATE_INFORMATION', 'Sửa thông tin vai trò (Tên, Mô tả)', 'ROLE'),
(7, 'ROLE_PERMISSION_VIEW', 'Xem danh sách quyền hạn của vai trò', 'ROLE'),
(8, 'ROLE_PERMISSION_EDIT', 'Phân quyền cho vai trò', 'ROLE'),
(9, 'ATTENDANCE_VIEW_ALL', 'Xem chấm công toàn công ty', 'ATTENDANCE'),
(10, 'LEAVE_APPROVE', 'Duyệt nghỉ phép cho cấp dưới', 'LEAVE'),
(11, 'PAYROLL_MANAGE', 'Chạy bảng lương', 'PAYROLL');

INSERT INTO role_permissions (role_id, permission_id) VALUES
-- 1. Super Admin (Full rights)
(1,1),(1,2),(1,3),(1,4),(1,5),(1,6),(1,7),(1,8),(1,9),(1,10),(1,11),
-- 2. HR Manager
(2,1),(2,2),(2,3),(2,9),(2,10),(2,11),
-- 3. C&B Specialist
(3,1),(3,9),(3,11),
-- 4. Recruitment/Training
(4,1),
-- 5. Factory Manager
(5,1),(5,9),(5,10),
-- 6. Team Leader
(6,1),(6,10),
-- 7. Store Manager
(7,1),(7,10),
-- 8. Department Head
(8,1),(8,10);

-- ── 3. Users & Profiles ──
-- Admin
INSERT INTO users (user_id, username, password, full_name, email, role_id, department_id, position_id) VALUES
(1, 'admin', '@123456', 'Hệ Thống Admin', 'admin@hrm.com', 1, 1, 1);
INSERT INTO employee_profiles (user_id, dob, gender, base_salary, hire_date) VALUES 
(1, '1980-01-01', 1, 30000000, '2020-01-01');

-- HR Manager
INSERT INTO users (user_id, username, password, full_name, email, role_id, department_id, position_id) VALUES
(2, 'manager_hr', '@123456', 'Nguyễn Thị B (HR)', 'hr@hrm.com', 2, 2, 2);
INSERT INTO employee_profiles (user_id, dob, gender, base_salary, hire_date) VALUES 
(2, '1990-05-15', 0, 20000000, '2021-03-10');

-- Factory Manager
INSERT INTO users (user_id, username, password, full_name, email, role_id, department_id, position_id) VALUES
(3, 'manager_sx', '@123456', 'Trần Văn C (Quản Đốc)', 'quanly.sx@hrm.com', 2, 3, 3);
INSERT INTO employee_profiles (user_id, dob, gender, base_salary, hire_date) VALUES 
(3, '1985-08-20', 1, 25000000, '2020-06-01');

-- Worker 1
INSERT INTO users (user_id, username, password, full_name, email, role_id, department_id, position_id) VALUES
(4, 'congnhan1', '@123456', 'Lê Công Nhân', 'cn1@hrm.com', 3, 3, 7);
INSERT INTO employee_profiles (user_id, dob, gender, base_salary, hire_date) VALUES 
(4, '1995-12-10', 1, 8000000, '2022-02-15');

-- Sales 1
INSERT INTO users (user_id, username, password, full_name, email, role_id, department_id, position_id) VALUES
(5, 'sales1', '@123456', 'Phạm Bán Hàng', 'sales1@hrm.com', 3, 4, 8);
INSERT INTO employee_profiles (user_id, dob, gender, base_salary, hire_date) VALUES 
(5, '1998-07-22', 0, 7000000, '2023-01-10');

-- ── 4. Shifts & Attendance ──
INSERT INTO shifts (shift_id, shift_name, start_time, end_time, working_days) VALUES
(1, 'Hành Chính', '08:00:00', '17:00:00', '2,3,4,5,6,7'),
(2, 'Ca 1 (Sản xuất)', '06:00:00', '14:00:00', '2,3,4,5,6,7'),
(3, 'Ca 2 (Sản xuất)', '14:00:00', '22:00:00', '2,3,4,5,6,7');

-- Chấm công mẫu (Cho ngày 2026-05-18)
INSERT INTO attendance (user_id, shift_id, work_date, check_in, check_out, status) VALUES
(2, 1, '2026-05-18', '07:55:00', '17:05:00', 'Present'),
(4, 2, '2026-05-18', '05:50:00', '14:10:00', 'Present'),
(5, 1, '2026-05-18', '08:05:00', '17:00:00', 'Late');

-- ── 5. Leave Types & Requests ──
INSERT INTO leave_types (leave_type_id, type_name, paid_leave) VALUES
(1, 'Nghỉ phép năm', 1),
(2, 'Nghỉ ốm', 0),
(3, 'Nghỉ không lương', 0);

-- Đơn phép mẫu
INSERT INTO leave_requests (user_id, leave_type_id, start_date, end_date, total_days, reason, status, approved_by) VALUES
(4, 1, '2026-05-20', '2026-05-21', 2.0, 'Về quê có việc gia đình', 'Approved', 3),
(5, 2, '2026-05-19', '2026-05-19', 1.0, 'Bị sốt xuất huyết', 'Pending', NULL);

-- ── 6. Payroll (Bảng lương tháng trước 04/2026) ──
INSERT INTO payroll (user_id, month, year, base_salary, working_days, allowances, deductions, net_salary, status) VALUES
(2, 4, 2026, 20000000, 24, 1000000, 0, 21000000, 'Paid'),
(4, 4, 2026, 8000000, 26, 1500000, 0, 9500000, 'Paid'),
(5, 4, 2026, 7000000, 25, 3000000, 500000, 9500000, 'Paid');

-- ── 7. Notifications ──
INSERT INTO notifications (user_id, type, title, body, link) VALUES
(4, 'leave', 'Đơn nghỉ phép được duyệt', 'Quản đốc đã duyệt đơn xin nghỉ 2 ngày của bạn.', '/leave/detail?id=1'),
(5, 'system', 'Hệ thống nâng cấp', 'HRM sẽ bảo trì vào 22h tối nay.', '#');
