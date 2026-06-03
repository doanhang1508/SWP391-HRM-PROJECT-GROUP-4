package model;

import java.sql.Timestamp;

public class ContractType {
    private int contractTypeId;
    private String typeName;
    private String description;
    private Integer duration; // Can be null
    private String durationUnit; // Can be null
    private boolean status;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public ContractType() {}

    // Constructor for compatibility
    public ContractType(int contractTypeId, String typeName, String description, boolean status) {
        this.contractTypeId = contractTypeId;
        this.typeName = typeName;
        this.description = description;
        this.status = status;
    }

    // Constructor with all fields
    public ContractType(int contractTypeId, String typeName, String description, Integer duration, String durationUnit, boolean status, Timestamp createdAt, Timestamp updatedAt) {
        this.contractTypeId = contractTypeId;
        this.typeName = typeName;
        this.description = description;
        this.duration = duration;
        this.durationUnit = durationUnit;
        this.status = status;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public int getContractTypeId() { return contractTypeId; }
    public void setContractTypeId(int contractTypeId) { this.contractTypeId = contractTypeId; }

    public String getTypeName() { return typeName; }
    public void setTypeName(String typeName) { this.typeName = typeName; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Integer getDuration() { return duration; }
    public void setDuration(Integer duration) { this.duration = duration; }

    public String getDurationUnit() { return durationUnit; }
    public void setDurationUnit(String durationUnit) { this.durationUnit = durationUnit; }

    public boolean isStatus() { return status; }
    public void setStatus(boolean status) { this.status = status; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
}
