package dao;

import model.OvertimeAssignment;
import java.util.List;

/**
 * OvertimeAssignmentDAO — Data Access interface for `overtime_assignments` table.
 * Manages individual OT assignments to employees within OT plans.
 */
public interface OvertimeAssignmentDAO {

    List<OvertimeAssignment> getByPlanId(int planId);

    List<OvertimeAssignment> getByUserId(int userId);

    List<OvertimeAssignment> getByDepartmentId(int deptId);

    List<OvertimeAssignment> getPendingByDepartmentId(int deptId);

    OvertimeAssignment getById(int assignmentId);

    boolean create(OvertimeAssignment assignment);

    boolean updateStatus(int assignmentId, String status);

    /**
     * Check if user already has OT assigned on the target date of a specific plan.
     */
    boolean hasOverlap(int userId, int planId);

    /**
     * Get total approved OT hours for a user on a specific date.
     */
    double getTotalOTHoursForDate(int userId, java.sql.Date date);
}
