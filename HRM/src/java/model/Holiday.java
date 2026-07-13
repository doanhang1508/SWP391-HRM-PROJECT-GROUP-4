package model;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;

public class Holiday {
    private int holidayId;
    private String holidayName;
    private Date holidayDate;
    private String calendarType; // SOLAR or LUNAR
    private BigDecimal otMultiplier;
    private String description;
    private boolean status;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public Holiday() {
    }

    // Constructor without timestamps (for insert/update)
    public Holiday(int holidayId, String holidayName, Date holidayDate, String calendarType, BigDecimal otMultiplier, String description, boolean status) {
        this.holidayId = holidayId;
        this.holidayName = holidayName;
        this.holidayDate = holidayDate;
        this.calendarType = calendarType;
        this.otMultiplier = otMultiplier;
        this.description = description;
        this.status = status;
    }

    // Constructor with all fields
    public Holiday(int holidayId, String holidayName, Date holidayDate, String calendarType, BigDecimal otMultiplier, String description, boolean status, Timestamp createdAt, Timestamp updatedAt) {
        this.holidayId = holidayId;
        this.holidayName = holidayName;
        this.holidayDate = holidayDate;
        this.calendarType = calendarType;
        this.otMultiplier = otMultiplier;
        this.description = description;
        this.status = status;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public int getHolidayId() {
        return holidayId;
    }

    public void setHolidayId(int holidayId) {
        this.holidayId = holidayId;
    }

    public String getHolidayName() {
        return holidayName;
    }

    public void setHolidayName(String holidayName) {
        this.holidayName = holidayName;
    }

    public Date getHolidayDate() {
        return holidayDate;
    }

    public void setHolidayDate(Date holidayDate) {
        this.holidayDate = holidayDate;
    }

    public String getCalendarType() {
        return calendarType;
    }

    public void setCalendarType(String calendarType) {
        this.calendarType = calendarType;
    }

    public BigDecimal getOtMultiplier() {
        return otMultiplier;
    }

    public void setOtMultiplier(BigDecimal otMultiplier) {
        this.otMultiplier = otMultiplier;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public boolean isStatus() {
        return status;
    }

    public void setStatus(boolean status) {
        this.status = status;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }
}
