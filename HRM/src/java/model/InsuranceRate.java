package model;

import java.math.BigDecimal;

public class InsuranceRate {
    private int insuranceRateId;
    private String insuranceName;
    private BigDecimal companyRate;
    private BigDecimal employeeRate;
    private String description;
    private boolean status;

    public InsuranceRate() {}

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

    public int getInsuranceRateId() { return insuranceRateId; }
    public void setInsuranceRateId(int insuranceRateId) { this.insuranceRateId = insuranceRateId; }

    public String getInsuranceName() { return insuranceName; }
    public void setInsuranceName(String insuranceName) { this.insuranceName = insuranceName; }

    public BigDecimal getCompanyRate() { return companyRate; }
    public void setCompanyRate(BigDecimal companyRate) { this.companyRate = companyRate; }

    public BigDecimal getEmployeeRate() { return employeeRate; }
    public void setEmployeeRate(BigDecimal employeeRate) { this.employeeRate = employeeRate; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public boolean isStatus() { return status; }
    public void setStatus(boolean status) { this.status = status; }
}
