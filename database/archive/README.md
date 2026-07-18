# Archive — Migration Files (Đã gộp vào schema chính)

Thư mục này chỉ còn lại **tool script** dùng khi cần, không phải migration schema.

Toàn bộ file migration đã được hợp nhất vào `../HRM_database.sql` ngày **2026-07-18**.

**Không cần chạy bất kỳ file nào trong thư mục này** khi setup database mới —
chỉ cần chạy `HRM_database.sql` là đủ.

## File còn lại

| File | Mục đích |
|---|---|
| `reset_payroll_for_test.sql` | ⚠️ **Xóa toàn bộ data bảng payroll** để test lại. **KHÔNG chạy trên production!** |

## Danh sách migration đã gộp vào HRM_database.sql

| File | Nội dung |
|---|---|
| `payroll_workflow_migration.sql` | ENUM payroll status, cột approved_by/paid_by, role Accountant (id=8), user ke_toan_01 |
| `payroll_tax_insurance_fix_migration.sql` | Cột is_bhxh_applied, is_taxable (reward_disciplines); insurance_base_amount, taxable_income_base (payroll) |
| `migration_proc.sql` / `migration_simple.sql` / `payroll_migration_all_in_one.sql` | Cùng nội dung với file trên (các phiên bản thay thế) |
| `fix_reward_name_utf8.sql` | Cập nhật tên "Thưởng Năng suất" UTF-8 cho reward_disciplines id=9 |
| `resignation_migration.sql` | Tạo bảng resignation_requests (v1) |
| `resignation_v2_migration.sql` | ALTER employee_contracts thêm actual_end_date, termination_reason; ALTER resignation_requests thêm cột v2; tạo resignation_checklist; INSERT employment_statuses mới |
| `resignation_v3_migration.sql` | ENUM status thêm WITHDRAW_REQUESTED, WITHDRAWN; thêm previous_employment_status_id |
| `transfer_new_flow_migration.sql` | ENUM transfer status mới, cột employee_confirmed_at/manager_approved_by, FK, bảng transfer_request_allowances |
| `transfer_effective_date_migration.sql` | Thêm COMPLETED vào ENUM, cột applied_at, migrate data cũ APPROVED→COMPLETED |
| `holiday_auto_generation_migration.sql` | Cột mới holidays (holiday_year, rule_code, source, is_makeup_day); bảng holiday_rules + seed data |
| `leave_insurance_migration.sql` | Bảng leave_insurance_rates + loại nghỉ thai sản nam + seed tỉ lệ BHXH |
