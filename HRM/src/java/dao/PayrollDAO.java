package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import model.Payroll;
import util.DBContext;

import java.sql.Date;

public class PayrollDAO {

    public static class EmployeeSalaryInfo {
        public Date hireDate;
        public java.math.BigDecimal baseSalary;
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
                    info.hireDate = rs.getDate("hire_date");
                    info.baseSalary = rs.getBigDecimal("base_salary");
                    return info;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean insertOrUpdatePayroll(Payroll p) {
        String sql = "INSERT INTO payroll (user_id, month, year, base_salary, bonus_amount, deduction_amount, gross_salary, net_salary) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?) " +
                     "ON DUPLICATE KEY UPDATE base_salary=?, bonus_amount=?, deduction_amount=?, gross_salary=?, net_salary=?";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, p.getUserId());
            ps.setInt(2, p.getMonth());
            ps.setInt(3, p.getYear());
            ps.setBigDecimal(4, p.getBaseSalary());
            ps.setBigDecimal(5, p.getBonusAmount());
            ps.setBigDecimal(6, p.getDeductionAmount());
            ps.setBigDecimal(7, p.getGrossSalary());
            ps.setBigDecimal(8, p.getNetSalary());
            
            ps.setBigDecimal(9, p.getBaseSalary());
            ps.setBigDecimal(10, p.getBonusAmount());
            ps.setBigDecimal(11, p.getDeductionAmount());
            ps.setBigDecimal(12, p.getGrossSalary());
            ps.setBigDecimal(13, p.getNetSalary());
            
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
                if (rs.next()) {
                    Payroll p = new Payroll();
                    p.setPayrollId(rs.getInt("payroll_id"));
                    p.setUserId(rs.getInt("user_id"));
                    p.setMonth(rs.getInt("month"));
                    p.setYear(rs.getInt("year"));
                    p.setBaseSalary(rs.getBigDecimal("base_salary"));
                    p.setBonusAmount(rs.getBigDecimal("bonus_amount"));
                    p.setDeductionAmount(rs.getBigDecimal("deduction_amount"));
                    p.setGrossSalary(rs.getBigDecimal("gross_salary"));
                    p.setNetSalary(rs.getBigDecimal("net_salary"));
                    return p;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
}
