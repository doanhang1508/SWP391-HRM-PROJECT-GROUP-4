package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.EducationLevel;
import util.DBContext;

public class EducationLevelDAO {

    public List<EducationLevel> getAll() {
        List<EducationLevel> list = new ArrayList<>();
        String sql = "SELECT * FROM education_levels WHERE status = 1 ORDER BY education_level_id";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new EducationLevel(
                    rs.getInt("education_level_id"),
                    rs.getString("level_name"),
                    rs.getString("description"),
                    rs.getBoolean("status")
                ));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public void insert(EducationLevel el) {
        String sql = "INSERT INTO education_levels (level_name, description, status) VALUES (?, ?, 1)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, el.getLevelName());
            ps.setString(2, el.getDescription());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void update(EducationLevel el) {
        String sql = "UPDATE education_levels SET level_name=?, description=? WHERE education_level_id=?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, el.getLevelName());
            ps.setString(2, el.getDescription());
            ps.setInt(3, el.getEducationLevelId());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void delete(int id) {
        String sql = "UPDATE education_levels SET status = 0 WHERE education_level_id=?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public int countEmployees(int educationLevelId) {
        String sql = "SELECT COUNT(*) FROM employee_profiles WHERE education_level_id=?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, educationLevelId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }
}
