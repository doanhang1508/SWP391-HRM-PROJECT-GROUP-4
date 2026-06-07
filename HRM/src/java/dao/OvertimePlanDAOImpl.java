package dao;

import model.OvertimePlan;
import util.DBContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * OvertimePlanDAOImpl — JDBC implementation for `overtime_plans` table.
 */
public class OvertimePlanDAOImpl implements OvertimePlanDAO {

    private OvertimePlan mapRow(ResultSet rs) throws SQLException {
        OvertimePlan p = new OvertimePlan();
        p.setPlanId(rs.getInt("plan_id"));
        p.setDeptId(rs.getInt("dept_id"));
        p.setSupervisorId(rs.getInt("supervisor_id"));
        p.setTargetDate(rs.getDate("target_date"));
        p.setDescription(rs.getString("description"));
        p.setStatus(rs.getString("status"));
        p.setCreatedAt(rs.getTimestamp("created_at"));
        p.setDepartmentName(rs.getString("department_name"));
        p.setSupervisorName(rs.getString("supervisor_name"));
        p.setAssignmentCount(rs.getInt("assignment_count"));
        return p;
    }

    @Override
    public List<OvertimePlan> getByDepartmentId(int deptId) {
        List<OvertimePlan> list = new ArrayList<>();
        String sql = "SELECT op.*, d.department_name, u.full_name AS supervisor_name, "
                   + "(SELECT COUNT(*) FROM overtime_assignments oa WHERE oa.plan_id = op.plan_id) AS assignment_count "
                   + "FROM overtime_plans op "
                   + "JOIN departments d ON op.dept_id = d.department_id "
                   + "JOIN users u ON op.supervisor_id = u.user_id "
                   + "WHERE op.dept_id = ? "
                   + "ORDER BY op.target_date DESC";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, deptId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("Error getByDepartmentId OvertimePlan: " + e.getMessage());
        }
        return list;
    }

    @Override
    public OvertimePlan getById(int planId) {
        String sql = "SELECT op.*, d.department_name, u.full_name AS supervisor_name, "
                   + "(SELECT COUNT(*) FROM overtime_assignments oa WHERE oa.plan_id = op.plan_id) AS assignment_count "
                   + "FROM overtime_plans op "
                   + "JOIN departments d ON op.dept_id = d.department_id "
                   + "JOIN users u ON op.supervisor_id = u.user_id "
                   + "WHERE op.plan_id = ?";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, planId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("Error getById OvertimePlan: " + e.getMessage());
        }
        return null;
    }

    @Override
    public boolean create(OvertimePlan plan) {
        String sql = "INSERT INTO overtime_plans (dept_id, supervisor_id, target_date, description, status) "
                   + "VALUES (?, ?, ?, ?, ?)";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, plan.getDeptId());
            ps.setInt(2, plan.getSupervisorId());
            ps.setDate(3, plan.getTargetDate());
            ps.setString(4, plan.getDescription());
            ps.setString(5, plan.getStatus() != null ? plan.getStatus() : "Active");
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error create OvertimePlan: " + e.getMessage());
        }
        return false;
    }

    @Override
    public boolean updateStatus(int planId, String status) {
        String sql = "UPDATE overtime_plans SET status = ? WHERE plan_id = ?";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, planId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error updateStatus OvertimePlan: " + e.getMessage());
        }
        return false;
    }
}
