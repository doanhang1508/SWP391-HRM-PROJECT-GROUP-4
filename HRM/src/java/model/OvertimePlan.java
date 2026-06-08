package model;

import java.sql.Date;
import java.sql.Timestamp;

/**
 * OvertimePlan Entity — maps to the `overtime_plans` table.
 * Pure data carrier: represents an OT plan created by a Supervisor for their department.
 * All business logic resides in the Service layer.
 *
 * Schema: plan_id, dept_id, supervisor_id, target_date, description, status, created_at
 */
public class OvertimePlan {

    private int planId;
    private int deptId;
    private int supervisorId;
    private Date targetDate;
    private String description;
    private String status;        // Active, Completed, Cancelled
    private Timestamp createdAt;

    // ── Transient: joined display fields ──
    private String departmentName;
    private String supervisorName;
    private int assignmentCount;  // number of employees assigned

    // ── No-arg constructor ──
    public OvertimePlan() {
        this.status = "Active";
    }

    // ── Getters & Setters ──
    public int getPlanId() { return planId; }
    public void setPlanId(int planId) { this.planId = planId; }

    public int getDeptId() { return deptId; }
    public void setDeptId(int deptId) { this.deptId = deptId; }

    public int getSupervisorId() { return supervisorId; }
    public void setSupervisorId(int supervisorId) { this.supervisorId = supervisorId; }

    public Date getTargetDate() { return targetDate; }
    public void setTargetDate(Date targetDate) { this.targetDate = targetDate; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getDepartmentName() { return departmentName; }
    public void setDepartmentName(String departmentName) { this.departmentName = departmentName; }

    public String getSupervisorName() { return supervisorName; }
    public void setSupervisorName(String supervisorName) { this.supervisorName = supervisorName; }

    public int getAssignmentCount() { return assignmentCount; }
    public void setAssignmentCount(int assignmentCount) { this.assignmentCount = assignmentCount; }
}
