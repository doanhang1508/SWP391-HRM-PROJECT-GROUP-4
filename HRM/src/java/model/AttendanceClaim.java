package model;

import java.sql.Date;
import java.sql.Timestamp;

/**
 * Model cho Attendance Claim (Đơn khiếu nại chấm công).
 * Nhân viên submit khi dữ liệu chấm công bị sai.
 */
public class AttendanceClaim {
    private int claimId;
    private int attendanceId;
    private int userId;
    private Date workDate;
    private String claimType;      // "MISSING", "WRONG_STATUS", "WRONG_TIME", "OTHER"
    private String description;
    private String status;         // "PENDING", "APPROVED", "REJECTED"
    private String hrNote;
    private int resolvedBy;
    private Timestamp resolvedAt;
    private Timestamp createdAt;

    // Display fields (join)
    private String userName;
    private String userDept;
    private String shiftName;
    private String currentStatus;  // current attendance status
    private String resolverName;

    public AttendanceClaim() {}

    public int getClaimId() { return claimId; }
    public void setClaimId(int claimId) { this.claimId = claimId; }

    public int getAttendanceId() { return attendanceId; }
    public void setAttendanceId(int attendanceId) { this.attendanceId = attendanceId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public Date getWorkDate() { return workDate; }
    public void setWorkDate(Date workDate) { this.workDate = workDate; }

    public String getClaimType() { return claimType; }
    public void setClaimType(String claimType) { this.claimType = claimType; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getHrNote() { return hrNote; }
    public void setHrNote(String hrNote) { this.hrNote = hrNote; }

    public int getResolvedBy() { return resolvedBy; }
    public void setResolvedBy(int resolvedBy) { this.resolvedBy = resolvedBy; }

    public Timestamp getResolvedAt() { return resolvedAt; }
    public void setResolvedAt(Timestamp resolvedAt) { this.resolvedAt = resolvedAt; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }

    public String getUserDept() { return userDept; }
    public void setUserDept(String userDept) { this.userDept = userDept; }

    public String getShiftName() { return shiftName; }
    public void setShiftName(String shiftName) { this.shiftName = shiftName; }

    public String getCurrentStatus() { return currentStatus; }
    public void setCurrentStatus(String currentStatus) { this.currentStatus = currentStatus; }

    public String getResolverName() { return resolverName; }
    public void setResolverName(String resolverName) { this.resolverName = resolverName; }
}
