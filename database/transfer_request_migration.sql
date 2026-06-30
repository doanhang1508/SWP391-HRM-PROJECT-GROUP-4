-- ============================================================
-- Migration: Tạo bảng transfer_requests
-- Module: Điều chuyển nội bộ (Internal Transfer)
-- ============================================================

CREATE TABLE IF NOT EXISTS transfer_requests (
    transfer_request_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    old_department_id INT NULL,
    old_position_id INT NULL,
    old_role_id INT NULL,
    new_department_id INT NOT NULL,
    new_position_id INT NOT NULL,
    new_role_id INT NOT NULL,
    reason TEXT NOT NULL,
    effective_date DATE NOT NULL,
    status ENUM('PENDING','APPROVED','REJECTED','CANCELLED') NOT NULL DEFAULT 'PENDING',
    requested_by INT NOT NULL,
    approved_by INT NULL,
    approved_at TIMESTAMP NULL,
    reject_reason TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_transfer_employee FOREIGN KEY (employee_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_transfer_old_dept FOREIGN KEY (old_department_id) REFERENCES departments(department_id) ON DELETE SET NULL,
    CONSTRAINT fk_transfer_old_pos FOREIGN KEY (old_position_id) REFERENCES positions(position_id) ON DELETE SET NULL,
    CONSTRAINT fk_transfer_old_role FOREIGN KEY (old_role_id) REFERENCES roles(role_id) ON DELETE SET NULL,
    CONSTRAINT fk_transfer_new_dept FOREIGN KEY (new_department_id) REFERENCES departments(department_id) ON DELETE CASCADE,
    CONSTRAINT fk_transfer_new_pos FOREIGN KEY (new_position_id) REFERENCES positions(position_id) ON DELETE CASCADE,
    CONSTRAINT fk_transfer_new_role FOREIGN KEY (new_role_id) REFERENCES roles(role_id) ON DELETE CASCADE,
    CONSTRAINT fk_transfer_requester FOREIGN KEY (requested_by) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_transfer_approver FOREIGN KEY (approved_by) REFERENCES users(user_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX IF NOT EXISTS idx_transfer_employee ON transfer_requests(employee_id);
CREATE INDEX IF NOT EXISTS idx_transfer_status ON transfer_requests(status);
