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
}
