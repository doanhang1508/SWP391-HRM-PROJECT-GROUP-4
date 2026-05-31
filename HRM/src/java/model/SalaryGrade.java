package model;

import java.math.BigDecimal;

public class SalaryGrade {
    private int salaryGradeId;
    private String gradeName;
    private BigDecimal baseSalary;
    private BigDecimal coefficient;
    private String description;
    private boolean status;

    public SalaryGrade() {}

    public SalaryGrade(int salaryGradeId, String gradeName,
                       BigDecimal baseSalary, BigDecimal coefficient,
                       String description, boolean status) {
        this.salaryGradeId = salaryGradeId;
        this.gradeName     = gradeName;
        this.baseSalary    = baseSalary;
        this.coefficient   = coefficient;
        this.description   = description;
        this.status        = status;
    }

    public int getSalaryGradeId() { return salaryGradeId; }
    public void setSalaryGradeId(int salaryGradeId) { this.salaryGradeId = salaryGradeId; }

    public String getGradeName() { return gradeName; }
    public void setGradeName(String gradeName) { this.gradeName = gradeName; }

    public BigDecimal getBaseSalary() { return baseSalary; }
    public void setBaseSalary(BigDecimal baseSalary) { this.baseSalary = baseSalary; }

    public BigDecimal getCoefficient() { return coefficient; }
    public void setCoefficient(BigDecimal coefficient) { this.coefficient = coefficient; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public boolean isStatus() { return status; }
    public void setStatus(boolean status) { this.status = status; }
}
