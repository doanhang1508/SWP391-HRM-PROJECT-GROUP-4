package model;

import java.sql.Timestamp;

public class ExitInterview {

    private int exitInterviewId;
    private int resignationId;
    private String reasonCategory;
    private String comment;
    private Timestamp createdAt;

    public ExitInterview() {}

    public int getExitInterviewId() { return exitInterviewId; }
    public void setExitInterviewId(int exitInterviewId) { this.exitInterviewId = exitInterviewId; }

    public int getResignationId() { return resignationId; }
    public void setResignationId(int resignationId) { this.resignationId = resignationId; }

    public String getReasonCategory() { return reasonCategory; }
    public void setReasonCategory(String reasonCategory) { this.reasonCategory = reasonCategory; }

    public String getComment() { return comment; }
    public void setComment(String comment) { this.comment = comment; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
