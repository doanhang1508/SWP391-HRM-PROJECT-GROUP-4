package model;

import java.sql.Timestamp;
import java.sql.Date;

/**
 * Model mapping bảng resignation_requests.
 * Dùng cho luồng nhân viên tự xin nghỉ việc (self-resignation).
 * Khác với Termination (HR sa thải).
 */
public class ResignationRequest {

    private int       resignationId;
    private int       userId;
    private String    reason;
    private Date      desiredLastDate;
    private String    status;          // PENDING | APPROVED | REJECTED
    private Timestamp submittedAt;
    private int       reviewedBy;      // 0 = chưa có reviewer
    private Timestamp reviewedAt;
    private String    hrNote;
    private Integer   noticePeriodDays;
    private Date      expectedLeaveDate;
    private Date      lastWorkingDay;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // ── Transient fields (JOIN với bảng users để hiển thị tên) ──
    private String    employeeName;      // full_name của user_id
    private String    employeeUsername;  // username (mã NV) của user_id
    private String    reviewerName;      // full_name của reviewed_by

    public ResignationRequest() {}

    // ── Getters & Setters ──

    public int getResignationId() { return resignationId; }
    public void setResignationId(int resignationId) { this.resignationId = resignationId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }

    public Date getDesiredLastDate() { return desiredLastDate; }
    public void setDesiredLastDate(Date desiredLastDate) { this.desiredLastDate = desiredLastDate; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getSubmittedAt() { return submittedAt; }
    public void setSubmittedAt(Timestamp submittedAt) { this.submittedAt = submittedAt; }

    public int getReviewedBy() { return reviewedBy; }
    public void setReviewedBy(int reviewedBy) { this.reviewedBy = reviewedBy; }

    public Timestamp getReviewedAt() { return reviewedAt; }
    public void setReviewedAt(Timestamp reviewedAt) { this.reviewedAt = reviewedAt; }

    public String getHrNote() { return hrNote; }
    public void setHrNote(String hrNote) { this.hrNote = hrNote; }

    public Integer getNoticePeriodDays() { return noticePeriodDays; }
    public void setNoticePeriodDays(Integer noticePeriodDays) { this.noticePeriodDays = noticePeriodDays; }

    public Date getExpectedLeaveDate() { return expectedLeaveDate; }
    public void setExpectedLeaveDate(Date expectedLeaveDate) { this.expectedLeaveDate = expectedLeaveDate; }

    public Date getLastWorkingDay() { return lastWorkingDay; }
    public void setLastWorkingDay(Date lastWorkingDay) { this.lastWorkingDay = lastWorkingDay; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public String getEmployeeName() { return employeeName; }
    public void setEmployeeName(String employeeName) { this.employeeName = employeeName; }

    public String getEmployeeUsername() { return employeeUsername; }
    public void setEmployeeUsername(String employeeUsername) { this.employeeUsername = employeeUsername; }

    public String getReviewerName() { return reviewerName; }
    public void setReviewerName(String reviewerName) { this.reviewerName = reviewerName; }

    @Override
    public String toString() {
        return "ResignationRequest{id=" + resignationId
               + ", userId=" + userId
               + ", status=" + status
               + ", desiredLastDate=" + desiredLastDate + "}";
    }
}
