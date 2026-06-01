package service;

public interface PayrollService {
    void calculateMonthlyPayroll(int userId, int month, int year);
    void calculate13thMonthBonus(int userId, int currentYear);
}
