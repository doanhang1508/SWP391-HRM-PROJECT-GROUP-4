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
import java.util.*;

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
        int userId = user.getUserId();
        int deptId = user.getDepartmentId();

        // Lấy danh sách tất cả kỳ (tháng/năm) có dữ liệu chấm công của user này
        List<AttendanceDAO.MonthYearOption> allPeriods = attendanceDAO.getPeriodsForUser(userId);

        // Với mỗi kỳ, build một PeriodData object chứa summary + danh sách ngày
        List<Map<String, Object>> periodDataList = new ArrayList<>();

        for (AttendanceDAO.MonthYearOption p : allPeriods) {
            int month = p.getMonth();
            int year  = p.getYear();

            // Lấy attendance thực tế
            List<Attendance> records = attendanceDAO.getAttendanceByUser(userId, month, year);
            if (records.isEmpty()) continue;

            // Fill đủ các ngày trong tháng (kể cả ngày không có data)
            List<Attendance> fullRecords = new ArrayList<>();
            int endDay = LocalDate.of(year, month, 1).lengthOfMonth();
            for (int d = 1; d <= endDay; d++) {
                final int currentDay = d;
                Attendance existing = records.stream()
                    .filter(a -> a.getWorkDate().toLocalDate().getDayOfMonth() == currentDay)
                    .findFirst().orElse(null);
                if (existing != null) {
                    fullRecords.add(existing);
                } else {
                    Attendance dummy = new Attendance();
                    dummy.setWorkDate(java.sql.Date.valueOf(LocalDate.of(year, month, currentDay)));
                    dummy.setStatus("NO_DATA");
                    dummy.setShiftName("—");
                    fullRecords.add(dummy);
                }
            }

            // Summary stats
            int[] summary = attendanceDAO.getAttendanceSummary(userId, month, year);

            // Dept confirmation status
            TimesheetConfirmation tc = tcDAO.getConfirmationByPeriodAndDept(month, year, deptId);

            Map<String, Object> periodData = new LinkedHashMap<>();
            periodData.put("month", month);
            periodData.put("year", year);
            periodData.put("attendanceList", fullRecords);
            periodData.put("present", summary[0]);
            periodData.put("late", summary[1]);
            periodData.put("absent", summary[2]);
            periodData.put("ot", summary[3]);
            periodData.put("confirmation", tc);
            periodDataList.add(periodData);
        }

        request.setAttribute("periodDataList", periodDataList);
        request.getRequestDispatcher("/employee/timesheet.jsp").forward(request, response);
    }
}
