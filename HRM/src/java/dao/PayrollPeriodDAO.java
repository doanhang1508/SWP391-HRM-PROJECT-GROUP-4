package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.PayrollPeriod;
import util.DBContext;

public class PayrollPeriodDAO {

    private PayrollPeriod mapRow(ResultSet rs) throws SQLException {
        PayrollPeriod pp = new PayrollPeriod();
        pp.setPeriodId(rs.getInt("period_id"));
        pp.setPeriodName(rs.getString("period_name"));
        pp.setMonth(rs.getInt("month"));
        pp.setYear(rs.getInt("year"));
        pp.setStartDate(rs.getDate("start_date"));
        pp.setEndDate(rs.getDate("end_date"));
        pp.setStatus(rs.getString("status"));
        int lb = rs.getInt("locked_by");
        pp.setLockedBy(rs.wasNull() ? null : lb);
        pp.setLockedAt(rs.getTimestamp("locked_at"));
        pp.setCreatedAt(rs.getTimestamp("created_at"));
        return pp;
    }

    public PayrollPeriod getByMonthYear(int month, int year) {
        String sql = "SELECT * FROM payroll_periods WHERE month = ? AND year = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, month); ps.setInt(2, year);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public PayrollPeriod getOrCreate(int month, int year) {
        PayrollPeriod pp = getByMonthYear(month, year);
        if (pp != null) return pp;
        java.time.LocalDate start = java.time.LocalDate.of(year, month, 1);
        java.time.LocalDate end = start.with(java.time.temporal.TemporalAdjusters.lastDayOfMonth());
        String name = String.format("Tháng %02d/%d", month, year);
        String sql = "INSERT INTO payroll_periods (period_name, month, year, start_date, end_date) " +
                     "VALUES (?, ?, ?, ?, ?) ON DUPLICATE KEY UPDATE period_name = VALUES(period_name)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name); ps.setInt(2, month); ps.setInt(3, year);
            ps.setDate(4, Date.valueOf(start)); ps.setDate(5, Date.valueOf(end));
            ps.executeUpdate();
        } catch (SQLException e) { e.printStackTrace(); }
        return getByMonthYear(month, year);
    }

    public List<PayrollPeriod> getAll() {
        List<PayrollPeriod> list = new ArrayList<>();
        String sql = "SELECT * FROM payroll_periods ORDER BY year DESC, month DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public boolean lockPeriod(int periodId, int lockedBy) {
        String sql = "UPDATE payroll_periods SET status = 'LOCKED', locked_by = ?, locked_at = NOW() WHERE period_id = ? AND status = 'OPEN'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, lockedBy); ps.setInt(2, periodId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    public boolean closePeriod(int periodId) {
        String sql = "UPDATE payroll_periods SET status = 'CLOSED' WHERE period_id = ? AND status = 'LOCKED'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, periodId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    public PayrollPeriod getById(int periodId) {
        String sql = "SELECT * FROM payroll_periods WHERE period_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, periodId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }
}
