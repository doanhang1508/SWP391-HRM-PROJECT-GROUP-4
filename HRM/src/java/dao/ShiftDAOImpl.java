package dao;

import model.Shift;
import util.DBContext;

import java.sql.*;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

/**
 * ShiftDAOImpl — JDBC implementation of {@link ShiftDAO} for v2 schema.
 * Columns: shift_id, shift_name, start_time, end_time,
 *          break_start, break_end, is_night_shift, coefficient, status
 */
public class ShiftDAOImpl implements ShiftDAO {

    // ── Map ResultSet → Shift ──
    private Shift mapRow(ResultSet rs) throws SQLException {
        Shift s = new Shift();
        s.setShiftId(rs.getInt("shift_id"));
        s.setShiftName(rs.getString("shift_name"));
        s.setStartTime(rs.getTime("start_time").toLocalTime());
        s.setEndTime(rs.getTime("end_time").toLocalTime());

        Time bs = rs.getTime("break_start");
        s.setBreakStart(bs != null ? bs.toLocalTime() : null);

        Time be = rs.getTime("break_end");
        s.setBreakEnd(be != null ? be.toLocalTime() : null);

        s.setNightShift(rs.getBoolean("is_night_shift"));
        s.setCoefficient(rs.getFloat("coefficient"));
        s.setStatus(rs.getInt("status"));
        return s;
    }

    // ── Helper: set nullable TIME ──
    private void setNullableTime(PreparedStatement ps, int idx, LocalTime t) throws SQLException {
        if (t != null) ps.setTime(idx, Time.valueOf(t));
        else ps.setNull(idx, Types.TIME);
    }

    // ═══════════════════════════════════════════════════════════════
    // CRUD
    // ═══════════════════════════════════════════════════════════════

    @Override
    public List<Shift> getAllShifts() {
        List<Shift> list = new ArrayList<>();
        String sql = "SELECT * FROM shifts ORDER BY shift_id";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            System.err.println("Lỗi getAllShifts: " + e.getMessage());
        }
        return list;
    }

    @Override
    public List<Shift> getActiveShifts() {
        List<Shift> list = new ArrayList<>();
        String sql = "SELECT * FROM shifts WHERE status = 1 ORDER BY start_time";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            System.err.println("Lỗi getActiveShifts: " + e.getMessage());
        }
        return list;
    }

    @Override
    public Shift getShiftById(int shiftId) {
        String sql = "SELECT * FROM shifts WHERE shift_id = ?";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, shiftId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("Lỗi getShiftById: " + e.getMessage());
        }
        return null;
    }

    @Override
    public boolean addShift(Shift s) {
        String sql = "INSERT INTO shifts (shift_name, start_time, end_time, "
                   + "break_start, break_end, is_night_shift, coefficient, status) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, s.getShiftName());
            ps.setTime(2, Time.valueOf(s.getStartTime()));
            ps.setTime(3, Time.valueOf(s.getEndTime()));
            setNullableTime(ps, 4, s.getBreakStart());
            setNullableTime(ps, 5, s.getBreakEnd());
            ps.setBoolean(6, s.isNightShift());
            ps.setFloat(7, s.getCoefficient());
            ps.setInt(8, s.getStatus());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi addShift: " + e.getMessage());
        }
        return false;
    }

    @Override
    public boolean updateShift(Shift s) {
        String sql = "UPDATE shifts SET shift_name=?, start_time=?, end_time=?, "
                   + "break_start=?, break_end=?, is_night_shift=?, coefficient=?, status=? "
                   + "WHERE shift_id=?";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, s.getShiftName());
            ps.setTime(2, Time.valueOf(s.getStartTime()));
            ps.setTime(3, Time.valueOf(s.getEndTime()));
            setNullableTime(ps, 4, s.getBreakStart());
            setNullableTime(ps, 5, s.getBreakEnd());
            ps.setBoolean(6, s.isNightShift());
            ps.setFloat(7, s.getCoefficient());
            ps.setInt(8, s.getStatus());
            ps.setInt(9, s.getShiftId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi updateShift: " + e.getMessage());
        }
        return false;
    }

    @Override
    public boolean deleteShift(int shiftId) {
        String sql = "DELETE FROM shifts WHERE shift_id = ?";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, shiftId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi deleteShift: " + e.getMessage());
        }
        return false;
    }

    @Override
    public boolean toggleShiftStatus(int shiftId) {
        String sql = "UPDATE shifts SET status = 1 - status WHERE shift_id = ?";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, shiftId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi toggleShiftStatus: " + e.getMessage());
        }
        return false;
    }

    @Override
    public boolean isShiftNameExists(String shiftName, int excludeShiftId) {
        String sql = "SELECT 1 FROM shifts WHERE shift_name = ? AND shift_id != ?";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, shiftName);
            ps.setInt(2, excludeShiftId);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        } catch (SQLException e) {
            System.err.println("Lỗi isShiftNameExists: " + e.getMessage());
        }
        return false;
    }
}
