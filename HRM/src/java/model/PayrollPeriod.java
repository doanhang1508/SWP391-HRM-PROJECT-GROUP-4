package model;

import java.sql.Date;
import java.sql.Timestamp;

/**
 * Model cho bảng payroll_periods - Kỳ lương.
 */
public class PayrollPeriod {
    private int periodId;
    private String periodName;
    private int month;
    private int year;
    private Date startDate;
    private Date endDate;
    private String status; // OPEN, LOCKED, CLOSED
    private Integer lockedBy;
    private Timestamp lockedAt;
    private Timestamp createdAt;

    public PayrollPeriod() {}

    // Getters & Setters
    public int getPeriodId() { return periodId; }
    public void setPeriodId(int periodId) { this.periodId = periodId; }

    public String getPeriodName() { return periodName; }
    public void setPeriodName(String periodName) { this.periodName = periodName; }

    public int getMonth() { return month; }
    public void setMonth(int month) { this.month = month; }

    public int getYear() { return year; }
    public void setYear(int year) { this.year = year; }

    public Date getStartDate() { return startDate; }
    public void setStartDate(Date startDate) { this.startDate = startDate; }

    public Date getEndDate() { return endDate; }
    public void setEndDate(Date endDate) { this.endDate = endDate; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Integer getLockedBy() { return lockedBy; }
    public void setLockedBy(Integer lockedBy) { this.lockedBy = lockedBy; }

    public Timestamp getLockedAt() { return lockedAt; }
    public void setLockedAt(Timestamp lockedAt) { this.lockedAt = lockedAt; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
