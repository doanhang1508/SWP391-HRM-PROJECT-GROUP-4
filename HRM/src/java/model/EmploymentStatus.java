package model;

public class EmploymentStatus {
    private int statusId;
    private String statusName;
    private String description;
    private boolean status;

    public EmploymentStatus() {}

    public EmploymentStatus(int statusId, String statusName, String description, boolean status) {
        this.statusId = statusId;
        this.statusName = statusName;
        this.description = description;
        this.status = status;
    }

    public int getStatusId() { return statusId; }
    public void setStatusId(int statusId) { this.statusId = statusId; }

    public String getStatusName() { return statusName; }
    public void setStatusName(String statusName) { this.statusName = statusName; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public boolean isStatus() { return status; }
    public void setStatus(boolean status) { this.status = status; }
}
