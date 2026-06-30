package model;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;

public class InsuranceRate {
    private int insuranceRateId;
    private String insuranceCode;
    private String insuranceName;
    private BigDecimal companyRate;
    private BigDecimal employeeRate;
    private String description;
    private Date effectiveFrom;
    private Date effectiveTo;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private boolean status;

    public InsuranceRate() {}

    /** Backward-compatible constructor (6 params) */
    public InsuranceRate(int insuranceRateId, String insuranceName,
                         BigDecimal companyRate, BigDecimal employeeRate,
                         String description, boolean status) {
        this.insuranceRateId = insuranceRateId;
        this.insuranceName   = insuranceName;
        this.companyRate     = companyRate;
        this.employeeRate    = employeeRate;
        this.description     = description;
        this.status          = status;
    }

    /** Full constructor */
    public InsuranceRate(int insuranceRateId, String insuranceCode, String insuranceName,
                         BigDecimal companyRate, BigDecimal employeeRate,
                         String description, Date effectiveFrom, Date effectiveTo,
                         Timestamp createdAt, Timestamp updatedAt, boolean status) {
        this.insuranceRateId = insuranceRateId;
        this.insuranceCode   = insuranceCode;
        this.insuranceName   = insuranceName;
        this.companyRate     = companyRate;
        this.employeeRate    = employeeRate;
        this.description     = description;
        this.effectiveFrom   = effectiveFrom;
        this.effectiveTo     = effectiveTo;
        this.createdAt       = createdAt;
        this.updatedAt       = updatedAt;
        this.status          = status;
    }

    public int getInsuranceRateId() { return insuranceRateId; }
    public void setInsuranceRateId(int v) { this.insuranceRateId = v; }

    public String getInsuranceCode() { return insuranceCode; }
    public void setInsuranceCode(String v) { this.insuranceCode = v; }

    public String getInsuranceName() { return insuranceName; }
    public void setInsuranceName(String v) { this.insuranceName = v; }

    public BigDecimal getCompanyRate() { return companyRate; }
    public void setCompanyRate(BigDecimal v) { this.companyRate = v; }

    public BigDecimal getEmployeeRate() { return employeeRate; }
    public void setEmployeeRate(BigDecimal v) { this.employeeRate = v; }

    public String getDescription() { return description; }
    public void setDescription(String v) { this.description = v; }

    public Date getEffectiveFrom() { return effectiveFrom; }
    public void setEffectiveFrom(Date v) { this.effectiveFrom = v; }

    public Date getEffectiveTo() { return effectiveTo; }
    public void setEffectiveTo(Date v) { this.effectiveTo = v; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp v) { this.createdAt = v; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp v) { this.updatedAt = v; }

    public boolean isStatus() { return status; }
    public void setStatus(boolean v) { this.status = v; }

    /** Alias for getInsuranceName() — backward compatibility */
    public String getName() { return insuranceName; }

    /**
     * Trả về loại đối tượng áp dụng: "Employee" hoặc "Company".
     * Quy ước: insurance_rates trong HRM áp dụng cho Employee.
     */
    public String getAppliedTo() { return "Employee"; }

    /**
     * Trả về tỷ lệ % phần nhân viên đóng (employee_rate).
     * Dùng để tính số tiền khấu trừ bảo hiểm từ lương nhân viên.
     */
    public BigDecimal getRatePercentage() { return employeeRate; }
}
