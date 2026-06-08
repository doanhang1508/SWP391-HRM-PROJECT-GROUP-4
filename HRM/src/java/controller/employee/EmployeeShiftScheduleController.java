package controller.employee;

import model.Shift;
import model.ShiftAssignment;
import model.User;
import dao.ShiftAssignmentDAO;
import dao.ShiftAssignmentDAOImpl;
import dao.ShiftDAO;
import dao.ShiftDAOImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.temporal.TemporalAdjusters;
import java.util.List;

/**
 * EmployeeShiftScheduleController — "View personal shift schedule" feature.
 *
 * Routes:
 *   /employee/schedule               → Current week schedule
 *   /employee/schedule?week=2026-06-02  → Specific week (any date in target week)
 *
 * Displays the logged-in employee's assigned shifts for the selected week,
 * with navigation to previous/next weeks.
 */
@WebServlet(name = "EmployeeShiftScheduleController", urlPatterns = {"/employee/schedule"})
public class EmployeeShiftScheduleController extends HttpServlet {

    private ShiftAssignmentDAO assignmentService;
    private ShiftDAO shiftService;

    @Override
    public void init() throws ServletException {
        assignmentService = new ShiftAssignmentDAOImpl();
        shiftService = new ShiftDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ── Auth check ──
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // If admin, redirect to admin dashboard
        if (currentUser.getRoleId() == 1) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            return;
        }

        int userId = currentUser.getUserId();

        // ── Determine target week (Monday start) ──
        LocalDate targetDate = parseDate(request.getParameter("week"));
        if (targetDate == null) targetDate = LocalDate.now();
        LocalDate weekStart = targetDate.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
        LocalDate weekEnd = weekStart.plusDays(6);

        // ── Load this employee's assignments for the week ──
        List<ShiftAssignment> weekAssignments =
                assignmentService.getByUserAndDateRange(userId, weekStart, weekEnd);

        // ── Build week dates array for the JSP header ──
        LocalDate[] weekDates = new LocalDate[7];
        for (int i = 0; i < 7; i++) {
            weekDates[i] = weekStart.plusDays(i);
        }

        // ── Load working hours for display ──
        double[] workingHours = new double[weekAssignments.size()];
        for (int i = 0; i < weekAssignments.size(); i++) {
            Shift shift = shiftService.getShiftById(weekAssignments.get(i).getShiftId());
            workingHours[i] = (shift != null) ? shiftService.calculateTotalWorkingHours(shift) : 0;
        }

        // ── Set request attributes ──
        request.setAttribute("weekStart", weekStart);
        request.setAttribute("weekEnd", weekEnd);
        request.setAttribute("weekDates", weekDates);
        request.setAttribute("weekAssignments", weekAssignments);
        request.setAttribute("workingHours", workingHours);

        request.getRequestDispatcher("/employee/shift-schedule.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    private LocalDate parseDate(String s) {
        if (s == null || s.trim().isEmpty()) return null;
        try { return LocalDate.parse(s.trim()); }
        catch (Exception e) { return null; }
    }
}
