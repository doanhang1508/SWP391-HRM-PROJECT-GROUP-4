package model;

import java.sql.Date;
import java.sql.Timestamp;

/**
 * OvertimeAssignment Entity — maps to the `overtime_assignments` table.
 * Pure data carrier: represents an individual OT assignment to an employee.
 * All business logic resides in the DAO/Service layer.
 *
 * Schema (updated Phase 2A):
 *   assignment_id, plan_id, user_id, assigned_hours, status, created_at,
 *   actual_hours, approved_hours,
 *   employee_response, employee_response_at, employee_response_note
 *
 * employee_response lifecycle:
 *   PENDING   → nhân viên chưa phản hồi (default)
 *   ACCEPTED  → nhân viên đồng ý tăng ca
 *   DECLINED  → nhân viên từ chối (có ghi lý do)
 *
 * status (supervisor action) lifecycle:
 *   Pending   → chờ supervisor duyệt (chỉ duyệt được khi employee_response = ACCEPTED)
 *   Approved  → supervisor đã duyệt; approved_hours được sync vào attendance
 *   Cancelled → đã hủy
 */
public class OvertimeAssignment {

    // ── DB columns ──
    private int assignmentId;
    private int planId;
    private int userId;
    private double assignedHours;
    private String status;                  // Pending, Approved, Cancelled
    private Timestamp createdAt;

    // ── Phase 2A new columns ──
    private Double actualHours;             // Giờ OT thực tế đã làm (nhân viên/quản đốc confirm)
    private Double approvedHours;           // Giờ OT được phép chính thức (quản đốc duyệt)
    private String employeeResponse;        // PENDING | ACCEPTED | DECLINED
    private Timestamp employeeResponseAt;   // Thời điểm nhân viên phản hồi
    private String employeeResponseNote;    // Lý do từ chối (nếu DECLINED)

    // ── Transient: joined display fields ──
    private String employeeName;
    private String planDescription;
    private Date targetDate;
    private String departmentName;

    // ── No-arg constructor ──
    public OvertimeAssignment() {
        this.status = "Pending";
        this.employeeResponse = "PENDING";
    }

    // ── Getters & Setters ──

    public int getAssignmentId() { return assignmentId; }
    public void setAssignmentId(int assignmentId) { this.assignmentId = assignmentId; }

    public int getPlanId() { return planId; }
    public void setPlanId(int planId) { this.planId = planId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public double getAssignedHours() { return assignedHours; }
    public void setAssignedHours(double assignedHours) { this.assignedHours = assignedHours; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    // ── Phase 2A ──

    public Double getActualHours() { return actualHours; }
    public void setActualHours(Double actualHours) { this.actualHours = actualHours; }

    public Double getApprovedHours() { return approvedHours; }
    public void setApprovedHours(Double approvedHours) { this.approvedHours = approvedHours; }

    public String getEmployeeResponse() { return employeeResponse; }
    public void setEmployeeResponse(String employeeResponse) { this.employeeResponse = employeeResponse; }

    public Timestamp getEmployeeResponseAt() { return employeeResponseAt; }
    public void setEmployeeResponseAt(Timestamp employeeResponseAt) { this.employeeResponseAt = employeeResponseAt; }

    public String getEmployeeResponseNote() { return employeeResponseNote; }
    public void setEmployeeResponseNote(String employeeResponseNote) { this.employeeResponseNote = employeeResponseNote; }

    // ── Transient display ──

    public String getEmployeeName() { return employeeName; }
    public void setEmployeeName(String employeeName) { this.employeeName = employeeName; }

    public String getPlanDescription() { return planDescription; }
    public void setPlanDescription(String planDescription) { this.planDescription = planDescription; }

    public Date getTargetDate() { return targetDate; }
    public void setTargetDate(Date targetDate) { this.targetDate = targetDate; }

    public String getDepartmentName() { return departmentName; }
    public void setDepartmentName(String departmentName) { this.departmentName = departmentName; }

    // ── Helper methods ──

    /** Trả về true nếu nhân viên đã đồng ý tăng ca. */
    public boolean isAccepted() {
        return "ACCEPTED".equals(this.employeeResponse);
    }

    /** Trả về true nếu nhân viên từ chối tăng ca. */
    public boolean isDeclined() {
        return "DECLINED".equals(this.employeeResponse);
    }

    /**
     * Trả về số giờ OT hiệu quả để sync vào chấm công.
     * Ưu tiên approvedHours (nếu có), fallback về assignedHours.
     */
    public double getEffectiveHours() {
        return (approvedHours != null && approvedHours > 0) ? approvedHours : assignedHours;
    }
}
