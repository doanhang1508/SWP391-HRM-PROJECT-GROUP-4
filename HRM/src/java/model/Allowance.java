package model;

import java.math.BigDecimal;

public class Allowance {
    private int allowanceId;
    private String allowanceName;
    private String description;
    private BigDecimal amount;       // Mức tiền phụ cấp
    private String applyCondition;   // Điều kiện hưởng
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

    public boolean isStatus() { return status; }
    public void setStatus(boolean status) { this.status = status; }
}
