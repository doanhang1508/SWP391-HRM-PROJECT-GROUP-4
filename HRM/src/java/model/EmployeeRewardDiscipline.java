package model;

import java.math.BigDecimal;
import java.sql.Date;

public class EmployeeRewardDiscipline {
    private int id;
    private int userId;
    private int rewardDisciplineId;
    private BigDecimal amount;
    private String note;
    private Date appliedDate;

    // Additional fields for display
    private String rewardDisciplineName;
    private String type;

    public EmployeeRewardDiscipline() {}

    public EmployeeRewardDiscipline(int id, int userId, int rewardDisciplineId, BigDecimal amount, String note, Date appliedDate) {
        this.id = id;
        this.userId = userId;
        this.rewardDisciplineId = rewardDisciplineId;
        this.amount = amount;
        this.note = note;
        this.appliedDate = appliedDate;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public int getRewardDisciplineId() { return rewardDisciplineId; }
    public void setRewardDisciplineId(int rewardDisciplineId) { this.rewardDisciplineId = rewardDisciplineId; }
    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }
    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }
    public Date getAppliedDate() { return appliedDate; }
    public void setAppliedDate(Date appliedDate) { this.appliedDate = appliedDate; }

    public String getRewardDisciplineName() { return rewardDisciplineName; }
    public void setRewardDisciplineName(String rewardDisciplineName) { this.rewardDisciplineName = rewardDisciplineName; }
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
}
