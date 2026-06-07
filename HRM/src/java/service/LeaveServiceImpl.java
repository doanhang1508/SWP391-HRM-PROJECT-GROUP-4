package service;

import dao.LeaveRequestDAO;
import dao.LeaveRequestDAOImpl;
import model.Attendance;
import model.LeaveRequest;
import model.LeaveType;
import java.sql.Date;
import java.time.LocalDate;
import java.util.List;

import java.time.DayOfWeek;

public class LeaveServiceImpl implements LeaveService {

    private final LeaveRequestDAO leaveRequestDAO;
    private static final double BASE_ANNUAL_LEAVE = 12.0;

    public LeaveServiceImpl() {
        this.leaveRequestDAO = new LeaveRequestDAOImpl();
    }

    // ═══════════════════════════════════════════════════════════════
    // 1. Core Logic (Included Use Cases)
    // ═══════════════════════════════════════════════════════════════

    @Override
    public double calculateTotalLeaveDays(LocalDate startDate, LocalDate endDate) {
        if (startDate == null || endDate == null || startDate.isAfter(endDate)) {
            return 0;
        }
        double days = 0;
        LocalDate current = startDate;
        while (!current.isAfter(endDate)) {
            if (current.getDayOfWeek() != DayOfWeek.SATURDAY && current.getDayOfWeek() != DayOfWeek.SUNDAY) {
                days += 1.0;
            }
            current = current.plusDays(1);
        }
        return days;
    }

    @Override
    public double checkRemainingLeaveBalance(int userId, int leaveTypeId) throws Exception {
        LeaveType type = leaveRequestDAO.getLeaveTypeById(leaveTypeId);
        if (type == null) {
            throw new Exception("Loại nghỉ phép không tồn tại.");
        }
        
        int currentYear = LocalDate.now().getYear();
        double usedDays = leaveRequestDAO.getUsedLeaveDaysByType(userId, leaveTypeId, currentYear);
        
        // If it's Annual Leave (assume id 1 or maxDaysPerYear is set), we track it
        if (type.getMaxDaysPerYear() != null) {
            return Math.max(0, type.getMaxDaysPerYear() - usedDays);
        }
        
        // If it's the default "Annual Leave" logic with base 12
        if (leaveTypeId == 1) {
            return Math.max(0, BASE_ANNUAL_LEAVE - usedDays);
        }
        
        // For other leaves without a max, just return a high number or 0
        return 999.0;
    }

    @Override
    public void validateLeaveRequestData(LeaveRequest request) throws Exception {
        LocalDate startDate = request.getStartDate().toLocalDate();
        LocalDate endDate = request.getEndDate().toLocalDate();
        
        if (startDate.isAfter(endDate)) {
            throw new Exception("Ngày bắt đầu không được lớn hơn ngày kết thúc.");
        }
        
        if (startDate.isBefore(LocalDate.now())) {
            throw new Exception("Không thể xin nghỉ phép cho ngày trong quá khứ.");
        }
        
        // <<include>> calculateTotalLeaveDays
        double calculatedDays = calculateTotalLeaveDays(startDate, endDate);
        if (calculatedDays <= 0) {
            throw new Exception("Số ngày làm việc không hợp lệ (có thể bạn chỉ chọn ngày cuối tuần).");
        }
        // Force the total days to be exactly the working days calculated
        // Unless the user requested a half-day, which we might support, but for strictness:
        if (request.getTotalDays() > calculatedDays) {
            throw new Exception("Số ngày nghỉ vượt quá số ngày làm việc thực tế trong khoảng thời gian này.");
        }
        
        // Check overlapping
        if (leaveRequestDAO.hasOverlappingLeave(request.getUserId(), request.getStartDate(), request.getEndDate())) {
            throw new Exception("Bạn đã có đơn nghỉ phép trong khoảng thời gian này.");
        }
        
        // <<include>> checkRemainingLeaveBalance
        LeaveType type = leaveRequestDAO.getLeaveTypeById(request.getLeaveTypeId());
        if (type != null && (type.getLeaveTypeId() == 1 || type.getMaxDaysPerYear() != null)) {
            double remaining = checkRemainingLeaveBalance(request.getUserId(), request.getLeaveTypeId());
            if (request.getTotalDays() > remaining) {
                throw new Exception("Số ngày phép không đủ. Bạn chỉ còn " + remaining + " ngày phép.");
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // 2. Employee Actions
    // ═══════════════════════════════════════════════════════════════

    @Override
    public boolean submitLeaveRequest(LeaveRequest request) throws Exception {
        validateLeaveRequestData(request);
        return leaveRequestDAO.submitRequest(request);
    }

    @Override
    public List<LeaveRequest> getLeaveHistoryByUserId(int userId) {
        return leaveRequestDAO.getRequestsByUserId(userId);
    }

    // ═══════════════════════════════════════════════════════════════
    // 3. Supervisor Actions
    // ═══════════════════════════════════════════════════════════════

    @Override
    public List<LeaveRequest> getPendingLeavesByDepartment(int departmentId) {
        return leaveRequestDAO.getPendingRequestsByDepartment(departmentId);
    }

    @Override
    public boolean approveLeaveRequest(int requestId, int approvedBy) throws Exception {
        return leaveRequestDAO.updateRequestStatus(requestId, "Approved", approvedBy);
    }

    @Override
    public boolean rejectLeaveRequest(int requestId, int approvedBy) throws Exception {
        return leaveRequestDAO.updateRequestStatus(requestId, "Rejected", approvedBy);
    }

    // ═══════════════════════════════════════════════════════════════
    // 4. HR Manager Actions
    // ═══════════════════════════════════════════════════════════════

    @Override
    public List<LeaveType> getAllLeaveTypes() {
        return leaveRequestDAO.getAllLeaveTypes();
    }

    @Override
    public boolean addLeaveType(LeaveType leaveType) {
        return leaveRequestDAO.addLeaveType(leaveType);
    }

    @Override
    public boolean updateLeaveType(LeaveType leaveType) {
        return leaveRequestDAO.updateLeaveType(leaveType);
    }

    @Override
    public boolean deleteLeaveType(int leaveTypeId) {
        return leaveRequestDAO.deleteLeaveType(leaveTypeId);
    }

    @Override
    public List<LeaveRequest> getAllLeaveRequests() {
        return leaveRequestDAO.getAllRequests();
    }
}
