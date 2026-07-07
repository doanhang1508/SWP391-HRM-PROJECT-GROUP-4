package dao;

import model.EmployeeContract;
import model.TransferRequest;
import util.DBContext;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class TransferRequestDAO {

    // ── [NEW FLOW] Base SQL dùng chung cho tất cả query SELECT ──────────────────
    private static final String BASE_SELECT_SQL =
        "SELECT tr.*, u.full_name AS employee_name, " +
        "d1.department_name AS old_dept_name, d2.department_name AS new_dept_name, " +
        "p1.position_name AS old_pos_name, p2.position_name AS new_pos_name, " +
        "r1.role_name AS old_role_name, r2.role_name AS new_role_name, " +
        "ur.full_name AS requester_name, ua.full_name AS approver_name, " +
        "um.full_name AS manager_approver_name " +
        "FROM transfer_requests tr " +
        "JOIN users u ON tr.employee_id = u.user_id " +
        "LEFT JOIN departments d1 ON tr.old_department_id = d1.department_id " +
        "LEFT JOIN departments d2 ON tr.new_department_id = d2.department_id " +
        "LEFT JOIN positions p1 ON tr.old_position_id = p1.position_id " +
        "LEFT JOIN positions p2 ON tr.new_position_id = p2.position_id " +
        "LEFT JOIN roles r1 ON tr.old_role_id = r1.role_id " +
        "LEFT JOIN roles r2 ON tr.new_role_id = r2.role_id " +
        "JOIN users ur ON tr.requested_by = ur.user_id " +
        "LEFT JOIN users ua ON tr.approved_by = ua.user_id " +
        "LEFT JOIN users um ON tr.manager_approved_by = um.user_id ";

    public boolean createTransferRequest(TransferRequest req) {

        // Bao gồm new_salary_grade_id và new_base_salary (nullable — null = giữ nguyên lương)
        String sql = "INSERT INTO transfer_requests " +
                     "(employee_id, old_department_id, old_position_id, old_role_id, " +
                     " new_department_id, new_position_id, new_role_id, " +
                     " new_salary_grade_id, new_base_salary, " +
                     " reason, effective_date, status, requested_by) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'PENDING', ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, req.getEmployeeId());
            if (req.getOldDepartmentId() > 0) ps.setInt(2, req.getOldDepartmentId());
            else ps.setNull(2, java.sql.Types.INTEGER);
            if (req.getOldPositionId() > 0) ps.setInt(3, req.getOldPositionId());
            else ps.setNull(3, java.sql.Types.INTEGER);
            if (req.getOldRoleId() != null && req.getOldRoleId() > 0) ps.setInt(4, req.getOldRoleId());
            else ps.setNull(4, java.sql.Types.INTEGER);
            ps.setInt(5, req.getNewDepartmentId());
            ps.setInt(6, req.getNewPositionId());
            ps.setInt(7, req.getNewRoleId());
            // Lương mới — optional (null = giữ nguyên lương hiện tại)
            if (req.getNewSalaryGradeId() != null) ps.setInt(8, req.getNewSalaryGradeId());
            else ps.setNull(8, java.sql.Types.INTEGER);
            if (req.getNewBaseSalary() != null) ps.setBigDecimal(9, req.getNewBaseSalary());
            else ps.setNull(9, java.sql.Types.DECIMAL);
            ps.setString(10, req.getReason());
            ps.setDate(11, req.getEffectiveDate());
            ps.setInt(12, req.getRequestedBy());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * [NEW FLOW] Tạo phiếu điều chuyển kèm danh sách phụ cấp.
     * Insert vào transfer_requests + transfer_request_allowances trong 1 transaction.
     * allowanceIds rỗng = không có phụ cấp (chấp nhận).
     */
    public boolean createTransferRequestWithAllowances(TransferRequest req, List<Integer> allowanceIds) {
        String sqlInsertReq = "INSERT INTO transfer_requests " +
                "(employee_id, old_department_id, old_position_id, old_role_id, " +
                " new_department_id, new_position_id, new_role_id, " +
                " new_base_salary, " +
                " reason, effective_date, status, requested_by) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'PENDING', ?)";
        String sqlInsertAlw = "INSERT INTO transfer_request_allowances (transfer_request_id, allowance_id) VALUES (?, ?)";

        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);

            int requestId;
            try (PreparedStatement ps = conn.prepareStatement(sqlInsertReq,
                    java.sql.Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, req.getEmployeeId());
                if (req.getOldDepartmentId() > 0) ps.setInt(2, req.getOldDepartmentId());
                else ps.setNull(2, java.sql.Types.INTEGER);
                if (req.getOldPositionId() > 0) ps.setInt(3, req.getOldPositionId());
                else ps.setNull(3, java.sql.Types.INTEGER);
                if (req.getOldRoleId() != null && req.getOldRoleId() > 0) ps.setInt(4, req.getOldRoleId());
                else ps.setNull(4, java.sql.Types.INTEGER);
                ps.setInt(5, req.getNewDepartmentId());
                ps.setInt(6, req.getNewPositionId());
                ps.setInt(7, req.getNewRoleId());
                if (req.getNewBaseSalary() != null) ps.setBigDecimal(8, req.getNewBaseSalary());
                else ps.setNull(8, java.sql.Types.DECIMAL);
                ps.setString(9, req.getReason());
                ps.setDate(10, req.getEffectiveDate());
                ps.setInt(11, req.getRequestedBy());
                ps.executeUpdate();

                try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                    if (!generatedKeys.next()) {
                        conn.rollback();
                        return false;
                    }
                    requestId = generatedKeys.getInt(1);
                }
            }

            // Insert phụ cấp nếu có
            if (allowanceIds != null && !allowanceIds.isEmpty()) {
                try (PreparedStatement ps2 = conn.prepareStatement(sqlInsertAlw)) {
                    for (int aid : allowanceIds) {
                        ps2.setInt(1, requestId);
                        ps2.setInt(2, aid);
                        ps2.addBatch();
                    }
                    ps2.executeBatch();
                }
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ignored) {}
            }
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ignored) {}
            }
        }
        return false;
    }



    public List<TransferRequest> getAllTransferRequests() {
        List<TransferRequest> list = new ArrayList<>();
        String sql = BASE_SELECT_SQL + "ORDER BY tr.created_at DESC";
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
        String sql = BASE_SELECT_SQL + "WHERE tr.transfer_request_id = ?";
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

    /**
     * [NEW FLOW Bước 1] Lấy danh sách đơn PENDING của nhân viên cụ thể (NV xác nhận).
     */
    public List<TransferRequest> getPendingForEmployee(int employeeId) {
        List<TransferRequest> list = new ArrayList<>();
        String sql = BASE_SELECT_SQL +
                     "WHERE tr.status = 'PENDING' AND tr.employee_id = ? " +
                     "ORDER BY tr.created_at DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, employeeId);
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

    /**
     * [NEW FLOW Bước 1] Lấy danh sách đơn EMPLOYEE_CONFIRMED của phòng ban cụ thể (Trưởng phòng xử lý).
     */
    public List<TransferRequest> getEmployeeConfirmedRequestsForManager(int managerDepartmentId) {
        List<TransferRequest> list = new ArrayList<>();
        String sql = BASE_SELECT_SQL +
                     "WHERE tr.status = 'EMPLOYEE_CONFIRMED' AND tr.old_department_id = ? " +
                     "ORDER BY tr.employee_confirmed_at ASC";
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

    /**
     * [2-STEP] Lấy danh sách đơn MANAGER_APPROVED (HR Manager xác nhận bước 2).
     */
    public List<TransferRequest> getManagerApprovedRequests() {
        List<TransferRequest> list = new ArrayList<>();
        String sql = BASE_SELECT_SQL +
                     "WHERE tr.status = 'MANAGER_APPROVED' " +
                     "ORDER BY tr.manager_approved_at ASC";
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

    /**
     * Kiểm tra nhân viên có đơn điều chuyển đang trong quá trình xử lý không.
     * (PENDING, EMPLOYEE_CONFIRMED, MANAGER_APPROVED, hoặc APPROVED chưa tới effective_date)
     */
    public boolean hasPendingOrInProgressRequest(int employeeId) {
        String sql = "SELECT 1 FROM transfer_requests WHERE employee_id = ? " +
                     "AND status IN ('PENDING','EMPLOYEE_CONFIRMED','MANAGER_APPROVED') " +
                     "UNION SELECT 1 FROM transfer_requests " +
                     "WHERE employee_id = ? AND status = 'APPROVED' AND applied_at IS NULL";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, employeeId);
            ps.setInt(2, employeeId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<TransferRequest> getByEmployeeId(int employeeId) {
        List<TransferRequest> list = new ArrayList<>();
        String sql = BASE_SELECT_SQL + "WHERE tr.employee_id = ? ORDER BY tr.created_at DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, employeeId);
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

    /**
     * Giữ được khả năng tương thích ngược với các nơi gọi hasPendingRequest cũ.
     * @deprecated Dùng hasPendingOrInProgressRequest() thay thế
     */
    @Deprecated
    public boolean hasPendingRequest(int employeeId) {
        return hasPendingOrInProgressRequest(employeeId);
    }

    /**
     * [NEW FLOW] Lấy ID của đơn điều chuyển mới nhất (PENDING) của một nhân viên.
     * Dùng ngay sau khi createTransferRequest() để lấy ID cho notification.
     */
    public int getLatestRequestIdForEmployee(int employeeId) {
        String sql = "SELECT transfer_request_id FROM transfer_requests " +
                     "WHERE employee_id = ? AND status = 'PENDING' " +
                     "ORDER BY created_at DESC LIMIT 1";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, employeeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public boolean rejectTransferRequest(int requestId, int approverId, String rejectReason) {
        // Trưởng phòng từ chối từ EMPLOYEE_CONFIRMED; HR Manager từ chối từ MANAGER_APPROVED
        String sql = "UPDATE transfer_requests SET " +
                     "status = 'REJECTED', approved_by = ?, approved_at = NOW(), reject_reason = ?, updated_at = NOW() " +
                     "WHERE transfer_request_id = ? AND status IN ('EMPLOYEE_CONFIRMED','MANAGER_APPROVED')";
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

    /**
     * [NEW FLOW Bước 1] Nhân viên XÁC NHẬN đồng ý: PENDING → EMPLOYEE_CONFIRMED.
     * Sau đó gửi notification cho Trưởng phòng của phòng ban cũ.
     */
    public boolean employeeConfirmTransfer(int requestId, int employeeId) {
        String sql = "UPDATE transfer_requests " +
                     "SET status = 'EMPLOYEE_CONFIRMED', employee_confirmed_at = NOW(), updated_at = NOW() " +
                     "WHERE transfer_request_id = ? AND employee_id = ? AND status = 'PENDING'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, requestId);
            ps.setInt(2, employeeId);
            boolean ok = ps.executeUpdate() > 0;
            if (ok) {
                // Lấy thông tin đơn để gửi notification
                TransferRequest req = getById(requestId);
                if (req != null) {
                    sendDeptHeadNotificationOnConfirm(requestId, req.getOldDepartmentId(), req.getEmployeeName());
                }
            }
            return ok;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * [NEW FLOW Bước 1] Nhân viên TỪ CHỐI điều chuyển: PENDING → EMPLOYEE_REJECTED.
     * Gửi notification cho HR Staff người tạo đơn.
     */
    public boolean employeeRejectTransfer(int requestId, int employeeId, String rejectReason) {
        String sql = "UPDATE transfer_requests " +
                     "SET status = 'EMPLOYEE_REJECTED', employee_reject_reason = ?, updated_at = NOW() " +
                     "WHERE transfer_request_id = ? AND employee_id = ? AND status = 'PENDING'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, rejectReason);
            ps.setInt(2, requestId);
            ps.setInt(3, employeeId);
            boolean ok = ps.executeUpdate() > 0;
            if (ok) {
                // Gửi notification cho HR Staff người tạo đơn
                TransferRequest req = getById(requestId);
                if (req != null) {
                    sendNotificationToRequester(requestId, req.getRequestedBy(),
                        req.getEmployeeName(), rejectReason);
                }
            }
            return ok;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * [NEW FLOW Bước 2] Trưởng phòng duyệt: EMPLOYEE_CONFIRMED → MANAGER_APPROVED.
     * Sau đó gửi notification cho HR Manager.
     */
    public boolean managerApproveTransferRequest(int requestId, int managerId) {
        String sql = "UPDATE transfer_requests " +
                     "SET status = 'MANAGER_APPROVED', manager_approved_by = ?, manager_approved_at = NOW(), updated_at = NOW() " +
                     "WHERE transfer_request_id = ? AND status = 'EMPLOYEE_CONFIRMED'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, managerId);
            ps.setInt(2, requestId);
            boolean ok = ps.executeUpdate() > 0;
            if (ok) {
                // Gửi notification cho HR Manager sau khi cập nhật thành công
                sendNotificationToHRManagers(requestId);
            }
            return ok;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Hủy yêu cầu điều chuyển đang PENDING.
     * Chỉ cho phép nếu:
     *   - Người hủy là người tạo yêu cầu (requested_by), HOẶC
     *   - Người hủy là Admin (roleId=1) hoặc HR Manager (roleId=2)
     *
     * @param requestId        ID của yêu cầu điều chuyển
     * @param cancelledByUserId user_id của người thực hiện hủy
     * @param cancelledByRoleId role_id của người thực hiện hủy
     * @return true nếu hủy thành công
     */
    public boolean cancelTransferRequest(int requestId, int cancelledByUserId, int cancelledByRoleId) {
        boolean isAdminOrHRManager = (cancelledByRoleId == 1 || cancelledByRoleId == 2);
        String sql;
        if (isAdminOrHRManager) {
            // Admin/HR Manager có thể hủy đơn PENDING hoặc EMPLOYEE_CONFIRMED
            sql = "UPDATE transfer_requests SET status = 'CANCELLED', updated_at = NOW() " +
                  "WHERE transfer_request_id = ? AND status IN ('PENDING','EMPLOYEE_CONFIRMED')";
        } else {
            // Người tạo chỉ được hủy request PENDING của chính mình (chưa qua bước NV xác nhận)
            sql = "UPDATE transfer_requests SET status = 'CANCELLED', updated_at = NOW() " +
                  "WHERE transfer_request_id = ? AND status = 'PENDING' AND requested_by = ?";
        }
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, requestId);
            if (!isAdminOrHRManager) {
                ps.setInt(2, cancelledByUserId);
            }
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ── [EFFECTIVE DATE FLOW] applyTransferEffects ───────────────────────────

    /**
     * Thực thi đầy đủ hiệu ứng của điều chuyển: cập nhật users, employee_profiles,
     * work_history, và tạo phụ lục hợp đồng.
     *
     * QUAN TRỌNG: Hàm này không tự commit/rollback. Caller phụ trách transaction.
     *
     * @param conn        Connection đang trong transaction
     * @param req         TransferRequest đã được load (có employee_id, new_*, effective_date, ...)
     * @param requestId   ID của transfer request (dùng cho addendum_reason)
     * @param oldDeptName Tên phòng ban cũ (cho work_history)
     * @param newDeptName Tên phòng ban mới
     * @param oldPosName  Tên chức vụ cũ
     * @param newPosName  Tên chức vụ mới
     * @param oldRoleName Tên vai trò cũ
     * @param newRoleName Tên vai trò mới
     * @throws SQLException nếu có lỗi DB (caller sẽ rollback)
     */
    private void applyTransferEffects(
            Connection conn, TransferRequest req, int requestId,
            String oldDeptName, String newDeptName,
            String oldPosName,  String newPosName,
            String oldRoleName, String newRoleName) throws SQLException {

        // 1. UPDATE users (department_id, position_id, role_id)
        String updateUserSql = "UPDATE users SET department_id = ?, position_id = ?, role_id = ? WHERE user_id = ?";
        try (PreparedStatement psUpUser = conn.prepareStatement(updateUserSql)) {
            psUpUser.setInt(1, req.getNewDepartmentId());
            psUpUser.setInt(2, req.getNewPositionId());
            psUpUser.setInt(3, req.getNewRoleId());
            psUpUser.setInt(4, req.getEmployeeId());
            psUpUser.executeUpdate();
        }

        // 2. UPDATE employee_profiles (department_id)
        String updateProfileSql = "UPDATE employee_profiles SET department_id = ? WHERE user_id = ?";
        try (PreparedStatement psUpProfile = conn.prepareStatement(updateProfileSql)) {
            psUpProfile.setInt(1, req.getNewDepartmentId());
            psUpProfile.setInt(2, req.getEmployeeId());
            psUpProfile.executeUpdate();
        }

        // 3. Đóng work_history cũ
        WorkHistoryDAO whDAO = new WorkHistoryDAO();
        whDAO.closeCurrentHistory(conn, req.getEmployeeId(), req.getEffectiveDate());

        // 4. Insert work_history mới
        String description = "Điều chuyển nội bộ từ " + oldDeptName + " - " + oldPosName + " - " + oldRoleName
                           + " sang " + newDeptName + " - " + newPosName + " - " + newRoleName
                           + ". Lý do: " + req.getReason();
        whDAO.insertTransferHistory(conn, req.getEmployeeId(), newPosName, newDeptName, req.getEffectiveDate(), description);

        // 5. Lấy hợp đồng active hiện tại trong cùng conn
        EmployeeContract currentContract = getActiveContractInTransaction(conn, req.getEmployeeId());
        if (currentContract == null) {
            throw new SQLException("Không tìm thấy hợp đồng active cho nhân viên ID=" + req.getEmployeeId()
                    + ". Không thể tạo phụ lục điều chuyển.");
        }

        // 6. Tạo ADDENDUM phản ánh vị trí mới
        EmployeeContract addendum = new EmployeeContract();
        addendum.setUserId(req.getEmployeeId());
        addendum.setContractTypeId(currentContract.getContractTypeId());
        addendum.setPositionId(req.getNewPositionId());
        addendum.setDepartmentId(req.getNewDepartmentId());
        if (req.getNewSalaryGradeId() != null) {
            addendum.setSalaryGradeId(req.getNewSalaryGradeId());
        } else {
            addendum.setSalaryGradeId(currentContract.getSalaryGradeId());
        }
        if (req.getNewBaseSalary() != null) {
            addendum.setBaseSalary(req.getNewBaseSalary());
        } else {
            addendum.setBaseSalary(currentContract.getBaseSalary());
        }
        addendum.setTaxCalcType(currentContract.getTaxCalcType());
        addendum.setStartDate(req.getEffectiveDate());
        addendum.setEndDate(currentContract.getEndDate());
        addendum.setParentContractId(currentContract.getContractId());
        addendum.setAddendumReason("Điều chuyển nội bộ #" + requestId);

        EmployeeContractDAO contractDAO = new EmployeeContractDAO();
        contractDAO.insertAddendumInTransaction(conn, addendum);
    }

    /**
     * Phê duyệt yêu cầu điều chuyển nội bộ (HR Manager bước cuối).
     *
     * Logic mới (Effective Date Flow):
     *   1. SELECT FOR UPDATE, validate status = MANAGER_APPROVED
     *   2. UPDATE transfer_requests -> status='APPROVED', approved_by, approved_at
     *   3. Nếu effective_date <= hôm nay:
     *        -> gọi applyTransferEffects() trong cùng transaction
     *        -> UPDATE status='COMPLETED', applied_at=NOW()
     *   4. Nếu effective_date ở tương lai:
     *        -> giữ status='APPROVED', applied_at=NULL (scheduler sẽ xử lý sau)
     *   5. Commit
     *   6. Gửi notification tương ứng
     */
    public boolean approveTransferRequest(int requestId, int approverId) {
        Connection conn = null;
        // Biến để gửi notification sau commit (outside transaction)
        int employeeIdForNotif = 0;
        int newDeptIdForNotif  = 0;
        String newDeptNameForNotif = "";
        boolean appliedImmediately = false;
        java.sql.Date effectiveDateForNotif = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);

            // ── Bước 1: SELECT FOR UPDATE ───────────────────────────────────────
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
                        int oldRoleIdVal = rsSel.getInt("old_role_id");
                        req.setOldRoleId(rsSel.wasNull() ? null : oldRoleIdVal);
                        req.setNewDepartmentId(rsSel.getInt("new_department_id"));
                        req.setNewPositionId(rsSel.getInt("new_position_id"));
                        req.setNewRoleId(rsSel.getInt("new_role_id"));
                        req.setReason(rsSel.getString("reason"));
                        req.setEffectiveDate(rsSel.getDate("effective_date"));
                        req.setStatus(rsSel.getString("status"));
                        int newSgId = rsSel.getInt("new_salary_grade_id");
                        req.setNewSalaryGradeId(rsSel.wasNull() ? null : newSgId);
                        java.math.BigDecimal newBs = rsSel.getBigDecimal("new_base_salary");
                        req.setNewBaseSalary(rsSel.wasNull() ? null : newBs);
                    }
                }
            }

            if (req == null) {
                throw new SQLException("Transfer Request not found: " + requestId);
            }
            if (!"MANAGER_APPROVED".equals(req.getStatus())) {
                throw new SQLException("Transfer Request is not MANAGER_APPROVED (status=" + req.getStatus() + ")");
            }

            // ── Bước 2: Lấy tên phòng ban, chức vụ, vai trò ────────────────────────────
            String oldDeptName = "-", newDeptName = "-";
            String oldPosName  = "-", newPosName  = "-";
            String oldRoleName = "-", newRoleName = "-";

            try (PreparedStatement psDept = conn.prepareStatement(
                    "SELECT department_id, department_name FROM departments WHERE department_id IN (?, ?)")) {
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
            try (PreparedStatement psPos = conn.prepareStatement(
                    "SELECT position_id, position_name FROM positions WHERE position_id IN (?, ?)")) {
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
            try (PreparedStatement psRole = conn.prepareStatement(
                    "SELECT role_id, role_name FROM roles WHERE role_id IN (?, ?)")) {
                if (req.getOldRoleId() != null) psRole.setInt(1, req.getOldRoleId());
                else psRole.setNull(1, java.sql.Types.INTEGER);
                psRole.setInt(2, req.getNewRoleId());
                try (ResultSet rsRole = psRole.executeQuery()) {
                    while (rsRole.next()) {
                        int id = rsRole.getInt("role_id");
                        String name = rsRole.getString("role_name");
                        if (req.getOldRoleId() != null && id == req.getOldRoleId()) oldRoleName = name;
                        if (id == req.getNewRoleId()) newRoleName = name;
                    }
                }
            }

            // ── Bước 3: UPDATE transfer_requests -> APPROVED ───────────────────────
            String updateReqSql = "UPDATE transfer_requests " +
                "SET status = 'APPROVED', approved_by = ?, approved_at = NOW(), updated_at = NOW() " +
                "WHERE transfer_request_id = ?";
            try (PreparedStatement psUpReq = conn.prepareStatement(updateReqSql)) {
                psUpReq.setInt(1, approverId);
                psUpReq.setInt(2, requestId);
                psUpReq.executeUpdate();
            }

            // ── Bước 4: Kiểm tra effective_date ─────────────────────────────────────
            java.sql.Date today = new java.sql.Date(System.currentTimeMillis());
            if (!req.getEffectiveDate().after(today)) {
                // effective_date đã tới hoặc qua hạn -> áp dụng ngay trong cùng transaction
                applyTransferEffects(conn, req, requestId,
                        oldDeptName, newDeptName, oldPosName, newPosName, oldRoleName, newRoleName);
                // UPDATE status -> COMPLETED, applied_at = NOW()
                String completeReqSql = "UPDATE transfer_requests " +
                    "SET status = 'COMPLETED', applied_at = NOW(), updated_at = NOW() " +
                    "WHERE transfer_request_id = ?";
                try (PreparedStatement psCmp = conn.prepareStatement(completeReqSql)) {
                    psCmp.setInt(1, requestId);
                    psCmp.executeUpdate();
                }
                appliedImmediately = true;
            }
            // Nếu effective_date ở tương lai: giữ status='APPROVED', applied_at=NULL
            // Scheduler sẽ xử lý khi tới ngày

            // ── Commit Transaction ─────────────────────────────────────────────────
            conn.commit();

            employeeIdForNotif   = req.getEmployeeId();
            newDeptIdForNotif    = req.getNewDepartmentId();
            newDeptNameForNotif  = newDeptName;
            effectiveDateForNotif = req.getEffectiveDate();
            return true;

        } catch (Exception e) {
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            return false;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            // Gửi notification sau commit (outside transaction)
            if (employeeIdForNotif > 0) {
                sendTransferNotifications(employeeIdForNotif, newDeptIdForNotif, newDeptNameForNotif,
                        requestId, appliedImmediately, effectiveDateForNotif);
            }
        }
    }

    /**
     * [SCHEDULER] Xử lý các đơn điều chuyển đã tới effective_date nhưng chưa được áp dụng.
     * Được gọi mỗi ngày bởng TransferSchedulerListener.
     *
     * Algorithm:
     *   1. SELECT các request_id có status='APPROVED' AND applied_at IS NULL AND effective_date <= CURDATE()
     *   2. Với mỗi đơn: mở transaction riêng, SELECT FOR UPDATE, re-validate,
     *      gọi applyTransferEffects(), UPDATE status='COMPLETED', applied_at=NOW(), commit.
     *   3. Gửi notification sau commit.
     *
     * @return Số lượng đơn đã xử lý thành công.
     */
    public int processElapsedEffectiveTransfers() {
        // Bước 1: Lấy danh sách đơn cần xử lý
        String selectSql = "SELECT transfer_request_id FROM transfer_requests " +
                           "WHERE status = 'APPROVED' AND applied_at IS NULL AND effective_date <= CURDATE()";
        List<Integer> ids = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(selectSql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                ids.add(rs.getInt(1));
            }
        } catch (SQLException e) {
            System.err.println("[TransferScheduler] Lỗi query đơn điều chuyển cần xử lý: " + e.getMessage());
            return 0;
        }

        int processed = 0;
        for (int requestId : ids) {
            Connection conn = null;
            int employeeIdForNotif = 0;
            int newDeptIdForNotif  = 0;
            String newDeptNameForNotif = "";
            try {
                conn = DBContext.getConnection();
                conn.setAutoCommit(false);

                // Bước 2: SELECT FOR UPDATE để lock row, tránh race condition
                String lockSql = "SELECT * FROM transfer_requests WHERE transfer_request_id = ? FOR UPDATE";
                TransferRequest req = null;
                try (PreparedStatement psLock = conn.prepareStatement(lockSql)) {
                    psLock.setInt(1, requestId);
                    try (ResultSet rsLock = psLock.executeQuery()) {
                        if (rsLock.next()) {
                            req = new TransferRequest();
                            req.setTransferRequestId(rsLock.getInt("transfer_request_id"));
                            req.setEmployeeId(rsLock.getInt("employee_id"));
                            req.setOldDepartmentId(rsLock.getInt("old_department_id"));
                            req.setOldPositionId(rsLock.getInt("old_position_id"));
                            int oldRoleVal = rsLock.getInt("old_role_id");
                            req.setOldRoleId(rsLock.wasNull() ? null : oldRoleVal);
                            req.setNewDepartmentId(rsLock.getInt("new_department_id"));
                            req.setNewPositionId(rsLock.getInt("new_position_id"));
                            req.setNewRoleId(rsLock.getInt("new_role_id"));
                            req.setReason(rsLock.getString("reason"));
                            req.setEffectiveDate(rsLock.getDate("effective_date"));
                            req.setStatus(rsLock.getString("status"));
                            int newSgId = rsLock.getInt("new_salary_grade_id");
                            req.setNewSalaryGradeId(rsLock.wasNull() ? null : newSgId);
                            java.math.BigDecimal newBs = rsLock.getBigDecimal("new_base_salary");
                            req.setNewBaseSalary(rsLock.wasNull() ? null : newBs);
                        }
                    }
                }

                // Re-validate: chỉ xử lý nếu vẫn ở APPROVED và applied_at IS NULL và đã tới ngày
                if (req == null || !"APPROVED".equals(req.getStatus())) {
                    conn.rollback();
                    continue;
                }
                java.sql.Date today = new java.sql.Date(System.currentTimeMillis());
                if (req.getEffectiveDate().after(today)) {
                    conn.rollback();
                    continue;
                }

                // Lấy tên phòng ban, chức vụ, vai trò để ghi work_history
                String oldDeptName = "-", newDeptName = "-";
                String oldPosName  = "-", newPosName  = "-";
                String oldRoleName = "-", newRoleName = "-";

                try (PreparedStatement psDept = conn.prepareStatement(
                        "SELECT department_id, department_name FROM departments WHERE department_id IN (?, ?)")) {
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
                try (PreparedStatement psPos = conn.prepareStatement(
                        "SELECT position_id, position_name FROM positions WHERE position_id IN (?, ?)")) {
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
                try (PreparedStatement psRole = conn.prepareStatement(
                        "SELECT role_id, role_name FROM roles WHERE role_id IN (?, ?)")) {
                    if (req.getOldRoleId() != null) psRole.setInt(1, req.getOldRoleId());
                    else psRole.setNull(1, java.sql.Types.INTEGER);
                    psRole.setInt(2, req.getNewRoleId());
                    try (ResultSet rsRole = psRole.executeQuery()) {
                        while (rsRole.next()) {
                            int id = rsRole.getInt("role_id");
                            String name = rsRole.getString("role_name");
                            if (req.getOldRoleId() != null && id == req.getOldRoleId()) oldRoleName = name;
                            if (id == req.getNewRoleId()) newRoleName = name;
                        }
                    }
                }

                // Áp dụng hiệu ứng điều chuyển
                applyTransferEffects(conn, req, requestId,
                        oldDeptName, newDeptName, oldPosName, newPosName, oldRoleName, newRoleName);

                // UPDATE status='COMPLETED', applied_at=NOW()
                String completeSql = "UPDATE transfer_requests " +
                    "SET status = 'COMPLETED', applied_at = NOW(), updated_at = NOW() " +
                    "WHERE transfer_request_id = ?";
                try (PreparedStatement psCmp = conn.prepareStatement(completeSql)) {
                    psCmp.setInt(1, requestId);
                    psCmp.executeUpdate();
                }

                conn.commit();
                processed++;
                employeeIdForNotif  = req.getEmployeeId();
                newDeptIdForNotif   = req.getNewDepartmentId();
                newDeptNameForNotif = newDeptName;

                System.out.println("[TransferScheduler] Đã áp dụng điều chuyển requestId=" + requestId
                        + " cho nhân viên userId=" + req.getEmployeeId());

            } catch (Exception e) {
                System.err.println("[TransferScheduler] Lỗi xử lý requestId=" + requestId + ": " + e.getMessage());
                if (conn != null) {
                    try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
                }
            } finally {
                if (conn != null) {
                    try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ex) { ex.printStackTrace(); }
                }
                // Gửi notification sau khi commit xong
                if (employeeIdForNotif > 0) {
                    sendTransferCompletedNotifications(employeeIdForNotif, newDeptIdForNotif, newDeptNameForNotif, requestId);
                }
            }
        }
        return processed;
    }

    /**
     * Lấy hợp đồng ACTIVE của nhân viên trong cùng một transaction (dùng conn ngoài truyền vào).
     * Ưu tiên hợp đồng có start_date gần nhất và contract_id cao nhất.
     */
    private EmployeeContract getActiveContractInTransaction(Connection conn, int userId) throws SQLException {
        String sql = "SELECT ec.*, ct.type_name, p.position_name, d.department_name, sg.grade_name " +
                     "FROM employee_contracts ec " +
                     "LEFT JOIN contract_types ct ON ec.contract_type_id = ct.contract_type_id " +
                     "LEFT JOIN positions p ON ec.position_id = p.position_id " +
                     "LEFT JOIN departments d ON ec.department_id = d.department_id " +
                     "LEFT JOIN salary_grades sg ON ec.salary_grade_id = sg.salary_grade_id " +
                     "WHERE ec.user_id = ? AND ec.status = 'Active' " +
                     "ORDER BY ec.start_date DESC, ec.contract_id DESC " +
                     "LIMIT 1";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
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
                    c.setStatus(rs.getString("status"));
                    return c;
                }
            }
        }
        return null;
    }

    /**
     * [EFFECTIVE DATE FLOW] Gửi notification với 2 trường hợp:
     *   - Áp dụng ngay (effective_date đã tới)
     *   - Chờ ngày hiệu lực (scheduler sẽ xử lý sau)
     */
    private void sendTransferNotifications(int employeeId, int newDeptId, String newDeptName,
            int requestId, boolean appliedImmediately, java.sql.Date effectiveDate) {
        try {
            notificationDAO notifDAO = new notificationDAO();
            String detailLink = "/manager/transfer-approval-detail?id=" + requestId;
            String empMsg;
            if (appliedImmediately) {
                empMsg = "Yêu cầu điều chuyển nội bộ #" + requestId + " của bạn sang phòng " + newDeptName
                       + " đã được duyệt và có hiệu lực ngay hôm nay.";
            } else {
                String effStr = (effectiveDate != null)
                    ? new java.text.SimpleDateFormat("dd/MM/yyyy").format(effectiveDate) : "";
                empMsg = "Yêu cầu điều chuyển nội bộ #" + requestId + " của bạn sang phòng " + newDeptName
                       + " đã được duyệt. Hiệu lực từ ngày " + effStr + ".";
            }
            notifDAO.create(employeeId, "transfer",
                "Yêu cầu điều chuyển đã được phê duyệt", empMsg, detailLink);

            // Notify trưởng phòng mới
            String findManagerSql = "SELECT user_id FROM users " +
                                    "WHERE department_id = ? AND role_id IN (3, 6) AND status = 1 " +
                                    "ORDER BY user_id ASC LIMIT 1";
            try (Connection conn2 = DBContext.getConnection();
                 PreparedStatement ps2 = conn2.prepareStatement(findManagerSql)) {
                ps2.setInt(1, newDeptId);
                try (ResultSet rs2 = ps2.executeQuery()) {
                    if (rs2.next()) {
                        int managerId = rs2.getInt("user_id");
                        notifDAO.create(managerId, "transfer",
                            "Nhân sự mới sắp chuyển vào phòng của bạn",
                            "Yêu cầu điều chuyển #" + requestId + " đã được duyệt. Một nhân viên sẽ chuyển sang " + newDeptName + ".",
                            detailLink);
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("[TransferRequestDAO] Lỗi gửi notification approve requestId=" + requestId + ": " + e.getMessage());
        }
    }

    /**
     * [SCHEDULER] Gửi notification khi scheduler tự động áp dụng điều chuyển theo ngày hiệu lực.
     */
    private void sendTransferCompletedNotifications(int employeeId, int newDeptId, String newDeptName, int requestId) {
        try {
            notificationDAO notifDAO = new notificationDAO();
            String detailLink = "/hr/transfer-request/list";
            notifDAO.create(employeeId, "transfer",
                "Điều chuyển nội bộ đã có hiệu lực",
                "Kể từ hôm nay, bạn chính thức công tác tại phòng " + newDeptName
                + " theo yêu cầu điều chuyển #" + requestId + ".",
                detailLink);
        } catch (Exception e) {
            System.err.println("[TransferScheduler] Lỗi gửi notification completed requestId=" + requestId + ": " + e.getMessage());
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
        int oldRoleIdVal = rs.getInt("old_role_id");
        tr.setOldRoleId(rs.wasNull() ? null : oldRoleIdVal);
        tr.setOldRoleName(rs.getString("old_role_name"));
        tr.setNewDepartmentId(rs.getInt("new_department_id"));
        tr.setNewDepartmentName(rs.getString("new_dept_name"));
        tr.setNewPositionId(rs.getInt("new_position_id"));
        tr.setNewPositionName(rs.getString("new_pos_name"));
        tr.setNewRoleId(rs.getInt("new_role_id"));
        tr.setNewRoleName(rs.getString("new_role_name"));
        // [FIX #2] Đọc thêm 2 cột lương mới (nullable)
        int newSgId = rs.getInt("new_salary_grade_id");
        tr.setNewSalaryGradeId(rs.wasNull() ? null : newSgId);
        BigDecimal newBs = rs.getBigDecimal("new_base_salary");
        tr.setNewBaseSalary(rs.wasNull() ? null : newBs);
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
        // [2-STEP] Đọc thông tin duyệt bước 1 (Trưởng phòng)
        int mgrBy = rs.getInt("manager_approved_by");
        tr.setManagerApprovedBy(rs.wasNull() ? null : mgrBy);
        tr.setManagerApprovedByName(rs.getString("manager_approver_name"));
        tr.setManagerApprovedAt(rs.getTimestamp("manager_approved_at"));
        // [NEW FLOW] Đọc thông tin xác nhận của Nhân viên
        tr.setEmployeeConfirmedAt(rs.getTimestamp("employee_confirmed_at"));
        tr.setEmployeeRejectReason(rs.getString("employee_reject_reason"));
        // [EFFECTIVE DATE FLOW] applied_at (nullable)
        tr.setAppliedAt(rs.getTimestamp("applied_at"));
        return tr;
    }

    // ── Notification Helpers ──────────────────────────────────────────────────

    /**
     * [NEW FLOW] Gửi notification cho Nhân viên khi HR Staff tạo đơn điều chuyển.
     * Đây là bước đầu tiên trong luồng mới: NV cần xác nhận.
     */
    public void sendEmployeeNotificationOnCreate(int requestId, int employeeId, String employeeName) {
        try {
            notificationDAO notifDAO = new notificationDAO();
            notifDAO.create(
                employeeId,
                "transfer",
                "Bạn có yêu cầu điều chuyển cần xác nhận",
                "Hệ thống vừa tạo yêu cầu điều chuyển nội bộ #" + requestId + " cho bạn. Vui lòng xác nhận đồng ý hoặc từ chối.",
                "/employee/transfer-confirm"
            );
        } catch (Exception e) {
            System.err.println("[TransferRequestDAO] Lỗi gửi notification nhân viên requestId=" + requestId + ": " + e.getMessage());
        }
    }

    /**
     * [COMPAT] Giữ lại để không phá code cũ, nhưng redirect về sendEmployeeNotificationOnCreate.
     * @deprecated Dùng sendEmployeeNotificationOnCreate() theo luồng mới
     */
    @Deprecated
    public void sendDeptHeadNotification(int requestId, int employeeId, int oldDeptId, String employeeName) {
        sendEmployeeNotificationOnCreate(requestId, employeeId, employeeName);
    }

    /**
     * [NEW FLOW] Gửi notification cho Trưởng phòng khi Nhân viên xác nhận đồng ý.
     */
    private void sendDeptHeadNotificationOnConfirm(int requestId, int oldDeptId, String employeeName) {
        try {
            notificationDAO notifDAO = new notificationDAO();
            String detailLink = "/manager/transfer-approval-detail?id=" + requestId;
            String findManagerSql = "SELECT user_id FROM users " +
                                    "WHERE department_id = ? AND role_id IN (3, 6) AND status = 1 " +
                                    "ORDER BY user_id ASC LIMIT 1";
            try (Connection conn = DBContext.getConnection();
                 PreparedStatement ps = conn.prepareStatement(findManagerSql)) {
                ps.setInt(1, oldDeptId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        int deptHeadId = rs.getInt("user_id");
                        notifDAO.create(
                            deptHeadId,
                            "transfer",
                            "Yêu cầu điều chuyển cần phê duyệt",
                            "Nhân viên " + employeeName + " đã xác nhận yêu cầu điều chuyển nội bộ #" + requestId + ". Vui lòng phê duyệt bước 1.",
                            detailLink
                        );
                    }
                    // Nếu không tìm thấy Trưởng phòng — đơn vẫn EMPLOYEE_CONFIRMED, HR Manager có thể xử lý thay
                }
            }
        } catch (Exception e) {
            System.err.println("[TransferRequestDAO] Lỗi gửi notification Trưởng phòng requestId=" + requestId + ": " + e.getMessage());
        }
    }

    /**
     * [NEW FLOW] Gửi notification cho HR Staff người tạo đơn khi Nhân viên từ chối.
     */
    private void sendNotificationToRequester(int requestId, int requestedBy, String employeeName, String rejectReason) {
        try {
            notificationDAO notifDAO = new notificationDAO();
            notifDAO.create(
                requestedBy,
                "transfer",
                "Nhân viên đã từ chối điều chuyển",
                "Nhân viên " + employeeName + " đã từ chối yêu cầu điều chuyển nội bộ #" + requestId +
                (rejectReason != null && !rejectReason.isEmpty() ? ". Lý do: " + rejectReason : "") + ".",
                "/hr/transfer-requests"
            );
        } catch (Exception e) {
            System.err.println("[TransferRequestDAO] Lỗi gửi notification HR Staff requestId=" + requestId + ": " + e.getMessage());
        }
    }


    /**
     * [NEW FLOW] Gửi notification cho tất cả HR Manager (role 2) khi Trưởng phòng duyệt bước 1.
     */
    private void sendNotificationToHRManagers(int requestId) {
        try {
            notificationDAO notifDAO = new notificationDAO();
            String detailLink = "/manager/transfer-approval-detail?id=" + requestId;
            String findHRSql = "SELECT user_id FROM users WHERE role_id = 2 AND status = 1";
            try (Connection conn = DBContext.getConnection();
                 PreparedStatement ps = conn.prepareStatement(findHRSql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int hrManagerId = rs.getInt("user_id");
                    notifDAO.create(
                        hrManagerId,
                        "transfer",
                        "Yêu cầu điều chuyển đã qua bước duyệt Trưởng phòng",
                        "Yêu cầu điều chuyển nội bộ #" + requestId + " đã được Trưởng phòng phê duyệt. Vui lòng xác nhận lần cuối.",
                        detailLink
                    );
                }
            }
        } catch (Exception e) {
            System.err.println("[TransferRequestDAO] Lỗi gửi notification HR Manager requestId=" + requestId + ": " + e.getMessage());
        }
    }

    // ── TuVV: Department Manager Dashboard — đếm điều chuyển sắp có hiệu lực ──

    /**
     * Đếm số đơn điều chuyển đã duyệt và có effective_date trong N ngày tới.
     * Dùng cho card "Điều chuyển sắp có hiệu lực" trên Department Manager Dashboard.
     */
    public int countUpcomingEffectiveTransfers(int managerDepartmentId, int days) {
        String sql = "SELECT COUNT(*) FROM transfer_requests " +
                     "WHERE old_department_id = ? " +
                     "AND status IN ('MANAGER_APPROVED', 'APPROVED') " +
                     "AND effective_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL ? DAY)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, managerDepartmentId);
            ps.setInt(2, days);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
}

