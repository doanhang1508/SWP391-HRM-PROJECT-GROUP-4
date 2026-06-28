package model;

import java.sql.Timestamp;
import java.util.List;

public class KpiEvaluation {
    private int evaluationId;
    private int cycleId;
    private int employeeId;
    private int managerId;
    private double score;
    private double weightedScore;
    private String status; // 'DRAFT', 'SUBMITTED', 'APPROVED', 'REJECTED'
    private String comment;
    private Timestamp submittedAt;
    private Timestamp approvedAt;
    private Timestamp lockedAt;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private int createdBy;
    private int updatedBy;
    private List<KpiEvaluationItem> evaluationItems; // List of criteria items with scores


    // View helper properties (not stored directly in kpi_evaluations table, populated via JOINs)
    private String employeeName;
    private String employeeCode; // username or employee code
    private String managerName;
    private String cycleName;
    private String departmentName;

    public KpiEvaluation() {}

    public KpiEvaluation(int evaluationId, int cycleId, int employeeId, int managerId, double score, double weightedScore, String status, String comment, Timestamp submittedAt, Timestamp approvedAt, Timestamp lockedAt, Timestamp createdAt, Timestamp updatedAt, int createdBy, int updatedBy) {
        this.evaluationId = evaluationId;
        this.cycleId = cycleId;
        this.employeeId = employeeId;
        this.managerId = managerId;
        this.score = score;
        this.weightedScore = weightedScore;
        this.status = status;
        this.comment = comment;
        this.submittedAt = submittedAt;
        this.approvedAt = approvedAt;
        this.lockedAt = lockedAt;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
        this.createdBy = createdBy;
        this.updatedBy = updatedBy;
    }

    public int getEvaluationId() { return evaluationId; }
    public void setEvaluationId(int evaluationId) { this.evaluationId = evaluationId; }

    public int getCycleId() { return cycleId; }
    public void setCycleId(int cycleId) { this.cycleId = cycleId; }

    public int getEmployeeId() { return employeeId; }
    public void setEmployeeId(int employeeId) { this.employeeId = employeeId; }

    public int getManagerId() { return managerId; }
    public void setManagerId(int managerId) { this.managerId = managerId; }

    public double getScore() { return score; }
    public void setScore(double score) { this.score = score; }

    public double getWeightedScore() { return weightedScore; }
    public void setWeightedScore(double weightedScore) { this.weightedScore = weightedScore; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getComment() { return comment; }
    public void setComment(String comment) { this.comment = comment; }

    public Timestamp getSubmittedAt() { return submittedAt; }
    public void setSubmittedAt(Timestamp submittedAt) { this.submittedAt = submittedAt; }

    public Timestamp getApprovedAt() { return approvedAt; }
    public void setApprovedAt(Timestamp approvedAt) { this.approvedAt = approvedAt; }

    public Timestamp getLockedAt() { return lockedAt; }
    public void setLockedAt(Timestamp lockedAt) { this.lockedAt = lockedAt; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public int getCreatedBy() { return createdBy; }
    public void setCreatedBy(int createdBy) { this.createdBy = createdBy; }

    public int getUpdatedBy() { return updatedBy; }
    public void setUpdatedBy(int updatedBy) { this.updatedBy = updatedBy; }

    // Getters and setters for helper fields
    public String getEmployeeName() { return employeeName; }
    public void setEmployeeName(String employeeName) { this.employeeName = employeeName; }

    public String getEmployeeCode() { return employeeCode; }
    public void setEmployeeCode(String employeeCode) { this.employeeCode = employeeCode; }

    public String getManagerName() { return managerName; }
    public void setManagerName(String managerName) { this.managerName = managerName; }

    public String getCycleName() { return cycleName; }
    public void setCycleName(String cycleName) { this.cycleName = cycleName; }

    public String getDepartmentName() { return departmentName; }
    public void setDepartmentName(String departmentName) { this.departmentName = departmentName; }

    public List<KpiEvaluationItem> getEvaluationItems() { return evaluationItems; }
    public void setEvaluationItems(List<KpiEvaluationItem> evaluationItems) { this.evaluationItems = evaluationItems; }
}
