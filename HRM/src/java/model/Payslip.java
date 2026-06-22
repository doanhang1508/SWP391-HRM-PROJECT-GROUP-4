package model;

import java.math.BigDecimal;
import java.sql.Timestamp;

/**
 * Model cho bảng payslips - Phiếu lương cuối cùng.
 */
public class Payslip {
    private int payslipId;
    private int payrollId;
    private int userId;
    private Integer periodId;
    private String payslipCode;
    private BigDecimal grossIncome;
    private BigDecimal totalDeduction;
    private BigDecimal insuranceAmount;
    private BigDecimal pitAmount;
    private BigDecimal netSalary;
    private String pitBreakdown;
    private String status;
    private Timestamp generatedAt;
    private Integer finalizedBy;
    private Timestamp finalizedAt;

    // Transient
    private String fullName;
    private int month;
    private int year;

    public Payslip() {}

    // Getters & Setters
    public int getPayslipId() { return payslipId; }
    public void setPayslipId(int payslipId) { this.payslipId = payslipId; }

    public int getPayrollId() { return payrollId; }
    public void setPayrollId(int payrollId) { this.payrollId = payrollId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public Integer getPeriodId() { return periodId; }
    public void setPeriodId(Integer periodId) { this.periodId = periodId; }

    public String getPayslipCode() { return payslipCode; }
    public void setPayslipCode(String payslipCode) { this.payslipCode = payslipCode; }

    public BigDecimal getGrossIncome() { return grossIncome; }
    public void setGrossIncome(BigDecimal grossIncome) { this.grossIncome = grossIncome; }

    public BigDecimal getTotalDeduction() { return totalDeduction; }
    public void setTotalDeduction(BigDecimal totalDeduction) { this.totalDeduction = totalDeduction; }

    public BigDecimal getInsuranceAmount() { return insuranceAmount; }
    public void setInsuranceAmount(BigDecimal insuranceAmount) { this.insuranceAmount = insuranceAmount; }

    public BigDecimal getPitAmount() { return pitAmount; }
    public void setPitAmount(BigDecimal pitAmount) { this.pitAmount = pitAmount; }

    public BigDecimal getNetSalary() { return netSalary; }
    public void setNetSalary(BigDecimal netSalary) { this.netSalary = netSalary; }

    public String getPitBreakdown() { return pitBreakdown; }
    public void setPitBreakdown(String pitBreakdown) { this.pitBreakdown = pitBreakdown; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getGeneratedAt() { return generatedAt; }
    public void setGeneratedAt(Timestamp generatedAt) { this.generatedAt = generatedAt; }

    public Integer getFinalizedBy() { return finalizedBy; }
    public void setFinalizedBy(Integer finalizedBy) { this.finalizedBy = finalizedBy; }

    public Timestamp getFinalizedAt() { return finalizedAt; }
    public void setFinalizedAt(Timestamp finalizedAt) { this.finalizedAt = finalizedAt; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public int getMonth() { return month; }
    public void setMonth(int month) { this.month = month; }

    public int getYear() { return year; }
    public void setYear(int year) { this.year = year; }
}
