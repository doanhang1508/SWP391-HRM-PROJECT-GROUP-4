package model;

import java.math.BigDecimal;

public class Payroll {
    private int payrollId;
    private int userId;
    private int month;
    private int year;
    private BigDecimal baseSalary;
    private BigDecimal bonusAmount;
    private BigDecimal deductionAmount;
    private BigDecimal grossSalary;
    private BigDecimal netSalary;

    public Payroll() {}

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
    public BigDecimal getBonusAmount() { return bonusAmount; }
    public void setBonusAmount(BigDecimal bonusAmount) { this.bonusAmount = bonusAmount; }
    public BigDecimal getDeductionAmount() { return deductionAmount; }
    public void setDeductionAmount(BigDecimal deductionAmount) { this.deductionAmount = deductionAmount; }
    public BigDecimal getGrossSalary() { return grossSalary; }
    public void setGrossSalary(BigDecimal grossSalary) { this.grossSalary = grossSalary; }
    public BigDecimal getNetSalary() { return netSalary; }
    public void setNetSalary(BigDecimal netSalary) { this.netSalary = netSalary; }

    /**
     * Kiểm tra dữ liệu bảng lương hợp lệ.
     * Thuần Java, không cần Database.
     */
    public static String validate(Payroll p) {
        if (p == null) return "Payroll không được null";
        if (p.getUserId() <= 0)
            return "UserId phải lớn hơn 0";
        if (p.getMonth() < 1 || p.getMonth() > 12)
            return "Tháng phải từ 1 đến 12";
        if (p.getYear() < 2000)
            return "Năm không hợp lệ (phải >= 2000)";
        if (p.getBaseSalary() == null)
            return "Lương cơ bản không được null";
        if (p.getBaseSalary().compareTo(java.math.BigDecimal.ZERO) <= 0)
            return "Lương cơ bản phải lớn hơn 0";
        if (p.getBonusAmount() == null)
            return "Tiền thưởng không được null";
        if (p.getBonusAmount().compareTo(java.math.BigDecimal.ZERO) < 0)
            return "Tiền thưởng không được âm";
        if (p.getDeductionAmount() == null)
            return "Tiền khấu trừ không được null";
        if (p.getDeductionAmount().compareTo(java.math.BigDecimal.ZERO) < 0)
            return "Tiền khấu trừ không được âm";
        if (p.getNetSalary() != null && p.getNetSalary().compareTo(java.math.BigDecimal.ZERO) < 0)
            return "Lương thực nhận không được âm";
        return null; // null = hợp lệ
    }
}
