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
-- NHÓM 1: CÁC DANH MỤC CƠ SỞ (MASTER DATA) - 12 BẢNG
-- =============================================================

-- BẢNG 1: departments (Phòng ban / Xưởng / Cửa hàng)
CREATE TABLE departments (
    department_id   INT          PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(100) NOT NULL UNIQUE,
    description     VARCHAR(255),
    status          TINYINT(1)   NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- BẢNG 2: positions (Chức vụ)
CREATE TABLE positions (
    position_id   INT          PRIMARY KEY AUTO_INCREMENT,
    position_name VARCHAR(100) NOT NULL UNIQUE,
    description   VARCHAR(255),
    status        TINYINT(1)   NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- BẢNG 3: work_locations (Địa điểm làm việc / Chi nhánh)
CREATE TABLE work_locations (
    location_id   INT          PRIMARY KEY AUTO_INCREMENT,
    location_name VARCHAR(100) NOT NULL UNIQUE,
    address       VARCHAR(255),
    regional_minimum_wage DECIMAL(15,2) DEFAULT 0, -- Lương tối thiểu vùng
    status        TINYINT(1)   NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- BẢNG 4: salary_grades (Ngạch lương)
CREATE TABLE salary_grades (
    salary_grade_id INT PRIMARY KEY AUTO_INCREMENT,
    grade_name VARCHAR(100) NOT NULL UNIQUE,
    base_salary DECIMAL(15,2) NOT NULL,
    coefficient DECIMAL(5,2) DEFAULT 1.00,
    description VARCHAR(255),
    status TINYINT(1) DEFAULT 1
);

-- BẢNG 5: contract_types (Loại hợp đồng)
CREATE TABLE contract_types (
    contract_type_id INT          PRIMARY KEY AUTO_INCREMENT,
    type_name        VARCHAR(100) NOT NULL UNIQUE,
    description      VARCHAR(255),
    status           TINYINT(1)   NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- BẢNG 6: allowances (Loại phụ cấp)
CREATE TABLE allowances (
    allowance_id   INT          PRIMARY KEY AUTO_INCREMENT,
    allowance_name VARCHAR(100) NOT NULL UNIQUE,
    description    VARCHAR(255),
    status         TINYINT(1)   NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- BẢNG 7: insurance_rates (Mức đóng BHXH)
CREATE TABLE insurance_rates (
    insurance_rate_id INT          PRIMARY KEY AUTO_INCREMENT,
    insurance_name    VARCHAR(100) NOT NULL UNIQUE,
    company_rate      DECIMAL(5,2) NOT NULL,
    employee_rate     DECIMAL(5,2) NOT NULL,
    description       VARCHAR(255),
    status            TINYINT(1)   NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- BẢNG 8: employment_statuses (Trạng thái làm việc)
CREATE TABLE employment_statuses (
    status_id   INT          PRIMARY KEY AUTO_INCREMENT,
    status_name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(255),
    status      TINYINT(1)   NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- BẢNG 9: education_levels (Trình độ học vấn)
CREATE TABLE education_levels (
    education_level_id INT          PRIMARY KEY AUTO_INCREMENT,
    level_name         VARCHAR(100) NOT NULL UNIQUE,
    description        VARCHAR(255),
    status             TINYINT(1)   NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- BẢNG 10: shifts (Ca làm việc)
CREATE TABLE shifts (
    shift_id     INT          PRIMARY KEY AUTO_INCREMENT,
    shift_name   VARCHAR(50)  NOT NULL, 
    start_time   TIME         NOT NULL,
    end_time     TIME         NOT NULL,
    break_start  TIME,
    break_end    TIME,
    working_days VARCHAR(50),
    status       TINYINT(1)   NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- BẢNG 11: leave_types (Loại nghỉ phép)
CREATE TABLE leave_types (
    leave_type_id INT          PRIMARY KEY AUTO_INCREMENT,
    type_name     VARCHAR(50)  NOT NULL, 
    paid_leave    TINYINT(1)   DEFAULT 1,
    status        TINYINT(1)   NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- BẢNG 12: reward_disciplines (Loại Khen thưởng / Kỷ luật)
CREATE TABLE reward_disciplines (
    id          INT          PRIMARY KEY AUTO_INCREMENT,
    name        VARCHAR(100) NOT NULL,
    type        VARCHAR(20)  NOT NULL, -- 'Reward' hoặc 'Discipline'
    description VARCHAR(255),
    status      TINYINT(1)   NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================
-- NHÓM 2: PHÂN QUYỀN HỆ THỐNG
-- =============================================================

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
    module          VARCHAR(50)  
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
-- NHÓM 3: NGƯỜI DÙNG & HỒ SƠ NHÂN SỰ
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
    profile_id             INT          PRIMARY KEY AUTO_INCREMENT,
    user_id                INT          NOT NULL UNIQUE,
    id_card                VARCHAR(20), -- CMND/CCCD
    dob                    DATE,        -- Ngày sinh
    gender                 TINYINT(1),  -- 1: Nam, 0: Nữ
    address                VARCHAR(255),-- Thường trú
    hire_date              DATE,        -- Ngày vào làm
    tax_code               VARCHAR(50), -- Mã số thuế
    social_insurance_no    VARCHAR(50), -- Sổ BHXH
    bank_account           VARCHAR(50), -- STK Ngân hàng
    bank_name              VARCHAR(100),-- Tên Ngân hàng
    
    contract_type_id       INT,         -- Loại HĐ
    salary_grade_id        INT,         -- Ngạch lương
    employment_status_id   INT,         -- Trạng thái làm việc
    education_level_id     INT,         -- Trình độ học vấn
    work_location_id       INT,         -- Chi nhánh/Xưởng làm việc
    CONSTRAINT fk_profile_user   FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_profile_ct     FOREIGN KEY (contract_type_id) REFERENCES contract_types(contract_type_id) ON DELETE SET NULL,
    CONSTRAINT fk_profile_sg     FOREIGN KEY (salary_grade_id) REFERENCES salary_grades(salary_grade_id) ON DELETE SET NULL,
    CONSTRAINT fk_profile_es     FOREIGN KEY (employment_status_id) REFERENCES employment_statuses(status_id) ON DELETE SET NULL,
    CONSTRAINT fk_profile_ed     FOREIGN KEY (education_level_id) REFERENCES education_levels(education_level_id) ON DELETE SET NULL,
    CONSTRAINT fk_profile_loc    FOREIGN KEY (work_location_id) REFERENCES work_locations(location_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- BẢNG: dependents (Người phụ thuộc)
CREATE TABLE dependents (
    dependent_id   INT          PRIMARY KEY AUTO_INCREMENT,
    user_id        INT          NOT NULL,
    full_name      VARCHAR(100) NOT NULL,
    relationship   VARCHAR(50)  NOT NULL, -- VD: Con đẻ, Bố mẹ
    dob            DATE,
    tax_code       VARCHAR(50),
    status         TINYINT(1)   NOT NULL DEFAULT 1,
    CONSTRAINT fk_dep_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- BẢNG: work_history (Lịch sử công tác)
CREATE TABLE work_history (
    history_id      INT          PRIMARY KEY AUTO_INCREMENT,
    user_id         INT          NOT NULL,
    position_title  VARCHAR(100) NOT NULL,
    company_name    VARCHAR(100) DEFAULT 'Công ty TNHH Group4',
    location        VARCHAR(100) DEFAULT 'TP. Hồ Chí Minh',
    start_date      DATE         NOT NULL,
    end_date        DATE,
    description     TEXT,
    is_current      TINYINT(1)   DEFAULT 0,
    CONSTRAINT fk_wh_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================
-- NHÓM 4: NGHIỆP VỤ (ATTENDANCE, LEAVE, PAYROLL)
-- =============================================================

-- BẢNG: attendance (Bảng chấm công hàng ngày)
CREATE TABLE attendance (
    attendance_id INT  PRIMARY KEY AUTO_INCREMENT,
    user_id       INT  NOT NULL,
    shift_id      INT  NOT NULL,
    work_date     DATE NOT NULL,
    check_in      TIME,
    check_out     TIME,
    status        VARCHAR(30) DEFAULT 'Present', 
    overtime_hrs  DECIMAL(5,2) DEFAULT 0,        
    created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_att_user  FOREIGN KEY (user_id)  REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_att_shift FOREIGN KEY (shift_id) REFERENCES shifts(shift_id) ON DELETE RESTRICT
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
    status        VARCHAR(20)  DEFAULT 'Pending', 
    approved_by   INT,         
    created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_leave_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_leave_type FOREIGN KEY (leave_type_id) REFERENCES leave_types(leave_type_id) ON DELETE RESTRICT,
    CONSTRAINT fk_leave_approver FOREIGN KEY (approved_by) REFERENCES users(user_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- BẢNG: payroll (Bảng lương tháng)
CREATE TABLE payroll (
    payroll_id INT PRIMARY KEY AUTO_INCREMENT,

    user_id INT NOT NULL,

    month INT NOT NULL,
    year INT NOT NULL,

    base_salary DECIMAL(15,2),

    working_days DECIMAL(5,1),

    overtime_amount DECIMAL(15,2),

    allowance_amount DECIMAL(15,2),

    bonus_amount DECIMAL(15,2),

    deduction_amount DECIMAL(15,2),

    insurance_amount DECIMAL(15,2),

    tax_amount DECIMAL(15,2),

    gross_salary DECIMAL(15,2),

    net_salary DECIMAL(15,2),

    status ENUM(
        'Draft',
        'Approved',
        'Paid'
    ) DEFAULT 'Draft',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY(user_id)
        REFERENCES users(user_id)
);

-- BẢNG: notifications (Thông báo hệ thống)
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
-- BẢNG: employee_shifts (Phân ca nhân viên)

CREATE TABLE employee_shifts(
    id INT PRIMARY KEY AUTO_INCREMENT,

    user_id INT NOT NULL,

    shift_id INT NOT NULL,

    work_date DATE NOT NULL,

    FOREIGN KEY(user_id)
        REFERENCES users(user_id),

    FOREIGN KEY(shift_id)
        REFERENCES shifts(shift_id)
);
-- =============================================================
-- NHÓM 5: Lương - C&B (Compensation & Benefits)
-- =============================================================
-- BẢNG: employee_allowances (nhân viên được phụ cấp)

CREATE TABLE employee_allowances(
    id INT PRIMARY KEY AUTO_INCREMENT,

    user_id INT NOT NULL,

    allowance_id INT NOT NULL,

    amount DECIMAL(15,2) NOT NULL,

    FOREIGN KEY(user_id)
        REFERENCES users(user_id),

    FOREIGN KEY(allowance_id)
        REFERENCES allowances(allowance_id)
);
-- BẢNG: employee_rewards_disciplines (thưởng phạt nhân viên)

CREATE TABLE employee_rewards_disciplines(
    id INT PRIMARY KEY AUTO_INCREMENT,

    user_id INT NOT NULL,

    reward_discipline_id INT NOT NULL,

    amount DECIMAL(15,2) NOT NULL,

    note VARCHAR(255),

    applied_date DATE,

    FOREIGN KEY(user_id)
        REFERENCES users(user_id),

    FOREIGN KEY(reward_discipline_id)
        REFERENCES reward_disciplines(id)
);
-- 3. BẬT LẠI KIỂM TRA KHÓA NGOẠI
SET FOREIGN_KEY_CHECKS = 1;

-- =========================================================================
-- =========================== SEED DATA ===================================
-- =========================================================================

-- ── 1. Departments ──
INSERT INTO departments (department_id, department_name, description) VALUES
(1, 'Hành chính', 'Phụ trách thiết bị, văn phòng phẩm, lễ tân'),
(2, 'Nhân sự', 'Tuyển dụng, đào tạo, C&B'),
(3, 'Kế toán', 'Tài chính, công nợ, thuế'),
(4, 'Kinh doanh', 'Sales thương mại, phát triển thị trường'),
(5, 'Xưởng sản xuất', 'Trực tiếp sản xuất sản phẩm');

-- ── 2. Positions ──
INSERT INTO positions (position_id, position_name, description) VALUES
(1, 'Giám đốc', 'Quản lý điều hành'),
(2, 'Trưởng phòng', 'Quản lý phòng ban'),
(3, 'Phó phòng', 'Hỗ trợ trưởng phòng'),
(4, 'Quản đốc', 'Quản lý xưởng sản xuất'),
(5, 'Tổ trưởng', 'Quản lý tổ trong xưởng'),
(6, 'Kế toán trưởng', 'Trưởng phòng Kế toán'),
(7, 'Chuyên viên', 'Nhân sự có chuyên môn sâu (Văn phòng)'),
(8, 'Nhân viên', 'Nhân viên cơ bản (Văn phòng/Sales)'),
(9, 'Công nhân', 'Lao động tại xưởng');

-- ── 3. Work Locations ──
INSERT INTO work_locations (location_id, location_name, address, regional_minimum_wage) VALUES
(1, 'Trụ sở chính - Hà Nội', 'Tòa nhà A, Cầu Giấy, Hà Nội', 4960000), -- Vùng 1
(2, 'Xưởng Sản Xuất Bắc Ninh', 'KCN VSIP, Từ Sơn, Bắc Ninh', 4410000), -- Vùng 2
(3, 'Chi nhánh Hồ Chí Minh', 'Tòa nhà B, Quận 1, TP.HCM', 4960000);  -- Vùng 1

-- ── 4. Salary Grades ──
INSERT INTO salary_grades
(salary_grade_id, grade_name, base_salary, coefficient, description)
VALUES
(1,'Ngạch Quản lý',30000000,1.50,'Giám đốc, Trưởng phòng'),
(2,'Ngạch Chuyên viên',12000000,1.20,'Khối văn phòng'),
(3,'Ngạch Kinh doanh',10000000,1.00,'Nhân viên kinh doanh'),
(4,'Ngạch Sản xuất',7000000,1.00,'Công nhân sản xuất');

-- ── 5. Contract Types ──
INSERT INTO contract_types (contract_type_id, type_name, description) VALUES
(1, 'Thử việc', 'Hợp đồng thử việc 2 tháng'),
(2, 'Có thời hạn 1 năm', 'Hợp đồng lao động 12 tháng'),
(3, 'Có thời hạn 3 năm', 'Hợp đồng lao động 36 tháng'),
(4, 'Vô thời hạn', 'Hợp đồng không xác định thời hạn'),
(5, 'Thời vụ', 'Dành cho lao động ngắn hạn ở xưởng');

-- ── 6. Allowances ──
INSERT INTO allowances (allowance_id, allowance_name, description) VALUES
(1, 'Ăn trưa', 'Phụ cấp ăn ca'),
(2, 'Đi lại', 'Phụ cấp xăng xe'),
(3, 'Trách nhiệm', 'Cho quản đốc, tổ trưởng'),
(4, 'Độc hại', 'Cho công nhân xưởng'),
(5, 'Chuyên cần', 'Thưởng đi làm đầy đủ');

-- ── 7. Insurance Rates ──
INSERT INTO insurance_rates (insurance_rate_id, insurance_name, company_rate, employee_rate) VALUES
(1, 'Bảo hiểm Xã hội (BHXH)', 17.5, 8.0),
(2, 'Bảo hiểm Y tế (BHYT)', 3.0, 1.5),
(3, 'Bảo hiểm Thất nghiệp (BHTN)', 1.0, 1.0);

-- ── 8. Employment Statuses ──
INSERT INTO employment_statuses (status_id, status_name, description) VALUES
(1, 'Đang thử việc', 'Đang trong thời gian đánh giá'),
(2, 'Đang làm việc', 'Nhân viên chính thức'),
(3, 'Tạm hoãn HĐLĐ', 'Nghỉ ốm dài ngày, Thai sản'),
(4, 'Đã nghỉ việc', 'Chấm dứt Hợp đồng');

-- ── 9. Education Levels ──
INSERT INTO education_levels (education_level_id, level_name) VALUES
(1, 'Trên Đại học'),
(2, 'Đại học'),
(3, 'Cao đẳng'),
(4, 'Trung cấp/Nghề'),
(5, 'Lao động phổ thông');

-- ── 10. Shifts ──
INSERT INTO shifts (shift_id, shift_name, start_time, end_time, break_start, break_end, working_days) VALUES
(1, 'Ca Hành Chính', '08:00:00', '17:00:00', '12:00:00', '13:00:00', '2,3,4,5,6,7'),
(2, 'Ca 1 (Sáng)', '06:00:00', '14:00:00', '11:00:00', '11:30:00', '2,3,4,5,6,7'),
(3, 'Ca 2 (Chiều)', '14:00:00', '22:00:00', '17:30:00', '18:00:00', '2,3,4,5,6,7'),
(4, 'Ca 3 (Đêm)', '22:00:00', '06:00:00', '02:00:00', '02:30:00', '2,3,4,5,6,7');

-- ── 11. Leave Types ──
INSERT INTO leave_types (leave_type_id, type_name, paid_leave) VALUES
(1, 'Nghỉ phép năm', 1),
(2, 'Nghỉ ốm (Hưởng BHXH)', 0),
(3, 'Nghỉ thai sản', 0),
(4, 'Nghỉ việc riêng có lương', 1),
(5, 'Nghỉ không lương', 0);

-- ── 12. Reward Disciplines ──
INSERT INTO reward_disciplines (id, name, type, description) VALUES
(1, 'Thưởng KPI Tháng', 'Reward', 'Thưởng dựa trên đánh giá hiệu suất'),
(2, 'Thưởng Dự án', 'Reward', 'Thưởng hoàn thành xuất sắc dự án'),
(3, 'Thưởng Chuyên cần', 'Reward', 'Không đi muộn, không nghỉ phép trong tháng'),
(4, 'Đi muộn/Về sớm', 'Discipline', 'Phạt đi muộn theo quy định'),
(5, 'Vi phạm An toàn LĐ', 'Discipline', 'Phạt do không tuân thủ an toàn tại xưởng');

-- ── 13. Roles & Permissions ──
INSERT INTO roles (role_id, role_name, description) VALUES
(1, 'Admin', 'Quản trị hệ thống toàn quyền'),
(2, 'HR Manager', 'Trưởng phòng Nhân sự'),
(3, 'Factory Manager', 'Quản đốc xưởng sản xuất');

INSERT INTO permissions (permission_id, permission_name, description, module) VALUES
-- MODULE: USER - Quản lý người dùng
(1,  'USER_MANAGE',               'Thêm, sửa, xóa người dùng',              'USER'),
(2,  'USER_VIEW',                 'Xem danh sách người dùng',                'USER'),

-- MODULE: ROLE - Quản lý vai trò
(3,  'ROLE_VIEW',                 'Xem danh sách vai trò',                   'ROLE'),
(4,  'ROLE_UPDATE_INFORMATION',   'Cập nhật thông tin vai trò',              'ROLE'),
(5,  'ROLE_PERMISSION_VIEW',      'Xem phân quyền của vai trò',              'ROLE'),
(6,  'ROLE_PERMISSION_MANAGE',    'Chỉnh sửa phân quyền vai trò',            'ROLE'),

-- MODULE: DEPARTMENT - Phòng ban
(7,  'DEPARTMENT_VIEW',           'Xem danh sách phòng ban',                 'DEPARTMENT'),
(8,  'DEPARTMENT_MANAGE',         'Thêm, sửa, xóa phòng ban',               'DEPARTMENT'),

-- MODULE: POSITION - Chức vụ
(9,  'POSITION_VIEW',             'Xem danh sách chức vụ',                   'POSITION'),
(10, 'POSITION_MANAGE',           'Thêm, sửa, xóa chức vụ',                 'POSITION'),

-- MODULE: WORK_LOCATION - Địa điểm làm việc
(11, 'WORK_LOCATION_VIEW',        'Xem danh sách địa điểm làm việc',         'WORK_LOCATION'),
(12, 'WORK_LOCATION_MANAGE',      'Thêm, sửa, xóa địa điểm làm việc',       'WORK_LOCATION'),

-- MODULE: ATTENDANCE - Chấm công
(13, 'ATTENDANCE_VIEW',           'Xem bảng chấm công',                      'ATTENDANCE'),
(14, 'ATTENDANCE_MANAGE',         'Quản lý chấm công',                       'ATTENDANCE'),

-- MODULE: LEAVE - Nghỉ phép
(15, 'LEAVE_VIEW',                'Xem đơn xin nghỉ phép',                   'LEAVE'),
(16, 'LEAVE_MANAGE',              'Quản lý đơn nghỉ phép',                   'LEAVE'),
(17, 'LEAVE_APPROVE',             'Phê duyệt / từ chối đơn nghỉ phép',       'LEAVE'),

-- MODULE: PAYROLL - Lương
(18, 'PAYROLL_VIEW',              'Xem bảng lương',                          'PAYROLL'),
(19, 'PAYROLL_MANAGE',            'Quản lý tính lương',                      'PAYROLL'),

-- MODULE: REPORT - Báo cáo
(20, 'REPORT_VIEW',               'Xem báo cáo thống kê',                    'REPORT'),

-- MODULE: SYSTEM - Hệ thống
(21, 'SYSTEM_CONFIG',             'Cấu hình hệ thống',                       'SYSTEM');

-- Admin (role_id=1): Toàn quyền tất cả modules
INSERT INTO role_permissions (role_id, permission_id) VALUES
(1,1),(1,2),(1,3),(1,4),(1,5),(1,6),(1,7),(1,8),(1,9),(1,10),
(1,11),(1,12),(1,13),(1,14),(1,15),(1,16),(1,17),(1,18),(1,19),(1,20),(1,21);

-- HR Manager (role_id=2): Quản lý nhân sự, chấm công, nghỉ phép, báo cáo
INSERT INTO role_permissions (role_id, permission_id) VALUES
(2,1),(2,2),(2,7),(2,8),(2,9),(2,10),(2,11),
(2,13),(2,14),(2,15),(2,16),(2,17),(2,18),(2,20);

-- Factory Manager (role_id=3): Xem nhân sự, quản lý chấm công và nghỉ phép xưởng
INSERT INTO role_permissions (role_id, permission_id) VALUES
(3,2),(3,7),(3,9),(3,11),(3,13),(3,14),(3,15),(3,16),(3,17);

-- ── 14. Users & Profiles ──

-- Admin hệ thống (tài khoản quản trị thuần túy, không phải nhân viên)
INSERT INTO users (user_id, username, password, full_name, email, role_id, department_id, position_id) VALUES
(1, 'admin', '@123456', 'Quản Trị Viên', 'admin@hrm.com', 1, NULL, NULL);
-- Thiếu 4 dòng này trước các INSERT employee_profiles
INSERT INTO users (user_id, username, password, full_name, email, role_id, department_id, position_id) VALUES
(2, 'giam_doc', '@123456', 'Nguyễn Văn Giám Đốc', 'giamdoc@hrm.com', 1, 1, 1);

INSERT INTO users (user_id, username, password, full_name, email, role_id, department_id, position_id) VALUES
(3, 'hr_manager', '@123456', 'Trần Thị Nhân Sự', 'hr@hrm.com', 2, 2, 2);

INSERT INTO users (user_id, username, password, full_name, email, role_id, department_id, position_id) VALUES
(4, 'quan_doc', '@123456', 'Lê Văn Quản Đốc', 'quandoc@hrm.com', 3, 5, 4);

INSERT INTO users (user_id, username, password, full_name, email, role_id, department_id, position_id) VALUES
(5, 'cong_nhan', '@123456', 'Phạm Công Nhân', 'cn1@hrm.com', NULL, 5, 9);

-- User 2: Giám đốc → hợp đồng vô thời hạn (id=4), ngạch quản lý (id=1)
INSERT INTO employee_profiles (user_id, id_card, dob, gender, address, hire_date, tax_code, bank_account, contract_type_id, salary_grade_id, employment_status_id, education_level_id, work_location_id) VALUES
(2, '001085000001', '1985-01-01', 1, 'Hà Nội', '2020-01-01', '8012345678', '190300001', 4, 1, 2, 1, 1);

-- User 3: Trưởng phòng HR → hợp đồng vô thời hạn (id=4), ngạch chuyên viên (id=2)
INSERT INTO employee_profiles (user_id, id_card, dob, gender, address, hire_date, tax_code, bank_account, contract_type_id, salary_grade_id, employment_status_id, education_level_id, work_location_id) VALUES
(3, '001090000002', '1990-05-15', 0, 'Hà Nội', '2021-03-10', '8012345679', '190300002', 4, 2, 2, 2, 1);

-- User 4: Quản đốc → hợp đồng vô thời hạn (id=4), ngạch chuyên viên (id=2)
INSERT INTO employee_profiles (user_id, id_card, dob, gender, address, hire_date, tax_code, bank_account, contract_type_id, salary_grade_id, employment_status_id, education_level_id, work_location_id) VALUES
(4, '001088000003', '1988-08-20', 1, 'Hải Phòng', '2020-06-01', '8012345680', '190300003', 4, 2, 2, 2, 2);

-- User 5: Công nhân → hợp đồng có thời hạn 1 năm (id=2), ngạch sản xuất (id=4)
INSERT INTO employee_profiles (user_id, id_card, dob, gender, address, hire_date, tax_code, bank_account, contract_type_id, salary_grade_id, employment_status_id, education_level_id, work_location_id) VALUES
(5, '001095000004', '1995-12-10', 1, 'Bắc Ninh', '2022-02-15', '8012345681', '190300004', 2, 4, 2, 5, 2);
-- ── 15. Dependents (Người phụ thuộc) ──
INSERT INTO dependents (user_id, full_name, relationship, dob) VALUES
(3, 'Nguyễn Bé Bỏng', 'Con ruột', '2020-10-10'),
(5, 'Phạm Thị Mẹ', 'Mẹ ruột', '1960-01-01');

