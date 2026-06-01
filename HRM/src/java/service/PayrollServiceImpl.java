package service;

import dao.PayrollDAO;
import dao.RewardDisciplineDAO;
import java.math.BigDecimal;
import java.util.List;
import model.EmployeeRewardDiscipline;
import model.Payroll;

public class PayrollServiceImpl implements PayrollService {

    private PayrollDAO payrollDAO = new PayrollDAO();
    private RewardDisciplineDAO rewardDisciplineDAO = new RewardDisciplineDAO();

    @Override
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
        
        payrollDAO.insertOrUpdatePayroll(payroll);
    }

    @Override
    public void calculate13thMonthBonus(int userId, int currentYear) {
        PayrollDAO.EmployeeSalaryInfo info = payrollDAO.getEmployeeSalaryInfo(userId);
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
