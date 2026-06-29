package model;

import java.sql.Date;
import java.sql.Timestamp;

public class KpiCycle {
    private int cycleId;
    private String name;
    private Date startDate;
    private Date endDate;
    private Date deadline;
    private int templateId;
    private String status; // 'DRAFT', 'ACTIVE', 'SUBMITTED', 'APPROVED', 'LOCKED'
    private Timestamp createdAt;
    private int createdBy;
    private Timestamp updatedAt;

    // Helper field populated via JOIN — not a DB column
    private String templateName;

    public KpiCycle() {}

    public KpiCycle(int cycleId, String name, Date startDate, Date endDate, Date deadline, int templateId, String status, Timestamp createdAt, int createdBy, Timestamp updatedAt) {
        this.cycleId = cycleId;
        this.name = name;
        this.startDate = startDate;
        this.endDate = endDate;
        this.deadline = deadline;
        this.templateId = templateId;
        this.status = status;
        this.createdAt = createdAt;
        this.createdBy = createdBy;
        this.updatedAt = updatedAt;
    }

    public int getCycleId() { return cycleId; }
    public void setCycleId(int cycleId) { this.cycleId = cycleId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public Date getStartDate() { return startDate; }
    public void setStartDate(Date startDate) { this.startDate = startDate; }

    public Date getEndDate() { return endDate; }
    public void setEndDate(Date endDate) { this.endDate = endDate; }

    public Date getDeadline() { return deadline; }
    public void setDeadline(Date deadline) { this.deadline = deadline; }

    public int getTemplateId() { return templateId; }
    public void setTemplateId(int templateId) { this.templateId = templateId; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public int getCreatedBy() { return createdBy; }
    public void setCreatedBy(int createdBy) { this.createdBy = createdBy; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public String getTemplateName() { return templateName; }
    public void setTemplateName(String templateName) { this.templateName = templateName; }

    /** Alias for {@link #getDeadline()} — used by kpi-cycles.jsp via EL ${cycle.evaluationDeadline} */
    public java.sql.Date getEvaluationDeadline() { return deadline; }
    public void setEvaluationDeadline(java.sql.Date evaluationDeadline) { this.deadline = evaluationDeadline; }
}
