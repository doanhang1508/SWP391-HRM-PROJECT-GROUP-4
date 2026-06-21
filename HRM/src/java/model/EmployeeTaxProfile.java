package model;

import java.math.BigDecimal;
import java.sql.Timestamp;

/**
 * Model cho bảng employee_tax_profiles - Hồ sơ thuế của nhân viên.
 */
public class EmployeeTaxProfile {
    private int taxProfileId;
    private int userId;
    private String taxCode;
    private boolean taxRegistration;
    private int dependentCount;
    private BigDecimal personalDeduction;
    private BigDecimal dependentDeduction;
    private int status;
    private String notes;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Transient fields for display
    private String fullName;
    private String departmentName;

    public EmployeeTaxProfile() {}

    // Getters & Setters
    public int getTaxProfileId() { return taxProfileId; }
    public void setTaxProfileId(int taxProfileId) { this.taxProfileId = taxProfileId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getTaxCode() { return taxCode; }
    public void setTaxCode(String taxCode) { this.taxCode = taxCode; }

    public boolean isTaxRegistration() { return taxRegistration; }
    public void setTaxRegistration(boolean taxRegistration) { this.taxRegistration = taxRegistration; }

    public int getDependentCount() { return dependentCount; }
    public void setDependentCount(int dependentCount) { this.dependentCount = dependentCount; }

    public BigDecimal getPersonalDeduction() { return personalDeduction; }
    public void setPersonalDeduction(BigDecimal personalDeduction) { this.personalDeduction = personalDeduction; }

    public BigDecimal getDependentDeduction() { return dependentDeduction; }
    public void setDependentDeduction(BigDecimal dependentDeduction) { this.dependentDeduction = dependentDeduction; }

    public BigDecimal getTotalDeduction() {
        BigDecimal personal = personalDeduction != null ? personalDeduction : BigDecimal.ZERO;
        BigDecimal dependent = dependentDeduction != null ? dependentDeduction : BigDecimal.ZERO;
        return personal.add(dependent.multiply(BigDecimal.valueOf(dependentCount)));
    }

    public int getStatus() { return status; }
    public void setStatus(int status) { this.status = status; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getDepartmentName() { return departmentName; }
    public void setDepartmentName(String departmentName) { this.departmentName = departmentName; }
}
