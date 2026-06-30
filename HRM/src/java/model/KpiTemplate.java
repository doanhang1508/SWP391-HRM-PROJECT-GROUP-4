package model;

import java.sql.Timestamp;

public class KpiTemplate {
    private int templateId;
    private String name;
    private String description;
    private int status;
    private Timestamp createdAt;
    private int createdBy;
    private Integer departmentId; // Nullable
    private String departmentName; // Non-DB helper field

    public KpiTemplate() {}

    public KpiTemplate(int templateId, String name, String description, int status, Timestamp createdAt, int createdBy) {
        this.templateId = templateId;
        this.name = name;
        this.description = description;
        this.status = status;
        this.createdAt = createdAt;
        this.createdBy = createdBy;
    }

    public KpiTemplate(int templateId, String name, String description, int status, Timestamp createdAt, int createdBy, Integer departmentId) {
        this.templateId = templateId;
        this.name = name;
        this.description = description;
        this.status = status;
        this.createdAt = createdAt;
        this.createdBy = createdBy;
        this.departmentId = departmentId;
    }

    public int getTemplateId() { return templateId; }
    public void setTemplateId(int templateId) { this.templateId = templateId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public int getStatus() { return status; }
    public void setStatus(int status) { this.status = status; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public int getCreatedBy() { return createdBy; }
    public void setCreatedBy(int createdBy) { this.createdBy = createdBy; }

    public Integer getDepartmentId() { return departmentId; }
    public void setDepartmentId(Integer departmentId) { this.departmentId = departmentId; }

    public String getDepartmentName() { return departmentName; }
    public void setDepartmentName(String departmentName) { this.departmentName = departmentName; }
}
