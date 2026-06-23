package controller.employee;

import dao.AttendanceDAO;
import dao.TimesheetConfirmationDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Attendance;
import model.TimesheetConfirmation;
import model.User;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

@WebServlet(name = "EmployeeTimesheetController", urlPatterns = {"/employee/timesheet"})
public class EmployeeTimesheetController extends HttpServlet {

    private final AttendanceDAO attendanceDAO = new AttendanceDAO();
    private final TimesheetConfirmationDAO tcDAO = new TimesheetConfirmationDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("currentUser");

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
        
        // Generate full list of days in the month
        List<Attendance> fullRecords = new java.util.ArrayList<>();
        int endDay = LocalDate.of(year, month, 1).lengthOfMonth();

        for (int i = 1; i <= endDay; i++) {
            int currentDay = i;
            Attendance existing = records.stream()
                .filter(a -> a.getWorkDate().toLocalDate().getDayOfMonth() == currentDay)
                .findFirst().orElse(null);
                
            if (existing != null) {
                fullRecords.add(existing);
            } else {
                Attendance dummy = new Attendance();
                dummy.setWorkDate(java.sql.Date.valueOf(LocalDate.of(year, month, currentDay)));
                dummy.setStatus("ABSENT");
                dummy.setShiftName("—");
                fullRecords.add(dummy);
            }
        }
        
        int[] summary = attendanceDAO.getAttendanceSummary(user.getUserId(), month, year);

        // Fetch department timesheet status for info
        TimesheetConfirmation deptConfirmation = tcDAO.getConfirmationByPeriodAndDept(month, year, user.getDepartmentId());

        request.setAttribute("attendanceList", fullRecords);
        request.setAttribute("summaryPresent", summary[0]);
        request.setAttribute("summaryLate", summary[1]);
        request.setAttribute("summaryAbsent", summary[2]);
        request.setAttribute("summaryOT", summary[3]);
        request.setAttribute("selectedMonth", month);
        request.setAttribute("selectedYear", year);
        request.setAttribute("deptConfirmation", deptConfirmation);

        request.getRequestDispatcher("/employee/timesheet.jsp").forward(request, response);
    }
}
