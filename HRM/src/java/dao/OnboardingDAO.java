package dao;

import model.OnboardingRequest;
import model.User;
import util.DBContext;
import util.PasswordUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO xử lý tất cả thao tác DB liên quan đến luồng Onboarding
 */
public class OnboardingDAO {

    // ──────────────────────────────────────────────────────────────
    // HELPER: Map ResultSet → OnboardingRequest (với JOIN fields)
    // ──────────────────────────────────────────────────────────────
    private OnboardingRequest mapRow(ResultSet rs) throws SQLException {
        OnboardingRequest r = new OnboardingRequest();
        r.setId(rs.getInt("id"));
        r.setFullName(rs.getString("full_name"));
        r.setEmail(rs.getString("email"));
        r.setPhone(rs.getString("phone"));
        r.setCccdNumber(rs.getString("cccd_number"));

        Date dob = rs.getDate("date_of_birth");
        if (dob != null)
            r.setDateOfBirth(dob);

        r.setAddress(rs.getString("address"));

        int gender = rs.getInt("gender");
        if (!rs.wasNull())
            r.setGender(gender);

        int deptId = rs.getInt("department_id");
        if (!rs.wasNull())
            r.setDepartmentId(deptId);

        int posId = rs.getInt("position_id");
        if (!rs.wasNull())
            r.setPositionId(posId);

        r.setRoleId(rs.getInt("role_id"));
        r.setStatus(rs.getString("status"));
        r.setRejectReason(rs.getString("reject_reason"));
        r.setCreatedBy(rs.getInt("created_by"));

        int procBy = rs.getInt("processed_by");
        if (!rs.wasNull())
            r.setProcessedBy(procBy);

        r.setCreatedAt(rs.getTimestamp("created_at"));
        r.setUpdatedAt(rs.getTimestamp("updated_at"));

        // JOIN columns (nullable — chỉ có khi dùng LEFT JOIN)
        try {
            r.setDepartmentName(rs.getString("department_name"));
        } catch (SQLException ignored) {
        }
        try {
            r.setPositionName(rs.getString("position_name"));
        } catch (SQLException ignored) {
        }
        try {
            r.setCreatedByName(rs.getString("created_by_name"));
        } catch (SQLException ignored) {
        }
        try {
            r.setProcessedByName(rs.getString("processed_by_name"));
        } catch (SQLException ignored) {
        }

        return r;
    }

    // SQL dùng chung cho list queries (JOIN để lấy tên phòng ban, chức vụ, HR)
    private static final String SELECT_BASE = "SELECT o.*, " +
            "  d.department_name, p.position_name, " +
            "  u1.full_name AS created_by_name, " +
            "  u2.full_name AS processed_by_name " +
            "FROM onboarding_requests o " +
            "LEFT JOIN departments d ON o.department_id = d.department_id " +
            "LEFT JOIN positions   p ON o.position_id   = p.position_id " +
            "LEFT JOIN users       u1 ON o.created_by   = u1.user_id " +
            "LEFT JOIN users       u2 ON o.processed_by = u2.user_id ";

    // ──────────────────────────────────────────────────────────────
    // CREATE: Lưu yêu cầu mới (DRAFT hoặc PENDING)
    // ──────────────────────────────────────────────────────────────
    public int create(OnboardingRequest r) {
        String sql = "INSERT INTO onboarding_requests " +
                "(full_name, email, phone, cccd_number, date_of_birth, address, gender, " +
                " department_id, position_id, role_id, status, created_by) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, r.getFullName());
            ps.setString(2, r.getEmail());
            ps.setString(3, r.getPhone());
            ps.setString(4, r.getCccdNumber());
            if (r.getDateOfBirth() != null)
                ps.setDate(5, r.getDateOfBirth());
            else
                ps.setNull(5, Types.DATE);
            ps.setString(6, r.getAddress());
            if (r.getGender() != null)
                ps.setInt(7, r.getGender());
            else
                ps.setNull(7, Types.TINYINT);
            if (r.getDepartmentId() != null)
                ps.setInt(8, r.getDepartmentId());
            else
                ps.setNull(8, Types.INTEGER);
            if (r.getPositionId() != null)
                ps.setInt(9, r.getPositionId());
            else
                ps.setNull(9, Types.INTEGER);
            ps.setInt(10, r.getRoleId());
            ps.setString(11, r.getStatus());
            ps.setInt(12, r.getCreatedBy());

            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet gk = ps.getGeneratedKeys()) {
                    if (gk.next())
                        return gk.getInt(1);
                }
            }
        } catch (SQLException e) {
            System.err.println("OnboardingDAO.create: " + e.getMessage());
        }
        return -1;
    }

    // ──────────────────────────────────────────────────────────────
    // UPDATE: Cập nhật yêu cầu (cho phép edit khi DRAFT/REJECTED)
    // ──────────────────────────────────────────────────────────────
    public boolean update(OnboardingRequest r) {
        String sql = "UPDATE onboarding_requests SET " +
                "full_name=?, email=?, phone=?, cccd_number=?, date_of_birth=?, address=?, gender=?, " +
                "department_id=?, position_id=?, role_id=?, status=?, reject_reason=NULL " +
                "WHERE id=? AND created_by=? AND status IN ('DRAFT','REJECTED')";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, r.getFullName());
            ps.setString(2, r.getEmail());
            ps.setString(3, r.getPhone());
            ps.setString(4, r.getCccdNumber());
            if (r.getDateOfBirth() != null)
                ps.setDate(5, r.getDateOfBirth());
            else
                ps.setNull(5, Types.DATE);
            ps.setString(6, r.getAddress());
            if (r.getGender() != null)
                ps.setInt(7, r.getGender());
            else
                ps.setNull(7, Types.TINYINT);
            if (r.getDepartmentId() != null)
                ps.setInt(8, r.getDepartmentId());
            else
                ps.setNull(8, Types.INTEGER);
            if (r.getPositionId() != null)
                ps.setInt(9, r.getPositionId());
            else
                ps.setNull(9, Types.INTEGER);
            ps.setInt(10, r.getRoleId());
            ps.setString(11, r.getStatus());
            ps.setInt(12, r.getId());
            ps.setInt(13, r.getCreatedBy());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("OnboardingDAO.update: " + e.getMessage());
        }
        return false;
    }

    // ──────────────────────────────────────────────────────────────
    // READ: Lấy theo ID
    // ──────────────────────────────────────────────────────────────
    public OnboardingRequest getById(int id) {
        String sql = SELECT_BASE + "WHERE o.id = ?";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next())
                    return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("OnboardingDAO.getById: " + e.getMessage());
        }
        return null;
    }

    // ──────────────────────────────────────────────────────────────
    // READ: HR xem danh sách của chính mình
    // ──────────────────────────────────────────────────────────────
    public List<OnboardingRequest> getByCreator(int createdBy) {
        List<OnboardingRequest> list = new ArrayList<>();
        String sql = SELECT_BASE + "WHERE o.created_by = ? ORDER BY o.updated_at DESC";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, createdBy);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next())
                    list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("OnboardingDAO.getByCreator: " + e.getMessage());
        }
        return list;
    }

    // ──────────────────────────────────────────────────────────────
    // READ: Admin xem tất cả (có filter theo status)
    // ──────────────────────────────────────────────────────────────
    public List<OnboardingRequest> getAll(String statusFilter) {
        List<OnboardingRequest> list = new ArrayList<>();
        String where = (statusFilter != null && !statusFilter.isEmpty() && !"ALL".equalsIgnoreCase(statusFilter))
                ? "WHERE o.status = ? "
                : "";
        String sql = SELECT_BASE + where + "ORDER BY o.updated_at DESC";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            if (!where.isEmpty())
                ps.setString(1, statusFilter);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next())
                    list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("OnboardingDAO.getAll: " + e.getMessage());
        }
        return list;
    }

    // ──────────────────────────────────────────────────────────────
    // VALIDATE: Kiểm tra trùng CCCD / Email
    // ──────────────────────────────────────────────────────────────
    public String checkDuplicate(String cccd, String email, int excludeId) {
        // Kiểm tra trong onboarding_requests (chỉ DRAFT/PENDING/APPROVED)
        String sql = "SELECT cccd_number, email FROM onboarding_requests " +
                "WHERE (cccd_number = ? OR email = ?) AND id != ? " +
                "AND status IN ('DRAFT','PENDING','APPROVED') LIMIT 1";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, cccd != null ? cccd : "");
            ps.setString(2, email != null ? email : "");
            ps.setInt(3, excludeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String existCccd = rs.getString("cccd_number");
                    String existEmail = rs.getString("email");
                    if (cccd != null && cccd.equals(existCccd))
                        return "Số CCCD này đã tồn tại trong hệ thống!";
                    if (email != null && email.equals(existEmail))
                        return "Email này đã tồn tại trong hệ thống!";
                }
            }
        } catch (SQLException e) {
            System.err.println("OnboardingDAO.checkDuplicate (onboarding): " + e.getMessage());
        }

        // Kiểm tra trong bảng users (đề phòng CCCD/email đã được dùng)
        String sqlUsers = "SELECT 1 FROM users WHERE email = ? LIMIT 1";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sqlUsers)) {
            ps.setString(1, email != null ? email : "");
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next())
                    return "Email này đã được dùng cho một tài khoản khác!";
            }
        } catch (SQLException e) {
            System.err.println("OnboardingDAO.checkDuplicate (users): " + e.getMessage());
        }
        return null; // Không trùng
    }

    // ──────────────────────────────────────────────────────────────
    // STATS: Thống kê cho Admin
    // ──────────────────────────────────────────────────────────────
    public int countByStatus(String status) {
        String sql = "ALL".equalsIgnoreCase(status)
                ? "SELECT COUNT(*) FROM onboarding_requests"
                : "SELECT COUNT(*) FROM onboarding_requests WHERE status = ?";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            if (!"ALL".equalsIgnoreCase(status))
                ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next())
                    return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("OnboardingDAO.countByStatus: " + e.getMessage());
        }
        return 0;
    }

    // ──────────────────────────────────────────────────────────────
    // APPROVE: Transaction — Tạo tài khoản + Cập nhật status
    // Trả về username được tạo (để gửi email), null nếu thất bại
    // ──────────────────────────────────────────────────────────────
    public String approveAndCreateUser(int requestId, int adminId,
            String username, String rawPassword) {
        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);

            // Lấy thông tin request
            OnboardingRequest req = null;
            String sqlGet = "SELECT * FROM onboarding_requests WHERE id = ? AND status = 'PENDING' FOR UPDATE";
            try (PreparedStatement ps = conn.prepareStatement(sqlGet)) {
                ps.setInt(1, requestId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        req = new OnboardingRequest();
                        req.setId(rs.getInt("id"));
                        req.setFullName(rs.getString("full_name"));
                        req.setEmail(rs.getString("email"));
                        req.setPhone(rs.getString("phone"));
                        req.setRoleId(rs.getInt("role_id"));
                        req.setDepartmentId((Integer) rs.getObject("department_id"));
                        req.setPositionId((Integer) rs.getObject("position_id"));
                    }
                }
            }
            if (req == null) {
                conn.rollback();
                return null;
            }

            // 1. Insert vào bảng users
            String insertUser = "INSERT INTO users (username, password, full_name, email, phone, role_id, department_id, position_id, status) "
                    +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1)";
            try (PreparedStatement ps = conn.prepareStatement(insertUser)) {
                ps.setString(1, username);
                ps.setString(2, PasswordUtil.hashPassword(rawPassword));
                ps.setString(3, req.getFullName());
                ps.setString(4, req.getEmail());
                ps.setString(5, req.getPhone());
                ps.setInt(6, req.getRoleId());
                if (req.getDepartmentId() != null)
                    ps.setInt(7, req.getDepartmentId());
                else
                    ps.setNull(7, Types.INTEGER);
                if (req.getPositionId() != null)
                    ps.setInt(8, req.getPositionId());
                else
                    ps.setNull(8, Types.INTEGER);
                ps.executeUpdate();
            }

            // 2. Cập nhật status onboarding_requests → APPROVED
            String updateReq = "UPDATE onboarding_requests SET status='APPROVED', processed_by=? WHERE id=?";
            try (PreparedStatement ps = conn.prepareStatement(updateReq)) {
                ps.setInt(1, adminId);
                ps.setInt(2, requestId);
                ps.executeUpdate();
            }

            conn.commit();
            return username;

        } catch (Exception e) {
            System.err.println("OnboardingDAO.approveAndCreateUser ERROR: " + e.getMessage());
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            return null;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException ignored) {
                }
            }
        }
    }

    // ──────────────────────────────────────────────────────────────
    // REJECT: Cập nhật status + ghi lý do
    // ──────────────────────────────────────────────────────────────
    public boolean rejectRequest(int requestId, int adminId, String reason) {
        String sql = "UPDATE onboarding_requests " +
                "SET status='REJECTED', reject_reason=?, processed_by=? " +
                "WHERE id=? AND status='PENDING'";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, reason);
            ps.setInt(2, adminId);
            ps.setInt(3, requestId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("OnboardingDAO.rejectRequest: " + e.getMessage());
        }
        return false;
    }

    // ──────────────────────────────────────────────────────────────
    // HELPER: Kiểm tra username đã tồn tại trong bảng users chưa
    // ──────────────────────────────────────────────────────────────
    public boolean isUsernameExists(String username) {
        String sql = "SELECT 1 FROM users WHERE username = ? LIMIT 1";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            System.err.println("OnboardingDAO.isUsernameExists: " + e.getMessage());
        }
        return false;
    }

    // ──────────────────────────────────────────────────────────────
    // TuVV: HR Staff Dashboard — thống kê onboarding theo người tạo
    // ──────────────────────────────────────────────────────────────

    /**
     * Đếm số onboarding request theo người tạo và trạng thái.
     * Dùng cho card "Hồ sơ onboarding chờ duyệt" / "bị từ chối" trên HR Staff Dashboard.
     */
    public int countByCreatorAndStatus(int createdBy, String status) {
        String sql = "SELECT COUNT(*) FROM onboarding_requests WHERE created_by = ? AND status = ?";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, createdBy);
            ps.setString(2, status);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("OnboardingDAO.countByCreatorAndStatus: " + e.getMessage());
        }
        return 0;
    }

    /**
     * Lấy tổng số onboarding theo từng trạng thái của một HR Staff (1 query GROUP BY).
     * Dùng cho khu vực "Tiến độ nhập hồ sơ" trên HR Staff Dashboard.
     * @return Map với key = status (DRAFT, PENDING, APPROVED, REJECTED), value = count
     */
    public java.util.Map<String, Integer> getStatusCountsByCreator(int createdBy) {
        java.util.Map<String, Integer> counts = new java.util.LinkedHashMap<>();
        // Khởi tạo mặc định để JSP không bị null
        counts.put("DRAFT", 0);
        counts.put("PENDING", 0);
        counts.put("APPROVED", 0);
        counts.put("REJECTED", 0);

        String sql = "SELECT status, COUNT(*) AS cnt FROM onboarding_requests " +
                     "WHERE created_by = ? GROUP BY status";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, createdBy);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    counts.put(rs.getString("status"), rs.getInt("cnt"));
                }
            }
        } catch (SQLException e) {
            System.err.println("OnboardingDAO.getStatusCountsByCreator: " + e.getMessage());
        }
        return counts;
    }
}
