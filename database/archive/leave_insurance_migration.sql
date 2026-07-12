-- =====================================================================
-- Migration: Leave Insurance Rates Table
-- Purpose: Separate table to calculate insurance benefits for leave periods
-- Vietnamese Labor Law references: BHXH coverage for sick/maternity/paternity leave
-- =====================================================================

-- 1. Create leave_insurance_rates table
-- This table maps each leave type to its insurance benefit rate,
-- making it configurable without hardcoding percentages in Java code.
CREATE TABLE IF NOT EXISTS leave_insurance_rates (
    leave_insurance_rate_id INT PRIMARY KEY AUTO_INCREMENT,
    leave_type_id           INT NOT NULL,
    insurance_rate_percent  DECIMAL(5,2) NOT NULL COMMENT 'Percentage of base salary covered by BHXH (e.g. 75.00 for 75%)',
    description             NVARCHAR(500),
    effective_from          DATE DEFAULT (CURRENT_DATE),
    effective_to            DATE DEFAULT NULL,
    status                  TINYINT(1) NOT NULL DEFAULT 1 COMMENT '1=Active, 0=Inactive',
    created_at              DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at              DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (leave_type_id) REFERENCES leave_types(leave_type_id)
);

-- 2. Insert Paternity Leave type if not exists
-- Nghỉ thai sản nam (Paternity Leave) - unpaid by company, covered by BHXH
INSERT INTO leave_types (type_name, description, paid_leave, max_days_per_year, status)
SELECT N'Nghỉ thai sản nam', 
       N'Nghỉ phép cho lao động nam khi vợ sinh con. Thời gian: 5-14 ngày làm việc tùy trường hợp sinh. Hưởng BHXH 100% mức bình quân lương đóng BHXH 6 tháng trước nghỉ.', 
       0,    -- NOT paid by company
       14,   -- max 14 working days per year
       1
WHERE NOT EXISTS (
    SELECT 1 FROM leave_types WHERE type_name = N'Nghỉ thai sản nam'
);

-- 3. Seed data for leave_insurance_rates
-- Based on Vietnamese Labor Law (Luật BHXH 2024, effective 2025):

-- Sick Leave (leaveTypeId = 2): 75% of base salary
INSERT INTO leave_insurance_rates (leave_type_id, insurance_rate_percent, description, effective_from) 
SELECT 2, 75.00, 
       N'Nghỉ ốm: Hưởng 75% mức tiền lương đóng BHXH theo quy định Luật BHXH. Người lao động nghỉ ốm được quỹ BHXH chi trả 75% lương đóng BHXH.',
       '2026-01-01'
WHERE NOT EXISTS (SELECT 1 FROM leave_insurance_rates WHERE leave_type_id = 2 AND status = 1);

-- Maternity Leave - Female (leaveTypeId = 3): 100% of average 6-month salary
INSERT INTO leave_insurance_rates (leave_type_id, insurance_rate_percent, description, effective_from)
SELECT 3, 100.00, 
       N'Nghỉ thai sản nữ: Hưởng 100% mức bình quân tiền lương tháng đóng BHXH 6 tháng trước khi nghỉ. Được BHXH chi trả toàn bộ.',
       '2026-01-01'
WHERE NOT EXISTS (SELECT 1 FROM leave_insurance_rates WHERE leave_type_id = 3 AND status = 1);

-- Paternity Leave - Male (leaveTypeId = 4 or auto-detected): 100% of average 6-month salary
-- Need to get the actual leaveTypeId of the paternity leave type we just inserted
INSERT INTO leave_insurance_rates (leave_type_id, insurance_rate_percent, description, effective_from)
SELECT lt.leave_type_id, 100.00,
       N'Nghỉ thai sản nam: Hưởng 100% mức bình quân tiền lương đóng BHXH 6 tháng trước khi nghỉ. Thời gian nghỉ: sinh thường 5 ngày, mổ/sinh non 7 ngày, sinh đôi 10 ngày, sinh đôi mổ 14 ngày. Phải nghỉ trong 60 ngày đầu kể từ ngày sinh.',
       '2026-01-01'
FROM leave_types lt
WHERE lt.type_name = N'Nghỉ thai sản nam'
  AND NOT EXISTS (SELECT 1 FROM leave_insurance_rates lir WHERE lir.leave_type_id = lt.leave_type_id AND lir.status = 1);

-- =====================================================================
-- SUMMARY:
-- leave_insurance_rates table stores the BHXH benefit rates per leave type:
--   - Sick leave (ID 2): 75%
--   - Maternity/female (ID 3): 100%
--   - Paternity/male (new): 100%
-- 
-- Payroll calculation formula:
--   insuranceBenefit = SUM(dailyBaseSalary × (insurance_rate_percent / 100))
--   for each unpaid leave day that has a matching leave_insurance_rate
-- =====================================================================
