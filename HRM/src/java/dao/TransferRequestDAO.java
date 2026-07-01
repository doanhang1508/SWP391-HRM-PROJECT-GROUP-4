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

    public List<TransferRequest> getAllTransferRequests() {
        List<TransferRequest> list = new ArrayList<>();
        String sql = "SELECT tr.*, u.full_name AS employee_name, " +
                     "d1.department_name AS old_dept_name, d2.department_name AS new_dept_name, " +
                     "p1.position_name AS old_pos_name, p2.position_name AS new_pos_name, " +
                     "r1.role_name AS old_role_name, r2.role_name AS new_role_name, " +
                     "ur.full_name AS requester_name, ua.full_name AS approver_name " +
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
                     "r1.role_name AS old_role_name, r2.role_name AS new_role_name, " +
                     "ur.full_name AS requester_name, ua.full_name AS approver_name " +
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
                     "r1.role_name AS old_role_name, r2.role_name AS new_role_name, " +
                     "ur.full_name AS requester_name, ua.full_name AS approver_name " +
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
            // Admin/HR Manager có thể hủy bất kỳ request PENDING nào
            sql = "UPDATE transfer_requests SET status = 'CANCELLED', updated_at = NOW() " +
                  "WHERE transfer_request_id = ? AND status = 'PENDING'";
        } else {
            // Người tạo chỉ được hủy request của chính mình
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

    /**
     * Phê duyệt yêu cầu điều chuyển nội bộ.
     *
     * Trong 1 atomic transaction, thực hiện đầy đủ:
     *   1. SELECT FOR UPDATE để lock row
     *   2. Validate status = PENDING
     *   3. Lấy tên phòng ban, chức vụ, vai trò (để ghi work_history)
     *   4. UPDATE transfer_requests → APPROVED
     *   5. UPDATE users (department_id, position_id, role_id)
     *   6. UPDATE employee_profiles (department_id)
     *   7. Đóng work_history cũ (closeCurrentHistory)
     *   8. Insert work_history mới (insertTransferHistory)
     *   9. [FIX #1] Lấy hợp đồng active hiện tại của nhân viên (trong cùng conn)
     *  10. [FIX #1] Insert ADDENDUM mới vào employee_contracts (status=Active, sign_status=SIGNED)
     *
     * Sau commit (không trong transaction, không critical):
     *  11. [FIX #3] Gửi notification cho nhân viên và trưởng phòng ban mới
     */
    public boolean approveTransferRequest(int requestId, int approverId) {
        Connection conn = null;
        // Các biến để gửi notification sau commit (outside transaction)
        int employeeIdForNotif = 0;
        int newDeptIdForNotif = 0;
        String employeeNameForNotif = "";
        String newDeptNameForNotif = "";
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false); // Bắt đầu transaction

            // ── Bước 1: SELECT FOR UPDATE ──────────────────────────────────────────
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
                        // [FIX #2] Lấy thông tin lương mới nếu có trong request
                        int newSgId = rsSel.getInt("new_salary_grade_id");
                        req.setNewSalaryGradeId(rsSel.wasNull() ? null : newSgId);
                        BigDecimal newBs = rsSel.getBigDecimal("new_base_salary");
                        req.setNewBaseSalary(rsSel.wasNull() ? null : newBs);
                    }
                }
            }

            if (req == null) {
                throw new SQLException("Transfer Request not found: " + requestId);
            }
            if (!"PENDING".equals(req.getStatus())) {
                throw new SQLException("Transfer Request is not PENDING (status=" + req.getStatus() + ")");
            }

            // ── Bước 2: Lấy tên phòng ban, chức vụ, vai trò để ghi work_history ──
            String oldDeptName = "-";
            String newDeptName = "-";
            String oldPosName = "-";
            String newPosName = "-";
            String oldRoleName = "-";
            String newRoleName = "-";

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

            String roleSql = "SELECT role_id, role_name FROM roles WHERE role_id IN (?, ?)";
            try (PreparedStatement psRole = conn.prepareStatement(roleSql)) {
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

            // ── Bước 3: UPDATE transfer_requests → APPROVED ────────────────────────
            String updateReqSql = "UPDATE transfer_requests SET status = 'APPROVED', approved_by = ?, approved_at = NOW(), updated_at = NOW() WHERE transfer_request_id = ?";
            try (PreparedStatement psUpReq = conn.prepareStatement(updateReqSql)) {
                psUpReq.setInt(1, approverId);
                psUpReq.setInt(2, requestId);
                psUpReq.executeUpdate();
            }

            // ── Bước 4: UPDATE users ────────────────────────────────────────────────
            String updateUserSql = "UPDATE users SET department_id = ?, position_id = ?, role_id = ? WHERE user_id = ?";
            try (PreparedStatement psUpUser = conn.prepareStatement(updateUserSql)) {
                psUpUser.setInt(1, req.getNewDepartmentId());
                psUpUser.setInt(2, req.getNewPositionId());
                psUpUser.setInt(3, req.getNewRoleId());
                psUpUser.setInt(4, req.getEmployeeId());
                psUpUser.executeUpdate();
            }

            // ── Bước 5: UPDATE employee_profiles ───────────────────────────────────
            String updateProfileSql = "UPDATE employee_profiles SET department_id = ? WHERE user_id = ?";
            try (PreparedStatement psUpProfile = conn.prepareStatement(updateProfileSql)) {
                psUpProfile.setInt(1, req.getNewDepartmentId());
                psUpProfile.setInt(2, req.getEmployeeId());
                psUpProfile.executeUpdate();
            }

            // ── Bước 6: Đóng work_history cũ ───────────────────────────────────────
            WorkHistoryDAO whDAO = new WorkHistoryDAO();
            whDAO.closeCurrentHistory(conn, req.getEmployeeId(), req.getEffectiveDate());

            // ── Bước 7: Insert work_history mới ────────────────────────────────────
            String description = "Điều chuyển nội bộ từ " + oldDeptName + " - " + oldPosName + " - " + oldRoleName
                               + " sang " + newDeptName + " - " + newPosName + " - " + newRoleName
                               + ". Lý do: " + req.getReason();
            whDAO.insertTransferHistory(conn, req.getEmployeeId(), newPosName, newDeptName, req.getEffectiveDate(), description);

            // ── Bước 8 [FIX #1]: Lấy hợp đồng active hiện tại trong cùng conn ─────
            // Dùng effective_date để tìm hợp đồng đang có hiệu lực tại thời điểm chuyển
            EmployeeContract currentContract = getActiveContractInTransaction(conn, req.getEmployeeId());

            if (currentContract == null) {
                throw new SQLException("Không tìm thấy hợp đồng active cho nhân viên ID=" + req.getEmployeeId()
                        + ". Không thể tạo phụ lục điều chuyển.");
            }

            // ── Bước 9 [FIX #1]: Tạo ADDENDUM mới phản ánh vị trí mới ────────────
            EmployeeContract addendum = new EmployeeContract();
            addendum.setUserId(req.getEmployeeId());
            addendum.setContractTypeId(currentContract.getContractTypeId()); // Giữ nguyên loại HĐ
            addendum.setPositionId(req.getNewPositionId());                  // Chức vụ MỚI
            addendum.setDepartmentId(req.getNewDepartmentId());              // Phòng ban MỚI
            // [FIX #2] Lương: ưu tiên giá trị mới từ request, fallback về hợp đồng cũ
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
            addendum.setTaxCalcType(currentContract.getTaxCalcType());       // Giữ nguyên cách tính thuế
            addendum.setStartDate(req.getEffectiveDate());                   // Có hiệu lực từ ngày chuyển
            addendum.setEndDate(currentContract.getEndDate());               // Kế thừa end_date hợp đồng gốc
            addendum.setParentContractId(currentContract.getContractId());   // Trỏ về hợp đồng cũ
            addendum.setAddendumReason("Điều chuyển nội bộ #" + requestId); // Ghi rõ nguồn gốc

            EmployeeContractDAO contractDAO = new EmployeeContractDAO();
            contractDAO.insertAddendumInTransaction(conn, addendum);

            // ── Commit Transaction ──────────────────────────────────────────────────
            conn.commit();

            // Lưu lại thông tin để gửi notification sau commit (không trong transaction)
            employeeIdForNotif  = req.getEmployeeId();
            newDeptIdForNotif   = req.getNewDepartmentId();
            employeeNameForNotif = oldDeptName; // dùng tạm, tên NV lấy từ notification body
            newDeptNameForNotif = newDeptName;
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
            // ── Bước 10 [FIX #3]: Gửi notification sau commit (outside transaction) ─
            // Không throw exception vì không ảnh hưởng tính đúng đắn của dữ liệu
            if (employeeIdForNotif > 0) {
                sendTransferNotifications(employeeIdForNotif, newDeptIdForNotif, newDeptNameForNotif, requestId);
            }
        }
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
     * [FIX #3] Gửi notification cho nhân viên và trưởng phòng mới sau khi approve.
     * Chạy NGOÀI transaction — nếu lỗi thì log nhưng không ảnh hưởng data.
     */
    private void sendTransferNotifications(int employeeId, int newDeptId, String newDeptName, int requestId) {
        try {
            notificationDAO notifDAO = new notificationDAO();
            String detailLink = "/manager/transfer-approval-detail?id=" + requestId;

            // Gửi cho nhân viên được điều chuyển
            notifDAO.create(
                employeeId,
                "transfer",
                "Yêu cầu điều chuyển đã được phê duyệt",
                "Yêu cầu điều chuyển nội bộ #" + requestId + " của bạn sang phòng " + newDeptName + " đã được duyệt và có hiệu lực.",
                detailLink
            );

            // Tìm trưởng phòng ban mới (Factory Manager roleId=3 hoặc Department Manager roleId=6)
            // để thông báo về nhân sự mới sắp về phòng
            String findManagerSql = "SELECT user_id FROM users " +
                                    "WHERE department_id = ? AND role_id IN (3, 6) AND status = 1 " +
                                    "ORDER BY user_id ASC LIMIT 1";
            try (Connection conn = DBContext.getConnection();
                 PreparedStatement ps = conn.prepareStatement(findManagerSql)) {
                ps.setInt(1, newDeptId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        int managerId = rs.getInt("user_id");
                        notifDAO.create(
                            managerId,
                            "transfer",
                            "Nhân sự mới điều chuyển vào phòng của bạn",
                            "Yêu cầu điều chuyển #" + requestId + " đã được duyệt. Một nhân viên mới sẽ chuyển sang " + newDeptName + " theo đúng ngày hiệu lực.",
                            detailLink
                        );
                    }
                }
            }
        } catch (Exception e) {
            // Ghi log nhưng không throw — không ảnh hưởng kết quả approve
            System.err.println("[TransferRequestDAO] Lỗi gửi notification sau approve requestId=" + requestId + ": " + e.getMessage());
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
        return tr;
    }
}
