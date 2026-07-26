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
        p.setInsuranceBenefit(rs.getBigDecimal("insurance_benefit") != null ? rs.getBigDecimal("insurance_benefit") : BigDecimal.ZERO);
        p.setStatus(rs.getString("status"));
        p.setCreatedAt(rs.getTimestamp("created_at"));
        
        // Đọc 2 cột audit mới — backward-compatible nếu migration chưa chạy
        try {
            BigDecimal insBase = rs.getBigDecimal("insurance_base_amount");
            p.setInsuranceBaseAmount(insBase != null ? insBase : BigDecimal.ZERO);
        } catch (SQLException ignored) {}
        try {
            BigDecimal taxBase = rs.getBigDecimal("taxable_income_base");
            p.setTaxableIncomeBase(taxBase != null ? taxBase : BigDecimal.ZERO);
        } catch (SQLException ignored) {}

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
     * Kiểm tra xem đã có bảng lương nháp (Draft/Pending/Approved/Paid) cho tháng/năm chưa.
     * Dùng để chặn mở khóa bảng công khi đã gen payroll draft.
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

    // Insert hoặc update đầy đủ tất cả cột
    public boolean insertOrUpdatePayroll(Payroll p) {
        String sql = "INSERT INTO payroll " +
                     "(user_id, month, year, base_salary, working_days, overtime_amount, " +
                     " allowance_amount, bonus_amount, deduction_amount, insurance_amount, " +
                     " tax_amount, gross_salary, net_salary, insurance_benefit, " +
                     " insurance_base_amount, taxable_income_base, " +
                     " status, approved_by, approved_at, reject_reason, paid_by, paid_at, payment_note) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) " +
                     "ON DUPLICATE KEY UPDATE " +
                     "base_salary=VALUES(base_salary), working_days=VALUES(working_days), " +
                     "overtime_amount=VALUES(overtime_amount), allowance_amount=VALUES(allowance_amount), " +
                     "bonus_amount=VALUES(bonus_amount), deduction_amount=VALUES(deduction_amount), " +
                     "insurance_amount=VALUES(insurance_amount), tax_amount=VALUES(tax_amount), " +
                     "gross_salary=VALUES(gross_salary), net_salary=VALUES(net_salary), " +
                     "insurance_benefit=VALUES(insurance_benefit), " +
                     "insurance_base_amount=VALUES(insurance_base_amount), " +
                     "taxable_income_base=VALUES(taxable_income_base), " +
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
            ps.setBigDecimal(14, p.getInsuranceBenefit() != null ? p.getInsuranceBenefit() : BigDecimal.ZERO);
            ps.setBigDecimal(15, p.getInsuranceBaseAmount() != null ? p.getInsuranceBaseAmount() : BigDecimal.ZERO);
            ps.setBigDecimal(16, p.getTaxableIncomeBase() != null ? p.getTaxableIncomeBase() : BigDecimal.ZERO);
            ps.setString(17, p.getStatus() != null ? p.getStatus() : "Draft");

            if (p.getApprovedBy() != null) {
                ps.setInt(18, p.getApprovedBy());
            } else {
                ps.setNull(18, java.sql.Types.INTEGER);
            }
            ps.setTimestamp(19, p.getApprovedAt());
            ps.setString(20, p.getRejectReason());

            if (p.getPaidBy() != null) {
                ps.setInt(21, p.getPaidBy());
            } else {
                ps.setNull(21, java.sql.Types.INTEGER);
            }
            ps.setTimestamp(22, p.getPaidAt());
            ps.setString(23, p.getPaymentNote());

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



    public List<Integer> getAllEligibleEmployeeIds(int month, int year) {
        List<Integer> list = new ArrayList<>();
        java.time.LocalDate firstDay = java.time.LocalDate.of(year, month, 1);
        java.time.LocalDate lastDay = firstDay.with(java.time.temporal.TemporalAdjusters.lastDayOfMonth());
        java.sql.Date sqlFirstDay = java.sql.Date.valueOf(firstDay);
        java.sql.Date sqlLastDay = java.sql.Date.valueOf(lastDay);

        // Điều kiện eligibility cho nhân viên status=0:
        // - Còn có attendance / shift trong tháng (đã làm việc thực tế), HOẶC
        // - Hợp đồng lao động còn overlap với tháng (start_date <= lastDay AND end_date >= firstDay)
        //   → bao gồm nhân viên nghỉ giữa tháng (Case 2: end_date trong tháng này)
        //   → loại nhân viên nghỉ trước tháng (Case 1: end_date < firstDay)
        // Không dùng work_history — bảng đó là CV/lý lịch cá nhân, không phản ánh
        // quan hệ hợp đồng lao động thực tế với công ty.
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
                     "               SELECT 1 FROM employee_contracts ec " +
                     "               WHERE ec.user_id = u.user_id " +
                     "                 AND ec.start_date <= ? " +
                     "                 AND (ec.end_date IS NULL OR ec.end_date >= ?) " +
                     "                 AND (ec.actual_end_date IS NULL OR ec.actual_end_date >= ?) " +
                     "           ) " +
                     "           OR EXISTS ( " +
                     "               SELECT 1 FROM employee_rewards_disciplines erd " +
                     "               JOIN reward_disciplines rd ON erd.reward_discipline_id = rd.id " +
                     "               WHERE erd.user_id = u.user_id " +
                     "                 AND rd.name = 'Dismissal' " +
                     "                 AND erd.applied_date >= ? " +
                     "           ) " +
                     "       ) " +
                     "   ) " +
                     "   AND NOT EXISTS ( " +
                     "       SELECT 1 FROM employee_profiles ep2 " +
                     "       JOIN employee_contracts ec2 ON ep2.user_id = ec2.user_id " +
                     "       WHERE ep2.user_id = u.user_id " +
                     "         AND ep2.employment_status_id = 4 " +
                     "         AND ec2.status = 'Terminated' " +
                     "         AND ec2.actual_end_date < ? " +
                     "   )";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            // params: attendance(1-2), shift_assignments(3-4), employee_shifts(5-6),
            //         employee_contracts(7=lastDay, 8=firstDay, 9=firstDay), rewards(10=firstDay), 
            //         not_exists(11=firstDay)
            ps.setDate(1, sqlFirstDay);
            ps.setDate(2, sqlLastDay);
            ps.setDate(3, sqlFirstDay);
            ps.setDate(4, sqlLastDay);
            ps.setDate(5, sqlFirstDay);
            ps.setDate(6, sqlLastDay);
            ps.setDate(7, sqlLastDay);   // ec.start_date <= lastDay
            ps.setDate(8, sqlFirstDay);  // ec.end_date >= firstDay
            ps.setDate(9, sqlFirstDay);  // ec.actual_end_date >= firstDay
            ps.setDate(10, sqlFirstDay); // erd.applied_date >= firstDay
            ps.setDate(11, sqlFirstDay); // ec2.actual_end_date < firstDay

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



    /**
     * Tính tổng phụ cấp tháng theo logic chuẩn.
     * Chỉ đọc phụ cấp thuộc hợp đồng đang hiệu lực HOẶC phụ cấp vận hành (contract_id IS NULL).
     *
     * @param activeContractId  ID của hợp đồng đang active (truyền 0 nếu không có hợp đồng)
     */
    public AllowanceResult calculateAllowances(
            int empId, int activeContractId,
            double actualWorkDays, double standardWorkDays, int month, int year) {
        if (activeContractId <= 0) {
            return new AllowanceResult(BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO);
        }

        int positionId = -1;
        String sqlPos = "SELECT position_id FROM employee_contracts WHERE contract_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sqlPos)) {
            ps.setInt(1, activeContractId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) positionId = rs.getInt("position_id");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        BigDecimal totalAllowance       = BigDecimal.ZERO;
        BigDecimal bhxhBaseFromAllowances  = BigDecimal.ZERO;
        BigDecimal taxableAllowance     = BigDecimal.ZERO;  // phần phụ cấp chịu thuế TNCN

        if (positionId > 0) {
            // SELECT thêm is_taxable để biết phần nào chịu thuế TNCN
            String sql = "SELECT a.amount, a.calculation_type, a.is_bhxh_applied, a.is_taxable " +
                         "FROM position_allowances pa " +
                         "JOIN allowances a ON pa.allowance_id = a.allowance_id " +
                         "WHERE pa.position_id = ? AND a.status = 1";
            try (Connection conn = DBContext.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, positionId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        BigDecimal amount      = rs.getBigDecimal("amount");
                        String calcType        = rs.getString("calculation_type");
                        boolean isBhxhApplied  = rs.getInt("is_bhxh_applied") == 1;
                        boolean isTaxable      = rs.getInt("is_taxable") == 1;

                        if (amount == null) continue;

                        BigDecimal earned;
                        switch (calcType != null ? calcType : "FIXED") {
                            case "PER_DAY" -> {
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
                                boolean hasUnexcused = hasUnexcusedAbsence(empId, month, year);
                                earned = hasUnexcused ? BigDecimal.ZERO : amount;
                            }
                            default -> earned = amount; // FIXED
                        }

                        totalAllowance = totalAllowance.add(earned);
                        if (isBhxhApplied) {
                            bhxhBaseFromAllowances = bhxhBaseFromAllowances.add(earned);
                        }
                        if (isTaxable) {
                            taxableAllowance = taxableAllowance.add(earned);
                        }
                    }
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

        // Add Seniority Allowance
        // TODO: Nếu bảng cấu hình seniority có thêm cột is_bhxh_applied/is_taxable thì đọc từ đó.
        // Hiện tại: mặc định phụ cấp thâm niên là chịu thuế + đóng BHXH (giữ nguyên hành vi cũ)
        AllowanceDAO alwDao = new AllowanceDAO();
        int tenureMonths = alwDao.getTenureMonths(empId);
        BigDecimal seniorityAmount = alwDao.getSeniorityAmount(tenureMonths);
        if (seniorityAmount.compareTo(BigDecimal.ZERO) > 0) {
            totalAllowance = totalAllowance.add(seniorityAmount);
            bhxhBaseFromAllowances = bhxhBaseFromAllowances.add(seniorityAmount); // chịu BHXH
            taxableAllowance = taxableAllowance.add(seniorityAmount);              // chịu thuế
        }

        return new AllowanceResult(totalAllowance, bhxhBaseFromAllowances, taxableAllowance);
    }

    /** Kiểm tra có ngày ABSENT không phép trong tháng không. */
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

    /** Kết quả tính phụ cấp: tổng phụ cấp, phần thuộc nền BHXH, và phần chịu thuế TNCN */
    public static class AllowanceResult {
        public final BigDecimal totalAmount;   // Tổng phụ cấp (hiển thị gross, không dùng để tính BH/thuế)
        public final BigDecimal bhxhBase;      // Phần cộng vào nền BHXH (is_bhxh_applied=1)
        public final BigDecimal taxableBase;   // Phần chịu thuế TNCN (is_taxable=1)
        public AllowanceResult(BigDecimal totalAmount, BigDecimal bhxhBase, BigDecimal taxableBase) {
            this.totalAmount  = totalAmount;
            this.bhxhBase     = bhxhBase;
            this.taxableBase  = taxableBase;
        }
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
                     "insurance_benefit = ?, " +
                     "insurance_base_amount = ?, " +
                     "taxable_income_base = ?, " +
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
            ps.setBigDecimal(11, p.getInsuranceBenefit() != null ? p.getInsuranceBenefit() : BigDecimal.ZERO);
            ps.setBigDecimal(12, p.getInsuranceBaseAmount() != null ? p.getInsuranceBaseAmount() : BigDecimal.ZERO);
            ps.setBigDecimal(13, p.getTaxableIncomeBase() != null ? p.getTaxableIncomeBase() : BigDecimal.ZERO);
            ps.setInt(14, p.getPayrollId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ═══════════════════════════════════════════════════════════════
    // INSURANCE BENEFIT HELPERS
    // ═══════════════════════════════════════════════════════════════

    /** leaveTypeId = 2: Nghỉ ốm hưởng BHXH */
    private static final int SICK_LEAVE_TYPE_ID = 2;

    /**
     * Số ngày bảo hiểm chuẩn để tính trợ cấp nghỉ ốm (quy định: 1 tháng = 24 ngày công BH).
     */
    private static final BigDecimal SICK_BENEFIT_DIVISOR = new BigDecimal("24");

    /**
     * Tính trợ cấp nghỉ ốm (leaveTypeId = 2).
     *
     * <p>Công thức theo Luật BHXH 2014 Điều 26:
     * <pre>
     *   sickBenefit = insuranceBase / 24 × sickRate% × số ngày nghỉ ốm đủ điều kiện
     * </pre>
     *
     * @param insuranceBase  Nền đóng BHXH = baseSalary + phụ cấp/thưởng is_bhxh_applied
     * @param sickDayTypeMap Map ngày nghỉ → leaveTypeId, chỉ lấy ngày có type = SICK_LEAVE_TYPE_ID
     * @param rateMap        leaveTypeId → tỷ lệ % (từ LeaveInsuranceRateDAO.getActiveRateMap)
     * @return Trợ cấp nghỉ ốm, scale 2 HALF_UP
     */
    private BigDecimal calculateInsuranceBenefit(
            BigDecimal insuranceBase,
            Map<LocalDate, Integer> sickDayTypeMap,
            Map<Integer, BigDecimal> rateMap
    ) {
        if (insuranceBase == null || insuranceBase.compareTo(BigDecimal.ZERO) <= 0
                || sickDayTypeMap == null || sickDayTypeMap.isEmpty()
                || rateMap == null || rateMap.isEmpty()) {
            return BigDecimal.ZERO.setScale(2, java.math.RoundingMode.HALF_UP);
        }
        // Trợ cấp 1 ngày nghỉ ốm = insuranceBase / 24 (giữ 8 chữ số để tránh mất mát làm tròn)
        BigDecimal dailyBenefit = insuranceBase.divide(SICK_BENEFIT_DIVISOR, 8, java.math.RoundingMode.HALF_UP);
        BigDecimal sickBenefit  = BigDecimal.ZERO;
        for (Map.Entry<LocalDate, Integer> entry : sickDayTypeMap.entrySet()) {
            if (entry.getValue() == null || entry.getValue() != SICK_LEAVE_TYPE_ID) continue; // Chỉ tính ngày nghỉ ốm
            BigDecimal ratePercent = rateMap.get(SICK_LEAVE_TYPE_ID);
            if (ratePercent == null || ratePercent.compareTo(BigDecimal.ZERO) <= 0) continue;
            BigDecimal multiplier = ratePercent.divide(new BigDecimal("100"), 8, java.math.RoundingMode.HALF_UP);
            sickBenefit = sickBenefit.add(dailyBenefit.multiply(multiplier));
        }
        return sickBenefit.setScale(2, java.math.RoundingMode.HALF_UP);
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
        // Dùng getPayrollStandardWorkDays (trừ cả ngày lễ active) thay vì DateUtil.getStandardWorkDays
        // (chỉ trừ Chủ nhật) để đảm bảo mẫu số ngày công của payroll khớp với
        // số ngày làm việc thực tế (không bao gồm ngày lễ).
        HolidayDAO holidayDAO = new HolidayDAO();
        BigDecimal standardWorkDays = new BigDecimal(holidayDAO.getPayrollStandardWorkDays(month, year));
        // Tải rateMap 1 lần cho toàn bộ batch — tránh query DB lặp lại trong vòng lặp nhân viên
        LeaveInsuranceRateDAO lirDAO = new LeaveInsuranceRateDAO();
        Map<Integer, BigDecimal> insuranceRateMap = lirDAO.getActiveRateMap();
        
        for (int userId : userIds) {
            Payroll existing = getPayroll(userId, month, year);
            if (existing != null && !"Draft".equals(existing.getStatus()) && !"Rejected".equals(existing.getStatus())) {
                result.setSkippedCount(result.getSkippedCount() + 1);
                continue;
            }
            
            // Tự động quét và sinh dữ liệu phạt đi muộn/thưởng chuyên cần trước khi tính lương
            RewardDisciplineDAO rewardDisciplineDAO = new RewardDisciplineDAO();
            rewardDisciplineDAO.deleteAutomatedAttendanceRecords(userId, month, year);
            rewardDisciplineDAO.generateAttendanceAutomations(userId, month, year);
            
            EmployeeSalaryInfo salaryInfo = getEmployeeSalaryInfo(userId);
            int roleId = (salaryInfo != null) ? salaryInfo.roleId : -1;
            
            EmployeeContractDAO ecDAO = new EmployeeContractDAO();
            // Dùng getContractForMonth (truyền firstDay và lastDay của tháng) thay vì getContractAsOf
            // Lý do: nhân viên nghỉ giữa kỳ (Case 2) hoặc hết hạn hợp đồng giữa tháng
            // vẫn cần lấy đúng base_salary/tax_calc_type từ hợp đồng đó để tính lương.
            java.time.LocalDate firstDayLocal = java.time.LocalDate.of(year, month, 1);
            java.time.LocalDate lastDayLocal = firstDayLocal.with(java.time.temporal.TemporalAdjusters.lastDayOfMonth());
            java.sql.Date sqlFirstDayOfMonth = java.sql.Date.valueOf(firstDayLocal);
            java.sql.Date sqlLastDayOfMonth = java.sql.Date.valueOf(lastDayLocal);
            EmployeeContract activeContract = ecDAO.getContractForMonth(userId, sqlFirstDayOfMonth, sqlLastDayOfMonth);
            
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
            // Ngày nghỉ không lương (nghỉ ốm) — dùng chung cho cả Director và nhân viên.
            // Khai báo trước if/else để insuranceBenefit tính bên dưới có thể truy cập.
            Map<LocalDate, Integer> unpaidLeaveDaysForExclusion =
                    leaveDAO.getUnpaidLeaveDayMapWithShift(userId, month, year);

            if (roleId == 4) { // 4 = Director
                // Giám đốc miễn chấm công, auto full công chuẩn
                // Trừ đi ngày nghỉ ốm nếu có (Director cũng có thể nghỉ ốm)
                int sickDays = (unpaidLeaveDaysForExclusion != null) ? unpaidLeaveDaysForExclusion.size() : 0;
                totalDays = standardWorkDays.doubleValue() - sickDays;
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

                // Bước 2b: Lấy Map ngày nghỉ không lương (nghỉ ốm) đã duyệt.
                // Những ngày này KHÔNG được tính vào ngày công hưởng lương thông thường,
                // mà chỉ nhận khoản insuranceBenefit riêng do BHXH chi trả.
                // Phải loại bỏ khỏi unionDayMap trước khi tính totalDays để tránh tính trùng:
                //   VD: import 27 ngày công + 2 ngày nghỉ ốm → totalDays = 25, insuranceBenefit cho 2 ngày.
                // unpaidLeaveDaysForExclusion đã được lấy trước if/else block (Bước 2b)

                // Bước 3: Hợp (union) 2 tập ngày.
                // - Ưu tiên attendance nếu ngày xuất hiện ở cả 2 (số liệu chấm công thực tế hơn).
                // - Ngày chỉ có trong leave (không có bản ghi attendance) được tính 1.0.
                Map<LocalDate, Double> unionDayMap = new HashMap<>(attendanceDayMap);
                for (LocalDate leaveDate : leaveDaySet) {
                    // putIfAbsent: nếu ngày đó đã có trong attendance thì bỏ qua (không đếm trùng)
                    unionDayMap.putIfAbsent(leaveDate, 1.0);
                }

                // Bước 3b: Loại bỏ ngày nghỉ không lương (nghỉ ốm) khỏi tập ngày công.
                // Ngày nghỉ ốm chỉ được trả qua insuranceBenefit, không phải lương thường.
                // Nếu data chấm công gốc vẫn ghi nhận ngày ốm là "Present" thì phải trừ ra.
                if (unpaidLeaveDaysForExclusion != null && !unpaidLeaveDaysForExclusion.isEmpty()) {
                    for (LocalDate sickDay : unpaidLeaveDaysForExclusion.keySet()) {
                        unionDayMap.remove(sickDay);
                    }
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
            
            // insuranceBenefit được tính SAU khi insuranceBase có giá trị (xem bên dưới)
            
            // Tính lương 1 giờ dựa trên số giờ làm việc thực tế của tháng (standardWorkDays * 8h)
            // thay vì chia cứng cho 176 giờ.
            BigDecimal hourlyRate = BigDecimal.ZERO;
            if (baseSalary.compareTo(BigDecimal.ZERO) > 0 && standardWorkDays.compareTo(BigDecimal.ZERO) > 0) {
                BigDecimal monthlyWorkingHours = standardWorkDays.multiply(new BigDecimal("8"));
                hourlyRate = baseSalary.divide(monthlyWorkingHours, 4, java.math.RoundingMode.HALF_UP);
            }
            
            BigDecimal overtimeHours = attendanceDAO.getTotalOvertimeHoursFromAttendance(userId, month, year);
            BigDecimal overtimeAmount = attendanceDAO.getOvertimeAmountWithHolidayRate(userId, month, year, hourlyRate, new BigDecimal("1.5"));

            // Tính phụ cấp: chỉ lấy khoản thuộc hợp đồng đang hiệu lực HOẶC phụ cấp vận hành (contract_id IS NULL)
            int activeContractId = (activeContract != null) ? activeContract.getContractId() : 0;
            AllowanceResult allowanceResult = calculateAllowances(
                userId, activeContractId, totalDays, standardWorkDays.doubleValue(), month, year);
            BigDecimal allowanceAmount = allowanceResult.totalAmount;

            // ── Thưởng / Kỷ luật ──
            // Tách thành 3 biến để biết phần nào tính vào nền BHXH và nền thuế TNCN:
            //   bonusAmount        = tổng thưởng thực nhận (đưa vào gross, hiển thị phiếu lương)
            //   bonusTaxableAmount = phần thưởng chịu thuế TNCN (is_taxable=1)
            //   bonusBhxhAmount    = phần thưởng cộng vào nền BHXH (is_bhxh_applied=1, thường = 0)

            List<EmployeeRewardDiscipline> erdRecords = rewardDisciplineDAO.getRecordsByUserIdAndMonthYear(userId, month, year);
            BigDecimal bonusAmount              = BigDecimal.ZERO;
            BigDecimal bonusTaxableAmount       = BigDecimal.ZERO;
            BigDecimal bonusBhxhAmount          = BigDecimal.ZERO;
            BigDecimal disciplineDeductionAmount = BigDecimal.ZERO;
            for (EmployeeRewardDiscipline erd : erdRecords) {
                if ("Reward".equalsIgnoreCase(erd.getType())) {
                    BigDecimal amt = erd.getAmount() != null ? erd.getAmount() : BigDecimal.ZERO;
                    bonusAmount = bonusAmount.add(amt);
                    if (erd.isTaxable())      bonusTaxableAmount = bonusTaxableAmount.add(amt);
                    if (erd.isBhxhApplied())  bonusBhxhAmount    = bonusBhxhAmount.add(amt);
                } else if ("Discipline".equalsIgnoreCase(erd.getType())) {
                    disciplineDeductionAmount = disciplineDeductionAmount.add(
                        erd.getAmount() != null ? erd.getAmount() : BigDecimal.ZERO);
                }
            }

            // ── Nền đóng BHXH (insuranceBase) ──
            // = lương cơ bản (từ hợp đồng) + phần phụ cấp is_bhxh_applied=1 + phần thưởng is_bhxh_applied=1
            // Theo quy định: OT KHÔNG tính vào nền BHXH.
            BigDecimal insuranceBase = baseSalary
                    .add(allowanceResult.bhxhBase)
                    .add(bonusBhxhAmount);
            BigDecimal insuranceAmount = calculateInsurance(insuranceBase);

            // ── Trợ cấp BHXH (insuranceBenefit) ──
            // Nghỉ ốm (type 2): insuranceBase / 24 × rate% × số ngày nghỉ ốm
            BigDecimal insuranceBenefit = calculateInsuranceBenefit(
                    insuranceBase, unpaidLeaveDaysForExclusion, insuranceRateMap);


            // ── Gross Salary = tổng đầy đủ thực nhận (hiển thị phiếu lương) ──
            BigDecimal grossSalary = baseWorkedSalary.add(allowanceAmount).add(overtimeAmount).add(bonusAmount);

            // ── Thu nhập chịu thuế TNCN (taxableIncomeBeforeDeduction) ──
            // = lương theo công + OT + phụ cấp is_taxable=1 + thưởng is_taxable=1
            // KHÔNG bao gồm phụ cấp/thưởng miễn thuế (VD: ăn trưa, đi lại, thưởng KPI/năng suất)
            BigDecimal taxableIncomeBeforeDeduction = baseWorkedSalary
                    .add(overtimeAmount)
                    .add(allowanceResult.taxableBase)
                    .add(bonusTaxableAmount);

            // Calculate Taxable Income = TaxableBase - Insurance - PersonalDeduction - DependentDeductions
            TaxProfileInfo taxProfile = getTaxProfile(userId);
            BigDecimal totalDeductionForTax = insuranceAmount.add(taxProfile.personalDeduction)
                .add(taxProfile.dependentDeduction.multiply(new BigDecimal(taxProfile.dependentCount)));

            BigDecimal taxableIncome = taxableIncomeBeforeDeduction.subtract(totalDeductionForTax);
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
            // NET = GROSS - TOTAL DEDUCTIONS + INSURANCE BENEFIT
            BigDecimal netSalary = grossSalary.subtract(totalDeductions).add(insuranceBenefit);
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
            p.setInsuranceBenefit(insuranceBenefit);
            // Lưu breakdown audit để hiển thị phiếu lương và kiểm tra sau này
            p.setInsuranceBaseAmount(insuranceBase);
            p.setTaxableIncomeBase(taxableIncomeBeforeDeduction.subtract(insuranceAmount).max(BigDecimal.ZERO));
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
     * TASK 2: Viết lại updatePayrollDraft — tự động tính lại Thuế TNCN và Bảo hiểm
     * khi HR thay đổi thưởng, phụ cấp hoặc phạt.
     *
     * HR chỉ nhập: workingDays, overtimeAmount, allowanceAmount, bonusAmount, deductionAmount
     * Hệ thống tự tính: insurance, tax (PIT), gross, net
     */
    public boolean updatePayrollDraft(Payroll payroll) {
        if (payroll == null) return false;
        Payroll current = getById(payroll.getPayrollId());
        if (current == null) return false;

        String currentStatus = current.getStatus();
        if (!"Draft".equals(currentStatus) && !"Rejected".equals(currentStatus)) {
            return false;
        }

        // --- Lấy giá trị HR nhập (hoặc giữ nguyên từ bản ghi hiện tại) ---
        BigDecimal baseSalary = current.getBaseSalary() != null ? current.getBaseSalary() : BigDecimal.ZERO;
        BigDecimal overtime   = payroll.getOvertimeAmount()   != null ? payroll.getOvertimeAmount()   : BigDecimal.ZERO;
        BigDecimal allowance  = payroll.getAllowanceAmount()  != null ? payroll.getAllowanceAmount()  : BigDecimal.ZERO;
        BigDecimal bonus      = payroll.getBonusAmount()      != null ? payroll.getBonusAmount()      : BigDecimal.ZERO;
        BigDecimal deduction  = payroll.getDeductionAmount()  != null ? payroll.getDeductionAmount()  : BigDecimal.ZERO;

        // --- Tính lương theo ngày công thực tế ---
        // Dùng getPayrollStandardWorkDays để mẫu số trừ cả ngày lễ active như generatePayrollDraft.
        HolidayDAO holidayDAO = new HolidayDAO();
        int payrollStdDays = holidayDAO.getPayrollStandardWorkDays(current.getMonth(), current.getYear());
        BigDecimal standardWorkDays = new BigDecimal(payrollStdDays);

        // Guard: HR không được nhập ngày công vượt quá ngày công chuẩn của kỳ lương.
        // Lý do: đi làm ngày lễ/Chủ nhật chỉ được tính OT, không tính thêm ngày công.
        if (payrollStdDays > 0 && payroll.getWorkingDays() > payrollStdDays) {
            throw new IllegalArgumentException(
                "Ngày công không được vượt quá ngày công chuẩn của kỳ lương (" + payrollStdDays + " ngày)."
            );
        }
        BigDecimal baseWorkedSalary = BigDecimal.ZERO;
        if (standardWorkDays.compareTo(BigDecimal.ZERO) > 0) {
            BigDecimal daysRatio = new BigDecimal(payroll.getWorkingDays())
                    .divide(standardWorkDays, 4, java.math.RoundingMode.HALF_UP);
            baseWorkedSalary = baseSalary.multiply(daysRatio).setScale(2, java.math.RoundingMode.HALF_UP);
        }

        // --- Lấy breakdown taxable/bhxh từ DB gốc (không tin tưởng số HR nhập tạy cho mục đích này) ---
        // Lý do: allowance và bonus HR nhập là số tổng (override), không biết tỷ lệ miễn thuế/BH.
        // Giải pháp: dung breakdown từ DB gốc cho nền BH/thuế; giá trị HR nhập chỉ dùng cho gross hiển thị.
        int activeContractId = 0;
        EmployeeContractDAO ecDAO = new EmployeeContractDAO();
        java.time.LocalDate firstDayLocal = java.time.LocalDate.of(current.getYear(), current.getMonth(), 1);
        java.time.LocalDate lastDayLocal  = firstDayLocal.with(java.time.temporal.TemporalAdjusters.lastDayOfMonth());
        EmployeeContract activeContract = ecDAO.getContractForMonth(
            current.getUserId(),
            java.sql.Date.valueOf(firstDayLocal),
            java.sql.Date.valueOf(lastDayLocal));
        if (activeContract != null) activeContractId = activeContract.getContractId();

        AllowanceResult allowanceResult = calculateAllowances(
            current.getUserId(), activeContractId,
            payroll.getWorkingDays(), standardWorkDays.doubleValue(),
            current.getMonth(), current.getYear());

        RewardDisciplineDAO rewardDisciplineDAO = new RewardDisciplineDAO();
        List<EmployeeRewardDiscipline> erdRecords = rewardDisciplineDAO
            .getRecordsByUserIdAndMonthYear(current.getUserId(), current.getMonth(), current.getYear());
        BigDecimal bonusTaxableAmount = BigDecimal.ZERO;
        BigDecimal bonusBhxhAmount    = BigDecimal.ZERO;
        for (EmployeeRewardDiscipline erd : erdRecords) {
            if ("Reward".equalsIgnoreCase(erd.getType())) {
                BigDecimal amt = erd.getAmount() != null ? erd.getAmount() : BigDecimal.ZERO;
                if (erd.isTaxable())     bonusTaxableAmount = bonusTaxableAmount.add(amt);
                if (erd.isBhxhApplied()) bonusBhxhAmount    = bonusBhxhAmount.add(amt);
            }
        }

        // --- Nền đóng BHXH: baseSalary + phụ cấp is_bhxh_applied=1 + thưởng is_bhxh_applied=1 ---
        BigDecimal insuranceBase = baseSalary
                .add(allowanceResult.bhxhBase)
                .add(bonusBhxhAmount);
        BigDecimal insuranceAmount = calculateInsurance(insuranceBase);

        // --- Gross = số HR nhập (hoặc có thể override) — dùng cho hiển thị phiếu lương ---
        BigDecimal grossSalary = baseWorkedSalary.add(overtime).add(allowance).add(bonus);

        // --- Thu nhập chịu thuế: dùng breakdown từ DB, không dùng gross HR nhập ---
        BigDecimal taxableIncomeBeforeDeduction = baseWorkedSalary
                .add(overtime)
                .add(allowanceResult.taxableBase)
                .add(bonusTaxableAmount);

        // --- Tự động tính Thuế TNCN (PIT) lũy tiến ---
        TaxProfileInfo taxProfile = getTaxProfile(current.getUserId());
        BigDecimal totalDeductionForTax = insuranceAmount
                .add(taxProfile.personalDeduction)
                .add(taxProfile.dependentDeduction.multiply(new BigDecimal(taxProfile.dependentCount)));
        BigDecimal taxableIncome = taxableIncomeBeforeDeduction.subtract(totalDeductionForTax);
        if (taxableIncome.compareTo(BigDecimal.ZERO) < 0) {
            taxableIncome = BigDecimal.ZERO;
        }
        BigDecimal taxAmount = calculateDynamicPIT(taxableIncome);

        // ─── Tính trợ cấp BHXH cho các ngày nghỉ không lương ───
        // Nghỉ ốm (type 2): insuranceBase / 24 × rate% × số ngày
        LeaveRequestDAOImpl leaveDAO = new LeaveRequestDAOImpl();
        Map<LocalDate, Integer> unpaidLeaves = leaveDAO.getUnpaidLeaveDayMapWithShift(
            current.getUserId(), current.getMonth(), current.getYear());
        LeaveInsuranceRateDAO lirDAO = new LeaveInsuranceRateDAO();
        Map<Integer, BigDecimal> rateMap = lirDAO.getActiveRateMap();

        BigDecimal insuranceBenefit = calculateInsuranceBenefit(
                insuranceBase, unpaidLeaves, rateMap);

        // --- Tính Net Salary ---
        BigDecimal totalDeductions = deduction.add(insuranceAmount).add(taxAmount);
        BigDecimal netSalary = grossSalary.subtract(totalDeductions).add(insuranceBenefit);
        if (netSalary.compareTo(BigDecimal.ZERO) < 0) {
            netSalary = BigDecimal.ZERO;
        }

        // --- Cập nhật vào payroll object để controller có thể trả về ---
        payroll.setBaseSalary(baseSalary);
        payroll.setInsuranceAmount(insuranceAmount);
        payroll.setTaxAmount(taxAmount);
        payroll.setGrossSalary(grossSalary);
        payroll.setNetSalary(netSalary);
        payroll.setInsuranceBenefit(insuranceBenefit);
        payroll.setInsuranceBaseAmount(insuranceBase);
        payroll.setTaxableIncomeBase(taxableIncomeBeforeDeduction.subtract(insuranceAmount).max(BigDecimal.ZERO));

        String sql = "UPDATE payroll SET " +
                     "working_days = ?, " +
                     "overtime_amount = ?, " +
                     "allowance_amount = ?, " +
                     "bonus_amount = ?, " +
                     "deduction_amount = ?, " +
                     "insurance_amount = ?, " +
                     "tax_amount = ?, " +
                     "gross_salary = ?, " +
                     "net_salary = ?, " +
                     "insurance_benefit = ?, " +
                     "insurance_base_amount = ?, " +
                     "taxable_income_base = ? " +
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
            ps.setBigDecimal(10, insuranceBenefit);
            ps.setBigDecimal(11, insuranceBase);
            ps.setBigDecimal(12, payroll.getTaxableIncomeBase());
            ps.setInt(13, payroll.getPayrollId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * TASK 2: Tính toán preview khi HR thay đổi giá trị (dùng cho AJAX recalculate)
     * Trả về Payroll object với các giá trị insurance, tax, gross, net đã tính sẵn.
     * KHÔNG lưu vào DB.
     *
     * Lưu ý: allowanceAmount và bonusAmount đưa vào đây là số tổng HR nhập tay.
     * Để đảm bảo tính đúng nền BHXH và thuế, breakdown taxable/bhxh được tính lại từ DB gốc.
     */
    public Payroll recalculatePayrollPreview(int payrollId, BigDecimal overtimeAmount,
            BigDecimal allowanceAmount, BigDecimal bonusAmount, BigDecimal deductionAmount) {
        Payroll current = getById(payrollId);
        if (current == null) return null;

        BigDecimal baseSalary     = current.getBaseSalary()      != null ? current.getBaseSalary()      : BigDecimal.ZERO;
        BigDecimal overtime       = overtimeAmount               != null ? overtimeAmount               : BigDecimal.ZERO;
        BigDecimal allowance      = allowanceAmount              != null ? allowanceAmount              : BigDecimal.ZERO;
        BigDecimal bonus          = bonusAmount                  != null ? bonusAmount                  : BigDecimal.ZERO;
        BigDecimal deduction      = deductionAmount              != null ? deductionAmount              : BigDecimal.ZERO;
        BigDecimal insuranceBenefit = current.getInsuranceBenefit() != null ? current.getInsuranceBenefit() : BigDecimal.ZERO;

        // Tính baseWorkedSalary đúng: baseSalary * (workingDays / standardWorkDays)
        // Dùng getPayrollStandardWorkDays để mẫu số khớp với generatePayrollDraft.
        HolidayDAO holidayDAO = new HolidayDAO();
        BigDecimal standardWorkDays = new BigDecimal(holidayDAO.getPayrollStandardWorkDays(current.getMonth(), current.getYear()));
        BigDecimal baseWorkedSalary = BigDecimal.ZERO;
        if (standardWorkDays.compareTo(BigDecimal.ZERO) > 0 && current.getWorkingDays() > 0) {
            BigDecimal daysRatio = new BigDecimal(current.getWorkingDays())
                    .divide(standardWorkDays, 4, java.math.RoundingMode.HALF_UP);
            baseWorkedSalary = baseSalary.multiply(daysRatio).setScale(2, java.math.RoundingMode.HALF_UP);
        }

        // Lấy breakdown taxable/bhxh từ DB gốc
        int activeContractId = 0;
        EmployeeContractDAO ecDAO = new EmployeeContractDAO();
        java.time.LocalDate firstDayLocal = java.time.LocalDate.of(current.getYear(), current.getMonth(), 1);
        java.time.LocalDate lastDayLocal  = firstDayLocal.with(java.time.temporal.TemporalAdjusters.lastDayOfMonth());
        EmployeeContract activeContract = ecDAO.getContractForMonth(
            current.getUserId(),
            java.sql.Date.valueOf(firstDayLocal),
            java.sql.Date.valueOf(lastDayLocal));
        if (activeContract != null) activeContractId = activeContract.getContractId();

        AllowanceResult allowanceResult = calculateAllowances(
            current.getUserId(), activeContractId,
            current.getWorkingDays(), standardWorkDays.doubleValue(),
            current.getMonth(), current.getYear());

        RewardDisciplineDAO rewardDisciplineDAO = new RewardDisciplineDAO();
        List<EmployeeRewardDiscipline> erdRecords = rewardDisciplineDAO
            .getRecordsByUserIdAndMonthYear(current.getUserId(), current.getMonth(), current.getYear());
        BigDecimal bonusTaxableAmount = BigDecimal.ZERO;
        BigDecimal bonusBhxhAmount    = BigDecimal.ZERO;
        for (EmployeeRewardDiscipline erd : erdRecords) {
            if ("Reward".equalsIgnoreCase(erd.getType())) {
                BigDecimal amt = erd.getAmount() != null ? erd.getAmount() : BigDecimal.ZERO;
                if (erd.isTaxable())     bonusTaxableAmount = bonusTaxableAmount.add(amt);
                if (erd.isBhxhApplied()) bonusBhxhAmount    = bonusBhxhAmount.add(amt);
            }
        }

        // Nền BHXH = baseSalary + phần phụ cấp is_bhxh_applied=1 + phần thưởng is_bhxh_applied=1
        BigDecimal insuranceBase = baseSalary
                .add(allowanceResult.bhxhBase)
                .add(bonusBhxhAmount);
        BigDecimal insuranceAmount = calculateInsurance(insuranceBase);

        // Gross = tổng đầy đủ (số HR nhập)
        BigDecimal grossSalary = baseWorkedSalary.add(overtime).add(allowance).add(bonus);

        // Thu nhập chịu thuế = breakdown từ DB, không dùng gross HR nhập
        BigDecimal taxableIncomeBeforeDeduction = baseWorkedSalary
                .add(overtime)
                .add(allowanceResult.taxableBase)
                .add(bonusTaxableAmount);

        TaxProfileInfo taxProfile = getTaxProfile(current.getUserId());
        BigDecimal totalDeductionForTax = insuranceAmount
                .add(taxProfile.personalDeduction)
                .add(taxProfile.dependentDeduction.multiply(new BigDecimal(taxProfile.dependentCount)));
        BigDecimal taxableIncome = taxableIncomeBeforeDeduction.subtract(totalDeductionForTax);
        if (taxableIncome.compareTo(BigDecimal.ZERO) < 0) {
            taxableIncome = BigDecimal.ZERO;
        }
        BigDecimal taxAmount = calculateDynamicPIT(taxableIncome);

        BigDecimal totalDeductions = deduction.add(insuranceAmount).add(taxAmount);
        BigDecimal netSalary = grossSalary.subtract(totalDeductions).add(insuranceBenefit);
        if (netSalary.compareTo(BigDecimal.ZERO) < 0) {
            netSalary = BigDecimal.ZERO;
        }

        Payroll preview = new Payroll();
        preview.setPayrollId(payrollId);
        preview.setUserId(current.getUserId());
        preview.setMonth(current.getMonth());
        preview.setYear(current.getYear());
        preview.setBaseSalary(baseSalary);
        preview.setWorkingDays(current.getWorkingDays());
        preview.setOvertimeAmount(overtime);
        preview.setAllowanceAmount(allowance);
        preview.setBonusAmount(bonus);
        preview.setDeductionAmount(deduction);
        preview.setInsuranceAmount(insuranceAmount);
        preview.setTaxAmount(taxAmount);
        preview.setGrossSalary(grossSalary);
        preview.setNetSalary(netSalary);
        preview.setInsuranceBenefit(insuranceBenefit);
        preview.setInsuranceBaseAmount(insuranceBase);
        preview.setTaxableIncomeBase(taxableIncomeBeforeDeduction);
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



    public int submitMonthlyPayrollForApproval(int month, int year) {
        if (month < 1 || month > 12 || year < 2000) {
            throw new IllegalArgumentException("Tháng hoặc năm không hợp lệ");
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
     * Kế toán xác nhận đã chuyển khoản cho TẤT CẢ nhân viên có status=Approved trong tháng (có tracking)
     * @return số bản ghi được cập nhật
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

    // ═════════════════════════════════════════════════════
    // TASK 24: Director Approve / Reject Payroll (Verified -> Approved/Rejected)
    // ═════════════════════════════════════════════════════

    /**
     * Director duyệt 1 bảng lương: Verified → Approved
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
     * Director từ chối 1 bảng lương: Verified → Rejected
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
     * Director duyệt TẤT CẢ bảng lương Verified trong tháng
     * @return số bản ghi được duyệt
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

    // ═════════════════════════════════════════════════════
    // HR Manager Approve / Reject Payroll (Pending -> Verified/Rejected)
    // ═════════════════════════════════════════════════════

    /**
     * HR Manager duyệt 1 bảng lương: Pending → Verified
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
     * HR Manager từ chối 1 bảng lương: Pending → Rejected
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
     * HR Manager duyệt TẤT CẢ bảng lương Pending trong tháng
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
     * Lấy danh sách payroll theo tháng/năm kèm tên nhân viên (JOIN users)
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
     * Đếm số lượng payroll theo status trong 1 tháng
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
     * Kế toán mark paid với tracking (paid_by, paid_at)
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
     * Lấy danh sách payroll của 1 nhân viên kèm filter status (cho employee xem payslip)
     * Chỉ trả về Approved hoặc Paid
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

    /**
     * Báo cáo Bảng lương Tổng hợp — dành cho HR Manager / Director / Admin xem.
     * JOIN users + departments + employee_profiles (bank info).
     * Mặc định lọc status IN ('Approved','Paid') — dữ liệu đã chốt cuối kỳ.
     *
     * @param month        tháng báo cáo
     * @param year         năm báo cáo
     * @param departmentId null = tất cả phòng ban; số = lọc phòng ban cụ thể
     */
    public List<Payroll> getMasterPayrollReport(int month, int year, Integer departmentId) {
        List<Payroll> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT p.*, u.full_name, u.department_id, d.department_name, " +
            "       ep.bank_account, ep.bank_name " +
            "FROM payroll p " +
            "LEFT JOIN users u ON p.user_id = u.user_id " +
            "LEFT JOIN departments d ON u.department_id = d.department_id " +
            "LEFT JOIN employee_profiles ep ON p.user_id = ep.user_id " +
            "WHERE p.month = ? AND p.year = ? " +
            "  AND p.status IN ('Approved', 'Paid')"
        );
        if (departmentId != null) {
            sql.append(" AND u.department_id = ?");
        }
        sql.append(" ORDER BY d.department_name, u.full_name");

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            ps.setInt(1, month);
            ps.setInt(2, year);
            if (departmentId != null) {
                ps.setInt(3, departmentId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Payroll p = mapRow(rs);
                    p.setFullName(rs.getString("full_name"));
                    p.setBankAccount(rs.getString("bank_account"));
                    p.setBankName(rs.getString("bank_name"));
                    try {
                        p.setDepartmentName(rs.getString("department_name"));
                    } catch (SQLException ignored) {}
                    list.add(p);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }


    // TAX & INSURANCE ENGINE (TASK 35 & 36)
    // ═════════════════════════════════════════════════════

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
     * Task 36: Đếm số người phụ thuộc
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


