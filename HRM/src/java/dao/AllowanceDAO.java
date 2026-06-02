package dao;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.Allowance;
import util.DBContext;

public class AllowanceDAO {

    private Allowance mapRow(ResultSet rs) throws Exception {
        return new Allowance(
            rs.getInt("allowance_id"),
            rs.getString("allowance_name"),
            rs.getString("description"),
            rs.getBigDecimal("amount"),
            rs.getString("apply_condition"),
            rs.getBoolean("status")
        );
    }

    /** Lấy tất cả phụ cấp (cả active lẫn inactive) */
    public List<Allowance> getAll() {
        List<Allowance> list = new ArrayList<>();
        String sql = "SELECT * FROM allowances ORDER BY status DESC, allowance_id";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    /** Lấy phụ cấp đang hoạt động */
    public List<Allowance> getActive() {
        List<Allowance> list = new ArrayList<>();
        String sql = "SELECT * FROM allowances WHERE status = 1 ORDER BY allowance_id";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    /** Lấy chi tiết theo ID */
    public Allowance getById(int id) {
        String sql = "SELECT * FROM allowances WHERE allowance_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    /** Kiểm tra trùng tên (bỏ qua chính nó khi update) */
    public boolean isDuplicate(String allowanceName, int excludeId) {
        String sql = "SELECT COUNT(*) FROM allowances WHERE allowance_name = ? AND allowance_id != ? AND status = 1";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, allowanceName);
            ps.setInt(2, excludeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    /** Thêm phụ cấp mới */
    public void insert(Allowance a) {
        String sql = "INSERT INTO allowances (allowance_name, description, amount, apply_condition, status) VALUES (?, ?, ?, ?, 1)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, a.getAllowanceName());
            ps.setString(2, a.getDescription());
            ps.setBigDecimal(3, a.getAmount());
            ps.setString(4, a.getApplyCondition());
            ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
    }

    /** Cập nhật phụ cấp (tên, mô tả, mức tiền, điều kiện) */
    public void update(Allowance a) {
        String sql = "UPDATE allowances SET allowance_name=?, description=?, amount=?, apply_condition=? WHERE allowance_id=?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, a.getAllowanceName());
            ps.setString(2, a.getDescription());
            ps.setBigDecimal(3, a.getAmount());
            ps.setString(4, a.getApplyCondition());
            ps.setInt(5, a.getAllowanceId());
            ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
    }

    /** Vô hiệu hóa (soft-delete) */
    public void deactivate(int id) {
        String sql = "UPDATE allowances SET status = 0 WHERE allowance_id=?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
    }

    /** Kích hoạt lại */
    public void activate(int id) {
        String sql = "UPDATE allowances SET status = 1 WHERE allowance_id=?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
    }

    /** Đếm số nhân viên đang hưởng phụ cấp này */
    public int countEmployees(int id) {
        // Placeholder – kết nối với bảng employee_allowances khi có
        return 0;
    }
}
