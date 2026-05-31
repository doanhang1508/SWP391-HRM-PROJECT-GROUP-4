package dao;

import model.Shift;
import java.util.List;

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
}
