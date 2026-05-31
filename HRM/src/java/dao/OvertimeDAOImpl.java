package dao;

import model.Attendance;
import util.DBContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OvertimeDAOImpl implements OvertimeDAO {

    @Override
    public List<Attendance> getOTRequestsByUserId(int userId) {
        List<Attendance> list = new ArrayList<>();
        String sql = "SELECT a.*, s.shift_name, u.full_name FROM attendance a " +
                     "JOIN shifts s ON a.shift_id = s.shift_id " +
                     "JOIN users u ON a.user_id = u.user_id " +
                     "WHERE a.user_id = ? AND a.overtime_hrs > 0 " +
                     "ORDER BY a.work_date DESC";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
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

    @Override
    public List<Attendance> getPendingOTRequestsByDepartment(int departmentId) {
        List<Attendance> list = new ArrayList<>();
        String sql = "SELECT a.*, s.shift_name, u.full_name FROM attendance a " +
                     "JOIN shifts s ON a.shift_id = s.shift_id " +
                     "JOIN users u ON a.user_id = u.user_id " +
                     "WHERE u.department_id = ? AND a.status = 'Pending OT' " +
                     "ORDER BY a.work_date DESC";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, departmentId);
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

    @Override
    public boolean submitOTRequest(int userId, int shiftId, Date workDate, double hours, String reason) {
        String checkSql = "SELECT attendance_id FROM attendance WHERE user_id = ? AND shift_id = ? AND work_date = ?";
        try (Connection c = DBContext.getConnection();
             PreparedStatement checkPs = c.prepareStatement(checkSql)) {
            checkPs.setInt(1, userId);
            checkPs.setInt(2, shiftId);
            checkPs.setDate(3, workDate);
            try (ResultSet rs = checkPs.executeQuery()) {
                if (rs.next()) {
                    int attendanceId = rs.getInt("attendance_id");
                    String updateSql = "UPDATE attendance SET overtime_hrs = ?, status = 'Pending OT' WHERE attendance_id = ?";
                    try (PreparedStatement updatePs = c.prepareStatement(updateSql)) {
                        updatePs.setDouble(1, hours);
                        updatePs.setInt(2, attendanceId);
                        return updatePs.executeUpdate() > 0;
                    }
                } else {
                    String insertSql = "INSERT INTO attendance (user_id, shift_id, work_date, overtime_hrs, status) " +
                                       "VALUES (?, ?, ?, ?, 'Pending OT')";
                    try (PreparedStatement insertPs = c.prepareStatement(insertSql)) {
                        insertPs.setInt(1, userId);
                        insertPs.setInt(2, shiftId);
                        insertPs.setDate(3, workDate);
                        insertPs.setDouble(4, hours);
                        return insertPs.executeUpdate() > 0;
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean approveOTRequest(int attendanceId) {
        String sql = "UPDATE attendance SET status = 'Present' WHERE attendance_id = ? AND status = 'Pending OT'";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, attendanceId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean rejectOTRequest(int attendanceId) {
        String sql = "UPDATE attendance SET status = 'Present', overtime_hrs = 0 WHERE attendance_id = ? AND status = 'Pending OT'";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, attendanceId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private Attendance mapRow(ResultSet rs) throws SQLException {
        Attendance a = new Attendance();
        a.setAttendanceId(rs.getInt("attendance_id"));
        a.setUserId(rs.getInt("user_id"));
        a.setShiftId(rs.getInt("shift_id"));
        a.setWorkDate(rs.getDate("work_date"));
        a.setCheckIn(rs.getTime("check_in"));
        a.setCheckOut(rs.getTime("check_out"));
        a.setStatus(rs.getString("status"));
        a.setOvertimeHrs(rs.getDouble("overtime_hrs"));
        a.setCreatedAt(rs.getTimestamp("created_at"));
        
        a.setShiftName(rs.getString("shift_name"));
        a.setUserName(rs.getString("full_name"));
        // reason is transient, we don't fetch it from DB as there is no column
        return a;
    }
}
