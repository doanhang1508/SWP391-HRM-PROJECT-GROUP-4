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
    double getUsedLeaveDaysByType(int userId, int leaveTypeId, int year);
    
    // HR Manager Actions
    List<LeaveRequest> getAllRequests();
    boolean addLeaveType(LeaveType leaveType);
    boolean updateLeaveType(LeaveType leaveType);
    boolean deleteLeaveType(int leaveTypeId);
    
    // Validation
    boolean hasOverlappingLeave(int userId, java.sql.Date startDate, java.sql.Date endDate);
    LeaveType getLeaveTypeById(int leaveTypeId);
}
