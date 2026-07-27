-- =============================================================
-- MIGRATION: Xóa user 27 (Nguyễn Thị Thai Sản) và bổ sung HĐ/Profile/Shift cho NV0021 (Ngô Văn Ốm)
-- Ngày: 2026-07-27
-- =============================================================

USE HRM_System;

SET FOREIGN_KEY_CHECKS = 0;

-- 1. XÓA USER 27 (Nguyễn Thị Thai Sản) VÀ CÁC DỮ LIỆU LIÊN QUAN
DELETE FROM leave_requests WHERE user_id = 27;
DELETE FROM attendance WHERE user_id = 27;
DELETE FROM shift_assignments WHERE user_id = 27;
DELETE FROM employee_shifts WHERE user_id = 27;
DELETE FROM employee_profiles WHERE user_id = 27;
DELETE FROM employee_contracts WHERE user_id = 27;
DELETE FROM users WHERE user_id = 27;

-- 2. CẬP NHẬT THÔNG TIN VÀ BỔ SUNG HỢP ĐỒNG / PROFILE CHO USER 21 (Ngô Văn Ốm)
UPDATE users 
SET department_id = 5, position_id = 9 
WHERE user_id = 21;

INSERT INTO employee_profiles 
    (user_id, department_id, id_card, dob, gender, address, hire_date, tax_code, social_insurance_no, bank_account, bank_name, contract_type_id, salary_grade_id, employment_status_id, education_level_id, dependent_count) 
VALUES 
    (21, 5, '001095000021', '1995-05-21', 1, 'Hà Nội', '2026-01-01', '8012345621', '0100001021', '190300021', 'Agribank', 2, 4, 2, 5, 0)
ON DUPLICATE KEY UPDATE 
    department_id = 5, contract_type_id = 2, salary_grade_id = 4, employment_status_id = 2;

INSERT INTO employee_contracts 
    (user_id, contract_type_id, position_id, department_id, salary_grade_id, start_date, end_date, base_salary, status) 
VALUES 
    (21, 2, 9, 5, 4, '2026-01-01', '2027-01-01', 5000000.00, 'Active')
ON DUPLICATE KEY UPDATE 
    department_id = 5, position_id = 9, base_salary = 5000000.00, status = 'Active';

-- 3. ĐẢM BẢO PHÂN CA CHO USER 21 (Gán ca hành chính shift_id = 1 từ 01/06/2026 đến 31/12/2027)
DROP PROCEDURE IF EXISTS AssignShiftForUser21;
DELIMITER //
CREATE PROCEDURE AssignShiftForUser21()
BEGIN
    DECLARE v_current_date DATE;
    SET v_current_date = '2026-06-01';

    WHILE v_current_date <= '2027-12-31' DO
        IF DAYOFWEEK(v_current_date) != 1 THEN
            INSERT IGNORE INTO shift_assignments (user_id, shift_id, assigned_date)
            VALUES (21, 1, v_current_date);

            INSERT IGNORE INTO employee_shifts (user_id, shift_id, work_date)
            VALUES (21, 1, v_current_date);
        END IF;
        SET v_current_date = DATE_ADD(v_current_date, INTERVAL 1 DAY);
    END WHILE;
END //
DELIMITER ;

CALL AssignShiftForUser21();
DROP PROCEDURE IF EXISTS AssignShiftForUser21;

-- 4. BỔ SUNG ĐƠN NGHỈ ỐM (leave_requests) CHO USER 21 (Ngô Văn Ốm) - tháng 7/2026
-- Nhóm 4 ngày SICK_LEAVE thành 2 đơn nghỉ liên tiếp (3-4/7 và 6-7/7)
-- approved_by = 3 (Trần Thị Nhân Sự - HR Manager, role_id=2)
INSERT INTO leave_requests (user_id, leave_type_id, start_date, end_date, total_days, reason, status, approved_by, created_at)
VALUES
    (21, 2, '2026-07-03', '2026-07-04', 2.0, 'Nghỉ ốm theo dữ liệu chấm công tháng 7', 'Approved', 3, NOW()),
    (21, 2, '2026-07-06', '2026-07-07', 2.0, 'Nghỉ ốm theo dữ liệu chấm công tháng 7', 'Approved', 3, NOW());

SET FOREIGN_KEY_CHECKS = 1;

