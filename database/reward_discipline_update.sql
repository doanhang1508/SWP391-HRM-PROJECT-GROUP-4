-- ================================================================
-- Script cập nhật bảng reward_disciplines
-- Thêm: apply_level, created_at, created_by
-- ================================================================
USE HRM_System;

-- Thêm cột mới
ALTER TABLE reward_disciplines
    ADD COLUMN apply_level VARCHAR(50) DEFAULT 'Cá nhân' AFTER description,
    ADD COLUMN created_at  TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP AFTER apply_level,
    ADD COLUMN created_by  INT         NULL AFTER created_at,
    ADD CONSTRAINT fk_rd_creator FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE SET NULL;

-- Cập nhật dữ liệu mẫu hiện có
UPDATE reward_disciplines SET apply_level = 'Cá nhân',  created_by = 1 WHERE id = 1;
UPDATE reward_disciplines SET apply_level = 'Nhóm/Dự án', created_by = 1 WHERE id = 2;
UPDATE reward_disciplines SET apply_level = 'Cá nhân',  created_by = 1 WHERE id = 3;
UPDATE reward_disciplines SET apply_level = 'Cá nhân',  created_by = 1 WHERE id = 4;
UPDATE reward_disciplines SET apply_level = 'Cá nhân',  created_by = 1 WHERE id = 5;
