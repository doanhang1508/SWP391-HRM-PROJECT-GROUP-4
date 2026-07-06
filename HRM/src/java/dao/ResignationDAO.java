package dao;

import model.ResignationRequest;
import model.ResignationChecklist;
import model.ExitInterview;
import util.DBContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO cho bảng resignation_requests, resignation_checklist, exit_interviews.
 * Xử lý luồng nhân viên tự xin nghỉ việc.
 */
public class ResignationDAO {

    // ── SQL constants ──────────────────────────────────────────────────────────

    private static final String SQL_INSERT =
            "INSERT INTO resignation_requests (user_id, reason, desired_last_date, expected_leave_date, notice_period_days, status) " +
            "VALUES (?, ?, ?, ?, ?, 'PENDING')";

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

    private static final String SQL_GET_BY_ID =
            "SELECT r.*, u.full_name AS employee_name, u.username AS employee_username, rv.full_name AS reviewer_name " +
            "FROM resignation_requests r " +
            "JOIN users u ON r.user_id = u.user_id " +
            "LEFT JOIN users rv ON r.reviewed_by = rv.user_id " +
            "WHERE r.resignation_id = ?";

    private static final String SQL_UPDATE_STATUS =
            "UPDATE resignation_requests " +
            "SET status = ?, reviewed_by = ?, reviewed_at = NOW(), hr_note = ?, last_working_day = ? " +
            "WHERE resignation_id = ?";

    // ── Public Methods ─────────────────────────────────────────────────────────

    public ResignationDAO() {
    }

    /**
     * Kiểm tra xem nhân viên có đơn đang chờ duyệt (PENDING) không.
     * Dùng để ngăn nộp đơn trùng lặp.
     */
    public boolean hasPendingResignation(int userId) {
        String sql = "SELECT COUNT(*) FROM resignation_requests WHERE user_id = ? AND status IN ('PENDING', 'APPROVED', 'WITHDRAW_REQUESTED')";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            System.err.println("ResignationDAO.hasPendingResignation error: " + e.getMessage());
        }
        return false;
    }

    /**
     * Nhân viên nộp đơn xin nghỉ mới (status = PENDING).
     */
    public boolean insert(ResignationRequest r) {
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_INSERT)) {

            ps.setInt(1, r.getUserId());
            ps.setString(2, r.getReason());
            ps.setDate(3, r.getDesiredLastDate());
            ps.setDate(4, r.getExpectedLeaveDate());
            if (r.getNoticePeriodDays() != null) {
                ps.setInt(5, r.getNoticePeriodDays());
            } else {
                ps.setNull(5, Types.INTEGER);
            }
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            System.err.println("ResignationDAO.insert error: " + e.getMessage());
            return false;
        }
    }

    public List<ResignationRequest> getByUserId(int userId) {
        List<ResignationRequest> list = new ArrayList<>();
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_GET_BY_USER)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("ResignationDAO.getByUserId error: " + e.getMessage());
        }
        return list;
    }

    public List<ResignationRequest> getAll() {
        List<ResignationRequest> list = new ArrayList<>();
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_GET_ALL);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            System.err.println("ResignationDAO.getAll error: " + e.getMessage());
        }
        return list;
    }

    public List<ResignationRequest> getAllByStatus(String status) {
        List<ResignationRequest> list = new ArrayList<>();
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_GET_ALL_BY_STATUS)) {
            ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("ResignationDAO.getAllByStatus error: " + e.getMessage());
        }
        return list;
    }

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

    public boolean updateStatus(int id, String status, String expectedOldStatus, int reviewedBy, String hrNote, Date lastWorkingDay) {
        String sql = "UPDATE resignation_requests " +
                     "SET status = ?, reviewed_by = ?, reviewed_at = NOW(), hr_note = ?, last_working_day = ? " +
                     "WHERE resignation_id = ? AND status = ?";
                     
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);
            if (reviewedBy > 0) {
                ps.setInt(2, reviewedBy);
            } else {
                ps.setNull(2, Types.INTEGER);
            }
            if (hrNote != null && !hrNote.isBlank()) {
                ps.setString(3, hrNote);
            } else {
                ps.setNull(3, Types.VARCHAR);
            }
            if (lastWorkingDay != null) {
                ps.setDate(4, lastWorkingDay);
            } else {
                ps.setNull(4, Types.DATE);
            }
            ps.setInt(5, id);
            ps.setString(6, expectedOldStatus);
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            System.err.println("ResignationDAO.updateStatus error: " + e.getMessage());
            return false;
        }
    }

    public boolean approveResignationRequestTransaction(int resignationId, int userId, int hrUserId, Date lastWorkingDay, int currentEmpStatusId) {
        String sqlResign = "UPDATE resignation_requests " +
                           "SET status = 'APPROVED', reviewed_by = ?, reviewed_at = NOW(), last_working_day = ?, previous_employment_status_id = ? " +
                           "WHERE resignation_id = ? AND status = 'PENDING'";
        String sqlProfile = "UPDATE employee_profiles SET employment_status_id = 5 WHERE user_id = ?";
        
        DBContext dbContext = new DBContext();
        Connection conn = null;
        try {
            conn = dbContext.getConnection();
            conn.setAutoCommit(false);
            
            // 1. Update resignation_requests
            try (PreparedStatement ps = conn.prepareStatement(sqlResign)) {
                ps.setInt(1, hrUserId);
                if (lastWorkingDay != null) {
                    ps.setDate(2, lastWorkingDay);
                } else {
                    ps.setNull(2, Types.DATE);
                }
                ps.setInt(3, currentEmpStatusId);
                ps.setInt(4, resignationId);
                int updated = ps.executeUpdate();
                if (updated == 0) {
                    conn.rollback();
                    return false; // Race condition
                }
            }
            
            // 2. Update employee_profiles
            try (PreparedStatement ps = conn.prepareStatement(sqlProfile)) {
                ps.setInt(1, userId);
                ps.executeUpdate();
            }
            
            conn.commit();
            return true;
        } catch (SQLException e) {
            System.err.println("ResignationDAO.approveResignationRequestTransaction error: " + e.getMessage());
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) {}
            }
            return false;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ex) {}
            }
        }
    }

    public boolean approveWithdrawResignationTransaction(int resignationId, int userId, int hrUserId, int previousEmpStatusId) {
        String sqlResign = "UPDATE resignation_requests " +
                           "SET status = 'WITHDRAWN', reviewed_by = ?, reviewed_at = NOW() " +
                           "WHERE resignation_id = ? AND status = 'WITHDRAW_REQUESTED'";
        String sqlProfile = "UPDATE employee_profiles SET employment_status_id = ? WHERE user_id = ?";
        
        DBContext dbContext = new DBContext();
        Connection conn = null;
        try {
            conn = dbContext.getConnection();
            conn.setAutoCommit(false);
            
            // 1. Update resignation_requests
            try (PreparedStatement ps = conn.prepareStatement(sqlResign)) {
                ps.setInt(1, hrUserId);
                ps.setInt(2, resignationId);
                int updated = ps.executeUpdate();
                if (updated == 0) {
                    conn.rollback();
                    return false; // Race condition
                }
            }
            
            // 2. Update employee_profiles
            try (PreparedStatement ps = conn.prepareStatement(sqlProfile)) {
                ps.setInt(1, previousEmpStatusId);
                ps.setInt(2, userId);
                ps.executeUpdate();
            }
            
            conn.commit();
            return true;
        } catch (SQLException e) {
            System.err.println("ResignationDAO.approveWithdrawResignationTransaction error: " + e.getMessage());
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) {}
            }
            return false;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ex) {}
            }
        }
    }

    // ── Checklist methods ─────────────────────────────────────────────────────────

    public List<ResignationChecklist> getChecklistByResignationId(int resignationId) {
        List<ResignationChecklist> list = new ArrayList<>();
        String sql = "SELECT c.*, u.full_name AS completed_by_name FROM resignation_checklist c LEFT JOIN users u ON c.completed_by = u.user_id WHERE resignation_id = ?";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, resignationId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ResignationChecklist c = new ResignationChecklist();
                    c.setChecklistId(rs.getInt("checklist_id"));
                    c.setResignationId(rs.getInt("resignation_id"));
                    c.setItemName(rs.getString("item_name"));
                    c.setCompleted(rs.getBoolean("is_completed"));
                    c.setCompletedBy(rs.getObject("completed_by") != null ? rs.getInt("completed_by") : null);
                    c.setCompletedAt(rs.getTimestamp("completed_at"));
                    c.setNote(rs.getString("note"));
                    c.setCompletedByName(rs.getString("completed_by_name"));
                    list.add(c);
                }
            }
        } catch (SQLException e) {
            System.err.println("ResignationDAO.getChecklist error: " + e.getMessage());
        }
        return list;
    }

    public boolean updateChecklistItem(int checklistId, boolean isCompleted, int completedBy, String note) {
        String sql = "UPDATE resignation_checklist SET is_completed = ?, completed_by = ?, completed_at = NOW(), note = ? WHERE checklist_id = ?";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, isCompleted);
            ps.setInt(2, completedBy);
            ps.setString(3, note);
            ps.setInt(4, checklistId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("ResignationDAO.updateChecklistItem error: " + e.getMessage());
            return false;
        }
    }

    public boolean insertChecklistItem(int resignationId, String itemName) {
        String sql = "INSERT INTO resignation_checklist (resignation_id, item_name) VALUES (?, ?)";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, resignationId);
            ps.setString(2, itemName);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("ResignationDAO.insertChecklistItem error: " + e.getMessage());
            return false;
        }
    }

    public boolean deleteChecklistItem(int checklistId) {
        String sql = "DELETE FROM resignation_checklist WHERE checklist_id = ?";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, checklistId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("ResignationDAO.deleteChecklistItem error: " + e.getMessage());
            return false;
        }
    }

    // ── Exit Interview methods ─────────────────────────────────────────────────────────

    public ExitInterview getExitInterview(int resignationId) {
        String sql = "SELECT * FROM exit_interviews WHERE resignation_id = ?";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, resignationId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    ExitInterview e = new ExitInterview();
                    e.setExitInterviewId(rs.getInt("exit_interview_id"));
                    e.setResignationId(rs.getInt("resignation_id"));
                    e.setReasonCategory(rs.getString("reason_category"));
                    e.setComment(rs.getString("comment"));
                    e.setCreatedAt(rs.getTimestamp("created_at"));
                    return e;
                }
            }
        } catch (SQLException e) {
            System.err.println("ResignationDAO.getExitInterview error: " + e.getMessage());
        }
        return null;
    }

    public boolean insertExitInterview(ExitInterview exit) {
        String sql = "INSERT INTO exit_interviews (resignation_id, reason_category, comment) VALUES (?, ?, ?)";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, exit.getResignationId());
            ps.setString(2, exit.getReasonCategory());
            ps.setString(3, exit.getComment());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("ResignationDAO.insertExitInterview error: " + e.getMessage());
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
        try {
            r.setExpectedLeaveDate(rs.getDate("expected_leave_date"));
            r.setLastWorkingDay(rs.getDate("last_working_day"));
            if (rs.getObject("notice_period_days") != null) {
                r.setNoticePeriodDays(rs.getInt("notice_period_days"));
            }
            if (rs.getObject("previous_employment_status_id") != null) {
                r.setPreviousEmploymentStatusId(rs.getInt("previous_employment_status_id"));
            }
        } catch(SQLException ex) {}

        r.setStatus(rs.getString("status"));
        r.setSubmittedAt(rs.getTimestamp("submitted_at"));
        r.setReviewedBy(rs.getInt("reviewed_by"));      // 0 nếu NULL
        r.setReviewedAt(rs.getTimestamp("reviewed_at")); // null nếu chưa duyệt
        
        try {
            r.setHrNote(rs.getString("hr_note"));
        } catch(SQLException ex) {}
        
        try {
            r.setCreatedAt(rs.getTimestamp("created_at"));
            r.setUpdatedAt(rs.getTimestamp("updated_at"));
        } catch(SQLException ex) {}

        r.setEmployeeName(rs.getString("employee_name"));
        r.setEmployeeUsername(rs.getString("employee_username")); // username (mã NV)
        r.setReviewerName(rs.getString("reviewer_name")); // null nếu chưa duyệt
        return r;
    }
}
