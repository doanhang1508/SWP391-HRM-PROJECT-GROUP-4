package model;

import java.sql.Timestamp;

/**
 * Model cho TimesheetLock (Khóa bảng chấm công theo tháng/năm).
 * HR khóa lại để xử lý payroll.
 */
public class TimesheetLock {
    private int lockId;
    private int month;
    private int year;
    private String status;         // "LOCKED", "UNLOCKED"
    private int lockedBy;
    private Timestamp lockedAt;
    private String note;

    // Display
    private String lockedByName;

    public TimesheetLock() {}

    public int getLockId() { return lockId; }
    public void setLockId(int lockId) { this.lockId = lockId; }

    public int getMonth() { return month; }
    public void setMonth(int month) { this.month = month; }

    public int getYear() { return year; }
    public void setYear(int year) { this.year = year; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public int getLockedBy() { return lockedBy; }
    public void setLockedBy(int lockedBy) { this.lockedBy = lockedBy; }

    public Timestamp getLockedAt() { return lockedAt; }
    public void setLockedAt(Timestamp lockedAt) { this.lockedAt = lockedAt; }

    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }

    public String getLockedByName() { return lockedByName; }
    public void setLockedByName(String lockedByName) { this.lockedByName = lockedByName; }
}
