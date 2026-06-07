package dao;

import model.OvertimeAssignment;
import util.DBContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * OvertimeAssignmentDAOImpl — JDBC implementation for `overtime_assignments` table.
 */
public class OvertimeAssignmentDAOImpl implements OvertimeAssignmentDAO {

    private OvertimeAssignment mapRow(ResultSet rs) throws SQLException {
        OvertimeAssignment a = new OvertimeAssignment();
        a.setAssignmentId(rs.getInt("assignment_id"));
        a.setPlanId(rs.getInt("plan_id"));
        a.setUserId(rs.getInt("user_id"));
        a.setAssignedHours(rs.getDouble("assigned_hours"));
        a.setStatus(rs.getString("status"));
        a.setCreatedAt(rs.getTimestamp("created_at"));
        a.setEmployeeName(rs.getString("employee_name"));
        a.setPlanDescription(rs.getString("plan_description"));
        a.setTargetDate(rs.getDate("target_date"));
        a.setDepartmentName(rs.getString("department_name"));
        return a;
    }

    private static final String BASE_SELECT =
            "SELECT oa.*, u.full_name AS employee_name, "
          + "op.description AS plan_description, op.target_date, d.department_name "
          + "FROM overtime_assignments oa "
          + "JOIN users u ON oa.user_id = u.user_id "
          + "JOIN overtime_plans op ON oa.plan_id = op.plan_id "
          + "JOIN departments d ON op.dept_id = d.department_id ";

    @Override
    public List<OvertimeAssignment> getByPlanId(int planId) {
        List<OvertimeAssignment> list = new ArrayList<>();
        String sql = BASE_SELECT + "WHERE oa.plan_id = ? ORDER BY u.full_name";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, planId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("Error getByPlanId OTAssignment: " + e.getMessage());
        }
        return list;
    }

    @Override
    public List<OvertimeAssignment> getByUserId(int userId) {
        List<OvertimeAssignment> list = new ArrayList<>();
        String sql = BASE_SELECT + "WHERE oa.user_id = ? ORDER BY op.target_date DESC";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("Error getByUserId OTAssignment: " + e.getMessage());
        }
        return list;
    }

    @Override
    public List<OvertimeAssignment> getByDepartmentId(int deptId) {
        List<OvertimeAssignment> list = new ArrayList<>();
        String sql = BASE_SELECT + "WHERE op.dept_id = ? ORDER BY op.target_date DESC, u.full_name";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, deptId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("Error getByDepartmentId OTAssignment: " + e.getMessage());
        }
        return list;
    }

    @Override
    public List<OvertimeAssignment> getPendingByDepartmentId(int deptId) {
        List<OvertimeAssignment> list = new ArrayList<>();
        String sql = BASE_SELECT + "WHERE op.dept_id = ? AND oa.status = 'Pending' ORDER BY op.target_date DESC, u.full_name";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, deptId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("Error getPendingByDepartmentId: " + e.getMessage());
        }
        return list;
    }

    @Override
    public OvertimeAssignment getById(int assignmentId) {
        String sql = BASE_SELECT + "WHERE oa.assignment_id = ?";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, assignmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("Error getById OTAssignment: " + e.getMessage());
        }
        return null;
    }

    @Override
    public boolean create(OvertimeAssignment assignment) {
        String sql = "INSERT INTO overtime_assignments (plan_id, user_id, assigned_hours, status) "
                   + "VALUES (?, ?, ?, ?)";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, assignment.getPlanId());
            ps.setInt(2, assignment.getUserId());
            ps.setDouble(3, assignment.getAssignedHours());
            ps.setString(4, assignment.getStatus() != null ? assignment.getStatus() : "Pending");
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error create OTAssignment: " + e.getMessage());
        }
        return false;
    }

    @Override
    public boolean updateStatus(int assignmentId, String status) {
        String sql = "UPDATE overtime_assignments SET status = ? WHERE assignment_id = ?";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, assignmentId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error updateStatus OTAssignment: " + e.getMessage());
        }
        return false;
    }

    @Override
    public boolean hasOverlap(int userId, int planId) {
        String sql = "SELECT 1 FROM overtime_assignments WHERE user_id = ? AND plan_id = ?";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, planId);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        } catch (SQLException e) {
            System.err.println("Error hasOverlap: " + e.getMessage());
        }
        return false;
    }

    @Override
    public double getTotalOTHoursForDate(int userId, java.sql.Date date) {
        String sql = "SELECT COALESCE(SUM(oa.assigned_hours), 0) AS total_hours "
                   + "FROM overtime_assignments oa "
                   + "JOIN overtime_plans op ON oa.plan_id = op.plan_id "
                   + "WHERE oa.user_id = ? AND op.target_date = ? AND oa.status != 'Cancelled'";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setDate(2, date);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getDouble("total_hours");
            }
        } catch (SQLException e) {
            System.err.println("Error getTotalOTHoursForDate: " + e.getMessage());
        }
        return 0;
    }
}
