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
import java.util.stream.Collectors;

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

        String weekParam = request.getParameter("week");
        int selectedWeek = 0;
        if (weekParam != null && !weekParam.isEmpty()) {
            try { selectedWeek = Integer.parseInt(weekParam); } catch (NumberFormatException ignored) {}
        }

        List<Attendance> records = attendanceDAO.getAttendanceByUser(user.getUserId(), month, year);
        
        // Tạo danh sách đầy đủ các ngày trong tuần/tháng
        List<Attendance> fullRecords = new java.util.ArrayList<>();
        int startDay = 1;
        int endDay = LocalDate.of(year, month, 1).lengthOfMonth();

        if (selectedWeek == 1) { endDay = 7; }
        else if (selectedWeek == 2) { startDay = 8; endDay = 14; }
        else if (selectedWeek == 3) { startDay = 15; endDay = 21; }
        else if (selectedWeek == 4) { startDay = 22; endDay = 28; }
        else if (selectedWeek == 5) { startDay = 29; }

        for (int i = startDay; i <= endDay; i++) {
            if (i > LocalDate.of(year, month, 1).lengthOfMonth()) break;
            int currentDay = i;
            Attendance existing = records.stream()
                .filter(a -> a.getWorkDate().toLocalDate().getDayOfMonth() == currentDay)
                .findFirst().orElse(null);
                
            if (existing != null) {
                fullRecords.add(existing);
            } else {
                Attendance dummy = new Attendance();
                dummy.setWorkDate(java.sql.Date.valueOf(LocalDate.of(year, month, currentDay)));
                dummy.setStatus("Chưa có dữ liệu");
                dummy.setShiftName("—");
                fullRecords.add(dummy);
            }
        }
        
        records = fullRecords;
        
        int[] summary = attendanceDAO.getAttendanceSummary(user.getUserId(), month, year);

        request.setAttribute("attendanceList", records);
        request.setAttribute("summaryPresent", summary[0]);
        request.setAttribute("summaryLate", summary[1]);
        request.setAttribute("summaryAbsent", summary[2]);
        request.setAttribute("summaryOT", summary[3]);
        request.setAttribute("selectedMonth", month);
        request.setAttribute("selectedYear", year);
        request.setAttribute("selectedWeek", selectedWeek);

        // Generate year options (last 3 years)
        int currentYear = LocalDate.now().getYear();
        request.setAttribute("yearOptions", new int[]{currentYear, currentYear - 1, currentYear - 2});

        request.getRequestDispatcher("/employee/attendance.jsp").forward(request, response);
    }
}
