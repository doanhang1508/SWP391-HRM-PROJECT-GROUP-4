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
    min_salary      DECIMAL(15,2) NOT NULL,
    max_salary      DECIMAL(15,2) NOT NULL,
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
    allowance_id      INT           PRIMARY KEY AUTO_INCREMENT,
    allowance_name    VARCHAR(100)  NOT NULL UNIQUE,
    description       VARCHAR(255),
    amount            DECIMAL(15,2) NOT NULL DEFAULT 0,
    apply_condition   VARCHAR(255),
    -- === THÊM MỚI: Thuộc tính tính toán (Source of Truth cho module Lương) ===
    calculation_type  ENUM('FIXED', 'PER_DAY', 'CONDITIONAL')
                      NOT NULL DEFAULT 'FIXED'
                      COMMENT 'FIXED=Cố định mỗi tháng, PER_DAY=Nhân x ngày công thực tế, CONDITIONAL=Theo điều kiện (thưởng chuyên cần...)',
    is_bhxh_applied   TINYINT(1)    NOT NULL DEFAULT 0
                      COMMENT '1=Khoản này cộng vào nền tính BHXH/BHYT/BHTN, 0=Không',
    is_taxable        TINYINT(1)    NOT NULL DEFAULT 0
                      COMMENT '1=Chịu thuế TNCN, 0=Miễn thuế (VD: ăn ca ≤730k/tháng)',
    -- =========================================================================
    status            TINYINT(1)    NOT NULL DEFAULT 1
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
    id               INT          PRIMARY KEY AUTO_INCREMENT,
    name             VARCHAR(100) NOT NULL,
    type             VARCHAR(20)  NOT NULL,
    description      VARCHAR(255),
    apply_level      VARCHAR(50)  DEFAULT 'Cá nhân',
    status           TINYINT(1)   NOT NULL DEFAULT 1,
    is_bhxh_applied  TINYINT(1)   NOT NULL DEFAULT 0
                     COMMENT '1=Khoản này cộng vào nền tính BHXH/BHYT/BHTN, 0=Không',
    is_taxable       TINYINT(1)   NOT NULL DEFAULT 1
                     COMMENT '1=Chịu thuế TNCN, 0=Miễn thuế (VD: thưởng KPI/năng suất)',
    created_at       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by       INT          NULL
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
    dependent_count      INT          NOT NULL DEFAULT 0
                         COMMENT 'Số lượng người phụ thuộc (dùng để tính giảm trừ gia cảnh thuế TNCN)',
    CONSTRAINT fk_profile_user FOREIGN KEY (user_id)              REFERENCES users(user_id)                         ON DELETE CASCADE,
    CONSTRAINT fk_profile_dept FOREIGN KEY (department_id)        REFERENCES departments(department_id)             ON DELETE SET NULL,
    CONSTRAINT fk_profile_ct   FOREIGN KEY (contract_type_id)     REFERENCES contract_types(contract_type_id)       ON DELETE SET NULL,
    CONSTRAINT fk_profile_sg   FOREIGN KEY (salary_grade_id)      REFERENCES salary_grades(salary_grade_id)         ON DELETE SET NULL,
    CONSTRAINT fk_profile_es   FOREIGN KEY (employment_status_id) REFERENCES employment_statuses(status_id)         ON DELETE SET NULL,
    CONSTRAINT fk_profile_ed   FOREIGN KEY (education_level_id)   REFERENCES education_levels(education_level_id)   ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE employee_contracts (
    contract_id      INT           PRIMARY KEY AUTO_INCREMENT,
    user_id          INT           NOT NULL,
    contract_type_id INT           NOT NULL,
    position_id      INT           NOT NULL,
    department_id    INT           NULL,
    salary_grade_id  INT           NOT NULL,
    start_date            DATE          NOT NULL,
    end_date              DATE          NULL,
    effective_date        DATE          NULL
                         COMMENT 'Ngày hiệu lực thực tế của Phụ lục (có thể khác ngày ký và start_date)',
    actual_end_date       DATE          NULL
                         COMMENT 'Ngày thực tế chấm dứt hợp đồng (do nghỉ việc / sa thải) — khác với end_date theo lịch',
    termination_reason    VARCHAR(255)  NULL
                         COMMENT 'Lý do chấm dứt hợp đồng sớm (nghỉ việc tự nguyện, sa thải, hết hạn...)',
    base_salary           DECIMAL(15,2) NOT NULL,
    tax_calc_type    INT           NOT NULL DEFAULT 1
                     COMMENT '1=Lũy tiến, 2=Khấu trừ 10%, 3=Không thuế',
    file_path        VARCHAR(255),
    doc_type         ENUM('CONTRACT', 'ADDENDUM') NOT NULL DEFAULT 'CONTRACT'
                     COMMENT 'CONTRACT=Hợp đồng chính thức, ADDENDUM=Phụ lục (tăng lương, điều chuyển...)',
    parent_contract_id INT NULL DEFAULT NULL
                     COMMENT 'Nếu là Phụ lục thì trỏ về contract_id của hợp đồng gốc',
    addendum_reason  VARCHAR(255) NULL
                     COMMENT 'Lý do tạo phụ lục: Tăng lương, Điều chuyển phòng ban, Thăng tiến...',
    status           ENUM('Active','Pending','Expired','Terminated','Rejected') NOT NULL DEFAULT 'Pending'
                     COMMENT 'Trạng thái hợp đồng',
    sign_status      ENUM('N/A','PENDING','SIGNED','REJECTED') NOT NULL DEFAULT 'N/A'
                     COMMENT 'N/A=Hợp đồng gốc (không cần ký online), PENDING=Chờ nhân viên xác nhận, SIGNED=Đã xác nhận, REJECTED=Từ chối',
    signed_at        TIMESTAMP NULL DEFAULT NULL
                     COMMENT 'Thời điểm nhân viên bấm Xác nhận hoặc Từ chối',
    signed_by        INT NULL DEFAULT NULL
                     COMMENT 'user_id của người đại diện công ty ký/duyệt HĐ (HR Manager, Giám đốc)',
    reject_reason    VARCHAR(255) NULL
                     COMMENT 'Lý do nhân viên từ chối ký phụ lục',
    created_at       TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_contract_user FOREIGN KEY (user_id)          REFERENCES users(user_id)                         ON DELETE CASCADE,
    CONSTRAINT fk_contract_type FOREIGN KEY (contract_type_id) REFERENCES contract_types(contract_type_id)       ON DELETE RESTRICT,
    CONSTRAINT fk_contract_pos  FOREIGN KEY (position_id)      REFERENCES positions(position_id)                 ON DELETE RESTRICT,
    CONSTRAINT fk_contract_dept FOREIGN KEY (department_id)    REFERENCES departments(department_id)             ON DELETE SET NULL,
    CONSTRAINT fk_contract_sg   FOREIGN KEY (salary_grade_id)  REFERENCES salary_grades(salary_grade_id)         ON DELETE RESTRICT,
    CONSTRAINT fk_ec_parent     FOREIGN KEY (parent_contract_id) REFERENCES employee_contracts(contract_id)       ON DELETE SET NULL,
    CONSTRAINT fk_contract_signed_by FOREIGN KEY (signed_by)   REFERENCES users(user_id)                         ON DELETE SET NULL,
    INDEX idx_ec_user_status    (user_id, status),
    INDEX idx_ec_parent         (parent_contract_id),
    INDEX idx_ec_effective_date (effective_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bảng dependents đã được đơn giản hoá: chỉ lưu số lượng người phụ thuộc
-- trực tiếp trong cột dependent_count của bảng employee_profiles.

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
-- NHÓM 3b: LUỒNG NGHỈ VIỆC (RESIGNATION)
-- Tích hợp từ: resignation_migration.sql + resignation_v2_migration.sql
-- (Merge ngày 2026-07-06 — các file migration gốc đã được lưu trữ
--  tại database/archive/ để tham khảo lịch sử.)
-- =============================================================

-- BẢNG: resignation_requests (phiên bản v2 đầy đủ)
CREATE TABLE resignation_requests (
    resignation_id      INT           PRIMARY KEY AUTO_INCREMENT,
    user_id             INT           NOT NULL,
    reason              TEXT          NOT NULL,
    desired_last_date   DATE          NOT NULL,
    notice_period_days  INT           NULL
                        COMMENT 'Số ngày báo trước (tính từ ngày nộp đơn đến desired_last_date)',
    expected_leave_date DATE          NULL
                        COMMENT 'Ngày dự kiến rời công ty (do HR tính toán sau khi duyệt)',
    last_working_day    DATE          NULL
                        COMMENT 'Ngày làm việc cuối cùng thực tế (sau khi COMPLETED)',
    status              ENUM('PENDING','APPROVED','REJECTED','COMPLETED','CANCELLED','WITHDRAW_REQUESTED','WITHDRAWN')
                        NOT NULL DEFAULT 'PENDING',
    previous_employment_status_id INT NULL
                        COMMENT 'Lưu trạng thái làm việc trước khi chuyển sang NoticePeriod',
    submitted_at        TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    reviewed_by         INT           NULL,
    reviewed_at         TIMESTAMP     NULL,
    hr_note             TEXT          NULL,
    created_at          TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_resignation_user
        FOREIGN KEY (user_id)     REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_resignation_reviewer
        FOREIGN KEY (reviewed_by) REFERENCES users(user_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_resignation_user_id ON resignation_requests(user_id);
CREATE INDEX idx_resignation_status  ON resignation_requests(status);

-- BẢNG: resignation_checklist (Checklist bàn giao khi nghỉ việc)
CREATE TABLE resignation_checklist (
    checklist_id   INT           PRIMARY KEY AUTO_INCREMENT,
    resignation_id INT           NOT NULL,
    item_name      VARCHAR(100)  NOT NULL
                   COMMENT 'Laptop, ID Card, Uniform, Document, Knowledge Transfer, Company Assets',
    is_completed   TINYINT(1)    NOT NULL DEFAULT 0,
    completed_by   INT           NULL,
    completed_at   TIMESTAMP     NULL,
    note           VARCHAR(255)  NULL,
    CONSTRAINT fk_checklist_resignation
        FOREIGN KEY (resignation_id) REFERENCES resignation_requests(resignation_id) ON DELETE CASCADE,
    CONSTRAINT fk_checklist_user
        FOREIGN KEY (completed_by)   REFERENCES users(user_id)                       ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;




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
    payroll_id            INT PRIMARY KEY AUTO_INCREMENT,
    user_id               INT NOT NULL,
    month                 INT NOT NULL,
    year                  INT NOT NULL,
    base_salary           DECIMAL(15,2),
    working_days          DECIMAL(5,1),
    overtime_amount       DECIMAL(15,2),
    allowance_amount      DECIMAL(15,2),
    bonus_amount          DECIMAL(15,2),
    deduction_amount      DECIMAL(15,2),
    insurance_amount      DECIMAL(15,2),
    tax_amount            DECIMAL(15,2),
    gross_salary          DECIMAL(15,2),
    net_salary            DECIMAL(15,2),
    insurance_benefit     DECIMAL(15,2) DEFAULT 0.00,
    -- Audit columns: breakdown tính BHXH và thuế để hiển thị phiếu lương
    insurance_base_amount DECIMAL(15,2) DEFAULT 0
                          COMMENT 'Nền tính BHXH/BHYT/BHTN thực tế (lương cơ bản + phụ cấp/thưởng chịu BH)',
    taxable_income_base   DECIMAL(15,2) DEFAULT 0
                          COMMENT 'Thu nhập chịu thuế TNCN trước khi trừ giảm trừ gia cảnh',
    status                ENUM('Draft','Pending','Verified','Approved','Rejected','Paid') DEFAULT 'Draft',
    approved_by           INT NULL,
    approved_at           TIMESTAMP NULL,
    reject_reason         VARCHAR(500) NULL,
    paid_by               INT NULL,
    paid_at               TIMESTAMP NULL,
    payment_note          VARCHAR(500) NULL,
    created_at            TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (approved_by) REFERENCES users(user_id) ON DELETE SET NULL,
    FOREIGN KEY (paid_by) REFERENCES users(user_id) ON DELETE SET NULL,
    UNIQUE KEY uk_user_month_year (user_id, month, year)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- BẢNG: leave_insurance_rates (Tỷ lệ BHXH chi trả cho từng loại nghỉ phép)
-- Tách riêng để dễ cấu hình tỷ lệ bảo hiểm theo từng loại nghỉ phép.
CREATE TABLE leave_insurance_rates (
    leave_insurance_rate_id INT PRIMARY KEY AUTO_INCREMENT,
    leave_type_id           INT NOT NULL,
    insurance_rate_percent  DECIMAL(5,2) NOT NULL COMMENT 'Tỷ lệ % lương cơ bản được BHXH chi trả (VD: 75.00 = 75%)',
    description             NVARCHAR(500),
    effective_from          DATE DEFAULT (CURRENT_DATE),
    effective_to            DATE DEFAULT NULL,
    status                  TINYINT(1) NOT NULL DEFAULT 1 COMMENT '1=Active, 0=Inactive',
    created_at              DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at              DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (leave_type_id) REFERENCES leave_types(leave_type_id)
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

CREATE TABLE position_allowances (
    id              INT           PRIMARY KEY AUTO_INCREMENT,
    position_id     INT           NOT NULL,
    allowance_id    INT           NOT NULL,
    FOREIGN KEY (position_id)  REFERENCES positions(position_id) ON DELETE CASCADE,
    FOREIGN KEY (allowance_id) REFERENCES allowances(allowance_id) ON DELETE CASCADE,
    INDEX idx_pa_position (position_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE seniority_rules (
    rule_id         INT           PRIMARY KEY AUTO_INCREMENT,
    min_months      INT           NOT NULL,
    max_months      INT           NULL,
    amount          DECIMAL(15,2) NOT NULL
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

-- ── transfer_requests: Điều chuyển nội bộ (Internal Transfer) ──────────────
-- Tích hợp từ: transfer_request_migration.sql + transfer_salary_migration.sql
CREATE TABLE IF NOT EXISTS transfer_requests (
    transfer_request_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id         INT         NOT NULL,
    old_department_id   INT         NULL,
    old_position_id     INT         NULL,
    old_role_id         INT         NULL,
    new_department_id   INT         NOT NULL,
    new_position_id     INT         NOT NULL,
    new_role_id         INT         NOT NULL,
    -- Lớp 2: Thông tin lương mới (tuỳ chọn — NULL = giữ nguyên lương hiện tại)
    new_salary_grade_id INT         NULL
                        COMMENT 'Ngạch lương mới (NULL = giữ nguyên ngạch lương từ hợp đồng active)',
    new_base_salary     DECIMAL(15,2) NULL
                        COMMENT 'Lương cơ bản mới (NULL = giữ nguyên). Bắt buộc nếu new_salary_grade_id != NULL',
    reason              TEXT        NOT NULL,
    effective_date      DATE        NOT NULL,
    status              ENUM('PENDING','EMPLOYEE_CONFIRMED','MANAGER_APPROVED','APPROVED','COMPLETED','REJECTED','EMPLOYEE_REJECTED','CANCELLED') NOT NULL DEFAULT 'PENDING',
    requested_by        INT         NOT NULL,
    approved_by              INT         NULL,
    approved_at              TIMESTAMP   NULL,
    reject_reason            TEXT        NULL,
    created_at               TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,
    updated_at               TIMESTAMP   DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    applied_at               TIMESTAMP   NULL COMMENT 'Thời điểm hệ thống thực sự thực thi đổi phòng ban/chức vụ/vai trò (NULL = chưa áp dụng)',
    -- Tích hợp từ transfer_new_flow_migration.sql
    employee_confirmed_at    TIMESTAMP   NULL COMMENT 'Thời điểm nhân viên xác nhận đồng ý điều chuyển',
    employee_reject_reason   TEXT        NULL COMMENT 'Lý do nhân viên từ chối điều chuyển',
    manager_approved_by      INT         NULL COMMENT 'User ID của Trưởng phòng đã duyệt bước 1',
    manager_approved_at      TIMESTAMP   NULL COMMENT 'Thời điểm Trưởng phòng duyệt bước 1',

    CONSTRAINT fk_transfer_employee   FOREIGN KEY (employee_id)        REFERENCES users(user_id)            ON DELETE CASCADE,
    CONSTRAINT fk_transfer_old_dept   FOREIGN KEY (old_department_id)  REFERENCES departments(department_id) ON DELETE SET NULL,
    CONSTRAINT fk_transfer_old_pos    FOREIGN KEY (old_position_id)    REFERENCES positions(position_id)    ON DELETE SET NULL,
    CONSTRAINT fk_transfer_old_role   FOREIGN KEY (old_role_id)        REFERENCES roles(role_id)            ON DELETE SET NULL,
    CONSTRAINT fk_transfer_new_dept   FOREIGN KEY (new_department_id)  REFERENCES departments(department_id) ON DELETE CASCADE,
    CONSTRAINT fk_transfer_new_pos    FOREIGN KEY (new_position_id)    REFERENCES positions(position_id)    ON DELETE CASCADE,
    CONSTRAINT fk_transfer_new_role   FOREIGN KEY (new_role_id)        REFERENCES roles(role_id)            ON DELETE CASCADE,
    CONSTRAINT fk_transfer_requester  FOREIGN KEY (requested_by)       REFERENCES users(user_id)            ON DELETE CASCADE,
    CONSTRAINT fk_transfer_approver   FOREIGN KEY (approved_by)        REFERENCES users(user_id)            ON DELETE SET NULL,
    CONSTRAINT fk_transfer_mgr_approver FOREIGN KEY (manager_approved_by) REFERENCES users(user_id)         ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_transfer_employee ON transfer_requests(employee_id);
CREATE INDEX idx_transfer_status   ON transfer_requests(status);

-- ── transfer_request_allowances: Phụ cấp dự kiến đi kèm phiếu điều chuyển ──
-- Tích hợp từ transfer_new_flow_migration.sql
CREATE TABLE IF NOT EXISTS transfer_request_allowances (
  transfer_request_id INT NOT NULL,
  allowance_id        INT NOT NULL,
  PRIMARY KEY (transfer_request_id, allowance_id),
  CONSTRAINT fk_tra_transfer  FOREIGN KEY (transfer_request_id)
    REFERENCES transfer_requests(transfer_request_id) ON DELETE CASCADE,
  CONSTRAINT fk_tra_allowance FOREIGN KEY (allowance_id)
    REFERENCES allowances(allowance_id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Phụ cấp dự kiến đi kèm phiếu điều chuyển (chỉ áp dụng khi approve)';

-- 3. BẬT LẠI KIỂM TRA KHÓA NGOẠI
SET FOREIGN_KEY_CHECKS = 1;


-- =========================================================================
-- =========================== SEED DATA ===================================
-- =========================================================================

-- ── 1. Departments ──
INSERT INTO departments (department_id, department_name, description) VALUES
(2, 'Nhân sự',        'Tuyển dụng, đào tạo, C&B'),
(3, 'Tài chính',      'Tài chính, công nợ, thuế'),
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
INSERT INTO salary_grades (salary_grade_id, grade_name, min_salary, max_salary, description) VALUES
(1, 'Ngạch Quản lý',   20000000, 50000000, 'Giám đốc, Trưởng phòng'),
(2, 'Ngạch Chuyên viên',10000000, 25000000, 'Khối văn phòng'),
(3, 'Ngạch Kinh doanh', 8000000,  20000000, 'Nhân viên kinh doanh'),
(4, 'Ngạch Sản xuất',    5000000,  15000000, 'Công nhân sản xuất');

-- ── 5. Contract Types ──
INSERT INTO contract_types (contract_type_id, type_name, description, duration, duration_unit) VALUES
(1, 'Thử việc',           'Hợp đồng thử việc 2 tháng', 2, 'Tháng'),
(2, 'Có thời hạn 1 năm',  'Hợp đồng lao động 12 tháng', 1, 'Năm'),
(3, 'Có thời hạn 3 năm',  'Hợp đồng lao động 36 tháng', 3, 'Năm'),
(4, 'Vô thời hạn',        'Hợp đồng không xác định thời hạn', NULL, 'Vô thời hạn'),
(5, 'Thời vụ',            'Dành cho lao động ngắn hạn ở xưởng', 3, 'Tháng');

-- ── 6. Allowances ──
-- Columns: allowance_id, allowance_name, description, amount, apply_condition, calculation_type, is_bhxh_applied, is_taxable
INSERT INTO allowances (allowance_id, allowance_name, description, amount, apply_condition, calculation_type, is_bhxh_applied, is_taxable) VALUES
-- Ăn trưa: miễn thuế (≤730k/người/tháng theo TT78), không thuộc nền BHXH, tính theo ngày công thực tế
(1, 'Ăn trưa',     'Phụ cấp ăn ca',                    730000,  'Tất cả nhân viên chính thức',                   'PER_DAY',     0, 0),
-- Đi lại: miễn thuế (≤1tr/người/tháng theo TT78), không thuộc nền BHXH, cố định mỗi tháng
(2, 'Đi lại',      'Phụ cấp xăng xe',                  500000,  'Nhân viên không ở ký túc xá',                   'FIXED',       0, 0),
-- Trách nhiệm: thuộc nền BHXH + chịu thuế TNCN, cố định
(3, 'Trách nhiệm', 'Phụ cấp chức vụ cho quản lý',      1000000, 'Quản đốc, Tổ trưởng, Trưởng phòng',             'FIXED',       1, 1),
-- Thâm niên: thuộc nền BHXH + chịu thuế, cố định theo hệ số năm làm việc
(4, 'Thâm niên',   'Phụ cấp thâm niên theo năm làm việc', 300000, 'Áp dụng sau 3 năm công tác',                 'FIXED',       1, 1),
-- Điện thoại: miễn thuế, cố định
(5, 'Điện thoại',  'Phụ cấp cước viễn thông',          500000,  'Nhân viên kinh doanh, quản lý',                 'FIXED',       0, 0),
-- Trách nhiệm Giám Đốc
(6, 'Trách nhiệm GĐ', 'Phụ cấp chức vụ cho Giám đốc', 5000000, 'Giám đốc', 'FIXED', 1, 1),
-- Vùng miền: thuộc nền BHXH + chịu thuế
(7, 'Vùng miền', 'Phụ cấp vùng miền', 200000, 'Tùy theo vị trí địa lý của cơ sở làm việc', 'FIXED', 1, 1);

-- ── 7. Insurance Rates (BHXH / BHYT / BHTN) ──
INSERT INTO insurance_rates (insurance_rate_id, insurance_code, insurance_name, company_rate, employee_rate, description, effective_from) VALUES
(1, 'BHXH', 'Bảo hiểm Xã hội (BHXH)',       17.5, 8.0, 'Bảo hiểm xã hội theo quy định pháp luật', '2020-01-01'),
(2, 'BHYT', 'Bảo hiểm Y tế (BHYT)',          3.0,  1.5, 'Bảo hiểm y tế bắt buộc',                  '2020-01-01'),
(3, 'BHTN', 'Bảo hiểm Thất nghiệp (BHTN)',   1.0,  1.0, 'Bảo hiểm thất nghiệp theo quy định',       '2020-01-01');

-- ── 8. Employment Statuses ──
INSERT INTO employment_statuses (status_id, status_name, description, status) VALUES
(1, 'Đang thử việc',  'Đang trong thời gian đánh giá',                    1),
(2, 'Đang làm việc',  'Nhân viên chính thức',                              1),
(3, 'Tạm hoãn HĐLĐ', 'Nghỉ ốm dài ngày, Thai sản',                        1),
(4, 'Đã nghỉ việc',   'Chấm dứt Hợp đồng',                                1),
(5, 'NoticePeriod',   'Đang trong thời gian báo trước nghỉ việc',          1),
(6, 'ContractExpired','Hợp đồng đã hết hạn',                               1),
(7, 'Terminate',      'Bị cho thôi việc (sa thải)',                        1);

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
(2, 'Ca Đêm 1', '18:00:00','20:00:00', NULL,       NULL,        1, 1.50,'2,3,4,5,6,7'),
(3, 'Ca Đêm 2', '18:00:00','22:00:00', '20:00:00', '20:30:00', 1, 1.50,'2,3,4,5,6,7');

-- ── 11. Leave Types ──
INSERT INTO leave_types (leave_type_id, type_name, description, paid_leave, max_days_per_year) VALUES
(1, 'Nghỉ phép năm',           'Nghỉ phép theo quy định',                 1, 12),
(2, 'Nghỉ ốm (Hưởng BHXH)',    'Nghỉ ốm hưởng chế độ BHXH',               0, NULL),
(4, 'Nghỉ việc riêng có lương','Nghỉ việc riêng vẫn tính lương',          1, NULL),
(5, 'Nghỉ không lương',        'Nghỉ không hưởng lương',                  0, NULL);
-- Note: Thai sản nam (leave_type_id = 6) đã bị loại bỏ khỏi hệ thống (migration 2026-07-23).

-- ── 11b. Leave Insurance Rates (Tỷ lệ BHXH cho nghỉ phép) ──
-- Luật BHXH 2014/2024: Nghỉ ốm 75%, Thai sản nữ 100%
-- Business rule tạm thời của project:
--   Nghỉ ốm (type 2): sickBenefit = insuranceBase / 24 × 75% × số ngày nghỉ ốm
--   TODO: Thay thế bằng mức bình quân lương đóng BHXH 6 tháng trước khi nghỉ.
INSERT INTO leave_insurance_rates (leave_type_id, insurance_rate_percent, description, effective_from) VALUES
(2, 75.00,  'Nghỉ ốm: Hưởng 75% mức tiền lương đóng BHXH',   '2026-01-01');

-- ── 12. Reward Disciplines ──
-- is_bhxh_applied: 1=cộng vào nền BHXH, 0=không (thưởng KPI/năng suất luôn = 0)
-- is_taxable: 1=chịu thuế TNCN, 0=miễn thuế (thưởng KPI/năng suất = 0)
INSERT INTO reward_disciplines (id, name, type, description, apply_level, is_bhxh_applied, is_taxable, created_by) VALUES
(1, 'Thưởng KPI Tháng',      'Reward',    'Thưởng dựa trên đánh giá hiệu suất, miễn BHXH và thuế TNCN',  'Cá nhân',    0, 0, 1),
(2, 'Thưởng Dự án',          'Reward',    'Thưởng hoàn thành xuất sắc dự án',                             'Nhóm/Dự án', 0, 1, 1),
(3, 'Thưởng Chuyên cần',     'Reward',    'Không đi muộn, không nghỉ phép trong tháng',                   'Cá nhân',    0, 1, 1),
(4, 'Đi muộn/Về sớm',        'Discipline','Phạt đi muộn theo quy định',                                    'Cá nhân',    0, 1, 1),
(5, 'Vi phạm An toàn LĐ',    'Discipline','Phạt do không tuân thủ an toàn tại xưởng',                     'Cá nhân',    0, 1, 1),
(6, 'Warning',               'Discipline','Cảnh báo vi phạm kỷ luật',                                     'Cá nhân',    0, 1, 1),
(7, 'Vi phạm kỷ luật khác',  'Discipline','Các hình thức vi phạm nội quy khác',                           'Cá nhân',    0, 1, 1),
(8, 'Dismissal',             'Discipline','Sa thải / Chấm dứt hợp đồng lao động do vi phạm nghiêm trọng','Cá nhân',    0, 1, 1),
(9, 'Thưởng Năng suất',      'Reward',    'Thưởng theo năng suất lao động, miễn BHXH và thuế TNCN',       'Cá nhân',    0, 0, 1);

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
(1,'admin',     '$2a$12$rYoA1kECJ6UezPnfPqISP.Gg1Goc4FUiqLGQIFBOHqFbiBis2C4.i','Quản Trị Viên',          'admin@hrm.com',     '0900000001',1,NULL,NULL),
(2,'giam_doc',  '$2a$12$VmGdTMHeOmArIfaKnIm7KuR4IeZScPaJatyvb8aq6bQDqDUvU0FWe','Nguyễn Văn Giám Đốc',    'giamdoc@hrm.com',   '0901000002',4,NULL,1),
(3,'hr_manager','$2a$12$KlvlpagR4obNSuv2XfM32uWEVqKfNFT5t5JUzRMCrYGi.1QetPgEy','Trần Thị Nhân Sự',       'hr@hrm.com',        '0901000003',2,2,2),
(4,'quan_doc',  '$2a$12$Pz91uQpiTf8GgwrkbiA/ReDRjxRk48K4lu2Y5yxLGlxQQutJ2xUIm','Lê Văn Quản Đốc',        'quandoc@hrm.com',   '0901000004',3,5,4),
(5,'cong_nhan', '$2a$12$9rsQL.viVSSU3uxAqO4aI.LVVYSyc6i1BaZSvrF5SPnAKijaaMmFK','Phạm Công Nhân',          'cn1@hrm.com',       '0901000005',7,5,9);

-- ── 16b. Profiles users 2-5 ──
INSERT INTO employee_profiles (user_id,department_id,id_card,dob,gender,address,hire_date,tax_code,social_insurance_no,bank_account,bank_name,contract_type_id,salary_grade_id,employment_status_id,education_level_id) VALUES
(2,NULL,'001085000001','1985-01-01',1,'Hà Nội',     '2020-01-01','8012345678','0100001001','190300001','Vietcombank',4,1,2,1),
(3,2,'001090000002','1990-05-15',0,'Hà Nội',     '2021-03-10','8012345679','0100001002','190300002','BIDV',        4,2,2,2),
(4,5,'001088000003','1988-08-20',1,'Hải Phòng',  '2020-06-01','8012345680','0100001003','190300003','Techcombank',4,2,2,2),
(5,5,'001095000004','1995-12-10',1,'Bắc Ninh',   '2026-02-15','8012345681','0100001004','190300004','Agribank',   2,4,2,5);

-- ── 17. Nhân viên Quản lý (user_id 6-32, 27 người) ──

-- Phòng Nhân Sự (dept=2)
INSERT INTO users (user_id,username,password,full_name,email,phone,role_id,department_id,position_id) VALUES
(10,'hr_staff_01','$2a$12$TU4.I9PDJz5rYNR1fF7QNeAOwik010Ta6Pvihh7xhZHA3mmLxWF0C','Đặng Thị Hồng','hrs1@hrm.com','0901000010',5,2,8);

-- Phòng Kế Toán (dept=3)
INSERT INTO users (user_id,username,password,full_name,email,phone,role_id,department_id,position_id) VALUES
(14,'ke_toan_truong','$2a$12$CX4AKldReVh0P34bzQGNOeTYMKuSgZ/BScaFnB2mdUJ7mMaku/K3W','Phan Thị Khánh','ktt@hrm.com',    '0901000014',6,3,6);

-- Xưởng Sản Xuất (dept=5) + Ke Toan
INSERT INTO users (user_id,username,password,full_name,email,phone,role_id,department_id,position_id) VALUES
(33, 'ke_toan_01', '$2a$12$6P4evU5n2Vb5yujdiEVTo.X9yVsr4m0wVGnzr..W2DCY4j1WposdW', 'Nguyễn Thị Kế Toán', 'ketoan01@hrm.com', '0901000033', 8, 3, 7);

-- Bổ sung hai nhân viên được tham chiếu bằng mã NV0021 và NV0027 trong bảng công.
-- ImportAttendanceController diễn giải phần số trong mã NVxxxx là users.user_id.
INSERT INTO users (user_id, username, password, full_name, email, phone, role_id, status)
VALUES
    (21, 'NV0021', '$2a$12$9rsQL.viVSSU3uxAqO4aI.LVVYSyc6i1BaZSvrF5SPnAKijaaMmFK', 'Ngô Văn Ốm', 'nv0021@test.com', '0123456021', 7, 1);

-- ── Profiles quản lý ──
-- Format: (uid, dept_id, id_card, dob, gender, address, hire_date, tax_code, social_insurance_no, bank_account, bank_name, ct, sg, es, el)
INSERT INTO employee_profiles (user_id,department_id,id_card,dob,gender,address,hire_date,tax_code,social_insurance_no,bank_account,bank_name,contract_type_id,salary_grade_id,employment_status_id,education_level_id) VALUES
(10,2,'024940000010','1994-02-28',0,'Hà Nội',                 '2023-08-15','8012345710','0200001010','0011234510','VPBank',      3,2,2,2),
(14,3,'024820000014','1982-12-10',0,'Hai Bà Trưng, Hà Nội',  '2026-02-01','8012345714','0200001014','0011234514','Vietcombank', 2,1,2,1),
(33,3,'024910000033','1991-07-15',0,'Cầu Giấy, Hà Nội',       '2026-03-01','8012345733','0200001033','0011234533','Vietcombank', 2,2,2,2); -- employment_status_id=4: Đã nghỉ việc

-- ── 16d. Employee Contracts (Dữ liệu cụ thể cho từng nhân viên) ──
-- Cột: user_id, contract_type_id, position_id, department_id, salary_grade_id,
--       start_date,    end_date,       base_salary,  status
INSERT INTO employee_contracts (user_id, contract_type_id, position_id, department_id, salary_grade_id, start_date, end_date, base_salary, status) VALUES
-- user 2:  Giám đốc          | Vô thời hạn | Lương 30.000.000
(2,  4, 1, NULL, 1, '2020-01-01', NULL,         30000000, 'Active'),

-- ════ user 3: HR Manager — có 2 hợp đồng để test lịch sử ════
-- HĐ cũ: 3 năm, 2021-03-10 → 2024-03-10, lương 12tr (đã hết hạn)
(3,  3, 2, 2, 2, '2021-03-10', '2024-03-10', 12000000, 'Expired'),
-- HĐ mới: Vô thời hạn, gia hạn từ 2024-03-10, lương 15tr (đang hiệu lực)
(3,  4, 2, 2, 2, '2024-03-10', NULL,         15000000, 'Active'),

-- user 4:  Quản đốc          | Vô thời hạn | Lương 12.000.000
(4,  4, 4, 5, 2, '2020-06-01', NULL,         12000000, 'Active'),
-- user 5:  Công nhân         | 1 năm       | Lương 5.000.000
(5,  2, 9, 5, 4, '2026-02-15', '2027-02-15',  5000000, 'Active'),

-- user 10: HR Staff          | 3 năm       | Lương 10.000.000 (Sắp hết hạn 15/08/2026)
(10, 3, 8, 2, 2, '2023-08-15', '2026-08-15', 10000000, 'Active'),
-- user 14: Kế toán trưởng   | 1 năm       | Lương 20.000.000
(14, 2, 6, 3, 1, '2026-02-01', '2027-02-01', 20000000, 'Active'),
-- user 33: Kế toán viên     | 1 năm       | Lương 10.000.000
(33, 2, 7, 3, 2, '2026-03-01', '2027-03-01', 10000000, 'Active');



-- ── 16e. Số lượng người phụ thuộc (cập nhật vào employee_profiles) ──
UPDATE employee_profiles SET dependent_count = 2 WHERE user_id = 2;  -- 2 người phụ thuộc
UPDATE employee_profiles SET dependent_count = 1 WHERE user_id = 3;  -- 1 người phụ thuộc
UPDATE employee_profiles SET dependent_count = 1 WHERE user_id = 4;  -- 1 người phụ thuộc
UPDATE employee_profiles SET dependent_count = 1 WHERE user_id = 5;  -- 1 người phụ thuộc
UPDATE employee_profiles SET dependent_count = 1 WHERE user_id = 10; -- 1 người phụ thuộc
UPDATE employee_profiles SET dependent_count = 1 WHERE user_id = 14; -- 1 người phụ thuộc;

-- ================================================================
-- 18. MOCK DATA (Kỷ luật, ca làm việc, nghỉ phép, lịch sử)
-- ================================================================

INSERT INTO employee_rewards_disciplines (user_id, reward_discipline_id, amount, note, applied_date) VALUES
-- Thưởng KPI Tháng (reward_discipline_id = 1)
(2,  1, 5000000, 'Thưởng KPI tháng 5/2026 - Lãnh đạo xuất sắc', '2026-05-31'),
(3,  1, 2500000, 'Thưởng KPI tháng 5/2026 - Hoàn thành mục tiêu tuyển dụng', '2026-05-31'),
(4,  1, 2000000, 'Thưởng KPI tháng 5/2026 - Đảm bảo tiến độ sản xuất', '2026-05-31'),
(5,  1, 1000000, 'Thưởng KPI tháng 5/2026 - Hoàn thành chỉ tiêu', '2026-05-31'),
(10, 1, 1500000, 'Thưởng KPI tháng 5/2026 - Hoàn thành 105% chỉ tiêu',    '2026-05-31'),
(33, 1, 1000000, 'Thưởng KPI tháng 5/2026 - Quyết toán chuẩn xác', '2026-05-31'),
-- Thưởng Dự án (reward_discipline_id = 2)
(14, 2, 5000000, 'Thưởng hoàn thành xuất sắc dự án kiểm toán nội bộ Q1',   '2026-04-30');

INSERT INTO employee_shifts (user_id, shift_id, work_date) VALUES
(2,  1, '2026-06-03'),
(3,  1, '2026-06-03'),
(4,  1, '2026-06-03'),
(5,  1, '2026-06-03'),
(10, 1, '2026-06-03'),
(14, 1, '2026-06-03'),
(33, 1, '2026-06-03');

INSERT INTO leave_requests (user_id, leave_type_id, start_date, end_date, total_days, reason, status, approved_by) VALUES
-- Nghỉ phép năm (leave_type_id = 1)
(2,  1, '2026-06-10', '2026-06-11', 2.0, 'Nghỉ giải quyết việc riêng', 'Approved', 1),
(4,  1, '2026-06-15', '2026-06-16', 2.0, 'Đưa gia đình đi khám bệnh', 'Approved', 2),
-- Nghỉ ốm hưởng BHXH (leave_type_id = 2)
(3,  2, '2026-06-01', '2026-06-02', 2.0, 'Ốm sốt siêu vi', 'Approved', 2),
(5,  2, '2026-06-08', '2026-06-09', 2.0, 'Cảm cúm', 'Approved', 3),
(10, 2, '2026-06-03', '2026-06-04', 2.0, 'Sốt cao, có giấy nghỉ của bác sĩ',        'Approved', 3),
(33, 2, '2026-06-18', '2026-06-19', 2.0, 'Điều trị dạ dày', 'Approved', 14),
-- Nghỉ thai sản nữ (leave_type_id = 3) — user 27 nghỉ thai sản cả tháng 7/2026
-- Số ngày lịch: 31 (ngày lịch, bao gồm cả CN/T7)
-- Business rule tạm thời: maternityBenefit = insuranceBase của kỳ payroll (không chia 24, không nhân ngày)
-- Tháng 7/2026: 26 ngày làm việc (27 ngày T2-T7 trừ 1 ngày lễ test 15/7)
(27, 3, '2026-07-01', '2026-07-31', 31.0, 'Nghỉ thai sản theo quy định', 'Approved', 3);

-- Seed data for position_allowances
-- Giám đốc (1): Ăn trưa, Đi lại, Điện thoại, Trách nhiệm GĐ
INSERT INTO position_allowances (position_id, allowance_id) VALUES (1, 1), (1, 2), (1, 5), (1, 6);
-- Trưởng phòng (2): Ăn trưa, Đi lại, Trách nhiệm, Điện thoại
INSERT INTO position_allowances (position_id, allowance_id) VALUES (2, 1), (2, 2), (2, 3), (2, 5);
-- Phó phòng (3): Ăn trưa, Đi lại
INSERT INTO position_allowances (position_id, allowance_id) VALUES (3, 1), (3, 2);
-- Quản đốc (4): Ăn trưa, Đi lại, Trách nhiệm, Điện thoại
INSERT INTO position_allowances (position_id, allowance_id) VALUES (4, 1), (4, 2), (4, 3), (4, 5);
-- Tổ trưởng (5): Ăn trưa, Đi lại, Trách nhiệm
INSERT INTO position_allowances (position_id, allowance_id) VALUES (5, 1), (5, 2), (5, 3);
-- Kế toán trưởng (6): Ăn trưa, Đi lại, Trách nhiệm, Điện thoại
INSERT INTO position_allowances (position_id, allowance_id) VALUES (6, 1), (6, 2), (6, 3), (6, 5);
-- Chuyên viên (7): Ăn trưa, Đi lại
INSERT INTO position_allowances (position_id, allowance_id) VALUES (7, 1), (7, 2);
-- Nhân viên (8): Ăn trưa, Đi lại
INSERT INTO position_allowances (position_id, allowance_id) VALUES (8, 1), (8, 2);
-- Công nhân (9): Ăn trưa, Đi lại
INSERT INTO position_allowances (position_id, allowance_id) VALUES (9, 1), (9, 2);

-- Seed data for seniority_rules
INSERT INTO seniority_rules (min_months, max_months, amount) VALUES 
(36, 59, 300000),  -- 3 to <5 years
(60, 119, 500000), -- 5 to <10 years
(120, NULL, 1000000);

INSERT INTO shift_assignments (user_id, shift_id, assigned_date) VALUES
-- Ca Hành Chính (shift_id = 1) ngày 04/06/2026
(2,  1, '2026-06-04'),
(3,  1, '2026-06-04'),
(4,  1, '2026-06-04'),
(5,  1, '2026-06-04'),
(10, 1, '2026-06-04'),
(14, 1, '2026-06-04'),
(33, 1, '2026-06-04');

INSERT INTO work_history (user_id, position_title, company_name, location, start_date, end_date, description, is_current) VALUES
-- Giám đốc (user 2)
(2, 'Giám đốc điều hành', 'Công ty TNHH Group4', 'Hà Nội', '2020-01-01', NULL, 'Điều hành toàn bộ hoạt động sản xuất kinh doanh của công ty', 1),
-- Trưởng phòng Nhân sự (user 3)
(3, 'Trưởng phòng Nhân sự', 'Công ty TNHH Group4', 'Hà Nội', '2021-03-10', NULL, 'Phụ trách tuyển dụng, đào tạo và quản lý chính sách C&B toàn công ty', 1),
(3, 'Chuyên viên Nhân sự', 'Công ty CP Nhân Lực Việt', 'Hà Nội', '2016-06-01', '2021-02-28', 'Thực hiện tuyển dụng và quản lý hồ sơ nhân viên', 0),
-- Quản đốc (user 4)
(4, 'Quản đốc xưởng sản xuất', 'Công ty TNHH Group4', 'Bắc Ninh', '2020-06-01', NULL, 'Quản lý toàn bộ dây chuyền sản xuất, giám sát an toàn lao động', 1),
-- Công nhân (user 5)
(5, 'Công nhân lắp ráp', 'Công ty TNHH Group4', 'Bắc Ninh', '2022-02-15', NULL, 'Thực hiện công đoạn lắp ráp sản phẩm', 1),
(5, 'Công nhân', 'Công ty May Mặc ABC', 'Hà Nội', '2019-01-01', '2022-01-31', 'May mặc', 0),
-- Kế toán trưởng (user 14)
(14, 'Kế toán trưởng', 'Công ty TNHH Group4', 'Hà Nội', '2015-02-01', NULL, 'Phụ trách tài chính, công nợ, thuế và báo cáo tài chính định kỳ', 1),
(14, 'Kế toán tổng hợp', 'Công ty TNHH Tài Chính Minh Phát', 'Hà Nội', '2009-08-01', '2015-01-31', 'Lập báo cáo tài chính, quyết toán thuế hàng năm', 0),
-- HR Staff (user 10)
(10, 'Chuyên viên Nhân sự', 'Công ty TNHH Group4', 'Hà Nội', '2021-06-01', NULL, 'Quản lý hợp đồng, bảo hiểm, data nhân sự', 1),
-- Kế toán (user 33)
(33, 'Kế toán viên', 'Công ty TNHH Group4', 'Hà Nội', '2025-03-01', NULL, 'Thanh toán nội bộ', 1);



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
(2, 1),  -- Nhân sự → Ca Hành Chính
(3, 1),  -- Kế toán/Tài chính → Ca Hành Chính
(5, 1);  -- Xưởng sản xuất → Ca Hành Chính (default)

-- Sample overtime plan (created by Quản đốc - user 4)
INSERT INTO overtime_plans (plan_id, dept_id, supervisor_id, target_date, description, status) VALUES
(1, 5, 4, '2026-06-10', 'Tăng ca hoàn thành đơn hàng xuất khẩu gấp', 'Active'),
(2, 5, 4, '2026-06-12', 'Tăng ca bảo trì máy móc cuối tuần', 'Active');

-- Sample overtime assignments
INSERT INTO overtime_assignments (assignment_id, plan_id, user_id, assigned_hours, status) VALUES
(1, 1, 5,  3.0, 'Pending');   -- Phạm Công Nhân: 3h OT

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
    personal_deduction  DECIMAL(15,2)   NOT NULL DEFAULT 15500000 COMMENT 'Giảm trừ bản thân',
    dependent_deduction DECIMAL(15,2)   NOT NULL DEFAULT 6200000  COMMENT 'Giảm trừ mỗi NPT',
    status              TINYINT(1)      NOT NULL DEFAULT 1,
    notes               VARCHAR(500)    NULL,
    created_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_tax_profile_user (user_id),
    CONSTRAINT fk_etp_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;



-- ══════════════════════════════════════════════════════
-- SEED DATA: Biểu thuế TNCN — Đóng 7 bậc cũ (2020) + 5 bậc mới Luật 109/2025/QH15
-- ══════════════════════════════════════════════════════

-- Đóng 7 bậc cũ (hiệu lực 2020-01-01 → 2025-12-31)
INSERT INTO tax_brackets (bracket_no, income_from, income_to, rate, effective_from, effective_to, rounding_rule, status, created_by) VALUES
(1,         0,  5000000,  5.00, '2020-01-01', '2025-12-31', 'HALF_UP', 0, 1),
(2,   5000000, 10000000, 10.00, '2020-01-01', '2025-12-31', 'HALF_UP', 0, 1),
(3,  10000000, 18000000, 15.00, '2020-01-01', '2025-12-31', 'HALF_UP', 0, 1),
(4,  18000000, 32000000, 20.00, '2020-01-01', '2025-12-31', 'HALF_UP', 0, 1),
(5,  32000000, 52000000, 25.00, '2020-01-01', '2025-12-31', 'HALF_UP', 0, 1),
(6,  52000000, 80000000, 30.00, '2020-01-01', '2025-12-31', 'HALF_UP', 0, 1),
(7,  80000000,     NULL, 35.00, '2020-01-01', '2025-12-31', 'HALF_UP', 0, 1);

-- 5 bậc mới Luật 109/2025/QH15 (hiệu lực từ 01/01/2026)
INSERT INTO tax_brackets (bracket_no, income_from, income_to, rate, effective_from, rounding_rule, status, created_by) VALUES
(1,          0,  10000000,  5.00, '2026-01-01', 'HALF_UP', 1, 1),
(2,  10000000,  30000000, 10.00, '2026-01-01', 'HALF_UP', 1, 1),
(3,  30000000,  60000000, 20.00, '2026-01-01', 'HALF_UP', 1, 1),
(4,  60000000, 100000000, 30.00, '2026-01-01', 'HALF_UP', 1, 1),
(5, 100000000,      NULL, 35.00, '2026-01-01', 'HALF_UP', 1, 1);

-- ══════════════════════════════════════════════════════
-- SEED DATA: Giảm trừ thuế — Đóng mức cũ (2020) + Mức mới Luật 109/2025/QH15
-- ══════════════════════════════════════════════════════

-- Đóng mức cũ (2020)
INSERT INTO tax_deductions (deduction_type, deduction_name, amount, effective_from, effective_to, status, created_by) VALUES
('PERSONAL',  'Giảm trừ bản thân',        11000000, '2020-07-01', '2025-12-31', 0, 1),
('DEPENDENT', 'Giảm trừ người phụ thuộc',  4400000, '2020-07-01', '2025-12-31', 0, 1);

-- Mức mới 2026 (Luật 109/2025/QH15)
INSERT INTO tax_deductions (deduction_type, deduction_name, amount, effective_from, status, created_by) VALUES
('PERSONAL',  'Giảm trừ bản thân (Luật 109/2025)',         15500000, '2026-01-01', 1, 1),
('DEPENDENT', 'Giảm trừ người phụ thuộc (Luật 109/2025)',   6200000, '2026-01-01', 1, 1);

-- ══════════════════════════════════════════════════════
-- SEED DATA: employee_tax_profiles (auto-sync từ dependents)
-- ══════════════════════════════════════════════════════

INSERT INTO employee_tax_profiles (user_id, tax_code, tax_registration, dependent_count, personal_deduction, dependent_deduction)
SELECT 
    ep.user_id,
    ep.tax_code,
    1,
    ep.dependent_count,
    15500000,
    6200000
FROM employee_profiles ep
WHERE ep.user_id IN (SELECT user_id FROM users WHERE status = 1)
ON DUPLICATE KEY UPDATE 
    dependent_count     = ep.dependent_count,
    personal_deduction  = 15500000,
    dependent_deduction = 6200000;


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
CREATE TABLE IF NOT EXISTS timesheet_confirmations (
    id              INT PRIMARY KEY AUTO_INCREMENT,
    month           INT          NOT NULL,
    year            INT          NOT NULL,
    department_id   INT          NOT NULL,
    status          VARCHAR(50)  NOT NULL DEFAULT 'DRAFT',
    reject_reason   VARCHAR(500) NULL,
    created_by      INT          NOT NULL,
    created_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by      INT          NULL,
    updated_at      TIMESTAMP    NULL,
    CONSTRAINT fk_tc_dept   FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE CASCADE,
    CONSTRAINT fk_tc_creator FOREIGN KEY (created_by) REFERENCES users(user_id),
    CONSTRAINT fk_tc_updater FOREIGN KEY (updated_by) REFERENCES users(user_id),
    UNIQUE KEY uk_dept_month_year (department_id, month, year)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `timesheet_employee_confirmations` (
    `id`            INT             NOT NULL AUTO_INCREMENT,
    `user_id`       INT             NOT NULL,
    `month`         INT             NOT NULL,
    `year`          INT             NOT NULL,
    `department_id` INT             NOT NULL,
    `status`        VARCHAR(20)     NOT NULL DEFAULT 'CONFIRMED',
    `confirmed_at`  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_user_month_year` (`user_id`, `month`, `year`),
    CONSTRAINT `fk_tec_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
    CONSTRAINT `fk_tec_dept` FOREIGN KEY (`department_id`) REFERENCES `departments` (`department_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================
-- PERFORMANCE KPI EVALUATION SCHEMA
-- =============================================================

CREATE TABLE IF NOT EXISTS kpi_templates (
    template_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    status TINYINT DEFAULT 1, -- 1: Active, 0: Inactive
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT,
    department_id INT NULL,
    FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE SET NULL,
    FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS kpi_template_items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    template_id INT NOT NULL,
    criterion_name VARCHAR(255) NOT NULL,
    description TEXT,
    weight DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    FOREIGN KEY (template_id) REFERENCES kpi_templates(template_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS kpi_cycles (
    cycle_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    deadline DATE NOT NULL,
    template_id INT NOT NULL,
    status VARCHAR(20) DEFAULT 'DRAFT', -- 'DRAFT', 'ACTIVE', 'SUBMITTED', 'APPROVED', 'LOCKED'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (template_id) REFERENCES kpi_templates(template_id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS kpi_evaluations (
    evaluation_id INT AUTO_INCREMENT PRIMARY KEY,
    cycle_id INT NOT NULL,
    employee_id INT NOT NULL,
    manager_id INT NOT NULL,
    score DECIMAL(5,2) DEFAULT 0.00,
    weighted_score DECIMAL(5,2) DEFAULT 0.00,
    status VARCHAR(20) DEFAULT 'DRAFT', -- 'DRAFT', 'SUBMITTED', 'APPROVED', 'REJECTED'
    comment TEXT,
    submitted_at TIMESTAMP NULL,
    approved_at TIMESTAMP NULL,
    locked_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by INT NULL,
    updated_by INT NULL,
    UNIQUE KEY uq_cycle_employee (cycle_id, employee_id),
    FOREIGN KEY (cycle_id) REFERENCES kpi_cycles(cycle_id) ON DELETE CASCADE,
    FOREIGN KEY (employee_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (manager_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS kpi_evaluation_items (
    evaluation_item_id INT AUTO_INCREMENT PRIMARY KEY,
    evaluation_id INT NOT NULL,
    template_item_id INT NOT NULL,
    score DECIMAL(5,2) DEFAULT 0.00,
    comment TEXT,
    FOREIGN KEY (evaluation_id) REFERENCES kpi_evaluations(evaluation_id) ON DELETE CASCADE,
    FOREIGN KEY (template_item_id) REFERENCES kpi_template_items(item_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS kpi_comments (
    comment_id INT AUTO_INCREMENT PRIMARY KEY,
    evaluation_id INT NOT NULL,
    user_id INT NOT NULL,
    comment_text TEXT NOT NULL,
    type VARCHAR(20) NOT NULL, -- 'MANAGER', 'EMPLOYEE', 'REVIEWER'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (evaluation_id) REFERENCES kpi_evaluations(evaluation_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS kpi_status_history (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    evaluation_id INT NOT NULL,
    from_status VARCHAR(20) NOT NULL,
    to_status VARCHAR(20) NOT NULL,
    changed_by INT NOT NULL,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    note TEXT,
    FOREIGN KEY (evaluation_id) REFERENCES kpi_evaluations(evaluation_id) ON DELETE CASCADE,
    FOREIGN KEY (changed_by) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;



-- Seed default criteria and template
-- ── KPI Templates ──
INSERT INTO kpi_templates 
(template_id, name, description, status, created_by, department_id)
VALUES

(2, 'KPI Khối Nhân Sự',
 'Mẫu KPI đánh giá hiệu quả công việc phòng nhân sự',
 1, 1, 2),

(3, 'KPI Khối Tài Chính',
 'Mẫu KPI đánh giá hiệu quả công việc phòng tài chính',
 1, 1, 3),

(5, 'KPI Xưởng Sản Xuất',
 'Mẫu KPI đánh giá năng suất, chất lượng và hiệu quả sản xuất',
 1, 1, 5),

(6, 'Mẫu KPI Chung',
 'Mẫu KPI áp dụng chung cho toàn bộ nhân viên trong công ty',
 1, 1, NULL);

-- =============================================================
-- KPI TEMPLATE ITEMS
-- =============================================================

INSERT INTO kpi_template_items
(template_id, criterion_name, description, weight)
VALUES




-- =============================================================
-- 2. KPI KHỐI NHÂN SỰ
-- =============================================================

(2, 'Tuyển dụng và đáp ứng nhân sự',
 'Đảm bảo tuyển dụng đúng kế hoạch và nhu cầu nhân sự',
 20),

(2, 'Quản lý hồ sơ nhân viên',
 'Cập nhật đầy đủ thông tin nhân sự, hợp đồng và hồ sơ lao động',
 15),

(2, 'Quản lý chấm công, tính lương và phúc lợi',
 'Đảm bảo dữ liệu chấm công, lương và chế độ chính xác',
 15),

(2, 'Đào tạo và phát triển nhân sự',
 'Lập kế hoạch đào tạo và theo dõi phát triển nhân viên',
 10),

(2, 'Quan hệ lao động',
 'Hỗ trợ giải quyết vấn đề nhân sự và duy trì môi trường làm việc',
 10),

(2, 'Tuân thủ chính sách nhân sự',
 'Đảm bảo thực hiện đúng quy định lao động',
 10),

(2, 'Báo cáo và phân tích dữ liệu nhân sự',
 'Cung cấp báo cáo nhân sự đầy đủ và chính xác',
 10),


-- =============================================================
-- 3. KPI KHỐI KẾ TOÁN
-- =============================================================

(3, 'Độ chính xác nghiệp vụ kế toán',
 'Hạch toán, kiểm tra chứng từ và số liệu kế toán chính xác',
 25),

(3, 'Lập báo cáo tài chính và kế toán',
 'Hoàn thành báo cáo đúng thời hạn và đúng quy định',
 20),

(3, 'Quản lý chứng từ kế toán',
 'Lưu trữ hóa đơn, chứng từ khoa học và đầy đủ',
 15),

(3, 'Quản lý công nợ và thanh toán',
 'Theo dõi công nợ, xử lý thanh toán đúng hạn',
 15),

(3, 'Tuân thủ quy định tài chính - thuế',
 'Thực hiện đúng quy định kế toán và thuế',
 10),

(3, 'Kiểm soát chi phí',
 'Theo dõi và đề xuất tối ưu chi phí',
 10),

(3, 'Phối hợp nội bộ',
 'Hỗ trợ các phòng ban về nghiệp vụ tài chính',
 5),





-- =============================================================
-- 5. KPI XƯỞNG SẢN XUẤT
-- =============================================================

(5, 'Năng suất sản xuất',
 'Đảm bảo sản lượng theo kế hoạch sản xuất',
 25),

(5, 'Chất lượng sản phẩm',
 'Kiểm soát lỗi sản phẩm và đảm bảo tiêu chuẩn kỹ thuật',
 20),

(5, 'Tuân thủ quy trình sản xuất',
 'Thực hiện đúng quy trình vận hành và kỹ thuật',
 15),

(5, 'An toàn lao động và vệ sinh nhà xưởng',
 'Tuân thủ quy định an toàn lao động',
 15),

(5, 'Quản lý nguyên vật liệu',
 'Sử dụng nguyên vật liệu hiệu quả, hạn chế hao hụt',
 10),

(5, 'Bảo quản máy móc thiết bị',
 'Vận hành và bảo dưỡng thiết bị đúng quy định',
 10),

(5, 'Tinh thần làm việc nhóm',
 'Phối hợp sản xuất và tuân thủ kỷ luật',
 5),


-- =============================================================
-- 6. KPI CHUNG
-- =============================================================

(6, 'Hoàn thành công việc được giao',
 'Đảm bảo hoàn thành nhiệm vụ đúng tiến độ',
 25),

(6, 'Chất lượng công việc',
 'Đảm bảo độ chính xác và hạn chế sai sót',
 20),

(6, 'Tinh thần trách nhiệm',
 'Chủ động và có trách nhiệm trong công việc',
 15),

(6, 'Khả năng phối hợp làm việc nhóm',
 'Phối hợp tốt với đồng nghiệp và phòng ban',
 15),

(6, 'Tuân thủ nội quy công ty',
 'Thực hiện đúng quy định và quy trình',
 10),

(6, 'Học hỏi và phát triển bản thân',
 'Nâng cao kỹ năng chuyên môn',
 10),

(6, 'Đề xuất cải tiến',
 'Đóng góp ý tưởng nâng cao hiệu quả',
 5);
CREATE TABLE payroll_configs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    config_key VARCHAR(100) NOT NULL UNIQUE COMMENT 'Mã Tham số (Key)',
    description NVARCHAR(255) NOT NULL COMMENT 'Mô tả chi tiết',
    config_value DECIMAL(15, 2) NOT NULL COMMENT 'Giá trị thiết lập',
    unit NVARCHAR(20) NULL COMMENT 'Đơn vị tính (%, VNĐ, Tháng...)',
    status TINYINT(1) DEFAULT 1 COMMENT 'Trạng thái: 1-Hoạt động, 0-Vô hiệu hóa',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Thời gian tạo',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Thời gian cập nhật'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bảng cấu hình tham số tính lương';

INSERT INTO payroll_configs (config_key, description, config_value, unit) VALUES
-- 1. Nhóm tỷ lệ trích nộp Bảo hiểm (Phần Người lao động đóng)
('BHXH_EMP_RATE', 'Tỷ lệ đóng BHXH (Người lao động)', 8.00, '%'),
('BHYT_EMP_RATE', 'Tỷ lệ đóng BHYT (Người lao động)', 1.50, '%'),
('BHTN_EMP_RATE', 'Tỷ lệ đóng BHTN (Người lao động)', 1.00, '%'),

-- 2. Nhóm tỷ lệ trích nộp Bảo hiểm (Phần Doanh nghiệp đóng)
('BHXH_COMP_RATE', 'Tỷ lệ đóng BHXH (Doanh nghiệp)', 17.50, '%'),
('BHYT_COMP_RATE', 'Tỷ lệ đóng BHYT (Doanh nghiệp)', 3.00, '%'),
('BHTN_COMP_RATE', 'Tỷ lệ đóng BHTN (Doanh nghiệp)', 1.00, '%'),

-- 3. Nhóm giảm trừ Thuế Thu nhập cá nhân (TNCN)
('TAX_PERSONAL_DEDUCTION', 'Mức giảm trừ gia cảnh bản thân', 11000000.00, 'VNĐ'),
('TAX_DEPENDENT_DEDUCTION', 'Mức giảm trừ người phụ thuộc (1 người)', 4400000.00, 'VNĐ'),

-- 4. Các mức lương cơ sở & tối thiểu vùng (Lưu ý: Mức lương cơ sở 2.34tr áp dụng từ 01/07/2024)
('BASE_SALARY', 'Mức lương cơ sở (Tính trần BHXH, BHYT)', 2340000.00, 'VNĐ'),
('MIN_REGIONAL_WAGE_1', 'Lương tối thiểu Vùng I (Tính trần BHTN)', 4960000.00, 'VNĐ'),
('MIN_REGIONAL_WAGE_2', 'Lương tối thiểu Vùng II', 4410000.00, 'VNĐ'),
('MIN_REGIONAL_WAGE_3', 'Lương tối thiểu Vùng III', 3860000.00, 'VNĐ'),
('MIN_REGIONAL_WAGE_4', 'Lương tối thiểu Vùng IV', 3450000.00, 'VNĐ'),

-- 5. Số ngày công chuẩn trong tháng (Tùy công ty, thường là 22, 24 hoặc 26)
('STANDARD_WORK_DAYS', 'Số ngày công chuẩn trong tháng', 26.00, 'Ngày');

-- =====================================================================
-- BẢNG HOLIDAYS (Ngày nghỉ lễ)
-- =====================================================================
SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE IF NOT EXISTS holidays (
    holiday_id     INT           PRIMARY KEY AUTO_INCREMENT,
    holiday_name   VARCHAR(150)  NOT NULL,
    holiday_date   DATE          NOT NULL,
    holiday_year   INT           NOT NULL,
    rule_code      VARCHAR(50)   NULL,
    source         ENUM('AUTO','MANUAL') NOT NULL DEFAULT 'MANUAL',
    is_makeup_day  TINYINT(1)    NOT NULL DEFAULT 0,
    calendar_type  ENUM('SOLAR','LUNAR') NOT NULL DEFAULT 'SOLAR',
    ot_multiplier  DECIMAL(4,2)  NOT NULL DEFAULT 3.00,
    description    VARCHAR(255)  NULL,
    status         TINYINT(1)    NOT NULL DEFAULT 1,
    created_at     TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_holiday_date (holiday_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS holiday_rules (
    rule_code       VARCHAR(50) PRIMARY KEY,
    rule_name       VARCHAR(150),
    calendar_type   ENUM('SOLAR','LUNAR'),
    ref_month       INT,
    ref_day         INT,
    day_offset      INT DEFAULT 0,
    ot_multiplier   DECIMAL(4,2) DEFAULT 3.00,
    active          TINYINT(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO holiday_rules (rule_code, rule_name, calendar_type, ref_month, ref_day, day_offset, ot_multiplier, active) VALUES
('TET_DUONG_LICH', 'Tết Dương lịch', 'SOLAR', 1, 1, 0, 3.00, 1),
('TET_29', 'Tết Nguyên Đán (29 Tết)', 'LUNAR', 1, 1, -2, 3.00, 1),
('TET_30', 'Tết Nguyên Đán (30 Tết)', 'LUNAR', 1, 1, -1, 3.00, 1),
('TET_MUNG_1', 'Tết Nguyên Đán (Mùng 1)', 'LUNAR', 1, 1, 0, 3.00, 1),
('TET_MUNG_2', 'Tết Nguyên Đán (Mùng 2)', 'LUNAR', 1, 1, 1, 3.00, 1),
('TET_MUNG_3', 'Tết Nguyên Đán (Mùng 3)', 'LUNAR', 1, 1, 2, 3.00, 1),
('GIO_TO', 'Giỗ Tổ Hùng Vương', 'LUNAR', 3, 10, 0, 3.00, 1),
('GIAI_PHONG', 'Ngày Giải phóng miền Nam', 'SOLAR', 4, 30, 0, 3.00, 1),
('QUOC_TE_LAO_DONG', 'Ngày Quốc tế Lao động', 'SOLAR', 5, 1, 0, 3.00, 1),
('QUOC_KHANH_1', 'Quốc khánh (liền kề)', 'SOLAR', 9, 1, 0, 3.00, 1),
('QUOC_KHANH_2', 'Quốc khánh', 'SOLAR', 9, 2, 0, 3.00, 1)
ON DUPLICATE KEY UPDATE
    rule_name = VALUES(rule_name),
    calendar_type = VALUES(calendar_type),
    ref_month = VALUES(ref_month),
    ref_day = VALUES(ref_day),
    day_offset = VALUES(day_offset),
    ot_multiplier = VALUES(ot_multiplier);

INSERT INTO holidays (holiday_name, holiday_date, holiday_year, rule_code, source, calendar_type, ot_multiplier, status) VALUES
('Tết Dương lịch', '2026-01-01', 2026, 'TET_DUONG_LICH', 'AUTO', 'SOLAR', 3.00, 1),
('Tết Nguyên Đán (29 Tết)', '2026-02-16', 2026, 'TET_29', 'AUTO', 'LUNAR', 3.00, 1),
('Tết Nguyên Đán (Mùng 1)', '2026-02-17', 2026, 'TET_MUNG_1', 'AUTO', 'LUNAR', 3.00, 1),
('Tết Nguyên Đán (Mùng 2)', '2026-02-18', 2026, 'TET_MUNG_2', 'AUTO', 'LUNAR', 3.00, 1),
('Tết Nguyên Đán (Mùng 3)', '2026-02-19', 2026, 'TET_MUNG_3', 'AUTO', 'LUNAR', 3.00, 1),
('Tết Nguyên Đán (Mùng 4)', '2026-02-20', 2026, 'TET_MUNG_4', 'AUTO', 'LUNAR', 3.00, 1),
('Giỗ Tổ Hùng Vương', '2026-04-26', 2026, 'GIO_TO', 'AUTO', 'LUNAR', 3.00, 1),
('Giỗ Tổ Hùng Vương (nghỉ bù)', '2026-04-27', 2026, 'GIO_TO', 'AUTO', 'LUNAR', 3.00, 1),
('Ngày Giải phóng miền Nam', '2026-04-30', 2026, 'GIAI_PHONG', 'AUTO', 'SOLAR', 3.00, 1),
('Ngày Quốc tế Lao động', '2026-05-01', 2026, 'QUOC_TE_LAO_DONG', 'AUTO', 'SOLAR', 3.00, 1),
-- Ngày lễ test tính năng holiday trong hệ thống tính lương (15/7/2026 - Thứ Tư)
-- Mục đích: kiểm tra ngày lễ giữa tháng bị loại khỏi standardWorkDays và insuranceBenefit
('Ngày lễ test hệ thống', '2026-07-15', 2026, 'TEST_HOLIDAY_0715', 'MANUAL', 'SOLAR', 3.00, 1),
('Quốc khánh (liền kề)', '2026-09-01', 2026, 'QUOC_KHANH_1', 'AUTO', 'SOLAR', 3.00, 1),
('Quốc khánh', '2026-09-02', 2026, 'QUOC_KHANH_2', 'AUTO', 'SOLAR', 3.00, 1)
ON DUPLICATE KEY UPDATE 
    holiday_name = VALUES(holiday_name),
    calendar_type = VALUES(calendar_type),
    ot_multiplier = VALUES(ot_multiplier),
    status = VALUES(status);
SET FOREIGN_KEY_CHECKS = 1;