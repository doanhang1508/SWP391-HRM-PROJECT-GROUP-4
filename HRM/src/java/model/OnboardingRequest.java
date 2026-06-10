package model;

import java.sql.Timestamp;
import java.sql.Date;

/**
 * Model tương ứng với bảng onboarding_requests
 * Đại diện cho một yêu cầu tạo tài khoản nhân viên mới do HR gửi lên
 */
public class OnboardingRequest {

    private int     id;
    private String  fullName;
    private String  email;
    private String  phone;
    private String  cccdNumber;
    private Date    dateOfBirth;
    private String  address;
    private Integer gender;          // 1=Nam, 0=Nữ, null=Không xác định

    // Vị trí dự kiến
    private Integer departmentId;
    private Integer positionId;
    private int     roleId = 7;      // Mặc định: nhân viên

    // Trạng thái
    private String  status;          // DRAFT | PENDING | APPROVED | REJECTED
    private String  rejectReason;

    // Metadata
    private int     createdBy;
    private Integer processedBy;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // JOIN fields (không lưu DB — dùng khi JOIN query)
    private String departmentName;
    private String positionName;
    private String createdByName;    // tên HR gửi yêu cầu
    private String processedByName;  // tên Admin xử lý

    // ─── Constructor ────────────────────────────────────────────
    public OnboardingRequest() {}

    // ─── Getters & Setters ───────────────────────────────────────
    public int getId()                   { return id; }
    public void setId(int id)            { this.id = id; }

    public String getFullName()                      { return fullName; }
    public void setFullName(String fullName)          { this.fullName = fullName; }

    public String getEmail()                         { return email; }
    public void setEmail(String email)               { this.email = email; }

    public String getPhone()                         { return phone; }
    public void setPhone(String phone)               { this.phone = phone; }

    public String getCccdNumber()                    { return cccdNumber; }
    public void setCccdNumber(String cccdNumber)     { this.cccdNumber = cccdNumber; }

    public Date getDateOfBirth()                     { return dateOfBirth; }
    public void setDateOfBirth(Date dateOfBirth)     { this.dateOfBirth = dateOfBirth; }

    public String getAddress()                       { return address; }
    public void setAddress(String address)           { this.address = address; }

    public Integer getGender()                       { return gender; }
    public void setGender(Integer gender)            { this.gender = gender; }

    public Integer getDepartmentId()                 { return departmentId; }
    public void setDepartmentId(Integer departmentId){ this.departmentId = departmentId; }

    public Integer getPositionId()                   { return positionId; }
    public void setPositionId(Integer positionId)    { this.positionId = positionId; }

    public int getRoleId()                           { return roleId; }
    public void setRoleId(int roleId)                { this.roleId = roleId; }

    public String getStatus()                        { return status; }
    public void setStatus(String status)             { this.status = status; }

    public String getRejectReason()                  { return rejectReason; }
    public void setRejectReason(String rejectReason) { this.rejectReason = rejectReason; }

    public int getCreatedBy()                        { return createdBy; }
    public void setCreatedBy(int createdBy)          { this.createdBy = createdBy; }

    public Integer getProcessedBy()                  { return processedBy; }
    public void setProcessedBy(Integer processedBy)  { this.processedBy = processedBy; }

    public Timestamp getCreatedAt()                  { return createdAt; }
    public void setCreatedAt(Timestamp createdAt)    { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt()                  { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt)    { this.updatedAt = updatedAt; }

    // Join fields
    public String getDepartmentName()                { return departmentName; }
    public void setDepartmentName(String v)          { this.departmentName = v; }

    public String getPositionName()                  { return positionName; }
    public void setPositionName(String v)            { this.positionName = v; }

    public String getCreatedByName()                 { return createdByName; }
    public void setCreatedByName(String v)           { this.createdByName = v; }

    public String getProcessedByName()               { return processedByName; }
    public void setProcessedByName(String v)         { this.processedByName = v; }

    // ─── Helpers ────────────────────────────────────────────────
    public String getStatusLabel() {
        if (status == null) return "";
        switch (status) {
            case "DRAFT":    return "Bản nháp";
            case "PENDING":  return "Chờ duyệt";
            case "APPROVED": return "Đã duyệt";
            case "REJECTED": return "Từ chối";
            default:         return status;
        }
    }

    public String getGenderLabel() {
        if (gender == null) return "";
        return gender == 1 ? "Nam" : "Nữ";
    }

    /** Lấy chữ cái đầu của tên để hiển thị avatar */
    public String getInitial() {
        if (fullName == null || fullName.trim().isEmpty()) return "?";
        String[] parts = fullName.trim().split("\\s+");
        return parts[parts.length - 1].substring(0, 1).toUpperCase();
    }
}
