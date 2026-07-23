-- ============================================================================
-- SCRIPT: XÓA DỮ LIỆU CHẤM CÔNG & RESET TRẠNG THÁI KHÓA/DUYỆT BẢNG CÔNG
-- Ngày cập nhật: 2026-07-23
-- Mô tả: File SQL dùng để xóa sạch toàn bộ dữ liệu chấm công VÀ reset toàn bộ 
--        trạng thái duyệt/khóa bảng công (timesheet locks & confirmations)
--        đưa quy trình chấm công trở về trạng thái ban đầu để re-import.
-- WARNING: Hãy cân nhắc trước khi chạy trên môi trường chính thức!
-- ============================================================================

USE HRM_System;

-- Tắt Safe Update mode để có thể thực thi câu lệnh xóa/cập nhật không dùng PK
SET SQL_SAFE_UPDATES = 0;

-- ----------------------------------------------------------------------------
-- BƯỚC 1: XÓA DỮ LIỆU CHẤM CÔNG CHI TIẾT
-- ----------------------------------------------------------------------------
-- Xóa toàn bộ dữ liệu chấm công chi tiết (bảng attendance_claims tự xóa theo nhờ CASCADE)
DELETE FROM attendance;
ALTER TABLE attendance AUTO_INCREMENT = 1;

-- Xóa dữ liệu khiếu nại chấm công nếu còn
DELETE FROM attendance_claims;
ALTER TABLE attendance_claims AUTO_INCREMENT = 1;


-- ----------------------------------------------------------------------------
-- BƯỚC 2: XÓA DỮ LIỆU DUYỆT BẢNG CÔNG CÁ NHÂN VÀ PHÒNG BAN
-- ----------------------------------------------------------------------------
-- 2.1. Xóa toàn bộ xác nhận công cá nhân của nhân viên
DELETE FROM timesheet_employee_confirmations;
ALTER TABLE timesheet_employee_confirmations AUTO_INCREMENT = 1;

-- 2.2. Xóa toàn bộ dữ liệu trạng thái duyệt công phòng ban (trạng thái "Đã duyệt cuối")
DELETE FROM timesheet_confirmations;
ALTER TABLE timesheet_confirmations AUTO_INCREMENT = 1;


-- ----------------------------------------------------------------------------
-- BƯỚC 3: XÓA/RESET TRẠNG THÁI KHÓA BẢNG CÔNG (TIMESHEET LOCK)
-- ----------------------------------------------------------------------------
-- Xóa toàn bộ bản ghi khóa công (trạng thái "Đã khóa công")
DELETE FROM timesheet_lock;
ALTER TABLE timesheet_lock AUTO_INCREMENT = 1;


-- ----------------------------------------------------------------------------
-- LỰA CHỌN KHÁC: NẾU CHỈ MUỐN XÓA / RESET RIÊNG THÁNG 7 / 2026
-- (Bỏ comment các câu lệnh bên dưới nếu bạn CHỈ muốn xóa dữ liệu Tháng 7/2026)
-- ----------------------------------------------------------------------------
/*
-- 1. Xóa chấm công tháng 7/2026
DELETE FROM attendance WHERE MONTH(work_date) = 7 AND YEAR(work_date) = 2026;

-- 2. Xóa xác nhận công cá nhân tháng 7/2026
DELETE FROM timesheet_employee_confirmations WHERE month = 7 AND year = 2026;

-- 3. Xóa duyệt công phòng ban tháng 7/2026
DELETE FROM timesheet_confirmations WHERE month = 7 AND year = 2026;

-- 4. Xóa khóa công tháng 7/2026
DELETE FROM timesheet_lock WHERE month = 7 AND year = 2026;
*/


-- Bật lại Safe Update mode sau khi thực hiện
SET SQL_SAFE_UPDATES = 1;


-- ----------------------------------------------------------------------------
-- VERIFY: Kiểm tra số lượng bản ghi còn lại sau khi reset
-- ----------------------------------------------------------------------------
SELECT COUNT(*) AS remaining_attendance FROM attendance;
SELECT COUNT(*) AS remaining_emp_confirmations FROM timesheet_employee_confirmations;
SELECT COUNT(*) AS remaining_dept_confirmations FROM timesheet_confirmations;
SELECT COUNT(*) AS remaining_timesheet_locks FROM timesheet_lock;
