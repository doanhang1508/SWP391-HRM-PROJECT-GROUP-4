-- =============================================================
-- MIGRATION SCRIPT: NGHỈ VIỆC v3
-- Mô tả:
-- 1. Thêm trạng thái 'WITHDRAW_REQUESTED', 'WITHDRAWN' vào ENUM status của resignation_requests
-- 2. Thêm cột previous_employment_status_id để lưu trạng thái trước khi nghỉ
-- =============================================================

ALTER TABLE resignation_requests 
MODIFY COLUMN status ENUM('PENDING','APPROVED','REJECTED','COMPLETED','CANCELLED','WITHDRAW_REQUESTED','WITHDRAWN') NOT NULL DEFAULT 'PENDING',
ADD COLUMN previous_employment_status_id INT NULL COMMENT 'Lưu trạng thái làm việc (của bảng employee_profiles) trước khi chuyển sang NoticePeriod';
