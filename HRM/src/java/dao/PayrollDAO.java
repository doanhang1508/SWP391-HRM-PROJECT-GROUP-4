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
import model.Payroll;
import util.DBContext;
import java.sql.Date;

public class PayrollDAO {

    public static class EmployeeSalaryInfo {
        public Date hireDate;
        public BigDecimal baseSalary;
    }

    // Helper map đầy đủ tất cả cột DB
    private Payroll mapRow(ResultSet rs) throws SQLException {
        Payroll p = new Payroll();
        p.setPayrollId(rs.getInt("payroll_id"));
        p.setUserId(rs.getInt("user_id"));
        p.setMonth(rs.getInt("month"));
        p.setYear(rs.getInt("year"));
        p.setBaseSalary(rs.getBigDecimal("base_salary"));
        p.setWorkingDays(rs.getInt("working_days"));
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
        return p;
    }

    public EmployeeSalaryInfo getEmployeeSalaryInfo(int userId) {
        String sql = "SELECT ep.hire_date, sg.base_salary " +
                     "FROM employee_profiles ep " +
                     "JOIN salary_grades sg ON ep.salary_grade_id = sg.salary_grade_id " +
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
                    return info;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // Insert hoặc update đầy đủ tất cả cột
    public boolean insertOrUpdatePayroll(Payroll p) {
        String sql = "INSERT INTO payroll " +
                     "(user_id, month, year, base_salary, working_days, overtime_amount, " +
                     " allowance_amount, bonus_amount, deduction_amount, insurance_amount, " +
                     " tax_amount, gross_salary, net_salary, status) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) " +
                     "ON DUPLICATE KEY UPDATE " +
                     "base_salary=VALUES(base_salary), working_days=VALUES(working_days), " +
                     "overtime_amount=VALUES(overtime_amount), allowance_amount=VALUES(allowance_amount), " +
                     "bonus_amount=VALUES(bonus_amount), deduction_amount=VALUES(deduction_amount), " +
                     "insurance_amount=VALUES(insurance_amount), tax_amount=VALUES(tax_amount), " +
                     "gross_salary=VALUES(gross_salary), net_salary=VALUES(net_salary), " +
                     "status=VALUES(status)";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, p.getUserId());
            ps.setInt(2, p.getMonth());
            ps.setInt(3, p.getYear());
            ps.setBigDecimal(4, p.getBaseSalary() != null ? p.getBaseSalary() : BigDecimal.ZERO);
            ps.setInt(5, p.getWorkingDays());
            ps.setBigDecimal(6, p.getOvertimeAmount() != null ? p.getOvertimeAmount() : BigDecimal.ZERO);
            ps.setBigDecimal(7, p.getAllowanceAmount() != null ? p.getAllowanceAmount() : BigDecimal.ZERO);
            ps.setBigDecimal(8, p.getBonusAmount() != null ? p.getBonusAmount() : BigDecimal.ZERO);
            ps.setBigDecimal(9, p.getDeductionAmount() != null ? p.getDeductionAmount() : BigDecimal.ZERO);
            ps.setBigDecimal(10, p.getInsuranceAmount() != null ? p.getInsuranceAmount() : BigDecimal.ZERO);
            ps.setBigDecimal(11, p.getTaxAmount() != null ? p.getTaxAmount() : BigDecimal.ZERO);
            ps.setBigDecimal(12, p.getGrossSalary() != null ? p.getGrossSalary() : BigDecimal.ZERO);
            ps.setBigDecimal(13, p.getNetSalary() != null ? p.getNetSalary() : BigDecimal.ZERO);
            ps.setString(14, p.getStatus() != null ? p.getStatus() : "draft");
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

    // --- Merged from Service ---


    private RewardDisciplineDAO rewardDisciplineDAO = new RewardDisciplineDAO();

    public void calculateMonthlyPayroll(int userId, int month, int year) {
        List<EmployeeRewardDiscipline> records = rewardDisciplineDAO.getRecordsByUserIdAndMonthYear(userId, month, year);
        
        BigDecimal totalBonus = BigDecimal.ZERO;
        BigDecimal totalDeduction = BigDecimal.ZERO;
        
        for (EmployeeRewardDiscipline rec : records) {
            if ("Reward".equalsIgnoreCase(rec.getType())) {
                totalBonus = totalBonus.add(rec.getAmount());
            } else if ("Discipline".equalsIgnoreCase(rec.getType())) {
                totalDeduction = totalDeduction.add(rec.getAmount());
            }
        }
        
        // Mocking Base Salary - in a real app, fetch from User/Contract
        BigDecimal baseSalary = new BigDecimal("10000000"); 
        BigDecimal grossSalary = baseSalary.add(totalBonus);
        
        // 30% Legal Guardrail
        // Max Allowable Deduction = (Gross Salary - Insurance - Tax) * 0.30
        BigDecimal maxAllowableDeduction = grossSalary.multiply(new BigDecimal("0.30"));
        
        if (totalDeduction.compareTo(maxAllowableDeduction) > 0) {
            BigDecimal rolloverAmount = totalDeduction.subtract(maxAllowableDeduction);
            totalDeduction = maxAllowableDeduction;
            
            // Roll over balance to the next month
            model.RewardDiscipline rdRollover = rewardDisciplineDAO.getRewardDisciplineByName("Rolled Over Deduction");
            int rolloverTypeId = (rdRollover != null) ? rdRollover.getId() : 1; // Default to existing ID
            
            java.time.LocalDate nextMonthDate = java.time.LocalDate.of(year, month, 1).plusMonths(1);
            
            EmployeeRewardDiscipline rolloverRecord = new EmployeeRewardDiscipline();
            rolloverRecord.setUserId(userId);
            rolloverRecord.setRewardDisciplineId(rolloverTypeId);
            rolloverRecord.setAmount(rolloverAmount);
            rolloverRecord.setNote("Rolled over deduction from " + month + "/" + year);
            rolloverRecord.setAppliedDate(java.sql.Date.valueOf(nextMonthDate));
            
            rewardDisciplineDAO.insertManualRecord(rolloverRecord);
        }
        
        BigDecimal netSalary = grossSalary.subtract(totalDeduction);
        
        Payroll payroll = new Payroll();
        payroll.setUserId(userId);
        payroll.setMonth(month);
        payroll.setYear(year);
        payroll.setBaseSalary(baseSalary);
        payroll.setBonusAmount(totalBonus);
        payroll.setDeductionAmount(totalDeduction);
        payroll.setGrossSalary(grossSalary);
        payroll.setNetSalary(netSalary);
        
        this.insertOrUpdatePayroll(payroll);
    }

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

}



