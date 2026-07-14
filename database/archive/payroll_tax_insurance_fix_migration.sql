/* ================================================================
   MIGRATION: Payroll Tax & Insurance Base Fix

   Mô tả: Sửa logic tính BHXH và thuế TNCN cho phụ cấp & thưởng:
   1. Thêm 2 cột vào reward_disciplines để đánh dấu khoản thưởng
      nào miễn BHXH và/hoặc miễn thuế TNCN.
   2. Cập nhật seed data "Thưởng KPI Tháng" (id=1) → miễn cả 2.
   3. Thêm dòng "Thưởng Năng suất" (id=9) → miễn cả 2.
   4. Thêm 2 cột audit vào bảng payroll: insurance_base_amount
      và taxable_income_base để lưu breakdown phục vụ hiển thị
      phiếu lương và kiểm toán.

   Chạy TRỰC TIẾP trên database HRM_System đang sử dụng.
   An toàn chạy nhiều lần (IF NOT EXISTS / ON DUPLICATE KEY).
   ================================================================ */

USE HRM_System;

-- ══════════════════════════════════════════════════════════════════
-- 1. ALTER bảng reward_disciplines: thêm cờ is_bhxh_applied & is_taxable
-- ══════════════════════════════════════════════════════════════════

-- Thêm cột is_bhxh_applied nếu chưa tồn tại
ALTER TABLE reward_disciplines
  ADD COLUMN IF NOT EXISTS is_bhxh_applied TINYINT(1) NOT NULL DEFAULT 0
    COMMENT '1=Khoản này cộng vào nền tính BHXH/BHYT/BHTN, 0=Không';

-- Thêm cột is_taxable nếu chưa tồn tại
-- Default = 1: các khoản thưởng dự án, chuyên cần... chịu thuế bình thường
ALTER TABLE reward_disciplines
  ADD COLUMN IF NOT EXISTS is_taxable TINYINT(1) NOT NULL DEFAULT 1
    COMMENT '1=Chịu thuế TNCN, 0=Miễn thuế (VD: thưởng KPI/năng suất theo Thông tư 111)';

-- ══════════════════════════════════════════════════════════════════
-- 2. Cập nhật seed data cho các loại thưởng/kỷ luật hiện có
-- ══════════════════════════════════════════════════════════════════

-- Thưởng KPI Tháng: miễn BHXH + miễn thuế TNCN
-- Căn cứ: khoản thưởng KPI/năng suất theo Điều 3 Thông tư 111/2013/TT-BTC
-- không thuộc thu nhập chịu thuế khi gắn với KPI cá nhân theo quy chế nội bộ.
UPDATE reward_disciplines
SET is_bhxh_applied = 0, is_taxable = 0
WHERE id = 1;

-- Thưởng Dự án, Thưởng Chuyên cần: chịu thuế bình thường (is_taxable=1 = default)
-- Không cần UPDATE thêm, DEFAULT 1 đã đúng.

-- ══════════════════════════════════════════════════════════════════
-- 3. Thêm loại thưởng mới: Thưởng Năng suất (miễn BH + miễn thuế)
-- ══════════════════════════════════════════════════════════════════

INSERT INTO reward_disciplines (id, name, type, description, apply_level, is_bhxh_applied, is_taxable, created_by)
VALUES (9, 'Thưởng Năng suất', 'Reward', 'Thưởng theo năng suất lao động, miễn BHXH và thuế TNCN', 'Cá nhân', 0, 0, 1)
ON DUPLICATE KEY UPDATE
  is_bhxh_applied = 0,
  is_taxable      = 0;

-- ══════════════════════════════════════════════════════════════════
-- 4. ALTER bảng payroll: thêm 2 cột audit cho breakdown tính lương
-- ══════════════════════════════════════════════════════════════════

-- Nền đóng BHXH thực tế = base_salary + phụ cấp is_bhxh_applied=1 + thưởng is_bhxh_applied=1
ALTER TABLE payroll
  ADD COLUMN IF NOT EXISTS insurance_base_amount DECIMAL(15,2) DEFAULT 0
    COMMENT 'Nền tính BHXH/BHYT/BHTN thực tế (lương cơ bản + phụ cấp/thưởng chịu BH)';

-- Thu nhập chịu thuế trước khi trừ giảm trừ gia cảnh
-- = baseWorkedSalary + OT + allowance chịu thuế + thưởng chịu thuế
ALTER TABLE payroll
  ADD COLUMN IF NOT EXISTS taxable_income_base DECIMAL(15,2) DEFAULT 0
    COMMENT 'Thu nhập chịu thuế TNCN trước khi trừ giảm trừ gia cảnh (không gồm khoản miễn thuế)';

-- ══════════════════════════════════════════════════════════════════
-- 5. Verification queries (chạy để kiểm tra sau migration)
-- ══════════════════════════════════════════════════════════════════

-- SELECT id, name, type, is_bhxh_applied, is_taxable FROM reward_disciplines ORDER BY id;
-- Expected: id=1 → 0,0; id=2,3 → 0,1; id=4..8 → 0,1; id=9 → 0,0

-- DESCRIBE payroll;
-- Expected: có cột insurance_base_amount và taxable_income_base
