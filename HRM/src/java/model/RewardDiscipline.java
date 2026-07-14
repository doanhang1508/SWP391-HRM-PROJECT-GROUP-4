package model;

import java.sql.Timestamp;

public class RewardDiscipline {
    private int id;
    private String name;
    private String type;
    private String description;
    private String applyLevel;
    private int status;
    private Timestamp createdAt;
    private int createdBy;

    // Display-only field (joined from users table)
    private String createdByName;

    // Payroll tax/insurance flags
    // is_bhxh_applied: true = kỏ này cộng vào nền tính BHXH/BHYT/BHTN
    private boolean bhxhApplied = false;
    // is_taxable: true = chịu thuế TNCN (default true = chịu thuế bình thường)
    private boolean taxable = true;

    public RewardDiscipline() {}

    public RewardDiscipline(int id, String name, String type) {
        this.id = id;
        this.name = name;
        this.type = type;
    }

    public RewardDiscipline(int id, String name, String type, String description, int status) {
        this.id = id;
        this.name = name;
        this.type = type;
        this.description = description;
        this.status = status;
    }

    public RewardDiscipline(int id, String name, String type, String description,
                            String applyLevel, int status, Timestamp createdAt,
                            int createdBy, String createdByName) {
        this.id = id;
        this.name = name;
        this.type = type;
        this.description = description;
        this.applyLevel = applyLevel;
        this.status = status;
        this.createdAt = createdAt;
        this.createdBy = createdBy;
        this.createdByName = createdByName;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getApplyLevel() { return applyLevel; }
    public void setApplyLevel(String applyLevel) { this.applyLevel = applyLevel; }
    public int getStatus() { return status; }
    public void setStatus(int status) { this.status = status; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    public int getCreatedBy() { return createdBy; }
    public void setCreatedBy(int createdBy) { this.createdBy = createdBy; }
    public String getCreatedByName() { return createdByName; }
    public void setCreatedByName(String createdByName) { this.createdByName = createdByName; }

    public boolean isBhxhApplied() { return bhxhApplied; }
    public void setBhxhApplied(boolean bhxhApplied) { this.bhxhApplied = bhxhApplied; }

    public boolean isTaxable() { return taxable; }
    public void setTaxable(boolean taxable) { this.taxable = taxable; }
}
