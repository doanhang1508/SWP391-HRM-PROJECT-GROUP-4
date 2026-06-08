package dao;

import model.OvertimePlan;
import java.util.List;

/**
 * OvertimePlanDAO — Data Access interface for `overtime_plans` table.
 * Supervisors create OT plans for their departments.
 */
public interface OvertimePlanDAO {

    List<OvertimePlan> getByDepartmentId(int deptId);

    OvertimePlan getById(int planId);

    boolean create(OvertimePlan plan);

    boolean updateStatus(int planId, String status);
}
