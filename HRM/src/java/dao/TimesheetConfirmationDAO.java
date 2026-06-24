package dao;

import model.Attendance;
import model.TimesheetConfirmation;
import model.Department;
import util.DBContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TimesheetConfirmationDAO {

    public List<TimesheetConfirmation> getConfirmationsByPeriod(int month, int year) {
        List<TimesheetConfirmation> list = new ArrayList<>();
        String sql = "SELECT tc.*, d.department_name, u1.full_name AS created_by_name, u2.full_name AS updated_by_name " +
                     "FROM timesheet_confirmations tc " +
                     "JOIN departments d ON tc.department_id = d.department_id " +
                     "LEFT JOIN users u1 ON tc.created_by = u1.user_id " +
                     "LEFT JOIN users u2 ON tc.updated_by = u2.user_id " +
                     "WHERE tc.month = ? AND tc.year = ? " +
                     "ORDER BY d.department_name";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, month);
            ps.setInt(2, year);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public TimesheetConfirmation getConfirmationByPeriodAndDept(int month, int year, int deptId) {
        String sql = "SELECT tc.*, d.department_name, u1.full_name AS created_by_name, u2.full_name AS updated_by_name " +
                     "FROM timesheet_confirmations tc " +
                     "JOIN departments d ON tc.department_id = d.department_id " +
                     "LEFT JOIN users u1 ON tc.created_by = u1.user_id " +
                     "LEFT JOIN users u2 ON tc.updated_by = u2.user_id " +
                     "WHERE tc.month = ? AND tc.year = ? AND tc.department_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, month);
            ps.setInt(2, year);
            ps.setInt(3, deptId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public TimesheetConfirmation getConfirmationById(int id) {
        String sql = "SELECT tc.*, d.department_name, u1.full_name AS created_by_name, u2.full_name AS updated_by_name " +
                     "FROM timesheet_confirmations tc " +
                     "JOIN departments d ON tc.department_id = d.department_id " +
                     "LEFT JOIN users u1 ON tc.created_by = u1.user_id " +
                     "LEFT JOIN users u2 ON tc.updated_by = u2.user_id " +
                     "WHERE tc.id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean insert(TimesheetConfirmation tc) {
        String sql = "INSERT INTO timesheet_confirmations (month, year, department_id, status, created_by, created_at, updated_by) " +
                     "VALUES (?, ?, ?, ?, ?, NOW(), ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, tc.getMonth());
            ps.setInt(2, tc.getYear());
            ps.setInt(3, tc.getDepartmentId());
            ps.setString(4, tc.getStatus());
            ps.setInt(5, tc.getCreatedBy());
            ps.setInt(6, tc.getCreatedBy());
            boolean success = ps.executeUpdate() > 0;
            if (success) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        tc.setId(rs.getInt(1));
                    }
                }
            }
            return success;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateStatus(int id, String status, int userId, String rejectReason) {
        String sql = "UPDATE timesheet_confirmations SET status = ?, updated_by = ?, updated_at = NOW(), reject_reason = ? WHERE id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, userId);
            if (rejectReason != null) {
                ps.setString(3, rejectReason);
            } else {
                ps.setNull(3, Types.VARCHAR);
            }
            ps.setInt(4, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<String> getUnapprovedDepartments(int month, int year) {
        List<String> list = new ArrayList<>();
        String sql = "SELECT d.department_name " +
                     "FROM (" +
                     "    SELECT DISTINCT u.department_id " +
                     "    FROM attendance a " +
                     "    JOIN users u ON a.user_id = u.user_id " +
                     "    WHERE MONTH(a.work_date) = ? AND YEAR(a.work_date) = ? " +
                     "      AND u.department_id IS NOT NULL" +
                     ") dept_att " +
                     "JOIN departments d ON dept_att.department_id = d.department_id " +
                     "LEFT JOIN timesheet_confirmations tc " +
                     "  ON tc.month = ? " +
                     " AND tc.year = ? " +
                     " AND tc.department_id = dept_att.department_id " +
                     " AND (tc.status = 'HR_MANAGER_APPROVED' OR tc.status = 'LOCKED') " +
                     "WHERE tc.id IS NULL";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, month);
            ps.setInt(2, year);
            ps.setInt(3, month);
            ps.setInt(4, year);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(rs.getString("department_name"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean isEmployeeConfirmed(int userId, int month, int year) {
        String sql = "SELECT 1 FROM timesheet_employee_confirmations WHERE user_id = ? AND month = ? AND year = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, month);
            ps.setInt(3, year);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean confirmEmployeeTimesheet(int userId, int month, int year, int deptId) {
        String sql = "INSERT INTO timesheet_employee_confirmations (user_id, month, year, department_id, status, confirmed_at) " +
                     "VALUES (?, ?, ?, ?, 'CONFIRMED', NOW()) " +
                     "ON DUPLICATE KEY UPDATE status = 'CONFIRMED', confirmed_at = NOW()";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, month);
            ps.setInt(3, year);
            ps.setInt(4, deptId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean haveAllEmployeesConfirmed(int month, int year, int deptId) {
        String sqlTotal = "SELECT COUNT(DISTINCT u.user_id) FROM users u " +
                          "JOIN attendance a ON u.user_id = a.user_id " +
                          "WHERE u.department_id = ? AND MONTH(a.work_date) = ? AND YEAR(a.work_date) = ?";
        String sqlConfirmed = "SELECT COUNT(DISTINCT tec.user_id) FROM timesheet_employee_confirmations tec " +
                              "JOIN attendance a ON tec.user_id = a.user_id AND MONTH(a.work_date) = tec.month AND YEAR(a.work_date) = tec.year " +
                              "WHERE tec.department_id = ? AND tec.month = ? AND tec.year = ?";
        int total = 0;
        int confirmed = 0;
        try (Connection conn = DBContext.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(sqlTotal)) {
                ps.setInt(1, deptId);
                ps.setInt(2, month);
                ps.setInt(3, year);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        total = rs.getInt(1);
                    }
                }
            }
            try (PreparedStatement ps = conn.prepareStatement(sqlConfirmed)) {
                ps.setInt(1, deptId);
                ps.setInt(2, month);
                ps.setInt(3, year);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        confirmed = rs.getInt(1);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return total == 0 || confirmed >= total;
    }

    public boolean areAllActiveDepartmentsConfirmed(int month, int year) {
        String sql = "SELECT COUNT(*) FROM (" +
                     "    SELECT DISTINCT u.department_id FROM attendance a " +
                     "    JOIN users u ON a.user_id = u.user_id " +
                     "    WHERE MONTH(a.work_date) = ? AND YEAR(a.work_date) = ? AND u.department_id IS NOT NULL" +
                     ") dept_att " +
                     "LEFT JOIN timesheet_confirmations tc ON tc.month = ? AND tc.year = ? AND tc.department_id = dept_att.department_id " +
                     "WHERE tc.id IS NULL OR tc.status IN ('DRAFT', 'SENT_TO_DEPARTMENT', 'DEPARTMENT_REJECTED', 'HR_MANAGER_REJECTED')";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, month);
            ps.setInt(2, year);
            ps.setInt(3, month);
            ps.setInt(4, year);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) == 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Department> getDepartmentsWithAttendance(int month, int year) {
        List<Department> list = new ArrayList<>();
        String sql = "SELECT DISTINCT d.department_id, d.department_name " +
                     "FROM attendance a " +
                     "JOIN users u ON a.user_id = u.user_id " +
                     "JOIN departments d ON u.department_id = d.department_id " +
                     "WHERE MONTH(a.work_date) = ? AND YEAR(a.work_date) = ? " +
                     "ORDER BY d.department_name";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, month);
            ps.setInt(2, year);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Department d = new Department();
                    d.setDepartmentId(rs.getInt("department_id"));
                    d.setDepartmentName(rs.getString("department_name"));
                    list.add(d);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<TimesheetConfirmation> getAllConfirmations() {
        List<TimesheetConfirmation> list = new ArrayList<>();
        String sql = "SELECT tc.*, d.department_name, u1.full_name AS created_by_name, u2.full_name AS updated_by_name " +
                     "FROM timesheet_confirmations tc " +
                     "JOIN departments d ON tc.department_id = d.department_id " +
                     "LEFT JOIN users u1 ON tc.created_by = u1.user_id " +
                     "LEFT JOIN users u2 ON tc.updated_by = u2.user_id " +
                     "ORDER BY tc.year DESC, tc.month DESC, d.department_name";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<String> getPeriodsWithAttendance() {
        List<String> list = new ArrayList<>();
        String sql = "SELECT DISTINCT MONTH(work_date) AS m, YEAR(work_date) AS y FROM attendance";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(rs.getInt("y") + "-" + rs.getInt("m"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Attendance> getDepartmentAttendance(int month, int year, int departmentId) {
        List<Attendance> list = new ArrayList<>();
        String sql = "SELECT a.*, u.full_name AS user_name, s.shift_name " +
                     "FROM attendance a " +
                     "JOIN users u ON a.user_id = u.user_id " +
                     "LEFT JOIN shifts s ON a.shift_id = s.shift_id " +
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

    private TimesheetConfirmation mapRow(ResultSet rs) throws SQLException {
        TimesheetConfirmation tc = new TimesheetConfirmation();
        tc.setId(rs.getInt("id"));
        tc.setMonth(rs.getInt("month"));
        tc.setYear(rs.getInt("year"));
        tc.setDepartmentId(rs.getInt("department_id"));
        tc.setStatus(rs.getString("status"));
        tc.setRejectReason(rs.getString("reject_reason"));
        tc.setCreatedBy(rs.getInt("created_by"));
        tc.setCreatedAt(rs.getTimestamp("created_at"));
        int updatedBy = rs.getInt("updated_by");
        tc.setUpdatedBy(rs.wasNull() ? 0 : updatedBy);
        tc.setUpdatedAt(rs.getTimestamp("updated_at"));
        tc.setDepartmentName(rs.getString("department_name"));
        tc.setCreatedByName(rs.getString("created_by_name"));
        tc.setUpdatedByName(rs.getString("updated_by_name"));
        return tc;
    }

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
        a.setUserName(rs.getString("user_name"));
        a.setShiftName(rs.getString("shift_name"));
        return a;
    }

    public static class EmployeeTimesheetSummary {
        private int userId;
        private String fullName;
        private String departmentName;
        private String positionName;
        private double totalWorkDays;
        private double totalLeaveDays;
        private double totalOTHours;
        private boolean confirmed;

        public int getUserId() { return userId; }
        public void setUserId(int userId) { this.userId = userId; }

        public String getFullName() { return fullName; }
        public void setFullName(String fullName) { this.fullName = fullName; }

        public String getDepartmentName() { return departmentName; }
        public void setDepartmentName(String departmentName) { this.departmentName = departmentName; }

        public String getPositionName() { return positionName; }
        public void setPositionName(String positionName) { this.positionName = positionName; }

        public double getTotalWorkDays() { return totalWorkDays; }
        public void setTotalWorkDays(double totalWorkDays) { this.totalWorkDays = totalWorkDays; }

        public double getTotalLeaveDays() { return totalLeaveDays; }
        public void setTotalLeaveDays(double totalLeaveDays) { this.totalLeaveDays = totalLeaveDays; }

        public double getTotalOTHours() { return totalOTHours; }
        public void setTotalOTHours(double totalOTHours) { this.totalOTHours = totalOTHours; }

        public boolean isConfirmed() { return confirmed; }
        public void setConfirmed(boolean confirmed) { this.confirmed = confirmed; }
    }

    public List<EmployeeTimesheetSummary> getDepartmentEmployeeSummary(int month, int year, int departmentId) {
        List<EmployeeTimesheetSummary> list = new ArrayList<>();
        String sql = "SELECT " +
                     "  u.user_id, " +
                     "  u.full_name, " +
                     "  d.department_name, " +
                     "  COALESCE(p.position_name, '-') AS position_name, " +
                     "  COALESCE(SUM(CASE WHEN a.status = 'PRESENT' OR a.status = 'LATE' THEN 1 WHEN a.status = 'HALFDAY' THEN 0.5 ELSE 0 END), 0) AS total_work_days, " +
                     "  COALESCE(SUM(CASE WHEN a.status = 'ABSENT' THEN 1 WHEN a.status = 'HALFDAY' THEN 0.5 ELSE 0 END), 0) AS total_leave_days, " +
                     "  COALESCE(SUM(a.overtime_hrs), 0) AS total_ot_hours, " +
                     "  MAX(CASE WHEN tec.id IS NOT NULL THEN 1 ELSE 0 END) AS is_confirmed " +
                     "FROM users u " +
                     "JOIN departments d ON u.department_id = d.department_id " +
                     "LEFT JOIN positions p ON u.position_id = p.position_id " +
                     "LEFT JOIN attendance a ON u.user_id = a.user_id AND MONTH(a.work_date) = ? AND YEAR(a.work_date) = ? " +
                     "LEFT JOIN timesheet_employee_confirmations tec ON u.user_id = tec.user_id AND tec.month = ? AND tec.year = ? " +
                     "WHERE u.department_id = ? " +
                     "GROUP BY u.user_id, u.full_name, d.department_name, p.position_name " +
                     "ORDER BY u.full_name";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, month);
            ps.setInt(2, year);
            ps.setInt(3, month);
            ps.setInt(4, year);
            ps.setInt(5, departmentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    EmployeeTimesheetSummary s = new EmployeeTimesheetSummary();
                    s.setUserId(rs.getInt("user_id"));
                    s.setFullName(rs.getString("full_name"));
                    s.setDepartmentName(rs.getString("department_name"));
                    s.setPositionName(rs.getString("position_name"));
                    s.setTotalWorkDays(rs.getDouble("total_work_days"));
                    s.setTotalLeaveDays(rs.getDouble("total_leave_days"));
                    s.setTotalOTHours(rs.getDouble("total_ot_hours"));
                    s.setConfirmed(rs.getInt("is_confirmed") == 1);
                    list.add(s);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}
