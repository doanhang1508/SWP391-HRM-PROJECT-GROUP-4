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
        try { c.setActualEndDate(rs.getDate("actual_end_date")); } catch(SQLException e) {}
        try { c.setTerminationReason(rs.getString("termination_reason")); } catch(SQLException e) {}
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
     * Lấy hợp đồng đang có hiệu lực vào một ngày cụ thể, bất kể status.
     * Dùng riêng cho luồng tính lương (PayrollDAO.generatePayrollDraft).
     *
     * Lý do KHÔNG lọc theo status:
     * - Khi HR duyệt đơn nghỉ việc, hợp đồng chuyển sang status='Terminated' ngay lập tức.
     * - Nhân viên nghỉ giữa kỳ (Case 2) vẫn cần lấy đúng base_salary/tax_calc_type từ
     *   hợp đồng đã Terminated đó để tính lương đến ngày nghỉ.
     * - Nếu dùng getActiveContract() (lọc status='Active') sẽ trả về null cho case này
     *   → rơi vào fallback sai (salary_grades.min_salary, taxCalcType=1 mặc định).
     *
     * @param userId    user_id của nhân viên
     * @param asOfDate  ngày cần kiểm tra (thường = ngày cuối tháng lương)
     * @return hợp đồng hiệu lực vào ngày đó, hoặc null nếu không có
     */
    public EmployeeContract getContractForMonth(int userId, java.sql.Date firstDay, java.sql.Date lastDay) {
        String sql = "SELECT ec.*, ct.type_name, p.position_name, d.department_name, sg.grade_name " +
                     "FROM employee_contracts ec " +
                     "LEFT JOIN contract_types ct ON ec.contract_type_id = ct.contract_type_id " +
                     "LEFT JOIN positions p ON ec.position_id = p.position_id " +
                     "LEFT JOIN departments d ON ec.department_id = d.department_id " +
                     "LEFT JOIN salary_grades sg ON ec.salary_grade_id = sg.salary_grade_id " +
                     "WHERE ec.user_id = ? " +
                     "  AND ec.status IN ('Active', 'Terminated', 'Expired') " +
                     "  AND ec.sign_status IN ('SIGNED', 'N/A') " +
                     "  AND ec.start_date <= ? " +
                     "  AND (ec.end_date IS NULL OR ec.end_date >= ?) " +
                     "  AND (ec.actual_end_date IS NULL OR ec.actual_end_date >= ?) " +
                     "ORDER BY ec.start_date DESC, ec.contract_id DESC " +
                     "LIMIT 1";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setDate(2, lastDay);
            ps.setDate(3, firstDay);
            ps.setDate(4, firstDay);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Lấy danh sách các hợp đồng/phụ lục đang chờ nhân viên xác nhận (sign_status = 'PENDING').
     * Lưu ý: Chỉ lấy các hợp đồng đã được duyệt nội dung (Active) hoặc đang chờ nội dung (Pending) tuỳ luồng.
     * Luồng của chúng ta: HR duyệt -> Active, sign_status = PENDING -> NV thấy và Ký.
     */
    public List<EmployeeContract> getPendingSignContracts(int userId) {
        List<EmployeeContract> list = new ArrayList<>();
        String sql = "SELECT ec.*, ct.type_name, p.position_name, d.department_name, sg.grade_name " +
                     "FROM employee_contracts ec " +
                     "LEFT JOIN contract_types ct ON ec.contract_type_id = ct.contract_type_id " +
                     "LEFT JOIN positions p ON ec.position_id = p.position_id " +
                     "LEFT JOIN departments d ON ec.department_id = d.department_id " +
                     "LEFT JOIN salary_grades sg ON ec.salary_grade_id = sg.salary_grade_id " +
                     "WHERE ec.user_id = ? AND ec.sign_status = 'PENDING' " +
                     "ORDER BY ec.created_at DESC";
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

    public List<EmployeeContract> getExpiringContracts(int daysThreshold) {
        List<EmployeeContract> list = new ArrayList<>();
        String sql = "SELECT ec.*, u.full_name AS employee_name, ct.type_name AS contract_type_name " +
                     "FROM employee_contracts ec " +
                     "JOIN users u ON ec.user_id = u.user_id " +
                     "LEFT JOIN contract_types ct ON ec.contract_type_id = ct.contract_type_id " +
                     "WHERE ec.status = 'Active' AND ec.end_date IS NOT NULL " +
                     "  AND ec.end_date <= DATE_ADD(CURDATE(), INTERVAL ? DAY) " +
                     "ORDER BY ec.end_date ASC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, daysThreshold);
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
                     "SUM(CASE WHEN status = 'Terminated' THEN 1 ELSE 0 END) AS `terminated`, " +
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
            if ("approved".equalsIgnoreCase(statusFilter)) {
                sql.append("AND ec.status = 'Active' ");
            } else if ("rejected".equalsIgnoreCase(statusFilter)) {
                sql.append("AND ec.status = 'Rejected' ");
            } else {
                sql.append("AND ec.status = 'Pending' ");
            }
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
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'CONTRACT', 'PENDING')";
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
     * Thêm phụ lục hợp đồng (ADDENDUM) dùng chung Connection từ bên ngoài.
     * Dùng trong approveTransferRequest() để đảm bảo cùng 1 transaction.
     * status='Active', sign_status='SIGNED' vì ADDENDUM từ điều chuyển đã qua duyệt quản lý.
     *
     * @param conn Connection đang dùng (đã setAutoCommit(false))
     * @param c    EmployeeContract object chứa dữ liệu ADDENDUM
     * @return true nếu insert thành công
     */
    public boolean insertAddendumInTransaction(Connection conn, EmployeeContract c) throws SQLException {
        String sql = "INSERT INTO employee_contracts " +
                     "(user_id, contract_type_id, position_id, department_id, salary_grade_id, " +
                     " start_date, end_date, base_salary, tax_calc_type, " +
                     " doc_type, parent_contract_id, addendum_reason, status, sign_status, signed_at) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'ADDENDUM', ?, ?, 'Active', 'SIGNED', NOW())";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, c.getUserId());
            ps.setInt(2, c.getContractTypeId());
            ps.setInt(3, c.getPositionId());
            ps.setInt(4, c.getDepartmentId());
            ps.setInt(5, c.getSalaryGradeId() > 0 ? c.getSalaryGradeId() : 1);
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

                // ── Đóng hợp đồng cha ────────────────────────────────────────
                // Sau khi ADDENDUM mới đã được tạo thành công (và đã có contractId mới),
                // terminate đúng hợp đồng cha (parentContractId) trong cùng transaction.
                // Dùng contract_id = ? thay vì != ? để chỉ đóng đúng 1 bản ghi biết trước,
                // tránh lỡ tay terminate hợp đồng Active khác trong edge case dữ liệu bẩn.
                if (c.getParentContractId() != null) {
                    String closeOldSql = "UPDATE employee_contracts SET status = 'Terminated' " +
                                         "WHERE user_id = ? AND status = 'Active' AND contract_id = ?";
                    try (PreparedStatement psClose = conn.prepareStatement(closeOldSql)) {
                        psClose.setInt(1, c.getUserId());
                        psClose.setInt(2, c.getParentContractId());
                        psClose.executeUpdate();
                    }
                } else {
                    // parentContractId null không xảy ra trong luồng điều chuyển bình thường,
                    // nhưng guard để tránh NPE phá vỡ transaction nếu có edge case.
                    System.err.println("[WARN] insertAddendumInTransaction: parentContractId is null " +
                                       "for userId=" + c.getUserId() + " — bỏ qua bước đóng hợp đồng cha.");
                }
                // ─────────────────────────────────────────────────────────────

                return true;
            }
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

                // Đóng (Terminate) các hợp đồng đang Active cũ của nhân viên này
                String sqlTerminateOld = "UPDATE employee_contracts SET status = 'Terminated' " +
                                         "WHERE user_id = ? AND status = 'Active' AND contract_id != ?";
                try (PreparedStatement ps3 = conn.prepareStatement(sqlTerminateOld)) {
                    ps3.setInt(1, userId);
                    ps3.setInt(2, contractId);
                    ps3.executeUpdate();
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
        String sql = "UPDATE employee_contracts SET status = 'Rejected', reject_reason = ? " +
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
    // WRITE: Cập nhật đường dẫn file (PDF Hợp đồng / Phụ lục)
    // =========================================================================

    /**
     * Cập nhật đường dẫn file PDF bản scan đã ký vào hợp đồng/phụ lục.
     */
    public boolean updateFilePath(int contractId, String filePath) {
        String sql = "UPDATE employee_contracts SET file_path = ? WHERE contract_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, filePath);
            ps.setInt(2, contractId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // =========================================================================
    // Utility
    // =========================================================================

    public java.util.List<java.util.Map<String, Object>> getExpiringContracts(java.sql.Date fromDate, java.sql.Date toDate, Integer departmentId) {
        java.util.List<java.util.Map<String, Object>> list = new java.util.ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT u.user_id, u.full_name, d.department_name, ct.type_name, ec.end_date, COALESCE(DATEDIFF(ec.end_date, CURDATE()), 99999) as days_left " +
            "FROM employee_contracts ec " +
            "JOIN users u ON ec.user_id = u.user_id " +
            "LEFT JOIN departments d ON u.department_id = d.department_id " +
            "LEFT JOIN contract_types ct ON ec.contract_type_id = ct.contract_type_id " +
            "WHERE ec.status = 'Active' "
        );
        if (fromDate != null && toDate != null) {
            sql.append(" AND ec.end_date IS NOT NULL AND ec.end_date BETWEEN ? AND ? ");
        }
        if (departmentId != null && departmentId > 0) {
            sql.append(" AND u.department_id = ? ");
        }
        sql.append(" ORDER BY ec.end_date ASC");

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            int paramIndex = 1;
            if (fromDate != null && toDate != null) {
                ps.setDate(paramIndex++, fromDate);
                ps.setDate(paramIndex++, toDate);
            }
            if (departmentId != null && departmentId > 0) {
                ps.setInt(paramIndex++, departmentId);
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    java.util.Map<String, Object> map = new java.util.HashMap<>();
                    map.put("userId", rs.getInt("user_id"));
                    map.put("fullName", rs.getString("full_name"));
                    map.put("departmentName", rs.getString("department_name") != null ? rs.getString("department_name") : "Không xác định");
                    map.put("typeName", rs.getString("type_name"));
                    map.put("endDate", rs.getDate("end_date"));
                    map.put("daysLeft", rs.getInt("days_left"));
                    list.add(map);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

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

    // =========================================================================
    // TuVV: HR Staff Dashboard — đếm hợp đồng chờ nhân viên ký
    // =========================================================================

    /**
     * Đếm tổng số hợp đồng/phụ lục có sign_status = 'PENDING'.
     * Dùng cho card "Chờ nhân viên ký" trên HR Staff Dashboard.
     */
    public int countPendingSignatureContracts() {
        String sql = "SELECT COUNT(*) FROM employee_contracts WHERE sign_status = 'PENDING'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }
}
