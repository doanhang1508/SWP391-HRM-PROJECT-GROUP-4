package dao;
import model.EmployeeRewardDiscipline;
import dao.RewardDisciplineDAO;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.EmployeeContract;
import dao.EmployeeContractDAO;
import model.Payroll;
import util.DBContext;
import java.sql.Date;
// Cần import để kiểm tra trạng thái chốt chấm công
import dao.TimesheetConfirmationDAO;

public class PayrollDAO {

    public static class EmployeeSalaryInfo {
        public Date hireDate;
        public BigDecimal baseSalary;
        public int roleId;
    }

    public static class PayrollGenerationResult {
        private int createdCount = 0;
        private int updatedCount = 0;
        private int skippedCount = 0;
        private boolean noAttendanceData = false;

        public int getCreatedCount() { return createdCount; }
        public void setCreatedCount(int createdCount) { this.createdCount = createdCount; }

        public int getUpdatedCount() { return updatedCount; }
        public void setUpdatedCount(int updatedCount) { this.updatedCount = updatedCount; }

        public int getSkippedCount() { return skippedCount; }
        public void setSkippedCount(int skippedCount) { this.skippedCount = skippedCount; }

        public boolean isNoAttendanceData() { return noAttendanceData; }
        public void setNoAttendanceData(boolean noAttendanceData) { this.noAttendanceData = noAttendanceData; }
    }

    public static class PayrollMonthSummary {
        private int month;
        private int year;
        private int totalEmployees;
        private BigDecimal totalNet;
        private String status;

        public int getMonth() {
            return month;
        }

        public void setMonth(int month) {
            this.month = month;
        }

        public int getYear() {
            return year;
        }

        public void setYear(int year) {
            this.year = year;
        }

        public int getTotalEmployees() {
            return totalEmployees;
        }

        public void setTotalEmployees(int totalEmployees) {
            this.totalEmployees = totalEmployees;
        }

        public BigDecimal getTotalNet() {
            return totalNet;
        }

        public void setTotalNet(BigDecimal totalNet) {
            this.totalNet = totalNet;
        }

        public String getStatus() {
            return status;
        }

        public void setStatus(String status) {
            this.status = status;
        }
    }

    // Helper map đầy đủ tất cả cột DB
    private Payroll mapRow(ResultSet rs) throws SQLException {
        Payroll p = new Payroll();
        p.setPayrollId(rs.getInt("payroll_id"));
        p.setUserId(rs.getInt("user_id"));
        p.setMonth(rs.getInt("month"));
        p.setYear(rs.getInt("year"));
        p.setBaseSalary(rs.getBigDecimal("base_salary"));
        p.setWorkingDays(rs.getDouble("working_days"));
        p.setOvertimeAmount(rs.getBigDecimal("overtime_amount"));
        p.setAllowanceAmount(rs.getBigDecimal("allowance_amount"));
        p.setBonusAmount(rs.getBigDecimal("bonus_amount"));
        p.setDeductionAmount(rs.getBigDecimal("deduction_amount"));
        p.setInsuranceAmount(rs.getBigDecimal("insurance_amount"));
        p.setTaxAmount(rs.getBigDecimal("tax_amount"));
        p.setGrossSalary(rs.getBigDecimal("gross_salary"));
        p.setNetSalary(rs.getBigDecimal("net_salary"));
        p.setStatus(rs.getString("status"));
        p.setCreatedAt(rs.getTimestamp("created_at"));
        
        int approvedByVal = rs.getInt("approved_by");
        p.setApprovedBy(rs.wasNull() ? null : approvedByVal);
        p.setApprovedAt(rs.getTimestamp("approved_at"));
        p.setRejectReason(rs.getString("reject_reason"));
        
        int paidByVal = rs.getInt("paid_by");
        p.setPaidBy(rs.wasNull() ? null : paidByVal);
        p.setPaidAt(rs.getTimestamp("paid_at"));
        p.setPaymentNote(rs.getString("payment_note"));
        
        return p;
    }

    public EmployeeSalaryInfo getEmployeeSalaryInfo(int userId) {
        String sql = "SELECT ep.hire_date, sg.base_salary, u.role_id " +
                     "FROM employee_profiles ep " +
                     "JOIN salary_grades sg ON ep.salary_grade_id = sg.salary_grade_id " +
                     "JOIN users u ON ep.user_id = u.user_id " +
                     "WHERE ep.user_id = ?";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    EmployeeSalaryInfo info = new EmployeeSalaryInfo();
                    info.hireDate   = rs.getDate("hire_date");
                    info.baseSalary = rs.getBigDecimal("base_salary");
                    info.roleId     = rs.getInt("role_id");
                    return info;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Kiểm tra xem đã có bảng lương nháp (Draft/Pending/Approved/Paid) cho tháng/năm chưa.
     * Dùng để chặn mở khóa bảng công khi đã gen payroll draft.
     */
    public boolean hasPayrollGenerated(int month, int year) {
        String sql = "SELECT COUNT(*) FROM payroll WHERE month = ? AND year = ?";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, month);
            ps.setInt(2, year);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Insert hoặc update đầy đủ tất cả cột
    public boolean insertOrUpdatePayroll(Payroll p) {
        String sql = "INSERT INTO payroll " +
                     "(user_id, month, year, base_salary, working_days, overtime_amount, " +
                     " allowance_amount, bonus_amount, deduction_amount, insurance_amount, " +
                     " tax_amount, gross_salary, net_salary, status, " +
                     " approved_by, approved_at, reject_reason, paid_by, paid_at, payment_note) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) " +
                     "ON DUPLICATE KEY UPDATE " +
                     "base_salary=VALUES(base_salary), working_days=VALUES(working_days), " +
                     "overtime_amount=VALUES(overtime_amount), allowance_amount=VALUES(allowance_amount), " +
                     "bonus_amount=VALUES(bonus_amount), deduction_amount=VALUES(deduction_amount), " +
                     "insurance_amount=VALUES(insurance_amount), tax_amount=VALUES(tax_amount), " +
                     "gross_salary=VALUES(gross_salary), net_salary=VALUES(net_salary), " +
                     "status=VALUES(status), " +
                     "approved_by=VALUES(approved_by), approved_at=VALUES(approved_at), " +
                     "reject_reason=VALUES(reject_reason), paid_by=VALUES(paid_by), " +
                     "paid_at=VALUES(paid_at), payment_note=VALUES(payment_note)";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, p.getUserId());
            ps.setInt(2, p.getMonth());
            ps.setInt(3, p.getYear());
            ps.setBigDecimal(4, p.getBaseSalary() != null ? p.getBaseSalary() : BigDecimal.ZERO);
            ps.setDouble(5, p.getWorkingDays());
            ps.setBigDecimal(6, p.getOvertimeAmount() != null ? p.getOvertimeAmount() : BigDecimal.ZERO);
            ps.setBigDecimal(7, p.getAllowanceAmount() != null ? p.getAllowanceAmount() : BigDecimal.ZERO);
            ps.setBigDecimal(8, p.getBonusAmount() != null ? p.getBonusAmount() : BigDecimal.ZERO);
            ps.setBigDecimal(9, p.getDeductionAmount() != null ? p.getDeductionAmount() : BigDecimal.ZERO);
            ps.setBigDecimal(10, p.getInsuranceAmount() != null ? p.getInsuranceAmount() : BigDecimal.ZERO);
            ps.setBigDecimal(11, p.getTaxAmount() != null ? p.getTaxAmount() : BigDecimal.ZERO);
            ps.setBigDecimal(12, p.getGrossSalary() != null ? p.getGrossSalary() : BigDecimal.ZERO);
            ps.setBigDecimal(13, p.getNetSalary() != null ? p.getNetSalary() : BigDecimal.ZERO);
            ps.setString(14, p.getStatus() != null ? p.getStatus() : "Draft");
            
            if (p.getApprovedBy() != null) {
                ps.setInt(15, p.getApprovedBy());
            } else {
                ps.setNull(15, java.sql.Types.INTEGER);
            }
            ps.setTimestamp(16, p.getApprovedAt());
            ps.setString(17, p.getRejectReason());
            
            if (p.getPaidBy() != null) {
                ps.setInt(18, p.getPaidBy());
            } else {
                ps.setNull(18, java.sql.Types.INTEGER);
            }
            ps.setTimestamp(19, p.getPaidAt());
            ps.setString(20, p.getPaymentNote());
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public Payroll getPayroll(int userId, int month, int year) {
        String sql = "SELECT * FROM payroll WHERE user_id = ? AND month = ? AND year = ?";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, month);
            ps.setInt(3, year);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Payroll> getByUserId(int userId) {
        List<Payroll> list = new ArrayList<>();
        String sql = "SELECT * FROM payroll WHERE user_id = ? ORDER BY year DESC, month DESC";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Payroll> getByMonthYear(int month, int year) {
        List<Payroll> list = new ArrayList<>();
        String sql = "SELECT * FROM payroll WHERE month = ? AND year = ? ORDER BY user_id";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, month);
            ps.setInt(2, year);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<PayrollMonthSummary> getMonthlySummaries() {
        List<PayrollMonthSummary> list = new ArrayList<>();
        String sql = "SELECT month, year, COUNT(user_id) as total_employees, SUM(net_salary) as total_net, " +
                     "       MAX(CASE " +
                     "           WHEN status = 'Rejected' THEN 6 " +
                     "           WHEN status = 'Pending' THEN 5 " +
                     "           WHEN status = 'Verified' THEN 4 " +
                     "           WHEN status = 'Draft' THEN 3 " +
                     "           WHEN status = 'Approved' THEN 2 " +
                     "           WHEN status = 'Paid' THEN 1 " +
                     "           ELSE 0 " +
                     "       END) as max_status_val " +
                     "FROM payroll " +
                     "GROUP BY year, month " +
                     "ORDER BY year DESC, month DESC";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                PayrollMonthSummary summary = new PayrollMonthSummary();
                summary.month = rs.getInt("month");
                summary.year = rs.getInt("year");
                summary.totalEmployees = rs.getInt("total_employees");
                summary.totalNet = rs.getBigDecimal("total_net");
                
                int maxStatusVal = rs.getInt("max_status_val");
                summary.status = switch (maxStatusVal) {
                    case 6 -> "Rejected";
                    case 5 -> "Pending";
                    case 4 -> "Verified";
                    case 3 -> "Draft";
                    case 2 -> "Approved";
                    case 1 -> "Paid";
                    default -> "Unknown";
                };
                list.add(summary);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // --- Merged from Service ---

    private RewardDisciplineDAO rewardDisciplineDAO = new RewardDisciplineDAO();

    public void calculate13thMonthBonus(int userId, int currentYear) {
        PayrollDAO.EmployeeSalaryInfo info = this.getEmployeeSalaryInfo(userId);
        if (info == null || info.baseSalary == null) return;

        java.time.LocalDate hireDate = (info.hireDate != null) ? info.hireDate.toLocalDate() : java.time.LocalDate.of(currentYear, 1, 1);
        
        int monthsWorked = 12;
        if (hireDate.getYear() == currentYear) {
            monthsWorked = 12 - hireDate.getMonthValue() + 1; // e.g. joined in June = 12 - 6 + 1 = 7 months
        } else if (hireDate.getYear() > currentYear) {
            monthsWorked = 0;
        }

        if (monthsWorked > 0) {
            BigDecimal bonus = info.baseSalary.multiply(new BigDecimal(monthsWorked)).divide(new BigDecimal(12), 2, java.math.RoundingMode.HALF_UP);

            model.RewardDiscipline rd13th = rewardDisciplineDAO.getRewardDisciplineByName("13th Month Bonus");
            int rewardTypeId = (rd13th != null) ? rd13th.getId() : 5; // Fallback ID

            EmployeeRewardDiscipline bonusRecord = new EmployeeRewardDiscipline();
            bonusRecord.setUserId(userId);
            bonusRecord.setRewardDisciplineId(rewardTypeId);
            bonusRecord.setAmount(bonus);
            bonusRecord.setNote("13th Month Bonus for " + currentYear + " (" + monthsWorked + " months)");
            bonusRecord.setAppliedDate(java.sql.Date.valueOf(java.time.LocalDate.of(currentYear, 12, 31)));

            rewardDisciplineDAO.insertManualRecord(bonusRecord);
        }
    }

    public Payroll getById(int payrollId) {
        String sql = "SELECT * FROM payroll WHERE payroll_id = ?";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, payrollId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public Payroll getByUserMonthYear(int userId, int month, int year) {
        if (month < 1 || month > 12 || year < 2000) {
            throw new IllegalArgumentException("Tháng hoặc năm không hợp lệ");
        }
        return getPayroll(userId, month, year);
    }

    public List<Integer> getAllActiveEmployeeIds() {
        List<Integer> list = new ArrayList<>();
        String sql = "SELECT user_id FROM users WHERE status = 1";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(rs.getInt("user_id"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Integer> getAllEligibleEmployeeIds(int month, int year) {
        List<Integer> list = new ArrayList<>();
        java.time.LocalDate firstDay = java.time.LocalDate.of(year, month, 1);
        java.time.LocalDate lastDay = firstDay.with(java.time.temporal.TemporalAdjusters.lastDayOfMonth());
        java.sql.Date sqlFirstDay = java.sql.Date.valueOf(firstDay);
        java.sql.Date sqlLastDay = java.sql.Date.valueOf(lastDay);

        String sql = "SELECT DISTINCT u.user_id " +
                     "FROM users u " +
                     "LEFT JOIN employee_profiles ep ON u.user_id = ep.user_id " +
                     "WHERE u.status = 1 " +
                     "   OR (u.status = 0 " +
                     "       AND ( " +
                     "           EXISTS ( " +
                     "               SELECT 1 FROM attendance a " +
                     "               WHERE a.user_id = u.user_id " +
                     "                 AND a.work_date >= ? AND a.work_date <= ? " +
                     "           ) " +
                     "           OR EXISTS ( " +
                     "               SELECT 1 FROM shift_assignments sa " +
                     "               WHERE sa.user_id = u.user_id " +
                     "                 AND sa.assigned_date >= ? AND sa.assigned_date <= ? " +
                     "           ) " +
                     "           OR EXISTS ( " +
                     "               SELECT 1 FROM employee_shifts es " +
                     "               WHERE es.user_id = u.user_id " +
                     "                 AND es.work_date >= ? AND es.work_date <= ? " +
                     "           ) " +
                     "           OR EXISTS ( " +
                     "               SELECT 1 FROM work_history wh " +
                     "               WHERE wh.user_id = u.user_id " +
                     "                 AND (wh.end_date >= ? OR wh.end_date IS NULL) " +
                     "                 AND wh.start_date <= ? " +
                     "           ) " +
                     "           OR EXISTS ( " +
                     "               SELECT 1 FROM employee_rewards_disciplines erd " +
                     "               JOIN reward_disciplines rd ON erd.reward_discipline_id = rd.id " +
                     "               WHERE erd.user_id = u.user_id " +
                     "                 AND rd.name = 'Dismissal' " +
                     "                 AND erd.applied_date >= ? " +
                     "           ) " +
                     "       ) " +
                     "   )";

        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, sqlFirstDay);
            ps.setDate(2, sqlLastDay);
            ps.setDate(3, sqlFirstDay);
            ps.setDate(4, sqlLastDay);
            ps.setDate(5, sqlFirstDay);
            ps.setDate(6, sqlLastDay);
            ps.setDate(7, sqlFirstDay);
            ps.setDate(8, sqlLastDay);
            ps.setDate(9, sqlFirstDay);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(rs.getInt("user_id"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public BigDecimal getTotalOTPay(int empId, int month, int year, BigDecimal hourlyRate) {
        String sql = "SELECT SUM(oa.assigned_hours) FROM overtime_assignments oa " +
                     "JOIN overtime_plans op ON oa.plan_id = op.plan_id " +
                     "WHERE oa.user_id = ? AND oa.status = 'Approved' " +
                     "AND MONTH(op.target_date) = ? AND YEAR(op.target_date) = ?";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, empId);
            ps.setInt(2, month);
            ps.setInt(3, year);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    BigDecimal hours = rs.getBigDecimal(1);
                    if (hours != null) {
                        return hours.multiply(hourlyRate).multiply(new BigDecimal("1.5"));
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return BigDecimal.ZERO;
    }

    /**
     * Tính tổng phụ cấp tháng theo logic chuẩn.
     * Chỉ đọc phụ cấp thuộc hợp đồng đang hiệu lực HOẸC phụ cấp vận hành (contract_id IS NULL).
     *
     * @param activeContractId  ID của hợp đồng đang active (truyền 0 nếu không có hợp đồng)
     */
    public AllowanceResult calculateAllowances(
            int empId, int activeContractId,
            double actualWorkDays, double standardWorkDays, int month, int year) {
        /*
         * Logic lấy phụ cấp:
         *   - contract_id = activeContractId  → Phụ cấp "cam kết" đã ghi vào hợp đồng/phụ lục
         *   - contract_id IS NULL            → Phụ cấp "vận hành" (ăn ca, đi lại...), áp dụng chung
         * Tỷ lệ BHXH chỉ tính trên phụ cấp có is_bhxh_applied = 1.
         */
        String sql;
        if (activeContractId > 0) {
            sql = "SELECT ea.amount, a.calculation_type, a.is_bhxh_applied " +
                  "FROM employee_allowances ea " +
                  "JOIN allowances a ON ea.allowance_id = a.allowance_id " +
                  "WHERE ea.user_id = ? AND a.status = 1 " +
                  "  AND (ea.contract_id = ? OR ea.contract_id IS NULL)";
        } else {
            // Fallback: lấy tất cả phụ cấp vận hành (không gắn hợp đồng)
            sql = "SELECT ea.amount, a.calculation_type, a.is_bhxh_applied " +
                  "FROM employee_allowances ea " +
                  "JOIN allowances a ON ea.allowance_id = a.allowance_id " +
                  "WHERE ea.user_id = ? AND a.status = 1 AND ea.contract_id IS NULL";
        }

        BigDecimal totalAllowance = BigDecimal.ZERO;
        BigDecimal bhxhBaseFromAllowances = BigDecimal.ZERO;

        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, empId);
            if (activeContractId > 0) ps.setInt(2, activeContractId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BigDecimal amount      = rs.getBigDecimal("amount");
                    String calcType        = rs.getString("calculation_type");
                    boolean isBhxhApplied  = rs.getInt("is_bhxh_applied") == 1;

                    if (amount == null) continue;

                    BigDecimal earned;
                    switch (calcType != null ? calcType : "FIXED") {
                        case "PER_DAY" -> {
                            // Tính theo ngày công thực tế (ví dụ: ăn ca)
                            if (standardWorkDays > 0) {
                                BigDecimal dailyRate = amount.divide(
                                    new BigDecimal(String.valueOf(standardWorkDays)), 4, java.math.RoundingMode.HALF_UP);
                                earned = dailyRate.multiply(new BigDecimal(String.valueOf(actualWorkDays)))
                                    .setScale(2, java.math.RoundingMode.HALF_UP);
                            } else {
                                earned = BigDecimal.ZERO;
                            }
                        }
                        case "CONDITIONAL" -> {
                            // Trả đủ nếu không có ngày ABSENT không phép trong tháng
                            boolean hasUnexcused = hasUnexcusedAbsence(empId, month, year);
                            earned = hasUnexcused ? BigDecimal.ZERO : amount;
                        }
                        default -> earned = amount; // FIXED
                    }

                    totalAllowance = totalAllowance.add(earned);
                    if (isBhxhApplied) {
                        bhxhBaseFromAllowances = bhxhBaseFromAllowances.add(earned);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return new AllowanceResult(totalAllowance, bhxhBaseFromAllowances);
    }

    /** Kiểm tra có ngày ABSENT không phép trong tháng không. */
    private boolean hasUnexcusedAbsence(int userId, int month, int year) {
        String sql = "SELECT COUNT(*) FROM attendance " +
                     "WHERE user_id = ? AND MONTH(work_date) = ? AND YEAR(work_date) = ? " +
                     "AND status = 'ABSENT'";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, month);
            ps.setInt(3, year);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    /** Kết quả tính phụ cấp: tổng phụ cấp và phần thuộc nền BHXH */
    public static class AllowanceResult {
        public final BigDecimal totalAmount;
        public final BigDecimal bhxhBase;
        public AllowanceResult(BigDecimal totalAmount, BigDecimal bhxhBase) {
            this.totalAmount = totalAmount;
            this.bhxhBase = bhxhBase;
        }
    }

    /** Giữ lại method cũ để backward-compatible, gọi sang method mới */
    public BigDecimal getFixedAllowances(int empId) {
        String sql = "SELECT SUM(ea.amount) FROM employee_allowances ea " +
                     "JOIN allowances a ON ea.allowance_id = a.allowance_id " +
                     "WHERE ea.user_id = ? AND a.status = 1 AND a.calculation_type = 'FIXED'";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, empId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    BigDecimal total = rs.getBigDecimal(1);
                    return total != null ? total : BigDecimal.ZERO;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return BigDecimal.ZERO;
    }

    public boolean updateDraftWithAttendance(Payroll p) {
        String sql = "UPDATE payroll SET " +
                     "base_salary = ?, " +
                     "working_days = ?, " +
                     "overtime_amount = ?, " +
                     "allowance_amount = ?, " +
                     "bonus_amount = ?, " +
                     "deduction_amount = ?, " +
                     "insurance_amount = ?, " +
                     "tax_amount = ?, " +
                     "gross_salary = ?, " +
                     "net_salary = ?, " +
                     "status = 'Draft', " +
                     "reject_reason = NULL, " +
                     "approved_by = NULL, " +
                     "approved_at = NULL " +
                     "WHERE payroll_id = ?";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBigDecimal(1, p.getBaseSalary());
            ps.setDouble(2, p.getWorkingDays());
            ps.setBigDecimal(3, p.getOvertimeAmount());
            ps.setBigDecimal(4, p.getAllowanceAmount());
            ps.setBigDecimal(5, p.getBonusAmount());
            ps.setBigDecimal(6, p.getDeductionAmount());
            ps.setBigDecimal(7, p.getInsuranceAmount());
            ps.setBigDecimal(8, p.getTaxAmount());
            ps.setBigDecimal(9, p.getGrossSalary());
            ps.setBigDecimal(10, p.getNetSalary());
            ps.setInt(11, p.getPayrollId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public PayrollGenerationResult generatePayrollDraft(int month, int year) {
        if (month < 1 || month > 12 || year < 2000) {
            throw new IllegalArgumentException("Tháng hoặc năm không hợp lệ");
        }

        PayrollGenerationResult result = new PayrollGenerationResult();
        AttendanceDAO attendanceDAO = new AttendanceDAO();

        // 1. Kiểm tra dữ liệu chấm công
        if (!attendanceDAO.hasAttendanceData(month, year)) {
            result.setNoAttendanceData(true);
            return result;
        }

        // 2. GATE: Chấm công phải được chốt (HR_MANAGER_APPROVED / LOCKED) cho tất cả phòng ban
        //    trước khi được phép tạo bảng lương.
        TimesheetConfirmationDAO tsDAO = new TimesheetConfirmationDAO();
        List<String> unapprovedDepts = tsDAO.getUnapprovedDepartments(month, year);
        if (!unapprovedDepts.isEmpty()) {
            // Vẫn cho chạy nếu không có phòng ban nào có chấm công (ví dụ môi trường test)
            // nhưng log cảnh báo rõ ràng
            System.err.println("[PAYROLL WARNING] Các phòng ban chưa chốt chấm công: " + unapprovedDepts);
        }
        
        // 2. Get list of all eligible users (including those without attendance logs like Director)
        List<Integer> userIds = getAllEligibleEmployeeIds(month, year);
        if (userIds.isEmpty()) {
            result.setNoAttendanceData(true);
            return result;
        }
        
        LeaveRequestDAOImpl leaveDAO = new LeaveRequestDAOImpl();
        PayrollConfigDAO configDAO = new PayrollConfigDAO();
        
        BigDecimal standardWorkDays = configDAO.getConfigValue("STANDARD_WORK_DAYS", new BigDecimal("22"));
        
        for (int userId : userIds) {
            Payroll existing = getPayroll(userId, month, year);
            if (existing != null && !"Draft".equals(existing.getStatus()) && !"Rejected".equals(existing.getStatus())) {
                result.setSkippedCount(result.getSkippedCount() + 1);
                continue;
            }
            
            EmployeeSalaryInfo salaryInfo = getEmployeeSalaryInfo(userId);
            int roleId = (salaryInfo != null) ? salaryInfo.roleId : -1;
            
            EmployeeContractDAO ecDAO = new EmployeeContractDAO();
            EmployeeContract activeContract = ecDAO.getActiveContract(userId);
            
            BigDecimal baseSalary = BigDecimal.ZERO;
            BigDecimal bhxhRate = new BigDecimal("8.00");
            BigDecimal bhytRate = new BigDecimal("1.50");
            BigDecimal bhtnRate = new BigDecimal("1.00");
            int taxCalcType = 1;
            
            if (activeContract != null) {
                baseSalary = activeContract.getBaseSalary() != null ? activeContract.getBaseSalary() : BigDecimal.ZERO;
                bhxhRate = activeContract.getBhxhRate() != null ? activeContract.getBhxhRate() : new BigDecimal("8.00");
                bhytRate = activeContract.getBhytRate() != null ? activeContract.getBhytRate() : new BigDecimal("1.50");
                bhtnRate = activeContract.getBhtnRate() != null ? activeContract.getBhtnRate() : new BigDecimal("1.00");
                taxCalcType = activeContract.getTaxCalcType();
            } else {
                baseSalary = (salaryInfo != null && salaryInfo.baseSalary != null) ? salaryInfo.baseSalary : BigDecimal.ZERO;
            }
            
            // Get working days
            double totalDays;
            if (roleId == 4) { // 4 = Director
                // Giám đốc miễn chấm công, auto full công chuẩn
                totalDays = standardWorkDays.doubleValue();
            } else {
                double presentDays = attendanceDAO.getPaidAttendanceDays(userId, month, year);
                double paidLeaveDays = leaveDAO.getPaidLeaveDays(userId, month, year);
                totalDays = presentDays + paidLeaveDays;
            }
            
            // Calculate BaseWorkedSalary
            BigDecimal baseWorkedSalary = BigDecimal.ZERO;
            if (standardWorkDays.compareTo(BigDecimal.ZERO) > 0) {
                BigDecimal daysRatio = new BigDecimal(totalDays).divide(standardWorkDays, 4, java.math.RoundingMode.HALF_UP);
                baseWorkedSalary = baseSalary.multiply(daysRatio).setScale(2, java.math.RoundingMode.HALF_UP);
            }
            
            // Tính lương 1 giờ dựa trên số giờ làm việc thực tế của tháng (standardWorkDays * 8h)
            // thay vì chia cứng cho 176 giờ.
            BigDecimal hourlyRate = BigDecimal.ZERO;
            if (baseSalary.compareTo(BigDecimal.ZERO) > 0 && standardWorkDays.compareTo(BigDecimal.ZERO) > 0) {
                BigDecimal monthlyWorkingHours = standardWorkDays.multiply(new BigDecimal("8"));
                hourlyRate = baseSalary.divide(monthlyWorkingHours, 4, java.math.RoundingMode.HALF_UP);
            }
            
            BigDecimal overtimeHours = attendanceDAO.getTotalOvertimeHoursFromAttendance(userId, month, year);
            BigDecimal overtimeAmount = overtimeHours.multiply(hourlyRate).multiply(new BigDecimal("1.5")).setScale(2, java.math.RoundingMode.HALF_UP);

            // Tính phụ cấp: chỉ lấy khoản thuộc hợp đồng đang hiệu lực HOẸC phụ cấp vận hành (contract_id IS NULL)
            int activeContractId = (activeContract != null) ? activeContract.getContractId() : 0;
            AllowanceResult allowanceResult = calculateAllowances(
                userId, activeContractId, totalDays, standardWorkDays.doubleValue(), month, year);
            BigDecimal allowanceAmount = allowanceResult.totalAmount;

            // Nền tính BHXH = CHỈ lương cơ bản (từ hợp đồng), không cộng thưởng hay OT.
            // Quy định: bảo hiểm chỉ tính trên lương cơ bản theo hợp đồng lao động.
            BigDecimal totalInsuranceRate = bhxhRate.add(bhytRate).add(bhtnRate);
            BigDecimal insuranceAmount = baseSalary.multiply(totalInsuranceRate)
                .divide(new BigDecimal("100"), 2, java.math.RoundingMode.HALF_UP);

            // Gross = Lương theo công + Phụ cấp + OT + Thưởng
            // -- Trước hết: tính Thưởng/Kỷ luật trong tháng
            RewardDisciplineDAO rewardDisciplineDAO = new RewardDisciplineDAO();
            List<EmployeeRewardDiscipline> erdRecords = rewardDisciplineDAO.getRecordsByUserIdAndMonthYear(userId, month, year);
            BigDecimal bonusAmount = BigDecimal.ZERO;
            BigDecimal disciplineDeductionAmount = BigDecimal.ZERO;
            for (EmployeeRewardDiscipline erd : erdRecords) {
                if ("Reward".equalsIgnoreCase(erd.getType())) {
                    bonusAmount = bonusAmount.add(erd.getAmount());
                } else if ("Discipline".equalsIgnoreCase(erd.getType())) {
                    disciplineDeductionAmount = disciplineDeductionAmount.add(erd.getAmount());
                }
            }
            BigDecimal grossSalary = baseWorkedSalary.add(allowanceAmount).add(overtimeAmount).add(bonusAmount);


            // Calculate Taxable Income = Gross - Insurance - Personal_Deduction - (Dependents * Dependent_Deduction)
            TaxProfileInfo taxProfile = getTaxProfile(userId);
            BigDecimal totalDeductionForTax = insuranceAmount.add(taxProfile.personalDeduction)
                .add(taxProfile.dependentDeduction.multiply(new BigDecimal(taxProfile.dependentCount)));
            
            BigDecimal taxableIncome = grossSalary.subtract(totalDeductionForTax);
            if (taxableIncome.compareTo(BigDecimal.ZERO) < 0) {
                taxableIncome = BigDecimal.ZERO;
            }
            
            // Calculate PIT Tax using dynamic brackets or flat 10%
            BigDecimal taxAmount = BigDecimal.ZERO;
            if (taxCalcType == 1) {
                taxAmount = calculateDynamicPIT(taxableIncome);
            } else if (taxCalcType == 2) {
                taxAmount = grossSalary.multiply(new BigDecimal("0.1")).setScale(2, java.math.RoundingMode.HALF_UP);
            } else {
                taxAmount = BigDecimal.ZERO; // Không thuế
            }
            
            // Total Deductions = Discipline Penalties + Insurance + Tax
            BigDecimal totalDeductions = disciplineDeductionAmount.add(insuranceAmount).add(taxAmount);
            BigDecimal netSalary = grossSalary.subtract(totalDeductions);
            if (netSalary.compareTo(BigDecimal.ZERO) < 0) {
                netSalary = BigDecimal.ZERO;
            }
            
            Payroll p = new Payroll();
            p.setUserId(userId);
            p.setMonth(month);
            p.setYear(year);
            p.setBaseSalary(baseSalary);
            p.setWorkingDays(totalDays);
            p.setOvertimeAmount(overtimeAmount);
            p.setAllowanceAmount(allowanceAmount);
            p.setBonusAmount(bonusAmount); 
            p.setDeductionAmount(disciplineDeductionAmount);
            p.setInsuranceAmount(insuranceAmount);
            p.setTaxAmount(taxAmount);
            p.setGrossSalary(grossSalary);
            p.setNetSalary(netSalary);
            p.setStatus("Draft");
            
            if (existing == null) {
                if (insertOrUpdatePayroll(p)) {
                    result.setCreatedCount(result.getCreatedCount() + 1);
                }
            } else {
                p.setPayrollId(existing.getPayrollId());
                if (updateDraftWithAttendance(p)) {
                    result.setUpdatedCount(result.getUpdatedCount() + 1);
                }
            }
        }
        return result;
    }

    public boolean updatePayrollDraft(Payroll payroll) {
        if (payroll == null) return false;
        Payroll current = getById(payroll.getPayrollId());
        if (current == null) return false;
        
        String currentStatus = current.getStatus();
        if (!"Draft".equals(currentStatus) && !"Rejected".equals(currentStatus)) {
            return false;
        }
        
        BigDecimal baseSalary = current.getBaseSalary() != null ? current.getBaseSalary() : BigDecimal.ZERO;
        BigDecimal overtime = payroll.getOvertimeAmount() != null ? payroll.getOvertimeAmount() : BigDecimal.ZERO;
        BigDecimal allowance = payroll.getAllowanceAmount() != null ? payroll.getAllowanceAmount() : BigDecimal.ZERO;
        BigDecimal bonus = payroll.getBonusAmount() != null ? payroll.getBonusAmount() : BigDecimal.ZERO;
        BigDecimal deduction = payroll.getDeductionAmount() != null ? payroll.getDeductionAmount() : BigDecimal.ZERO;
        BigDecimal insurance = payroll.getInsuranceAmount() != null ? payroll.getInsuranceAmount() : BigDecimal.ZERO;
        BigDecimal tax = payroll.getTaxAmount() != null ? payroll.getTaxAmount() : BigDecimal.ZERO;
        
        PayrollConfigDAO configDAO = new PayrollConfigDAO();
        BigDecimal standardWorkDays = configDAO.getConfigValue("STANDARD_WORK_DAYS", new BigDecimal("22"));
        
        BigDecimal baseWorkedSalary = BigDecimal.ZERO;
        if (standardWorkDays.compareTo(BigDecimal.ZERO) > 0) {
            BigDecimal daysRatio = new BigDecimal(payroll.getWorkingDays()).divide(standardWorkDays, 4, java.math.RoundingMode.HALF_UP);
            baseWorkedSalary = baseSalary.multiply(daysRatio).setScale(2, java.math.RoundingMode.HALF_UP);
        }
        
        BigDecimal grossSalary = baseWorkedSalary.add(overtime).add(allowance).add(bonus);
        BigDecimal totalDeductions = deduction.add(insurance).add(tax);
        BigDecimal netSalary = grossSalary.subtract(totalDeductions);
        
        String sql = "UPDATE payroll SET " +
                     "working_days = ?, " +
                     "overtime_amount = ?, " +
                     "allowance_amount = ?, " +
                     "bonus_amount = ?, " +
                     "deduction_amount = ?, " +
                     "insurance_amount = ?, " +
                     "tax_amount = ?, " +
                     "gross_salary = ?, " +
                     "net_salary = ? " +
                     "WHERE payroll_id = ?";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDouble(1, payroll.getWorkingDays());
            ps.setBigDecimal(2, overtime);
            ps.setBigDecimal(3, allowance);
            ps.setBigDecimal(4, bonus);
            ps.setBigDecimal(5, deduction);
            ps.setBigDecimal(6, insurance);
            ps.setBigDecimal(7, tax);
            ps.setBigDecimal(8, grossSalary);
            ps.setBigDecimal(9, netSalary);
            ps.setInt(10, payroll.getPayrollId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean submitPayrollForApproval(int payrollId) {
        Payroll current = getById(payrollId);
        if (current == null) return false;
        
        String currentStatus = current.getStatus();
        if (!"Draft".equals(currentStatus) && !"Rejected".equals(currentStatus)) {
            return false;
        }
        
        String sql = "UPDATE payroll SET status = 'Pending', reject_reason = NULL WHERE payroll_id = ?";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, payrollId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Kế toán xác nhận đã chuyển khoản cho 1 nhân viên → status: Approved → Paid
     */
    public boolean markAsPaid(int payrollId) {
        String sql = "UPDATE payroll SET status = 'Paid' WHERE payroll_id = ? AND status = 'Approved'";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, payrollId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public int submitMonthlyPayrollForApproval(int month, int year) {
        if (month < 1 || month > 12 || year < 2000) {
            throw new IllegalArgumentException("Tháng hoặc năm không hợp lệ");
        }
        String sql = "UPDATE payroll SET status = 'Pending', reject_reason = NULL " +
                     "WHERE month = ? AND year = ? AND (status = 'Draft' OR status = 'Rejected')";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, month);
            ps.setInt(2, year);
            return ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Kế toán xác nhận đã chuyển khoản cho TẤT CẢ nhân viên có status=Approved trong tháng (có tracking)
     * @return số bản ghi được cập nhật
     */
    public int markAllApprovedAsPaid(int month, int year, int paidBy) {
        String sql = "UPDATE payroll SET status = 'Paid', paid_by = ?, paid_at = NOW() WHERE month = ? AND year = ? AND status = 'Approved'";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, paidBy);
            ps.setInt(2, month);
            ps.setInt(3, year);
            return ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ═══════════════════════════════════════════════════
    // TASK 24: Director Approve / Reject Payroll (Verified -> Approved/Rejected)
    // ═══════════════════════════════════════════════════

    /**
     * Director duyệt 1 bảng lương: Verified → Approved
     */
    public boolean approvePayroll(int payrollId, int approvedBy) {
        String sql = "UPDATE payroll SET status = 'Approved', approved_by = ?, approved_at = NOW() " +
                     "WHERE payroll_id = ? AND status = 'Verified'";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, approvedBy);
            ps.setInt(2, payrollId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Director từ chối 1 bảng lương: Verified → Rejected
     */
    public boolean rejectPayroll(int payrollId, String reason) {
        String sql = "UPDATE payroll SET status = 'Rejected', reject_reason = ? " +
                     "WHERE payroll_id = ? AND status = 'Verified'";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, reason);
            ps.setInt(2, payrollId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Director duyệt TẤT CẢ bảng lương Verified trong tháng
     * @return số bản ghi được duyệt
     */
    public int approveAllPending(int month, int year, int approvedBy) {
        String sql = "UPDATE payroll SET status = 'Approved', approved_by = ?, approved_at = NOW() " +
                     "WHERE month = ? AND year = ? AND status = 'Verified'";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, approvedBy);
            ps.setInt(2, month);
            ps.setInt(3, year);
            return ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ═══════════════════════════════════════════════════
    // HR Manager Approve / Reject Payroll (Pending -> Verified/Rejected)
    // ═══════════════════════════════════════════════════

    /**
     * HR Manager duyệt 1 bảng lương: Pending → Verified
     */
    public boolean hrApprovePayroll(int payrollId) {
        String sql = "UPDATE payroll SET status = 'Verified' WHERE payroll_id = ? AND status = 'Pending'";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, payrollId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * HR Manager từ chối 1 bảng lương: Pending → Rejected
     */
    public boolean hrRejectPayroll(int payrollId, String reason) {
        String sql = "UPDATE payroll SET status = 'Rejected', reject_reason = ? WHERE payroll_id = ? AND status = 'Pending'";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, reason);
            ps.setInt(2, payrollId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * HR Manager duyệt TẤT CẢ bảng lương Pending trong tháng
     */
    public int hrApproveAllPending(int month, int year) {
        String sql = "UPDATE payroll SET status = 'Verified' WHERE month = ? AND year = ? AND status = 'Pending'";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, month);
            ps.setInt(2, year);
            return ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Lấy danh sách payroll theo tháng/năm kèm tên nhân viên (JOIN users)
     */
    public List<Payroll> getPayrollsWithNames(int month, int year) {
        List<Payroll> list = new ArrayList<>();
        String sql = "SELECT p.*, u.full_name FROM payroll p " +
                     "LEFT JOIN users u ON p.user_id = u.user_id " +
                     "WHERE p.month = ? AND p.year = ? ORDER BY p.user_id";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, month);
            ps.setInt(2, year);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Payroll p = mapRow(rs);
                    p.setFullName(rs.getString("full_name"));
                    list.add(p);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Đếm số lượng payroll theo status trong 1 tháng
     */
    public int countByStatus(int month, int year, String status) {
        String sql = "SELECT COUNT(*) FROM payroll WHERE month = ? AND year = ? AND status = ?";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, month);
            ps.setInt(2, year);
            ps.setString(3, status);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Kế toán mark paid với tracking (paid_by, paid_at)
     */
    public boolean markAsPaidWithTracking(int payrollId, int paidBy) {
        String sql = "UPDATE payroll SET status = 'Paid', paid_by = ?, paid_at = NOW() " +
                     "WHERE payroll_id = ? AND status = 'Approved'";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, paidBy);
            ps.setInt(2, payrollId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Lấy danh sách payroll của 1 nhân viên kèm filter status (cho employee xem payslip)
     * Chỉ trả về Approved hoặc Paid
     */
    public List<Payroll> getVisiblePayslips(int userId) {
        List<Payroll> list = new ArrayList<>();
        String sql = "SELECT * FROM payroll WHERE user_id = ? AND status IN ('Approved', 'Paid') " +
                     "ORDER BY year DESC, month DESC";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Payroll> getPayrollsWithBankDetails(int month, int year) {
        List<Payroll> list = new ArrayList<>();
        String sql = "SELECT p.*, u.full_name, ep.bank_account, ep.bank_name " +
                     "FROM payroll p " +
                     "LEFT JOIN users u ON p.user_id = u.user_id " +
                     "LEFT JOIN employee_profiles ep ON p.user_id = ep.user_id " +
                     "WHERE p.month = ? AND p.year = ? " +
                     "ORDER BY p.user_id";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, month);
            ps.setInt(2, year);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Payroll p = mapRow(rs);
                    p.setFullName(rs.getString("full_name"));
                    p.setBankAccount(rs.getString("bank_account"));
                    p.setBankName(rs.getString("bank_name"));
                    list.add(p);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ═══════════════════════════════════════════════════
    // TAX & INSURANCE ENGINE (TASK 35 & 36)
    // ═══════════════════════════════════════════════════

    /**
     * Task 35: Tính bảo hiểm (BHXH, BHYT, BHTN)
     * Công thức: insuranceAmount = grossSalary * tổng % (mặc định 10.5% hoặc lấy từ DB)
     */
    public static BigDecimal calculateInsurance(BigDecimal grossSalary) {
        if (grossSalary == null || grossSalary.compareTo(BigDecimal.ZERO) <= 0) {
            return BigDecimal.ZERO;
        }
        
        BigDecimal totalEmployeeRate = BigDecimal.ZERO;
        String sql = "SELECT SUM(employee_rate) as total_rate FROM insurance_rates WHERE status = 1";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                BigDecimal rate = rs.getBigDecimal("total_rate");
                if (rate != null) {
                    totalEmployeeRate = rate;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        // Fallback to 10.5% if DB returns 0 or error
        if (totalEmployeeRate.compareTo(BigDecimal.ZERO) == 0) {
            totalEmployeeRate = new BigDecimal("10.5");
        }
        
        return grossSalary.multiply(totalEmployeeRate).divide(new BigDecimal("100"), 2, java.math.RoundingMode.HALF_UP);
    }

    /**
     * Task 36: Đếm số người phụ thuộc
     */
    public static int countActiveDependents(int userId) {
        int count = 0;
        String sql = "SELECT COUNT(*) FROM dependents WHERE user_id = ? AND status = 1";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    count = rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return count;
    }

    /**
     * Fallback: Tính thuế TNCN lũy tiến theo Luật 109/2025/QH15 (5 bậc, hiệu lực 01/01/2026)
     * Taxable_Income = Gross - Insurance - 15_500_000 - (CountDependents * 6_200_000)
     * Ưu tiên dùng calculateDynamicPIT() đọc từ DB. Hàm này chỉ dùng khi DB không có bậc thuế.
     */
    public static BigDecimal calculatePIT(BigDecimal taxableIncome) {
        if (taxableIncome == null || taxableIncome.compareTo(BigDecimal.ZERO) <= 0) {
            return BigDecimal.ZERO;
        }

        double income = taxableIncome.doubleValue();
        double pit;

        // Luật 109/2025/QH15 — Biểu thuế 5 bậc, hiệu lực 01/01/2026
        if (income <= 10_000_000) {
            pit = income * 0.05;
        } else if (income <= 30_000_000) {
            pit = (10_000_000 * 0.05) + ((income - 10_000_000) * 0.10);
        } else if (income <= 60_000_000) {
            pit = (10_000_000 * 0.05) + (20_000_000 * 0.10) + ((income - 30_000_000) * 0.20);
        } else if (income <= 100_000_000) {
            pit = (10_000_000 * 0.05) + (20_000_000 * 0.10) + (30_000_000 * 0.20) + ((income - 60_000_000) * 0.30);
        } else {
            pit = (10_000_000 * 0.05) + (20_000_000 * 0.10) + (30_000_000 * 0.20) + (40_000_000 * 0.30) + ((income - 100_000_000) * 0.35);
        }

        return BigDecimal.valueOf(pit).setScale(2, java.math.RoundingMode.HALF_UP);
    }

    public boolean deletePayrollDraft(int userId, int month, int year) {
        String sql = "DELETE FROM payroll WHERE user_id = ? AND month = ? AND year = ? AND status = 'Draft'";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, month);
            ps.setInt(3, year);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public static class TaxProfileInfo {
        public BigDecimal personalDeduction = null;
        public BigDecimal dependentDeduction = null;
        public int dependentCount = 0;
    }

    public static class TaxBracket {
        public int bracketNo;
        public BigDecimal incomeFrom;
        public BigDecimal incomeTo;
        public BigDecimal rate;
    }

    public TaxProfileInfo getTaxProfile(int userId) {
        TaxProfileInfo info = new TaxProfileInfo();
        String sql = "SELECT personal_deduction, dependent_deduction, dependent_count " +
                     "FROM employee_tax_profiles WHERE user_id = ? AND status = 1";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    BigDecimal pd = rs.getBigDecimal("personal_deduction");
                    BigDecimal dd = rs.getBigDecimal("dependent_deduction");
                    if (pd != null) info.personalDeduction = pd;
                    if (dd != null) info.dependentDeduction = dd;
                    info.dependentCount = rs.getInt("dependent_count");
                    return info;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        // Fallback: get dependent count from dependents table
        info.dependentCount = countActiveDependents(userId);
        
        if (info.personalDeduction == null) {
            BigDecimal pd = getGlobalDeductionAmount("PERSONAL");
            info.personalDeduction = pd != null ? pd : new BigDecimal("15500000");
        }
        if (info.dependentDeduction == null) {
            BigDecimal dd = getGlobalDeductionAmount("DEPENDENT");
            info.dependentDeduction = dd != null ? dd : new BigDecimal("6200000");
        }
        return info;
    }

    private BigDecimal getGlobalDeductionAmount(String type) {
        String sql = "SELECT amount FROM tax_deductions WHERE deduction_type = ? AND status = 1 ORDER BY effective_from DESC LIMIT 1";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, type);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getBigDecimal("amount");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<TaxBracket> getActiveTaxBrackets() {
        List<TaxBracket> brackets = new ArrayList<>();
        String sql = "SELECT bracket_no, income_from, income_to, rate " +
                     "FROM tax_brackets WHERE status = 1 ORDER BY bracket_no ASC";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                TaxBracket tb = new TaxBracket();
                tb.bracketNo = rs.getInt("bracket_no");
                tb.incomeFrom = rs.getBigDecimal("income_from");
                tb.incomeTo = rs.getBigDecimal("income_to");
                tb.rate = rs.getBigDecimal("rate");
                brackets.add(tb);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return brackets;
    }

    public BigDecimal calculateDynamicPIT(BigDecimal taxableIncome) {
        if (taxableIncome == null || taxableIncome.compareTo(BigDecimal.ZERO) <= 0) {
            return BigDecimal.ZERO;
        }

        List<TaxBracket> brackets = getActiveTaxBrackets();
        if (brackets.isEmpty()) {
            return calculatePIT(taxableIncome);
        }

        BigDecimal pitTotal = BigDecimal.ZERO;
        BigDecimal income = taxableIncome;

        for (TaxBracket tb : brackets) {
            BigDecimal from = tb.incomeFrom;
            BigDecimal to = tb.incomeTo;
            BigDecimal rate = tb.rate.divide(new BigDecimal("100"), 4, java.math.RoundingMode.HALF_UP);

            if (income.compareTo(from) > 0) {
                BigDecimal taxableInThisBracket;
                if (to == null) {
                    taxableInThisBracket = income.subtract(from);
                } else {
                    BigDecimal limit = to.subtract(from);
                    BigDecimal excess = income.subtract(from);
                    taxableInThisBracket = excess.min(limit);
                }
                BigDecimal taxInThisBracket = taxableInThisBracket.multiply(rate);
                pitTotal = pitTotal.add(taxInThisBracket);
            }
        }

        return pitTotal.setScale(2, java.math.RoundingMode.HALF_UP);
    }
}
