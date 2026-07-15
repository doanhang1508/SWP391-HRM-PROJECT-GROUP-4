package model;

import java.math.BigDecimal;

public class HolidayRule {
    private String ruleCode;
    private String ruleName;
    private String calendarType; // SOLAR or LUNAR
    private int refMonth;
    private int refDay;
    private int dayOffset;
    private BigDecimal otMultiplier;
    private boolean active;

    public HolidayRule() {
    }

    public HolidayRule(String ruleCode, String ruleName, String calendarType, int refMonth, int refDay, int dayOffset, BigDecimal otMultiplier, boolean active) {
        this.ruleCode = ruleCode;
        this.ruleName = ruleName;
        this.calendarType = calendarType;
        this.refMonth = refMonth;
        this.refDay = refDay;
        this.dayOffset = dayOffset;
        this.otMultiplier = otMultiplier;
        this.active = active;
    }

    public String getRuleCode() {
        return ruleCode;
    }

    public void setRuleCode(String ruleCode) {
        this.ruleCode = ruleCode;
    }

    public String getRuleName() {
        return ruleName;
    }

    public void setRuleName(String ruleName) {
        this.ruleName = ruleName;
    }

    public String getCalendarType() {
        return calendarType;
    }

    public void setCalendarType(String calendarType) {
        this.calendarType = calendarType;
    }

    public int getRefMonth() {
        return refMonth;
    }

    public void setRefMonth(int refMonth) {
        this.refMonth = refMonth;
    }

    public int getRefDay() {
        return refDay;
    }

    public void setRefDay(int refDay) {
        this.refDay = refDay;
    }

    public int getDayOffset() {
        return dayOffset;
    }

    public void setDayOffset(int dayOffset) {
        this.dayOffset = dayOffset;
    }

    public BigDecimal getOtMultiplier() {
        return otMultiplier;
    }

    public void setOtMultiplier(BigDecimal otMultiplier) {
        this.otMultiplier = otMultiplier;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }
}
