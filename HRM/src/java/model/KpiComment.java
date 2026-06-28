package model;

import java.sql.Timestamp;

public class KpiComment {
    private int commentId;
    private int evaluationId;
    private int userId;
    private String commentText;
    private String type; // 'MANAGER', 'EMPLOYEE', 'REVIEWER'
    private Timestamp createdAt;

    // Helper
    private String userName;

    public KpiComment() {}

    public KpiComment(int commentId, int evaluationId, int userId, String commentText, String type, Timestamp createdAt) {
        this.commentId = commentId;
        this.evaluationId = evaluationId;
        this.userId = userId;
        this.commentText = commentText;
        this.type = type;
        this.createdAt = createdAt;
    }

    public int getCommentId() { return commentId; }
    public void setCommentId(int commentId) { this.commentId = commentId; }

    public int getEvaluationId() { return evaluationId; }
    public void setEvaluationId(int evaluationId) { this.evaluationId = evaluationId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getCommentText() { return commentText; }
    public void setCommentText(String commentText) { this.commentText = commentText; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }
}
