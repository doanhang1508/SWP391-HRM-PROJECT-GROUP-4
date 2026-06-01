package service;

import java.time.LocalDate;

public interface EmployeeLifecycleService {
    boolean terminateEmployee(int userId, String reason, LocalDate terminationDate);
}
