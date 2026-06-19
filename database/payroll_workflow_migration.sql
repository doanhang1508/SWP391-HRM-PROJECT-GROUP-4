/* ================================================================
   MIGRATION: Payroll Workflow (Tasks 23-28)
   
   Mô tả: Thêm các cột và trạng thái cần thiết cho quy trình
   duyệt lương đầy đủ:
   Draft → Pending → Approved/Rejected → Paid
   
   Thêm role Accountant (roleId=8) và user kế toán mẫu.
   
   Chạy TRỰC TIẾP trên database gốc HRM_System.
   ================================================================ */

USE HRM_System;

-- ══════════════════════════════════════════════════════
-- 1. ALTER bảng payroll: mở rộng ENUM status + thêm cột
-- ══════════════════════════════════════════════════════

ALTER TABLE payroll 
  MODIFY COLUMN status ENUM('Draft','Pending','Verified','Approved','Rejected','Paid') DEFAULT 'Draft';

-- Thêm cột tracking cho việc duyệt
ALTER TABLE payroll
  ADD COLUMN approved_by INT NULL AFTER status,
  ADD COLUMN approved_at TIMESTAMP NULL AFTER approved_by,
  ADD COLUMN reject_reason VARCHAR(500) NULL AFTER approved_at,
  ADD COLUMN paid_by INT NULL AFTER reject_reason,
  ADD COLUMN paid_at TIMESTAMP NULL AFTER paid_by,
  ADD COLUMN payment_note VARCHAR(500) NULL AFTER paid_at;

-- Thêm UNIQUE constraint cho user_id + month + year
ALTER TABLE payroll
  ADD UNIQUE KEY uk_user_month_year (user_id, month, year);

-- ══════════════════════════════════════════════════════
-- 2. Thêm role Accountant
-- ══════════════════════════════════════════════════════

INSERT INTO roles (role_id, role_name, description) VALUES
(8, 'Accountant', 'Kế toán - xem bảng lương, xác nhận chuyển khoản')
ON DUPLICATE KEY UPDATE role_name = VALUES(role_name);

-- Phân quyền cho Accountant
INSERT IGNORE INTO role_permissions (role_id, permission_id) VALUES
(8, 18),  -- PAYROLL_VIEW
(8, 28);  -- PROFILE_VIEW

-- ══════════════════════════════════════════════════════
-- 3. Thêm user kế toán mẫu
-- ══════════════════════════════════════════════════════

INSERT INTO users (user_id, username, password, full_name, email, phone, role_id, department_id, position_id) VALUES
(33, 'ke_toan_01', '@123456', 'Nguyễn Thị Kế Toán', 'ketoan01@hrm.com', '0901000033', 8, 3, 7)
ON DUPLICATE KEY UPDATE role_id = 8;

INSERT INTO employee_profiles (user_id, department_id, id_card, dob, gender, address, hire_date, tax_code, social_insurance_no, bank_account, bank_name, contract_type_id, salary_grade_id, employment_status_id, education_level_id) VALUES
(33, 3, '024910000033', '1991-07-15', 0, 'Cầu Giấy, Hà Nội', '2020-03-01', '8012345733', '0200001033', '0011234533', 'Vietcombank', 4, 2, 2, 2)
ON DUPLICATE KEY UPDATE department_id = 3;
