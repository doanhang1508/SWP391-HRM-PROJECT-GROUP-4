package controller.employee;

import dao.AttendanceDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Attendance;
import model.User;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

/**
 * Controller: Nhân viên xem lịch sử chấm công cá nhân.
 * URL: /employee/attendance
 * Roles: Employee (4), Manager (3), HR (2), Admin (1)
 */
@WebServlet(name = "ViewPersonalAttendanceController", urlPatterns = {"/employee/attendance"})
public class ViewPersonalAttendanceController extends HttpServlet {

    private final AttendanceDAO attendanceDAO = new AttendanceDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("currentUser");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Default to current month/year
        int month = LocalDate.now().getMonthValue();
        int year = LocalDate.now().getYear();

        String monthParam = request.getParameter("month");
        String yearParam = request.getParameter("year");
        if (monthParam != null && !monthParam.isEmpty()) {
            try { month = Integer.parseInt(monthParam); } catch (NumberFormatException ignored) {}
        }
        if (yearParam != null && !yearParam.isEmpty()) {
            try { year = Integer.parseInt(yearParam); } catch (NumberFormatException ignored) {}
        }

        List<Attendance> records = attendanceDAO.getAttendanceByUser(user.getUserId(), month, year);
        int[] summary = attendanceDAO.getAttendanceSummary(user.getUserId(), month, year);

        request.setAttribute("attendanceList", records);
        request.setAttribute("summaryPresent", summary[0]);
        request.setAttribute("summaryLate", summary[1]);
        request.setAttribute("summaryAbsent", summary[2]);
        request.setAttribute("summaryOT", summary[3]);
        request.setAttribute("selectedMonth", month);
        request.setAttribute("selectedYear", year);

        // Generate year options (last 3 years)
        int currentYear = LocalDate.now().getYear();
        request.setAttribute("yearOptions", new int[]{currentYear, currentYear - 1, currentYear - 2});

        request.getRequestDispatcher("/employee/attendance.jsp").forward(request, response);
    }
}
