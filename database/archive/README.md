# Archive — Migration Files (Đã gộp vào schema chính)

Thư mục này lưu giữ các file migration cũ **chỉ để tham khảo lịch sử**.
Toàn bộ nội dung đã được hợp nhất vào `../HRM_database.sql` vào ngày **2026-07-06**.

**Không cần chạy các file trong thư mục này** khi setup database mới —
chỉ cần chạy `HRM_database.sql` là đủ.

## Danh sách file đã merge

| File | Nội dung | Merged vào HRM_database.sql |
|---|---|---|
| `resignation_migration.sql` | Tạo bảng `resignation_requests` (v1) | ✅ Đã gộp (phiên bản v2 đầy đủ hơn) |
| `resignation_v2_migration.sql` | ALTER `employee_contracts` thêm `actual_end_date`, `termination_reason`; ALTER `resignation_requests` thêm cột v2; tạo `resignation_checklist`, `exit_interviews`; INSERT employment_statuses mới | ✅ Đã gộp |
