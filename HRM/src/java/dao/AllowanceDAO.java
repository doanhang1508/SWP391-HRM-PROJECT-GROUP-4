package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.Allowance;
import util.DBContext;

public class AllowanceDAO {

    public List<Allowance> getAll() {
        List<Allowance> list = new ArrayList<>();
        String sql = "SELECT * FROM allowances WHERE status = 1 ORDER BY allowance_id";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new Allowance(
                    rs.getInt("allowance_id"),
                    rs.getString("allowance_name"),
                    rs.getString("description"),
                    rs.getBoolean("status")
                ));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public Allowance getById(int id) {
        String sql = "SELECT * FROM allowances WHERE allowance_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new Allowance(
                        rs.getInt("allowance_id"),
                        rs.getString("allowance_name"),
                        rs.getString("description"),
                        rs.getBoolean("status")
                    );
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean isDuplicate(String allowanceName, int excludeId) {
        String sql = "SELECT COUNT(*) FROM allowances WHERE allowance_name = ? AND allowance_id != ? AND status = 1";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, allowanceName);
            ps.setInt(2, excludeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public void insert(Allowance a) {
        String sql = "INSERT INTO allowances (allowance_name, description, status) VALUES (?, ?, 1)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, a.getAllowanceName());
            ps.setString(2, a.getDescription());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void update(Allowance a) {
        String sql = "UPDATE allowances SET allowance_name=?, description=? WHERE allowance_id=?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, a.getAllowanceName());
            ps.setString(2, a.getDescription());
            ps.setInt(3, a.getAllowanceId());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void delete(int id) {
        String sql = "UPDATE allowances SET status = 0 WHERE allowance_id=?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public int countEmployees(int id) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }
}
