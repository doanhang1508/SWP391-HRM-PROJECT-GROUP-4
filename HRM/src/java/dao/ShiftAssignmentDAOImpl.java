package dao;

import model.ShiftAssignment;
import util.DBContext;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * ShiftAssignmentDAOImpl — JDBC implementation of {@link ShiftAssignmentDAO}.
 * All queries use PreparedStatement via the DBContext connection pool.
 */
public class ShiftAssignmentDAOImpl implements ShiftAssignmentDAO {

    // ── Map ResultSet → ShiftAssignment (basic columns only) ──
    private ShiftAssignment mapRow(ResultSet rs) throws SQLException {
        ShiftAssignment sa = new ShiftAssignment();
        sa.setAssignmentId(rs.getInt("assignment_id"));
        sa.setUserId(rs.getInt("user_id"));
        sa.setShiftId(rs.getInt("shift_id"));
        sa.setAssignedDate(rs.getDate("assigned_date").toLocalDate());
        sa.setCreatedAt(rs.getTimestamp("created_at"));
        return sa;
    }

    // ── Map ResultSet with JOIN data (user_name, shift_name, times, flags) ──
    private ShiftAssignment mapRowWithJoin(ResultSet rs) throws SQLException {
        ShiftAssignment sa = mapRow(rs);
        try { sa.setUserName(rs.getString("full_name")); } catch (SQLException ignored) {}
        try { sa.setShiftName(rs.getString("shift_name")); } catch (SQLException ignored) {}
        try {
            java.sql.Time st = rs.getTime("start_time");
            if (st != null) sa.setStartTime(st.toLocalTime());
        } catch (SQLException ignored) {}
        try {
            java.sql.Time et = rs.getTime("end_time");
            if (et != null) sa.setEndTime(et.toLocalTime());
        } catch (SQLException ignored) {}
        try { sa.setNightShift(rs.getBoolean("is_night_shift")); } catch (SQLException ignored) {}
        try { sa.setCoefficient(rs.getFloat("coefficient")); } catch (SQLException ignored) {}
        return sa;
    }

    // ═══════════════════════════════════════════════════════════════

    @Override
    public List<ShiftAssignment> getByUserAndDateRange(int userId, LocalDate from, LocalDate to) {
        List<ShiftAssignment> list = new ArrayList<>();
        String sql = "SELECT sa.*, s.shift_name, s.start_time, s.end_time, s.is_night_shift, s.coefficient "
                   + "FROM shift_assignments sa "
                   + "JOIN shifts s ON sa.shift_id = s.shift_id "
                   + "WHERE sa.user_id = ? AND sa.assigned_date BETWEEN ? AND ? "
                   + "ORDER BY sa.assigned_date";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setDate(2, Date.valueOf(from));
            ps.setDate(3, Date.valueOf(to));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRowWithJoin(rs));
            }
        } catch (SQLException e) {
            System.err.println("Lỗi getByUserAndDateRange: " + e.getMessage());
        }
        return list;
    }

    @Override
    public List<ShiftAssignment> getByDateRange(LocalDate from, LocalDate to) {
        List<ShiftAssignment> list = new ArrayList<>();
        String sql = "SELECT sa.*, u.full_name, s.shift_name "
                   + "FROM shift_assignments sa "
                   + "JOIN users u ON sa.user_id = u.user_id "
                   + "JOIN shifts s ON sa.shift_id = s.shift_id "
                   + "WHERE sa.assigned_date BETWEEN ? AND ? "
                   + "ORDER BY u.full_name, sa.assigned_date";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(from));
            ps.setDate(2, Date.valueOf(to));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRowWithJoin(rs));
            }
        } catch (SQLException e) {
            System.err.println("Lỗi getByDateRange: " + e.getMessage());
        }
        return list;
    }

    @Override
    public ShiftAssignment getByUserAndDate(int userId, LocalDate date) {
        String sql = "SELECT sa.*, s.shift_name "
                   + "FROM shift_assignments sa "
                   + "JOIN shifts s ON sa.shift_id = s.shift_id "
                   + "WHERE sa.user_id = ? AND sa.assigned_date = ?";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setDate(2, Date.valueOf(date));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRowWithJoin(rs);
            }
        } catch (SQLException e) {
            System.err.println("Lỗi getByUserAndDate: " + e.getMessage());
        }
        return null;
    }

    @Override
    public boolean addAssignment(ShiftAssignment a) {
        // INSERT IGNORE skips duplicates on UNIQUE(user_id, assigned_date)
        String sql = "INSERT IGNORE INTO shift_assignments (user_id, shift_id, assigned_date) "
                   + "VALUES (?, ?, ?)";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, a.getUserId());
            ps.setInt(2, a.getShiftId());
            ps.setDate(3, Date.valueOf(a.getAssignedDate()));
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi addAssignment: " + e.getMessage());
        }
        return false;
    }

    @Override
    public int batchAssign(int userId, int shiftId, LocalDate from, LocalDate to) {
        // Batch-insert one row per date in the range, skipping duplicates
        String sql = "INSERT IGNORE INTO shift_assignments (user_id, shift_id, assigned_date) "
                   + "VALUES (?, ?, ?)";
        int inserted = 0;
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {

            LocalDate cursor = from;
            while (!cursor.isAfter(to)) {
                ps.setInt(1, userId);
                ps.setInt(2, shiftId);
                ps.setDate(3, Date.valueOf(cursor));
                ps.addBatch();
                cursor = cursor.plusDays(1);
            }
            int[] results = ps.executeBatch();
            for (int r : results) {
                if (r > 0) inserted++;
            }
        } catch (SQLException e) {
            System.err.println("Lỗi batchAssign: " + e.getMessage());
        }
        return inserted;
    }

    @Override
    public boolean updateAssignment(int assignmentId, int newShiftId) {
        String sql = "UPDATE shift_assignments SET shift_id = ? WHERE assignment_id = ?";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, newShiftId);
            ps.setInt(2, assignmentId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi updateAssignment: " + e.getMessage());
        }
        return false;
    }

    @Override
    public boolean deleteAssignment(int assignmentId) {
        String sql = "DELETE FROM shift_assignments WHERE assignment_id = ?";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, assignmentId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi deleteAssignment: " + e.getMessage());
        }
        return false;
    }

    @Override
    public boolean deleteByUserAndDate(int userId, LocalDate date) {
        String sql = "DELETE FROM shift_assignments WHERE user_id = ? AND assigned_date = ?";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setDate(2, Date.valueOf(date));
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi deleteByUserAndDate: " + e.getMessage());
        }
        return false;
    }
}
