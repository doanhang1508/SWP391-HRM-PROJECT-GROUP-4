package model;

public class EducationLevel {
    private int educationLevelId;
    private String levelName;
    private String description;
    private boolean status;

    public EducationLevel() {}

    public EducationLevel(int educationLevelId, String levelName, String description, boolean status) {
        this.educationLevelId = educationLevelId;
        this.levelName = levelName;
        this.description = description;
        this.status = status;
    }

    public int getEducationLevelId() { return educationLevelId; }
    public void setEducationLevelId(int educationLevelId) { this.educationLevelId = educationLevelId; }

    public String getLevelName() { return levelName; }
    public void setLevelName(String levelName) { this.levelName = levelName; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public boolean isStatus() { return status; }
    public void setStatus(boolean status) { this.status = status; }
}
