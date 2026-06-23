/* ================================================================
   DỰ ÁN: HUMAN RESOURCE MANAGEMENT (HRM)
   Mô tả: Script tự động xóa, tạo mới database và cung cấp
          bộ dữ liệu mẫu (Seed Data) gồm 181 users (1 admin +
          30 quản lý + 150 công nhân), 7 roles, 29 permissions.
   Cập nhật: Tích hợp đầy đủ roles, permissions, seed data 180 NV.
   ================================================================ */

-- 1. XÓA VÀ TẠO MỚI DATABASE
DROP DATABASE IF EXISTS HRM_System;
CREATE DATABASE HRM_System CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE HRM_System;
SET NAMES utf8mb4;

-- 2. TẮT KIỂM TRA KHÓA NGOẠI
SET FOREIGN_KEY_CHECKS = 0;

-- =============================================================
-- NHÓM 1: CÁC DANH MỤC CƠ SỞ (MASTER DATA)
-- =============================================================

-- BẢNG 1: departments
CREATE TABLE departments (
    department_id   INT          PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(100) NOT NULL UNIQUE,
    description     VARCHAR(255),
    status          TINYINT(1)   NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- BẢNG 2: positions
CREATE TABLE positions (
    position_id   INT          PRIMARY KEY AUTO_INCREMENT,
    position_name VARCHAR(100) NOT NULL UNIQUE,
    description   VARCHAR(255),
    status        TINYINT(1)   NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;



-- BẢNG 4: salary_grades
CREATE TABLE salary_grades (
    salary_grade_id INT          PRIMARY KEY AUTO_INCREMENT,
    grade_name      VARCHAR(100) NOT NULL UNIQUE,
    base_salary     DECIMAL(15,2) NOT NULL,
    coefficient     DECIMAL(5,2)  DEFAULT 1.00,
    description     VARCHAR(255),
    status          TINYINT(1)    DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- BẢNG 5: contract_types
CREATE TABLE contract_types (
    contract_type_id INT          PRIMARY KEY AUTO_INCREMENT,
    type_name        VARCHAR(100) NOT NULL UNIQUE,
    description      VARCHAR(255),
    duration         INT          NULL,
    duration_unit    VARCHAR(50)  NULL,
    status           TINYINT(1)   NOT NULL DEFAULT 1,
    created_at       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- BẢNG 6: allowances
CREATE TABLE allowances (
    allowance_id    INT           PRIMARY KEY AUTO_INCREMENT,
    allowance_name  VARCHAR(100)  NOT NULL UNIQUE,
    description     VARCHAR(255),
    amount          DECIMAL(15,2) NOT NULL DEFAULT 0,
    apply_condition VARCHAR(255),
    status          TINYINT(1)    NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- BẢNG 7: insurance_rates
CREATE TABLE insurance_rates (
    insurance_rate_id INT          PRIMARY KEY AUTO_INCREMENT,
    insurance_code    VARCHAR(20)  NOT NULL DEFAULT '',
    insurance_name    VARCHAR(100) NOT NULL UNIQUE,
    company_rate      DECIMAL(5,2) NOT NULL,
    employee_rate     DECIMAL(5,2) NOT NULL,
    description       VARCHAR(255),
    effective_from    DATE         NULL,
    effective_to      DATE         NULL,
    created_at        TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at        TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    status            TINYINT(1)   NOT NULL DEFAULT 1,
    UNIQUE KEY uk_insurance_code (insurance_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- BẢNG 8: employment_statuses
CREATE TABLE employment_statuses (
    status_id   INT          PRIMARY KEY AUTO_INCREMENT,
    status_name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(255),
    status      TINYINT(1)   NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- BẢNG 9: education_levels
CREATE TABLE education_levels (
    education_level_id INT          PRIMARY KEY AUTO_INCREMENT,
    level_name         VARCHAR(100) NOT NULL UNIQUE,
    description        VARCHAR(255),
    status             TINYINT(1)   NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- BẢNG 10: shifts
CREATE TABLE shifts (
    shift_id       INT          PRIMARY KEY AUTO_INCREMENT,
    shift_name     VARCHAR(50)  NOT NULL,
    start_time     TIME         NOT NULL,
    end_time       TIME         NOT NULL,
    break_start    TIME,
    break_end      TIME,
    is_night_shift TINYINT(1)   NOT NULL DEFAULT 0,
    coefficient    DECIMAL(5,2) NOT NULL DEFAULT 1.00,
    working_days   VARCHAR(50),
    status         TINYINT(1)   NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- BẢNG 11: leave_types
CREATE TABLE leave_types (
    leave_type_id INT         PRIMARY KEY AUTO_INCREMENT,
    type_name     VARCHAR(255) NOT NULL,
    description   VARCHAR(500),
    paid_leave    TINYINT(1)  DEFAULT 1,
    max_days_per_year INT,
    status        TINYINT(1)  NOT NULL DEFAULT 1,
    UNIQUE KEY uk_leave_types_type_name (type_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- BẢNG 12: reward_disciplines
CREATE TABLE reward_disciplines (
    id          INT          PRIMARY KEY AUTO_INCREMENT,
    name        VARCHAR(100) NOT NULL,
    type        VARCHAR(20)  NOT NULL,
    description VARCHAR(255),
    apply_level VARCHAR(50)  DEFAULT 'Cá nhân',
    status      TINYINT(1)   NOT NULL DEFAULT 1,
    created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by  INT          NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================
-- NHÓM 2: PHÂN QUYỀN HỆ THỐNG
-- =============================================================

CREATE TABLE roles (
    role_id     INT          PRIMARY KEY AUTO_INCREMENT,
    role_name   VARCHAR(50)  NOT NULL UNIQUE,
    description VARCHAR(255),
    status      TINYINT(1)   NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE permissions (
    permission_id   INT          PRIMARY KEY AUTO_INCREMENT,
    permission_name VARCHAR(100) NOT NULL UNIQUE,
    description     VARCHAR(255),
    module          VARCHAR(50)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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

CREATE TABLE users (
    user_id       INT          PRIMARY KEY AUTO_INCREMENT,
    username      VARCHAR(50)  NOT NULL UNIQUE,
    password      VARCHAR(255) NOT NULL,
    full_name     VARCHAR(100),
    email         VARCHAR(100) UNIQUE,
    phone         VARCHAR(20),
    status        TINYINT(1)   NOT NULL DEFAULT 1,
    role_id       INT,
    department_id INT,
    position_id   INT,
    created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_user_role FOREIGN KEY (role_id)       REFERENCES roles(role_id)             ON DELETE SET NULL,
    CONSTRAINT fk_user_dept FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE SET NULL,
    CONSTRAINT fk_user_pos  FOREIGN KEY (position_id)   REFERENCES positions(position_id)     ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE employee_profiles (
    profile_id           INT          PRIMARY KEY AUTO_INCREMENT,
    user_id              INT          NOT NULL UNIQUE,
    department_id        INT,
    id_card              VARCHAR(20),
    dob                  DATE,
    gender               TINYINT(1),
    address              VARCHAR(255),
    hire_date            DATE,
    tax_code             VARCHAR(50),
    social_insurance_no  VARCHAR(50),
    bank_account         VARCHAR(50),
    bank_name            VARCHAR(100),
    contract_type_id     INT,
    salary_grade_id      INT,
    employment_status_id INT,
    education_level_id   INT,
    CONSTRAINT fk_profile_user FOREIGN KEY (user_id)              REFERENCES users(user_id)                         ON DELETE CASCADE,
    CONSTRAINT fk_profile_dept FOREIGN KEY (department_id)        REFERENCES departments(department_id)             ON DELETE SET NULL,
    CONSTRAINT fk_profile_ct   FOREIGN KEY (contract_type_id)     REFERENCES contract_types(contract_type_id)       ON DELETE SET NULL,
    CONSTRAINT fk_profile_sg   FOREIGN KEY (salary_grade_id)      REFERENCES salary_grades(salary_grade_id)         ON DELETE SET NULL,
    CONSTRAINT fk_profile_es   FOREIGN KEY (employment_status_id) REFERENCES employment_statuses(status_id)         ON DELETE SET NULL,
    CONSTRAINT fk_profile_ed   FOREIGN KEY (education_level_id)   REFERENCES education_levels(education_level_id)   ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE dependents (
    dependent_id INT          PRIMARY KEY AUTO_INCREMENT,
    user_id      INT          NOT NULL,
    full_name    VARCHAR(100) NOT NULL,
    relationship VARCHAR(50)  NOT NULL,
    dob          DATE,
    tax_code     VARCHAR(50),
    status       TINYINT(1)   NOT NULL DEFAULT 1,
    CONSTRAINT fk_dep_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE work_history (
    history_id     INT          PRIMARY KEY AUTO_INCREMENT,
    user_id        INT          NOT NULL,
    position_title VARCHAR(100) NOT NULL,
    company_name   VARCHAR(100) DEFAULT 'Công ty TNHH Group4',
    location       VARCHAR(100) DEFAULT 'TP. Hồ Chí Minh',
    start_date     DATE         NOT NULL,
    end_date       DATE,
    description    TEXT,
    is_current     TINYINT(1)   DEFAULT 0,
    CONSTRAINT fk_wh_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE onboarding_requests (
    id              INT AUTO_INCREMENT PRIMARY KEY,

    -- Thông tin ứng viên (từ OCR CCCD)
    full_name       VARCHAR(150)    NOT NULL,
    email           VARCHAR(150)    NOT NULL,
    phone           VARCHAR(20),
    cccd_number     VARCHAR(20),
    date_of_birth   DATE,
    address         TEXT,
    gender          TINYINT(1)      DEFAULT NULL COMMENT '1=Nam, 0=Nữ',

    -- Vị trí dự kiến
    department_id   INT             DEFAULT NULL,
    position_id     INT             DEFAULT NULL,
    role_id         INT             DEFAULT 7    COMMENT 'Mặc định: Nhân viên',

    -- Trạng thái: DRAFT / PENDING / APPROVED / REJECTED
    status          ENUM('DRAFT','PENDING','APPROVED','REJECTED') NOT NULL DEFAULT 'DRAFT',
    reject_reason   TEXT            DEFAULT NULL COMMENT 'Lý do từ chối (Admin ghi)',

    -- Metadata
    created_by      INT             NOT NULL     COMMENT 'HR user_id gửi yêu cầu',
    processed_by    INT             DEFAULT NULL COMMENT 'Admin user_id xử lý',
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    -- FK
    CONSTRAINT fk_onb_dept     FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE SET NULL,
    CONSTRAINT fk_onb_pos      FOREIGN KEY (position_id)   REFERENCES positions(position_id)     ON DELETE SET NULL,
    CONSTRAINT fk_onb_creator  FOREIGN KEY (created_by)    REFERENCES users(user_id),
    CONSTRAINT fk_onb_processor FOREIGN KEY (processed_by) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Index tìm kiếm nhanh
CREATE INDEX idx_onb_status     ON onboarding_requests(status);
CREATE INDEX idx_onb_created_by ON onboarding_requests(created_by);
CREATE INDEX idx_onb_cccd       ON onboarding_requests(cccd_number);
CREATE INDEX idx_onb_email      ON onboarding_requests(email);


-- =============================================================
-- NHÓM 4: NGHIỆP VỤ (ATTENDANCE, LEAVE, PAYROLL)
-- =============================================================

CREATE TABLE shift_assignments (
    assignment_id INT  PRIMARY KEY AUTO_INCREMENT,
    user_id       INT  NOT NULL,
    shift_id      INT  NOT NULL,
    assigned_date DATE NOT NULL,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_sa_user  FOREIGN KEY (user_id)  REFERENCES users(user_id)   ON DELETE CASCADE,
    CONSTRAINT fk_sa_shift FOREIGN KEY (shift_id) REFERENCES shifts(shift_id) ON DELETE CASCADE,
    INDEX idx_user_date (user_id, assigned_date),
    UNIQUE KEY idx_user_shift_date (user_id, shift_id, assigned_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE attendance (
    attendance_id INT         PRIMARY KEY AUTO_INCREMENT,
    user_id       INT         NOT NULL,
    shift_id      INT         NOT NULL,
    work_date     DATE        NOT NULL,
    check_in      TIME,
    check_out     TIME,
    status        VARCHAR(30) DEFAULT 'Present',
    overtime_hrs  DECIMAL(5,2) DEFAULT 0,
    ot_reason     VARCHAR(255),
    created_at    TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_att_user  FOREIGN KEY (user_id)  REFERENCES users(user_id)   ON DELETE CASCADE,
    CONSTRAINT fk_att_shift FOREIGN KEY (shift_id) REFERENCES shifts(shift_id) ON DELETE RESTRICT,
    UNIQUE KEY uk_user_date (user_id, work_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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
    reject_reason VARCHAR(255),
    attachment    VARCHAR(255),
    created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_leave_user     FOREIGN KEY (user_id)       REFERENCES users(user_id)                 ON DELETE CASCADE,
    CONSTRAINT fk_leave_type     FOREIGN KEY (leave_type_id) REFERENCES leave_types(leave_type_id)     ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE payroll (
    payroll_id       INT PRIMARY KEY AUTO_INCREMENT,
    user_id          INT NOT NULL,
    month            INT NOT NULL,
    year             INT NOT NULL,
    base_salary      DECIMAL(15,2),
    working_days     DECIMAL(5,1),
    overtime_amount  DECIMAL(15,2),
    allowance_amount DECIMAL(15,2),
    bonus_amount     DECIMAL(15,2),
    deduction_amount DECIMAL(15,2),
    insurance_amount DECIMAL(15,2),
    tax_amount       DECIMAL(15,2),
    gross_salary     DECIMAL(15,2),
    net_salary       DECIMAL(15,2),
    status           ENUM('Draft','Pending','Verified','Approved','Rejected','Paid') DEFAULT 'Draft',
    approved_by      INT NULL,
    approved_at      TIMESTAMP NULL,
    reject_reason    VARCHAR(500) NULL,
    paid_by          INT NULL,
    paid_at          TIMESTAMP NULL,
    payment_note     VARCHAR(500) NULL,
    created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (approved_by) REFERENCES users(user_id) ON DELETE SET NULL,
    FOREIGN KEY (paid_by) REFERENCES users(user_id) ON DELETE SET NULL,
    UNIQUE KEY uk_user_month_year (user_id, month, year)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE notifications (
    id         INT          NOT NULL AUTO_INCREMENT,
    user_id    INT          NOT NULL,
    type       VARCHAR(30)  NOT NULL DEFAULT 'system',
    title      VARCHAR(120) NOT NULL,
    body       VARCHAR(255) NOT NULL DEFAULT '',
    link       VARCHAR(255) DEFAULT NULL,
    is_read    TINYINT(1)   NOT NULL DEFAULT 0,
    created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX idx_user_read (user_id, is_read),
    INDEX idx_created   (created_at),
    CONSTRAINT fk_notif_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE employee_shifts (
    id        INT  PRIMARY KEY AUTO_INCREMENT,
    user_id   INT  NOT NULL,
    shift_id  INT  NOT NULL,
    work_date DATE NOT NULL,
    FOREIGN KEY (user_id)  REFERENCES users(user_id),
    FOREIGN KEY (shift_id) REFERENCES shifts(shift_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- BẢNG: attendance_claims (Đơn khiếu nại chấm công)
CREATE TABLE attendance_claims (
    claim_id     INT          PRIMARY KEY AUTO_INCREMENT,
    attendance_id INT         NOT NULL,
    user_id      INT          NOT NULL,
    work_date    DATE         NOT NULL,
    claim_type   VARCHAR(30)  NOT NULL DEFAULT 'OTHER',
    description  TEXT,
    status       VARCHAR(20)  NOT NULL DEFAULT 'PENDING',
    hr_note      VARCHAR(500),
    resolved_by  INT,
    resolved_at  TIMESTAMP    NULL,
    created_at   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_claim_att  FOREIGN KEY (attendance_id) REFERENCES attendance(attendance_id) ON DELETE CASCADE,
    CONSTRAINT fk_claim_user FOREIGN KEY (user_id)       REFERENCES users(user_id)            ON DELETE CASCADE,
    CONSTRAINT fk_claim_res  FOREIGN KEY (resolved_by)   REFERENCES users(user_id)            ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- BẢNG: timesheet_lock (Khóa bảng chấm công theo tháng)
CREATE TABLE timesheet_lock (
    lock_id   INT       PRIMARY KEY AUTO_INCREMENT,
    month     INT       NOT NULL,
    year      INT       NOT NULL,
    status    VARCHAR(20) NOT NULL DEFAULT 'UNLOCKED',
    locked_by INT,
    locked_at TIMESTAMP NULL,
    note      VARCHAR(500),
    UNIQUE KEY uk_month_year (month, year),
    CONSTRAINT fk_lock_user FOREIGN KEY (locked_by) REFERENCES users(user_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================
-- NHÓM 5: LƯƠNG - C&B
-- =============================================================

CREATE TABLE employee_allowances (
    id           INT           PRIMARY KEY AUTO_INCREMENT,
    user_id      INT           NOT NULL,
    allowance_id INT           NOT NULL,
    amount       DECIMAL(15,2) NOT NULL,
    FOREIGN KEY (user_id)      REFERENCES users(user_id),
    FOREIGN KEY (allowance_id) REFERENCES allowances(allowance_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE employee_rewards_disciplines (
    id                   INT           PRIMARY KEY AUTO_INCREMENT,
    user_id              INT           NOT NULL,
    reward_discipline_id INT           NOT NULL,
    amount               DECIMAL(15,2) NOT NULL,
    note                 VARCHAR(255),
    applied_date         DATE,
    FOREIGN KEY (user_id)              REFERENCES users(user_id),
    FOREIGN KEY (reward_discipline_id) REFERENCES reward_disciplines(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. BẬT LẠI KIỂM TRA KHÓA NGOẠI
SET FOREIGN_KEY_CHECKS = 1;

-- =========================================================================
-- =========================== SEED DATA ===================================
-- =========================================================================

-- ── 1. Departments ──
INSERT INTO departments (department_id, department_name, description) VALUES
(1, 'Hành chính',     'Phụ trách thiết bị, văn phòng phẩm, lễ tân'),
(2, 'Nhân sự',        'Tuyển dụng, đào tạo, C&B'),
(3, 'Kế toán',        'Tài chính, công nợ, thuế'),
(4, 'Kinh doanh',     'Sales thương mại, phát triển thị trường'),
(5, 'Xưởng sản xuất', 'Trực tiếp sản xuất sản phẩm');

-- ── 2. Positions ──
INSERT INTO positions (position_id, position_name, description) VALUES
(1, 'Giám đốc',      'Quản lý điều hành'),
(2, 'Trưởng phòng',  'Quản lý phòng ban'),
(3, 'Phó phòng',     'Hỗ trợ trưởng phòng'),
(4, 'Quản đốc',      'Quản lý xưởng sản xuất'),
(5, 'Tổ trưởng',     'Quản lý tổ trong xưởng'),
(6, 'Kế toán trưởng','Trưởng phòng Kế toán'),
(7, 'Chuyên viên',   'Nhân sự có chuyên môn sâu (Văn phòng)'),
(8, 'Nhân viên',     'Nhân viên cơ bản (Văn phòng/Sales)'),
(9, 'Công nhân',     'Lao động tại xưởng');


-- ── 4. Salary Grades ──
INSERT INTO salary_grades (salary_grade_id, grade_name, base_salary, coefficient, description) VALUES
(1, 'Ngạch Quản lý',   30000000, 1.50, 'Giám đốc, Trưởng phòng'),
(2, 'Ngạch Chuyên viên',12000000, 1.20, 'Khối văn phòng'),
(3, 'Ngạch Kinh doanh', 10000000, 1.00, 'Nhân viên kinh doanh'),
(4, 'Ngạch Sản xuất',    7000000, 1.00, 'Công nhân sản xuất');

-- ── 5. Contract Types ──
INSERT INTO contract_types (contract_type_id, type_name, description, duration, duration_unit) VALUES
(1, 'Thử việc',           'Hợp đồng thử việc 2 tháng', 2, 'Tháng'),
(2, 'Có thời hạn 1 năm',  'Hợp đồng lao động 12 tháng', 1, 'Năm'),
(3, 'Có thời hạn 3 năm',  'Hợp đồng lao động 36 tháng', 3, 'Năm'),
(4, 'Vô thời hạn',        'Hợp đồng không xác định thời hạn', NULL, 'Vô thời hạn'),
(5, 'Thời vụ',            'Dành cho lao động ngắn hạn ở xưởng', 3, 'Tháng');

-- ── 6. Allowances ──
INSERT INTO allowances (allowance_id, allowance_name, description, amount, apply_condition) VALUES
(1, 'Ăn trưa',    'Phụ cấp ăn ca',                    800000,  'Áp dụng cho tất cả nhân viên chính thức'),
(2, 'Đi lại',     'Phụ cấp xăng xe',                  500000,  'Áp dụng cho nhân viên không ở trong ký túc xá'),
(3, 'Trách nhiệm','Cho quản đốc, tổ trưởng',          1000000, 'Áp dụng cho quản đốc và tổ trưởng'),
(4, 'Độc hại',    'Cho công nhân xưởng',               300000,  'Áp dụng cho công nhân làm việc trực tiếp tại xưởng'),
(5, 'Chuyên cần', 'Thưởng đi làm đầy đủ',             500000,  'Không nghỉ phép, không đi muộn trong tháng');

-- ── 7. Insurance Rates (BHXH / BHYT / BHTN) ──
INSERT INTO insurance_rates (insurance_rate_id, insurance_code, insurance_name, company_rate, employee_rate, description, effective_from) VALUES
(1, 'BHXH', 'Bảo hiểm Xã hội (BHXH)',       17.5, 8.0, 'Bảo hiểm xã hội theo quy định pháp luật', '2020-01-01'),
(2, 'BHYT', 'Bảo hiểm Y tế (BHYT)',          3.0,  1.5, 'Bảo hiểm y tế bắt buộc',                  '2020-01-01'),
(3, 'BHTN', 'Bảo hiểm Thất nghiệp (BHTN)',   1.0,  1.0, 'Bảo hiểm thất nghiệp theo quy định',       '2020-01-01');

-- ── 8. Employment Statuses ──
INSERT INTO employment_statuses (status_id, status_name, description) VALUES
(1, 'Đang thử việc',  'Đang trong thời gian đánh giá'),
(2, 'Đang làm việc',  'Nhân viên chính thức'),
(3, 'Tạm hoãn HĐLĐ', 'Nghỉ ốm dài ngày, Thai sản'),
(4, 'Đã nghỉ việc',   'Chấm dứt Hợp đồng');

-- ── 9. Education Levels ──
INSERT INTO education_levels (education_level_id, level_name) VALUES
(1, 'Trên Đại học'),
(2, 'Đại học'),
(3, 'Cao đẳng'),
(4, 'Trung cấp/Nghề'),
(5, 'Lao động phổ thông');

-- ── 10. Shifts ──
INSERT INTO shifts (shift_id, shift_name, start_time, end_time, break_start, break_end, is_night_shift, coefficient, working_days) VALUES
(1, 'Ca Hành Chính','07:30:00','17:30:00','11:00:00','13:00:00', 0, 1.00,'2,3,4,5,6,7'),
(2, 'Ca Đêm 1', '18:00:00','20:00:00', NULL,       NULL,        0, 1.50,'2,3,4,5,6,7'),
(3, 'Ca Đêm 2', '18:00:00','22:00:00', '20:00:00', '20:30:00', 0, 1.50,'2,3,4,5,6,7');

-- ── 11. Leave Types ──
INSERT INTO leave_types (leave_type_id, type_name, description, paid_leave, max_days_per_year) VALUES
(1, 'Nghỉ phép năm',           'Nghỉ phép theo quy định',                 1, 12),
(2, 'Nghỉ ốm (Hưởng BHXH)',    'Nghỉ ốm hưởng chế độ BHXH',               0, NULL),
(3, 'Nghỉ thai sản',           'Chế độ thai sản theo quy định',           0, NULL),
(4, 'Nghỉ việc riêng có lương','Nghỉ việc riêng vẫn tính lương',          1, NULL),
(5, 'Nghỉ không lương',        'Nghỉ không hưởng lương',                  0, NULL);

-- ── 12. Reward Disciplines ──
INSERT INTO reward_disciplines (id, name, type, description, apply_level, created_by) VALUES
(1, 'Thưởng KPI Tháng',      'Reward',    'Thưởng dựa trên đánh giá hiệu suất',                           'Cá nhân',    1),
(2, 'Thưởng Dự án',          'Reward',    'Thưởng hoàn thành xuất sắc dự án',                             'Nhóm/Dự án', 1),
(3, 'Thưởng Chuyên cần',     'Reward',    'Không đi muộn, không nghỉ phép trong tháng',                   'Cá nhân',    1),
(4, 'Đi muộn/Về sớm',        'Discipline','Phạt đi muộn theo quy định',                                    'Cá nhân',    1),
(5, 'Vi phạm An toàn LĐ',    'Discipline','Phạt do không tuân thủ an toàn tại xưởng',                     'Cá nhân',    1),
(6, 'Warning',               'Discipline','Cảnh báo vi phạm kỷ luật',                                     'Cá nhân',    1),
(7, 'Vi phạm kỷ luật khác',  'Discipline','Các hình thức vi phạm nội quy khác',                           'Cá nhân',    1),
(8, 'Dismissal',             'Discipline','Sa thải / Chấm dứt hợp đồng lao động do vi phạm nghiêm trọng','Cá nhân',    1);

-- ── 13. Roles (8 roles) ──
INSERT INTO roles (role_id, role_name, description) VALUES
(1, 'Admin',              'Quản trị hệ thống toàn quyền'),
(2, 'HR Manager',         'Trưởng phòng Nhân sự - duyệt attendance, payroll'),
(3, 'Factory Manager',    'Quản đốc xưởng - duyệt OT, phân ca'),
(4, 'Director',           'Giám đốc - xem tổng quan, duyệt lương cuối'),
(5, 'HR Staff',           'Nhân viên Nhân sự - upload Excel, quản lý hồ sơ'),
(6, 'Department Manager', 'Trưởng phòng / Tổ trưởng - duyệt nghỉ phép'),
(7, 'Employee',           'Nhân viên / Công nhân'),
(8, 'Accountant',         'Kế toán - xem bảng lương, xác nhận chuyển khoản');

-- ── 14. Permissions (29 permissions) ──
INSERT INTO permissions (permission_id, permission_name, description, module) VALUES
-- USER
(1,  'USER_MANAGE',            'Thêm, sửa, xóa người dùng',              'USER'),
(2,  'USER_VIEW',              'Xem danh sách người dùng',                'USER'),
-- ROLE
(3,  'ROLE_VIEW',              'Xem danh sách vai trò',                   'ROLE'),
(4,  'ROLE_UPDATE_INFORMATION','Cập nhật thông tin vai trò',              'ROLE'),
(5,  'ROLE_PERMISSION_VIEW',   'Xem phân quyền của vai trò',              'ROLE'),
(6,  'ROLE_PERMISSION_MANAGE', 'Chỉnh sửa phân quyền vai trò',            'ROLE'),
-- DEPARTMENT
(7,  'DEPARTMENT_VIEW',        'Xem danh sách phòng ban',                 'DEPARTMENT'),
(8,  'DEPARTMENT_MANAGE',      'Thêm, sửa, xóa phòng ban',               'DEPARTMENT'),
-- POSITION
(9,  'POSITION_VIEW',          'Xem danh sách chức vụ',                   'POSITION'),
(10, 'POSITION_MANAGE',        'Thêm, sửa, xóa chức vụ',                 'POSITION'),
-- ATTENDANCE
(13, 'ATTENDANCE_VIEW',        'Xem bảng chấm công',                      'ATTENDANCE'),
(14, 'ATTENDANCE_MANAGE',      'Quản lý chấm công',                       'ATTENDANCE'),
-- LEAVE
(15, 'LEAVE_VIEW',             'Xem đơn xin nghỉ phép',                   'LEAVE'),
(16, 'LEAVE_MANAGE',           'Quản lý đơn nghỉ phép',                   'LEAVE'),
(17, 'LEAVE_APPROVE',          'Phê duyệt / từ chối đơn nghỉ phép',       'LEAVE'),
-- PAYROLL
(18, 'PAYROLL_VIEW',           'Xem bảng lương',                          'PAYROLL'),
(19, 'PAYROLL_MANAGE',         'Quản lý tính lương',                      'PAYROLL'),
-- REPORT
(20, 'REPORT_VIEW',            'Xem báo cáo thống kê',                    'REPORT'),
-- SYSTEM
(21, 'SYSTEM_CONFIG',          'Cấu hình hệ thống',                       'SYSTEM'),
-- ATTENDANCE (mới)
(22, 'ATTENDANCE_UPLOAD',      'Upload file Excel chấm công',             'ATTENDANCE'),
-- OVERTIME (mới)
(23, 'OT_VIEW',                'Xem đơn tăng ca',                         'OVERTIME'),
(24, 'OT_APPROVE',             'Duyệt đơn tăng ca',                       'OVERTIME'),
(25, 'OT_MANAGE',              'Gửi / quản lý đơn tăng ca',               'OVERTIME'),
-- PAYROLL (mới)
(26, 'PAYROLL_APPROVE',        'Duyệt bảng lương',                        'PAYROLL'),
-- SHIFT (mới)
(27, 'SHIFT_MANAGE',           'Quản lý ca làm việc',                     'SHIFT'),
-- PROFILE (mới)
(28, 'PROFILE_VIEW',           'Xem hồ sơ nhân viên',                     'PROFILE'),
(29, 'PROFILE_MANAGE',         'Chỉnh sửa hồ sơ nhân viên',               'PROFILE');

-- ── 15. Role Permissions ──

-- Admin (1): Toàn quyền
INSERT INTO role_permissions (role_id, permission_id) VALUES
(1,1),(1,2),(1,3),(1,4),(1,5),(1,6),(1,7),(1,8),(1,9),(1,10),
(1,13),(1,14),(1,15),(1,16),(1,17),(1,18),(1,19),(1,20),
(1,21),(1,22),(1,23),(1,24),(1,25),(1,26),(1,27),(1,28),(1,29);

-- HR Manager (2): Quản lý nhân sự, chấm công, nghỉ phép, lương
INSERT INTO role_permissions (role_id, permission_id) VALUES
(2,1),(2,2),(2,7),(2,8),(2,9),(2,10),(2,13),(2,14),(2,15),
(2,16),(2,17),(2,18),(2,19),(2,20),(2,22),(2,23),(2,25),(2,26),(2,28),(2,29);

-- Factory Manager / Quản đốc (3): Chấm công, nghỉ phép, OT, ca
INSERT INTO role_permissions (role_id, permission_id) VALUES
(3,2),(3,7),(3,9),(3,13),(3,14),(3,15),(3,16),(3,17),
(3,23),(3,24),(3,25),(3,27),(3,28),(3,29);

-- Director (4): Xem tất cả, duyệt lương cuối
INSERT INTO role_permissions (role_id, permission_id) VALUES
(4,2),(4,3),(4,5),(4,7),(4,9),(4,13),(4,15),(4,18),(4,20),
(4,23),(4,26),(4,28);

-- HR Staff (5): Upload, quản lý hồ sơ, duyệt đơn cơ bản
INSERT INTO role_permissions (role_id, permission_id) VALUES
(5,1),(5,2),(5,7),(5,9),(5,13),(5,14),(5,15),(5,16),(5,17),
(5,18),(5,20),(5,22),(5,23),(5,25),(5,28),(5,29);

-- Department Manager / Trưởng phòng (6): Duyệt phép, xem chấm công phòng
INSERT INTO role_permissions (role_id, permission_id) VALUES
(6,2),(6,7),(6,9),(6,13),(6,15),(6,17),(6,18),(6,20),(6,23),(6,28);

-- Employee (7): Xem thông tin cá nhân, gửi đơn
INSERT INTO role_permissions (role_id, permission_id) VALUES
(7,13),(7,15),(7,16),(7,18),(7,23),(7,25),(7,28);

-- Accountant (8): Xem bảng lương, xem hồ sơ
INSERT INTO role_permissions (role_id, permission_id) VALUES
(8,18),(8,28);

-- ── 16. Users & Profiles ──

-- ── 16a. Users cốt lõi (user_id 1-5) ──
INSERT INTO users (user_id,username,password,full_name,email,phone,role_id,department_id,position_id) VALUES
(1,'admin',     '@123456','Quản Trị Viên',          'admin@hrm.com',     '0900000001',1,NULL,NULL),
(2,'giam_doc',  '@123456','Nguyễn Văn Giám Đốc',    'giamdoc@hrm.com',   '0901000002',4,1,1),
(3,'hr_manager','@123456','Trần Thị Nhân Sự',       'hr@hrm.com',        '0901000003',2,2,2),
(4,'quan_doc',  '@123456','Lê Văn Quản Đốc',        'quandoc@hrm.com',   '0901000004',3,5,4),
(5,'cong_nhan', '@123456','Phạm Công Nhân',          'cn1@hrm.com',       '0901000005',7,5,9);

-- ── 16b. Profiles users 2-5 ──
INSERT INTO employee_profiles (user_id,department_id,id_card,dob,gender,address,hire_date,tax_code,social_insurance_no,bank_account,bank_name,contract_type_id,salary_grade_id,employment_status_id,education_level_id) VALUES
(2,1,'001085000001','1985-01-01',1,'Hà Nội',     '2020-01-01','8012345678','0100001001','190300001','Vietcombank',4,1,2,1),
(3,2,'001090000002','1990-05-15',0,'Hà Nội',     '2021-03-10','8012345679','0100001002','190300002','BIDV',        4,2,2,2),
(4,5,'001088000003','1988-08-20',1,'Hải Phòng',  '2020-06-01','8012345680','0100001003','190300003','Techcombank',4,2,2,2),
(5,5,'001095000004','1995-12-10',1,'Bắc Ninh',   '2022-02-15','8012345681','0100001004','190300004','Agribank',   2,4,2,5);

-- ── 16c. Dependents ──
INSERT INTO dependents (user_id, full_name, relationship, dob) VALUES
(3,'Nguyễn Bé Bỏng','Con ruột','2020-10-10'),
(5,'Phạm Thị Mẹ',   'Mẹ ruột', '1960-01-01');

-- ── 17. Nhân viên Quản lý (user_id 6-32, 27 người) ──

-- Phòng Hành Chính (dept=1): 4 mới + giam_doc = 5
INSERT INTO users (user_id,username,password,full_name,email,phone,role_id,department_id,position_id) VALUES
(6, 'tp_hanh_chinh','@123456','Đỗ Thị Hà',    'tp_hc@hrm.com',  '0901000006',6,1,2),
(7, 'pp_hanh_chinh','@123456','Ngô Văn Tài',   'pp_hc@hrm.com',  '0901000007',7,1,3),
(8, 'cv_hc_01',     '@123456','Vũ Thị Nga',    'cv_hc1@hrm.com', '0901000008',7,1,7),
(9, 'cv_hc_02',     '@123456','Đinh Văn Phúc', 'cv_hc2@hrm.com', '0901000009',7,1,7);

-- Phòng Nhân Sự (dept=2): 4 HR Staff + hr_manager = 5
INSERT INTO users (user_id,username,password,full_name,email,phone,role_id,department_id,position_id) VALUES
(10,'hr_staff_01','@123456','Đặng Thị Hồng','hrs1@hrm.com','0901000010',5,2,8),
(11,'hr_staff_02','@123456','Chu Văn Minh', 'hrs2@hrm.com','0901000011',5,2,8),
(12,'hr_staff_03','@123456','Lý Thị Loan',  'hrs3@hrm.com','0901000012',5,2,8),
(13,'hr_staff_04','@123456','Tạ Văn Sơn',   'hrs4@hrm.com','0901000013',5,2,8);

-- Phòng Kế Toán (dept=3): 5 mới
INSERT INTO users (user_id,username,password,full_name,email,phone,role_id,department_id,position_id) VALUES
(14,'ke_toan_truong','@123456','Phan Thị Khánh','ktt@hrm.com',    '0901000014',6,3,6),
(15,'pp_ke_toan',    '@123456','Trịnh Văn Hùng','pp_kt@hrm.com',  '0901000015',7,3,3),
(16,'cv_kt_01',      '@123456','Cao Thị Lan',   'cv_kt1@hrm.com', '0901000016',7,3,7),
(17,'cv_kt_02',      '@123456','Bùi Văn Tuấn',  'cv_kt2@hrm.com', '0901000017',7,3,7),
(18,'cv_kt_03',      '@123456','Đinh Thị Mai',  'cv_kt3@hrm.com', '0901000018',7,3,7);

-- Phòng Kinh Doanh (dept=4): 10 mới
INSERT INTO users (user_id,username,password,full_name,email,phone,role_id,department_id,position_id) VALUES
(19,'tp_kinh_doanh','@123456','Hoàng Văn Lộc', 'tp_kd@hrm.com',  '0901000019',6,4,2),
(20,'pp_kinh_doanh','@123456','Vũ Thị Thủy',   'pp_kd@hrm.com',  '0901000020',7,4,3),
(21,'nv_kd_01',     '@123456','Nguyễn Văn Phú','nv_kd1@hrm.com', '0901000021',7,4,8),
(22,'nv_kd_02',     '@123456','Trần Thị Bích', 'nv_kd2@hrm.com', '0901000022',7,4,8),
(23,'nv_kd_03',     '@123456','Lê Văn Sáng',   'nv_kd3@hrm.com', '0901000023',7,4,8),
(24,'nv_kd_04',     '@123456','Phạm Thị Dung', 'nv_kd4@hrm.com', '0901000024',7,4,8),
(25,'nv_kd_05',     '@123456','Đỗ Văn Hòa',    'nv_kd5@hrm.com', '0901000025',7,4,8),
(26,'nv_kd_06',     '@123456','Ngô Thị Xuân',  'nv_kd6@hrm.com', '0901000026',7,4,8),
(27,'nv_kd_07',     '@123456','Bùi Văn Cường', 'nv_kd7@hrm.com', '0901000027',7,4,8),
(28,'nv_kd_08',     '@123456','Hoàng Thị Ánh', 'nv_kd8@hrm.com', '0901000028',7,4,8);

-- Xưởng Sản Xuất - Quản lý (dept=5): 4 mới + quan_doc = 5
INSERT INTO users (user_id,username,password,full_name,email,phone,role_id,department_id,position_id) VALUES
(29,'to_truong_01','@123456','Lý Văn Dũng',   'tt1@hrm.com',  '0901000029',6,5,5),
(30,'to_truong_02','@123456','Tống Văn Thắng','tt2@hrm.com',  '0901000030',6,5,5),
(31,'to_truong_03','@123456','Hà Thị Giang',  'tt3@hrm.com',  '0901000031',6,5,5),
(32,'to_pho_01',   '@123456','Đinh Văn Khoa', 'tp_x@hrm.com', '0901000032',7,5,5),
(33, 'ke_toan_01', '@123456', 'Nguyễn Thị Kế Toán', 'ketoan01@hrm.com', '0901000033', 8, 3, 7);

-- ── Profiles quản lý (user_id 6-32) ──
-- Format: (uid, id_card, dob, gender, address, hire_date, tax_code, bank_account, ct, sg, es, el)
-- Format: (uid, dept_id, id_card, dob, gender, address, hire_date, tax_code, social_insurance_no, bank_account, bank_name, ct, sg, es, el)
INSERT INTO employee_profiles (user_id,department_id,id_card,dob,gender,address,hire_date,tax_code,social_insurance_no,bank_account,bank_name,contract_type_id,salary_grade_id,employment_status_id,education_level_id) VALUES
(6, 1,'024880000006','1988-06-20',0,'Cầu Giấy, Hà Nội',     '2018-03-01','8012345706','0200001006','0011234506','Vietcombank',4,1,2,2),
(7, 1,'024920000007','1992-04-10',1,'Đống Đa, Hà Nội',       '2020-05-01','8012345707','0200001007','0011234507','BIDV',        4,2,2,2),
(8, 1,'024950000008','1995-08-15',0,'Ba Đình, Hà Nội',        '2021-01-10','8012345708','0200001008','0011234508','Techcombank', 3,2,2,2),
(9, 1,'024930000009','1993-11-22',1,'Hoàn Kiếm, Hà Nội',     '2022-03-15','8012345709','0200001009','0011234509','Agribank',    2,2,2,2),
(10,2,'024940000010','1994-02-28',0,'Hà Nội',                 '2021-06-01','8012345710','0200001010','0011234510','VPBank',      4,2,2,2),
(11,2,'024960000011','1996-07-14',1,'Hà Nội',                 '2022-08-01','8012345711','0200001011','0011234511','Techcombank', 3,2,2,2),
(12,2,'024970000012','1997-03-05',0,'Hà Nội',                 '2023-01-10','8012345712','0200001012','0011234512','BIDV',        2,2,2,3),
(13,2,'024980000013','1998-09-20',1,'Hà Nội',                 '2023-07-01','8012345713','0200001013','0011234513','Agribank',    1,2,1,3),
(14,3,'024820000014','1982-12-10',0,'Hai Bà Trưng, Hà Nội',  '2015-02-01','8012345714','0200001014','0011234514','Vietcombank', 4,1,2,1),
(15,3,'024870000015','1987-05-18',1,'Thanh Xuân, Hà Nội',    '2018-10-01','8012345715','0200001015','0011234515','BIDV',        4,2,2,2),
(16,3,'024910000016','1991-01-25',0,'Cầu Giấy, Hà Nội',      '2019-04-01','8012345716','0200001016','0011234516','VPBank',      4,2,2,2),
(17,3,'024930000017','1993-08-30',1,'Nam Từ Liêm, Hà Nội',   '2020-01-15','8012345717','0200001017','0011234517','Techcombank', 4,2,2,2),
(18,3,'024950000018','1995-04-12',0,'Hà Nội',                 '2021-09-01','8012345718','0200001018','0011234518','Agribank',    3,2,2,2),
(19,4,'024830000019','1983-07-22',1,'Đống Đa, Hà Nội',       '2016-01-01','8012345719','0200001019','0011234519','Vietcombank', 4,1,2,2),
(20,4,'024890000020','1989-11-08',0,'Hà Nội',                 '2019-03-01','8012345720','0200001020','0011234520','BIDV',        4,2,2,2),
(21,4,'024910000021','1991-05-15',1,'Hà Nội',                 '2020-06-01','8012345721','0200001021','0011234521','VPBank',      3,3,2,2),
(22,4,'024930000022','1993-02-28',0,'Hà Nội',                 '2020-10-01','8012345722','0200001022','0011234522','Agribank',    3,3,2,2),
(23,4,'024940000023','1994-09-10',1,'Hà Nội',                 '2021-03-01','8012345723','0200001023','0011234523','Techcombank', 2,3,2,2),
(24,4,'024960000024','1996-06-20',0,'TP. Hồ Chí Minh',       '2021-08-15','8012345724','0200001024','0011234524','Vietcombank', 2,3,2,2),
(25,4,'024920000025','1992-12-01',1,'TP. Hồ Chí Minh',       '2022-01-10','8012345725','0200001025','0011234525','BIDV',        3,3,2,2),
(26,4,'024980000026','1998-04-05',0,'Hà Nội',                 '2022-07-01','8012345726','0200001026','0011234526','VPBank',      2,3,2,3),
(27,4,'024970000027','1997-08-18',1,'Hà Nội',                 '2023-01-05','8012345727','0200001027','0011234527','Agribank',    2,3,2,2),
(28,4,'024990000028','1999-03-22',0,'Hà Nội',                 '2023-06-01','8012345728','0200001028','0011234528','Techcombank', 1,3,1,2),
(29,5,'056800000029','1980-08-15',1,'Từ Sơn, Bắc Ninh',      '2015-06-01','8012345729','0200001029','0011234529','Vietcombank', 4,2,2,3),
(30,5,'056820000030','1982-03-10',1,'Từ Sơn, Bắc Ninh',      '2017-01-01','8012345730','0200001030','0011234530','BIDV',        4,2,2,3),
(31,5,'056850000031','1985-11-25',0,'Từ Sơn, Bắc Ninh',      '2018-04-01','8012345731','0200001031','0011234531','Agribank',    4,2,2,3),
(32,5,'056880000032','1988-06-30',1,'Từ Sơn, Bắc Ninh',      '2020-09-01','8012345732','0200001032','0011234532','Techcombank', 4,2,2,3),
(33,3,'024910000033','1991-07-15',0,'Cầu Giấy, Hà Nội',       '2020-03-01','8012345733','0200001033','0011234533','Vietcombank', 4,2,2,2);

-- ================================================================
-- 18. CÔNG NHÂN (user_id 33-181, 149 người)
-- ================================================================
-- (Chưa có seed data công nhân — sẽ bổ sung sau)


INSERT INTO employee_rewards_disciplines (user_id, reward_discipline_id, amount, note, applied_date) VALUES
-- Thưởng KPI Tháng (reward_discipline_id = 1)
(6,  1, 2000000, 'Thưởng KPI tháng 5/2026 - Hoàn thành 110% chỉ tiêu',    '2026-05-31'),
(10, 1, 1500000, 'Thưởng KPI tháng 5/2026 - Hoàn thành 105% chỉ tiêu',    '2026-05-31'),
(19, 1, 3000000, 'Thưởng KPI tháng 5/2026 - Doanh thu vượt mục tiêu',      '2026-05-31'),

-- Thưởng Dự án (reward_discipline_id = 2)
(14, 2, 5000000, 'Thưởng hoàn thành xuất sắc dự án kiểm toán nội bộ Q1',   '2026-04-30'),
(21, 2, 2500000, 'Thưởng ký kết hợp đồng lớn với đối tác mới',             '2026-05-15'),

-- Thưởng Chuyên cần (reward_discipline_id = 3)
(9,  3,  500000, 'Chuyên cần tháng 5/2026 - Không nghỉ, không đi muộn',    '2026-05-31'),
(17, 3,  500000, 'Chuyên cần tháng 5/2026 - Không nghỉ, không đi muộn',    '2026-05-31'),

-- Phạt Đi muộn/Về sớm (reward_discipline_id = 4)
(7,  4,  100000, 'Đi muộn 3 lần trong tháng 5/2026',                       '2026-05-31'),
(18, 4,  150000, 'Đi muộn 4 lần trong tháng 5/2026',                       '2026-05-31'),

-- Phạt Vi phạm An toàn LĐ (reward_discipline_id = 5)
(29, 5,  500000, 'Không đeo bảo hộ khi vận hành máy tại xưởng ngày 20/5',  '2026-05-20');

INSERT INTO employee_shifts (user_id, shift_id, work_date) VALUES
(6,  1, '2026-06-03'),
(7,  1, '2026-06-03'),
(8,  1, '2026-06-03'),
(9,  1, '2026-06-03'),
(10, 1, '2026-06-03'),
(29, 1, '2026-06-03'),
(30, 1, '2026-06-03'),
(31, 2, '2026-06-03'),
(32, 2, '2026-06-03'),
(4,  1, '2026-06-03');

INSERT INTO leave_requests (user_id, leave_type_id, start_date, end_date, total_days, reason, status, approved_by) VALUES
-- Nghỉ phép năm (leave_type_id = 1)
(7,  1, '2026-06-05', '2026-06-06', 2.0, 'Về quê thăm gia đình',                    'Approved', 6),
(21, 1, '2026-06-10', '2026-06-12', 3.0, 'Nghỉ phép năm theo kế hoạch',             'Approved', 19),
(16, 1, '2026-06-15', '2026-06-15', 1.0, 'Giải quyết việc cá nhân',                 'Pending',  NULL),

-- Nghỉ ốm hưởng BHXH (leave_type_id = 2)
(12, 2, '2026-06-03', '2026-06-04', 2.0, 'Sốt cao, có giấy nghỉ của bác sĩ',        'Approved', 3),
(25, 2, '2026-06-05', '2026-06-05', 1.0, 'Khám sức khỏe định kỳ',                   'Approved', 19),

-- Nghỉ việc riêng có lương (leave_type_id = 4)
(9,  4, '2026-06-08', '2026-06-08', 1.0, 'Đám cưới anh trai',                       'Approved', 6),
(17, 4, '2026-06-09', '2026-06-10', 2.0, 'Người thân mất, lo tang lễ',              'Approved', 14),

-- Nghỉ không lương (leave_type_id = 5)
(22, 5, '2026-06-16', '2026-06-19', 4.0, 'Du lịch nước ngoài, xin nghỉ không lương','Pending',  NULL),
(27, 5, '2026-06-20', '2026-06-20', 1.0, 'Giải quyết thủ tục hành chính cá nhân',   'Rejected', 19),

-- Nghỉ thai sản (leave_type_id = 3)
(31, 3, '2026-06-01', '2026-11-30', 130.0,'Nghỉ thai sản theo chế độ BHXH 6 tháng', 'Approved', 4);

INSERT INTO shift_assignments (user_id, shift_id, assigned_date) VALUES

-- Ca Hành Chính (shift_id = 1): Khối văn phòng ngày 04/06/2026
(6,  1, '2026-06-04'),
(7,  1, '2026-06-04'),
(10, 1, '2026-06-04'),
(14, 1, '2026-06-04'),
(19, 1, '2026-06-04'),

-- Ca Hành Chính (shift_id = 1): Tổ trưởng xưởng ngày 04/06/2026
(29, 1, '2026-06-04'),
(30, 1, '2026-06-04'),
(31, 1, '2026-06-04'),
(32, 1, '2026-06-04'),

-- Ca Hành Chính (shift_id = 1): Quản đốc ngày 04/06/2026
(4,  1, '2026-06-04');

INSERT INTO work_history (user_id, position_title, company_name, location, start_date, end_date, description, is_current) VALUES

-- Giám đốc (user 2) - Vị trí hiện tại
(2, 'Giám đốc điều hành',
    'Công ty TNHH Group4',
    'Hà Nội',
    '2020-01-01', NULL,
    'Điều hành toàn bộ hoạt động sản xuất kinh doanh của công ty',
    1),

-- Trưởng phòng Nhân sự (user 3) - Vị trí hiện tại
(3, 'Trưởng phòng Nhân sự',
    'Công ty TNHH Group4',
    'Hà Nội',
    '2021-03-10', NULL,
    'Phụ trách tuyển dụng, đào tạo và quản lý chính sách C&B toàn công ty',
    1),

-- Trưởng phòng Nhân sự (user 3) - Vị trí cũ
(3, 'Chuyên viên Nhân sự',
    'Công ty CP Nhân Lực Việt',
    'Hà Nội',
    '2016-06-01', '2021-02-28',
    'Thực hiện tuyển dụng và quản lý hồ sơ nhân viên',
    0),

-- Quản đốc (user 4) - Vị trí hiện tại
(4, 'Quản đốc xưởng sản xuất',
    'Công ty TNHH Group4',
    'Bắc Ninh',
    '2020-06-01', NULL,
    'Quản lý toàn bộ dây chuyền sản xuất, giám sát an toàn lao động',
    1),

-- Kế toán trưởng (user 14) - Vị trí hiện tại
(14, 'Kế toán trưởng',
     'Công ty TNHH Group4',
     'Hà Nội',
     '2015-02-01', NULL,
     'Phụ trách tài chính, công nợ, thuế và báo cáo tài chính định kỳ',
     1),

-- Kế toán trưởng (user 14) - Vị trí cũ
(14, 'Kế toán tổng hợp',
     'Công ty TNHH Tài Chính Minh Phát',
     'Hà Nội',
     '2009-08-01', '2015-01-31',
     'Lập báo cáo tài chính, quyết toán thuế hàng năm',
     0),

-- Trưởng phòng Kinh doanh (user 19) - Vị trí hiện tại
(19, 'Trưởng phòng Kinh doanh',
     'Công ty TNHH Group4',
     'Hà Nội',
     '2016-01-01', NULL,
     'Phụ trách phát triển thị trường, quản lý đội ngũ sales 10 người',
     1),

-- Trưởng phòng Kinh doanh (user 19) - Vị trí cũ
(19, 'Nhân viên Kinh doanh',
     'Công ty CP Thương Mại Sao Việt',
     'TP. Hồ Chí Minh',
     '2010-03-01', '2015-12-31',
     'Phát triển khách hàng mới, chăm sóc khách hàng khu vực miền Nam',
     0),

-- Tổ trưởng xưởng (user 29) - Vị trí hiện tại
(29, 'Tổ trưởng sản xuất',
     'Công ty TNHH Group4',
     'Bắc Ninh',
     '2015-06-01', NULL,
     'Quản lý tổ sản xuất 15 công nhân, giám sát chất lượng sản phẩm',
     1),

-- Trưởng phòng Hành chính (user 6) - Vị trí hiện tại
(6,  'Trưởng phòng Hành chính',
     'Công ty TNHH Group4',
     'Hà Nội',
     '2018-03-01', NULL,
     'Quản lý văn phòng phẩm, thiết bị, lễ tân và công tác hành chính nội bộ',
     1);
     
INSERT INTO employee_allowances (user_id, allowance_id, amount) VALUES

-- Phụ cấp Ăn trưa (allowance_id = 1): 800,000đ - Áp dụng tất cả nhân viên chính thức
(6,  1, 800000),
(14, 1, 800000),
(19, 1, 800000),

-- Phụ cấp Đi lại (allowance_id = 2): 500,000đ - Nhân viên không ở ký túc xá
(6,  2, 500000),
(19, 2, 500000),

-- Phụ cấp Trách nhiệm (allowance_id = 3): 1,000,000đ - Quản đốc, Tổ trưởng
(4,  3, 1000000),
(29, 3, 1000000),

-- Phụ cấp Độc hại (allowance_id = 4): 300,000đ - Công nhân làm việc trực tiếp tại xưởng
(29, 4, 300000),
(30, 4, 300000),

-- Phụ cấp Chuyên cần (allowance_id = 5): 500,000đ - Không nghỉ, không đi muộn
(9,  5, 500000);

/* ================================================================
   MIGRATION V2: Shift & Overtime Management Module
   
   New Tables:
     - department_shifts   (default shift → department mapping)
     - overtime_plans      (supervisor OT plans)
     - overtime_assignments (employee OT assignments)
   
   Prerequisites: HRM_database.sql must be run first.
   ================================================================ */

USE HRM_System;
SET FOREIGN_KEY_CHECKS = 0;

-- ══════════════════════════════════════════════════════
-- TABLE 1: department_shifts
-- Maps a default/standard shift to a department.
-- HR Manager assigns these via the admin panel.
-- ══════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS department_shifts (
    id            INT PRIMARY KEY AUTO_INCREMENT,
    department_id INT NOT NULL,
    shift_id      INT NOT NULL,
    created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_dept_shift (department_id, shift_id),
    CONSTRAINT fk_ds_dept  FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE CASCADE,
    CONSTRAINT fk_ds_shift FOREIGN KEY (shift_id)      REFERENCES shifts(shift_id)           ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ══════════════════════════════════════════════════════
-- TABLE 2: overtime_plans
-- Created by Supervisor (role 3) for their department.
-- Represents a general OT plan for a specific date.
-- ══════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS overtime_plans (
    plan_id       INT          PRIMARY KEY AUTO_INCREMENT,
    dept_id       INT          NOT NULL,
    supervisor_id INT          NOT NULL,
    target_date   DATE         NOT NULL,
    description   VARCHAR(500),
    status        VARCHAR(20)  NOT NULL DEFAULT 'Active',
    created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_otp_dept FOREIGN KEY (dept_id)       REFERENCES departments(department_id) ON DELETE CASCADE,
    CONSTRAINT fk_otp_user FOREIGN KEY (supervisor_id) REFERENCES users(user_id)             ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ══════════════════════════════════════════════════════
-- TABLE 3: overtime_assignments
-- Individual employee assignments within an OT plan.
-- Status: Pending → Approved / Cancelled
-- ══════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS overtime_assignments (
    assignment_id  INT           PRIMARY KEY AUTO_INCREMENT,
    plan_id        INT           NOT NULL,
    user_id        INT           NOT NULL,
    assigned_hours DECIMAL(5,2)  NOT NULL,
    status         VARCHAR(20)   NOT NULL DEFAULT 'Pending',
    created_at     TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_plan_user (plan_id, user_id),
    CONSTRAINT fk_ota_plan FOREIGN KEY (plan_id) REFERENCES overtime_plans(plan_id) ON DELETE CASCADE,
    CONSTRAINT fk_ota_user FOREIGN KEY (user_id) REFERENCES users(user_id)          ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS = 1;

-- ══════════════════════════════════════════════════════
-- SEED DATA
-- ══════════════════════════════════════════════════════

-- Default shift assignments for departments
INSERT INTO department_shifts (department_id, shift_id) VALUES
(1, 1),  -- Hành chính → Ca Hành Chính
(2, 1),  -- Nhân sự → Ca Hành Chính
(3, 1),  -- Kế toán → Ca Hành Chính
(4, 1),  -- Kinh doanh → Ca Hành Chính
(5, 1);  -- Xưởng sản xuất → Ca Hành Chính (default)

-- Sample overtime plan (created by Quản đốc - user 4)
INSERT INTO overtime_plans (plan_id, dept_id, supervisor_id, target_date, description, status) VALUES
(1, 5, 4, '2026-06-10', 'Tăng ca hoàn thành đơn hàng xuất khẩu gấp', 'Active'),
(2, 5, 4, '2026-06-12', 'Tăng ca bảo trì máy móc cuối tuần', 'Active');

-- Sample overtime assignments
INSERT INTO overtime_assignments (assignment_id, plan_id, user_id, assigned_hours, status) VALUES
(1, 1, 5,  3.0, 'Pending'),   -- Phạm Công Nhân: 3h OT
(2, 1, 29, 2.0, 'Approved'),  -- Tổ trưởng 1: 2h OT (approved)
(3, 1, 30, 2.5, 'Pending'),   -- Tổ trưởng 2: 2.5h OT
(4, 2, 31, 2.0, 'Cancelled'), -- Tổ trưởng 3: cancelled
(5, 2, 32, 3.0, 'Pending');   -- Tổ phó: 3h OT

-- TABLE 4: payroll_claims
DROP TABLE IF EXISTS payroll_claims;
CREATE TABLE IF NOT EXISTS payroll_claims (
    claim_id INT PRIMARY KEY AUTO_INCREMENT,
    payroll_id INT NOT NULL,
    complaint_type VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    expected_amount DECIMAL(15,2) DEFAULT 0,
    evidence VARCHAR(255) DEFAULT NULL,
    status VARCHAR(50) DEFAULT 'Pending',
    hr_staff_id INT DEFAULT NULL,
    hr_staff_note TEXT DEFAULT NULL,
    accountant_id INT DEFAULT NULL,
    accountant_note TEXT DEFAULT NULL,
    proposed_adjustment DECIMAL(15,2) DEFAULT 0,
    hr_manager_id INT DEFAULT NULL,
    hr_manager_note TEXT DEFAULT NULL,
    director_id INT DEFAULT NULL,
    director_note TEXT DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (payroll_id) REFERENCES payroll(payroll_id) ON DELETE CASCADE,
    FOREIGN KEY (hr_staff_id) REFERENCES users(user_id) ON DELETE SET NULL,
    FOREIGN KEY (accountant_id) REFERENCES users(user_id) ON DELETE SET NULL,
    FOREIGN KEY (hr_manager_id) REFERENCES users(user_id) ON DELETE SET NULL,
    FOREIGN KEY (director_id) REFERENCES users(user_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/* ================================================================
   MIGRATION: Progressive PIT (Personal Income Tax) Module
   
   Mô tả: Tạo các bảng phục vụ tính thuế TNCN lũy tiến theo
   Quest.md cho HRM Payroll system.
   
   Bảng mới:
     - tax_brackets         (Bậc thuế lũy tiến, versioned)
     - tax_deductions       (Giảm trừ bản thân, người phụ thuộc)
     - employee_tax_profiles(Đăng ký thuế của nhân viên)
     - payroll_periods      (Kỳ lương)
     - payroll_runs         (Mỗi lần chạy tính lương)
     - payroll_run_items    (Kết quả từng nhân viên trong kỳ)
     - audit_logs           (Nhật ký thay đổi)
     - payslips             (Phiếu lương cuối cùng)
   
   Bảng hiện có KHÔNG tạo lại:
     - employees (= users), employee_contracts (= employee_profiles),
       salary_components (= employee_allowances + employee_rewards_disciplines),
       payroll, dependents, insurance_rates
   ================================================================ */

SET FOREIGN_KEY_CHECKS = 0;

-- ══════════════════════════════════════════════════════
-- TABLE 1: tax_brackets (Biểu thuế lũy tiến 7 bậc)
-- ══════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS tax_brackets (
    bracket_id      INT             PRIMARY KEY AUTO_INCREMENT,
    bracket_no      INT             NOT NULL COMMENT 'Bậc thuế (1-7)',
    income_from     DECIMAL(15,2)   NOT NULL COMMENT 'Thu nhập tính thuế từ',
    income_to       DECIMAL(15,2)   NULL     COMMENT 'Thu nhập tính thuế đến (NULL = vô cùng)',
    rate            DECIMAL(5,2)    NOT NULL COMMENT 'Thuế suất (%)',
    effective_from  DATE            NOT NULL COMMENT 'Ngày bắt đầu hiệu lực',
    effective_to    DATE            NULL     COMMENT 'Ngày hết hiệu lực (NULL = đang hiệu lực)',
    rounding_rule   VARCHAR(20)     NOT NULL DEFAULT 'HALF_UP' COMMENT 'Quy tắc làm tròn',
    status          TINYINT(1)      NOT NULL DEFAULT 1 COMMENT '1=Active, 0=Inactive',
    created_by      INT             NULL,
    updated_by      INT             NULL,
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_bracket_version (bracket_no, effective_from),
    CONSTRAINT fk_tb_created_by FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE SET NULL,
    CONSTRAINT fk_tb_updated_by FOREIGN KEY (updated_by) REFERENCES users(user_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ══════════════════════════════════════════════════════
-- TABLE 2: tax_deductions (Giảm trừ thuế)
-- ══════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS tax_deductions (
    deduction_id    INT             PRIMARY KEY AUTO_INCREMENT,
    deduction_type  VARCHAR(50)     NOT NULL COMMENT 'PERSONAL, DEPENDENT, OTHER',
    deduction_name  VARCHAR(100)    NOT NULL,
    amount          DECIMAL(15,2)   NOT NULL,
    effective_from  DATE            NOT NULL,
    effective_to    DATE            NULL,
    status          TINYINT(1)      NOT NULL DEFAULT 1,
    created_by      INT             NULL,
    updated_by      INT             NULL,
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_deduction_version (deduction_type, effective_from),
    CONSTRAINT fk_td_created_by FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE SET NULL,
    CONSTRAINT fk_td_updated_by FOREIGN KEY (updated_by) REFERENCES users(user_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ══════════════════════════════════════════════════════
-- TABLE 3: employee_tax_profiles (Hồ sơ thuế nhân viên)
-- ══════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS employee_tax_profiles (
    tax_profile_id      INT             PRIMARY KEY AUTO_INCREMENT,
    user_id             INT             NOT NULL,
    tax_code            VARCHAR(50)     NULL COMMENT 'Mã số thuế cá nhân',
    tax_registration    TINYINT(1)      NOT NULL DEFAULT 1 COMMENT '1=Đã đăng ký, 0=Chưa',
    dependent_count     INT             NOT NULL DEFAULT 0 COMMENT 'Số người phụ thuộc đã đăng ký',
    personal_deduction  DECIMAL(15,2)   NOT NULL DEFAULT 11000000 COMMENT 'Giảm trừ bản thân',
    dependent_deduction DECIMAL(15,2)   NOT NULL DEFAULT 4400000  COMMENT 'Giảm trừ mỗi NPT',
    status              TINYINT(1)      NOT NULL DEFAULT 1,
    notes               VARCHAR(500)    NULL,
    created_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_tax_profile_user (user_id),
    CONSTRAINT fk_etp_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ══════════════════════════════════════════════════════
-- TABLE 4: payroll_periods (Kỳ lương)
-- ══════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS payroll_periods (
    period_id       INT             PRIMARY KEY AUTO_INCREMENT,
    period_name     VARCHAR(100)    NOT NULL COMMENT 'VD: Tháng 06/2026',
    month           INT             NOT NULL,
    year            INT             NOT NULL,
    start_date      DATE            NOT NULL,
    end_date        DATE            NOT NULL,
    status          VARCHAR(20)     NOT NULL DEFAULT 'OPEN' COMMENT 'OPEN, LOCKED, CLOSED',
    locked_by       INT             NULL,
    locked_at       TIMESTAMP       NULL,
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_period_month_year (month, year),
    CONSTRAINT fk_pp_locked_by FOREIGN KEY (locked_by) REFERENCES users(user_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ══════════════════════════════════════════════════════
-- TABLE 5: payroll_runs (Mỗi lần chạy tính lương)
-- ══════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS payroll_runs (
    run_id          INT             PRIMARY KEY AUTO_INCREMENT,
    period_id       INT             NOT NULL,
    run_type        VARCHAR(20)     NOT NULL DEFAULT 'CALCULATE' COMMENT 'CALCULATE, RECALCULATE',
    run_by          INT             NOT NULL COMMENT 'User thực hiện',
    status          VARCHAR(20)     NOT NULL DEFAULT 'RUNNING' COMMENT 'RUNNING, COMPLETED, FAILED',
    total_employees INT             NOT NULL DEFAULT 0,
    total_gross     DECIMAL(15,2)   DEFAULT 0,
    total_pit       DECIMAL(15,2)   DEFAULT 0,
    total_net       DECIMAL(15,2)   DEFAULT 0,
    error_count     INT             DEFAULT 0,
    started_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at    TIMESTAMP       NULL,
    notes           VARCHAR(500)    NULL,
    CONSTRAINT fk_pr_period FOREIGN KEY (period_id) REFERENCES payroll_periods(period_id) ON DELETE CASCADE,
    CONSTRAINT fk_pr_user   FOREIGN KEY (run_by)    REFERENCES users(user_id)             ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ══════════════════════════════════════════════════════
-- TABLE 6: payroll_run_items (Kết quả từng NV trong kỳ)
-- ══════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS payroll_run_items (
    item_id             INT             PRIMARY KEY AUTO_INCREMENT,
    run_id              INT             NOT NULL,
    user_id             INT             NOT NULL,
    base_salary         DECIMAL(15,2)   NOT NULL DEFAULT 0,
    overtime_amount     DECIMAL(15,2)   NOT NULL DEFAULT 0,
    allowance_amount    DECIMAL(15,2)   NOT NULL DEFAULT 0,
    bonus_amount        DECIMAL(15,2)   NOT NULL DEFAULT 0,
    gross_income        DECIMAL(15,2)   NOT NULL DEFAULT 0,
    insurance_amount    DECIMAL(15,2)   NOT NULL DEFAULT 0,
    personal_deduction  DECIMAL(15,2)   NOT NULL DEFAULT 0,
    dependent_deduction DECIMAL(15,2)   NOT NULL DEFAULT 0,
    other_deduction     DECIMAL(15,2)   NOT NULL DEFAULT 0,
    taxable_income      DECIMAL(15,2)   NOT NULL DEFAULT 0,
    pit_amount          DECIMAL(15,2)   NOT NULL DEFAULT 0,
    pit_breakdown       TEXT            NULL COMMENT 'JSON breakdown theo bậc thuế',
    net_salary          DECIMAL(15,2)   NOT NULL DEFAULT 0,
    has_warning         TINYINT(1)      NOT NULL DEFAULT 0,
    warning_message     VARCHAR(500)    NULL,
    UNIQUE KEY uk_run_user (run_id, user_id),
    CONSTRAINT fk_pri_run   FOREIGN KEY (run_id)  REFERENCES payroll_runs(run_id) ON DELETE CASCADE,
    CONSTRAINT fk_pri_user  FOREIGN KEY (user_id) REFERENCES users(user_id)       ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ══════════════════════════════════════════════════════
-- TABLE 7: audit_logs (Nhật ký thay đổi)
-- ══════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS audit_logs (
    log_id          INT             PRIMARY KEY AUTO_INCREMENT,
    entity_type     VARCHAR(50)     NOT NULL COMMENT 'payroll, tax_bracket, tax_deduction, etc.',
    entity_id       INT             NOT NULL,
    action          VARCHAR(50)     NOT NULL COMMENT 'CREATE, UPDATE, DELETE, CALCULATE, APPROVE, REJECT',
    old_value       TEXT            NULL COMMENT 'JSON old values',
    new_value       TEXT            NULL COMMENT 'JSON new values',
    changed_by      INT             NOT NULL,
    changed_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ip_address      VARCHAR(50)     NULL,
    description     VARCHAR(500)    NULL,
    CONSTRAINT fk_al_user FOREIGN KEY (changed_by) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_audit_entity (entity_type, entity_id),
    INDEX idx_audit_date (changed_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ══════════════════════════════════════════════════════
-- TABLE 8: payslips (Phiếu lương)
-- ══════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS payslips (
    payslip_id      INT             PRIMARY KEY AUTO_INCREMENT,
    payroll_id      INT             NOT NULL,
    user_id         INT             NOT NULL,
    period_id       INT             NULL,
    payslip_code    VARCHAR(50)     NOT NULL COMMENT 'Mã phiếu lương VD: PS-2026-06-001',
    gross_income    DECIMAL(15,2)   NOT NULL DEFAULT 0,
    total_deduction DECIMAL(15,2)   NOT NULL DEFAULT 0,
    insurance_amount DECIMAL(15,2)  NOT NULL DEFAULT 0,
    pit_amount      DECIMAL(15,2)   NOT NULL DEFAULT 0,
    net_salary      DECIMAL(15,2)   NOT NULL DEFAULT 0,
    pit_breakdown   TEXT            NULL COMMENT 'JSON PIT breakdown theo bậc',
    status          VARCHAR(20)     NOT NULL DEFAULT 'GENERATED' COMMENT 'GENERATED, FINALIZED',
    generated_at    TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    finalized_by    INT             NULL,
    finalized_at    TIMESTAMP       NULL,
    UNIQUE KEY uk_payslip_code (payslip_code),
    CONSTRAINT fk_ps_payroll  FOREIGN KEY (payroll_id)   REFERENCES payroll(payroll_id)          ON DELETE CASCADE,
    CONSTRAINT fk_ps_user     FOREIGN KEY (user_id)      REFERENCES users(user_id)               ON DELETE CASCADE,
    CONSTRAINT fk_ps_period   FOREIGN KEY (period_id)    REFERENCES payroll_periods(period_id)   ON DELETE SET NULL,
    CONSTRAINT fk_ps_finalize FOREIGN KEY (finalized_by) REFERENCES users(user_id)               ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS = 1;

-- ══════════════════════════════════════════════════════
-- SEED DATA: Biểu thuế TNCN lũy tiến 7 bậc (Việt Nam)
-- ══════════════════════════════════════════════════════

INSERT INTO tax_brackets (bracket_no, income_from, income_to, rate, effective_from, rounding_rule, status, created_by) VALUES
(1,         0,  5000000,  5.00, '2020-01-01', 'HALF_UP', 1, 1),
(2,   5000000, 10000000, 10.00, '2020-01-01', 'HALF_UP', 1, 1),
(3,  10000000, 18000000, 15.00, '2020-01-01', 'HALF_UP', 1, 1),
(4,  18000000, 32000000, 20.00, '2020-01-01', 'HALF_UP', 1, 1),
(5,  32000000, 52000000, 25.00, '2020-01-01', 'HALF_UP', 1, 1),
(6,  52000000, 80000000, 30.00, '2020-01-01', 'HALF_UP', 1, 1),
(7,  80000000,     NULL, 35.00, '2020-01-01', 'HALF_UP', 1, 1);

-- ══════════════════════════════════════════════════════
-- SEED DATA: Giảm trừ thuế (theo Luật thuế TNCN VN)
-- ══════════════════════════════════════════════════════

INSERT INTO tax_deductions (deduction_type, deduction_name, amount, effective_from, status, created_by) VALUES
('PERSONAL',  'Giảm trừ bản thân',        11000000, '2020-07-01', 1, 1),
('DEPENDENT', 'Giảm trừ người phụ thuộc',   4400000, '2020-07-01', 1, 1);

-- ══════════════════════════════════════════════════════
-- SEED DATA: employee_tax_profiles (auto-sync từ dependents)
-- ══════════════════════════════════════════════════════

INSERT INTO employee_tax_profiles (user_id, tax_code, tax_registration, dependent_count, personal_deduction, dependent_deduction)
SELECT 
    ep.user_id,
    ep.tax_code,
    1,
    COALESCE((SELECT COUNT(*) FROM dependents d WHERE d.user_id = ep.user_id AND d.status = 1), 0),
    11000000,
    4400000
FROM employee_profiles ep
WHERE ep.user_id IN (SELECT user_id FROM users WHERE status = 1)
ON DUPLICATE KEY UPDATE 
    dependent_count = COALESCE((SELECT COUNT(*) FROM dependents d WHERE d.user_id = ep.user_id AND d.status = 1), 0);

-- ══════════════════════════════════════════════════════
-- SEED DATA: Kỳ lương mẫu
-- ══════════════════════════════════════════════════════



-- ══════════════════════════════════════════════════════
-- PERMISSIONS: Thêm quyền cho module PIT
-- ══════════════════════════════════════════════════════

INSERT INTO permissions (permission_id, permission_name, description, module) VALUES
(30, 'PIT_VIEW',       'Xem biểu thuế và thông tin PIT',       'PIT'),
(31, 'PIT_MANAGE',     'Quản lý cấu hình biểu thuế',          'PIT'),
(32, 'PIT_CALCULATE',  'Chạy tính thuế TNCN',                  'PIT'),
(33, 'AUDIT_VIEW',     'Xem nhật ký thay đổi',                 'AUDIT')
ON DUPLICATE KEY UPDATE permission_name = VALUES(permission_name);

-- Admin: toàn quyền PIT
INSERT IGNORE INTO role_permissions (role_id, permission_id) VALUES
(1, 30), (1, 31), (1, 32), (1, 33);

-- HR Manager: xem + tính PIT
INSERT IGNORE INTO role_permissions (role_id, permission_id) VALUES
(2, 30), (2, 32), (2, 33);

-- HR Staff: xem + tính PIT
INSERT IGNORE INTO role_permissions (role_id, permission_id) VALUES
(5, 30), (5, 32);

-- Director: xem
INSERT IGNORE INTO role_permissions (role_id, permission_id) VALUES
(4, 30), (4, 33);

-- Accountant: xem
INSERT IGNORE INTO role_permissions (role_id, permission_id) VALUES
(8, 30);

