package model;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;

/**
 * Model cho bảng tax_brackets - Biểu thuế lũy tiến.
 * Hỗ trợ versioning theo effective_from/effective_to.
 */
public class TaxBracket {
    private int bracketId;
    private int bracketNo;
    private BigDecimal incomeFrom;
    private BigDecimal incomeTo;
    private BigDecimal rate;
    private Date effectiveFrom;
    private Date effectiveTo;
    private String roundingRule;
    private int status;
    private Integer createdBy;
    private Integer updatedBy;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public TaxBracket() {}

    // Getters & Setters
    public int getBracketId() { return bracketId; }
    public void setBracketId(int bracketId) { this.bracketId = bracketId; }

    public int getBracketNo() { return bracketNo; }
    public void setBracketNo(int bracketNo) { this.bracketNo = bracketNo; }

    public BigDecimal getIncomeFrom() { return incomeFrom; }
    public void setIncomeFrom(BigDecimal incomeFrom) { this.incomeFrom = incomeFrom; }

    public BigDecimal getIncomeTo() { return incomeTo; }
    public void setIncomeTo(BigDecimal incomeTo) { this.incomeTo = incomeTo; }

    public BigDecimal getRate() { return rate; }
    public void setRate(BigDecimal rate) { this.rate = rate; }

    public Date getEffectiveFrom() { return effectiveFrom; }
    public void setEffectiveFrom(Date effectiveFrom) { this.effectiveFrom = effectiveFrom; }

    public Date getEffectiveTo() { return effectiveTo; }
    public void setEffectiveTo(Date effectiveTo) { this.effectiveTo = effectiveTo; }

    public String getRoundingRule() { return roundingRule; }
    public void setRoundingRule(String roundingRule) { this.roundingRule = roundingRule; }

    public int getStatus() { return status; }
    public void setStatus(int status) { this.status = status; }

    public Integer getCreatedBy() { return createdBy; }
    public void setCreatedBy(Integer createdBy) { this.createdBy = createdBy; }

    public Integer getUpdatedBy() { return updatedBy; }
    public void setUpdatedBy(Integer updatedBy) { this.updatedBy = updatedBy; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
}
