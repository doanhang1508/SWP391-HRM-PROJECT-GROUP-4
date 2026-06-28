package model;

import java.sql.Timestamp;

public class KpiAuditLog {
    private int auditId;
    private int evaluationId;
    private int changedBy;
    private Timestamp changedAt;
    private String action;
    private String oldValue;
    private String newValue;

    // Helper
    private String changedByName;

    public KpiAuditLog() {}

    public KpiAuditLog(int auditId, int evaluationId, int changedBy, Timestamp changedAt, String action, String oldValue, String newValue) {
        this.auditId = auditId;
        this.evaluationId = evaluationId;
        this.changedBy = changedBy;
        this.changedAt = changedAt;
        this.action = action;
        this.oldValue = oldValue;
        this.newValue = newValue;
    }

    public int getAuditId() { return auditId; }
    public void setAuditId(int auditId) { this.auditId = auditId; }

    public int getEvaluationId() { return evaluationId; }
    public void setEvaluationId(int evaluationId) { this.evaluationId = evaluationId; }

    public int getChangedBy() { return changedBy; }
    public void setChangedBy(int changedBy) { this.changedBy = changedBy; }

    public Timestamp getChangedAt() { return changedAt; }
    public void setChangedAt(Timestamp changedAt) { this.changedAt = changedAt; }

    public String getAction() { return action; }
    public void setAction(String action) { this.action = action; }

    public String getOldValue() { return oldValue; }
    public void setOldValue(String oldValue) { this.oldValue = oldValue; }

    public String getNewValue() { return newValue; }
    public void setNewValue(String newValue) { this.newValue = newValue; }

    public String getChangedByName() { return changedByName; }
    public void setChangedByName(String changedByName) { this.changedByName = changedByName; }
}
