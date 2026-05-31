package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.EmploymentStatus;
import util.DBContext;

public class EmploymentStatusDAO {

    public List<EmploymentStatus> getAll() {
        List<EmploymentStatus> list = new ArrayList<>();
        String sql = "SELECT * FROM employment_statuses WHERE status = 1 ORDER BY status_id";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new EmploymentStatus(
                    rs.getInt("status_id"),
                    rs.getString("status_name"),
                    rs.getString("description"),
                    rs.getBoolean("status")
                ));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public void insert(EmploymentStatus es) {
        String sql = "INSERT INTO employment_statuses (status_name, description, status) VALUES (?, ?, 1)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, es.getStatusName());
            ps.setString(2, es.getDescription());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void update(EmploymentStatus es) {
        String sql = "UPDATE employment_statuses SET status_name=?, description=? WHERE status_id=?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, es.getStatusName());
            ps.setString(2, es.getDescription());
            ps.setInt(3, es.getStatusId());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void delete(int id) {
        String sql = "UPDATE employment_statuses SET status = 0 WHERE status_id=?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public int countEmployees(int statusId) {
        String sql = "SELECT COUNT(*) FROM employee_profiles WHERE employment_status_id=?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, statusId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }
}
