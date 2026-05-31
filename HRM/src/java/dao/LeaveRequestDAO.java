package dao;

import model.LeaveRequest;
import model.LeaveType;
import java.util.List;

public interface LeaveRequestDAO {
    List<LeaveType> getAllLeaveTypes();
    List<LeaveRequest> getRequestsByUserId(int userId);
    List<LeaveRequest> getPendingRequestsByDepartment(int departmentId);
    boolean submitRequest(LeaveRequest request);
    boolean updateRequestStatus(int requestId, String status, int approvedBy);
    double getUsedAnnualLeaveDays(int userId, int year);
}
