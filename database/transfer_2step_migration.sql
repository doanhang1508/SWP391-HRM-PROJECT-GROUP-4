-- ============================================================
-- Migration: Thêm cột phê duyệt bước 1 (Trưởng phòng) vào transfer_requests
-- Chạy trên DB live: hrm_system
-- ============================================================

ALTER TABLE transfer_requests
    ADD COLUMN manager_approved_by INT NULL DEFAULT NULL
        COMMENT 'ID người duyệt bước 1 (Trưởng phòng)',
    ADD COLUMN manager_approved_at DATETIME NULL DEFAULT NULL
        COMMENT 'Thời gian duyệt bước 1 (Trưởng phòng)',
    ADD CONSTRAINT fk_tr_manager_approved_by
        FOREIGN KEY (manager_approved_by) REFERENCES users(user_id)
        ON DELETE SET NULL ON UPDATE CASCADE;

-- Cập nhật index để query nhanh theo status
-- (chỉ thêm nếu chưa có)
ALTER TABLE transfer_requests
    ADD INDEX idx_tr_status (status),
    ADD INDEX idx_tr_old_dept_status (old_department_id, status);

-- Verify
SELECT 'Migration completed. Columns added:' AS info;
SHOW COLUMNS FROM transfer_requests LIKE 'manager%';
