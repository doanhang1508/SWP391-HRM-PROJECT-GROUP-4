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
import service.ShiftAssignmentService;
import service.ShiftAssignmentServiceImpl;

/**
 * EmployeeDashboardController — Employee dashboard with real shift data.
 * Loads this week's shift assignments for the "Lịch Phân Ca (Tuần này)" widget.
 */
@WebServlet(name = "EmployeeDashboardController", urlPatterns = {"/employee/dashboard"})
public class employeeDashboardController extends HttpServlet {

    private ShiftAssignmentService assignmentService;

    @Override
    public void init() throws ServletException {
        assignmentService = new ShiftAssignmentServiceImpl();
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

            request.getRequestDispatcher("/employee/dashboard.jsp").forward(request, response);
        }
    } 

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        doGet(request, response);
    }
}
