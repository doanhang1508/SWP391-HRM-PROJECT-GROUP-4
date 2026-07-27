package dao;

import model.LeaveRequest;
import model.Attendance;
import java.time.LocalDate;
import java.time.DayOfWeek;
import model.LeaveType;
import util.DBContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.Map;
import java.util.HashMap;

import java.util.Arrays;


public class LeaveRequestDAOImpl implements LeaveRequestDAO {

    @Override
    public List<LeaveType> getAllLeaveTypes() {
    List<LeaveType> list = new ArrayList<>();
    String sql = "SELECT * FROM leave_types WHERE status = 1";
    try (Connection c = DBContext.getConnection();
         PreparedStatement ps = c.prepareStatement(sql);
         ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
            LeaveType type = new LeaveType();
            type.setLeaveTypeId(rs.getInt("leave_type_id"));
            type.setTypeName(rs.getString("type_name"));
            type.setDescription(rs.getString("description"));
            type.setPaidLeave(rs.getInt("paid_leave"));
            type.setMaxDaysPerYear((Integer) rs.getObject("max_days_per_year"));
            type.setStatus(rs.getInt("status"));
            list.add(type);
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return list;
}

    @Override
    public List<LeaveRequest> getRequestsByUserId(int userId) {
        List<LeaveRequest> list = new ArrayList<>();
        String sql = "SELECT lr.*, lt.type_name, u.full_name FROM leave_requests lr " +
                     "JOIN leave_types lt ON lr.leave_type_id = lt.leave_type_id " +
                     "JOIN users u ON lr.user_id = u.user_id " +
                     "WHERE lr.user_id = ? ORDER BY lr.created_at DESC";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
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

    @Override
    public List<LeaveRequest> getPendingRequestsByDepartment(int departmentId) {
        List<LeaveRequest> list = new ArrayList<>();
        String sql = "SELECT lr.*, lt.type_name, u.full_name FROM leave_requests lr " +
                     "JOIN leave_types lt ON lr.leave_type_id = lt.leave_type_id " +
                     "JOIN users u ON lr.user_id = u.user_id " +
                     "WHERE lr.status = 'Pending' ";
        if (departmentId > 0) {
            sql += "AND u.department_id = ? ";
        }
        sql += "ORDER BY lr.created_at DESC";
        
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            if (departmentId > 0) {
                ps.setInt(1, departmentId);
            }
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

    public List<LeaveRequest> getApprovedRequestsByDepartment(int departmentId) {
        List<LeaveRequest> list = new ArrayList<>();
        String sql = "SELECT lr.*, lt.type_name, u.full_name FROM leave_requests lr " +
                     "JOIN leave_types lt ON lr.leave_type_id = lt.leave_type_id " +
                     "JOIN users u ON lr.user_id = u.user_id " +
                     "WHERE lr.status = 'Approved' ";
        if (departmentId > 0) {
            sql += "AND u.department_id = ? ";
        }
        sql += "ORDER BY lr.start_date ASC";
        
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            if (departmentId > 0) {
                ps.setInt(1, departmentId);
            }
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

    public List<LeaveRequest> getAllRequestsByDepartment(int departmentId) {
        List<LeaveRequest> list = new ArrayList<>();
        String sql = "SELECT lr.*, lt.type_name, u.full_name FROM leave_requests lr " +
                     "JOIN leave_types lt ON lr.leave_type_id = lt.leave_type_id " +
                     "JOIN users u ON lr.user_id = u.user_id ";
        if (departmentId > 0) {
            sql += "WHERE u.department_id = ? ";
        }
        sql += "ORDER BY lr.created_at DESC";
        
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            if (departmentId > 0) {
                ps.setInt(1, departmentId);
            }
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

    @Override
    public boolean submitRequest(LeaveRequest request) {
        String sql = "INSERT INTO leave_requests (user_id, leave_type_id, start_date, end_date, total_days, reason, status, attachment) " +
                     "VALUES (?, ?, ?, ?, ?, ?, 'Pending', ?)";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, request.getUserId());
            ps.setInt(2, request.getLeaveTypeId());
            ps.setDate(3, request.getStartDate());
            ps.setDate(4, request.getEndDate());
            ps.setDouble(5, request.getTotalDays());
            ps.setString(6, request.getReason());
            ps.setString(7, request.getAttachment());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean updateRequestStatus(int requestId, String status, int approvedBy) {
        String sql = "UPDATE leave_requests SET status = ?, approved_by = ? WHERE request_id = ?";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, approvedBy);
            ps.setInt(3, requestId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public double getUsedLeaveDaysByType(int userId, int leaveTypeId, int year) {
        String sql = "SELECT SUM(total_days) as used_days FROM leave_requests " +
                     "WHERE user_id = ? AND leave_type_id = ? AND status IN ('Approved', 'Pending') " +
                     "AND YEAR(start_date) = ?";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, leaveTypeId);
            ps.setInt(3, year);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble("used_days");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    @Override
    public List<LeaveRequest> getAllRequests() {
        List<LeaveRequest> list = new ArrayList<>();
        String sql = "SELECT lr.*, lt.type_name, u.full_name, d.department_name FROM leave_requests lr " +
                     "JOIN leave_types lt ON lr.leave_type_id = lt.leave_type_id " +
                     "JOIN users u ON lr.user_id = u.user_id " +
                     "LEFT JOIN departments d ON u.department_id = d.department_id " +
                     "ORDER BY lr.created_at DESC";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public boolean addLeaveType(LeaveType leaveType) {
        String sql = "INSERT INTO leave_types (type_name, description, paid_leave, max_days_per_year, status) VALUES (?, ?, ?, ?, ?)";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, leaveType.getTypeName());
            ps.setString(2, leaveType.getDescription());
            ps.setInt(3, leaveType.getPaidLeave());
            if (leaveType.getMaxDaysPerYear() == null) {
                ps.setNull(4, Types.INTEGER);
            } else {
                ps.setInt(4, leaveType.getMaxDaysPerYear());
            }
            ps.setInt(5, leaveType.getStatus());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean updateLeaveType(LeaveType leaveType) {
        String sql = "UPDATE leave_types SET type_name = ?, description = ?, paid_leave = ?, max_days_per_year = ?, status = ? WHERE leave_type_id = ?";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, leaveType.getTypeName());
            ps.setString(2, leaveType.getDescription());
            ps.setInt(3, leaveType.getPaidLeave());
            if (leaveType.getMaxDaysPerYear() == null) {
                ps.setNull(4, Types.INTEGER);
            } else {
                ps.setInt(4, leaveType.getMaxDaysPerYear());
            }
            ps.setInt(5, leaveType.getStatus());
            ps.setInt(6, leaveType.getLeaveTypeId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean deleteLeaveType(int leaveTypeId) {
        String sql = "UPDATE leave_types SET status = 0 WHERE leave_type_id = ?";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, leaveTypeId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean hasOverlappingLeave(int userId, java.sql.Date startDate, java.sql.Date endDate) {
        String sql = "SELECT COUNT(*) FROM leave_requests WHERE user_id = ? AND status IN ('Approved', 'Pending') " +
                     "AND start_date <= ? AND end_date >= ?";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setDate(2, endDate);
            ps.setDate(3, startDate);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public LeaveType getLeaveTypeById(int leaveTypeId) {
        String sql = "SELECT * FROM leave_types WHERE leave_type_id = ?";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, leaveTypeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    LeaveType type = new LeaveType();
                    type.setLeaveTypeId(rs.getInt("leave_type_id"));
                    type.setTypeName(rs.getString("type_name"));
                    type.setDescription(rs.getString("description"));
                    type.setPaidLeave(rs.getInt("paid_leave"));
                    type.setMaxDaysPerYear((Integer) rs.getObject("max_days_per_year"));
                    type.setStatus(rs.getInt("status"));
                    return type;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    private LeaveRequest mapRow(ResultSet rs) throws SQLException {
        LeaveRequest lr = new LeaveRequest();
        lr.setRequestId(rs.getInt("request_id"));
        lr.setUserId(rs.getInt("user_id"));
        lr.setLeaveTypeId(rs.getInt("leave_type_id"));
        lr.setStartDate(rs.getDate("start_date"));
        lr.setEndDate(rs.getDate("end_date"));
        lr.setTotalDays(rs.getDouble("total_days"));
        lr.setReason(rs.getString("reason"));
        lr.setStatus(rs.getString("status"));
        
        // try to get attachment if column exists
        try {
            lr.setAttachment(rs.getString("attachment"));
        } catch (Exception e) {}
        
        try {
            lr.setRejectReason(rs.getString("reject_reason"));
        } catch (Exception e) {}
        
        int approvedBy = rs.getInt("approved_by");
        if (!rs.wasNull()) {
            lr.setApprovedBy(approvedBy);
        }
        lr.setCreatedAt(rs.getTimestamp("created_at"));
        
        // Joined columns
        lr.setLeaveTypeName(rs.getString("type_name"));
        lr.setUserName(rs.getString("full_name"));
        try {
            lr.setDepartmentName(rs.getString("department_name"));
        } catch(Exception e) {}
        return lr;
    }

    private static final double BASE_ANNUAL_LEAVE = 12.0;

    // ═══════════════════════════════════════════════════════════════
    // 1. Core Logic (Included Use Cases)
    // ═══════════════════════════════════════════════════════════════

    /**
     * Tính số ngày nghỉ của các loại nghỉ dựa trên lịch phân ca.
     */
    @Override
    public double calculateTotalLeaveDays(int userId, LocalDate startDate, LocalDate endDate) {
        if (startDate == null || endDate == null || startDate.isAfter(endDate)) {
            return 0;
        }
        
        dao.ShiftAssignmentDAO shiftAssignmentDAO = new dao.ShiftAssignmentDAOImpl();
        List<model.ShiftAssignment> assignments = shiftAssignmentDAO.getByUserAndDateRange(userId, startDate, endDate);
        
        java.util.Set<LocalDate> workingDays = new java.util.HashSet<>();
        for (model.ShiftAssignment sa : assignments) {
            workingDays.add(sa.getAssignedDate());
        }
        
        return workingDays.size();
    }

    @Override
    public double checkRemainingLeaveBalance(int userId, int leaveTypeId) throws Exception {
        LeaveType type = this.getLeaveTypeById(leaveTypeId);
        if (type == null) {
            throw new Exception("Loại nghỉ phép không tồn tại.");
        }
        
        int currentYear = LocalDate.now().getYear();
        double usedDays = this.getUsedLeaveDaysByType(userId, leaveTypeId, currentYear);
        
        // If it's Annual Leave (assume id 1 or maxDaysPerYear is set), we track it
        if (type.getMaxDaysPerYear() != null) {
            return Math.max(0, type.getMaxDaysPerYear() - usedDays);
        }
        
        // If it's the default "Annual Leave" logic with base 12
        if (leaveTypeId == 1) {
            return Math.max(0, BASE_ANNUAL_LEAVE - usedDays);
        }
        
        // For other leaves without a max, just return a high number or 0
        return 999.0;
    }

    @Override
    public void validateLeaveRequestData(LeaveRequest request) throws Exception {
        int leaveTypeId = request.getLeaveTypeId();
        LocalDate startDate = request.getStartDate().toLocalDate();
        LocalDate endDate   = request.getEndDate().toLocalDate();

        // ── Không cho phép type 6 (không còn được hỗ trợ) ──
        if (leaveTypeId == 6) {
            throw new Exception("Loại nghỉ này không còn được hỗ trợ. Vui lòng liên hệ bộ phận nhân sự.");
        }

        // ── Kiểm tra trạng thái nhân sự ──
        EmployeeProfileDAO profileDAO = new EmployeeProfileDAO();
        model.EmployeeProfile profile = profileDAO.getByUserId(request.getUserId());
        if (profile != null) {
            int statusId = profile.getEmploymentStatusId();
            if (statusId == 4 || statusId == 6 || statusId == 7) {
                throw new Exception("Không thể tạo đơn nghỉ phép. Trạng thái nhân sự hiện tại: " + profile.getEmploymentStatusName());
            }
            if (statusId == 5) { // NoticePeriod
                ResignationDAO resDao = new ResignationDAO();
                java.util.List<model.ResignationRequest> requests = resDao.getByUserId(request.getUserId());
                for (model.ResignationRequest r : requests) {
                    if ("APPROVED".equals(r.getStatus()) && r.getLastWorkingDay() != null) {
                        if (endDate.isAfter(r.getLastWorkingDay().toLocalDate())) {
                            throw new Exception("Bạn đang trong thời gian báo trước nghỉ việc. Ngày kết thúc nghỉ phép không được vượt quá ngày làm việc cuối cùng (" + r.getLastWorkingDay() + ").");
                        }
                    }
                }
            }
        }

        // ── Validation ngày cơ bản ──
        if (startDate.isAfter(endDate)) {
            throw new Exception("Ngày bắt đầu không được lớn hơn ngày kết thúc.");
        }
        if (startDate.isBefore(LocalDate.now())) {
            throw new Exception("Không thể xin nghỉ phép cho ngày trong quá khứ.");
        }

        // ── Tính số ngày nghỉ — server tự tính lại, không tin frontend ──
        double calculatedDays = calculateTotalLeaveDays(request.getUserId(), startDate, endDate);

        if (calculatedDays <= 0) {
            throw new Exception("Bạn không có lịch làm việc nào trong khoảng thời gian này để xin nghỉ.");
        }

        // Cập nhật lại totalDays theo giá trị server tính
        request.setTotalDays(calculatedDays);

        // ── Kiểm tra trùng lịch nghỉ ──
        if (this.hasOverlappingLeave(request.getUserId(), request.getStartDate(), request.getEndDate())) {
            throw new Exception("Bạn đã có đơn nghỉ phép trong khoảng thời gian này.");
        }

        // ── Kiểm tra số dư phép (chỉ với loại có giới hạn) ──
        LeaveType type = this.getLeaveTypeById(leaveTypeId);
        if (type != null && (type.getLeaveTypeId() == 1 || type.getMaxDaysPerYear() != null)) {
            double remaining = checkRemainingLeaveBalance(request.getUserId(), leaveTypeId);
            if (request.getTotalDays() > remaining) {
                throw new Exception("Số ngày phép không đủ. Bạn chỉ còn " + remaining + " ngày phép.");
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // 2. Employee Actions
    // ═══════════════════════════════════════════════════════════════

    @Override
    public boolean submitLeaveRequest(LeaveRequest request) throws Exception {
        validateLeaveRequestData(request);
        return this.submitRequest(request);
    }

    

    // ═══════════════════════════════════════════════════════════════
    // 3. Supervisor Actions
    // ═══════════════════════════════════════════════════════════════

    

    

    

    // ═══════════════════════════════════════════════════════════════
    // 4. HR Manager Actions
    // ═══════════════════════════════════════════════════════════════

    

    

    

    

    


    @Override
    public List<LeaveRequest> getAllLeaveRequests() { return this.getAllRequests(); }

    @Override
    public boolean approveLeaveRequest(int requestId, int approvedBy) throws Exception {
        boolean updated = this.updateRequestStatus(requestId, "Approved", approvedBy);
        if (updated) {
            LeaveRequest request = getRequestById(requestId);
            if (request != null) {
                markApprovedLeaveAsAttendance(request);
            }
        }
        return updated;
    }

    /**
     * Lấy thông tin đơn nghỉ phép theo requestId. Dùng nội bộ sau khi duyệt đơn
     * để lấy user_id, start_date, end_date phục vụ việc ghi nhận chấm công.
     */
    @Override
    public LeaveRequest getRequestById(int requestId) {
        String sql = "SELECT * FROM leave_requests WHERE request_id = ?";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, requestId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    LeaveRequest r = new LeaveRequest();
                    r.setRequestId(rs.getInt("request_id"));
                    r.setUserId(rs.getInt("user_id"));
                    r.setLeaveTypeId(rs.getInt("leave_type_id"));
                    r.setStartDate(rs.getDate("start_date"));
                    r.setEndDate(rs.getDate("end_date"));
                    r.setTotalDays(rs.getDouble("total_days"));
                    r.setStatus(rs.getString("status"));
                    return r;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Ghi nhận mỗi ngày trong khoảng nghỉ phép đã duyệt vào bảng attendance với
     * status = 'Leave'. Áp dụng cho CẢ nghỉ có lương và không lương (nghỉ ốm,
     * thai sản), vì mục tiêu là ngày nghỉ vẫn được TÍNH LÀ CHẤM CÔNG (hiện diện),
     * không phải vắng mặt. Việc ngày đó có được TRẢ LƯƠNG hay không do
     * PayrollDAO xử lý riêng qua getPaidLeaveDaySet/getUnpaidLeaveDayMapWithShift,
     * và không bị ảnh hưởng bởi thay đổi này vì getPaidAttendanceDayMap không
     * đọc status 'Leave'.
     * <p>
     * Dùng INSERT IGNORE để KHÔNG ghi đè lên bản ghi chấm công thật đã tồn tại
     * (ví dụ nhân viên đã chấm công vào/ra ngày đó trước khi đơn được duyệt).
     * Bỏ qua các ngày rơi vào tháng đã bị khóa (timesheet_lock = LOCKED).
     */
    private void markApprovedLeaveAsAttendance(LeaveRequest request) {
        if (request.getStartDate() == null || request.getEndDate() == null) {
            return;
        }
        LocalDate start = request.getStartDate().toLocalDate();
        LocalDate end = request.getEndDate().toLocalDate();

        int defaultShiftId = getDefaultShiftId();
        if (defaultShiftId <= 0) {
            return; // Không có shift nào trong hệ thống, không thể ghi attendance (shift_id NOT NULL)
        }

        dao.AttendanceDAO attendanceDAO = new dao.AttendanceDAO();
        String shiftLookupSql = "SELECT shift_id FROM shift_assignments WHERE user_id = ? AND assigned_date = ?";
        String insertSql = "INSERT IGNORE INTO attendance (user_id, shift_id, work_date, status, overtime_hrs, created_at) " +
                            "VALUES (?, ?, ?, 'Leave', 0, NOW())";

        try (Connection c = DBContext.getConnection()) {
            LocalDate current = start;
            while (!current.isAfter(end)) {
                if (current.getDayOfWeek() != DayOfWeek.SUNDAY
                        && !attendanceDAO.isMonthLocked(current.getMonthValue(), current.getYear())) {

                    int shiftId = defaultShiftId;
                    try (PreparedStatement lookupPs = c.prepareStatement(shiftLookupSql)) {
                        lookupPs.setInt(1, request.getUserId());
                        lookupPs.setDate(2, java.sql.Date.valueOf(current));
                        try (ResultSet rs = lookupPs.executeQuery()) {
                            if (rs.next()) {
                                shiftId = rs.getInt("shift_id");
                            }
                        }
                    }

                    try (PreparedStatement insertPs = c.prepareStatement(insertSql)) {
                        insertPs.setInt(1, request.getUserId());
                        insertPs.setInt(2, shiftId);
                        insertPs.setDate(3, java.sql.Date.valueOf(current));
                        insertPs.executeUpdate();
                    }
                }
                current = current.plusDays(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    /**
     * Lấy shift_id mặc định (nhỏ nhất) để dùng khi nhân viên nghỉ phép vào ngày
     * không có shift_assignment nào được xếp trước. shift_id là NOT NULL trong
     * bảng attendance nên luôn cần một giá trị hợp lệ.
     */
    private int getDefaultShiftId() {
        String sql = "SELECT shift_id FROM shifts ORDER BY shift_id LIMIT 1";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt("shift_id");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    @Override
    public boolean rejectLeaveRequest(int requestId, int approvedBy, String rejectReason) throws Exception {
        String sql = "UPDATE leave_requests SET status = 'Rejected', approved_by = ?, reject_reason = ? WHERE request_id = ?";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, approvedBy);
            ps.setString(2, rejectReason);
            ps.setInt(3, requestId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public List<LeaveRequest> getPendingLeavesByDepartment(int departmentId) {
        return this.getPendingRequestsByDepartment(departmentId);
    }

    @Override
    public List<LeaveRequest> getApprovedLeavesByDepartment(int departmentId) {
        return this.getApprovedRequestsByDepartment(departmentId);
    }

    @Override
    public List<LeaveRequest> getAllLeavesByDepartment(int departmentId) {
        return this.getAllRequestsByDepartment(departmentId);
    }

    @Override
    public List<LeaveRequest> getLeaveHistoryByUserId(int userId) {
        return this.getRequestsByUserId(userId);
    }

    /**
     * @deprecated Dùng {@link #getPaidLeaveDaySet(int, int, int)} thay thế để tránh
     *             đếm trùng ngày khi kết hợp với dữ liệu chấm công.
     */
    @Deprecated
    @Override
    public double getPaidLeaveDays(int employeeId, int month, int year) {
        // Fetch all approved paid-leave requests that overlap with the target month.
        // A request overlaps if: start_date <= lastDayOfMonth AND end_date >= firstDayOfMonth
        LocalDate firstDayOfMonth = LocalDate.of(year, month, 1);
        LocalDate lastDayOfMonth  = firstDayOfMonth.withDayOfMonth(firstDayOfMonth.lengthOfMonth());

        String sql = "SELECT lr.start_date, lr.end_date " +
                     "FROM leave_requests lr " +
                     "JOIN leave_types lt ON lr.leave_type_id = lt.leave_type_id " +
                     "WHERE lr.user_id = ? " +
                     "  AND lr.status = 'Approved' " +
                     "  AND lt.paid_leave = 1 " +
                     "  AND lr.start_date <= ? " +
                     "  AND lr.end_date   >= ?";

        double totalDays = 0;
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, employeeId);
            ps.setDate(2, java.sql.Date.valueOf(lastDayOfMonth));
            ps.setDate(3, java.sql.Date.valueOf(firstDayOfMonth));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    LocalDate leaveStart = rs.getDate("start_date").toLocalDate();
                    LocalDate leaveEnd   = rs.getDate("end_date").toLocalDate();

                    // Clamp the leave range to the target month
                    LocalDate effectiveStart = leaveStart.isBefore(firstDayOfMonth) ? firstDayOfMonth : leaveStart;
                    LocalDate effectiveEnd   = leaveEnd.isAfter(lastDayOfMonth)     ? lastDayOfMonth  : leaveEnd;

                    // Count each day in the clamped range (exclude Sundays — working week is Mon-Sat)
                    LocalDate current = effectiveStart;
                    while (!current.isAfter(effectiveEnd)) {
                        if (current.getDayOfWeek() != DayOfWeek.SUNDAY) {
                            totalDays += 1;
                        }
                        current = current.plusDays(1);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return totalDays;
    }

    /**
     * Trả về tập (Set) các ngày nghỉ phép có lương đã duyệt trong tháng/năm chỉ định.
     * <p>
     * Sử dụng Set để bước sau có thể hợp (union) với tập ngày chấm công mà không đếm
     * trùng ngày nào đồng thời có cả attendance lẫn leave.
     * </p>
     * Logic giống method cũ: clamp phạm vi leave theo tháng, loại Chủ nhật.
     *
     * @param employeeId user_id của nhân viên
     * @param month      tháng cần tính (1–12)
     * @param year       năm cần tính
     * @return Set&lt;LocalDate&gt; các ngày nghỉ phép hợp lệ (không trùng nhau, không có Chủ nhật)
     */
    @Override
    public Set<LocalDate> getPaidLeaveDaySet(int employeeId, int month, int year) {
        LocalDate firstDayOfMonth = LocalDate.of(year, month, 1);
        LocalDate lastDayOfMonth  = firstDayOfMonth.withDayOfMonth(firstDayOfMonth.lengthOfMonth());

        String sql = "SELECT lr.start_date, lr.end_date " +
                     "FROM leave_requests lr " +
                     "JOIN leave_types lt ON lr.leave_type_id = lt.leave_type_id " +
                     "WHERE lr.user_id = ? " +
                     "  AND lr.status = 'Approved' " +
                     "  AND lt.paid_leave = 1 " +
                     "  AND lr.start_date <= ? " +
                     "  AND lr.end_date   >= ?";

        // Lấy tất cả shift assignments của nhân viên trong tháng để lọc các ngày được xếp lịch làm việc
        dao.ShiftAssignmentDAO shiftAssignmentDAO = new dao.ShiftAssignmentDAOImpl();
        List<model.ShiftAssignment> assignments = shiftAssignmentDAO.getByUserAndDateRange(employeeId, firstDayOfMonth, lastDayOfMonth);
        Set<LocalDate> assignedDates = new HashSet<>();
        if (assignments != null) {
            for (model.ShiftAssignment sa : assignments) {
                assignedDates.add(sa.getAssignedDate());
            }
        }

        // Tải tập hợp ngày lễ active trong tháng — ngày lễ không nằm trong standardWorkDays
        // nên nghỉ phép đúng ngày lễ không được tính vào ngày công thường.
        Set<LocalDate> activeHolidayDates = new HashSet<>();
        String sqlHoliday = "SELECT holiday_date FROM holidays "
                          + "WHERE status = 1 AND MONTH(holiday_date) = ? AND YEAR(holiday_date) = ?";
        try (Connection hConn = DBContext.getConnection();
             PreparedStatement hPs = hConn.prepareStatement(sqlHoliday)) {
            hPs.setInt(1, month);
            hPs.setInt(2, year);
            try (ResultSet hRs = hPs.executeQuery()) {
                while (hRs.next()) {
                    java.sql.Date hDate = hRs.getDate("holiday_date");
                    if (hDate != null) activeHolidayDates.add(hDate.toLocalDate());
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        Set<LocalDate> leaveDays = new HashSet<>();
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, employeeId);
            ps.setDate(2, java.sql.Date.valueOf(lastDayOfMonth));
            ps.setDate(3, java.sql.Date.valueOf(firstDayOfMonth));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    LocalDate leaveStart = rs.getDate("start_date").toLocalDate();
                    LocalDate leaveEnd   = rs.getDate("end_date").toLocalDate();

                    // Clamp phạm vi leave vào đúng tháng đang tính
                    LocalDate effectiveStart = leaveStart.isBefore(firstDayOfMonth) ? firstDayOfMonth : leaveStart;
                    LocalDate effectiveEnd   = leaveEnd.isAfter(lastDayOfMonth)     ? lastDayOfMonth  : leaveEnd;

                    // Chỉ tính ngày nghỉ phép nếu ngày đó:
                    // - Có phân ca làm việc (assignedDates)
                    // - Không phải Chủ nhật (SUNDAY không nằm trong standardWorkDays)
                    // - Không phải ngày lễ active (ngày lễ không nằm trong standardWorkDays)
                    LocalDate current = effectiveStart;
                    while (!current.isAfter(effectiveEnd)) {
                        boolean isSunday  = current.getDayOfWeek() == DayOfWeek.SUNDAY;
                        boolean isHoliday = activeHolidayDates.contains(current);
                        if (assignedDates.contains(current) && !isSunday && !isHoliday) {
                            leaveDays.add(current);
                        }
                        current = current.plusDays(1);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return leaveDays;
    }

    @Override
    public Map<LocalDate, Integer> getUnpaidLeaveDayMapWithShift(int employeeId, int month, int year) {
        LocalDate firstDayOfMonth = LocalDate.of(year, month, 1);
        LocalDate lastDayOfMonth  = firstDayOfMonth.withDayOfMonth(firstDayOfMonth.lengthOfMonth());

        String sql = "SELECT lr.start_date, lr.end_date, lr.leave_type_id " +
                     "FROM leave_requests lr " +
                     "JOIN leave_types lt ON lr.leave_type_id = lt.leave_type_id " +
                     "WHERE lr.user_id = ? " +
                     "  AND lr.status = 'Approved' " +
                     "  AND lt.paid_leave = 0 " +
                     "  AND lr.start_date <= ? " +
                     "  AND lr.end_date   >= ?";

        // Lấy tất cả shift assignments của nhân viên trong tháng
        dao.ShiftAssignmentDAO shiftAssignmentDAO = new dao.ShiftAssignmentDAOImpl();
        List<model.ShiftAssignment> assignments = shiftAssignmentDAO.getByUserAndDateRange(employeeId, firstDayOfMonth, lastDayOfMonth);
        Set<LocalDate> assignedDates = new HashSet<>();
        if (assignments != null) {
            for (model.ShiftAssignment sa : assignments) {
                assignedDates.add(sa.getAssignedDate());
            }
        }

        // Tải tập hợp ngày lễ active trong tháng
        // Nghỉ ốm đúng ngày lễ không được tính insuranceBenefit vì ngày lễ không nằm trong standardWorkDays.
        Set<LocalDate> activeHolidayDates = new HashSet<>();
        String sqlHoliday = "SELECT holiday_date FROM holidays "
                          + "WHERE status = 1 AND MONTH(holiday_date) = ? AND YEAR(holiday_date) = ?";
        try (Connection hConn = DBContext.getConnection();
             PreparedStatement hPs = hConn.prepareStatement(sqlHoliday)) {
            hPs.setInt(1, month);
            hPs.setInt(2, year);
            try (ResultSet hRs = hPs.executeQuery()) {
                while (hRs.next()) {
                    java.sql.Date hDate = hRs.getDate("holiday_date");
                    if (hDate != null) activeHolidayDates.add(hDate.toLocalDate());
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        // Fallback flag: nếu không có shift assignment nào, dùng tất cả ngày làm việc
        // bình thường (T2-T7, không CN, không lễ) cho các loại khác.
        boolean noShiftAssigned = assignedDates.isEmpty();

        Map<LocalDate, Integer> unpaidLeaveMap = new HashMap<>();
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, employeeId);
            ps.setDate(2, java.sql.Date.valueOf(lastDayOfMonth));
            ps.setDate(3, java.sql.Date.valueOf(firstDayOfMonth));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    LocalDate leaveStart = rs.getDate("start_date").toLocalDate();
                    LocalDate leaveEnd   = rs.getDate("end_date").toLocalDate();
                    int leaveTypeId      = rs.getInt("leave_type_id");

                    // Clamp phạm vi leave vào đúng tháng đang tính
                    LocalDate effectiveStart = leaveStart.isBefore(firstDayOfMonth) ? firstDayOfMonth : leaveStart;
                    LocalDate effectiveEnd   = leaveEnd.isAfter(lastDayOfMonth)     ? lastDayOfMonth  : leaveEnd;

                    LocalDate current = effectiveStart;
                    while (!current.isAfter(effectiveEnd)) {
                        boolean isSunday  = current.getDayOfWeek() == DayOfWeek.SUNDAY;
                        boolean isHoliday = activeHolidayDates.contains(current);
                        // Nghỉ ốm / loại khác: cần có shift assignment (hoặc fallback)
                        boolean isWorkDay = (noShiftAssigned || assignedDates.contains(current))
                                && !isSunday && !isHoliday;
                        if (isWorkDay) {
                            unpaidLeaveMap.put(current, leaveTypeId);
                        }
                        current = current.plusDays(1);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        // ── FALLBACK: đọc attendance.status = 'SICK_LEAVE' cho những ngày chưa có leave_request ──
        // Khi HR import Excel với mã "S" (SICK_LEAVE) mà nhân viên chưa nộp đơn nghỉ ốm,
        // hệ thống vẫn phải tính BHXH cho những ngày đó (leaveTypeId = 2: Nghỉ ốm hưởng BHXH).
        String sqlAttSick = "SELECT a.work_date FROM attendance a " +
                            "WHERE a.user_id = ? " +
                            "  AND MONTH(a.work_date) = ? AND YEAR(a.work_date) = ? " +
                            "  AND UPPER(a.status) = 'SICK_LEAVE' " +
                            "  AND DAYOFWEEK(a.work_date) != 1 " +
                            "  AND NOT EXISTS (" +
                            "      SELECT 1 FROM holidays h WHERE h.holiday_date = a.work_date AND h.status = 1)";
        try (Connection c2 = DBContext.getConnection();
             PreparedStatement ps2 = c2.prepareStatement(sqlAttSick)) {
            ps2.setInt(1, employeeId);
            ps2.setInt(2, month);
            ps2.setInt(3, year);
            try (ResultSet rs2 = ps2.executeQuery()) {
                while (rs2.next()) {
                    LocalDate sickDate = rs2.getDate("work_date").toLocalDate();
                    // putIfAbsent: ưu tiên leave_request nếu đã có, tránh ghi đè
                    unpaidLeaveMap.putIfAbsent(sickDate, 2); // 2 = Nghỉ ốm hưởng BHXH
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return unpaidLeaveMap;
    }
}
