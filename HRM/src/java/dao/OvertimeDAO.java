package dao;

import model.Attendance;
import java.sql.Date;
import java.util.List;

public interface OvertimeDAO {
    List<Attendance> getOTRequestsByUserId(int userId);
    List<Attendance> getPendingOTRequestsByDepartment(int departmentId);
    boolean submitOTRequest(int userId, int shiftId, Date workDate, double hours, String reason);
    boolean approveOTRequest(int attendanceId);
    boolean rejectOTRequest(int attendanceId);
}
