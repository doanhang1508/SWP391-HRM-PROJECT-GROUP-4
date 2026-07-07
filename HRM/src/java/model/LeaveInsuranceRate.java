package model;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;

/**
 * Model cho bảng leave_insurance_rates.
 * Lưu tỷ lệ bảo hiểm xã hội (BHXH) chi trả cho từng loại nghỉ phép.
 * 
 * Ví dụ:
 *   - Nghỉ ốm (Sick Leave): BHXH chi trả 75% lương cơ bản
 *   - Nghỉ thai sản nữ (Maternity): BHXH chi trả 100% mức bình quân lương
 *   - Nghỉ thai sản nam (Paternity): BHXH chi trả 100% mức bình quân lương
 */
public class LeaveInsuranceRate {
    private int leaveInsuranceRateId;
    private int leaveTypeId;
    private BigDecimal insuranceRatePercent; // e.g. 75.00 for 75%
    private String description;
    private Date effectiveFrom;
    private Date effectiveTo;
    private boolean status;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Transient: joined from leave_types for display
    private String leaveTypeName;

    public LeaveInsuranceRate() {}

    public LeaveInsuranceRate(int leaveInsuranceRateId, int leaveTypeId,
                               BigDecimal insuranceRatePercent, String description,
                               Date effectiveFrom, Date effectiveTo,
                               boolean status, Timestamp createdAt, Timestamp updatedAt) {
        this.leaveInsuranceRateId = leaveInsuranceRateId;
        this.leaveTypeId = leaveTypeId;
        this.insuranceRatePercent = insuranceRatePercent;
        this.description = description;
        this.effectiveFrom = effectiveFrom;
        this.effectiveTo = effectiveTo;
        this.status = status;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    // Getters & Setters
    public int getLeaveInsuranceRateId() { return leaveInsuranceRateId; }
    public void setLeaveInsuranceRateId(int leaveInsuranceRateId) { this.leaveInsuranceRateId = leaveInsuranceRateId; }

    public int getLeaveTypeId() { return leaveTypeId; }
    public void setLeaveTypeId(int leaveTypeId) { this.leaveTypeId = leaveTypeId; }

    public BigDecimal getInsuranceRatePercent() { return insuranceRatePercent; }
    public void setInsuranceRatePercent(BigDecimal insuranceRatePercent) { this.insuranceRatePercent = insuranceRatePercent; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Date getEffectiveFrom() { return effectiveFrom; }
    public void setEffectiveFrom(Date effectiveFrom) { this.effectiveFrom = effectiveFrom; }

    public Date getEffectiveTo() { return effectiveTo; }
    public void setEffectiveTo(Date effectiveTo) { this.effectiveTo = effectiveTo; }

    public boolean isStatus() { return status; }
    public void setStatus(boolean status) { this.status = status; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public String getLeaveTypeName() { return leaveTypeName; }
    public void setLeaveTypeName(String leaveTypeName) { this.leaveTypeName = leaveTypeName; }

    /**
     * Trả về tỷ lệ dưới dạng decimal (e.g. 0.75 cho 75%).
     * Dùng trực tiếp trong phép nhân khi tính insurance benefit.
     */
    public BigDecimal getRateAsDecimal() {
        if (insuranceRatePercent == null) return BigDecimal.ZERO;
        return insuranceRatePercent.divide(new BigDecimal("100"), 4, java.math.RoundingMode.HALF_UP);
    }
}
