package model;

public class AttendanceSummary {
    private int userId;
    private String userName;
    private String department;
    private int presentCount;
    private int lateCount;
    private int absentCount;
    private int overtimeCount;
    private double totalOvertimeHrs;
    private double scheduledOvertimeHrs;
    private int sickDayCount;

    // New fields for Time & Leave Report and updated Attendance Management
    private int standardWorkDays;
    private double actualWorkDays;
    private double regularOtHrs;
    private double sundayOtHrs;
    private double holidayOtHrs;
    private double annualLeaveDays;
    private double sickLeaveDays;
    private double maternityLeaveDays;
    private double remainingAnnualLeave;

    public AttendanceSummary() {
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getDepartment() {
        return department;
    }

    public void setDepartment(String department) {
        this.department = department;
    }

    public int getPresentCount() {
        return presentCount;
    }

    public void setPresentCount(int presentCount) {
        this.presentCount = presentCount;
    }

    public int getLateCount() {
        return lateCount;
    }

    public void setLateCount(int lateCount) {
        this.lateCount = lateCount;
    }

    public int getAbsentCount() {
        return absentCount;
    }

    public void setAbsentCount(int absentCount) {
        this.absentCount = absentCount;
    }

    public int getOvertimeCount() {
        return overtimeCount;
    }

    public void setOvertimeCount(int overtimeCount) {
        this.overtimeCount = overtimeCount;
    }

    public double getTotalOvertimeHrs() {
        return totalOvertimeHrs;
    }

    public void setTotalOvertimeHrs(double totalOvertimeHrs) {
        this.totalOvertimeHrs = totalOvertimeHrs;
    }

    public double getScheduledOvertimeHrs() {
        return scheduledOvertimeHrs;
    }

    public void setScheduledOvertimeHrs(double scheduledOvertimeHrs) {
        this.scheduledOvertimeHrs = scheduledOvertimeHrs;
    }

    public int getSickDayCount() {
        return sickDayCount;
    }

    public void setSickDayCount(int sickDayCount) {
        this.sickDayCount = sickDayCount;
    }

    public int getStandardWorkDays() {
        return standardWorkDays;
    }

    public void setStandardWorkDays(int standardWorkDays) {
        this.standardWorkDays = standardWorkDays;
    }

    public double getActualWorkDays() {
        return actualWorkDays;
    }

    public void setActualWorkDays(double actualWorkDays) {
        this.actualWorkDays = actualWorkDays;
    }

    public double getRegularOtHrs() {
        return regularOtHrs;
    }

    public void setRegularOtHrs(double regularOtHrs) {
        this.regularOtHrs = regularOtHrs;
    }

    public double getSundayOtHrs() {
        return sundayOtHrs;
    }

    public void setSundayOtHrs(double sundayOtHrs) {
        this.sundayOtHrs = sundayOtHrs;
    }

    public double getHolidayOtHrs() {
        return holidayOtHrs;
    }

    public void setHolidayOtHrs(double holidayOtHrs) {
        this.holidayOtHrs = holidayOtHrs;
    }

    public double getAnnualLeaveDays() {
        return annualLeaveDays;
    }

    public void setAnnualLeaveDays(double annualLeaveDays) {
        this.annualLeaveDays = annualLeaveDays;
    }

    public double getSickLeaveDays() {
        return sickLeaveDays;
    }

    public void setSickLeaveDays(double sickLeaveDays) {
        this.sickLeaveDays = sickLeaveDays;
    }

    public double getMaternityLeaveDays() {
        return maternityLeaveDays;
    }

    public void setMaternityLeaveDays(double maternityLeaveDays) {
        this.maternityLeaveDays = maternityLeaveDays;
    }

    public double getRemainingAnnualLeave() {
        return remainingAnnualLeave;
    }

    public void setRemainingAnnualLeave(double remainingAnnualLeave) {
        this.remainingAnnualLeave = remainingAnnualLeave;
    }
}

