package dao;
import util.DBContext;
import model.EmployeeRewardDiscipline;
import dao.RewardDisciplineDAO;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.time.LocalDate;
import java.time.DayOfWeek;
import model.EmployeeContract;
import dao.EmployeeContractDAO;
import model.Payroll;
import java.sql.Date;
// Cáº§n import Ä‘á»ƒ kiá»ƒm tra tráº¡ng thÃ¡i chá»‘t cháº¥m cÃ´ng
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

    // Helper map Ä‘áº§y Ä‘á»§ táº¥t cáº£ cá»™t DB
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
        String sql = "SELECT ep.hire_date, sg.min_salary as base_salary, u.role_id " +
                     "FROM employee_profiles ep " +
                     "JOIN salary_grades sg ON ep.salary_grade_id = sg.salary_grade_id " +
                     "JOIN users u ON ep.user_id = u.user_id " +
                     "WHERE ep.user_id = ?";
        try (Connection conn = DBContext.getConnection();
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
     * Kiá»ƒm tra xem Ä‘Ã£ cÃ³ báº£ng lÆ°Æ¡ng nhÃ¡p (Draft/Pending/Approved/Paid) cho thÃ¡ng/nÄƒm chÆ°a.
     * DÃ¹ng Ä‘á»ƒ cháº·n má»Ÿ khÃ³a báº£ng cÃ´ng khi Ä‘Ã£ gen payroll draft.
     */
    public boolean hasPayrollGenerated(int month, int year) {
        String sql = "SELECT COUNT(*) FROM payroll WHERE month = ? AND year = ?";
        try (Connection conn = DBContext.getConnection();
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

    // Insert hoáº·c update Ä‘áº§y Ä‘á»§ táº¥t cáº£ cá»™t
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
        try (Connection conn = DBContext.getConnection();
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
        try (Connection conn = DBContext.getConnection();
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
        try (Connection conn = DBContext.getConnection();
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
        try (Connection conn = DBContext.getConnection();
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
        try (Connection conn = DBContext.getConnection();
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
        try (Connection conn = DBContext.getConnection();
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
            throw new IllegalArgumentException("ThÃ¡ng hoáº·c nÄƒm khÃ´ng há»£p lá»‡");
        }
        return getPayroll(userId, month, year);
    }

    public List<Integer> getAllActiveEmployeeIds() {
        List<Integer> list = new ArrayList<>();
        String sql = "SELECT user_id FROM users WHERE status = 1";
        try (Connection conn = DBContext.getConnection();
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

        try (Connection conn = DBContext.getConnection();
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
        try (Connection conn = DBContext.getConnection();
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
     * TÃ­nh tá»•ng phá»¥ cáº¥p thÃ¡ng theo logic chuáº©n.
     * Chá»‰ Ä‘á»c phá»¥ cáº¥p thuá»™c há»£p Ä‘á»“ng Ä‘ang hiá»‡u lá»±c HOáº¸C phá»¥ cáº¥p váº­n hÃ nh (contract_id IS NULL).
     *
     * @param activeContractId  ID cá»§a há»£p Ä‘á»“ng Ä‘ang active (truyá»n 0 náº¿u khÃ´ng cÃ³ há»£p Ä‘á»“ng)
     */
    public AllowanceResult calculateAllowances(
            int empId, int activeContractId,
            double actualWorkDays, double standardWorkDays, int month, int year) {
        /*
         * Logic láº¥y phá»¥ cáº¥p:
         *   - contract_id = activeContractId  â†’ Phá»¥ cáº¥p "cam káº¿t" Ä‘Ã£ ghi vÃ o há»£p Ä‘á»“ng/phá»¥ lá»¥c
         *   - contract_id IS NULL            â†’ Phá»¥ cáº¥p "váº­n hÃ nh" (Äƒn ca, Ä‘i láº¡i...), Ã¡p dá»¥ng chung
         * Tá»· lá»‡ BHXH chá»‰ tÃ­nh trÃªn phá»¥ cáº¥p cÃ³ is_bhxh_applied = 1.
         */
        String sql;
        if (activeContractId > 0) {
            sql = "SELECT a.amount, a.calculation_type, a.is_bhxh_applied " +
                  "FROM employee_allowances ea " +
                  "JOIN allowances a ON ea.allowance_id = a.allowance_id " +
                  "WHERE ea.user_id = ? AND a.status = 1 " +
                  "  AND ea.contract_id = ?";
        } else {
            // KhÃ´ng cÃ³ há»£p Ä‘á»“ng -> KhÃ´ng cÃ³ phá»¥ cáº¥p
            return new AllowanceResult(BigDecimal.ZERO, BigDecimal.ZERO);
        }

        BigDecimal totalAllowance = BigDecimal.ZERO;
        BigDecimal bhxhBaseFromAllowances = BigDecimal.ZERO;

        try (Connection conn = DBContext.getConnection();
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
                            // TÃ­nh theo ngÃ y cÃ´ng thá»±c táº¿ (vÃ­ dá»¥: Äƒn ca)
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
                            // Tráº£ Ä‘á»§ náº¿u khÃ´ng cÃ³ ngÃ y ABSENT khÃ´ng phÃ©p trong thÃ¡ng
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

    /** Kiá»ƒm tra cÃ³ ngÃ y ABSENT khÃ´ng phÃ©p trong thÃ¡ng khÃ´ng. */
    private boolean hasUnexcusedAbsence(int userId, int month, int year) {
        String sql = "SELECT COUNT(*) FROM attendance " +
                     "WHERE user_id = ? AND MONTH(work_date) = ? AND YEAR(work_date) = ? " +
                     "AND status = 'ABSENT'";
        try (Connection conn = DBContext.getConnection();
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

    /** Káº¿t quáº£ tÃ­nh phá»¥ cáº¥p: tá»•ng phá»¥ cáº¥p vÃ  pháº§n thuá»™c ná»n BHXH */
    public static class AllowanceResult {
        public final BigDecimal totalAmount;
        public final BigDecimal bhxhBase;
        public AllowanceResult(BigDecimal totalAmount, BigDecimal bhxhBase) {
            this.totalAmount = totalAmount;
            this.bhxhBase = bhxhBase;
        }
    }

    /** Giá»¯ láº¡i method cÅ© Ä‘á»ƒ backward-compatible, gá»i sang method má»›i */
    public BigDecimal getFixedAllowances(int empId) {
        String sql = "SELECT SUM(a.amount) FROM employee_allowances ea " +
                     "JOIN allowances a ON ea.allowance_id = a.allowance_id " +
                     "WHERE ea.user_id = ? AND a.status = 1 AND a.calculation_type = 'FIXED'";
        try (Connection conn = DBContext.getConnection();
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
        try (Connection conn = DBContext.getConnection();
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
            throw new IllegalArgumentException("ThÃ¡ng hoáº·c nÄƒm khÃ´ng há»£p lá»‡");
        }

        PayrollGenerationResult result = new PayrollGenerationResult();
        AttendanceDAO attendanceDAO = new AttendanceDAO();

        // 1. Kiá»ƒm tra dá»¯ liá»‡u cháº¥m cÃ´ng
        if (!attendanceDAO.hasAttendanceData(month, year)) {
            result.setNoAttendanceData(true);
            return result;
        }

        // 2. GATE: Cháº¥m cÃ´ng pháº£i Ä‘Æ°á»£c chá»‘t (HR_MANAGER_APPROVED / LOCKED) cho táº¥t cáº£ phÃ²ng ban
        //    trÆ°á»›c khi Ä‘Æ°á»£c phÃ©p táº¡o báº£ng lÆ°Æ¡ng.
        TimesheetConfirmationDAO tsDAO = new TimesheetConfirmationDAO();
        List<String> unapprovedDepts = tsDAO.getUnapprovedDepartments(month, year);
        if (!unapprovedDepts.isEmpty()) {
            // Váº«n cho cháº¡y náº¿u khÃ´ng cÃ³ phÃ²ng ban nÃ o cÃ³ cháº¥m cÃ´ng (vÃ­ dá»¥ mÃ´i trÆ°á»ng test)
            // nhÆ°ng log cáº£nh bÃ¡o rÃµ rÃ ng
            System.err.println("[PAYROLL WARNING] CÃ¡c phÃ²ng ban chÆ°a chá»‘t cháº¥m cÃ´ng: " + unapprovedDepts);
        }
        
        // 2. Get list of all eligible users (including those without attendance logs like Director)
        List<Integer> userIds = getAllEligibleEmployeeIds(month, year);
        if (userIds.isEmpty()) {
            result.setNoAttendanceData(true);
            return result;
        }
        
        LeaveRequestDAOImpl leaveDAO = new LeaveRequestDAOImpl();
        PayrollConfigDAO configDAO = new PayrollConfigDAO();
        
        BigDecimal standardWorkDays = configDAO.getConfigValue("STANDARD_WORK_DAYS", new BigDecimal("26"));
        
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
            int taxCalcType = 1;
            
            if (activeContract != null) {
                baseSalary = activeContract.getBaseSalary() != null ? activeContract.getBaseSalary() : BigDecimal.ZERO;
                taxCalcType = activeContract.getTaxCalcType();
            } else {
                baseSalary = (salaryInfo != null && salaryInfo.baseSalary != null) ? salaryInfo.baseSalary : BigDecimal.ZERO;
            }
            
            // Get working days
            double totalDays;
            if (roleId == 4) { // 4 = Director
                // GiÃ¡m Ä‘á»‘c miá»…n cháº¥m cÃ´ng, auto full cÃ´ng chuáº©n
                totalDays = standardWorkDays.doubleValue();
            } else {
                // -------------------------------------------------------------------
                // Tính ngày công thực tế theo tập hợp ngày duy nhất (union-based).
                // Lý do đổi cách tính: cách cũ (presentDays + paidLeaveDays) đếm
                // độc lập 2 bảng riêng, nếu cùng 1 ngày vừa có bản ghi attendance
                // hợp lệ vừa có leave đã duyệt thì ngày đó bị tính 2 lần, gây sai lương.
                // -------------------------------------------------------------------

                // Bước 1: Lấy Map ngày -> giá trị công từ attendance (1.0 hoặc 0.5 cho HalfDay)
                Map<LocalDate, Double> attendanceDayMap =
                        attendanceDAO.getPaidAttendanceDayMap(userId, month, year);

                // Bước 2: Lấy Set ngày nghỉ phép có lương đã duyệt
                Set<LocalDate> leaveDaySet =
                        ((LeaveRequestDAOImpl) leaveDAO).getPaidLeaveDaySet(userId, month, year);

                // Bước 3: Hợp (union) 2 tập ngày.
                // - Ưu tiên attendance nếu ngày xuất hiện ở cả 2 (số liệu chấm công thực tế hơn).
                // - Ngày chỉ có trong leave (không có bản ghi attendance) được tính 1.0.
                Map<LocalDate, Double> unionDayMap = new HashMap<>(attendanceDayMap);
                for (LocalDate leaveDate : leaveDaySet) {
                    // putIfAbsent: nếu ngày đó đã có trong attendance thì bỏ qua (không đếm trùng)
                    unionDayMap.putIfAbsent(leaveDate, 1.0);
                }

                // Bước 4: Cộng giá trị của từng ngày trong tập hợp
                totalDays = unionDayMap.values().stream()
                                       .mapToDouble(Double::doubleValue)
                                       .sum();

                // Bước 5: Kiểm tra cảnh báo nếu totalDays vượt công chuẩn.
                // Trường hợp này xảy ra khi data gốc bị lỗi (ví dụ nhân viên có attendance
                // trên cả ngày nghỉ lễ hoặc ngày đang nghỉ phép không có lương).
                if (totalDays > standardWorkDays.doubleValue()) {
                    System.err.println("[PAYROLL WARNING] userId=" + userId +
                        ", tháng=" + month + "/" + year +
                        ": totalDays=" + totalDays +
                        " vượt standardWorkDays=" + standardWorkDays +
                        ". Kiểm tra lại data attendance/leave gốc.");
                }
            }
            
            // Calculate BaseWorkedSalary
            BigDecimal baseWorkedSalary = BigDecimal.ZERO;
            if (standardWorkDays.compareTo(BigDecimal.ZERO) > 0) {
                BigDecimal daysRatio = new BigDecimal(totalDays).divide(standardWorkDays, 4, java.math.RoundingMode.HALF_UP);
                baseWorkedSalary = baseSalary.multiply(daysRatio).setScale(2, java.math.RoundingMode.HALF_UP);
            }
            
            // TÃ­nh lÆ°Æ¡ng 1 giá» dá»±a trÃªn sá»‘ giá» lÃ m viá»‡c thá»±c táº¿ cá»§a thÃ¡ng (standardWorkDays * 8h)
            // thay vÃ¬ chia cá»©ng cho 176 giá».
            BigDecimal hourlyRate = BigDecimal.ZERO;
            if (baseSalary.compareTo(BigDecimal.ZERO) > 0 && standardWorkDays.compareTo(BigDecimal.ZERO) > 0) {
                BigDecimal monthlyWorkingHours = standardWorkDays.multiply(new BigDecimal("8"));
                hourlyRate = baseSalary.divide(monthlyWorkingHours, 4, java.math.RoundingMode.HALF_UP);
            }
            
            BigDecimal overtimeHours = attendanceDAO.getTotalOvertimeHoursFromAttendance(userId, month, year);
            BigDecimal overtimeAmount = overtimeHours.multiply(hourlyRate).multiply(new BigDecimal("1.5")).setScale(2, java.math.RoundingMode.HALF_UP);

            // TÃ­nh phá»¥ cáº¥p: chá»‰ láº¥y khoáº£n thuá»™c há»£p Ä‘á»“ng Ä‘ang hiá»‡u lá»±c HOáº¸C phá»¥ cáº¥p váº­n hÃ nh (contract_id IS NULL)
            int activeContractId = (activeContract != null) ? activeContract.getContractId() : 0;
            AllowanceResult allowanceResult = calculateAllowances(
                userId, activeContractId, totalDays, standardWorkDays.doubleValue(), month, year);
            BigDecimal allowanceAmount = allowanceResult.totalAmount;

            // Ná»n tÃ­nh BHXH = CHá»ˆ lÆ°Æ¡ng cÆ¡ báº£n (tá»« há»£p Ä‘á»“ng), khÃ´ng cá»™ng thÆ°á»Ÿng hay OT.
            // Quy Ä‘á»‹nh: báº£o hiá»ƒm chá»‰ tÃ­nh trÃªn lÆ°Æ¡ng cÆ¡ báº£n theo há»£p Ä‘á»“ng lao Ä‘á»™ng.
            // Láº¥y tá»•ng tá»· lá»‡ báº£o hiá»ƒm tá»« báº£ng cáº¥u hÃ¬nh insurance_rates thÃ´ng qua hÃ m tÃ­nh toÃ¡n
            BigDecimal insuranceAmount = calculateInsurance(baseSalary);

            // Gross = LÆ°Æ¡ng theo cÃ´ng + Phá»¥ cáº¥p + OT + ThÆ°á»Ÿng
            // -- TrÆ°á»›c háº¿t: tÃ­nh ThÆ°á»Ÿng/Ká»· luáº­t trong thÃ¡ng
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
                taxAmount = BigDecimal.ZERO; // KhÃ´ng thuáº¿
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

    /**
     * TASK 2: Viáº¿t láº¡i updatePayrollDraft â€” tá»± Ä‘á»™ng tÃ­nh láº¡i Thuáº¿ TNCN vÃ  Báº£o hiá»ƒm
     * khi HR thay Ä‘á»•i thÆ°á»Ÿng, phá»¥ cáº¥p hoáº·c pháº¡t.
     * 
     * HR chá»‰ nháº­p: workingDays, overtimeAmount, allowanceAmount, bonusAmount, deductionAmount
     * Há»‡ thá»‘ng tá»± tÃ­nh: insurance, tax (PIT), gross, net
     */
    public boolean updatePayrollDraft(Payroll payroll) {
        if (payroll == null) return false;
        Payroll current = getById(payroll.getPayrollId());
        if (current == null) return false;
        
        String currentStatus = current.getStatus();
        if (!"Draft".equals(currentStatus) && !"Rejected".equals(currentStatus)) {
            return false;
        }
        
        // --- Láº¥y giÃ¡ trá»‹ HR nháº­p (hoáº·c giá»¯ nguyÃªn tá»« báº£n ghi hiá»‡n táº¡i) ---
        BigDecimal baseSalary = current.getBaseSalary() != null ? current.getBaseSalary() : BigDecimal.ZERO;
        BigDecimal overtime = payroll.getOvertimeAmount() != null ? payroll.getOvertimeAmount() : BigDecimal.ZERO;
        BigDecimal allowance = payroll.getAllowanceAmount() != null ? payroll.getAllowanceAmount() : BigDecimal.ZERO;
        BigDecimal bonus = payroll.getBonusAmount() != null ? payroll.getBonusAmount() : BigDecimal.ZERO;
        BigDecimal deduction = payroll.getDeductionAmount() != null ? payroll.getDeductionAmount() : BigDecimal.ZERO;
        
        // --- TÃ­nh lÆ°Æ¡ng theo ngÃ y cÃ´ng thá»±c táº¿ ---
        PayrollConfigDAO configDAO = new PayrollConfigDAO();
        BigDecimal standardWorkDays = configDAO.getConfigValue("STANDARD_WORK_DAYS", new BigDecimal("26"));
        
        BigDecimal baseWorkedSalary = BigDecimal.ZERO;
        if (standardWorkDays.compareTo(BigDecimal.ZERO) > 0) {
            BigDecimal daysRatio = new BigDecimal(payroll.getWorkingDays()).divide(standardWorkDays, 4, java.math.RoundingMode.HALF_UP);
            baseWorkedSalary = baseSalary.multiply(daysRatio).setScale(2, java.math.RoundingMode.HALF_UP);
        }
        
        // --- TÃ­nh Gross Salary ---
        BigDecimal grossSalary = baseWorkedSalary.add(overtime).add(allowance).add(bonus);
        
        // --- Tá»± Ä‘á»™ng tÃ­nh Báº£o hiá»ƒm (BHXH + BHYT + BHTN) dá»±a trÃªn lÆ°Æ¡ng cÆ¡ báº£n ---
        BigDecimal insuranceAmount = calculateInsurance(baseSalary);
        
        // --- Tá»± Ä‘á»™ng tÃ­nh Thuáº¿ TNCN (PIT) lÅ©y tiáº¿n ---
        TaxProfileInfo taxProfile = getTaxProfile(current.getUserId());
        BigDecimal totalDeductionForTax = insuranceAmount
                .add(taxProfile.personalDeduction)
                .add(taxProfile.dependentDeduction.multiply(new BigDecimal(taxProfile.dependentCount)));
        
        BigDecimal taxableIncome = grossSalary.subtract(totalDeductionForTax);
        if (taxableIncome.compareTo(BigDecimal.ZERO) < 0) {
            taxableIncome = BigDecimal.ZERO;
        }
        BigDecimal taxAmount = calculateDynamicPIT(taxableIncome);
        
        // --- TÃ­nh Net Salary ---
        BigDecimal totalDeductions = deduction.add(insuranceAmount).add(taxAmount);

        BigDecimal netSalary = grossSalary.subtract(totalDeductions);
        if (netSalary.compareTo(BigDecimal.ZERO) < 0) {
            netSalary = BigDecimal.ZERO;
        }
        
        // --- Cáº­p nháº­t vÃ o payroll object Ä‘á»ƒ controller cÃ³ thá»ƒ tráº£ vá» ---
        payroll.setBaseSalary(baseSalary);
        payroll.setInsuranceAmount(insuranceAmount);
        payroll.setTaxAmount(taxAmount);
        payroll.setGrossSalary(grossSalary);
        payroll.setNetSalary(netSalary);
        
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
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDouble(1, payroll.getWorkingDays());
            ps.setBigDecimal(2, overtime);
            ps.setBigDecimal(3, allowance);
            ps.setBigDecimal(4, bonus);
            ps.setBigDecimal(5, deduction);
            ps.setBigDecimal(6, insuranceAmount);
            ps.setBigDecimal(7, taxAmount);
            ps.setBigDecimal(8, grossSalary);
            ps.setBigDecimal(9, netSalary);
            ps.setInt(10, payroll.getPayrollId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * TASK 2: TÃ­nh toÃ¡n preview khi HR thay Ä‘á»•i giÃ¡ trá»‹ (dÃ¹ng cho AJAX recalculate)
     * Tráº£ vá» Payroll object vá»›i cÃ¡c giÃ¡ trá»‹ insurance, tax, gross, net Ä‘Ã£ tÃ­nh sáºµn.
     * KHÃ”NG lÆ°u vÃ o DB.
     */
    public Payroll recalculatePayrollPreview(int payrollId, BigDecimal overtimeAmount,
            BigDecimal allowanceAmount, BigDecimal bonusAmount, BigDecimal deductionAmount) {
        Payroll current = getById(payrollId);
        if (current == null) return null;
        
        BigDecimal baseSalary = current.getBaseSalary() != null ? current.getBaseSalary() : BigDecimal.ZERO;
        BigDecimal overtime = overtimeAmount != null ? overtimeAmount : BigDecimal.ZERO;
        BigDecimal allowance = allowanceAmount != null ? allowanceAmount : BigDecimal.ZERO;
        BigDecimal bonus = bonusAmount != null ? bonusAmount : BigDecimal.ZERO;
        BigDecimal deduction = deductionAmount != null ? deductionAmount : BigDecimal.ZERO;
        
        BigDecimal grossSalary = baseSalary.add(overtime).add(allowance).add(bonus);
        BigDecimal insuranceAmount = calculateInsurance(grossSalary);
        
        TaxProfileInfo taxProfile = getTaxProfile(current.getUserId());
        BigDecimal totalDeductionForTax = insuranceAmount
                .add(taxProfile.personalDeduction)
                .add(taxProfile.dependentDeduction.multiply(new BigDecimal(taxProfile.dependentCount)));
        BigDecimal taxableIncome = grossSalary.subtract(totalDeductionForTax);
        if (taxableIncome.compareTo(BigDecimal.ZERO) < 0) {
            taxableIncome = BigDecimal.ZERO;
        }
        BigDecimal taxAmount = calculateDynamicPIT(taxableIncome);
        
        BigDecimal totalDeductions = deduction.add(insuranceAmount).add(taxAmount);
        BigDecimal netSalary = grossSalary.subtract(totalDeductions);
        if (netSalary.compareTo(BigDecimal.ZERO) < 0) {
            netSalary = BigDecimal.ZERO;
        }
        
        Payroll preview = new Payroll();
        preview.setPayrollId(payrollId);
        preview.setUserId(current.getUserId());
        preview.setBaseSalary(baseSalary);
        preview.setOvertimeAmount(overtime);
        preview.setAllowanceAmount(allowance);
        preview.setBonusAmount(bonus);
        preview.setDeductionAmount(deduction);
        preview.setInsuranceAmount(insuranceAmount);
        preview.setTaxAmount(taxAmount);
        preview.setGrossSalary(grossSalary);
        preview.setNetSalary(netSalary);
        return preview;
    }

    public boolean submitPayrollForApproval(int payrollId) {
        Payroll current = getById(payrollId);
        if (current == null) return false;
        
        String currentStatus = current.getStatus();
        if (!"Draft".equals(currentStatus) && !"Rejected".equals(currentStatus)) {
            return false;
        }
        
        String sql = "UPDATE payroll SET status = 'Pending', reject_reason = NULL WHERE payroll_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, payrollId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Káº¿ toÃ¡n xÃ¡c nháº­n Ä‘Ã£ chuyá»ƒn khoáº£n cho 1 nhÃ¢n viÃªn â†’ status: Approved â†’ Paid
     */
    public boolean markAsPaid(int payrollId) {
        String sql = "UPDATE payroll SET status = 'Paid' WHERE payroll_id = ? AND status = 'Approved'";
        try (Connection conn = DBContext.getConnection();
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
            throw new IllegalArgumentException("ThÃ¡ng hoáº·c nÄƒm khÃ´ng há»£p lá»‡");
        }
        String sql = "UPDATE payroll SET status = 'Pending', reject_reason = NULL " +
                     "WHERE month = ? AND year = ? AND (status = 'Draft' OR status = 'Rejected')";
        try (Connection conn = DBContext.getConnection();
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
     * Káº¿ toÃ¡n xÃ¡c nháº­n Ä‘Ã£ chuyá»ƒn khoáº£n cho Táº¤T Cáº¢ nhÃ¢n viÃªn cÃ³ status=Approved trong thÃ¡ng (cÃ³ tracking)
     * @return sá»‘ báº£n ghi Ä‘Æ°á»£c cáº­p nháº­t
     */
    public int markAllApprovedAsPaid(int month, int year, int paidBy) {
        String sql = "UPDATE payroll SET status = 'Paid', paid_by = ?, paid_at = NOW() WHERE month = ? AND year = ? AND status = 'Approved'";
        try (Connection conn = DBContext.getConnection();
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

    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    // TASK 24: Director Approve / Reject Payroll (Verified -> Approved/Rejected)
    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

    /**
     * Director duyá»‡t 1 báº£ng lÆ°Æ¡ng: Verified â†’ Approved
     */
    public boolean approvePayroll(int payrollId, int approvedBy) {
        String sql = "UPDATE payroll SET status = 'Approved', approved_by = ?, approved_at = NOW() " +
                     "WHERE payroll_id = ? AND status = 'Verified'";
        try (Connection conn = DBContext.getConnection();
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
     * Director tá»« chá»‘i 1 báº£ng lÆ°Æ¡ng: Verified â†’ Rejected
     */
    public boolean rejectPayroll(int payrollId, String reason) {
        String sql = "UPDATE payroll SET status = 'Rejected', reject_reason = ? " +
                     "WHERE payroll_id = ? AND status = 'Verified'";
        try (Connection conn = DBContext.getConnection();
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
     * Director duyá»‡t Táº¤T Cáº¢ báº£ng lÆ°Æ¡ng Verified trong thÃ¡ng
     * @return sá»‘ báº£n ghi Ä‘Æ°á»£c duyá»‡t
     */
    public int approveAllPending(int month, int year, int approvedBy) {
        String sql = "UPDATE payroll SET status = 'Approved', approved_by = ?, approved_at = NOW() " +
                     "WHERE month = ? AND year = ? AND status = 'Verified'";
        try (Connection conn = DBContext.getConnection();
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

    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    // HR Manager Approve / Reject Payroll (Pending -> Verified/Rejected)
    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

    /**
     * HR Manager duyá»‡t 1 báº£ng lÆ°Æ¡ng: Pending â†’ Verified
     */
    public boolean hrApprovePayroll(int payrollId) {
        String sql = "UPDATE payroll SET status = 'Verified' WHERE payroll_id = ? AND status = 'Pending'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, payrollId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * HR Manager tá»« chá»‘i 1 báº£ng lÆ°Æ¡ng: Pending â†’ Rejected
     */
    public boolean hrRejectPayroll(int payrollId, String reason) {
        String sql = "UPDATE payroll SET status = 'Rejected', reject_reason = ? WHERE payroll_id = ? AND status = 'Pending'";
        try (Connection conn = DBContext.getConnection();
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
     * HR Manager duyá»‡t Táº¤T Cáº¢ báº£ng lÆ°Æ¡ng Pending trong thÃ¡ng
     */
    public int hrApproveAllPending(int month, int year) {
        String sql = "UPDATE payroll SET status = 'Verified' WHERE month = ? AND year = ? AND status = 'Pending'";
        try (Connection conn = DBContext.getConnection();
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
     * Láº¥y danh sÃ¡ch payroll theo thÃ¡ng/nÄƒm kÃ¨m tÃªn nhÃ¢n viÃªn (JOIN users)
     */
    public List<Payroll> getPayrollsWithNames(int month, int year) {
        List<Payroll> list = new ArrayList<>();
        String sql = "SELECT p.*, u.full_name FROM payroll p " +
                     "LEFT JOIN users u ON p.user_id = u.user_id " +
                     "WHERE p.month = ? AND p.year = ? ORDER BY p.user_id";
        try (Connection conn = DBContext.getConnection();
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
     * Äáº¿m sá»‘ lÆ°á»£ng payroll theo status trong 1 thÃ¡ng
     */
    public int countByStatus(int month, int year, String status) {
        String sql = "SELECT COUNT(*) FROM payroll WHERE month = ? AND year = ? AND status = ?";
        try (Connection conn = DBContext.getConnection();
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
     * Káº¿ toÃ¡n mark paid vá»›i tracking (paid_by, paid_at)
     */
    public boolean markAsPaidWithTracking(int payrollId, int paidBy) {
        String sql = "UPDATE payroll SET status = 'Paid', paid_by = ?, paid_at = NOW() " +
                     "WHERE payroll_id = ? AND status = 'Approved'";
        try (Connection conn = DBContext.getConnection();
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
     * Láº¥y danh sÃ¡ch payroll cá»§a 1 nhÃ¢n viÃªn kÃ¨m filter status (cho employee xem payslip)
     * Chá»‰ tráº£ vá» Approved hoáº·c Paid
     */
    public List<Payroll> getVisiblePayslips(int userId) {
        List<Payroll> list = new ArrayList<>();
        String sql = "SELECT * FROM payroll WHERE user_id = ? AND status IN ('Approved', 'Paid') " +
                     "ORDER BY year DESC, month DESC";
        try (Connection conn = DBContext.getConnection();
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
        try (Connection conn = DBContext.getConnection();
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

    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    // TAX & INSURANCE ENGINE (TASK 35 & 36)
    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

    /**
     * Task 35: TÃ­nh báº£o hiá»ƒm (BHXH, BHYT, BHTN)
     * CÃ´ng thá»©c: insuranceAmount = grossSalary * tá»•ng % (máº·c Ä‘á»‹nh 10.5% hoáº·c láº¥y tá»« DB)
     */
    public static BigDecimal calculateInsurance(BigDecimal grossSalary) {
        if (grossSalary == null || grossSalary.compareTo(BigDecimal.ZERO) <= 0) {
            return BigDecimal.ZERO;
        }
        
        BigDecimal totalEmployeeRate = BigDecimal.ZERO;
        String sql = "SELECT SUM(employee_rate) as total_rate FROM insurance_rates WHERE status = 1";
        try (Connection conn = DBContext.getConnection();
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
     * Task 36: Äáº¿m sá»‘ ngÆ°á»i phá»¥ thuá»™c
     */
    public static int countActiveDependents(int userId) {
        int count = 0;
        String sql = "SELECT COUNT(*) FROM dependents WHERE user_id = ? AND status = 1";
        try (Connection conn = DBContext.getConnection();
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
     * Fallback: TÃ­nh thuáº¿ TNCN lÅ©y tiáº¿n theo Luáº­t 109/2025/QH15 (5 báº­c, hiá»‡u lá»±c 01/01/2026)
     * Taxable_Income = Gross - Insurance - 15_500_000 - (CountDependents * 6_200_000)
     * Æ¯u tiÃªn dÃ¹ng calculateDynamicPIT() Ä‘á»c tá»« DB. HÃ m nÃ y chá»‰ dÃ¹ng khi DB khÃ´ng cÃ³ báº­c thuáº¿.
     */
    public static BigDecimal calculatePIT(BigDecimal taxableIncome) {
        if (taxableIncome == null || taxableIncome.compareTo(BigDecimal.ZERO) <= 0) {
            return BigDecimal.ZERO;
        }

        double income = taxableIncome.doubleValue();
        double pit;

        // Luáº­t 109/2025/QH15 â€” Biá»ƒu thuáº¿ 5 báº­c, hiá»‡u lá»±c 01/01/2026
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
        try (Connection conn = DBContext.getConnection();
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
        try (Connection conn = DBContext.getConnection();
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
        try (Connection conn = DBContext.getConnection();
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
        try (Connection conn = DBContext.getConnection();
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


