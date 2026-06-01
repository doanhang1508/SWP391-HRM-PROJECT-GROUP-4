package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.LeaveType;
import util.DBContext;

public class LeaveTypeDAO {

    public List<LeaveType> getAll() {
        List<LeaveType> list = new ArrayList<>();
        String sql = "SELECT * FROM leave_types WHERE status = 1 ORDER BY leave_type_id";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new LeaveType(
                        rs.getInt("leave_type_id"),
                        rs.getString("type_name"),
                    rs.getString("description"),
                    rs.getInt("paid_leave"),
                    (Integer) rs.getObject("max_days_per_year"),
                        rs.getInt("status")
                ));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public void insert(LeaveType lt) {
        String sql = "INSERT INTO leave_types (type_name, description, paid_leave, max_days_per_year, status) VALUES (?, ?, ?, ?, 1)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, lt.getTypeName());
            ps.setString(2, lt.getDescription());
            ps.setInt(3, lt.getPaidLeave());
            if (lt.getMaxDaysPerYear() == null) {
                ps.setNull(4, java.sql.Types.INTEGER);
            } else {
                ps.setInt(4, lt.getMaxDaysPerYear());
            }
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void update(LeaveType lt) {
        String sql = "UPDATE leave_types SET type_name = ?, description = ?, paid_leave = ?, max_days_per_year = ? WHERE leave_type_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, lt.getTypeName());
            ps.setString(2, lt.getDescription());
            ps.setInt(3, lt.getPaidLeave());
            if (lt.getMaxDaysPerYear() == null) {
                ps.setNull(4, java.sql.Types.INTEGER);
            } else {
                ps.setInt(4, lt.getMaxDaysPerYear());
            }
            ps.setInt(5, lt.getLeaveTypeId());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public boolean isTypeNameExists(String typeName, Integer excludeId) {
        String sql = "SELECT 1 FROM leave_types WHERE LOWER(type_name) = LOWER(?)";
        if (excludeId != null && excludeId > 0) {
            sql += " AND leave_type_id <> ?";
        }
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, typeName);
            if (excludeId != null && excludeId > 0) {
                ps.setInt(2, excludeId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public void delete(int id) {
        String sql = "UPDATE leave_types SET status = 0 WHERE leave_type_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
