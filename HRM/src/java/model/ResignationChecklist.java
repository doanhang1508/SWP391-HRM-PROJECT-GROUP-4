package model;

import java.sql.Timestamp;

public class ResignationChecklist {

    private int checklistId;
    private int resignationId;
    private String itemName;
    private boolean isCompleted;
    private Integer completedBy;
    private Timestamp completedAt;
    private String note;

    // Transient
    private String completedByName;

    public ResignationChecklist() {}

    public int getChecklistId() { return checklistId; }
    public void setChecklistId(int checklistId) { this.checklistId = checklistId; }

    public int getResignationId() { return resignationId; }
    public void setResignationId(int resignationId) { this.resignationId = resignationId; }

    public String getItemName() { return itemName; }
    public void setItemName(String itemName) { this.itemName = itemName; }

    public boolean isCompleted() { return isCompleted; }
    public void setCompleted(boolean isCompleted) { this.isCompleted = isCompleted; }

    public Integer getCompletedBy() { return completedBy; }
    public void setCompletedBy(Integer completedBy) { this.completedBy = completedBy; }

    public Timestamp getCompletedAt() { return completedAt; }
    public void setCompletedAt(Timestamp completedAt) { this.completedAt = completedAt; }

    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }

    public String getCompletedByName() { return completedByName; }
    public void setCompletedByName(String completedByName) { this.completedByName = completedByName; }
}
