USE HRM_System;
SET NAMES utf8mb4;
UPDATE reward_disciplines 
SET name = 'Thưởng Năng suất',
    description = 'Thưởng theo năng suất lao động, miễn BHXH và thuế TNCN'
WHERE id = 9;
SELECT id, name, is_bhxh_applied, is_taxable FROM reward_disciplines WHERE id = 9;
