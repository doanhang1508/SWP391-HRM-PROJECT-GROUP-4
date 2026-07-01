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

    /**
     * Tìm kiếm phụ cấp theo tên (không phân biệt hoa thường).
     *
     * @param keyword  từ khóa tìm kiếm (null / blank = lấy tất cả)
     * @param statusFilter  "active" = chỉ đang hoạt động,
     *                      "inactive" = chỉ vô hiệu,
     *                      null/"all" = tất cả
     */
    public List<Allowance> search(String keyword, String statusFilter) {
        List<Allowance> list = new ArrayList<>();
        boolean hasKeyword = keyword != null && !keyword.isBlank();
        boolean activeOnly = "active".equalsIgnoreCase(statusFilter);
        boolean inactiveOnly = "inactive".equalsIgnoreCase(statusFilter);

        StringBuilder sql = new StringBuilder("SELECT * FROM allowances WHERE 1=1");
        if (hasKeyword)    sql.append(" AND allowance_name LIKE ?");
        if (activeOnly)    sql.append(" AND status = 1");
        if (inactiveOnly)  sql.append(" AND status = 0");
        sql.append(" ORDER BY status DESC, allowance_name");

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            if (hasKeyword) ps.setString(1, "%" + keyword.trim() + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
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
        String sql = "SELECT COUNT(DISTINCT user_id) FROM employee_allowances WHERE allowance_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return 0;
    }

    /**
     * Lấy danh sách phụ cấp chi tiết của một nhân viên theo hợp đồng cụ thể
     */
    public List<java.util.Map<String, Object>> getAllowancesByContract(int userId, int contractId) {
        List<java.util.Map<String, Object>> list = new java.util.ArrayList<>();
        String sql = "SELECT a.allowance_name, a.amount FROM employee_allowances ea " +
                     "JOIN allowances a ON ea.allowance_id = a.allowance_id " +
                     "WHERE ea.user_id = ? AND ea.contract_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, contractId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    java.util.Map<String, Object> map = new java.util.HashMap<>();
                    map.put("name", rs.getString("allowance_name"));
                    map.put("amount", rs.getDouble("amount"));
                    list.add(map);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Chèn nhiều phụ cấp cho một hợp đồng
     */
    public void insertEmployeeAllowances(int userId, int contractId, java.sql.Date effectiveDate, String[] allowanceIds) {
        if (allowanceIds == null || allowanceIds.length == 0) return;
        String sql = "INSERT INTO employee_allowances (user_id, allowance_id, contract_id, effective_date) " +
                     "VALUES (?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            for (String alwIdStr : allowanceIds) {
                int alwId = Integer.parseInt(alwIdStr);
                ps.setInt(1, userId);
                ps.setInt(2, alwId);
                ps.setInt(3, contractId);
                ps.setDate(4, effectiveDate);
                ps.addBatch();
            }
            ps.executeBatch();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * Lấy danh sách allowance_id đang được hưởng của một nhân viên
     * (lấy từ hợp đồng Active mới nhất — dùng để pre-check trong form phụ lục / điều chuyển).
     */
    public List<Integer> getActiveAllowanceIdsByEmployee(int userId) {
        List<Integer> ids = new java.util.ArrayList<>();
        // Lấy từ hợp đồng Active mới nhất của nhân viên
        String sql = "SELECT ea.allowance_id " +
                     "FROM employee_allowances ea " +
                     "JOIN employee_contracts ec ON ea.contract_id = ec.contract_id " +
                     "WHERE ea.user_id = ? AND ec.status = 'Active' " +
                     "ORDER BY ec.start_date DESC, ec.contract_id DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) ids.add(rs.getInt("allowance_id"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return ids;
    }

    /**
     * Lấy lương cơ bản hiện tại (từ hợp đồng Active mới nhất) của nhân viên.
     * Trả về null nếu không có hợp đồng Active.
     */
    public java.math.BigDecimal getActiveBaseSalaryByEmployee(int userId) {
        String sql = "SELECT base_salary FROM employee_contracts " +
                     "WHERE user_id = ? AND status = 'Active' " +
                     "ORDER BY start_date DESC, contract_id DESC LIMIT 1";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getBigDecimal("base_salary");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}



