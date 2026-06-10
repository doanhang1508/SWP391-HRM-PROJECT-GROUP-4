-- ============================================================
-- MIGRATION: Tạo bảng onboarding_requests
-- Mô tả: Lưu trữ yêu cầu tạo tài khoản nhân viên mới từ HR
-- ============================================================

CREATE TABLE IF NOT EXISTS onboarding_requests (
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
