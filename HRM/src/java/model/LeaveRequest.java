package model;

import java.sql.Date;
import java.sql.Timestamp;

public class LeaveRequest {
    private int requestId;
    private int userId;
    private int leaveTypeId;
    private Date startDate;
    private Date endDate;
    private double totalDays;
    private String reason;
    private String status; // Pending, Approved, Rejected
    private Integer approvedBy; // Nullable
    private Timestamp createdAt;
    private String attachment; // Document attachment (DOC, PDF)
    private String rejectReason; // Reason for rejection

    // Additional fields for display/join
    private String leaveTypeName;
    private String userName;
    private String departmentName;

    public LeaveRequest() {
    }

    public int getRequestId() {
        return requestId;
    }

    public void setRequestId(int requestId) {
        this.requestId = requestId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public int getLeaveTypeId() {
        return leaveTypeId;
    }

    public void setLeaveTypeId(int leaveTypeId) {
        this.leaveTypeId = leaveTypeId;
    }

    public Date getStartDate() {
        return startDate;
    }

    public void setStartDate(Date startDate) {
        this.startDate = startDate;
    }

    public Date getEndDate() {
        return endDate;
    }

    public void setEndDate(Date endDate) {
        this.endDate = endDate;
    }

    public double getTotalDays() {
        return totalDays;
    }

    public void setTotalDays(double totalDays) {
        this.totalDays = totalDays;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Integer getApprovedBy() {
        return approvedBy;
    }

    public void setApprovedBy(Integer approvedBy) {
        this.approvedBy = approvedBy;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getAttachment() {
        return attachment;
    }

    public void setAttachment(String attachment) {
        this.attachment = attachment;
    }

    public String getRejectReason() {
        return rejectReason;
    }

    public void setRejectReason(String rejectReason) {
        this.rejectReason = rejectReason;
    }

    public String getLeaveTypeName() {
        return leaveTypeName;
    }

    public void setLeaveTypeName(String leaveTypeName) {
        this.leaveTypeName = leaveTypeName;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getDepartmentName() {
        return departmentName;
    }

    public void setDepartmentName(String departmentName) {
        this.departmentName = departmentName;
    }

    /**
     * Kiểm tra dữ liệu đơn xin nghỉ phép hợp lệ.
     * Thuần Java, không cần Database.
     */
    public static String validate(LeaveRequest r) {
        if (r == null) return "LeaveRequest không được null";
        if (r.getUserId() <= 0)
            return "UserId phải lớn hơn 0";
        if (r.getLeaveTypeId() <= 0)
            return "Loại nghỉ phép phải hợp lệ (> 0)";
        if (r.getStartDate() == null)
            return "Ngày bắt đầu không được để trống";
        if (r.getEndDate() == null)
            return "Ngày kết thúc không được để trống";
        if (r.getStartDate().after(r.getEndDate()))
            return "Ngày bắt đầu không được sau ngày kết thúc";
        if (r.getTotalDays() <= 0)
            return "Số ngày nghỉ phải lớn hơn 0";
        if (r.getReason() == null || r.getReason().trim().isEmpty())
            return "Lý do không được để trống";
        return null; // null = hợp lệ
    }
}
