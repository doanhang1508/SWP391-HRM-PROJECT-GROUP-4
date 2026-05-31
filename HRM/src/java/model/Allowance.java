package model;

public class Allowance {
    private int allowanceId;
    private String allowanceName;
    private String description;
    private boolean status;

    public Allowance() {}

    public Allowance(int allowanceId, String allowanceName, String description, boolean status) {
        this.allowanceId   = allowanceId;
        this.allowanceName = allowanceName;
        this.description   = description;
        this.status        = status;
    }

    public int getAllowanceId() { return allowanceId; }
    public void setAllowanceId(int allowanceId) { this.allowanceId = allowanceId; }

    public String getAllowanceName() { return allowanceName; }
    public void setAllowanceName(String allowanceName) { this.allowanceName = allowanceName; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public boolean isStatus() { return status; }
    public void setStatus(boolean status) { this.status = status; }
}
