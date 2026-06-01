package model;

public class RewardDiscipline {
    private int id;
    private String name;
    private String type;
    private String description;
    private int status;

    public RewardDiscipline() {}

    public RewardDiscipline(int id, String name, String type) {
        this.id = id;
        this.name = name;
        this.type = type;
    }

    public RewardDiscipline(int id, String name, String type, String description, int status) {
        this.id = id;
        this.name = name;
        this.type = type;
        this.description = description;
        this.status = status;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public int getStatus() { return status; }
    public void setStatus(int status) { this.status = status; }
}
