package service;

import dao.RewardDisciplineDAO;
import dao.ShiftDAO;
import dao.ShiftDAOImpl;
import java.math.BigDecimal;
import java.sql.Date;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.temporal.ChronoUnit;
import java.util.List;
import model.Attendance;
import model.EmployeeRewardDiscipline;
import model.RewardDiscipline;
import model.Shift;

public class RewardDisciplineServiceImpl implements RewardDisciplineService {

    private RewardDisciplineDAO rewardDisciplineDAO = new RewardDisciplineDAO();
    private ShiftDAO shiftDAO = new ShiftDAOImpl();

    @Override
    public int generateAttendanceAutomations(int userId, int month, int year) {
        List<Attendance> attendances = rewardDisciplineDAO.getAttendanceByUserIdAndMonth(userId, month, year);
        int lateCount = 0;
        int validPresentDays = 0;
        int insertedCount = 0;
        
        for (Attendance a : attendances) {
            if ("Present".equalsIgnoreCase(a.getStatus())) {
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
                        
                        RewardDiscipline rdLate = rewardDisciplineDAO.getRewardDisciplineByName("Đi muộn/Về sớm");
                        
                        EmployeeRewardDiscipline erd = new EmployeeRewardDiscipline();
                        erd.setUserId(userId);
                        erd.setRewardDisciplineId(rdLate != null ? rdLate.getId() : 4);
                        erd.setAmount(deductionAmount);
                        erd.setNote("Late for " + lateMinutes + " minutes");
                        erd.setAppliedDate(a.getWorkDate());
                        if (rewardDisciplineDAO.insertManualRecord(erd)) {
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
             RewardDiscipline rdPenalty = rewardDisciplineDAO.getRewardDisciplineByName("Đi muộn/Về sớm");
             EmployeeRewardDiscipline erd = new EmployeeRewardDiscipline();
             erd.setUserId(userId);
             erd.setRewardDisciplineId(rdPenalty != null ? rdPenalty.getId() : 4);
             erd.setAmount(new BigDecimal(200000));
             erd.setNote("Late more than 3 times in month");
             erd.setAppliedDate(Date.valueOf(LocalDate.of(year, month, 28)));
             if (rewardDisciplineDAO.insertManualRecord(erd)) {
                 insertedCount++;
             }
        }
        
        // Perfect attendance bonus
        if (validPresentDays >= 22 && lateCount == 0) {
            RewardDiscipline rdBonus = rewardDisciplineDAO.getRewardDisciplineByName("Thưởng Chuyên cần");
            EmployeeRewardDiscipline erd2 = new EmployeeRewardDiscipline();
            erd2.setUserId(userId);
            erd2.setRewardDisciplineId(rdBonus != null ? rdBonus.getId() : 3);
            erd2.setAmount(new BigDecimal(500000));
            erd2.setNote("Perfect attendance for month " + month);
            erd2.setAppliedDate(Date.valueOf(LocalDate.of(year, month, 28)));
            if (rewardDisciplineDAO.insertManualRecord(erd2)) {
                insertedCount++;
            }
        }
        return insertedCount;
    }

    @Override
    public void calculateKPIBonus(int userId, int month, int year, BigDecimal baseSalary, double kpiScore) {
        BigDecimal maxBonus = baseSalary.multiply(new BigDecimal("0.30"));
        BigDecimal actualBonus = maxBonus.multiply(new BigDecimal(kpiScore));
        
        RewardDiscipline rdKpi = rewardDisciplineDAO.getRewardDisciplineByName("Thưởng KPI Tháng");
        EmployeeRewardDiscipline erd = new EmployeeRewardDiscipline();
        erd.setUserId(userId);
        erd.setRewardDisciplineId(rdKpi != null ? rdKpi.getId() : 1);
        erd.setAmount(actualBonus);
        erd.setNote("KPI Score: " + (kpiScore * 100) + "%");
        erd.setAppliedDate(Date.valueOf(LocalDate.of(year, month, 28)));
        rewardDisciplineDAO.insertManualRecord(erd);
    }

    @Override
    public boolean insertManualRecord(EmployeeRewardDiscipline record) {
        return rewardDisciplineDAO.insertManualRecord(record);
    }

    @Override
    public void issueWarning(int userId, String reason, java.time.LocalDate date) {
        RewardDiscipline rdWarning = rewardDisciplineDAO.getRewardDisciplineByName("Vi phạm kỷ luật khác");
        int warningTypeId = (rdWarning != null) ? rdWarning.getId() : 5;

        EmployeeRewardDiscipline warningRecord = new EmployeeRewardDiscipline();
        warningRecord.setUserId(userId);
        warningRecord.setRewardDisciplineId(warningTypeId);
        warningRecord.setAmount(BigDecimal.ZERO);
        warningRecord.setNote("Warning: " + reason);
        warningRecord.setAppliedDate(Date.valueOf(date));

        rewardDisciplineDAO.insertManualRecord(warningRecord);

        // Auto-Escalation Logic
        int warningCount = rewardDisciplineDAO.getWarningCountInLast3Months(userId, date);
        if (warningCount >= 3) {
            dao.PayrollDAO payrollDAO = new dao.PayrollDAO();
            dao.PayrollDAO.EmployeeSalaryInfo info = payrollDAO.getEmployeeSalaryInfo(userId);
            if (info != null && info.baseSalary != null) {
                BigDecimal deduction = info.baseSalary.multiply(new BigDecimal("0.05")); // 5% deduction
                
                RewardDiscipline rdPenalty = rewardDisciplineDAO.getRewardDisciplineByName("Đi muộn/Về sớm");
                int penaltyTypeId = (rdPenalty != null) ? rdPenalty.getId() : 4;
                
                EmployeeRewardDiscipline penaltyRecord = new EmployeeRewardDiscipline();
                penaltyRecord.setUserId(userId);
                penaltyRecord.setRewardDisciplineId(penaltyTypeId);
                penaltyRecord.setAmount(deduction);
                penaltyRecord.setNote("Auto-escalation: 3+ warnings in 3 months");
                penaltyRecord.setAppliedDate(Date.valueOf(date));
                
                rewardDisciplineDAO.insertManualRecord(penaltyRecord);
            }
        }
    }
}
