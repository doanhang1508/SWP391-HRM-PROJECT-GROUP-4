/* ================================================================
   MIGRATION: Tạo bảng timesheet_employee_confirmations
   
   Mô tả: Bảng lưu trạng thái xác nhận phiếu công của từng nhân viên
   theo tháng/năm. Nhân viên bấm "Xác nhận phiếu công" để xác nhận
   dữ liệu chấm công của mình là chính xác.
   
   Chạy TRỰC TIẾP trên database: HRM_System
   ================================================================ */

USE HRM_System;

CREATE TABLE IF NOT EXISTS `timesheet_employee_confirmations` (
    `id`            INT             NOT NULL AUTO_INCREMENT,
    `user_id`       INT             NOT NULL,
    `month`         INT             NOT NULL,
    `year`          INT             NOT NULL,
    `department_id` INT             NOT NULL,
    `status`        VARCHAR(20)     NOT NULL DEFAULT 'CONFIRMED',
    `confirmed_at`  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_user_month_year` (`user_id`, `month`, `year`),
    CONSTRAINT `fk_tec_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
    CONSTRAINT `fk_tec_dept` FOREIGN KEY (`department_id`) REFERENCES `departments` (`department_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
