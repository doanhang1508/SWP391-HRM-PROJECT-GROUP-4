package dao;

import model.Attendance;
import model.AttendanceClaim;
import model.TimesheetLock;
import util.DBContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * AttendanceDAO - Xử lý tất cả thao tác DB liên quan đến:
 *  1. Import Attendance (bulk insert từ Excel)
 *  2. View Personal Attendance (lấy chấm công theo nhân viên)
 *  3. Submit/Resolve Attendance Claim (khiếu nại chấm công)
 *  4. Lock/Unlock Timesheet (khóa dữ liệu tháng)
 */
public class AttendanceDAO {

    // ═══════════════════════════════════════════════════
    // MODULE 13: IMPORT ATTENDANCE FILE
    // ═══════════════════════════════════════════════════

    /**
     * Bulk insert danh sách chấm công từ file Excel.
     * Dùng INSERT IGNORE để tránh duplicate (user_id + work_date + shift_id).
     *
     * @return số bản ghi đã insert thành công
     */
    /**
     * Bulk upsert danh sách chấm công từ file Excel (SQL Server MERGE).
     * @return int[]{insertCount, updateCount, unchangedCount}
     */
    /**
     * Bulk upsert danh sách chấm công từ file Excel (SQL Server MERGE).
     * @return int[]{insertCount, updateCount, unchangedCount, skippedTerminatedCount}
     * @throws Exception nếu có lỗi CSDL thực sự — KHÔNG được nuốt lỗi rồi trả về
     *         {0,0,0,0} như trước, vì controller sẽ hiểu nhầm là "import thành công".
     */
    public int[] bulkImportAttendance(List<Attendance> records) throws Exception {
        String sql = "INSERT INTO attendance " +
                     "  (user_id, shift_id, work_date, check_in, check_out, status, overtime_hrs, ot_reason, created_at) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW()) " +
                     "ON DUPLICATE KEY UPDATE " +
                     "  check_in = VALUES(check_in), check_out = VALUES(check_out), " +
                     "  status = VALUES(status), overtime_hrs = VALUES(overtime_hrs), " +
                     "  ot_reason = VALUES(ot_reason)";
        int insertCount = 0;
        int updateCount = 0;
        int unchangedCount = 0;
        int skippedTerminatedCount = 0;
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection()) {
            conn.setAutoCommit(false);
            try {
                // Lấy danh sách ngày làm việc cuối cùng của các nhân viên đã nghỉ (dựa vào hợp đồng)
                java.util.Map<Integer, java.sql.Date> lastWorkingDays = new java.util.HashMap<>();
                String lwSql = "SELECT user_id, MAX(actual_end_date) as max_end FROM employee_contracts WHERE status = 'Terminated' AND actual_end_date IS NOT NULL GROUP BY user_id";
                try (PreparedStatement psLw = conn.prepareStatement(lwSql);
                     ResultSet rsLw = psLw.executeQuery()) {
                    while (rsLw.next()) {
                        lastWorkingDays.put(rsLw.getInt("user_id"), rsLw.getDate("max_end"));
                    }
                }

                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    for (Attendance a : records) {
                        java.sql.Date lwd = lastWorkingDays.get(a.getUserId());
                        if (lwd != null && a.getWorkDate().after(lwd)) {
                            skippedTerminatedCount++;
                            continue; // Bỏ qua chấm công sau ngày nghỉ việc
                        }

                        ps.setInt(1, a.getUserId());
                        ps.setInt(2, a.getShiftId());
                        ps.setDate(3, a.getWorkDate());
                        ps.setTime(4, a.getCheckIn());
                        ps.setTime(5, a.getCheckOut());
                        ps.setString(6, a.getStatus());
                        ps.setDouble(7, a.getOvertimeHrs());
                        ps.setString(8, a.getOtReason());

                        int res = ps.executeUpdate();
                        if (res == 1) {
                            insertCount++;
                        } else if (res == 2) {
                            updateCount++;
                        } else {
                            // res == 0: MySQL trùng khóa (user_id + work_date) nhưng dữ liệu
                            // mới GIỐNG HỆT dữ liệu cũ nên không có gì để cập nhật. Bản ghi
                            // này đã tồn tại đúng như file import, KHÔNG PHẢI là lỗi/bị bỏ qua.
                            unchangedCount++;
                        }
                    }
                }
                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                e.printStackTrace();
                throw new Exception("Lỗi CSDL khi ghi dữ liệu chấm công: " + e.getMessage(), e);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw new Exception("Lỗi kết nối CSDL: " + e.getMessage(), e);
        }
        return new int[]{insertCount, updateCount, unchangedCount, skippedTerminatedCount};
    }


    /**
     * Kiểm tra tháng đó đã bị lock chưa trước khi import.
     */
    public boolean isMonthLocked(int month, int year) {
        String sql = "SELECT status FROM timesheet_lock WHERE month=? AND year=? AND status='LOCKED'";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, month);
            ps.setInt(2, year);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean isUserMonthLocked(int userId, int month, int year) {
        return isMonthLocked(month, year);
    }

    /**
     * Kiểm tra xem tháng này có đang được Admin/Quản lý CHỦ ĐỘNG mở khóa hay
     * không (status = 'UNLOCKED' trong timesheet_lock). Dùng để cho phép import
     * lại các tháng đã qua trong trường hợp cần chỉnh sửa hợp lệ.
     */
    public boolean isExplicitlyUnlocked(int month, int year) {
        String sql = "SELECT status FROM timesheet_lock WHERE month=? AND year=? AND status='UNLOCKED'";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, month);
            ps.setInt(2, year);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean isAttendanceLocked(int attendanceId) {
        String sql1 = "SELECT 1 FROM attendance a " +
                      "JOIN timesheet_lock tl ON MONTH(a.work_date) = tl.month AND YEAR(a.work_date) = tl.year " +
                      "WHERE a.attendance_id = ? AND tl.status = 'LOCKED'";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql1)) {
            ps.setInt(1, attendanceId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }


    // ═══════════════════════════════════════════════════
    // MODULE 14: VIEW PERSONAL ATTENDANCE
    // ═══════════════════════════════════════════════════

    /**
     * Lấy danh sách chấm công của nhân viên, lọc theo tháng/năm.
     */
    public List<Attendance> getAttendanceByUser(int userId, int month, int year) {
        List<Attendance> list = new ArrayList<>();
        String sql = "SELECT a.*, u.full_name AS user_name, s.shift_name " +
                     "FROM attendance a " +
                     "JOIN users u ON a.user_id = u.user_id " +
                     "JOIN shifts s ON a.shift_id = s.shift_id " +
                     "WHERE a.user_id = ? AND MONTH(a.work_date) = ? AND YEAR(a.work_date) = ? " +
                     "ORDER BY a.work_date DESC";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, month);
            ps.setInt(3, year);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapAttendanceRow(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Thống kê nhanh: tổng công, đi trễ, vắng mặt của nhân viên trong tháng.
     */
    public int[] getAttendanceSummary(int userId, int month, int year) {
        // returns [present, late, absent, overtime_days]
        String sql = "SELECT " +
                     "SUM(CASE WHEN UPPER(status) IN ('PRESENT', 'P', 'LEAVE') THEN 1 ELSE 0 END) AS present_cnt, " +
                     "SUM(CASE WHEN UPPER(status) IN ('LATE', 'T') THEN 1 ELSE 0 END) AS late_cnt, " +
                     "SUM(CASE WHEN UPPER(status) IN ('ABSENT', 'A') THEN 1 ELSE 0 END) AS absent_cnt, " +
                     "SUM(CASE WHEN overtime_hrs > 0 THEN 1 ELSE 0 END) AS ot_cnt " +
                     "FROM attendance WHERE user_id=? AND MONTH(work_date)=? AND YEAR(work_date)=?";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, month);
            ps.setInt(3, year);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new int[]{
                        rs.getInt("present_cnt"),
                        rs.getInt("late_cnt"),
                        rs.getInt("absent_cnt"),
                        rs.getInt("ot_cnt")
                    };
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return new int[]{0, 0, 0, 0};
    }

    // ═══════════════════════════════════════════════════
    // MODULE 15: SUBMIT ATTENDANCE CLAIM (Employee)
    // ═══════════════════════════════════════════════════

    /**
     * Tra cứu attendance_id từ mã nhân viên (username) và ngày làm việc.
     * Trả về -1 nếu không tìm thấy.
     */
    public int getAttendanceIdByUsernameAndDate(String username, Date workDate) {
        String sql = "SELECT a.attendance_id FROM attendance a " +
                     "JOIN users u ON a.user_id = u.user_id " +
                     "WHERE u.username = ? AND a.work_date = ?";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setDate(2, workDate);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("attendance_id");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    /**
     * Tra cứu attendance_id từ userId và ngày làm việc (dùng cho user đã đăng nhập).
     * Trả về -1 nếu không tìm thấy.
     */
    public int getAttendanceIdByUserIdAndDate(int userId, Date workDate) {
        String sql = "SELECT attendance_id FROM attendance WHERE user_id = ? AND work_date = ?";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setDate(2, workDate);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("attendance_id");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    /**
     * Nhân viên nộp đơn khiếu nại chấm công.
     */
    public boolean submitClaim(AttendanceClaim claim) {

        String sql = "INSERT INTO attendance_claims " +
                     "(attendance_id, user_id, work_date, claim_type, description, status, created_at) " +
                     "VALUES (?, ?, ?, ?, ?, 'PENDING', NOW())";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, claim.getAttendanceId());
            ps.setInt(2, claim.getUserId());
            ps.setDate(3, claim.getWorkDate());
            ps.setString(4, claim.getClaimType());
            ps.setString(5, claim.getDescription());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Lấy danh sách claim của một nhân viên.
     */
    public List<AttendanceClaim> getClaimsByUser(int userId) {
        List<AttendanceClaim> list = new ArrayList<>();
        String sql = "SELECT ac.*, " +
                     "a.status AS current_status, " +
                     "s.shift_name, " +
                     "resolver.full_name AS resolver_name " +
                     "FROM attendance_claims ac " +
                     "LEFT JOIN attendance a ON ac.attendance_id = a.attendance_id " +
                     "LEFT JOIN shifts s ON a.shift_id = s.shift_id " +
                     "LEFT JOIN users resolver ON ac.resolved_by = resolver.user_id " +
                     "WHERE ac.user_id = ? " +
                     "ORDER BY ac.created_at DESC";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapClaimRow(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Kiểm tra nhân viên đã có claim pending cho attendance_id chưa.
     */
    public boolean hasPendingClaim(int attendanceId) {
        String sql = "SELECT 1 FROM attendance_claims WHERE attendance_id=? AND status='PENDING'";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, attendanceId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ═══════════════════════════════════════════════════
    // MODULE 16: RESOLVE ATTENDANCE CLAIM (HR)
    // ═══════════════════════════════════════════════════

    /**
     * Lấy tất cả claims (HR view), lọc theo status.
     */
    public List<AttendanceClaim> getAllClaims(String statusFilter) {
        List<AttendanceClaim> list = new ArrayList<>();
        String sql = "SELECT ac.*, " +
                     "u.full_name AS user_name, d.department_name AS user_dept, " +
                     "a.status AS current_status, " +
                     "s.shift_name, " +
                     "resolver.full_name AS resolver_name " +
                     "FROM attendance_claims ac " +
                     "JOIN users u ON ac.user_id = u.user_id " +
                     "LEFT JOIN employee_profiles ep ON u.user_id = ep.user_id " +
                     "LEFT JOIN departments d ON ep.department_id = d.department_id " +
                     "LEFT JOIN attendance a ON ac.attendance_id = a.attendance_id " +
                     "LEFT JOIN shifts s ON a.shift_id = s.shift_id " +
                     "LEFT JOIN users resolver ON ac.resolved_by = resolver.user_id " +
                     (statusFilter != null && !statusFilter.isEmpty() ? "WHERE ac.status = ? " : "") +
                     "ORDER BY ac.created_at DESC";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (statusFilter != null && !statusFilter.isEmpty()) {
                ps.setString(1, statusFilter);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapClaimRow(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy 1 claim theo claim_id. Dùng để lấy user_id gửi thông báo sau khi resolve.
     */
    public AttendanceClaim getClaimById(int claimId) {
        String sql = "SELECT ac.*, " +
                     "u.full_name AS user_name, d.department_name AS user_dept, " +
                     "a.status AS current_status, " +
                     "s.shift_name, " +
                     "resolver.full_name AS resolver_name " +
                     "FROM attendance_claims ac " +
                     "JOIN users u ON ac.user_id = u.user_id " +
                     "LEFT JOIN employee_profiles ep ON u.user_id = ep.user_id " +
                     "LEFT JOIN departments d ON ep.department_id = d.department_id " +
                     "LEFT JOIN attendance a ON ac.attendance_id = a.attendance_id " +
                     "LEFT JOIN shifts s ON a.shift_id = s.shift_id " +
                     "LEFT JOIN users resolver ON ac.resolved_by = resolver.user_id " +
                     "WHERE ac.claim_id = ?";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, claimId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapClaimRow(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * HR approve hoặc reject claim, đồng thời cập nhật attendance nếu approve.
     * @param correctedCheckIn  Giờ vào sửa (có thể null)
     * @param correctedCheckOut Giờ ra sửa (có thỉ null)
     */
    public boolean resolveClaim(int claimId, String decision, String hrNote,
                                 int resolvedBy, String newStatus,
                                 Time correctedCheckIn, Time correctedCheckOut) {
        DBContext dbContext = new DBContext();
        Connection conn = null;
        try {
            conn = dbContext.getConnection();
            conn.setAutoCommit(false);

            // 1. Cập nhật claim
            String updateClaim = "UPDATE attendance_claims SET status=?, hr_note=?, " +
                                  "resolved_by=?, resolved_at=NOW() WHERE claim_id=? AND status='PENDING'";
            int updated = 0;
            try (PreparedStatement ps = conn.prepareStatement(updateClaim)) {
                ps.setString(1, decision);
                ps.setString(2, hrNote);
                ps.setInt(3, resolvedBy);
                ps.setInt(4, claimId);
                updated = ps.executeUpdate();
            }

            // Nếu không có row nào được update (claim đã resolved hoặc không tồn tại)
            if (updated == 0) {
                conn.rollback();
                return false;
            }

            // 2. Nếu APPROVED và có điều chỉnh → cập nhật attendance
            if ("APPROVED".equals(decision)) {
                String getAttId = "SELECT attendance_id FROM attendance_claims WHERE claim_id=?";
                int attendanceId = -1;
                try (PreparedStatement ps = conn.prepareStatement(getAttId)) {
                    ps.setInt(1, claimId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) attendanceId = rs.getInt("attendance_id");
                    }
                }

                if (attendanceId > 0) {
                    // Xây dựng câu UPDATE động theo những gì có
                    StringBuilder sb = new StringBuilder("UPDATE attendance SET ");
                    List<Object> params = new ArrayList<>();

                    if (newStatus != null && !newStatus.isEmpty()) {
                        sb.append("status=?, ");
                        params.add(newStatus);
                    }
                    if (correctedCheckIn != null) {
                        sb.append("check_in=?, ");
                        params.add(correctedCheckIn);
                    }
                    if (correctedCheckOut != null) {
                        sb.append("check_out=?, ");
                        params.add(correctedCheckOut);
                    }

                    if (!params.isEmpty()) {
                        // Xóa dấu phẩy cuối
                        String sql = sb.toString().replaceAll(",\\s*$", "") + " WHERE attendance_id=?";
                        params.add(attendanceId);
                        try (PreparedStatement ps = conn.prepareStatement(sql)) {
                            for (int i = 0; i < params.size(); i++) {
                                Object p = params.get(i);
                                if (p instanceof String)  ps.setString(i + 1, (String) p);
                                else if (p instanceof Time) ps.setTime(i + 1, (Time) p);
                                else if (p instanceof Integer) ps.setInt(i + 1, (Integer) p);
                            }
                            ps.executeUpdate();
                        }
                    }
                }
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
        return false;
    }

    // ═══════════════════════════════════════════════════
    // MODULE 17: LOCK TIMESHEET DATA (HR)
    // ═══════════════════════════════════════════════════

    /**
     * Lấy danh sách trạng thái lock của các tháng.
     */
    public List<TimesheetLock> getAllLocks() {
        List<TimesheetLock> list = new ArrayList<>();
        String sql = "SELECT tl.*, u.full_name AS locked_by_name " +
                     "FROM timesheet_lock tl " +
                     "LEFT JOIN users u ON tl.locked_by = u.user_id " +
                     "ORDER BY tl.year DESC, tl.month DESC";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    TimesheetLock tl = new TimesheetLock();
                    tl.setLockId(rs.getInt("lock_id"));
                    tl.setMonth(rs.getInt("month"));
                    tl.setYear(rs.getInt("year"));
                    tl.setStatus(rs.getString("status"));
                    tl.setLockedBy(rs.getInt("locked_by"));
                    tl.setLockedAt(rs.getTimestamp("locked_at"));
                    tl.setNote(rs.getString("note"));
                    tl.setLockedByName(rs.getString("locked_by_name"));
                    list.add(tl);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lock tháng: INSERT hoặc UPDATE trạng thái LOCKED.
     */
    public boolean lockMonth(int month, int year, int lockedBy, String note) {
        String sql = "INSERT INTO timesheet_lock (month, year, status, locked_by, locked_at, note) " +
                     "VALUES (?, ?, 'LOCKED', ?, NOW(), ?) " +
                     "ON DUPLICATE KEY UPDATE status='LOCKED', locked_by=?, locked_at=NOW(), note=?";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, month);
            ps.setInt(2, year);
            ps.setInt(3, lockedBy);
            ps.setString(4, note);
            ps.setInt(5, lockedBy);
            ps.setString(6, note);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Unlock tháng: cho phép chỉnh sửa lại.
     */
    public boolean unlockMonth(int month, int year) {
        String sql = "UPDATE timesheet_lock SET status='UNLOCKED' WHERE month=? AND year=?";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, month);
            ps.setInt(2, year);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Đếm số bản ghi attendance trong tháng (để hiển thị summary trước khi lock).
     */
    public int countAttendanceInMonth(int month, int year) {
        String sql = "SELECT COUNT(*) FROM attendance WHERE MONTH(work_date)=? AND YEAR(work_date)=?";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, month);
            ps.setInt(2, year);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ═══════════════════════════════════════════════════
    // PRIVATE HELPERS
    // ═══════════════════════════════════════════════════

    private Attendance mapAttendanceRow(ResultSet rs) throws SQLException {
        Attendance a = new Attendance();
        a.setAttendanceId(rs.getInt("attendance_id"));
        a.setUserId(rs.getInt("user_id"));
        a.setShiftId(rs.getInt("shift_id"));
        a.setWorkDate(rs.getDate("work_date"));
        a.setCheckIn(rs.getTime("check_in"));
        a.setCheckOut(rs.getTime("check_out"));
        a.setStatus(rs.getString("status"));
        a.setOvertimeHrs(rs.getDouble("overtime_hrs"));
        a.setOtReason(rs.getString("ot_reason"));
        a.setCreatedAt(rs.getTimestamp("created_at"));
        try { a.setUserName(rs.getString("user_name")); } catch (SQLException ignored) {}
        try { a.setShiftName(rs.getString("shift_name")); } catch (SQLException ignored) {}
        return a;
    }

    private AttendanceClaim mapClaimRow(ResultSet rs) throws SQLException {
        AttendanceClaim c = new AttendanceClaim();
        c.setClaimId(rs.getInt("claim_id"));
        c.setAttendanceId(rs.getInt("attendance_id"));
        c.setUserId(rs.getInt("user_id"));
        c.setWorkDate(rs.getDate("work_date"));
        c.setClaimType(rs.getString("claim_type"));
        c.setDescription(rs.getString("description"));
        c.setStatus(rs.getString("status"));
        c.setHrNote(rs.getString("hr_note"));
        c.setResolvedBy(rs.getInt("resolved_by"));
        c.setResolvedAt(rs.getTimestamp("resolved_at"));
        c.setCreatedAt(rs.getTimestamp("created_at"));
        try { c.setUserName(rs.getString("user_name")); } catch (SQLException ignored) {}
        try { c.setUserDept(rs.getString("user_dept")); } catch (SQLException ignored) {}
        try { c.setShiftName(rs.getString("shift_name")); } catch (SQLException ignored) {}
        try { c.setCurrentStatus(rs.getString("current_status")); } catch (SQLException ignored) {}
        try { c.setResolverName(rs.getString("resolver_name")); } catch (SQLException ignored) {}
        return c;
    }

    public int getPresentDays(int employeeId, int month, int year) {
        String sql = "SELECT COUNT(*) FROM attendance WHERE user_id=? AND MONTH(work_date)=? AND YEAR(work_date)=? AND status IN ('Present', 'Late', 'PRESENT', 'LATE', 'T', 'P')";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, employeeId);
            ps.setInt(2, month);
            ps.setInt(3, year);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public static class MonthYearOption {
        private int month;
        private int year;
        
        public MonthYearOption(int month, int year) {
            this.month = month;
            this.year = year;
        }
        
        public int getMonth() { return month; }
        public int getYear() { return year; }
    }

    public List<MonthYearOption> getAvailableAttendancePeriods() {
        List<MonthYearOption> list = new ArrayList<>();
        String sql = "SELECT DISTINCT MONTH(work_date) AS month, YEAR(work_date) AS year FROM attendance ORDER BY year DESC, month DESC";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new MonthYearOption(rs.getInt("month"), rs.getInt("year")));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy danh sách kỳ (tháng/năm) có dữ liệu chấm công của một nhân viên cụ thể,
     * sắp xếp mới nhất trước.
     */
    public List<MonthYearOption> getPeriodsForUser(int userId) {
        List<MonthYearOption> list = new ArrayList<>();
        String sql = "SELECT DISTINCT MONTH(work_date) AS month, YEAR(work_date) AS year " +
                     "FROM attendance WHERE user_id=? ORDER BY year DESC, month DESC";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new MonthYearOption(rs.getInt("month"), rs.getInt("year")));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }


    public boolean hasAttendanceData(int month, int year) {
        String sql = "SELECT COUNT(*) FROM attendance WHERE MONTH(work_date)=? AND YEAR(work_date)=?";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, month);
            ps.setInt(2, year);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * @deprecated Dùng {@link #getPaidAttendanceDayMap(int, int, int)} thay thế để tránh
     *             đếm trùng ngày khi kết hợp với dữ liệu nghỉ phép có lương.
     */
    @Deprecated
    public double getPaidAttendanceDays(int userId, int month, int year) {
        String sql = "SELECT COALESCE(SUM(CASE WHEN UPPER(status) IN ('PRESENT', 'LATE', 'P', 'T') THEN 1 WHEN UPPER(status)='HALFDAY' THEN 0.5 ELSE 0 END), 0) " +
                     "FROM attendance WHERE user_id=? AND MONTH(work_date)=? AND YEAR(work_date)=?";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, month);
            ps.setInt(3, year);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0.0;
    }

    /**
     * Trả về Map ngày → giá trị công (1.0 hoặc 0.5) cho các ngày chấm công hợp lệ
     * trong tháng/năm chỉ định của nhân viên.
     * <p>
     * Thay thế {@link #getPaidAttendanceDays} để có thể hợp (union) với tập ngày nghỉ phép
     * có lương mà không bị đếm trùng khi 1 ngày xuất hiện trong cả 2 bảng.
     * </p>
     *
     * @param userId user_id của nhân viên
     * @param month  tháng cần tính (1–12)
     * @param year   năm cần tính
     * @return Map&lt;LocalDate, Double&gt; với key là ngày làm việc, value là 1.0 (Present/Late/P/T) hoặc 0.5 (HalfDay)
     */
    public Map<LocalDate, Double> getPaidAttendanceDayMap(int userId, int month, int year) {
        // Lấy từng bản ghi riêng lẻ (theo work_date) thay vì SUM tổng, để giữ được
        // thông tin ngày cụ thể dùng cho bước hợp tập với leave.
        // Chỉ tính những ngày thuộc lịch làm việc chính thức (shift_assignments)
        // và phải có đầy đủ check_in / check_out (tránh tính trùng ngày OT chủ nhật/ngày nghỉ).
        // Loại Chủ nhật (DAYOFWEEK=1) và ngày lễ active khỏi ngày công hưởng lương.
        // - Chủ nhật: không thuộc lịch làm việc bình thường.
        // - Ngày lễ: không nằm trong standardWorkDays (đã trừ ở mẫu số).
        // Cả hai loại ngày này nếu nhân viên có đi làm thì chỉ tính tiền OT riêng.
        String sql = "SELECT a.work_date, UPPER(a.status) AS status " +
                     "FROM attendance a " +
                     "JOIN shift_assignments sa ON sa.user_id = a.user_id AND sa.assigned_date = a.work_date " +
                     "WHERE a.user_id=? AND MONTH(a.work_date)=? AND YEAR(a.work_date)=? " +
                     "  AND ( " +
                     "    (UPPER(a.status) IN ('PRESENT','LATE','P','T','HALFDAY') AND a.check_in IS NOT NULL AND a.check_out IS NOT NULL) " +
                     "    OR (UPPER(a.status) = 'LEAVE') " +
                     "  ) " +
                     "  AND DAYOFWEEK(a.work_date) <> 1 " +
                     "  AND NOT EXISTS (" +
                     "      SELECT 1 FROM holidays h " +
                     "      WHERE h.holiday_date = a.work_date AND h.status = 1" +
                     "  )";
        Map<LocalDate, Double> dayMap = new HashMap<>();
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, month);
            ps.setInt(3, year);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    LocalDate workDate = rs.getDate("work_date").toLocalDate();
                    String status     = rs.getString("status");
                    double value      = "HALFDAY".equals(status) ? 0.5 : 1.0;
                    // Nếu 1 ngày có nhiều bản ghi (trường hợp data lỗi), ưu tiên giá trị lớn hơn
                    dayMap.merge(workDate, value, Math::max);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return dayMap;
    }

    public List<Integer> getUserIdsWithAttendance(int month, int year) {
        List<Integer> list = new ArrayList<>();
        String sql = "SELECT DISTINCT user_id FROM attendance WHERE MONTH(work_date)=? AND YEAR(work_date)=?";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, month);
            ps.setInt(2, year);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(rs.getInt("user_id"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public BigDecimal getTotalOvertimeHoursFromAttendance(int userId, int month, int year) {
        String sql = "SELECT COALESCE(SUM(overtime_hrs), 0) FROM attendance WHERE user_id=? AND MONTH(work_date)=? AND YEAR(work_date)=?";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, month);
            ps.setInt(3, year);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getBigDecimal(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return BigDecimal.ZERO;
    }

    public List<model.AttendanceSummary> getAttendanceSummaryAllUsers(int month, int year) {
        List<model.AttendanceSummary> list = new ArrayList<>();
        String sql = "SELECT u.user_id, u.full_name AS user_name, d.department_name, " +
                     "SUM(CASE WHEN UPPER(a.status) IN ('PRESENT', 'P', 'LEAVE') THEN 1 ELSE 0 END) AS present_cnt, " +
                     "SUM(CASE WHEN UPPER(a.status) IN ('LATE', 'T') THEN 1 ELSE 0 END) AS late_cnt, " +
                     "SUM(CASE WHEN UPPER(a.status) IN ('ABSENT', 'A') THEN 1 ELSE 0 END) AS absent_cnt, " +
                     "SUM(CASE WHEN a.overtime_hrs > 0 THEN 1 ELSE 0 END) AS ot_cnt, " +
                     "SUM(IFNULL(a.overtime_hrs, 0)) AS total_ot_hrs " +
                     "FROM users u " +
                     "LEFT JOIN employee_profiles ep ON u.user_id = ep.user_id " +
                     "LEFT JOIN departments d ON ep.department_id = d.department_id " +
                     "LEFT JOIN attendance a ON u.user_id = a.user_id AND MONTH(a.work_date)=? AND YEAR(a.work_date)=? " +
                     "GROUP BY u.user_id, u.full_name, d.department_name " +
                     "ORDER BY u.full_name";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, month);
            ps.setInt(2, year);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    model.AttendanceSummary s = new model.AttendanceSummary();
                    s.setUserId(rs.getInt("user_id"));
                    s.setUserName(rs.getString("user_name"));
                    s.setDepartment(rs.getString("department_name"));
                    s.setPresentCount(rs.getInt("present_cnt"));
                    s.setLateCount(rs.getInt("late_cnt"));
                    s.setAbsentCount(rs.getInt("absent_cnt"));
                    s.setOvertimeCount(rs.getInt("ot_cnt"));
                    s.setTotalOvertimeHrs(rs.getDouble("total_ot_hrs"));
                    list.add(s);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public model.AttendanceSummary getAttendanceSummaryForUser(int userId, int month, int year) {
        DBContext dbContext = new DBContext();
        boolean hasActivity = false;

        // 1. Check attendance records
        String checkAttSql = "SELECT COUNT(*) FROM attendance WHERE user_id=? AND MONTH(work_date)=? AND YEAR(work_date)=?";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(checkAttSql)) {
            ps.setInt(1, userId);
            ps.setInt(2, month);
            ps.setInt(3, year);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    hasActivity = true;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        // 2. Check overtime assignments
        if (!hasActivity) {
            String checkOtSql = "SELECT COUNT(*) FROM overtime_assignments oa "
                              + "JOIN overtime_plans op ON oa.plan_id = op.plan_id "
                              + "WHERE oa.user_id=? AND MONTH(op.target_date)=? AND YEAR(op.target_date)=?";
            try (Connection conn = dbContext.getConnection();
                 PreparedStatement ps = conn.prepareStatement(checkOtSql)) {
                ps.setInt(1, userId);
                ps.setInt(2, month);
                ps.setInt(3, year);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        hasActivity = true;
                    }
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

        // 3. Check shift assignments (covers manager-scheduled shifts/OT from "Xếp lịch ca",
        // which writes to shift_assignments and was previously never checked here)
        if (!hasActivity) {
            String checkShiftSql = "SELECT COUNT(*) FROM shift_assignments sa "
                                 + "WHERE sa.user_id=? AND MONTH(sa.assigned_date)=? AND YEAR(sa.assigned_date)=?";
            try (Connection conn = dbContext.getConnection();
                 PreparedStatement ps = conn.prepareStatement(checkShiftSql)) {
                ps.setInt(1, userId);
                ps.setInt(2, month);
                ps.setInt(3, year);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        hasActivity = true;
                    }
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

        if (!hasActivity) {
            return null; // Return null to trigger fallback in the controller for historical/future months with absolutely no data
        }


        model.AttendanceSummary s = new model.AttendanceSummary();
        s.setUserId(userId);
        s.setPresentCount(0);
        s.setLateCount(0);
        s.setAbsentCount(0);
        s.setOvertimeCount(0);
        s.setTotalOvertimeHrs(0.0);
        s.setScheduledOvertimeHrs(0.0);

        // Fetch actual attendance stats
        String sql = "SELECT " +
                     "SUM(CASE WHEN UPPER(status) IN ('PRESENT', 'P', 'LATE', 'T', 'LEAVE') THEN 1 ELSE 0 END) AS present_cnt, " +
                     "SUM(CASE WHEN UPPER(status) IN ('LATE', 'T') THEN 1 ELSE 0 END) AS late_cnt, " +
                     "SUM(CASE WHEN UPPER(status) IN ('ABSENT', 'A') THEN 1 ELSE 0 END) AS absent_cnt, " +
                     "SUM(CASE WHEN overtime_hrs > 0 THEN 1 ELSE 0 END) AS ot_cnt, " +
                     "SUM(IFNULL(overtime_hrs, 0)) AS total_ot_hrs " +
                     "FROM attendance WHERE user_id=? AND MONTH(work_date)=? AND YEAR(work_date)=? ";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, month);
            ps.setInt(3, year);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    s.setPresentCount(rs.getInt("present_cnt"));
                    s.setLateCount(rs.getInt("late_cnt"));
                    s.setAbsentCount(rs.getInt("absent_cnt"));
                    s.setOvertimeCount(rs.getInt("ot_cnt"));
                    s.setTotalOvertimeHrs(rs.getDouble("total_ot_hrs"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        // Fetch scheduled OT hours (from shift_assignments where coefficient > 1.0 AND overtime_assignments where status = 'Pending')
        double scheduledHrs = 0.0;

        // 1. Shift assignments
        String shiftOtSql = "SELECT COALESCE(SUM(TIME_TO_SEC(TIMEDIFF(s.end_time, s.start_time)) / 3600.0), 0) AS shift_ot_hrs " +
                            "FROM shift_assignments sa " +
                            "JOIN shifts s ON sa.shift_id = s.shift_id " +
                            "WHERE sa.user_id = ? AND MONTH(sa.assigned_date) = ? AND YEAR(sa.assigned_date) = ? " +
                            "AND s.coefficient > 1.0";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(shiftOtSql)) {
            ps.setInt(1, userId);
            ps.setInt(2, month);
            ps.setInt(3, year);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    scheduledHrs += rs.getDouble("shift_ot_hrs");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        // 2. Overtime assignments (Pending status)
        String pendingOtSql = "SELECT COALESCE(SUM(oa.assigned_hours), 0) AS pending_ot_hrs " +
                              "FROM overtime_assignments oa " +
                              "JOIN overtime_plans op ON oa.plan_id = op.plan_id " +
                              "WHERE oa.user_id = ? AND MONTH(op.target_date) = ? AND YEAR(op.target_date) = ? " +
                              "AND oa.status = 'Pending'";
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(pendingOtSql)) {
            ps.setInt(1, userId);
            ps.setInt(2, month);
            ps.setInt(3, year);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    scheduledHrs += rs.getDouble("pending_ot_hrs");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        s.setScheduledOvertimeHrs(scheduledHrs);
        return s;
    }

    public int[] getLatestAttendanceMonthAndYear(int userId) {
        String sql = "SELECT d FROM ("
                   + "  SELECT work_date AS d FROM attendance WHERE user_id = ? "
                   + "  UNION "
                   + "  SELECT op.target_date AS d FROM overtime_assignments oa JOIN overtime_plans op ON oa.plan_id = op.plan_id WHERE oa.user_id = ? "
                   + "  UNION "
                   + "  SELECT sa.assigned_date AS d FROM shift_assignments sa WHERE sa.user_id = ? "
                   + ") AS combined WHERE d IS NOT NULL ORDER BY d DESC LIMIT 1";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, userId);
            ps.setInt(3, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    java.sql.Date d = rs.getDate("d");
                    if (d != null) {
                        java.time.LocalDate ld = d.toLocalDate();
                        return new int[]{ld.getMonthValue(), ld.getYear()};
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }


    public List<Attendance> getAllAttendance(int month, int year, String userName, java.sql.Date workDate) {
        List<Attendance> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT a.*, u.full_name AS user_name, s.shift_name " +
            "FROM attendance a " +
            "JOIN users u ON a.user_id = u.user_id " +
            "JOIN shifts s ON a.shift_id = s.shift_id " +
            "WHERE MONTH(a.work_date) = ? AND YEAR(a.work_date) = ? "
        );
        
        if (userName != null && !userName.trim().isEmpty()) {
            sql.append(" AND u.full_name LIKE ? ");
        }
        if (workDate != null) {
            sql.append(" AND a.work_date = ? ");
        }
        
        sql.append("ORDER BY a.work_date DESC, u.full_name");
        
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            ps.setInt(1, month);
            ps.setInt(2, year);
            
            int paramIndex = 3;
            if (userName != null && !userName.trim().isEmpty()) {
                ps.setString(paramIndex++, "%" + userName.trim() + "%");
            }
            if (workDate != null) {
                ps.setDate(paramIndex++, workDate);
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapAttendanceRow(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countAllAttendance(int month, int year, String userName, java.sql.Date workDate) {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) FROM attendance a " +
            "JOIN users u ON a.user_id = u.user_id " +
            "WHERE MONTH(a.work_date) = ? AND YEAR(a.work_date) = ? " +
            "AND u.role_id NOT IN (1, 4) "
        );
        
        if (userName != null && !userName.trim().isEmpty()) {
            sql.append(" AND u.full_name LIKE ? ");
        }
        if (workDate != null) {
            sql.append(" AND a.work_date = ? ");
        }
        
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            ps.setInt(1, month);
            ps.setInt(2, year);
            
            int paramIndex = 3;
            if (userName != null && !userName.trim().isEmpty()) {
                ps.setString(paramIndex++, "%" + userName.trim() + "%");
            }
            if (workDate != null) {
                ps.setDate(paramIndex++, workDate);
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public List<Attendance> getAllAttendancePaginated(int month, int year, String userName, java.sql.Date workDate, int offset, int limit) {
        List<Attendance> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT a.*, u.full_name AS user_name, s.shift_name " +
            "FROM attendance a " +
            "JOIN users u ON a.user_id = u.user_id " +
            "JOIN shifts s ON a.shift_id = s.shift_id " +
            "WHERE MONTH(a.work_date) = ? AND YEAR(a.work_date) = ? " +
            "AND u.role_id NOT IN (1, 4) "
        );
        
        if (userName != null && !userName.trim().isEmpty()) {
            sql.append(" AND u.full_name LIKE ? ");
        }
        if (workDate != null) {
            sql.append(" AND a.work_date = ? ");
        }
        
        sql.append("ORDER BY a.work_date DESC, u.full_name LIMIT ? OFFSET ?");
        
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            ps.setInt(1, month);
            ps.setInt(2, year);
            
            int paramIndex = 3;
            if (userName != null && !userName.trim().isEmpty()) {
                ps.setString(paramIndex++, "%" + userName.trim() + "%");
            }
            if (workDate != null) {
                ps.setDate(paramIndex++, workDate);
            }
            
            ps.setInt(paramIndex++, limit);
            ps.setInt(paramIndex++, offset);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapAttendanceRow(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }


    public List<Attendance> getAttendanceByDepartment(int month, int year, int departmentId) {
        List<Attendance> list = new ArrayList<>();
        String sql = "SELECT a.*, u.full_name AS user_name, s.shift_name " +
                     "FROM attendance a " +
                     "JOIN users u ON a.user_id = u.user_id " +
                     "JOIN shifts s ON a.shift_id = s.shift_id " +
                     "WHERE MONTH(a.work_date) = ? AND YEAR(a.work_date) = ? AND u.department_id = ? " +
                     "ORDER BY a.work_date DESC, u.full_name";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, month);
            ps.setInt(2, year);
            ps.setInt(3, departmentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapAttendanceRow(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * HR cập nhật trực tiếp bản ghi chấm công
     */
    public boolean updateAttendanceHR(int attendanceId, Time checkIn, Time checkOut, String status, double overtimeHrs) {
        String sql = "UPDATE attendance SET check_in = ?, check_out = ?, status = ?, overtime_hrs = ? WHERE attendance_id = ?";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setTime(1, checkIn);
            ps.setTime(2, checkOut);
            ps.setString(3, status);
            ps.setDouble(4, overtimeHrs);
            ps.setInt(5, attendanceId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public int countAttendanceSummaryAllUsers(int month, int year) {
        String sql = "SELECT COUNT(DISTINCT u.user_id) " +
                     "FROM users u " +
                     "JOIN attendance a ON u.user_id = a.user_id AND MONTH(a.work_date)=? AND YEAR(a.work_date)=? " +
                     "WHERE u.role_id NOT IN (1, 4) AND u.department_id IS NOT NULL";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, month);
            ps.setInt(2, year);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public List<model.AttendanceSummary> getAttendanceSummaryAllUsersPaginated(int month, int year, int offset, int limit) {
        List<model.AttendanceSummary> list = new ArrayList<>();
        // sick_day_cnt: SUM(total_days) của đơn nghỉ ốm (leave_type_id=2) đã Approved.
        // Dùng SUM(total_days) thay COUNT(*) vì 1 đơn có thể nhiều ngày (ví dụ 08/06-09/06 = 2 ngày).
        // Điều kiện overlap: đơn có start_date <= cuối tháng AND end_date >= đầu tháng
        // → bắt đúng cả đơn bắt đầu tháng trước, kết thúc trong tháng này.
        String sql = "SELECT u.user_id, u.full_name AS user_name, d.department_name, " +
                     "SUM(CASE WHEN UPPER(a.status) IN ('PRESENT', 'P', 'LEAVE') THEN 1 ELSE 0 END) AS present_cnt, " +
                     "SUM(CASE WHEN UPPER(a.status) IN ('LATE', 'T') THEN 1 ELSE 0 END) AS late_cnt, " +
                     "SUM(CASE WHEN UPPER(a.status) IN ('ABSENT', 'A') THEN 1 ELSE 0 END) AS absent_cnt, " +
                     "SUM(CASE WHEN a.overtime_hrs > 0 THEN 1 ELSE 0 END) AS ot_cnt, " +
                     "SUM(IFNULL(a.overtime_hrs, 0)) AS total_ot_hrs, " +
                     "IFNULL(sk.sick_day_cnt, 0) AS sick_day_cnt " +
                     "FROM users u " +
                     "LEFT JOIN employee_profiles ep ON u.user_id = ep.user_id " +
                     "LEFT JOIN departments d ON ep.department_id = d.department_id " +
                     "JOIN attendance a ON u.user_id = a.user_id AND MONTH(a.work_date)=? AND YEAR(a.work_date)=? " +
                     "LEFT JOIN ( " +
                     "  SELECT user_id, CAST(SUM(total_days) AS SIGNED) AS sick_day_cnt " +
                     "  FROM leave_requests " +
                     "  WHERE leave_type_id = 2 AND status = 'Approved' " +
                     "    AND start_date <= LAST_DAY(CONCAT(?, '-', LPAD(?, 2, '0'), '-01')) " +
                     "    AND end_date   >= CONCAT(?, '-', LPAD(?, 2, '0'), '-01') " +
                     "  GROUP BY user_id " +
                     ") sk ON sk.user_id = u.user_id " +
                     "WHERE u.role_id NOT IN (1, 4) " +
                     "GROUP BY u.user_id, u.full_name, d.department_name, sk.sick_day_cnt " +
                     "ORDER BY u.full_name LIMIT ? OFFSET ?";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, month);
            ps.setInt(2, year);
            // params cho LAST_DAY và ngày đầu tháng trong subquery
            ps.setInt(3, year);
            ps.setInt(4, month);
            ps.setInt(5, year);
            ps.setInt(6, month);
            ps.setInt(7, limit);
            ps.setInt(8, offset);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    model.AttendanceSummary s = new model.AttendanceSummary();
                    s.setUserId(rs.getInt("user_id"));
                    s.setUserName(rs.getString("user_name"));
                    s.setDepartment(rs.getString("department_name"));
                    s.setPresentCount(rs.getInt("present_cnt"));
                    s.setLateCount(rs.getInt("late_cnt"));
                    s.setAbsentCount(rs.getInt("absent_cnt"));
                    s.setOvertimeCount(rs.getInt("ot_cnt"));
                    s.setTotalOvertimeHrs(rs.getDouble("total_ot_hrs"));
                    s.setSickDayCount(rs.getInt("sick_day_cnt"));
                    list.add(s);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ═══════════════════════════════════════════════════════════════
    // Phase 2B — OT 3-level rate engine
    // ═══════════════════════════════════════════════════════════════

    /**
     * Hằng số bội số OT theo loại ngày (Bộ Luật Lao động Việt Nam).
     *   NORMAL_WORKING_DAY  = 150%  (ngày làm việc bình thường theo lịch)
     *   WEEKLY_REST_DAY     = 200%  (ngày nghỉ theo tuần, không nằm trong shift plan)
     *   HOLIDAY / 5/1 etc.  = 300%  (ngày lễ — đọc từ bảng holidays.ot_multiplier)
     */
    private static final BigDecimal OT_MULTIPLIER_NORMAL       = new BigDecimal("1.5");
    private static final BigDecimal OT_MULTIPLIER_WEEKLY_REST  = new BigDecimal("2.0");
    private static final BigDecimal OT_MULTIPLIER_HOLIDAY_DEFAULT = new BigDecimal("3.0");

    /**
     * Phân loại loại ngày của 1 ngày cụ thể theo thứ tự ưu tiên:
     *   1. Nếu ngày thuộc bảng holidays (status=1) → "HOLIDAY"
     *   2. Nếu ngày có trong shift_assignments của nhân viên → "NORMAL"
     *   3. Còn lại → "WEEKLY_REST" (ngày nghỉ cuối tuần, lễ không chính thức)
     *
     * @param conn   Connection đang dùng (cùng transaction)
     * @param userId ID nhân viên
     * @param date   Ngày cần phân loại
     * @return "HOLIDAY", "NORMAL", hoặc "WEEKLY_REST"
     */
    private String resolveWorkDayType(Connection conn, int userId, java.sql.Date date) throws SQLException {
        // 1. Kiểm tra ngày lễ active → HOLIDAY (ưu tiên cao nhất)
        String sqlH = "SELECT 1 FROM holidays WHERE holiday_date = ? AND status = 1 LIMIT 1";
        try (PreparedStatement ps = conn.prepareStatement(sqlH)) {
            ps.setDate(1, date);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return "HOLIDAY";
            }
        }

        // 2. Kiểm tra Chủ nhật → WEEKLY_REST
        //    Phải kiểm tra TẠI ĐÂY (trước bước 3) để tránh Chủ nhật có shift_assignment
        //    bị phân loại nhầm là NORMAL.
        java.time.LocalDate localDate = date.toLocalDate();
        if (localDate.getDayOfWeek() == java.time.DayOfWeek.SUNDAY) {
            return "WEEKLY_REST";
        }

        // 3. Kiểm tra roster (shift_assignments = nguồn lịch làm việc chính thức)
        String sqlS = "SELECT 1 FROM shift_assignments WHERE user_id = ? AND assigned_date = ? LIMIT 1";
        try (PreparedStatement ps = conn.prepareStatement(sqlS)) {
            ps.setInt(1, userId);
            ps.setDate(2, date);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return "NORMAL";
            }
        }

        // 4. Không xác định được loại ngày → UNKNOWN
        //    Trường hợp này xảy ra khi dữ liệu thiếu shift_assignment cho một ngày thường.
        //    Không tự động áp hệ số 200% (WEEKLY_REST) vì có thể dữ liệu sai.
        System.err.println("[OT-WARN] userId=" + userId + " date=" + date
                + " → Không tìm thấy shift_assignment và không phải holiday/Sunday."
                + " Phân loại UNKNOWN — bỏ qua khi tính OT. Kiểm tra lại dữ liệu phân ca.");
        return "UNKNOWN";
    }

    /**
     * Trả về bội số OT dựa trên loại ngày và multiplier cấu hình từ holidays table.
     *
     * @param workDayType       "HOLIDAY" | "NORMAL" | "WEEKLY_REST" | "UNKNOWN"
     * @param holidayMultiplier ot_multiplier từ bảng holidays (null nếu không phải holiday)
     * @return BigDecimal bội số OT; trả về ZERO nếu UNKNOWN (bỏ qua, không tính OT sai)
     */
    private BigDecimal resolveOvertimeMultiplier(String workDayType, BigDecimal holidayMultiplier) {
        return switch (workDayType) {
            case "HOLIDAY"     -> (holidayMultiplier != null && holidayMultiplier.compareTo(BigDecimal.ZERO) > 0)
                                   ? holidayMultiplier
                                   : OT_MULTIPLIER_HOLIDAY_DEFAULT;
            case "WEEKLY_REST" -> OT_MULTIPLIER_WEEKLY_REST;
            case "UNKNOWN"     -> BigDecimal.ZERO;  // Dữ liệu thiếu — không tính OT để tránh sai hệ số
            default            -> OT_MULTIPLIER_NORMAL;  // "NORMAL"
        };
    }

    /**
     * Tính tổng tiền OT tháng với 3 mức bội số theo loại ngày.
     *
     * Thay thế phiên bản cũ chỉ phân biệt holiday/non-holiday.
     * Phiên bản mới:
     *   - HOLIDAY      → ot_multiplier từ bảng holidays (mặc định 3.0)
     *   - WEEKLY_REST  → 2.0 (ngày nghỉ tuần không được phân ca)
     *   - NORMAL       → normalMultiplier (truyền vào, mặc định 1.5)
     *
     * Nguồn giờ OT: attendance.overtime_hrs (có thể được sync từ overtime_assignments sau khi approve).
     *
     * @param userId           ID nhân viên
     * @param month            Tháng cần tính
     * @param year             Năm cần tính
     * @param hourlyRate       Lương 1 giờ = baseSalary / (standardWorkDays * 8)
     * @param normalMultiplier Bội số ngày làm việc bình thường (truyền 1.5)
     */
    public BigDecimal getOvertimeAmountWithHolidayRate(
            int userId, int month, int year,
            BigDecimal hourlyRate, BigDecimal normalMultiplier) {

        if (hourlyRate == null || hourlyRate.compareTo(BigDecimal.ZERO) <= 0) {
            return BigDecimal.ZERO;
        }

        // Query attendance kèm holiday multiplier (để tránh query lặp lại)
        String sql = "SELECT a.work_date, a.overtime_hrs, h.ot_multiplier "
                   + "FROM attendance a "
                   + "LEFT JOIN holidays h ON h.holiday_date = a.work_date AND h.status = 1 "
                   + "WHERE a.user_id = ? AND MONTH(a.work_date) = ? AND YEAR(a.work_date) = ? "
                   + "AND a.overtime_hrs > 0";

        BigDecimal totalAmount = BigDecimal.ZERO;
        DBContext dbContext = new DBContext();

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setInt(2, month);
            ps.setInt(3, year);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BigDecimal overtimeHrs = rs.getBigDecimal("overtime_hrs");
                    if (overtimeHrs == null || overtimeHrs.compareTo(BigDecimal.ZERO) <= 0) continue;

                    java.sql.Date workDate   = rs.getDate("work_date");
                    BigDecimal holidayMulti  = rs.getBigDecimal("ot_multiplier"); // null nếu không phải holiday

                    // Phân loại ngày và xác định bội số OT
                    // holidayMulti != null → chắc chắn là ngày lễ (đã JOIN được)
                    String dayType;
                    if (holidayMulti != null) {
                        dayType = "HOLIDAY";
                    } else {
                        // Phân loại tiếp: NORMAL vs WEEKLY_REST qua roster
                        dayType = resolveWorkDayType(conn, userId, workDate);
                    }

                    BigDecimal multiplier = resolveOvertimeMultiplier(dayType, holidayMulti);
                    BigDecimal dailyOt    = overtimeHrs.multiply(hourlyRate).multiply(multiplier);
                    totalAmount           = totalAmount.add(dailyOt);

                    System.out.printf("[OT-CALC] userId=%d date=%s type=%-12s hrs=%.2f rate=%.2f × %.1f = %.2f%n",
                        userId, workDate, dayType,
                        overtimeHrs.doubleValue(), hourlyRate.doubleValue(),
                        multiplier.doubleValue(), dailyOt.doubleValue());
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return totalAmount.setScale(2, java.math.RoundingMode.HALF_UP);
    }

    public static class OvertimeBreakdownItem {
        private String type;
        private double hours;
        private BigDecimal multiplier;
        private BigDecimal amount;

        public OvertimeBreakdownItem(String type, double hours, BigDecimal multiplier, BigDecimal amount) {
            this.type = type;
            this.hours = hours;
            this.multiplier = multiplier;
            this.amount = amount;
        }

        public String getType() { return type; }
        public double getHours() { return hours; }
        public BigDecimal getMultiplier() { return multiplier; }
        public BigDecimal getAmount() { return amount; }
    }

    /**
     * Lấy chi tiết tăng ca chia theo 3 loại ngày (ngày thường, ngày nghỉ tuần, ngày lễ).
     */
    public List<OvertimeBreakdownItem> getOvertimeBreakdown(int userId, int month, int year, BigDecimal hourlyRate) {
        List<OvertimeBreakdownItem> list = new ArrayList<>();
        if (hourlyRate == null || hourlyRate.compareTo(BigDecimal.ZERO) <= 0) {
            return list;
        }

        String sql = "SELECT a.work_date, a.overtime_hrs, h.ot_multiplier "
                   + "FROM attendance a "
                   + "LEFT JOIN holidays h ON h.holiday_date = a.work_date AND h.status = 1 "
                   + "WHERE a.user_id = ? AND MONTH(a.work_date) = ? AND YEAR(a.work_date) = ? "
                   + "AND a.overtime_hrs > 0";

        double normalHrs = 0;
        BigDecimal normalAmt = BigDecimal.ZERO;

        double weeklyRestHrs = 0;
        BigDecimal weeklyRestAmt = BigDecimal.ZERO;

        double holidayHrs = 0;
        BigDecimal holidayAmt = BigDecimal.ZERO;
        BigDecimal holidayMultiplier = new BigDecimal("3.0"); // mặc định 3.0

        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setInt(2, month);
            ps.setInt(3, year);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BigDecimal overtimeHrs = rs.getBigDecimal("overtime_hrs");
                    if (overtimeHrs == null || overtimeHrs.compareTo(BigDecimal.ZERO) <= 0) continue;

                    java.sql.Date workDate   = rs.getDate("work_date");
                    BigDecimal holidayMulti  = rs.getBigDecimal("ot_multiplier");

                    String dayType;
                    if (holidayMulti != null) {
                        dayType = "HOLIDAY";
                    } else {
                        dayType = resolveWorkDayType(conn, userId, workDate);
                    }

                    BigDecimal multiplier = resolveOvertimeMultiplier(dayType, holidayMulti);
                    BigDecimal dailyOt    = overtimeHrs.multiply(hourlyRate).multiply(multiplier);

                    if ("HOLIDAY".equals(dayType)) {
                        holidayHrs += overtimeHrs.doubleValue();
                        holidayAmt = holidayAmt.add(dailyOt);
                        if (holidayMulti != null) holidayMultiplier = holidayMulti;
                    } else if ("WEEKLY_REST".equals(dayType)) {
                        weeklyRestHrs += overtimeHrs.doubleValue();
                        weeklyRestAmt = weeklyRestAmt.add(dailyOt);
                    } else {
                        normalHrs += overtimeHrs.doubleValue();
                        normalAmt = normalAmt.add(dailyOt);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        if (normalHrs > 0) {
            list.add(new OvertimeBreakdownItem("NORMAL", normalHrs, new BigDecimal("1.5"), normalAmt.setScale(2, java.math.RoundingMode.HALF_UP)));
        }
        if (weeklyRestHrs > 0) {
            list.add(new OvertimeBreakdownItem("WEEKLY_REST", weeklyRestHrs, new BigDecimal("2.0"), weeklyRestAmt.setScale(2, java.math.RoundingMode.HALF_UP)));
        }
        if (holidayHrs > 0) {
            list.add(new OvertimeBreakdownItem("HOLIDAY", holidayHrs, holidayMultiplier, holidayAmt.setScale(2, java.math.RoundingMode.HALF_UP)));
        }

        return list;
    }

    public int countAdvancedAttendanceSummary(int month, int year, Integer departmentId) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM users u " +
                     "LEFT JOIN employee_profiles ep ON u.user_id = ep.user_id " +
                     "WHERE u.role_id NOT IN (1, 4)");
        
        if (departmentId != null) {
            sql.append(" AND COALESCE(ep.department_id, u.department_id) = ?");
        }

        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            if (departmentId != null) {
                ps.setInt(1, departmentId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public List<model.AttendanceSummary> getAdvancedAttendanceSummary(int month, int year, Integer departmentId, int offset, int limit) {
        List<model.AttendanceSummary> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT u.user_id, u.full_name AS user_name, d.department_name, ");
        // Actual Work Days
        sql.append("SUM(CASE WHEN UPPER(a.status) IN ('P', 'PRESENT', 'L', 'LATE', 'T', 'LEAVE') ")
           .append("AND DAYOFWEEK(a.work_date) != 1 AND h.holiday_date IS NULL THEN 1 ELSE 0 END) AS actual_work_days, ");
        // Late Count
        sql.append("SUM(CASE WHEN UPPER(a.status) IN ('L', 'LATE', 'T') THEN 1 ELSE 0 END) AS late_cnt, ");
        // Regular OT
        sql.append("SUM(CASE WHEN DAYOFWEEK(a.work_date) != 1 AND h.holiday_date IS NULL THEN IFNULL(a.overtime_hrs, 0) ELSE 0 END) AS regular_ot_hrs, ");
        // Sunday OT
        sql.append("SUM(CASE WHEN DAYOFWEEK(a.work_date) = 1 AND h.holiday_date IS NULL THEN IFNULL(a.overtime_hrs, 0) ELSE 0 END) AS sunday_ot_hrs, ");
        // Holiday OT
        sql.append("SUM(CASE WHEN h.holiday_date IS NOT NULL THEN IFNULL(a.overtime_hrs, 0) ELSE 0 END) AS holiday_ot_hrs, ");
        // Leaves
        // Excel imports carry leave codes on each attendance day.  Prefer this
        // month-specific data when it is present, otherwise retain approved leave requests.
        sql.append("GREATEST(IFNULL(lv.annual_leave_days, 0), SUM(CASE WHEN UPPER(a.status) IN ('LEAVE', 'ANNUAL_LEAVE') THEN 1 ELSE 0 END)) AS annual_leave_days, ");
        sql.append("GREATEST(IFNULL(lv.sick_leave_days, 0), SUM(CASE WHEN UPPER(a.status) = 'SICK_LEAVE' THEN 1 ELSE 0 END)) AS sick_leave_days, ");
        sql.append("GREATEST(IFNULL(lv.maternity_leave_days, 0), SUM(CASE WHEN UPPER(a.status) = 'MATERNITY_LEAVE' THEN 1 ELSE 0 END)) AS maternity_leave_days, ");
        // Remaining Annual Leave
        sql.append("IFNULL(MAX_LV.max_days, 12) - GREATEST(IFNULL(ytd_lv.used_annual_leave_days, 0), IFNULL(att_ytd_lv.used_annual_leave_days, 0)) AS remaining_annual_leave ");
        
        sql.append("FROM users u ");
        sql.append("LEFT JOIN employee_profiles ep ON u.user_id = ep.user_id ");
        sql.append("LEFT JOIN departments d ON d.department_id = COALESCE(ep.department_id, u.department_id) ");
        sql.append("LEFT JOIN attendance a ON u.user_id = a.user_id AND MONTH(a.work_date) = ? AND YEAR(a.work_date) = ? ");
        sql.append("LEFT JOIN holidays h ON a.work_date = h.holiday_date AND h.status = 1 ");
        
        sql.append("LEFT JOIN ( ")
           .append("  SELECT user_id, ")
           .append("         SUM(CASE WHEN leave_type_id = 1 THEN total_days ELSE 0 END) AS annual_leave_days, ")
           .append("         SUM(CASE WHEN leave_type_id = 2 THEN total_days ELSE 0 END) AS sick_leave_days, ")
           .append("         SUM(CASE WHEN leave_type_id IN (3, 6) THEN total_days ELSE 0 END) AS maternity_leave_days ")
           .append("  FROM leave_requests ")
           .append("  WHERE status IN ('Approved', 'Pending') ")
           .append("    AND MONTH(start_date) = ? AND YEAR(start_date) = ? ")
           .append("  GROUP BY user_id ")
           .append(") lv ON u.user_id = lv.user_id ");
           
        sql.append("LEFT JOIN ( ")
           .append("  SELECT user_id, SUM(total_days) AS used_annual_leave_days ")
           .append("  FROM leave_requests ")
           .append("  WHERE leave_type_id = 1 AND status IN ('Approved', 'Pending') ")
           .append("    AND YEAR(start_date) = ? ")
           .append("  GROUP BY user_id ")
           .append(") ytd_lv ON u.user_id = ytd_lv.user_id ");

        sql.append("LEFT JOIN ( ")
           .append("  SELECT user_id, COUNT(*) AS used_annual_leave_days ")
           .append("  FROM attendance ")
           .append("  WHERE UPPER(status) IN ('LEAVE', 'ANNUAL_LEAVE') AND YEAR(work_date) = ? ")
           .append("  GROUP BY user_id ")
           .append(") att_ytd_lv ON u.user_id = att_ytd_lv.user_id ");
           
        sql.append("CROSS JOIN (SELECT IFNULL((SELECT max_days_per_year FROM leave_types WHERE leave_type_id = 1), 12) AS max_days) AS MAX_LV ");

        sql.append("WHERE u.role_id NOT IN (1, 4) ");
        if (departmentId != null) {
            sql.append(" AND COALESCE(ep.department_id, u.department_id) = ? ");
        }
        
        sql.append("GROUP BY u.user_id, u.full_name, d.department_name, lv.annual_leave_days, lv.sick_leave_days, lv.maternity_leave_days, ytd_lv.used_annual_leave_days, att_ytd_lv.used_annual_leave_days, MAX_LV.max_days ");
        sql.append("ORDER BY u.full_name LIMIT ? OFFSET ?");

        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            int paramIndex = 1;
            ps.setInt(paramIndex++, month);
            ps.setInt(paramIndex++, year);
            ps.setInt(paramIndex++, month);
            ps.setInt(paramIndex++, year);
            ps.setInt(paramIndex++, year); // for YTD leave
            ps.setInt(paramIndex++, year); // for imported attendance leave

            if (departmentId != null) {
                ps.setInt(paramIndex++, departmentId);
            }
            
            ps.setInt(paramIndex++, limit);
            ps.setInt(paramIndex++, offset);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    model.AttendanceSummary s = new model.AttendanceSummary();
                    s.setUserId(rs.getInt("user_id"));
                    s.setUserName(rs.getString("user_name"));
                    s.setDepartment(rs.getString("department_name"));
                    
                    s.setActualWorkDays(rs.getDouble("actual_work_days"));
                    s.setLateCount(rs.getInt("late_cnt"));
                    s.setRegularOtHrs(rs.getDouble("regular_ot_hrs"));
                    s.setSundayOtHrs(rs.getDouble("sunday_ot_hrs"));
                    s.setHolidayOtHrs(rs.getDouble("holiday_ot_hrs"));
                    s.setAnnualLeaveDays(rs.getDouble("annual_leave_days"));
                    s.setSickLeaveDays(rs.getDouble("sick_leave_days"));
                    s.setMaternityLeaveDays(rs.getDouble("maternity_leave_days"));
                    s.setRemainingAnnualLeave(rs.getDouble("remaining_annual_leave"));
                    
                    list.add(s);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}
