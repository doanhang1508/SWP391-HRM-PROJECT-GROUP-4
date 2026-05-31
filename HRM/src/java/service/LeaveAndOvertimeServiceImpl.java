package service;

import dao.LeaveRequestDAO;
import dao.LeaveRequestDAOImpl;
import dao.OvertimeDAO;
import dao.OvertimeDAOImpl;
import model.Attendance;
import model.LeaveRequest;
import model.LeaveType;
import java.sql.Date;
import java.time.LocalDate;
import java.util.List;

public class LeaveAndOvertimeServiceImpl implements LeaveAndOvertimeService {

    private final LeaveRequestDAO leaveRequestDAO;
    private final OvertimeDAO overtimeDAO;
    private static final double BASE_ANNUAL_LEAVE = 12.0;

    public LeaveAndOvertimeServiceImpl() {
        this.leaveRequestDAO = new LeaveRequestDAOImpl();
        this.overtimeDAO = new OvertimeDAOImpl();
    }

    @Override
    public List<LeaveType> getAllLeaveTypes() {
        return leaveRequestDAO.getAllLeaveTypes();
    }

    @Override
    public List<LeaveRequest> getLeaveHistoryByUserId(int userId) {
        return leaveRequestDAO.getRequestsByUserId(userId);
    }

    @Override
    public List<LeaveRequest> getPendingLeavesByDepartment(int departmentId) {
        return leaveRequestDAO.getPendingRequestsByDepartment(departmentId);
    }

    @Override
    public double getRemainingAnnualLeave(int userId, int year) {
        double usedDays = leaveRequestDAO.getUsedAnnualLeaveDays(userId, year);
        return Math.max(0, BASE_ANNUAL_LEAVE - usedDays);
    }

    @Override
    public boolean submitLeaveRequest(LeaveRequest request) throws Exception {
        // Validation Rule: check if employee has enough remaining Annual Leave days
        // Assuming leave_type_id = 1 is Annual Leave (Nghỉ phép năm)
        if (request.getLeaveTypeId() == 1) {
            LocalDate startDate = request.getStartDate().toLocalDate();
            double remaining = getRemainingAnnualLeave(request.getUserId(), startDate.getYear());
            if (request.getTotalDays() > remaining) {
                throw new Exception("Not enough remaining Annual Leave days. Remaining: " + remaining + " days.");
            }
        }
        
        if (request.getTotalDays() <= 0) {
            throw new Exception("Total days must be greater than 0.");
        }
        
        if (request.getStartDate().after(request.getEndDate())) {
            throw new Exception("Start date cannot be after end date.");
        }

        return leaveRequestDAO.submitRequest(request);
    }

    @Override
    public boolean approveLeaveRequest(int requestId, int approvedBy) {
        // Here we just update the status to Approved.
        // In a full implementation, triggering the payroll service to compute according to the leave pay rule
        // would be done by an event publisher or calling PayrollService.
        return leaveRequestDAO.updateRequestStatus(requestId, "Approved", approvedBy);
    }

    @Override
    public boolean rejectLeaveRequest(int requestId, int approvedBy) {
        return leaveRequestDAO.updateRequestStatus(requestId, "Rejected", approvedBy);
    }

    @Override
    public String getLeavePaymentSource(int leaveTypeId) {
        // 1. Nghỉ phép năm (Annual Leave) -> Paid by Company
        // 2. Nghỉ ốm (Sick Leave) -> Paid by Social Insurance (BHXH)
        // 3. Nghỉ thai sản (Maternity Leave) -> Paid by Social Insurance (BHXH)
        // 4. Nghỉ việc riêng có lương (Personal Leave with Pay) -> Paid by Company
        // 5. Nghỉ không lương (Unpaid Leave) -> No pay
        switch (leaveTypeId) {
            case 1:
            case 4:
                return "Paid by Company";
            case 2:
            case 3:
                return "Paid by Social Insurance (BHXH)";
            case 5:
                return "No Pay";
            default:
                return "Unknown";
        }
    }

    @Override
    public List<Attendance> getOTHistoryByUserId(int userId) {
        return overtimeDAO.getOTRequestsByUserId(userId);
    }

    @Override
    public List<Attendance> getPendingOTByDepartment(int departmentId) {
        return overtimeDAO.getPendingOTRequestsByDepartment(departmentId);
    }

    @Override
    public boolean submitOTRequest(int userId, int shiftId, Date workDate, double hours, String reason) throws Exception {
        if (hours <= 0) {
            throw new Exception("Estimated OT Hours must be greater than 0.");
        }
        return overtimeDAO.submitOTRequest(userId, shiftId, workDate, hours, reason);
    }

    @Override
    public boolean approveOTRequest(int attendanceId) {
        return overtimeDAO.approveOTRequest(attendanceId);
    }

    @Override
    public boolean rejectOTRequest(int attendanceId) {
        return overtimeDAO.rejectOTRequest(attendanceId);
    }
}
