package dao;
import java.sql.Date;
import model.Shift;
import java.time.LocalTime;
import java.time.temporal.ChronoUnit;
import java.time.LocalDate;
import java.math.BigDecimal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.EmployeeRewardDiscipline;
import model.RewardDiscipline;
import model.Attendance;
import util.DBContext;

public class RewardDisciplineDAO {

    // ================================================================
    // CATEGORY CRUD OPERATIONS
    // ================================================================

    /**
     * Get all active reward/discipline categories.
     */
    public List<RewardDiscipline> getAllRewardDisciplines() {
        List<RewardDiscipline> list = new ArrayList<>();
        String sql = "SELECT rd.*, u.full_name AS creator_name "
                + "FROM reward_disciplines rd "
                + "LEFT JOIN users u ON rd.created_by = u.user_id "
                + "ORDER BY rd.id";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Search categories by keyword (name or description) and filter by type.
     */
    public List<RewardDiscipline> searchCategories(String keyword, String typeFilter) {
        List<RewardDiscipline> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT rd.*, u.full_name AS creator_name "
                + "FROM reward_disciplines rd "
                + "LEFT JOIN users u ON rd.created_by = u.user_id "
                + "WHERE 1=1 ");

        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (rd.name LIKE ? OR rd.description LIKE ?) ");
            String like = "%" + keyword.trim() + "%";
            params.add(like);
            params.add(like);
        }

        if (typeFilter != null && !typeFilter.trim().isEmpty()
                && !"all".equalsIgnoreCase(typeFilter.trim())) {
            sql.append("AND rd.type = ? ");
            params.add(typeFilter.trim());
        }

        sql.append("ORDER BY rd.id");

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Get a single category by ID (with creator info).
     */
    public RewardDiscipline getById(int id) {
        String sql = "SELECT rd.*, u.full_name AS creator_name "
                + "FROM reward_disciplines rd "
                + "LEFT JOIN users u ON rd.created_by = u.user_id "
                + "WHERE rd.id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Insert a new category.
     */
    public boolean insertCategory(RewardDiscipline rd) {
        String sql = "INSERT INTO reward_disciplines (name, type, description, apply_level, created_by) "
                + "VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, rd.getName());
            ps.setString(2, rd.getType());
            ps.setString(3, rd.getDescription());
            ps.setString(4, rd.getApplyLevel());
            if (rd.getCreatedBy() > 0) {
                ps.setInt(5, rd.getCreatedBy());
            } else {
                ps.setNull(5, java.sql.Types.INTEGER);
            }
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Update an existing category.
     */
    public boolean updateCategory(RewardDiscipline rd) {
        String sql = "UPDATE reward_disciplines SET name = ?, type = ?, description = ?, apply_level = ? "
                + "WHERE id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, rd.getName());
            ps.setString(2, rd.getType());
            ps.setString(3, rd.getDescription());
            ps.setString(4, rd.getApplyLevel());
            ps.setInt(5, rd.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Delete a category permanently.
     */
    public boolean deleteCategory(int id) {
        String sql = "DELETE FROM reward_disciplines WHERE id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Check if a category name already exists (for duplicate prevention).
     */
    public boolean isNameExists(String name, Integer excludeId) {
        String sql = "SELECT 1 FROM reward_disciplines WHERE LOWER(name) = LOWER(?)";
        if (excludeId != null && excludeId > 0) {
            sql += " AND id <> ?";
        }
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name);
            if (excludeId != null && excludeId > 0) {
                ps.setInt(2, excludeId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ================================================================
    // EMPLOYEE REWARD/DISCIPLINE OPERATIONS (existing - preserved)
    // ================================================================

    public boolean insertManualRecord(EmployeeRewardDiscipline record) {
        String sql = "INSERT INTO employee_rewards_disciplines (user_id, reward_discipline_id, amount, note, applied_date) VALUES (?, ?, ?, ?, ?)";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, record.getUserId());
            ps.setInt(2, record.getRewardDisciplineId());
            ps.setBigDecimal(3, record.getAmount());
            ps.setString(4, record.getNote());
            ps.setDate(5, record.getAppliedDate());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Lỗi lưu bản ghi Thưởng/Phạt: " + e.getMessage(), e);
        }
    }

    public List<EmployeeRewardDiscipline> getRecordsByUserIdAndMonthYear(int userId, int month, int year) {
        List<EmployeeRewardDiscipline> list = new ArrayList<>();
        // SELECT thêm is_bhxh_applied và is_taxable từ bảng reward_disciplines
        // để PayrollDAO biết kể này có tính vào nền BHXH / chịu thuế hay không
        String sql = "SELECT erd.*, rd.name as rd_name, rd.type as rd_type, "
                + "rd.is_bhxh_applied as rd_bhxh, rd.is_taxable as rd_taxable "
                + "FROM employee_rewards_disciplines erd "
                + "JOIN reward_disciplines rd ON erd.reward_discipline_id = rd.id "
                + "WHERE erd.user_id = ? AND MONTH(erd.applied_date) = ? AND YEAR(erd.applied_date) = ?";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, month);
            ps.setInt(3, year);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    EmployeeRewardDiscipline erd = new EmployeeRewardDiscipline();
                    erd.setId(rs.getInt("id"));
                    erd.setUserId(rs.getInt("user_id"));
                    erd.setRewardDisciplineId(rs.getInt("reward_discipline_id"));
                    erd.setAmount(rs.getBigDecimal("amount"));
                    erd.setNote(rs.getString("note"));
                    erd.setAppliedDate(rs.getDate("applied_date"));
                    erd.setRewardDisciplineName(rs.getString("rd_name"));
                    erd.setType(rs.getString("rd_type"));
                    // Đọc 2 cột mới — backward-compatible: nếu migration chưa chạy thì giữ default
                    try {
                        erd.setBhxhApplied(rs.getInt("rd_bhxh") == 1);
                    } catch (SQLException ignored) { /* cột chưa tồn tại, giữ default = false */ }
                    try {
                        erd.setTaxable(rs.getInt("rd_taxable") == 1);
                    } catch (SQLException ignored) { /* cột chưa tồn tại, giữ default = true */ }
                    list.add(erd);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public RewardDiscipline getRewardDisciplineByName(String name) {
        String sql = "SELECT * FROM reward_disciplines WHERE name = ?";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    RewardDiscipline rd = new RewardDiscipline();
                    rd.setId(rs.getInt("id"));
                    rd.setName(rs.getString("name"));
                    rd.setType(rs.getString("type"));
                    rd.setDescription(rs.getString("description"));
                    rd.setStatus(rs.getInt("status"));
                    return rd;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Attendance> getAttendanceByUserIdAndMonth(int userId, int month, int year) {
        List<Attendance> list = new ArrayList<>();
        String sql = "SELECT * FROM attendance WHERE user_id = ? AND MONTH(work_date) = ? AND YEAR(work_date) = ?";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, month);
            ps.setInt(3, year);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Attendance a = new Attendance();
                    a.setAttendanceId(rs.getInt("attendance_id"));
                    a.setUserId(rs.getInt("user_id"));
                    a.setShiftId(rs.getInt("shift_id"));
                    a.setWorkDate(rs.getDate("work_date"));
                    a.setCheckIn(rs.getTime("check_in"));
                    a.setCheckOut(rs.getTime("check_out"));
                    a.setStatus(rs.getString("status"));
                    list.add(a);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Lỗi lấy dữ liệu chấm công: " + e.getMessage(), e);
        }
        return list;
    }

    public int getWarningCountInLast3Months(int userId, java.time.LocalDate currentDate) {
        String sql = "SELECT COUNT(*) FROM employee_rewards_disciplines erd "
                + "JOIN reward_disciplines rd ON erd.reward_discipline_id = rd.id "
                + "WHERE erd.user_id = ? AND rd.name = 'Warning' "
                + "AND erd.applied_date BETWEEN ? AND ?";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setDate(2, java.sql.Date.valueOf(currentDate.minusMonths(3)));
            ps.setDate(3, java.sql.Date.valueOf(currentDate));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ================================================================
    // PRIVATE HELPERS
    // ================================================================

    private RewardDiscipline mapRow(ResultSet rs) throws SQLException {
        RewardDiscipline rd = new RewardDiscipline();
        rd.setId(rs.getInt("id"));
        rd.setName(rs.getString("name"));
        rd.setType(rs.getString("type"));
        rd.setDescription(rs.getString("description"));
        rd.setStatus(rs.getInt("status"));
        // New columns — read safely in case migration hasn't been run
        try {
            rd.setApplyLevel(rs.getString("apply_level"));
        } catch (SQLException ignored) {}
        try {
            rd.setCreatedAt(rs.getTimestamp("created_at"));
        } catch (SQLException ignored) {}
        try {
            rd.setCreatedBy(rs.getInt("created_by"));
        } catch (SQLException ignored) {}
        try {
            rd.setCreatedByName(rs.getString("creator_name"));
        } catch (SQLException ignored) {}
        // Payroll tax/insurance flags — backward-compatible
        try {
            rd.setBhxhApplied(rs.getInt("is_bhxh_applied") == 1);
        } catch (SQLException ignored) { /* cột chưa tồn tại, giữ default = false */ }
        try {
            rd.setTaxable(rs.getInt("is_taxable") == 1);
        } catch (SQLException ignored) { /* cột chưa tồn tại, giữ default = true */ }
        return rd;
    }

    // --- Merged from Service ---


    

    public int generateAttendanceAutomations(int userId, int month, int year) {
        List<Attendance> attendances = this.getAttendanceByUserIdAndMonth(userId, month, year);
        int lateCount = 0;
        int validPresentDays = 0;
        int insertedCount = 0;
        
        for (Attendance a : attendances) {
            if ("Present".equalsIgnoreCase(a.getStatus())) {
                ShiftDAO shiftDAO = new ShiftDAOImpl();
                Shift s = shiftDAO.getShiftById(a.getShiftId());
                if (s != null && a.getCheckIn() != null) {
                    LocalTime checkIn = a.getCheckIn().toLocalTime();
                    LocalTime shiftStart = s.getStartTime();
                    
                    // Grace period of 5 minutes
                    LocalTime allowedTime = shiftStart.plusMinutes(5);
                    if (checkIn.isAfter(allowedTime)) {
                        lateCount++;
                        long lateMinutes = ChronoUnit.MINUTES.between(shiftStart, checkIn);
                        BigDecimal deductionAmount = new BigDecimal(lateMinutes * 5000);
                        
                        RewardDiscipline rdLate = this.getRewardDisciplineByName("Đi muộn/Về sớm");
                        
                        EmployeeRewardDiscipline erd = new EmployeeRewardDiscipline();
                        erd.setUserId(userId);
                        erd.setRewardDisciplineId(rdLate != null ? rdLate.getId() : 4);
                        erd.setAmount(deductionAmount);
                        erd.setNote("Late for " + lateMinutes + " minutes");
                        erd.setAppliedDate(a.getWorkDate());
                        if (this.insertManualRecord(erd)) {
                            insertedCount++;
                        }
                    } else {
                        validPresentDays++;
                    }
                } else if (a.getCheckIn() != null) {
                    validPresentDays++;
                }
            }
        }
        
        if (lateCount > 3) {
             RewardDiscipline rdPenalty = this.getRewardDisciplineByName("Đi muộn/Về sớm");
             EmployeeRewardDiscipline erd = new EmployeeRewardDiscipline();
             erd.setUserId(userId);
             erd.setRewardDisciplineId(rdPenalty != null ? rdPenalty.getId() : 4);
             erd.setAmount(new BigDecimal(200000));
             erd.setNote("Late more than 3 times in month");
             erd.setAppliedDate(Date.valueOf(LocalDate.of(year, month, 28)));
             if (this.insertManualRecord(erd)) {
                 insertedCount++;
             }
        }
        
        // Perfect attendance bonus
        if (validPresentDays >= 26 && lateCount == 0) {
            RewardDiscipline rdBonus = this.getRewardDisciplineByName("Thưởng Chuyên cần");
            EmployeeRewardDiscipline erd2 = new EmployeeRewardDiscipline();
            erd2.setUserId(userId);
            erd2.setRewardDisciplineId(rdBonus != null ? rdBonus.getId() : 3);
            erd2.setAmount(new BigDecimal(500000));
            erd2.setNote("Perfect attendance for month " + month);
            erd2.setAppliedDate(Date.valueOf(LocalDate.of(year, month, 28)));
            if (this.insertManualRecord(erd2)) {
                insertedCount++;
            }
        }
        return insertedCount;
    }

    public void calculateKPIBonus(int userId, int month, int year, BigDecimal baseSalary, double kpiScore) {
        BigDecimal maxBonus = baseSalary.multiply(new BigDecimal("0.30"));
        BigDecimal actualBonus = maxBonus.multiply(new BigDecimal(kpiScore));
        
        RewardDiscipline rdKpi = this.getRewardDisciplineByName("Thưởng KPI Tháng");
        EmployeeRewardDiscipline erd = new EmployeeRewardDiscipline();
        erd.setUserId(userId);
        erd.setRewardDisciplineId(rdKpi != null ? rdKpi.getId() : 1);
        erd.setAmount(actualBonus);
        
        double pct = kpiScore * 100;
        String formattedPct;
        if (pct == (long) pct) {
            formattedPct = String.format("%d", (long) pct);
        } else {
            formattedPct = String.format(java.util.Locale.US, "%.1f", pct);
            if (formattedPct.endsWith(".0")) {
                formattedPct = formattedPct.substring(0, formattedPct.length() - 2);
            }
        }
        erd.setNote("KPI Score: " + formattedPct + "%");
        
        erd.setAppliedDate(Date.valueOf(LocalDate.of(year, month, 28)));
        this.insertManualRecord(erd);
    }

    

    public void issueWarning(int userId, String reason, java.time.LocalDate date) {
        RewardDiscipline rdWarning = this.getRewardDisciplineByName("Vi phạm kỷ luật khác");
        int warningTypeId = (rdWarning != null) ? rdWarning.getId() : 5;

        EmployeeRewardDiscipline warningRecord = new EmployeeRewardDiscipline();
        warningRecord.setUserId(userId);
        warningRecord.setRewardDisciplineId(warningTypeId);
        warningRecord.setAmount(BigDecimal.ZERO);
        warningRecord.setNote("Warning: " + reason);
        warningRecord.setAppliedDate(Date.valueOf(date));

        this.insertManualRecord(warningRecord);

        // Auto-Escalation Logic
        int warningCount = this.getWarningCountInLast3Months(userId, date);
        if (warningCount >= 3) {
            dao.PayrollDAO payrollDAO = new dao.PayrollDAO();
            dao.PayrollDAO.EmployeeSalaryInfo info = payrollDAO.getEmployeeSalaryInfo(userId);
            if (info != null && info.baseSalary != null) {
                BigDecimal deduction = info.baseSalary.multiply(new BigDecimal("0.05")); // 5% deduction
                
                RewardDiscipline rdPenalty = this.getRewardDisciplineByName("Đi muộn/Về sớm");
                int penaltyTypeId = (rdPenalty != null) ? rdPenalty.getId() : 4;
                
                EmployeeRewardDiscipline penaltyRecord = new EmployeeRewardDiscipline();
                penaltyRecord.setUserId(userId);
                penaltyRecord.setRewardDisciplineId(penaltyTypeId);
                penaltyRecord.setAmount(deduction);
                penaltyRecord.setNote("Auto-escalation: 3+ warnings in 3 months");
                penaltyRecord.setAppliedDate(Date.valueOf(date));
                
                this.insertManualRecord(penaltyRecord);
            }
        }
    }

}



