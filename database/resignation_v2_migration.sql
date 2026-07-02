-- ============================================================
-- Migration: Cập nhật luồng Nghỉ việc (Resignation V2)
-- ============================================================

-- 1. Bổ sung các trạng thái mới vào employment_statuses
INSERT IGNORE INTO employment_statuses (status_id, status_name, description, status) VALUES
  (5, 'NoticePeriod', 'Đang trong thời gian báo trước nghỉ việc', 1),
  (6, 'ContractExpired', 'Hợp đồng đã hết hạn', 1),
  (7, 'Terminate', 'Bị cho thôi việc (sa thải)', 1);

-- 2. Bổ sung actual_end_date và termination_reason vào employee_contracts
-- Kiểm tra xem cột actual_end_date đã tồn tại chưa để tránh lỗi
SET @dbname = DATABASE();
SET @tablename = 'employee_contracts';
SET @columnname = 'actual_end_date';
SET @preparedStatement = (SELECT IF(
  (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE
      (table_name = @tablename)
      AND (table_schema = @dbname)
      AND (column_name = @columnname)
  ) > 0,
  "SELECT 1",
  "ALTER TABLE employee_contracts ADD COLUMN actual_end_date DATE NULL AFTER end_date, ADD COLUMN termination_reason VARCHAR(255) NULL AFTER actual_end_date"
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- 3. Cập nhật bảng resignation_requests
SET @tablename = 'resignation_requests';
SET @columnname = 'notice_period_days';
SET @preparedStatement = (SELECT IF(
  (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE
      (table_name = @tablename)
      AND (table_schema = @dbname)
      AND (column_name = @columnname)
  ) > 0,
  "SELECT 1",
  "ALTER TABLE resignation_requests 
   ADD COLUMN notice_period_days INT NULL AFTER desired_last_date, 
   ADD COLUMN expected_leave_date DATE NULL AFTER notice_period_days, 
   ADD COLUMN last_working_day DATE NULL AFTER expected_leave_date, 
   ADD COLUMN created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP AFTER hr_note, 
   ADD COLUMN updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP AFTER created_at, 
   MODIFY COLUMN status ENUM('PENDING','APPROVED','REJECTED','COMPLETED','CANCELLED') NOT NULL DEFAULT 'PENDING'"
));
PREPARE alterIfNotExists2 FROM @preparedStatement;
EXECUTE alterIfNotExists2;
DEALLOCATE PREPARE alterIfNotExists2;

-- Nếu status ENUM chưa có CANCELLED hoặc COMPLETED, ta cần chạy lại MODIFY COLUMN cho chắc chắn:
ALTER TABLE resignation_requests MODIFY COLUMN status ENUM('PENDING','APPROVED','REJECTED','COMPLETED','CANCELLED') NOT NULL DEFAULT 'PENDING';

-- 4. Bảng Checklist
CREATE TABLE IF NOT EXISTS resignation_checklist (
    checklist_id   INT PRIMARY KEY AUTO_INCREMENT,
    resignation_id INT NOT NULL,
    item_name      VARCHAR(100) NOT NULL COMMENT 'Laptop, ID Card, Uniform, Document, Knowledge Transfer, Company Assets',
    is_completed   TINYINT(1) NOT NULL DEFAULT 0,
    completed_by   INT NULL,
    completed_at   TIMESTAMP NULL,
    note           VARCHAR(255) NULL,
    CONSTRAINT fk_checklist_resignation FOREIGN KEY (resignation_id) REFERENCES resignation_requests(resignation_id) ON DELETE CASCADE,
    CONSTRAINT fk_checklist_user FOREIGN KEY (completed_by) REFERENCES users(user_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 5. Bảng Exit Interview
CREATE TABLE IF NOT EXISTS exit_interviews (
    exit_interview_id  INT PRIMARY KEY AUTO_INCREMENT,
    resignation_id     INT NOT NULL UNIQUE,
    reason_category    ENUM('Salary','Career','Study','Family','Health','Other') NOT NULL,
    comment            TEXT NULL,
    created_at         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_exit_resignation FOREIGN KEY (resignation_id) REFERENCES resignation_requests(resignation_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
