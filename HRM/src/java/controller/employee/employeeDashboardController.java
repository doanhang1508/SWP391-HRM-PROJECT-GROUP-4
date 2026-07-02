package controller.employee;

import java.io.IOException;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.temporal.TemporalAdjusters;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import model.ShiftAssignment;
import model.User;
import model.ResignationRequest;
import model.TransferRequest;
import model.KpiEvaluation;
import dao.ShiftAssignmentDAO;
import dao.ShiftAssignmentDAOImpl;
import dao.ResignationDAO;
import dao.TransferRequestDAO;
import dao.KpiDAO;
import dao.LeaveRequestDAO;
import dao.LeaveRequestDAOImpl;
import dao.AttendanceDAO;

/**
 * EmployeeDashboardController — Employee dashboard with real shift data.
 * Loads this week's shift assignments for the "Lịch Phân Ca (Tuần này)" widget.
 */
@WebServlet(name = "EmployeeDashboardController", urlPatterns = {"/employee/dashboard"})
public class employeeDashboardController extends HttpServlet {

    private ShiftAssignmentDAO assignmentService;
    private ResignationDAO resignationDAO;
    private TransferRequestDAO transferRequestDAO;
    private KpiDAO kpiDAO;
    private LeaveRequestDAO leaveRequestDAO;
    private AttendanceDAO attendanceDAO;

    @Override
    public void init() throws ServletException {
        assignmentService = new ShiftAssignmentDAOImpl();
        resignationDAO = new ResignationDAO();
        transferRequestDAO = new TransferRequestDAO();
        kpiDAO = new KpiDAO();
        leaveRequestDAO = new LeaveRequestDAOImpl();
        attendanceDAO = new AttendanceDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        // Kiểm tra xem người dùng đã đăng nhập chưa
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            // Chưa đăng nhập -> Chuyển hướng về trang Đăng nhập
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        // Đã đăng nhập -> Hiển thị Dashboard tùy theo vai trò
        if (currentUser.getRoleId() == 1) { // 1 là Admin
            response.sendRedirect(request.getContextPath() + "/admin/dashboard");
        } else { // 2 là Manager, 3 là Employee
            // ── Load this week's shift assignments ──
            LocalDate today = LocalDate.now();
            LocalDate weekStart = today.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
            LocalDate weekEnd = weekStart.plusDays(6);

            List<ShiftAssignment> weekAssignments =
                    assignmentService.getByUserAndDateRange(currentUser.getUserId(), weekStart, weekEnd);

            // Build week dates array
            LocalDate[] weekDates = new LocalDate[7];
            for (int i = 0; i < 7; i++) {
                weekDates[i] = weekStart.plusDays(i);
            }

            request.setAttribute("weekAssignments", weekAssignments);
            request.setAttribute("weekDates", weekDates);
            request.setAttribute("weekStart", weekStart);

            // ── Fetch Resignation, Transfer, and KPI details ──
            List<ResignationRequest> resignations = resignationDAO.getByUserId(currentUser.getUserId());
            ResignationRequest latestResignation = resignations.isEmpty() ? null : resignations.get(0);
            request.setAttribute("latestResignation", latestResignation);

            List<TransferRequest> transfers = transferRequestDAO.getByEmployeeId(currentUser.getUserId());
            TransferRequest latestTransfer = transfers.isEmpty() ? null : transfers.get(0);
            request.setAttribute("latestTransfer", latestTransfer);

            List<KpiEvaluation> kpis = kpiDAO.getEvaluationsByEmployee(currentUser.getUserId());
            KpiEvaluation latestKpi = kpis.isEmpty() ? null : kpis.get(0);
            request.setAttribute("latestKpi", latestKpi);

            double remainingLeave = 12.0;
            try {
                remainingLeave = leaveRequestDAO.checkRemainingLeaveBalance(currentUser.getUserId(), 1);
            } catch (Exception e) {}
            request.setAttribute("remainingLeave", remainingLeave);

            model.AttendanceSummary attendanceSummary = attendanceDAO.getAttendanceSummaryForUser(
                    currentUser.getUserId(), today.getMonthValue(), today.getYear());
            request.setAttribute("attendanceSummary", attendanceSummary);

            request.getRequestDispatcher("/employee/dashboard.jsp").forward(request, response);
        }
    } 

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        doGet(request, response);
    }
}
