package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import model.EmployeeContract;
import util.DBContext;

/**
 * DAO cho bảng employee_contracts.
 * Hỗ trợ: hợp đồng gốc (CONTRACT) và phụ lục (ADDENDUM),
 * workflow duyệt hợp đồng Pending → Active, và ký phụ lục.
 */
public class EmployeeContractDAO {

    // =========================================================================
    // Helper: Map ResultSet → EmployeeContract
    // =========================================================================
    private EmployeeContract mapRow(ResultSet rs) throws SQLException {
        EmployeeContract c = new EmployeeContract();
        c.setContractId(rs.getInt("contract_id"));
        c.setUserId(rs.getInt("user_id"));
        c.setContractTypeId(rs.getInt("contract_type_id"));
        c.setPositionId(rs.getInt("position_id"));
        c.setDepartmentId(rs.getInt("department_id"));
        c.setSalaryGradeId(rs.getInt("salary_grade_id"));
        c.setStartDate(rs.getDate("start_date"));
        c.setEndDate(rs.getDate("end_date"));
        c.setBaseSalary(rs.getBigDecimal("base_salary"));
        c.setTaxCalcType(rs.getInt("tax_calc_type"));
        c.setFilePath(rs.getString("file_path"));
        c.setDocType(rs.getString("doc_type"));

        int parentId = rs.getInt("parent_contract_id");
        c.setParentContractId(rs.wasNull() ? null : parentId);

        c.setAddendumReason(rs.getString("addendum_reason"));
        c.setStatus(rs.getString("status"));
        c.setSignStatus(rs.getString("sign_status"));

        Timestamp signedAt = rs.getTimestamp("signed_at");
        c.setSignedAt(rs.wasNull() ? null : signedAt);

        c.setRejectReason(rs.getString("reject_reason"));
        c.setCreatedAt(rs.getTimestamp("created_at"));
        c.setUpdatedAt(rs.getTimestamp("updated_at"));

        // JOIN fields (có thể null nếu query không join)
        try { c.setContractTypeName(rs.getString("type_name")); } catch (SQLException e) {}
        try { c.setPositionName(rs.getString("position_name")); } catch (SQLException e) {}
        try { c.setDepartmentName(rs.getString("department_name")); } catch (SQLException e) {}
        try { c.setSalaryGradeName(rs.getString("grade_name")); } catch (SQLException e) {}
        try { c.setFullName(rs.getString("full_name")); } catch (SQLException e) {}

        return c;
    }

    // =========================================================================
    // READ: Lấy danh sách hợp đồng theo user
    // =========================================================================

    /**
     * Lấy tất cả hợp đồng + phụ lục của một nhân viên, sắp xếp theo ngày bắt đầu giảm dần.
     */
    public List<EmployeeContract> getByUserId(int userId) {
        List<EmployeeContract> list = new ArrayList<>();
        String sql = "SELECT ec.*, ct.type_name, p.position_name, d.department_name, sg.grade_name " +
                     "FROM employee_contracts ec " +
                     "LEFT JOIN contract_types ct ON ec.contract_type_id = ct.contract_type_id " +
                     "LEFT JOIN positions p ON ec.position_id = p.position_id " +
                     "LEFT JOIN departments d ON ec.department_id = d.department_id " +
                     "LEFT JOIN salary_grades sg ON ec.salary_grade_id = sg.salary_grade_id " +
                     "WHERE ec.user_id = ? " +
                     "ORDER BY ec.start_date DESC, ec.contract_id DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy hợp đồng ĐANG HIỆU LỰC (status = 'Active') của một nhân viên.
     * Ưu tiên hợp đồng gốc trước, phụ lục Active sau.
     */
    public EmployeeContract getActiveContract(int userId) {
        String sql = "SELECT ec.*, ct.type_name, p.position_name, d.department_name, sg.grade_name " +
                     "FROM employee_contracts ec " +
                     "LEFT JOIN contract_types ct ON ec.contract_type_id = ct.contract_type_id " +
                     "LEFT JOIN positions p ON ec.position_id = p.position_id " +
                     "LEFT JOIN departments d ON ec.department_id = d.department_id " +
                     "LEFT JOIN salary_grades sg ON ec.salary_grade_id = sg.salary_grade_id " +
                     "WHERE ec.user_id = ? AND ec.status = 'Active' " +
                     "ORDER BY ec.start_date DESC, ec.contract_id DESC " +
                     "LIMIT 1";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Lấy phụ lục đang chờ nhân viên xác nhận (sign_status = 'PENDING').
     */
    public EmployeeContract getPendingAddendum(int userId) {
        String sql = "SELECT ec.*, ct.type_name, p.position_name, d.department_name, sg.grade_name " +
                     "FROM employee_contracts ec " +
                     "LEFT JOIN contract_types ct ON ec.contract_type_id = ct.contract_type_id " +
                     "LEFT JOIN positions p ON ec.position_id = p.position_id " +
                     "LEFT JOIN departments d ON ec.department_id = d.department_id " +
                     "LEFT JOIN salary_grades sg ON ec.salary_grade_id = sg.salary_grade_id " +
                     "WHERE ec.user_id = ? AND ec.doc_type = 'ADDENDUM' AND ec.sign_status = 'PENDING' " +
                     "ORDER BY ec.created_at DESC LIMIT 1";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // =========================================================================
    // READ: Dành cho trang quản lý hợp đồng (HR)
    // =========================================================================

    /**
     * Lấy tất cả hợp đồng với bộ lọc status và tìm kiếm tên nhân viên.
     * Dùng cho trang /hr/contracts (HrContractManagementController).
     */
    public List<EmployeeContract> getAllContractsWithSearch(String statusFilter, String searchQuery) {
        List<EmployeeContract> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT ec.*, ct.type_name, p.position_name, d.department_name, sg.grade_name, u.full_name " +
            "FROM employee_contracts ec " +
            "LEFT JOIN contract_types ct ON ec.contract_type_id = ct.contract_type_id " +
            "LEFT JOIN positions p ON ec.position_id = p.position_id " +
            "LEFT JOIN departments d ON ec.department_id = d.department_id " +
            "LEFT JOIN salary_grades sg ON ec.salary_grade_id = sg.salary_grade_id " +
            "LEFT JOIN users u ON ec.user_id = u.user_id " +
            "WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();

        if (statusFilter != null && !statusFilter.isEmpty() && !"all".equalsIgnoreCase(statusFilter)) {
            if ("expiring".equalsIgnoreCase(statusFilter)) {
                // Sắp hết hạn trong 30 ngày
                sql.append("AND ec.status = 'Active' AND ec.end_date IS NOT NULL " +
                           "AND ec.end_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 30 DAY) ");
            } else {
                sql.append("AND ec.status = ? ");
                params.add(statusFilter);
            }
        }

        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            sql.append("AND u.full_name LIKE ? ");
            params.add("%" + searchQuery.trim() + "%");
        }

        sql.append("ORDER BY ec.start_date DESC, ec.contract_id DESC");

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Đếm số hợp đồng theo từng trạng thái.
     * Dùng cho widget thống kê trang /hr/contracts.
     */
    public Map<String, Integer> getContractCounts() {
        Map<String, Integer> counts = new HashMap<>();
        String sql = "SELECT " +
                     "COUNT(*) AS total, " +
                     "SUM(CASE WHEN status = 'Active' THEN 1 ELSE 0 END) AS active, " +
                     "SUM(CASE WHEN status = 'Pending' THEN 1 ELSE 0 END) AS pending, " +
                     "SUM(CASE WHEN status = 'Expired' THEN 1 ELSE 0 END) AS expired, " +
                     "SUM(CASE WHEN status = 'Terminated' THEN 1 ELSE 0 END) AS terminated, " +
                     "SUM(CASE WHEN status = 'Active' AND end_date IS NOT NULL " +
                     "         AND end_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 30 DAY) THEN 1 ELSE 0 END) AS expiring " +
                     "FROM employee_contracts";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                counts.put("total",      rs.getInt("total"));
                counts.put("active",     rs.getInt("active"));
                counts.put("pending",    rs.getInt("pending"));
                counts.put("expired",    rs.getInt("expired"));
                counts.put("terminated", rs.getInt("terminated"));
                counts.put("expiring",   rs.getInt("expiring"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return counts;
    }

    /**
     * Thống kê phân loại hợp đồng theo loại hợp đồng (type_name).
     * Dùng cho widget trang /hr/contracts.
     */
    public List<Map<String, Object>> getContractTypeStats() {
        List<Map<String, Object>> stats = new ArrayList<>();
        String sql = "SELECT ct.type_name, COUNT(*) AS cnt " +
                     "FROM employee_contracts ec " +
                     "JOIN contract_types ct ON ec.contract_type_id = ct.contract_type_id " +
                     "WHERE ec.status = 'Active' " +
                     "GROUP BY ct.type_name ORDER BY cnt DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> m = new HashMap<>();
                m.put("typeName", rs.getString("type_name"));
                m.put("count",    rs.getInt("cnt"));
                stats.add(m);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return stats;
    }

    // =========================================================================
    // READ: Trang phê duyệt hợp đồng (HrContractApprovalController)
    // =========================================================================

    /**
     * Lấy danh sách hợp đồng Pending cho trang duyệt của HR Manager.
     */
    public List<EmployeeContract> getAllApprovalContracts(String statusFilter, String search) {
        List<EmployeeContract> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT ec.*, ct.type_name, p.position_name, d.department_name, sg.grade_name, u.full_name " +
            "FROM employee_contracts ec " +
            "LEFT JOIN contract_types ct ON ec.contract_type_id = ct.contract_type_id " +
            "LEFT JOIN positions p ON ec.position_id = p.position_id " +
            "LEFT JOIN departments d ON ec.department_id = d.department_id " +
            "LEFT JOIN salary_grades sg ON ec.salary_grade_id = sg.salary_grade_id " +
            "LEFT JOIN users u ON ec.user_id = u.user_id " +
            "WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();

        if (statusFilter != null && !statusFilter.isEmpty() && !"all".equalsIgnoreCase(statusFilter)) {
            sql.append("AND ec.status = ? ");
            params.add(statusFilter);
        } else {
            // Mặc định chỉ hiển thị Pending
            sql.append("AND ec.status = 'Pending' ");
        }

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND u.full_name LIKE ? ");
            params.add("%" + search.trim() + "%");
        }

        sql.append("ORDER BY ec.created_at DESC");

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Đếm số hợp đồng cần duyệt (Pending / Active / All).
     */
    public Map<String, Integer> getApprovalCounts() {
        Map<String, Integer> counts = new HashMap<>();
        String sql = "SELECT " +
                     "COUNT(*) AS total, " +
                     "SUM(CASE WHEN status = 'Pending'  THEN 1 ELSE 0 END) AS pending, " +
                     "SUM(CASE WHEN status = 'Active'   THEN 1 ELSE 0 END) AS active, " +
                     "SUM(CASE WHEN status = 'Rejected' THEN 1 ELSE 0 END) AS rejected " +
                     "FROM employee_contracts";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                counts.put("total",    rs.getInt("total"));
                counts.put("pending",  rs.getInt("pending"));
                counts.put("active",   rs.getInt("active"));
                counts.put("rejected", rs.getInt("rejected"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return counts;
    }

    // =========================================================================
    // WRITE: Thêm hợp đồng mới
    // =========================================================================

    /**
     * Thêm một hợp đồng gốc mới. Sau khi insert, contractId được set lại vào object.
     */
    public boolean insert(EmployeeContract c) {
        String sql = "INSERT INTO employee_contracts " +
                     "(user_id, contract_type_id, position_id, department_id, salary_grade_id, " +
                     " start_date, end_date, base_salary, tax_calc_type, status, doc_type, sign_status) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'CONTRACT', 'N/A')";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, c.getUserId());
            ps.setInt(2, c.getContractTypeId());
            ps.setInt(3, c.getPositionId());
            ps.setInt(4, c.getDepartmentId());
            ps.setInt(5, c.getSalaryGradeId());
            ps.setDate(6, c.getStartDate());
            if (c.getEndDate() != null) ps.setDate(7, c.getEndDate());
            else ps.setNull(7, java.sql.Types.DATE);
            ps.setBigDecimal(8, c.getBaseSalary());
            ps.setInt(9, c.getTaxCalcType());
            ps.setString(10, c.getStatus());

            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) c.setContractId(keys.getInt(1));
                }
                return true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Thêm phụ lục hợp đồng (ADDENDUM).
     * Sau khi insert, contractId được set lại vào object.
     */
    public boolean insertAddendum(EmployeeContract c) {
        String sql = "INSERT INTO employee_contracts " +
                     "(user_id, contract_type_id, position_id, department_id, salary_grade_id, " +
                     " start_date, end_date, base_salary, tax_calc_type, " +
                     " doc_type, parent_contract_id, addendum_reason, status, sign_status) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'ADDENDUM', ?, ?, 'Active', 'PENDING')";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, c.getUserId());
            ps.setInt(2, c.getContractTypeId());
            ps.setInt(3, c.getPositionId());
            ps.setInt(4, c.getDepartmentId());
            ps.setInt(5, c.getSalaryGradeId() > 0 ? c.getSalaryGradeId() : 1); // default grade
            ps.setDate(6, c.getStartDate());
            if (c.getEndDate() != null) ps.setDate(7, c.getEndDate());
            else ps.setNull(7, java.sql.Types.DATE);
            ps.setBigDecimal(8, c.getBaseSalary());
            ps.setInt(9, c.getTaxCalcType());
            if (c.getParentContractId() != null) ps.setInt(10, c.getParentContractId());
            else ps.setNull(10, java.sql.Types.INTEGER);
            ps.setString(11, c.getAddendumReason());

            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) c.setContractId(keys.getInt(1));
                }
                return true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // =========================================================================
    // WRITE: Duyệt / Từ chối hợp đồng (HR Manager)
    // =========================================================================

    /**
     * Duyệt hợp đồng Pending → Active.
     * Đồng thời cập nhật profile nhân viên với contract_type_id và salary_grade_id.
     */
    public boolean approveContract(int contractId, int userId) {
        String sqlUpdate = "UPDATE employee_contracts SET status = 'Active' " +
                           "WHERE contract_id = ? AND user_id = ? AND status = 'Pending'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sqlUpdate)) {
            ps.setInt(1, contractId);
            ps.setInt(2, userId);
            int rows = ps.executeUpdate();
            if (rows > 0) {
                // Cập nhật employee_profiles
                String sqlProfile = "UPDATE employee_profiles ep " +
                                    "JOIN employee_contracts ec ON ec.contract_id = ? " +
                                    "SET ep.contract_type_id = ec.contract_type_id, " +
                                    "    ep.salary_grade_id  = ec.salary_grade_id " +
                                    "WHERE ep.user_id = ?";
                try (PreparedStatement ps2 = conn.prepareStatement(sqlProfile)) {
                    ps2.setInt(1, contractId);
                    ps2.setInt(2, userId);
                    ps2.executeUpdate();
                }
                return true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Từ chối hợp đồng Pending → Rejected (dùng 'Terminated' hoặc status riêng).
     * Lưu lý do từ chối vào cột reject_reason.
     */
    public boolean rejectContract(int contractId, String reason) {
        String sql = "UPDATE employee_contracts SET status = 'Terminated', reject_reason = ? " +
                     "WHERE contract_id = ? AND status = 'Pending'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, reason);
            ps.setInt(2, contractId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // =========================================================================
    // WRITE: Nhân viên ký / từ chối phụ lục
    // =========================================================================

    /**
     * Cập nhật trạng thái ký phụ lục của nhân viên.
     * action: "SIGNED" | "REJECTED"
     */
    public boolean updateSignStatus(int contractId, int userId, String action, String rejectReason) {
        String sql = "UPDATE employee_contracts SET sign_status = ?, signed_at = NOW(), reject_reason = ? " +
                     "WHERE contract_id = ? AND user_id = ? AND sign_status = 'PENDING'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, action);
            ps.setString(2, rejectReason);
            ps.setInt(3, contractId);
            ps.setInt(4, userId);
            int rows = ps.executeUpdate();
            if (rows > 0 && "SIGNED".equals(action)) {
                // Sau khi SIGNED: cập nhật lương trong bảng employee_profiles từ phụ lục
                String sqlProfile = "UPDATE employee_profiles ep " +
                                    "JOIN employee_contracts ec ON ec.contract_id = ? " +
                                    "SET ep.contract_type_id = ec.contract_type_id, " +
                                    "    ep.salary_grade_id  = ec.salary_grade_id " +
                                    "WHERE ep.user_id = ?";
                try (PreparedStatement ps2 = conn.prepareStatement(sqlProfile)) {
                    ps2.setInt(1, contractId);
                    ps2.setInt(2, userId);
                    ps2.executeUpdate();
                }
            }
            return rows > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // =========================================================================
    // Utility
    // =========================================================================

    /**
     * Lấy 1 hợp đồng theo ID.
     */
    public EmployeeContract getById(int contractId) {
        String sql = "SELECT ec.*, ct.type_name, p.position_name, d.department_name, sg.grade_name " +
                     "FROM employee_contracts ec " +
                     "LEFT JOIN contract_types ct ON ec.contract_type_id = ct.contract_type_id " +
                     "LEFT JOIN positions p ON ec.position_id = p.position_id " +
                     "LEFT JOIN departments d ON ec.department_id = d.department_id " +
                     "LEFT JOIN salary_grades sg ON ec.salary_grade_id = sg.salary_grade_id " +
                     "WHERE ec.contract_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, contractId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
