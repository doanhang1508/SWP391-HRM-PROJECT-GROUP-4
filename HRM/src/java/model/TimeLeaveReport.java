package model;

public class TimeLeaveReport {
    private int userId;
    private String fullName;
    private String departmentName;
    private int totalWorkDays;
    private int lateCount;
    private double otHours;
    private double annualLeaveUsed;
    private double annualLeaveRemaining;

    public TimeLeaveReport() {
    }

    public TimeLeaveReport(int userId, String fullName, String departmentName, int totalWorkDays, int lateCount, double otHours, double annualLeaveUsed, double annualLeaveRemaining) {
        this.userId = userId;
        this.fullName = fullName;
        this.departmentName = departmentName;
        this.totalWorkDays = totalWorkDays;
        this.lateCount = lateCount;
        this.otHours = otHours;
        this.annualLeaveUsed = annualLeaveUsed;
        this.annualLeaveRemaining = annualLeaveRemaining;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getDepartmentName() {
        return departmentName;
    }

    public void setDepartmentName(String departmentName) {
        this.departmentName = departmentName;
    }

    public int getTotalWorkDays() {
        return totalWorkDays;
    }

    public void setTotalWorkDays(int totalWorkDays) {
        this.totalWorkDays = totalWorkDays;
    }

    public int getLateCount() {
        return lateCount;
    }

    public void setLateCount(int lateCount) {
        this.lateCount = lateCount;
    }

    public double getOtHours() {
        return otHours;
    }

    public void setOtHours(double otHours) {
        this.otHours = otHours;
    }

    public double getAnnualLeaveUsed() {
        return annualLeaveUsed;
    }

    public void setAnnualLeaveUsed(double annualLeaveUsed) {
        this.annualLeaveUsed = annualLeaveUsed;
    }

    public double getAnnualLeaveRemaining() {
        return annualLeaveRemaining;
    }

    public void setAnnualLeaveRemaining(double annualLeaveRemaining) {
        this.annualLeaveRemaining = annualLeaveRemaining;
    }
}
