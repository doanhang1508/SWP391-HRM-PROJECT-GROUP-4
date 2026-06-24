package model;

import java.math.BigDecimal;
import java.sql.Date;

public class TaxBracket {
    private int bracketId;
    private int bracketNo;
    private BigDecimal incomeFrom;
    private BigDecimal incomeTo;
    private BigDecimal rate;
    private Date effectiveFrom;
    private Date effectiveTo;
    private String roundingRule;
    private boolean status;
    private int createdBy;
    private int updatedBy;

    public TaxBracket() {
    }

    public int getBracketId() {
        return bracketId;
    }

    public void setBracketId(int bracketId) {
        this.bracketId = bracketId;
    }

    public int getBracketNo() {
        return bracketNo;
    }

    public void setBracketNo(int bracketNo) {
        this.bracketNo = bracketNo;
    }

    public BigDecimal getIncomeFrom() {
        return incomeFrom;
    }

    public void setIncomeFrom(BigDecimal incomeFrom) {
        this.incomeFrom = incomeFrom;
    }

    public BigDecimal getIncomeTo() {
        return incomeTo;
    }

    public void setIncomeTo(BigDecimal incomeTo) {
        this.incomeTo = incomeTo;
    }

    public BigDecimal getRate() {
        return rate;
    }

    public void setRate(BigDecimal rate) {
        this.rate = rate;
    }

    public Date getEffectiveFrom() {
        return effectiveFrom;
    }

    public void setEffectiveFrom(Date effectiveFrom) {
        this.effectiveFrom = effectiveFrom;
    }

    public Date getEffectiveTo() {
        return effectiveTo;
    }

    public void setEffectiveTo(Date effectiveTo) {
        this.effectiveTo = effectiveTo;
    }

    public String getRoundingRule() {
        return roundingRule;
    }

    public void setRoundingRule(String roundingRule) {
        this.roundingRule = roundingRule;
    }

    public boolean isStatus() {
        return status;
    }

    public void setStatus(boolean status) {
        this.status = status;
    }

    public int getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(int createdBy) {
        this.createdBy = createdBy;
    }

    public int getUpdatedBy() {
        return updatedBy;
    }

    public void setUpdatedBy(int updatedBy) {
        this.updatedBy = updatedBy;
    }
}
