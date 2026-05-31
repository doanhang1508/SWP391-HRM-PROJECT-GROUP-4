package model;

public class LeaveType {
    private int leaveTypeId;
    private String typeName;
    private boolean paidLeave;
    private boolean status;

    public LeaveType() {
    }

    public LeaveType(int leaveTypeId, String typeName, boolean paidLeave, boolean status) {
        this.leaveTypeId = leaveTypeId;
        this.typeName = typeName;
        this.paidLeave = paidLeave;
        this.status = status;
    }

    public int getLeaveTypeId() {
        return leaveTypeId;
    }

    public void setLeaveTypeId(int leaveTypeId) {
        this.leaveTypeId = leaveTypeId;
    }

    public String getTypeName() {
        return typeName;
    }

    public void setTypeName(String typeName) {
        this.typeName = typeName;
    }

    public boolean isPaidLeave() {
        return paidLeave;
    }

    public void setPaidLeave(boolean paidLeave) {
        this.paidLeave = paidLeave;
    }

    public boolean isStatus() {
        return status;
    }

    public void setStatus(boolean status) {
        this.status = status;
    }
}
