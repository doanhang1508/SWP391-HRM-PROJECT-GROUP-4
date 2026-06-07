package service;

import model.LeaveRequest;
import model.LeaveType;
import java.time.LocalDate;
import java.util.List;

public interface LeaveService {
    // 1. Core Logic (Included Use Cases)
    double calculateTotalLeaveDays(LocalDate startDate, LocalDate endDate);
    double checkRemainingLeaveBalance(int userId, int leaveTypeId) throws Exception;
    void validateLeaveRequestData(LeaveRequest request) throws Exception;

    // 2. Employee Actions
    boolean submitLeaveRequest(LeaveRequest request) throws Exception;
    List<LeaveRequest> getLeaveHistoryByUserId(int userId);

    // 3. Supervisor Actions
    List<LeaveRequest> getPendingLeavesByDepartment(int departmentId);
    boolean approveLeaveRequest(int requestId, int approvedBy) throws Exception;
    boolean rejectLeaveRequest(int requestId, int approvedBy) throws Exception;

    // 4. HR Manager Actions
    List<LeaveType> getAllLeaveTypes();
    boolean addLeaveType(LeaveType leaveType);
    boolean updateLeaveType(LeaveType leaveType);
    boolean deleteLeaveType(int leaveTypeId);
    List<LeaveRequest> getAllLeaveRequests();
}
