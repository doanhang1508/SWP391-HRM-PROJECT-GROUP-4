package dao;

import model.OvertimeAssignment;
import java.util.List;
import model.OvertimePlan;
import java.sql.Date;

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

    List<OvertimePlan> getPlansByDepartment(int deptId);
    OvertimePlan getPlanById(int planId);
    boolean createPlan(OvertimePlan plan);
    boolean cancelPlan(int planId);
    List<OvertimeAssignment> getAssignmentsByPlan(int planId);
    List<OvertimeAssignment> getAssignmentsByDepartment(int deptId);
    List<OvertimeAssignment> getPendingAssignmentsByDepartment(int deptId);
    OvertimeAssignment getAssignmentById(int assignmentId);
    boolean createAssignment(OvertimeAssignment assignment) throws Exception;
    String validateOTRules(int userId, double assignedHours, Date targetDate);
    boolean approveOTAssignment(int assignmentId) throws Exception;
    boolean cancelOTAssignment(int assignmentId);
    List<OvertimeAssignment> getAssignmentsByUser(int userId);
    List<OvertimeAssignment> getUpcomingAssignmentsByUser(int userId);
    List<OvertimeAssignment> getPastAssignmentsByUser(int userId);

    /**
     * Nhân viên phản hồi (ACCEPT / DECLINE) đơn tăng ca của mình.
     * 
     * @param assignmentId ID đơn tăng ca
     * @param response     "ACCEPTED" hoặc "DECLINED"
     * @param note         Lý do từ chối (bắt buộc khi DECLINED, có thể null khi ACCEPTED)
     * @throws Exception nếu assignment không tồn tại hoặc trạng thái không hợp lệ
     */
    boolean respondToAssignment(int assignmentId, String response, String note) throws Exception;
}

