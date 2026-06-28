package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import model.EmployeeContract;
import util.DBContext;

public class EmployeeContractDAO {

    private EmployeeContract mapRow(ResultSet rs) throws Exception {
        EmployeeContract c = new EmployeeContract();
        c.setContractId(rs.getInt("contract_id"));
        c.setUserId(rs.getInt("user_id"));
        c.setContractTypeId(rs.getInt("contract_type_id"));
        c.setStartDate(rs.getDate("start_date"));
        c.setEndDate(rs.getDate("end_date"));
        c.setBaseSalary(rs.getBigDecimal("base_salary"));
        c.setBhxhRate(rs.getBigDecimal("bhxh_rate"));
        c.setBhytRate(rs.getBigDecimal("bhyt_rate"));
        c.setBhtnRate(rs.getBigDecimal("bhtn_rate"));
        c.setTaxCalcType(rs.getInt("tax_calc_type"));
        c.setStatus(rs.getString("status"));
        c.setCreatedAt(rs.getTimestamp("created_at"));
        // Addendum fields
        try { c.setDocType(rs.getString("doc_type")); } catch (Exception e) {}
        try {
            int pid = rs.getInt("parent_contract_id");
            if (!rs.wasNull()) c.setParentContractId(pid);
        } catch (Exception e) {}
        try { c.setAddendumReason(rs.getString("addendum_reason")); } catch (Exception e) {}
        try { c.setSignStatus(rs.getString("sign_status")); } catch (Exception e) {}
        try { c.setSignedAt(rs.getTimestamp("signed_at")); } catch (Exception e) {}
        try { c.setRejectReason(rs.getString("reject_reason")); } catch (Exception e) {}
        // Joined fields
        try { c.setContractTypeName(rs.getString("type_name")); } catch (Exception e) {}
        return c;
    }

    public List<EmployeeContract> getByUserId(int userId) {
        List<EmployeeContract> list = new ArrayList<>();
        String sql = "SELECT ec.*, ct.type_name FROM employee_contracts ec " +
                     "JOIN contract_types ct ON ec.contract_type_id = ct.contract_type_id " +
                     "WHERE ec.user_id = ? ORDER BY ec.start_date DESC, ec.contract_id DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public EmployeeContract getActiveContract(int userId) {
        String sql = "SELECT ec.*, ct.type_name FROM employee_contracts ec " +
                     "JOIN contract_types ct ON ec.contract_type_id = ct.contract_type_id " +
                     "WHERE ec.user_id = ? AND ec.status = 'Active' " +
                     "ORDER BY ec.start_date DESC LIMIT 1";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean insert(EmployeeContract c) {
        String status = c.getStatus() != null && !c.getStatus().trim().isEmpty() ? c.getStatus() : "Active";
        String sqlDeactivate = "UPDATE employee_contracts SET status = 'Expired' WHERE user_id = ? AND status = 'Active'";
        String sqlInsert = "INSERT INTO employee_contracts (user_id, contract_type_id, start_date, end_date, " +
                           "base_salary, bhxh_rate, bhyt_rate, bhtn_rate, tax_calc_type, status) " +
                           "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                           
        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement ps1 = conn.prepareStatement(sqlDeactivate);
                 PreparedStatement ps2 = conn.prepareStatement(sqlInsert, java.sql.Statement.RETURN_GENERATED_KEYS)) {
                 
                if ("Active".equalsIgnoreCase(status)) {
                    ps1.setInt(1, c.getUserId());
                    ps1.executeUpdate();
                }
                
                ps2.setInt(1, c.getUserId());
                ps2.setInt(2, c.getContractTypeId());
                ps2.setDate(3, c.getStartDate());
                ps2.setDate(4, c.getEndDate());
                ps2.setBigDecimal(5, c.getBaseSalary());
                ps2.setBigDecimal(6, c.getBhxhRate());
                ps2.setBigDecimal(7, c.getBhytRate());
                ps2.setBigDecimal(8, c.getBhtnRate());
                ps2.setInt(9, c.getTaxCalcType());
                ps2.setString(10, status);
                
                ps2.executeUpdate();
                
                try (ResultSet rsKeys = ps2.getGeneratedKeys()) {
                    if (rsKeys.next()) {
                        c.setContractId(rsKeys.getInt(1));
                    }
                }
                
                conn.commit();
                return true;
            } catch (Exception e) {
                conn.rollback();
                e.printStackTrace();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean approveContract(int contractId, int userId) {
        String sqlDeactivate = "UPDATE employee_contracts SET status = 'Expired' WHERE user_id = ? AND status = 'Active'";
        String sqlApprove = "UPDATE employee_contracts SET status = 'Active' WHERE contract_id = ?";
        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement ps1 = conn.prepareStatement(sqlDeactivate);
                 PreparedStatement ps2 = conn.prepareStatement(sqlApprove)) {
                
                ps1.setInt(1, userId);
                ps1.executeUpdate();
                
                ps2.setInt(1, contractId);
                int rows = ps2.executeUpdate();
                
                conn.commit();
                return rows > 0;
            } catch (Exception e) {
                conn.rollback();
                e.printStackTrace();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public Map<String, Integer> getContractCounts() {
        Map<String, Integer> counts = new HashMap<>();
        counts.put("all", 0);
        counts.put("active", 0);
        counts.put("expiring", 0);
        counts.put("expired", 0);

        String sql = "SELECT status, end_date FROM employee_contracts";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
             
            int total = 0, active = 0, expired = 0, expiring = 0;
            long now = System.currentTimeMillis();
            long thirtyDays = 30L * 24 * 60 * 60 * 1000;
            
            while (rs.next()) {
                total++;
                String status = rs.getString("status");
                if ("Active".equalsIgnoreCase(status)) {
                    java.sql.Date endDate = rs.getDate("end_date");
                    if (endDate != null && endDate.getTime() < now) {
                        expired++;
                    } else {
                        active++;
                        if (endDate != null) {
                            long diff = endDate.getTime() - now;
                            if (diff > 0 && diff <= thirtyDays) {
                                expiring++;
                            }
                        }
                    }
                } else if ("Expired".equalsIgnoreCase(status)) {
                    expired++;
                }
            }
            counts.put("all", total);
            counts.put("active", active);
            counts.put("expiring", expiring);
            counts.put("expired", expired);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return counts;
    }

    public List<EmployeeContract> getAllContractsWithSearch(String statusFilter, String search) {
        List<EmployeeContract> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT ec.*, ct.type_name, u.full_name, ep.id_card, d.department_name " +
            "FROM employee_contracts ec " +
            "JOIN contract_types ct ON ec.contract_type_id = ct.contract_type_id " +
            "JOIN users u ON ec.user_id = u.user_id " +
            "LEFT JOIN employee_profiles ep ON u.user_id = ep.user_id " +
            "LEFT JOIN departments d ON ep.department_id = d.department_id " +
            "WHERE 1=1 "
        );

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (u.full_name LIKE ? OR ep.id_card LIKE ?) ");
        }

        if (statusFilter != null && !statusFilter.isEmpty() && !statusFilter.equals("all")) {
            if (statusFilter.equals("active")) {
                sql.append("AND ec.status = 'Active' AND (ec.end_date IS NULL OR ec.end_date >= CURRENT_DATE) ");
            } else if (statusFilter.equals("expired")) {
                sql.append("AND (ec.status = 'Expired' OR (ec.status = 'Active' AND ec.end_date < CURRENT_DATE)) ");
            } else if (statusFilter.equals("expiring")) {
                sql.append("AND ec.status = 'Active' AND ec.end_date IS NOT NULL AND DATEDIFF(ec.end_date, CURRENT_DATE) <= 30 AND DATEDIFF(ec.end_date, CURRENT_DATE) >= 0 ");
            }
        }
        sql.append("ORDER BY ec.status ASC, ec.start_date DESC");

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
             
            if (search != null && !search.trim().isEmpty()) {
                String term = "%" + search.trim() + "%";
                ps.setString(1, term);
                ps.setString(2, term);
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    EmployeeContract c = mapRow(rs);
                    c.setEmployeeName(rs.getString("full_name"));
                    c.setEmployeeCode(rs.getString("id_card"));
                    c.setDepartmentName(rs.getString("department_name"));
                    list.add(c);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    
    public List<Map<String, Object>> getContractTypeStats() {
        List<Map<String, Object>> stats = new ArrayList<>();
        String sql = "SELECT ct.type_name, COUNT(ec.contract_id) as count " +
                     "FROM employee_contracts ec " +
                     "JOIN contract_types ct ON ec.contract_type_id = ct.contract_type_id " +
                     "WHERE ec.status = 'Active' " +
                     "GROUP BY ct.type_name ORDER BY count DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("typeName", rs.getString("type_name"));
                map.put("count", rs.getInt("count"));
                stats.add(map);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return stats;
    }

    // ── Phụ lục Hợp đồng (Addendum) methods ─────────────────────────────────

    /**
     * Lấy phụ lục đang chờ ký của nhân viên (sign_status = 'PENDING').
     * Dùng để hiện banner thông báo trên trang my-contract.
     */
    public EmployeeContract getPendingAddendum(int userId) {
        String sql = "SELECT ec.*, ct.type_name FROM employee_contracts ec " +
                     "JOIN contract_types ct ON ec.contract_type_id = ct.contract_type_id " +
                     "WHERE ec.user_id = ? AND ec.doc_type = 'ADDENDUM' AND ec.sign_status = 'PENDING' " +
                     "ORDER BY ec.created_at DESC LIMIT 1";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    /**
     * Nhân viên xác nhận hoặc từ chối ký phụ lục.
     * @param contractId  ID của phụ lục
     * @param userId      Mã nhân viên (bảo mật: chỉ chính chủ mới được xác nhận)
     * @param action      "SIGNED" hoặc "REJECTED"
     * @param rejectReason Lý do từ chối (chỉ cần khi action=REJECTED)
     */
    public boolean updateSignStatus(int contractId, int userId, String action, String rejectReason) {
        String sql = "UPDATE employee_contracts " +
                     "SET sign_status = ?, signed_at = NOW(), reject_reason = ? " +
                     "WHERE contract_id = ? AND user_id = ? AND doc_type = 'ADDENDUM' AND sign_status = 'PENDING'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, action);
            ps.setString(2, rejectReason);
            ps.setInt(3, contractId);
            ps.setInt(4, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    /**
     * HR tạo Phụ lục Hợp đồng mới (không Expire hợp đồng gốc, chỉ thêm bản ghi mới).
     * Phụ lục sẽ có hiệu lực sau khi nhân viên SIGNED.
     */
    public boolean insertAddendum(EmployeeContract addendum) {
        String sql = "INSERT INTO employee_contracts " +
                     "(user_id, contract_type_id, start_date, end_date, base_salary, " +
                     " bhxh_rate, bhyt_rate, bhtn_rate, tax_calc_type, status, " +
                     " doc_type, parent_contract_id, addendum_reason, sign_status) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'Active', 'ADDENDUM', ?, ?, 'PENDING')";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, addendum.getUserId());
            ps.setInt(2, addendum.getContractTypeId());
            ps.setDate(3, addendum.getStartDate());
            ps.setDate(4, addendum.getEndDate());
            ps.setBigDecimal(5, addendum.getBaseSalary());
            ps.setBigDecimal(6, addendum.getBhxhRate());
            ps.setBigDecimal(7, addendum.getBhytRate());
            ps.setBigDecimal(8, addendum.getBhtnRate());
            ps.setInt(9, addendum.getTaxCalcType());
            if (addendum.getParentContractId() != null) {
                ps.setInt(10, addendum.getParentContractId());
            } else {
                ps.setNull(10, java.sql.Types.INTEGER);
            }
            ps.setString(11, addendum.getAddendumReason());
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }
}
