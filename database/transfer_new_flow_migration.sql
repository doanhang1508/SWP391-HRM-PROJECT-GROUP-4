-- =========================================================================
-- Migration: Đổi luồng điều chuyển sang 5 bước (New Transfer Flow)
-- Tương thích MySQL 5.7+
-- Ngày: 2026-07-02
-- =========================================================================

SET FOREIGN_KEY_CHECKS = 0;

-- =========================================================================
-- BƯỚC 1: Mở rộng ENUM status (luôn an toàn khi chạy lại)
-- =========================================================================
ALTER TABLE transfer_requests
  MODIFY COLUMN status 
    ENUM(
      'PENDING',
      'EMPLOYEE_CONFIRMED',
      'MANAGER_APPROVED',
      'APPROVED',
      'REJECTED',
      'EMPLOYEE_REJECTED',
      'CANCELLED'
    ) NOT NULL DEFAULT 'PENDING';

-- =========================================================================
-- BƯỚC 2: Thêm các cột mới (dùng stored procedure để kiểm tra trước)
-- =========================================================================
DROP PROCEDURE IF EXISTS sp_add_column_if_not_exists;

DELIMITER $$
CREATE PROCEDURE sp_add_column_if_not_exists(
    IN p_table   VARCHAR(100),
    IN p_column  VARCHAR(100),
    IN p_def     TEXT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME   = p_table
          AND COLUMN_NAME  = p_column
    ) THEN
        SET @sql = CONCAT('ALTER TABLE `', p_table, '` ADD COLUMN `', p_column, '` ', p_def);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    ELSE
        SELECT CONCAT('Column already exists, skipping: ', p_column) AS info;
    END IF;
END$$
DELIMITER ;

-- Thêm employee_confirmed_at
CALL sp_add_column_if_not_exists(
    'transfer_requests',
    'employee_confirmed_at',
    'TIMESTAMP NULL COMMENT "Thoi diem nhan vien xac nhan dong y dieu chuyen" AFTER updated_at'
);

-- Thêm employee_reject_reason
CALL sp_add_column_if_not_exists(
    'transfer_requests',
    'employee_reject_reason',
    'TEXT NULL COMMENT "Ly do nhan vien tu choi dieu chuyen" AFTER employee_confirmed_at'
);

-- Thêm manager_approved_by (nếu chưa có từ phase trước)
CALL sp_add_column_if_not_exists(
    'transfer_requests',
    'manager_approved_by',
    'INT NULL COMMENT "User ID cua Truong phong da duyet buoc 1" AFTER approved_at'
);

-- Thêm manager_approved_at (nếu chưa có từ phase trước)
CALL sp_add_column_if_not_exists(
    'transfer_requests',
    'manager_approved_at',
    'TIMESTAMP NULL COMMENT "Thoi diem Truong phong duyet buoc 1" AFTER manager_approved_by'
);

-- Dọn dẹp procedure tạm
DROP PROCEDURE IF EXISTS sp_add_column_if_not_exists;

-- =========================================================================
-- BƯỚC 3: Thêm FK cho manager_approved_by (bỏ qua nếu đã tồn tại)
-- =========================================================================
DROP PROCEDURE IF EXISTS sp_add_fk_if_not_exists;

DELIMITER $$
CREATE PROCEDURE sp_add_fk_if_not_exists()
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.TABLE_CONSTRAINTS
        WHERE TABLE_SCHEMA     = DATABASE()
          AND TABLE_NAME       = 'transfer_requests'
          AND CONSTRAINT_NAME  = 'fk_transfer_mgr_approver'
          AND CONSTRAINT_TYPE  = 'FOREIGN KEY'
    ) THEN
        ALTER TABLE transfer_requests
          ADD CONSTRAINT fk_transfer_mgr_approver
            FOREIGN KEY (manager_approved_by) REFERENCES users(user_id) ON DELETE SET NULL;
        SELECT 'FK fk_transfer_mgr_approver added.' AS info;
    ELSE
        SELECT 'FK fk_transfer_mgr_approver already exists, skipping.' AS info;
    END IF;
END$$
DELIMITER ;

CALL sp_add_fk_if_not_exists();
DROP PROCEDURE IF EXISTS sp_add_fk_if_not_exists;

SET FOREIGN_KEY_CHECKS = 1;

-- =========================================================================
-- KIỂM TRA KẾT QUẢ
-- =========================================================================
SELECT COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE, COLUMN_DEFAULT, COLUMN_COMMENT
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME   = 'transfer_requests'
ORDER BY ORDINAL_POSITION;

-- =========================================================================
-- BƯỚC 4: Tạo bảng transfer_request_allowances (nếu chưa có)
-- =========================================================================
CREATE TABLE IF NOT EXISTS transfer_request_allowances (
  transfer_request_id INT NOT NULL,
  allowance_id        INT NOT NULL,
  PRIMARY KEY (transfer_request_id, allowance_id),
  CONSTRAINT fk_tra_transfer FOREIGN KEY (transfer_request_id)
    REFERENCES transfer_requests(transfer_request_id) ON DELETE CASCADE,
  CONSTRAINT fk_tra_allowance FOREIGN KEY (allowance_id)
    REFERENCES allowances(allowance_id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Phụ cấp dự kiến đi kèm phiếu điều chuyển (chỉ áp dụng khi approve)';
