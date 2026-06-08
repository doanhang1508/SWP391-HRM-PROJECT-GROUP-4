package dao;

import model.OvertimeAssignment;
import model.OvertimePlan;
import util.DBContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * OvertimeAssignmentDAOImpl — JDBC implementation for `overtime_assignments` table.
 */
public class OvertimeAssignmentDAOImpl implements OvertimeAssignmentDAO {
    private static final double MAX_DAILY_OT_HOURS = 4.0;
    private dao.OvertimePlanDAO planDAO = new dao.OvertimePlanDAOImpl();
    
    private OvertimeAssignment mapRow(ResultSet rs) throws SQLException {
        OvertimeAssignment a = new OvertimeAssignment();
        a.setAssignmentId(rs.getInt("assignment_id"));
        a.setPlanId(rs.getInt("plan_id"));
        a.setUserId(rs.getInt("user_id"));
        a.setAssignedHours(rs.getDouble("assigned_hours"));
        a.setStatus(rs.getString("status"));
        a.setCreatedAt(rs.getTimestamp("created_at"));
        a.setEmployeeName(rs.getString("employee_name"));
        a.setPlanDescription(rs.getString("plan_description"));
        a.setTargetDate(rs.getDate("target_date"));
        a.setDepartmentName(rs.getString("department_name"));
        return a;
    }

    private static final String BASE_SELECT =
            "SELECT oa.*, u.full_name AS employee_name, "
          + "op.description AS plan_description, op.target_date, d.department_name "
          + "FROM overtime_assignments oa "
          + "JOIN users u ON oa.user_id = u.user_id "
          + "JOIN overtime_plans op ON oa.plan_id = op.plan_id "
          + "JOIN departments d ON op.dept_id = d.department_id ";

    @Override
    public List<OvertimeAssignment> getByPlanId(int planId) {
        List<OvertimeAssignment> list = new ArrayList<>();
        String sql = BASE_SELECT + "WHERE oa.plan_id = ? ORDER BY u.full_name";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, planId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("Error getByPlanId OTAssignment: " + e.getMessage());
        }
        return list;
    }

    @Override
    public List<OvertimeAssignment> getByUserId(int userId) {
        List<OvertimeAssignment> list = new ArrayList<>();
        String sql = BASE_SELECT + "WHERE oa.user_id = ? ORDER BY op.target_date DESC";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("Error getByUserId OTAssignment: " + e.getMessage());
        }
        return list;
    }

    @Override
    public List<OvertimeAssignment> getByDepartmentId(int deptId) {
        List<OvertimeAssignment> list = new ArrayList<>();
        String sql = BASE_SELECT + "WHERE op.dept_id = ? ORDER BY op.target_date DESC, u.full_name";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, deptId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("Error getByDepartmentId OTAssignment: " + e.getMessage());
        }
        return list;
    }

    @Override
    public List<OvertimeAssignment> getPendingByDepartmentId(int deptId) {
        List<OvertimeAssignment> list = new ArrayList<>();
        String sql = BASE_SELECT + "WHERE op.dept_id = ? AND oa.status = 'Pending' ORDER BY op.target_date DESC, u.full_name";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, deptId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("Error getPendingByDepartmentId: " + e.getMessage());
        }
        return list;
    }

    @Override
    public OvertimeAssignment getById(int assignmentId) {
        String sql = BASE_SELECT + "WHERE oa.assignment_id = ?";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, assignmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("Error getById OTAssignment: " + e.getMessage());
        }
        return null;
    }

    @Override
    public boolean create(OvertimeAssignment assignment) {
        String sql = "INSERT INTO overtime_assignments (plan_id, user_id, assigned_hours, status) "
                   + "VALUES (?, ?, ?, ?)";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, assignment.getPlanId());
            ps.setInt(2, assignment.getUserId());
            ps.setDouble(3, assignment.getAssignedHours());
            ps.setString(4, assignment.getStatus() != null ? assignment.getStatus() : "Pending");
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error create OTAssignment: " + e.getMessage());
        }
        return false;
    }

    @Override
    public boolean updateStatus(int assignmentId, String status) {
        String sql = "UPDATE overtime_assignments SET status = ? WHERE assignment_id = ?";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, assignmentId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error updateStatus OTAssignment: " + e.getMessage());
        }
        return false;
    }

    @Override
    public boolean hasOverlap(int userId, int planId) {
        String sql = "SELECT 1 FROM overtime_assignments WHERE user_id = ? AND plan_id = ?";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, planId);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        } catch (SQLException e) {
            System.err.println("Error hasOverlap: " + e.getMessage());
        }
        return false;
    }

    @Override
    public double getTotalOTHoursForDate(int userId, java.sql.Date date) {
        String sql = "SELECT COALESCE(SUM(oa.assigned_hours), 0) AS total_hours "
                   + "FROM overtime_assignments oa "
                   + "JOIN overtime_plans op ON oa.plan_id = op.plan_id "
                   + "WHERE oa.user_id = ? AND op.target_date = ? AND oa.status != 'Cancelled'";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setDate(2, date);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getDouble("total_hours");
            }
        } catch (SQLException e) {
            System.err.println("Error getTotalOTHoursForDate: " + e.getMessage());
        }
        return 0;
    }

    // --- Merged from Service ---


    // ═══════════════════════════════════════════════════════════════
    // Overtime Plan CRUD
    // ═══════════════════════════════════════════════════════════════
    @Override
    public List<OvertimePlan> getPlansByDepartment(int deptId) {
        return planDAO.getByDepartmentId(deptId);
    }

    @Override
    public OvertimePlan getPlanById(int planId) {
        return planDAO.getById(planId);
    }

    @Override
    public boolean createPlan(OvertimePlan plan) {
        return planDAO.create(plan);
    }

    @Override
    public boolean cancelPlan(int planId) {
        return planDAO.updateStatus(planId, "Cancelled");
    }

    // ═══════════════════════════════════════════════════════════════
    // Overtime Assignment CRUD
    // ═══════════════════════════════════════════════════════════════
    

    

    

    

    @Override
    public boolean createAssignment(OvertimeAssignment assignment) throws Exception {
        // Get plan to know the target_date
        OvertimePlan plan = planDAO.getById(assignment.getPlanId());
        if (plan == null) {
            throw new Exception("Kế hoạch tăng ca không tồn tại");
        }

        // <<include>> Validate OT Rules
        String validationError = validateOTRules(
                assignment.getUserId(),
                assignment.getAssignedHours(),
                plan.getTargetDate()
        );
        if (validationError != null) {
            throw new Exception(validationError);
        }

        // Check for duplicate assignment
        if (this.hasOverlap(assignment.getUserId(), assignment.getPlanId())) {
            throw new Exception("Nhân viên đã được phân công trong kế hoạch tăng ca này");
        }

        return this.create(assignment);
    }

    // ═══════════════════════════════════════════════════════════════
    // <<include>> Validate OT Rules
    //
    // Use Case: Called by "Assign Overtime to Employees".
    // Business Rules:
    //   1. Assigned OT hours must not exceed the legal daily limit (4h)
    //   2. Total OT hours for the date (existing + new) must not exceed the limit
    //   3. OT hours must be positive and reasonable
    // ═══════════════════════════════════════════════════════════════
    @Override
    public String validateOTRules(int userId, double assignedHours, Date targetDate) {
        // Rule 1: Basic validation
        if (assignedHours <= 0) {
            return "Số giờ tăng ca phải lớn hơn 0";
        }
        if (assignedHours > MAX_DAILY_OT_HOURS) {
            return "Số giờ tăng ca không được vượt quá " + (int) MAX_DAILY_OT_HOURS + " giờ/ngày (quy định pháp luật)";
        }

        // Rule 2: Check total OT hours for the date
        double existingOTHours = this.getTotalOTHoursForDate(userId, targetDate);
        if (existingOTHours + assignedHours > MAX_DAILY_OT_HOURS) {
            return "Tổng giờ tăng ca trong ngày vượt quá giới hạn " + (int) MAX_DAILY_OT_HOURS + "h. "
                 + "Hiện tại đã có " + existingOTHours + "h OT";
        }

        // Rule 3: Target date must not be in the past
        if (targetDate != null && targetDate.toLocalDate().isBefore(java.time.LocalDate.now())) {
            return "Không thể phân công tăng ca cho ngày trong quá khứ";
        }

        return null; // null = valid
    }

    // ═══════════════════════════════════════════════════════════════
    // <<include>> Update OT Status in Attendance
    //
    // Use Case: Called by "Approve / Cancel Assigned OT".
    // Transactional: setAutoCommit(false)
    //   Step 1: UPDATE overtime_assignments SET status = 'Approved'
    //   Step 2: UPDATE attendance SET overtime_hrs = ? WHERE user_id = ? AND work_date = ?
    //           (INSERT if no attendance record exists)
    //   Both must succeed or both rollback.
    // ═══════════════════════════════════════════════════════════════
    @Override
    public boolean approveOTAssignment(int assignmentId) throws Exception {
        // Get assignment details first
        OvertimeAssignment assignment = this.getById(assignmentId);
        if (assignment == null) {
            throw new Exception("Phân công tăng ca không tồn tại");
        }
        if (!"Pending".equals(assignment.getStatus())) {
            throw new Exception("Chỉ có thể duyệt phân công đang ở trạng thái 'Chờ duyệt'");
        }

        // Get plan for target_date
        OvertimePlan plan = planDAO.getById(assignment.getPlanId());
        if (plan == null) {
            throw new Exception("Kế hoạch tăng ca không tồn tại");
        }

        // ── TRANSACTION: setAutoCommit(false) ──────────────────────
        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            Connection rawConn = DBContext.unwrap(conn);
            rawConn.setAutoCommit(false);

            // Step 1: Update assignment status to 'Approved'
            String sqlAssignment = "UPDATE overtime_assignments SET status = 'Approved' "
                                 + "WHERE assignment_id = ? AND status = 'Pending'";
            try (PreparedStatement ps1 = rawConn.prepareStatement(sqlAssignment)) {
                ps1.setInt(1, assignmentId);
                int rows = ps1.executeUpdate();
                if (rows == 0) {
                    rawConn.rollback();
                    return false;
                }
            }

            // Step 2: <<include>> Update OT Status in Attendance
            // Check if attendance record exists for this user and date
            String sqlCheck = "SELECT attendance_id, overtime_hrs FROM attendance "
                            + "WHERE user_id = ? AND work_date = ?";
            try (PreparedStatement psCheck = rawConn.prepareStatement(sqlCheck)) {
                psCheck.setInt(1, assignment.getUserId());
                psCheck.setDate(2, plan.getTargetDate());
                try (ResultSet rs = psCheck.executeQuery()) {
                    if (rs.next()) {
                        // Record exists → UPDATE overtime_hrs
                        double existingHrs = rs.getDouble("overtime_hrs");
                        double newHrs = existingHrs + assignment.getAssignedHours();
                        String sqlUpdate = "UPDATE attendance SET overtime_hrs = ? "
                                         + "WHERE user_id = ? AND work_date = ?";
                        try (PreparedStatement psUpd = rawConn.prepareStatement(sqlUpdate)) {
                            psUpd.setDouble(1, newHrs);
                            psUpd.setInt(2, assignment.getUserId());
                            psUpd.setDate(3, plan.getTargetDate());
                            int attRows = psUpd.executeUpdate();
                            if (attRows == 0) {
                                throw new SQLException("Không thể cập nhật giờ OT vào bảng chấm công.");
                            }
                        }
                    } else {
                        // Attendance record does not exist
                        throw new SQLException("Chưa có dữ liệu chấm công (Attendance) cho ngày này. Cần có dữ liệu check-in để duyệt OT.");
                    }
                }
            }

            // COMMIT both operations
            rawConn.commit();
            rawConn.setAutoCommit(true);
            return true;

        } catch (SQLException e) {
            // ROLLBACK on any error
            if (conn != null) {
                try {
                    Connection rawConn = DBContext.unwrap(conn);
                    rawConn.rollback();
                    rawConn.setAutoCommit(true);
                } catch (SQLException ex) {
                    System.err.println("Error during rollback: " + ex.getMessage());
                }
            }
            throw new Exception("Lỗi khi duyệt tăng ca: " + e.getMessage());
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException ignored) {}
            }
        }
    }

    

    // ═══════════════════════════════════════════════════════════════
    // Employee Self-Service Views
    // ═══════════════════════════════════════════════════════════════
    

    @Override
    public List<OvertimeAssignment> getUpcomingAssignmentsByUser(int userId) {
        List<OvertimeAssignment> all = this.getByUserId(userId);
        List<OvertimeAssignment> upcoming = new ArrayList<>();
        java.time.LocalDate today = java.time.LocalDate.now();
        for (OvertimeAssignment a : all) {
            if (a.getTargetDate() != null && !a.getTargetDate().toLocalDate().isBefore(today)
                    && !"Cancelled".equals(a.getStatus())) {
                upcoming.add(a);
            }
        }
        return upcoming;
    }

    @Override
    public List<OvertimeAssignment> getPastAssignmentsByUser(int userId) {
        List<OvertimeAssignment> all = this.getByUserId(userId);
        List<OvertimeAssignment> past = new ArrayList<>();
        java.time.LocalDate today = java.time.LocalDate.now();
        for (OvertimeAssignment a : all) {
            if (a.getTargetDate() != null && a.getTargetDate().toLocalDate().isBefore(today)) {
                past.add(a);
            }
        }
        return past;
    }


    @Override
    public List<OvertimeAssignment> getAssignmentsByUser(int userId) {
        return this.getByUserId(userId);
    }

    @Override
    public boolean cancelOTAssignment(int assignmentId) {
        return this.updateStatus(assignmentId, "Cancelled");
    }

    @Override
    public OvertimeAssignment getAssignmentById(int assignmentId) {
        return this.getById(assignmentId);
    }

    @Override
    public List<OvertimeAssignment> getPendingAssignmentsByDepartment(int deptId) {
        return this.getPendingByDepartmentId(deptId);
    }

    @Override
    public List<OvertimeAssignment> getAssignmentsByDepartment(int deptId) {
        return this.getByDepartmentId(deptId);
    }

    @Override
    public List<OvertimeAssignment> getAssignmentsByPlan(int planId) {
        return this.getByPlanId(planId);
    }
}








