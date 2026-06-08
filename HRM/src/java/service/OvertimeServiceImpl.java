package service;

import dao.OvertimeAssignmentDAO;
import dao.OvertimeAssignmentDAOImpl;
import dao.OvertimePlanDAO;
import dao.OvertimePlanDAOImpl;
import model.OvertimeAssignment;
import model.OvertimePlan;
import util.DBContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * OvertimeServiceImpl — ALL business logic for Overtime Plan & Assignment management.
 *
 * Implements Use Case Diagram relationships:
 *   <<include>> Validate OT Rules            → validateOTRules()
 *   <<include>> Update OT Status in Attendance → approveOTAssignment() with JDBC transaction
 */
public class OvertimeServiceImpl implements OvertimeService {

    /**
     * Legal daily OT limit (Vietnamese Labor Code: max 4 hours/day OT)
     */
    private static final double MAX_DAILY_OT_HOURS = 4.0;

    private final OvertimePlanDAO planDAO;
    private final OvertimeAssignmentDAO assignmentDAO;

    public OvertimeServiceImpl() {
        this.planDAO = new OvertimePlanDAOImpl();
        this.assignmentDAO = new OvertimeAssignmentDAOImpl();
    }

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
    public List<OvertimeAssignment> getAssignmentsByPlan(int planId) {
        return assignmentDAO.getByPlanId(planId);
    }

    @Override
    public List<OvertimeAssignment> getAssignmentsByDepartment(int deptId) {
        return assignmentDAO.getByDepartmentId(deptId);
    }

    @Override
    public List<OvertimeAssignment> getPendingAssignmentsByDepartment(int deptId) {
        return assignmentDAO.getPendingByDepartmentId(deptId);
    }

    @Override
    public OvertimeAssignment getAssignmentById(int assignmentId) {
        return assignmentDAO.getById(assignmentId);
    }

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
        if (assignmentDAO.hasOverlap(assignment.getUserId(), assignment.getPlanId())) {
            throw new Exception("Nhân viên đã được phân công trong kế hoạch tăng ca này");
        }

        return assignmentDAO.create(assignment);
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
        double existingOTHours = assignmentDAO.getTotalOTHoursForDate(userId, targetDate);
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
        OvertimeAssignment assignment = assignmentDAO.getById(assignmentId);
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

    @Override
    public boolean cancelOTAssignment(int assignmentId) {
        return assignmentDAO.updateStatus(assignmentId, "Cancelled");
    }

    // ═══════════════════════════════════════════════════════════════
    // Employee Self-Service Views
    // ═══════════════════════════════════════════════════════════════
    @Override
    public List<OvertimeAssignment> getAssignmentsByUser(int userId) {
        return assignmentDAO.getByUserId(userId);
    }

    @Override
    public List<OvertimeAssignment> getUpcomingAssignmentsByUser(int userId) {
        List<OvertimeAssignment> all = assignmentDAO.getByUserId(userId);
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
        List<OvertimeAssignment> all = assignmentDAO.getByUserId(userId);
        List<OvertimeAssignment> past = new ArrayList<>();
        java.time.LocalDate today = java.time.LocalDate.now();
        for (OvertimeAssignment a : all) {
            if (a.getTargetDate() != null && a.getTargetDate().toLocalDate().isBefore(today)) {
                past.add(a);
            }
        }
        return past;
    }
}
