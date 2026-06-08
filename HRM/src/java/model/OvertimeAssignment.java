package model;

import java.sql.Date;
import java.sql.Timestamp;

/**
 * OvertimeAssignment Entity — maps to the `overtime_assignments` table.
 * Pure data carrier: represents an individual OT assignment to an employee.
 * All business logic resides in the Service layer.
 *
 * Schema: assignment_id, plan_id, user_id, assigned_hours, status, created_at
 */
public class OvertimeAssignment {

    private int assignmentId;
    private int planId;
    private int userId;
    private double assignedHours;
    private String status;          // Pending, Approved, Cancelled
    private Timestamp createdAt;

    // ── Transient: joined display fields ──
    private String employeeName;
    private String planDescription;
    private Date targetDate;
    private String departmentName;

    // ── No-arg constructor ──
    public OvertimeAssignment() {
        this.status = "Pending";
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

    public String getEmployeeName() { return employeeName; }
    public void setEmployeeName(String employeeName) { this.employeeName = employeeName; }

    public String getPlanDescription() { return planDescription; }
    public void setPlanDescription(String planDescription) { this.planDescription = planDescription; }

    public Date getTargetDate() { return targetDate; }
    public void setTargetDate(Date targetDate) { this.targetDate = targetDate; }

    public String getDepartmentName() { return departmentName; }
    public void setDepartmentName(String departmentName) { this.departmentName = departmentName; }
}
