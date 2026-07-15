package dao;

import model.Shift;
import java.util.List;
import java.time.LocalTime;
import java.time.LocalDate;
import model.DepartmentShift;

/**
 * ShiftDAO — Data Access Object interface for the `shifts` table (v2 schema).
 * Defines standard CRUD + toggle-status operations.
 */
public interface ShiftDAO {

    List<Shift> getAllShifts();

    List<Shift> getActiveShifts();

    Shift getShiftById(int shiftId);

    boolean addShift(Shift shift);

    boolean updateShift(Shift shift);

    boolean deleteShift(int shiftId);

    boolean toggleShiftStatus(int shiftId);

    boolean isShiftNameExists(String shiftName, int excludeShiftId);

    String validateShiftData(Shift shift, int excludeShiftId);
    void autoDetectNightShift(Shift shift);
    List<DepartmentShift> getAllDepartmentShifts();
    List<DepartmentShift> getDepartmentShiftsByDeptId(int deptId);
    boolean assignDefaultShiftToDepartment(int departmentId, int shiftId);
    boolean removeDepartmentShift(int id);
    double calculateTotalWorkingHours(Shift shift);
    boolean isNightShift(Shift shift);
    LocalDate resolveWorkDate(Shift shift, LocalDate assignedDate);
    boolean isWithinGracePeriod(LocalTime shiftStart, LocalTime clockIn);
    long calculateLatenessMinutes(LocalTime shiftStart, LocalTime clockIn);
    long calculateEarlyCheckInOvertimeMinutes(LocalTime shiftStart, LocalTime clockIn, boolean hasOvertimeRequest);
    int findOrCreateCustomShift(LocalTime start, LocalTime end, LocalTime breakStart, LocalTime breakEnd, String shiftName);
    int findOrCreateCustomShift(LocalTime start, LocalTime end, LocalTime breakStart, LocalTime breakEnd, String shiftName, float coefficient);
}
