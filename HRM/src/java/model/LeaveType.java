package model;

public class LeaveType {
    private int leaveTypeId;
    private String typeName;
    private int paidLeave;
    private int status;

    public LeaveType() {}

    public LeaveType(int leaveTypeId, String typeName, int paidLeave, int status) {
        this.leaveTypeId = leaveTypeId;
        this.typeName = typeName;
        this.paidLeave = paidLeave;
        this.status = status;
    }

    public int getLeaveTypeId() { return leaveTypeId; }
    public void setLeaveTypeId(int leaveTypeId) { this.leaveTypeId = leaveTypeId; }

    public String getTypeName() { return typeName; }
    public void setTypeName(String typeName) { this.typeName = typeName; }

    public int getPaidLeave() { return paidLeave; }
    public void setPaidLeave(int paidLeave) { this.paidLeave = paidLeave; }

    public int getStatus() { return status; }
    public void setStatus(int status) { this.status = status; }
}