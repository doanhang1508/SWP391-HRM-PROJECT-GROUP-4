package service;

import model.Attendance;
import model.LeaveRequest;
import model.LeaveType;
import java.sql.Date;
import java.util.List;

public interface LeaveAndOvertimeService {
    // Leave Management
    List<LeaveType> getAllLeaveTypes();
    List<LeaveRequest> getLeaveHistoryByUserId(int userId);
    List<LeaveRequest> getPendingLeavesByDepartment(int departmentId);
    
    /**
     * @return remaining annual leave days for the given year (base 12 days)
     */
    double getRemainingAnnualLeave(int userId, int year);
    
    /**
     * @return true if successfully submitted, throws exception if validation fails
     */
    boolean submitLeaveRequest(LeaveRequest request) throws Exception;
    
    boolean approveLeaveRequest(int requestId, int approvedBy);
    boolean rejectLeaveRequest(int requestId, int approvedBy);
    
    /**
     * Determines the payment source (Company, BHXH, None)
     */
    String getLeavePaymentSource(int leaveTypeId);

    // Overtime Management
    List<Attendance> getOTHistoryByUserId(int userId);
    List<Attendance> getPendingOTByDepartment(int departmentId);
    
    boolean submitOTRequest(int userId, int shiftId, Date workDate, double hours, String reason) throws Exception;
    
    boolean approveOTRequest(int attendanceId);
    boolean rejectOTRequest(int attendanceId);
}
