package dao;

import model.DepartmentShift;
import util.DBContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DepartmentShiftDAOImpl — JDBC implementation for `department_shifts` table.
 */
public class DepartmentShiftDAOImpl implements DepartmentShiftDAO {

    private DepartmentShift mapRow(ResultSet rs) throws SQLException {
        DepartmentShift ds = new DepartmentShift();
        ds.setId(rs.getInt("id"));
        ds.setDepartmentId(rs.getInt("department_id"));
        ds.setShiftId(rs.getInt("shift_id"));
        ds.setCreatedAt(rs.getTimestamp("created_at"));
        ds.setDepartmentName(rs.getString("department_name"));
        ds.setShiftName(rs.getString("shift_name"));
        return ds;
    }

    @Override
    public List<DepartmentShift> getAll() {
        List<DepartmentShift> list = new ArrayList<>();
        String sql = "SELECT ds.*, d.department_name, s.shift_name "
                   + "FROM department_shifts ds "
                   + "JOIN departments d ON ds.department_id = d.department_id "
                   + "JOIN shifts s ON ds.shift_id = s.shift_id "
                   + "ORDER BY d.department_name, s.shift_name";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            System.err.println("Error getAll DepartmentShift: " + e.getMessage());
        }
        return list;
    }

    @Override
    public List<DepartmentShift> getByDepartmentId(int departmentId) {
        List<DepartmentShift> list = new ArrayList<>();
        String sql = "SELECT ds.*, d.department_name, s.shift_name "
                   + "FROM department_shifts ds "
                   + "JOIN departments d ON ds.department_id = d.department_id "
                   + "JOIN shifts s ON ds.shift_id = s.shift_id "
                   + "WHERE ds.department_id = ? "
                   + "ORDER BY s.start_time";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, departmentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("Error getByDepartmentId: " + e.getMessage());
        }
        return list;
    }

    @Override
    public boolean add(int departmentId, int shiftId) {
        String sql = "INSERT IGNORE INTO department_shifts (department_id, shift_id) VALUES (?, ?)";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, departmentId);
            ps.setInt(2, shiftId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error add DepartmentShift: " + e.getMessage());
        }
        return false;
    }

    @Override
    public boolean delete(int id) {
        String sql = "DELETE FROM department_shifts WHERE id = ?";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error delete DepartmentShift: " + e.getMessage());
        }
        return false;
    }

    @Override
    public boolean existsMapping(int departmentId, int shiftId) {
        String sql = "SELECT 1 FROM department_shifts WHERE department_id = ? AND shift_id = ?";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, departmentId);
            ps.setInt(2, shiftId);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        } catch (SQLException e) {
            System.err.println("Error existsMapping: " + e.getMessage());
        }
        return false;
    }
}
