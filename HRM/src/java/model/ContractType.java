package model;

public class ContractType {
    private int contractTypeId;
    private String typeName;
    private String description;
    private boolean status;

    public ContractType() {}

    public ContractType(int contractTypeId, String typeName, String description, boolean status) {
        this.contractTypeId = contractTypeId;
        this.typeName = typeName;
        this.description = description;
        this.status = status;
    }

    public int getContractTypeId() { return contractTypeId; }
    public void setContractTypeId(int contractTypeId) { this.contractTypeId = contractTypeId; }

    public String getTypeName() { return typeName; }
    public void setTypeName(String typeName) { this.typeName = typeName; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public boolean isStatus() { return status; }
    public void setStatus(boolean status) { this.status = status; }
}
