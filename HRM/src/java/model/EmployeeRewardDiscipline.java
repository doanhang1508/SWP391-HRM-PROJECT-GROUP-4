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

    /**
     * Kiểm tra dữ liệu khen thưởng/kỷ luật hợp lệ.
     * Thuần Java, không cần Database.
     */
    public static String validate(EmployeeRewardDiscipline r) {
        if (r == null) return "Record không được null";
        if (r.getUserId() <= 0)
            return "UserId phải lớn hơn 0";
        if (r.getRewardDisciplineId() <= 0)
            return "Loại khen thưởng/kỷ luật phải hợp lệ (> 0)";
        if (r.getAmount() == null)
            return "Số tiền không được null";
        if (r.getAmount().compareTo(java.math.BigDecimal.ZERO) < 0)
            return "Số tiền không được âm";
        if (r.getNote() == null || r.getNote().trim().isEmpty())
            return "Ghi chú không được để trống";
        if (r.getAppliedDate() == null)
            return "Ngày áp dụng không được để trống";
        return null; // null = hợp lệ
    }
}
