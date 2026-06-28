package model;

public class KpiTemplateItem {
    private int itemId;
    private int templateId;
    private String criterionName;
    private String description;
    private double weight;

    public KpiTemplateItem() {}

    public KpiTemplateItem(int itemId, int templateId, String criterionName, String description, double weight) {
        this.itemId = itemId;
        this.templateId = templateId;
        this.criterionName = criterionName;
        this.description = description;
        this.weight = weight;
    }

    public int getItemId() { return itemId; }
    public void setItemId(int itemId) { this.itemId = itemId; }

    public int getTemplateId() { return templateId; }
    public void setTemplateId(int templateId) { this.templateId = templateId; }

    public String getCriterionName() { return criterionName; }
    public void setCriterionName(String criterionName) { this.criterionName = criterionName; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public double getWeight() { return weight; }
    public void setWeight(double weight) { this.weight = weight; }
}
