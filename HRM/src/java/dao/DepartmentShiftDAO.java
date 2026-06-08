package dao;

import model.DepartmentShift;
import java.util.List;

/**
 * DepartmentShiftDAO — Data Access interface for `department_shifts` table.
 * Manages the mapping of default shifts to departments.
 */
public interface DepartmentShiftDAO {

    List<DepartmentShift> getAll();

    List<DepartmentShift> getByDepartmentId(int departmentId);

    boolean add(int departmentId, int shiftId);

    boolean delete(int id);

    boolean existsMapping(int departmentId, int shiftId);
}
