-- Cập nhật bảng holidays
ALTER TABLE holidays
  ADD COLUMN holiday_year INT NULL AFTER holiday_date,
  ADD COLUMN rule_code VARCHAR(50) NULL AFTER holiday_year,
  ADD COLUMN source ENUM('AUTO','MANUAL') NOT NULL DEFAULT 'MANUAL' AFTER rule_code,
  ADD COLUMN is_makeup_day TINYINT(1) NOT NULL DEFAULT 0 AFTER source;

-- Cập nhật lại holiday_year cho các dữ liệu cũ đã có
UPDATE holidays SET holiday_year = YEAR(holiday_date) WHERE holiday_year IS NULL;

-- Sau đó đổi cột holiday_year thành NOT NULL
ALTER TABLE holidays MODIFY COLUMN holiday_year INT NOT NULL;

-- Tạo bảng holiday_rules
CREATE TABLE IF NOT EXISTS holiday_rules (
  rule_code       VARCHAR(50) PRIMARY KEY,
  rule_name       VARCHAR(150),
  calendar_type   ENUM('SOLAR','LUNAR'),
  ref_month       INT,
  ref_day         INT,
  day_offset      INT DEFAULT 0,
  ot_multiplier   DECIMAL(4,2) DEFAULT 3.00,
  active          TINYINT(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Seed data cho holiday_rules
INSERT INTO holiday_rules (rule_code, rule_name, calendar_type, ref_month, ref_day, day_offset, ot_multiplier, active) VALUES
('TET_DUONG_LICH', 'Tết Dương lịch', 'SOLAR', 1, 1, 0, 3.00, 1),
('TET_29', 'Tết Nguyên Đán (29 Tết)', 'LUNAR', 1, 1, -2, 3.00, 1),
('TET_30', 'Tết Nguyên Đán (30 Tết)', 'LUNAR', 1, 1, -1, 3.00, 1),
('TET_MUNG_1', 'Tết Nguyên Đán (Mùng 1)', 'LUNAR', 1, 1, 0, 3.00, 1),
('TET_MUNG_2', 'Tết Nguyên Đán (Mùng 2)', 'LUNAR', 1, 1, 1, 3.00, 1),
('TET_MUNG_3', 'Tết Nguyên Đán (Mùng 3)', 'LUNAR', 1, 1, 2, 3.00, 1),
('GIO_TO', 'Giỗ Tổ Hùng Vương', 'LUNAR', 3, 10, 0, 3.00, 1),
('GIAI_PHONG', 'Ngày Giải phóng miền Nam', 'SOLAR', 4, 30, 0, 3.00, 1),
('QUOC_TE_LAO_DONG', 'Ngày Quốc tế Lao động', 'SOLAR', 5, 1, 0, 3.00, 1),
('QUOC_KHANH_1', 'Quốc khánh (liền kề)', 'SOLAR', 9, 1, 0, 3.00, 1),
('QUOC_KHANH_2', 'Quốc khánh', 'SOLAR', 9, 2, 0, 3.00, 1)
ON DUPLICATE KEY UPDATE
    rule_name = VALUES(rule_name),
    calendar_type = VALUES(calendar_type),
    ref_month = VALUES(ref_month),
    ref_day = VALUES(ref_day),
    day_offset = VALUES(day_offset),
    ot_multiplier = VALUES(ot_multiplier);
