package service;

import java.math.BigDecimal;
import model.EmployeeRewardDiscipline;

public interface RewardDisciplineService {
    int generateAttendanceAutomations(int userId, int month, int year);
    void calculateKPIBonus(int userId, int month, int year, BigDecimal baseSalary, double kpiScore);
    boolean insertManualRecord(EmployeeRewardDiscipline record);
    void issueWarning(int userId, String reason, java.time.LocalDate date);
}
