package model;

import java.math.BigDecimal;

public class Allowance {
    private int allowanceId;
    private String allowanceName;
    private String description;
    private BigDecimal amount;       // Mức tiền phụ cấp
    private String applyCondition;   // Điều kiện hưởng
    private String calculationType;  // FIXED, PER_DAY, CONDITIONAL
    private boolean isBhxhApplied;   // Có đóng BHXH không
    private boolean isTaxable;       // Có chịu thuế không
    private boolean status;

    public Allowance() {}

    public Allowance(int allowanceId, String allowanceName, String description,
                     BigDecimal amount, String applyCondition, boolean status) {
        this.allowanceId     = allowanceId;
        this.allowanceName   = allowanceName;
        this.description     = description;
        this.amount          = amount;
        this.applyCondition  = applyCondition;
        this.status          = status;
        this.calculationType = "FIXED"; // default
        this.isBhxhApplied   = false;
        this.isTaxable       = false;
    }

    public Allowance(int allowanceId, String allowanceName, String description,
                     BigDecimal amount, String applyCondition, 
                     String calculationType, boolean isBhxhApplied, boolean isTaxable, 
                     boolean status) {
        this.allowanceId     = allowanceId;
        this.allowanceName   = allowanceName;
        this.description     = description;
        this.amount          = amount;
        this.applyCondition  = applyCondition;
        this.calculationType = calculationType;
        this.isBhxhApplied   = isBhxhApplied;
        this.isTaxable       = isTaxable;
        this.status          = status;
    }

    // Getters & Setters
    public int getAllowanceId() { return allowanceId; }
    public void setAllowanceId(int allowanceId) { this.allowanceId = allowanceId; }

    public String getAllowanceName() { return allowanceName; }
    public void setAllowanceName(String allowanceName) { this.allowanceName = allowanceName; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }

    public String getApplyCondition() { return applyCondition; }
    public void setApplyCondition(String applyCondition) { this.applyCondition = applyCondition; }

    public String getCalculationType() { return calculationType; }
    public void setCalculationType(String calculationType) { this.calculationType = calculationType; }

    public boolean isBhxhApplied() { return isBhxhApplied; }
    public void setBhxhApplied(boolean bhxhApplied) { isBhxhApplied = bhxhApplied; }

    public boolean isTaxable() { return isTaxable; }
    public void setTaxable(boolean taxable) { isTaxable = taxable; }

    public boolean isStatus() { return status; }
    public void setStatus(boolean status) { this.status = status; }
}
