package model;

import java.math.BigDecimal;

public class SalaryGrade {
    private int salaryGradeId;
    private String gradeName;
    private BigDecimal minSalary;
    private BigDecimal maxSalary;
    private String description;
    private boolean status;

    public SalaryGrade() {}

    public SalaryGrade(int salaryGradeId, String gradeName,
                       BigDecimal minSalary, BigDecimal maxSalary,
                       String description, boolean status) {
        this.salaryGradeId = salaryGradeId;
        this.gradeName     = gradeName;
        this.minSalary     = minSalary;
        this.maxSalary     = maxSalary;
        this.description   = description;
        this.status        = status;
    }

    public int getSalaryGradeId() { return salaryGradeId; }
    public void setSalaryGradeId(int salaryGradeId) { this.salaryGradeId = salaryGradeId; }

    public String getGradeName() { return gradeName; }
    public void setGradeName(String gradeName) { this.gradeName = gradeName; }

    public BigDecimal getMinSalary() { return minSalary; }
    public void setMinSalary(BigDecimal minSalary) { this.minSalary = minSalary; }

    public BigDecimal getMaxSalary() { return maxSalary; }
    public void setMaxSalary(BigDecimal maxSalary) { this.maxSalary = maxSalary; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public boolean isStatus() { return status; }
    public void setStatus(boolean status) { this.status = status; }
}
