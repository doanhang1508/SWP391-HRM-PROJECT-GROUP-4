USE hrm_system;

DELIMITER //

DROP PROCEDURE IF EXISTS AssignAdminShiftToAll //

CREATE PROCEDURE AssignAdminShiftToAll(
    IN p_start_date DATE,
    IN p_end_date DATE
)
BEGIN
    DECLARE v_current_date DATE;
    SET v_current_date = p_start_date;

    WHILE v_current_date <= p_end_date DO

        -- Chỉ bỏ qua Chủ Nhật (1)
        IF DAYOFWEEK(v_current_date) != 1 THEN

            INSERT IGNORE INTO shift_assignments 
                (user_id, shift_id, assigned_date)
            SELECT user_id, 1, v_current_date
            FROM users
            WHERE status = 1;

            INSERT IGNORE INTO employee_shifts 
                (user_id, shift_id, work_date)
            SELECT user_id, 1, v_current_date
            FROM users
            WHERE status = 1;

        END IF;

        SET v_current_date = DATE_ADD(v_current_date, INTERVAL 1 DAY);

    END WHILE;

END //

DELIMITER ;

-- Thực thi việc gán ca hành chính từ 01/06/2026 đến 30/06/2026
CALL AssignAdminShiftToAll('2026-06-01', '2027-12-31');
