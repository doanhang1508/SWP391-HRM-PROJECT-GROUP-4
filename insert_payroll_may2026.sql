-- ================================================================
-- INSERT bảng lương tháng 5/2026, status = Approved
-- Dữ liệu thực tế dựa trên bảng lương tháng 6/2026 (giảm ~5%)
-- approved_by = 2 (Nguyễn Văn Giám Đốc, roleId=2 / HR Manager)
-- ================================================================

-- Xóa nếu đã có 5/2026 (tránh duplicate key)
DELETE FROM payroll WHERE month = 5 AND year = 2026;

INSERT INTO payroll
    (user_id, month, year,
     base_salary, working_days, overtime_amount,
     allowance_amount, bonus_amount,
     deduction_amount, insurance_amount, tax_amount,
     gross_salary, net_salary,
     insurance_benefit, insurance_base_amount, taxable_income_base,
     status, approved_by, approved_at)
VALUES

-- user_id=2: Nguyễn Văn Giám Đốc
(2, 5, 2026,
 30000000.00, 22.0, 0.00,
 6930000.00, 1000000.00,
 0.00, 3727500.00, 195000.00,
 37930000.00, 34007500.00,
 0.00, 30000000.00, 14202500.00,
 'Approved', 2, '2026-06-05 09:00:00'),

-- user_id=3: Trần Thị Nhân Sự
(3, 5, 2026,
 15000000.00, 22.0, 0.00,
 3050000.00, 500000.00,
 0.00, 1732500.00, 0.00,
 18050000.00, 16817500.00,
 0.00, 15000000.00, 3817500.00,
 'Approved', 2, '2026-06-05 09:00:00'),

-- user_id=4: Lê Văn Quản Đốc
(4, 5, 2026,
 12000000.00, 22.0, 0.00,
 3000000.00, 500000.00,
 0.00, 1417500.00, 0.00,
 15500000.00, 14082500.00,
 0.00, 12000000.00, 2582500.00,
 'Approved', 2, '2026-06-05 09:00:00'),

-- user_id=5: Phạm Công Nhận
(5, 5, 2026,
 5000000.00, 22.0, 0.00,
 1171600.00, 500000.00,
 0.00, 525000.00, 0.00,
 6671600.00, 6146600.00,
 0.00, 5000000.00, 1146600.00,
 'Approved', 2, '2026-06-05 09:00:00'),

-- user_id=10: Đặng Thị Hồng
(10, 5, 2026,
 10000000.00, 21.0, 0.00,
 1100000.00, 500000.00,
 0.00, 1050000.00, 0.00,
 10600000.00, 9550000.00,
 0.00, 10000000.00, 550000.00,
 'Approved', 2, '2026-06-05 09:00:00'),

-- user_id=14: Phan Thị Khánh
(14, 5, 2026,
 20000000.00, 22.0, 0.00,
 2600000.00, 800000.00,
 0.00, 2205000.00, 0.00,
 23400000.00, 21195000.00,
 0.00, 20000000.00, 1195000.00,
 'Approved', 2, '2026-06-05 09:00:00'),

-- user_id=33: Nguyễn Thị Kế Toán
(33, 5, 2026,
 10000000.00, 22.0, 0.00,
 1171600.00, 500000.00,
 100000.00, 1050000.00, 0.00,
 11671600.00, 10521600.00,
 0.00, 10000000.00, 521600.00,
 'Paid', 2, '2026-06-05 09:00:00');

-- Kiểm tra kết quả
SELECT p.payroll_id, u.full_name, d.department_name,
       p.base_salary, p.net_salary, p.status, p.month, p.year
FROM payroll p
JOIN users u ON p.user_id = u.user_id
LEFT JOIN employee_profiles ep ON u.user_id = ep.user_id
LEFT JOIN departments d ON ep.department_id = d.department_id
WHERE p.month = 5 AND p.year = 2026
ORDER BY p.payroll_id;
