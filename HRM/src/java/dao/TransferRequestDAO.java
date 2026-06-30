package dao;

import model.TransferRequest;
import util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class TransferRequestDAO {

    public boolean createTransferRequest(TransferRequest req) {
        String sql = "INSERT INTO transfer_requests (employee_id, old_department_id, old_position_id, new_department_id, new_position_id, reason, effective_date, status, requested_by) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, 'PENDING', ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, req.getEmployeeId());
            if (req.getOldDepartmentId() > 0) ps.setInt(2, req.getOldDepartmentId());
            else ps.setNull(2, java.sql.Types.INTEGER);
            if (req.getOldPositionId() > 0) ps.setInt(3, req.getOldPositionId());
            else ps.setNull(3, java.sql.Types.INTEGER);
            ps.setInt(4, req.getNewDepartmentId());
            ps.setInt(5, req.getNewPositionId());
            ps.setString(6, req.getReason());
            ps.setDate(7, req.getEffectiveDate());
            ps.setInt(8, req.getRequestedBy());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<TransferRequest> getAllTransferRequests() {
        List<TransferRequest> list = new ArrayList<>();
        String sql = "SELECT tr.*, u.full_name AS employee_name, " +
                     "d1.department_name AS old_dept_name, d2.department_name AS new_dept_name, " +
                     "p1.position_name AS old_pos_name, p2.position_name AS new_pos_name, " +
                     "ur.full_name AS requester_name, ua.full_name AS approver_name " +
                     "FROM transfer_requests tr " +
                     "JOIN users u ON tr.employee_id = u.user_id " +
                     "LEFT JOIN departments d1 ON tr.old_department_id = d1.department_id " +
                     "LEFT JOIN departments d2 ON tr.new_department_id = d2.department_id " +
                     "LEFT JOIN positions p1 ON tr.old_position_id = p1.position_id " +
                     "LEFT JOIN positions p2 ON tr.new_position_id = p2.position_id " +
                     "JOIN users ur ON tr.requested_by = ur.user_id " +
                     "LEFT JOIN users ua ON tr.approved_by = ua.user_id " +
                     "ORDER BY tr.created_at DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public TransferRequest getById(int id) {
        String sql = "SELECT tr.*, u.full_name AS employee_name, " +
                     "d1.department_name AS old_dept_name, d2.department_name AS new_dept_name, " +
                     "p1.position_name AS old_pos_name, p2.position_name AS new_pos_name, " +
                     "ur.full_name AS requester_name, ua.full_name AS approver_name " +
                     "FROM transfer_requests tr " +
                     "JOIN users u ON tr.employee_id = u.user_id " +
                     "LEFT JOIN departments d1 ON tr.old_department_id = d1.department_id " +
                     "LEFT JOIN departments d2 ON tr.new_department_id = d2.department_id " +
                     "LEFT JOIN positions p1 ON tr.old_position_id = p1.position_id " +
                     "LEFT JOIN positions p2 ON tr.new_position_id = p2.position_id " +
                     "JOIN users ur ON tr.requested_by = ur.user_id " +
                     "LEFT JOIN users ua ON tr.approved_by = ua.user_id " +
                     "WHERE tr.transfer_request_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<TransferRequest> getPendingRequestsForManager(int managerDepartmentId) {
        List<TransferRequest> list = new ArrayList<>();
        String sql = "SELECT tr.*, u.full_name AS employee_name, " +
                     "d1.department_name AS old_dept_name, d2.department_name AS new_dept_name, " +
                     "p1.position_name AS old_pos_name, p2.position_name AS new_pos_name, " +
                     "ur.full_name AS requester_name, ua.full_name AS approver_name " +
                     "FROM transfer_requests tr " +
                     "JOIN users u ON tr.employee_id = u.user_id " +
                     "LEFT JOIN departments d1 ON tr.old_department_id = d1.department_id " +
                     "LEFT JOIN departments d2 ON tr.new_department_id = d2.department_id " +
                     "LEFT JOIN positions p1 ON tr.old_position_id = p1.position_id " +
                     "LEFT JOIN positions p2 ON tr.new_position_id = p2.position_id " +
                     "JOIN users ur ON tr.requested_by = ur.user_id " +
                     "LEFT JOIN users ua ON tr.approved_by = ua.user_id " +
                     "WHERE tr.status = 'PENDING' AND tr.old_department_id = ? " +
                     "ORDER BY tr.created_at DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, managerDepartmentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean hasPendingRequest(int employeeId) {
        String sql = "SELECT 1 FROM transfer_requests WHERE employee_id = ? AND status = 'PENDING'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, employeeId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean rejectTransferRequest(int requestId, int approverId, String rejectReason) {
        String sql = "UPDATE transfer_requests SET status = 'REJECTED', approved_by = ?, approved_at = NOW(), reject_reason = ?, updated_at = NOW() " +
                     "WHERE transfer_request_id = ? AND status = 'PENDING'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, approverId);
            ps.setString(2, rejectReason);
            ps.setInt(3, requestId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean approveTransferRequest(int requestId, int approverId) {
        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false); // Start Transaction

            // 1. SELECT FOR UPDATE
            String selectReqSql = "SELECT * FROM transfer_requests WHERE transfer_request_id = ? FOR UPDATE";
            TransferRequest req = null;
            try (PreparedStatement psSel = conn.prepareStatement(selectReqSql)) {
                psSel.setInt(1, requestId);
                try (ResultSet rsSel = psSel.executeQuery()) {
                    if (rsSel.next()) {
                        req = new TransferRequest();
                        req.setTransferRequestId(rsSel.getInt("transfer_request_id"));
                        req.setEmployeeId(rsSel.getInt("employee_id"));
                        req.setOldDepartmentId(rsSel.getInt("old_department_id"));
                        req.setOldPositionId(rsSel.getInt("old_position_id"));
                        req.setNewDepartmentId(rsSel.getInt("new_department_id"));
                        req.setNewPositionId(rsSel.getInt("new_position_id"));
                        req.setReason(rsSel.getString("reason"));
                        req.setEffectiveDate(rsSel.getDate("effective_date"));
                        req.setStatus(rsSel.getString("status"));
                    }
                }
            }

            if (req == null) {
                throw new SQLException("Transfer Request not found");
            }
            if (!"PENDING".equals(req.getStatus())) {
                throw new SQLException("Transfer Request is not PENDING");
            }

            // 2. Retrieve old and new names
            String oldDeptName = "-";
            String newDeptName = "-";
            String oldPosName = "-";
            String newPosName = "-";

            String deptSql = "SELECT department_id, department_name FROM departments WHERE department_id IN (?, ?)";
            try (PreparedStatement psDept = conn.prepareStatement(deptSql)) {
                psDept.setInt(1, req.getOldDepartmentId());
                psDept.setInt(2, req.getNewDepartmentId());
                try (ResultSet rsDept = psDept.executeQuery()) {
                    while (rsDept.next()) {
                        int id = rsDept.getInt("department_id");
                        String name = rsDept.getString("department_name");
                        if (id == req.getOldDepartmentId()) oldDeptName = name;
                        if (id == req.getNewDepartmentId()) newDeptName = name;
                    }
                }
            }

            String posSql = "SELECT position_id, position_name FROM positions WHERE position_id IN (?, ?)";
            try (PreparedStatement psPos = conn.prepareStatement(posSql)) {
                psPos.setInt(1, req.getOldPositionId());
                psPos.setInt(2, req.getNewPositionId());
                try (ResultSet rsPos = psPos.executeQuery()) {
                    while (rsPos.next()) {
                        int id = rsPos.getInt("position_id");
                        String name = rsPos.getString("position_name");
                        if (id == req.getOldPositionId()) oldPosName = name;
                        if (id == req.getNewPositionId()) newPosName = name;
                    }
                }
            }

            // 3. Update transfer_requests
            String updateReqSql = "UPDATE transfer_requests SET status = 'APPROVED', approved_by = ?, approved_at = NOW(), updated_at = NOW() WHERE transfer_request_id = ?";
            try (PreparedStatement psUpReq = conn.prepareStatement(updateReqSql)) {
                psUpReq.setInt(1, approverId);
                psUpReq.setInt(2, requestId);
                psUpReq.executeUpdate();
            }

            // 4. Update users
            String updateUserSql = "UPDATE users SET department_id = ?, position_id = ? WHERE user_id = ?";
            try (PreparedStatement psUpUser = conn.prepareStatement(updateUserSql)) {
                psUpUser.setInt(1, req.getNewDepartmentId());
                psUpUser.setInt(2, req.getNewPositionId());
                psUpUser.setInt(3, req.getEmployeeId());
                psUpUser.executeUpdate();
            }

            // 5. Update employee_profiles (if exists)
            String updateProfileSql = "UPDATE employee_profiles SET department_id = ? WHERE user_id = ?";
            try (PreparedStatement psUpProfile = conn.prepareStatement(updateProfileSql)) {
                psUpProfile.setInt(1, req.getNewDepartmentId());
                psUpProfile.setInt(2, req.getEmployeeId());
                psUpProfile.executeUpdate();
            }

            // 6. Close current work history
            WorkHistoryDAO whDAO = new WorkHistoryDAO();
            whDAO.closeCurrentHistory(conn, req.getEmployeeId(), req.getEffectiveDate());

            // 7. Insert new work history
            String description = "Điều chuyển nội bộ từ " + oldDeptName + " - " + oldPosName 
                               + " sang " + newDeptName + " - " + newPosName 
                               + ". Lý do: " + req.getReason();
            whDAO.insertTransferHistory(conn, req.getEmployeeId(), newPosName, newDeptName, req.getEffectiveDate(), description);

            conn.commit(); // Commit Transaction
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
        }
    }

    private TransferRequest mapRow(ResultSet rs) throws SQLException {
        TransferRequest tr = new TransferRequest();
        tr.setTransferRequestId(rs.getInt("transfer_request_id"));
        tr.setEmployeeId(rs.getInt("employee_id"));
        tr.setEmployeeName(rs.getString("employee_name"));
        tr.setOldDepartmentId(rs.getInt("old_department_id"));
        tr.setOldDepartmentName(rs.getString("old_dept_name"));
        tr.setOldPositionId(rs.getInt("old_position_id"));
        tr.setOldPositionName(rs.getString("old_pos_name"));
        tr.setNewDepartmentId(rs.getInt("new_department_id"));
        tr.setNewDepartmentName(rs.getString("new_dept_name"));
        tr.setNewPositionId(rs.getInt("new_position_id"));
        tr.setNewPositionName(rs.getString("new_pos_name"));
        tr.setReason(rs.getString("reason"));
        tr.setEffectiveDate(rs.getDate("effective_date"));
        tr.setStatus(rs.getString("status"));
        tr.setRequestedBy(rs.getInt("requested_by"));
        tr.setRequestedByName(rs.getString("requester_name"));
        int appBy = rs.getInt("approved_by");
        tr.setApprovedBy(rs.wasNull() ? null : appBy);
        tr.setApprovedByName(rs.getString("approver_name"));
        tr.setApprovedAt(rs.getTimestamp("approved_at"));
        tr.setRejectReason(rs.getString("reject_reason"));
        tr.setCreatedAt(rs.getTimestamp("created_at"));
        tr.setUpdatedAt(rs.getTimestamp("updated_at"));
        return tr;
    }
}
