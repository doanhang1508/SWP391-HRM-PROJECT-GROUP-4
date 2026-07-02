package model;

import java.math.BigDecimal;

public class SeniorityRule {
    private int ruleId;
    private int minMonths;
    private Integer maxMonths; // can be null
    private BigDecimal amount;

    public SeniorityRule() {}

    public int getRuleId() { return ruleId; }
    public void setRuleId(int ruleId) { this.ruleId = ruleId; }

    public int getMinMonths() { return minMonths; }
    public void setMinMonths(int minMonths) { this.minMonths = minMonths; }

    public Integer getMaxMonths() { return maxMonths; }
    public void setMaxMonths(Integer maxMonths) { this.maxMonths = maxMonths; }

    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }
}
