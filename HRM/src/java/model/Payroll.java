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
    // New fields for approval and payment flow
    private Integer approvedBy;
    private Timestamp approvedAt;
    private String rejectReason;
    private Integer paidBy;
    private Timestamp paidAt;
    private String paymentNote;

    // Transient: dùng để hiển thị, không lưu DB
    private String fullName;

    public Payroll() {}

    /**
     * Validate dữ liệu Payroll trước khi lưu.
     * @return null nếu hợp lệ, chuỗi thông báo lỗi nếu không hợp lệ.
     */
    public static String validate(Payroll p) {
        if (p == null) {
            return "Payroll không được null";
        }

        // Kiểm tra tháng hợp lệ (1 - 12)
        if (p.getMonth() < 1 || p.getMonth() > 12) {
            return "Tháng không hợp lệ: phải từ 1 đến 12";
        }

        // Kiểm tra năm hợp lệ (>= 2000)
        if (p.getYear() < 2000) {
            return "Năm không hợp lệ: phải từ 2000 trở đi";
        }

        // Kiểm tra baseSalary không null và > 0
        if (p.getBaseSalary() == null) {
            return "Lương cơ bản không được để trống";
        }
        if (p.getBaseSalary().compareTo(BigDecimal.ZERO) <= 0) {
            return "Lương cơ bản phải lớn hơn 0";
        }

        // Kiểm tra bonusAmount không null
        if (p.getBonusAmount() == null) {
            return "Tiền thưởng không được để trống";
        }

        // Kiểm tra deductionAmount không null
        if (p.getDeductionAmount() == null) {
            return "Tiền khấu trừ không được để trống";
        }

        // Kiểm tra netSalary không âm (nếu đã được set)
        if (p.getNetSalary() != null && p.getNetSalary().compareTo(BigDecimal.ZERO) < 0) {
            return "Lương thực nhận không được âm";
        }

        return null;
    }

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

    public Integer getApprovedBy() { return approvedBy; }
    public void setApprovedBy(Integer approvedBy) { this.approvedBy = approvedBy; }

    public Timestamp getApprovedAt() { return approvedAt; }
    public void setApprovedAt(Timestamp approvedAt) { this.approvedAt = approvedAt; }

    public String getRejectReason() { return rejectReason; }
    public void setRejectReason(String rejectReason) { this.rejectReason = rejectReason; }

    public Integer getPaidBy() { return paidBy; }
    public void setPaidBy(Integer paidBy) { this.paidBy = paidBy; }

    public Timestamp getPaidAt() { return paidAt; }
    public void setPaidAt(Timestamp paidAt) { this.paidAt = paidAt; }

    public String getPaymentNote() { return paymentNote; }
    public void setPaymentNote(String paymentNote) { this.paymentNote = paymentNote; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
}
