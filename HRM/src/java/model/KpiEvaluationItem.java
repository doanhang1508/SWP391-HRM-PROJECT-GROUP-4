package model;

public class KpiEvaluationItem {
    private int evaluationItemId;
    private int evaluationId;
    private int templateItemId;
    private double score;
    private String comment;

    // Helper fields populated from template_items
    private String criterionName;
    private String criterionDescription;
    private double weight;

    public KpiEvaluationItem() {}

    public KpiEvaluationItem(int evaluationItemId, int evaluationId, int templateItemId, double score, String comment) {
        this.evaluationItemId = evaluationItemId;
        this.evaluationId = evaluationId;
        this.templateItemId = templateItemId;
        this.score = score;
        this.comment = comment;
    }

    public int getEvaluationItemId() { return evaluationItemId; }
    public void setEvaluationItemId(int evaluationItemId) { this.evaluationItemId = evaluationItemId; }

    public int getEvaluationId() { return evaluationId; }
    public void setEvaluationId(int evaluationId) { this.evaluationId = evaluationId; }

    public int getTemplateItemId() { return templateItemId; }
    public void setTemplateItemId(int templateItemId) { this.templateItemId = templateItemId; }

    public double getScore() { return score; }
    public void setScore(double score) { this.score = score; }

    public String getComment() { return comment; }
    public void setComment(String comment) { this.comment = comment; }

    // Getter & setters for helpers
    public String getCriterionName() { return criterionName; }
    public void setCriterionName(String criterionName) { this.criterionName = criterionName; }

    public String getCriterionDescription() { return criterionDescription; }
    public void setCriterionDescription(String criterionDescription) { this.criterionDescription = criterionDescription; }

    public double getWeight() { return weight; }
    public void setWeight(double weight) { this.weight = weight; }
}
