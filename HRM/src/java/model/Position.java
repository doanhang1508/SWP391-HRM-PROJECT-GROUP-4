package model;

public class Position {
    private int positionId;
    private String positionName;
    private String description;
    private boolean status;

    public Position() {}

    public Position(int positionId, String positionName, String description, boolean status) {
        this.positionId = positionId;
        this.positionName = positionName;
        this.description = description;
        this.status = status;
    }

    public int getPositionId() { return positionId; }
    public void setPositionId(int positionId) { this.positionId = positionId; }

    public String getPositionName() { return positionName; }
    public void setPositionName(String positionName) { this.positionName = positionName; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public boolean isStatus() { return status; }
    public void setStatus(boolean status) { this.status = status; }
}
