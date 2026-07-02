package model;

public class PositionAllowance {
    private int id;
    private int positionId;
    private int allowanceId;

    public PositionAllowance() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getPositionId() { return positionId; }
    public void setPositionId(int positionId) { this.positionId = positionId; }

    public int getAllowanceId() { return allowanceId; }
    public void setAllowanceId(int allowanceId) { this.allowanceId = allowanceId; }
}
