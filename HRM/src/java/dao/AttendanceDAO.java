package dao;

import model.Attendance;
import model.AttendanceClaim;
import model.TimesheetLock;
import util.DBContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.math.BigDecimal;

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
    public int bulkImportAttendance(List<Attendance> records) {
        String sql = "INSERT INTO attendance " +
                     "(user_id, shift_id, work_date, check_in, check_out, status, overtime_hrs, ot_reason, created_at) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW()) " +
                     "ON DUPLICATE KEY UPDATE " +
                     "shift_id=VALUES(shift_id), check_in=VALUES(check_in), check_out=VALUES(check_out), " +
                     "status=VALUES(status), overtime_hrs=VALUES(overtime_hrs), ot_reason=VALUES(ot_reason)";
        int successCount = 0;
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            conn.setAutoCommit(false);
            for (Attendance a : records) {
                ps.setInt(1, a.getUserId());
                ps.setInt(2, a.getShiftId());
                ps.setDate(3, a.getWorkDate());
                ps.setTime(4, a.getCheckIn());
                ps.setTime(5, a.getCheckOut());
                ps.setString(6, a.getStatus());
                ps.setDouble(7, a.getOvertimeHrs());
                ps.setString(8, a.getOtReason());
                ps.addBatch();
            }
            int[] results = ps.executeBatch();
            conn.commit();
            for (int r : results) {
                if (r > 0) successCount++;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return successCount;
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
                     "SUM(CASE WHEN status='PRESENT' THEN 1 ELSE 0 END) AS present_cnt, " +
                     "SUM(CASE WHEN status='LATE' THEN 1 ELSE 0 END) AS late_cnt, " +
                     "SUM(CASE WHEN status='ABSENT' THEN 1 ELSE 0 END) AS absent_cnt, " +
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
        String sql = "SELECT COUNT(*) FROM attendance WHERE user_id=? AND MONTH(work_date)=? AND YEAR(work_date)=? AND status IN ('Present', 'Late')";
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

    public double getPaidAttendanceDays(int userId, int month, int year) {
        String sql = "SELECT COALESCE(SUM(CASE WHEN status IN ('PRESENT','LATE') THEN 1 WHEN status='HALFDAY' THEN 0.5 ELSE 0 END), 0) " +
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
                     "SUM(CASE WHEN a.status='PRESENT' THEN 1 ELSE 0 END) AS present_cnt, " +
                     "SUM(CASE WHEN a.status='LATE' THEN 1 ELSE 0 END) AS late_cnt, " +
                     "SUM(CASE WHEN a.status='ABSENT' THEN 1 ELSE 0 END) AS absent_cnt, " +
                     "SUM(CASE WHEN a.overtime_hrs > 0 THEN 1 ELSE 0 END) AS ot_cnt, " +
                     "SUM(IFNULL(a.overtime_hrs, 0)) AS total_ot_hrs " +
                     "FROM users u " +
                     "LEFT JOIN employee_profiles ep ON u.user_id = ep.user_id " +
                     "LEFT JOIN departments d ON ep.department_id = d.department_id " +
                     "JOIN attendance a ON u.user_id = a.user_id AND MONTH(a.work_date)=? AND YEAR(a.work_date)=? " +
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

    public List<Attendance> getAllAttendance(int month, int year, Integer userId) {
        List<Attendance> list = new ArrayList<>();
        String sql = "SELECT a.*, u.full_name AS user_name, s.shift_name " +
                     "FROM attendance a " +
                     "JOIN users u ON a.user_id = u.user_id " +
                     "JOIN shifts s ON a.shift_id = s.shift_id " +
                     "WHERE MONTH(a.work_date) = ? AND YEAR(a.work_date) = ? ";
        if (userId != null) {
            sql += " AND a.user_id = ? ";
        }
        sql += "ORDER BY a.work_date DESC, u.full_name";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, month);
            ps.setInt(2, year);
            if (userId != null) {
                ps.setInt(3, userId);
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
}
