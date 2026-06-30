-- ============================================================
-- Migration: Tạo bảng resignation_requests
-- Module: Xin nghỉ việc (Employee self-resignation)
-- Khác với termination (HR sa thải): không insert vào employee_rewards_disciplines
-- ============================================================

CREATE TABLE IF NOT EXISTS resignation_requests (
    resignation_id    INT          AUTO_INCREMENT PRIMARY KEY,
    user_id           INT          NOT NULL,
    reason            TEXT         NOT NULL,
    desired_last_date DATE         NOT NULL,
    status            ENUM('PENDING', 'APPROVED', 'REJECTED') NOT NULL DEFAULT 'PENDING',
    submitted_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    reviewed_by       INT          NULL,
    reviewed_at       TIMESTAMP    NULL,
    hr_note           TEXT         NULL,

    CONSTRAINT fk_resignation_user
        FOREIGN KEY (user_id)    REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_resignation_reviewer
        FOREIGN KEY (reviewed_by) REFERENCES users(user_id) ON DELETE SET NULL
);

-- Index để tăng tốc query theo user_id và status
CREATE INDEX  idx_resignation_user_id ON resignation_requests(user_id);
CREATE INDEX  idx_resignation_status  ON resignation_requests(status);
