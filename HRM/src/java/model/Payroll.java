package model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class Payroll {
    private int payrollId;
    private int userId;
    private int month;
    private int year;
    private BigDecimal baseSalary;
    private int workingDays;
    private BigDecimal overtimeAmount;
    private BigDecimal allowanceAmount;
    private BigDecimal bonusAmount;
    private BigDecimal deductionAmount;
    private BigDecimal insuranceAmount;
    private BigDecimal taxAmount;
    private BigDecimal grossSalary;
    private BigDecimal netSalary;
    private String status;
    private Timestamp createdAt;

    public Payroll() {}

    // Getters & Setters
    public int getPayrollId() { return payrollId; }
    public void setPayrollId(int payrollId) { this.payrollId = payrollId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public int getMonth() { return month; }
    public void setMonth(int month) { this.month = month; }

    public int getYear() { return year; }
    public void setYear(int year) { this.year = year; }

    public BigDecimal getBaseSalary() { return baseSalary; }
    public void setBaseSalary(BigDecimal baseSalary) { this.baseSalary = baseSalary; }

    public int getWorkingDays() { return workingDays; }
    public void setWorkingDays(int workingDays) { this.workingDays = workingDays; }

    public BigDecimal getOvertimeAmount() { return overtimeAmount; }
    public void setOvertimeAmount(BigDecimal overtimeAmount) { this.overtimeAmount = overtimeAmount; }

    public BigDecimal getAllowanceAmount() { return allowanceAmount; }
    public void setAllowanceAmount(BigDecimal allowanceAmount) { this.allowanceAmount = allowanceAmount; }

    public BigDecimal getBonusAmount() { return bonusAmount; }
    public void setBonusAmount(BigDecimal bonusAmount) { this.bonusAmount = bonusAmount; }

    public BigDecimal getDeductionAmount() { return deductionAmount; }
    public void setDeductionAmount(BigDecimal deductionAmount) { this.deductionAmount = deductionAmount; }

    public BigDecimal getInsuranceAmount() { return insuranceAmount; }
    public void setInsuranceAmount(BigDecimal insuranceAmount) { this.insuranceAmount = insuranceAmount; }

    public BigDecimal getTaxAmount() { return taxAmount; }
    public void setTaxAmount(BigDecimal taxAmount) { this.taxAmount = taxAmount; }

    public BigDecimal getGrossSalary() { return grossSalary; }
    public void setGrossSalary(BigDecimal grossSalary) { this.grossSalary = grossSalary; }

    public BigDecimal getNetSalary() { return netSalary; }
    public void setNetSalary(BigDecimal netSalary) { this.netSalary = netSalary; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
