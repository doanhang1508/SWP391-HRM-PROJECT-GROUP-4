package model;

import java.sql.Timestamp;

public class KpiStatusHistory {
    private int historyId;
    private int evaluationId;
    private String fromStatus;
    private String toStatus;
    private int changedBy;
    private Timestamp changedAt;
    private String note;

    // Helper
    private String changedByName;

    public KpiStatusHistory() {}

    public KpiStatusHistory(int historyId, int evaluationId, String fromStatus, String toStatus, int changedBy, Timestamp changedAt, String note) {
        this.historyId = historyId;
        this.evaluationId = evaluationId;
        this.fromStatus = fromStatus;
        this.toStatus = toStatus;
        this.changedBy = changedBy;
        this.changedAt = changedAt;
        this.note = note;
    }

    public int getHistoryId() { return historyId; }
    public void setHistoryId(int historyId) { this.historyId = historyId; }

    public int getEvaluationId() { return evaluationId; }
    public void setEvaluationId(int evaluationId) { this.evaluationId = evaluationId; }

    public String getFromStatus() { return fromStatus; }
    public void setFromStatus(String fromStatus) { this.fromStatus = fromStatus; }

    public String getToStatus() { return toStatus; }
    public void setToStatus(String toStatus) { this.toStatus = toStatus; }

    public int getChangedBy() { return changedBy; }
    public void setChangedBy(int changedBy) { this.changedBy = changedBy; }

    public Timestamp getChangedAt() { return changedAt; }
    public void setChangedAt(Timestamp changedAt) { this.changedAt = changedAt; }

    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }

    public String getChangedByName() { return changedByName; }
    public void setChangedByName(String changedByName) { this.changedByName = changedByName; }
}
