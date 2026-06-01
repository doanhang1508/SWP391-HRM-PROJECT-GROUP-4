package model;

public class LeaveType {
    private int leaveTypeId;
    private String typeName;
    private String description;
    private int paidLeave;
    private Integer maxDaysPerYear;
    private int status;

    public LeaveType() {}

    public LeaveType(int leaveTypeId, String typeName, String description, int paidLeave, Integer maxDaysPerYear, int status) {
        this.leaveTypeId = leaveTypeId;
        this.typeName = typeName;
        this.description = description;
        this.paidLeave = paidLeave;
        this.maxDaysPerYear = maxDaysPerYear;
        this.status = status;
    }

    public int getLeaveTypeId() { return leaveTypeId; }
    public void setLeaveTypeId(int leaveTypeId) { this.leaveTypeId = leaveTypeId; }

    public String getTypeName() { return typeName; }
    public void setTypeName(String typeName) { this.typeName = typeName; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public int getPaidLeave() { return paidLeave; }
    public void setPaidLeave(int paidLeave) { this.paidLeave = paidLeave; }

    public Integer getMaxDaysPerYear() { return maxDaysPerYear; }
    public void setMaxDaysPerYear(Integer maxDaysPerYear) { this.maxDaysPerYear = maxDaysPerYear; }

    public int getStatus() { return status; }
    public void setStatus(int status) { this.status = status; }
}