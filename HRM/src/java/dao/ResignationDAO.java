package dao;

import model.ResignationRequest;
import util.DBContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO cho bảng resignation_requests.
 * Xử lý luồng nhân viên tự xin nghỉ việc.
 */
public class ResignationDAO {

    // ── SQL constants ──────────────────────────────────────────────────────────

    private static final String SQL_INSERT =
            "INSERT INTO resignation_requests (user_id, reason, desired_last_date, status) " +
            "VALUES (?, ?, ?, 'PENDING')";

    private static final String SQL_GET_BY_USER =
            "SELECT r.*, u.full_name AS employee_name, u.username AS employee_username, rv.full_name AS reviewer_name " +
            "FROM resignation_requests r " +
            "JOIN users u ON r.user_id = u.user_id " +
            "LEFT JOIN users rv ON r.reviewed_by = rv.user_id " +
            "WHERE r.user_id = ? " +
            "ORDER BY r.submitted_at DESC";

    private static final String SQL_GET_ALL =
            "SELECT r.*, u.full_name AS employee_name, u.username AS employee_username, rv.full_name AS reviewer_name " +
            "FROM resignation_requests r " +
            "JOIN users u ON r.user_id = u.user_id " +
            "LEFT JOIN users rv ON r.reviewed_by = rv.user_id " +
            "ORDER BY r.submitted_at DESC";

    private static final String SQL_GET_ALL_BY_STATUS =
            "SELECT r.*, u.full_name AS employee_name, u.username AS employee_username, rv.full_name AS reviewer_name " +
            "FROM resignation_requests r " +
            "JOIN users u ON r.user_id = u.user_id " +
            "LEFT JOIN users rv ON r.reviewed_by = rv.user_id " +
            "WHERE r.status = ? " +
            "ORDER BY r.submitted_at DESC";

    private static final String SQL_UPDATE_STATUS =
            "UPDATE resignation_requests " +
            "SET status = ?, reviewed_by = ?, reviewed_at = NOW(), hr_note = ? " +
            "WHERE resignation_id = ?";

    private static final String SQL_GET_BY_ID =
            "SELECT r.*, u.full_name AS employee_name, u.username AS employee_username, rv.full_name AS reviewer_name " +
            "FROM resignation_requests r " +
            "JOIN users u ON r.user_id = u.user_id " +
            "LEFT JOIN users rv ON r.reviewed_by = rv.user_id " +
            "WHERE r.resignation_id = ?";

    // ── Public Methods ─────────────────────────────────────────────────────────

    /**
     * Tự động tạo bảng resignation_requests nếu chưa tồn tại.
     * Gọi trong constructor để đảm bảo bảng luôn có sẵn.
     */
    private void ensureTableExists() {
        String createSQL =
            "CREATE TABLE IF NOT EXISTS resignation_requests (" +
            "  resignation_id    INT          AUTO_INCREMENT PRIMARY KEY," +
            "  user_id           INT          NOT NULL," +
            "  reason            TEXT         NOT NULL," +
            "  desired_last_date DATE         NOT NULL," +
            "  status            ENUM('PENDING','APPROVED','REJECTED') NOT NULL DEFAULT 'PENDING'," +
            "  submitted_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP," +
            "  reviewed_by       INT          NULL," +
            "  reviewed_at       TIMESTAMP    NULL," +
            "  hr_note           TEXT         NULL," +
            "  CONSTRAINT fk_resignation_user     FOREIGN KEY (user_id)     REFERENCES users(user_id) ON DELETE CASCADE," +
            "  CONSTRAINT fk_resignation_reviewer FOREIGN KEY (reviewed_by) REFERENCES users(user_id) ON DELETE SET NULL" +
            ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";
        DBContext dbContext = new DBContext();
        try (java.sql.Connection conn = dbContext.getConnection();
             java.sql.Statement st = conn.createStatement()) {
            st.execute(createSQL);
        } catch (java.sql.SQLException e) {
            System.err.println("ResignationDAO.ensureTableExists warning: " + e.getMessage());
        }
    }

    public ResignationDAO() {
        ensureTableExists();
    }

    /**
     * Kiểm tra xem nhân viên có đơn đang chờ duyệt (PENDING) không.
     * Dùng để ngăn nộp đơn trùng lặp.
     */
    public boolean hasPendingResignation(int userId) {
        String sql = "SELECT COUNT(*) FROM resignation_requests WHERE user_id = ? AND status = 'PENDING'";
        DBContext dbContext = new DBContext();
        try (java.sql.Connection conn = dbContext.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        } catch (java.sql.SQLException e) {
            System.err.println("ResignationDAO.hasPendingResignation error: " + e.getMessage());
        }
        return false;
    }

    /**
     * Nhân viên nộp đơn xin nghỉ mới (status = PENDING).
     * @return true nếu insert thành công
     */
    public boolean insert(ResignationRequest r) {
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_INSERT)) {

            ps.setInt(1, r.getUserId());
            ps.setString(2, r.getReason());
            ps.setDate(3, r.getDesiredLastDate());
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            System.err.println("ResignationDAO.insert error: " + e.getMessage());
            return false;
        }
    }

    /**
     * Lấy tất cả đơn của 1 nhân viên, sắp xếp mới nhất trước.
     */
    public List<ResignationRequest> getByUserId(int userId) {
        List<ResignationRequest> list = new ArrayList<>();
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_GET_BY_USER)) {

            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("ResignationDAO.getByUserId error: " + e.getMessage());
        }
        return list;
    }

    /**
     * Lấy tất cả đơn (dành cho HR — không filter).
     */
    public List<ResignationRequest> getAll() {
        List<ResignationRequest> list = new ArrayList<>();
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_GET_ALL);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("ResignationDAO.getAll error: " + e.getMessage());
        }
        return list;
    }

    /**
     * Lấy đơn theo trạng thái (PENDING / APPROVED / REJECTED).
     */
    public List<ResignationRequest> getAllByStatus(String status) {
        List<ResignationRequest> list = new ArrayList<>();
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_GET_ALL_BY_STATUS)) {

            ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("ResignationDAO.getAllByStatus error: " + e.getMessage());
        }
        return list;
    }

    /**
     * Lấy 1 đơn theo ID (dùng khi cần lấy userId trước khi approve).
     */
    public ResignationRequest getById(int resignationId) {
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_GET_BY_ID)) {

            ps.setInt(1, resignationId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("ResignationDAO.getById error: " + e.getMessage());
        }
        return null;
    }

    /**
     * Cập nhật trạng thái đơn (APPROVED hoặc REJECTED).
     * @param id         resignation_id
     * @param status     "APPROVED" hoặc "REJECTED"
     * @param reviewedBy user_id của HR duyệt
     * @param hrNote     ghi chú HR (nullable khi approve)
     */
    public boolean updateStatus(int id, String status, int reviewedBy, String hrNote) {
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_UPDATE_STATUS)) {

            ps.setString(1, status);
            ps.setInt(2, reviewedBy);
            if (hrNote != null && !hrNote.isBlank()) {
                ps.setString(3, hrNote);
            } else {
                ps.setNull(3, Types.VARCHAR);
            }
            ps.setInt(4, id);
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            System.err.println("ResignationDAO.updateStatus error: " + e.getMessage());
            return false;
        }
    }

    // ── Private Helpers ───────────────────────────────────────────────────────

    private ResignationRequest mapRow(ResultSet rs) throws SQLException {
        ResignationRequest r = new ResignationRequest();
        r.setResignationId(rs.getInt("resignation_id"));
        r.setUserId(rs.getInt("user_id"));
        r.setReason(rs.getString("reason"));
        r.setDesiredLastDate(rs.getDate("desired_last_date"));
        r.setStatus(rs.getString("status"));
        r.setSubmittedAt(rs.getTimestamp("submitted_at"));
        r.setReviewedBy(rs.getInt("reviewed_by"));      // 0 nếu NULL
        r.setReviewedAt(rs.getTimestamp("reviewed_at")); // null nếu chưa duyệt
        r.setHrNote(rs.getString("hr_note"));
        r.setEmployeeName(rs.getString("employee_name"));
        r.setEmployeeUsername(rs.getString("employee_username")); // username (mã NV)
        r.setReviewerName(rs.getString("reviewer_name")); // null nếu chưa duyệt
        return r;
    }
}
