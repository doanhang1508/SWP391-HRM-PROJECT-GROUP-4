-- =============================================================
-- MIGRATION: Loại bỏ nghỉ thai sản nam (leave_type_id = 6)
-- Ngày: 2026-07-23
-- Mô tả: Thai sản nam đã bị loại bỏ khỏi hệ thống HRM.
--        Không có leave_requests nào đang tham chiếu type_id = 6.
-- =============================================================

-- Bước 0: Kiểm tra trước khi xóa (kết quả phải = 0 để an toàn xóa)
SELECT COUNT(*) AS type6_request_count FROM leave_requests WHERE leave_type_id = 6;

-- Bước 1: Xóa rate của type 6 (không có FK từ leave_requests → leave_insurance_rates)
DELETE FROM leave_insurance_rates WHERE leave_type_id = 6;

-- Bước 2: Xóa leave_type_id = 6
-- (An toàn vì không có leave_requests tham chiếu — đã kiểm tra ở Bước 0)
DELETE FROM leave_types WHERE leave_type_id = 6;

-- Bước 3: Xác nhận
SELECT leave_type_id, type_name, status FROM leave_types ORDER BY leave_type_id;
SELECT leave_type_id, insurance_rate_percent FROM leave_insurance_rates ORDER BY leave_type_id;
