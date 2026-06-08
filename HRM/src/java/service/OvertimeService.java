package service;

import model.OvertimeAssignment;
import model.OvertimePlan;
import java.sql.Date;
import java.util.List;

/**
 * OvertimeService — Service interface for Overtime Plan & Assignment management.
 *
 * Implements Use Case Diagram relationships:
 *   <<include>> Validate OT Rules            → validateOTRules()
 *   <<include>> Update OT Status in Attendance → approveOTAssignment() (transactional)
 */
public interface OvertimeService {

    // ═══════════════════════════════════════════════════════════════
    // Overtime Plan CRUD (Supervisor)
    // ═══════════════════════════════════════════════════════════════
    List<OvertimePlan> getPlansByDepartment(int deptId);
    OvertimePlan getPlanById(int planId);
    boolean createPlan(OvertimePlan plan);
    boolean cancelPlan(int planId);

    // ═══════════════════════════════════════════════════════════════
    // Overtime Assignment CRUD (Supervisor)
    // ═══════════════════════════════════════════════════════════════
    List<OvertimeAssignment> getAssignmentsByPlan(int planId);
    List<OvertimeAssignment> getAssignmentsByDepartment(int deptId);
    List<OvertimeAssignment> getPendingAssignmentsByDepartment(int deptId);
    OvertimeAssignment getAssignmentById(int assignmentId);
    boolean createAssignment(OvertimeAssignment assignment) throws Exception;

    // ═══════════════════════════════════════════════════════════════
    // <<include>> Validate OT Rules
    //
    // Called by "Assign Overtime to Employees".
    // Ensures:
    //   1. Assigned hours do not exceed legal daily OT limit (4 hours).
    //   2. Employee does not have overlapping regular shifts.
    //   3. Total OT hours for the date stay within legal bounds.
    // ═══════════════════════════════════════════════════════════════
    String validateOTRules(int userId, double assignedHours, Date targetDate);

    // ═══════════════════════════════════════════════════════════════
    // <<include>> Update OT Status in Attendance
    //
    // Called by "Approve / Cancel Assigned OT".
    // When status is set to "Approved", the system MUST:
    //   1. Update overtime_assignments.status = 'Approved'
    //   2. UPDATE attendance SET overtime_hrs = ? WHERE user_id = ? AND work_date = ?
    //   Both in a single SQL transaction (setAutoCommit(false)).
    // ═══════════════════════════════════════════════════════════════
    boolean approveOTAssignment(int assignmentId) throws Exception;
    boolean cancelOTAssignment(int assignmentId);

    // ═══════════════════════════════════════════════════════════════
    // Employee Self-Service Views
    // ═══════════════════════════════════════════════════════════════
    List<OvertimeAssignment> getAssignmentsByUser(int userId);
    List<OvertimeAssignment> getUpcomingAssignmentsByUser(int userId);
    List<OvertimeAssignment> getPastAssignmentsByUser(int userId);
}
