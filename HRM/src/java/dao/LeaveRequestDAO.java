package dao;

import model.LeaveRequest;
import model.LeaveType;
import java.util.List;
import java.time.LocalDate;

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

    double calculateTotalLeaveDays(int userId, LocalDate startDate, LocalDate endDate);
    double checkRemainingLeaveBalance(int userId, int leaveTypeId) throws Exception;
    void validateLeaveRequestData(LeaveRequest request) throws Exception;
    boolean submitLeaveRequest(LeaveRequest request) throws Exception;
    List<LeaveRequest> getLeaveHistoryByUserId(int userId);
    List<LeaveRequest> getPendingLeavesByDepartment(int departmentId);
    List<LeaveRequest> getApprovedLeavesByDepartment(int departmentId);
    List<LeaveRequest> getAllLeavesByDepartment(int departmentId);
    boolean approveLeaveRequest(int requestId, int approvedBy) throws Exception;
    boolean rejectLeaveRequest(int requestId, int approvedBy, String rejectReason) throws Exception;
    List<LeaveRequest> getAllLeaveRequests();
    double getPaidLeaveDays(int employeeId, int month, int year);
}

