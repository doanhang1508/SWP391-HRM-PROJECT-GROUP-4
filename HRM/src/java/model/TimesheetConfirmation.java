package model;

import java.sql.Timestamp;

public class TimesheetConfirmation {
    private int id;
    private int month;
    private int year;
    private int departmentId;
    private String status; // DRAFT, SENT_TO_DEPARTMENT, DEPARTMENT_CONFIRMED, DEPARTMENT_REJECTED, SENT_TO_HR_MANAGER, HR_MANAGER_APPROVED, HR_MANAGER_REJECTED
    private String rejectReason;
    private int createdBy;
    private Timestamp createdAt;
    private int updatedBy;
    private Timestamp updatedAt;

    // Display fields
    private String departmentName;
    private String createdByName;
    private String updatedByName;

    public TimesheetConfirmation() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getMonth() { return month; }
    public void setMonth(int month) { this.month = month; }

    public int getYear() { return year; }
    public void setYear(int year) { this.year = year; }

    public int getDepartmentId() { return departmentId; }
    public void setDepartmentId(int departmentId) { this.departmentId = departmentId; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getRejectReason() { return rejectReason; }
    public void setRejectReason(String rejectReason) { this.rejectReason = rejectReason; }

    public int getCreatedBy() { return createdBy; }
    public void setCreatedBy(int createdBy) { this.createdBy = createdBy; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public int getUpdatedBy() { return updatedBy; }
    public void setUpdatedBy(int updatedBy) { this.updatedBy = updatedBy; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public String getDepartmentName() { return departmentName; }
    public void setDepartmentName(String departmentName) { this.departmentName = departmentName; }

    public String getCreatedByName() { return createdByName; }
    public void setCreatedByName(String createdByName) { this.createdByName = createdByName; }

    public String getUpdatedByName() { return updatedByName; }
    public void setUpdatedByName(String updatedByName) { this.updatedByName = updatedByName; }
}
