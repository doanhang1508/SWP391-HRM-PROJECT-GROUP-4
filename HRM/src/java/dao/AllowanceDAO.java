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

    /**
     * Lấy phụ cấp theo chức vụ
     */
    public List<java.util.Map<String, Object>> getAllowancesByPosition(int positionId) {
        List<java.util.Map<String, Object>> list = new java.util.ArrayList<>();
        String sql = "SELECT a.allowance_id, a.allowance_name, a.amount FROM position_allowances pa " +
                     "JOIN allowances a ON pa.allowance_id = a.allowance_id " +
                     "WHERE pa.position_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, positionId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    java.util.Map<String, Object> map = new java.util.HashMap<>();
                    map.put("id", rs.getInt("allowance_id"));
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
     * Lấy mức phụ cấp thâm niên dựa trên số tháng làm việc
     */
    public BigDecimal getSeniorityAmount(int tenureMonths) {
        String sql = "SELECT amount FROM seniority_rules WHERE min_months <= ? AND (max_months IS NULL OR max_months >= ?) ORDER BY min_months DESC LIMIT 1";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, tenureMonths);
            ps.setInt(2, tenureMonths);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getBigDecimal("amount");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return BigDecimal.ZERO;
    }

    /**
     * Helper method to calculate tenure months from user's first contract
     */
    public int getTenureMonths(int userId) {
        String sql = "SELECT TIMESTAMPDIFF(MONTH, MIN(start_date), CURDATE()) AS months FROM employee_contracts WHERE user_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("months");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Lấy danh sách phụ cấp chi tiết của một hợp đồng (Position + Seniority)
     */
    public List<java.util.Map<String, Object>> getAllowancesByContract(int userId, int contractId) {
        List<java.util.Map<String, Object>> list = new java.util.ArrayList<>();
        
        // 1. Lấy position_id của hợp đồng
        int positionId = -1;
        String sqlPos = "SELECT position_id FROM employee_contracts WHERE contract_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sqlPos)) {
            ps.setInt(1, contractId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) positionId = rs.getInt("position_id");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        if (positionId != -1) {
            // Lấy phụ cấp theo chức vụ
            list.addAll(getAllowancesByPosition(positionId));
        }

        // 2. Tính thâm niên và thêm phụ cấp thâm niên (nếu có)
        int tenureMonths = getTenureMonths(userId);
        BigDecimal seniorityAmount = getSeniorityAmount(tenureMonths);
        if (seniorityAmount.compareTo(BigDecimal.ZERO) > 0) {
            java.util.Map<String, Object> senMap = new java.util.HashMap<>();
            senMap.put("name", "Phụ cấp thâm niên");
            senMap.put("amount", seniorityAmount.doubleValue());
            list.add(senMap);
        }
        
        return list;
    }

    // ─────────────────────────────────────────────────────────────────
    // POSITION-ALLOWANCE MATRIX  (dùng cho màn hình cấu hình ma trận)
    // ─────────────────────────────────────────────────────────────────

    /**
     * Lấy tập hợp allowance_id hiện đang được gán cho một chức vụ.
     * Dùng để render trạng thái checked/unchecked trong ma trận checkbox.
     */
    public java.util.Set<Integer> getAssignedAllowanceIds(int positionId) {
        java.util.Set<Integer> ids = new java.util.HashSet<>();
        String sql = "SELECT allowance_id FROM position_allowances WHERE position_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, positionId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) ids.add(rs.getInt("allowance_id"));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return ids;
    }

    /**
     * Thay toàn bộ phụ cấp của một chức vụ bằng tập hợp mới (replace strategy).
     * Sử dụng transaction: xóa cũ → insert mới.
     *
     * @param positionId   ID chức vụ cần cập nhật
     * @param allowanceIds tập hợp allowance_id được chọn (rỗng = bỏ hết)
     * @return true nếu thành công
     */
    public boolean setAllowancesForPosition(int positionId, java.util.Set<Integer> allowanceIds) {
        String del = "DELETE FROM position_allowances WHERE position_id = ?";
        String ins = "INSERT INTO position_allowances (position_id, allowance_id) VALUES (?, ?)";
        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement ps = conn.prepareStatement(del)) {
                    ps.setInt(1, positionId);
                    ps.executeUpdate();
                }
                if (allowanceIds != null && !allowanceIds.isEmpty()) {
                    try (PreparedStatement ps = conn.prepareStatement(ins)) {
                        for (int aid : allowanceIds) {
                            ps.setInt(1, positionId);
                            ps.setInt(2, aid);
                            ps.addBatch();
                        }
                        ps.executeBatch();
                    }
                }
                conn.commit();
                return true;
            } catch (Exception ex) {
                conn.rollback();
                ex.printStackTrace();
                return false;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
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



