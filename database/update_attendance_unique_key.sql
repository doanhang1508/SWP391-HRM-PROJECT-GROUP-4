USE HRM_System;

-- Bổ sung UNIQUE KEY để ngăn việc import trùng dòng (user_id và work_date)
ALTER TABLE attendance 
ADD UNIQUE KEY uk_user_date (user_id, work_date);
