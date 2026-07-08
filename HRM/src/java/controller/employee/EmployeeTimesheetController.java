package controller.employee;

import dao.AttendanceDAO;
import dao.TimesheetConfirmationDAO;
import dao.notificationDAO;
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
        if (user.getRoleId() == 1) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }
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

            boolean isEmployeeConfirmed = tcDAO.isEmployeeConfirmed(userId, month, year);

            Map<String, Object> periodData = new LinkedHashMap<>();
            periodData.put("month", month);
            periodData.put("year", year);
            periodData.put("attendanceList", fullRecords);
            periodData.put("present", summary[0]);
            periodData.put("late", summary[1]);
            periodData.put("absent", summary[2]);
            periodData.put("ot", summary[3]);
            periodData.put("confirmation", tc);
            periodData.put("isEmployeeConfirmed", isEmployeeConfirmed);
            periodDataList.add(periodData);
        }

        request.setAttribute("periodDataList", periodDataList);
        request.getRequestDispatcher("/employee/timesheet.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("currentUser");
        if (user.getRoleId() == 1) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }
        int userId = user.getUserId();
        int deptId = user.getDepartmentId();

        String action = request.getParameter("action");
        String monthStr = request.getParameter("month");
        String yearStr = request.getParameter("year");

        if ("confirmTimesheet".equals(action) && monthStr != null && yearStr != null) {
            try {
                int month = Integer.parseInt(monthStr);
                int year = Integer.parseInt(yearStr);

                // Verify department status is SENT_TO_DEPARTMENT
                TimesheetConfirmation tc = tcDAO.getConfirmationByPeriodAndDept(month, year, deptId);
                if (tc != null && "SENT_TO_DEPARTMENT".equals(tc.getStatus())) {
                    boolean success = tcDAO.confirmEmployeeTimesheet(userId, month, year, deptId);
                    if (success) {
                        session.setAttribute("successMessage", "Xác nhận phiếu công thành công.");
                        new notificationDAO().create(userId, "attendance", "Đã xác nhận phiếu công",
                            "Bạn đã xác nhận phiếu công tháng " + month + "/" + year + ".",
                            "/employee/timesheet");
                        if (tc.getCreatedBy() > 0) {
                            new notificationDAO().create(tc.getCreatedBy(), "attendance", "Nhân viên đã xác nhận phiếu công",
                                user.getFullName() + " đã xác nhận phiếu công tháng " + month + "/" + year + ".",
                                "/manager/timesheet-confirm");
                        }
                    } else {
                        session.setAttribute("errorMessage", "Xác nhận phiếu công thất bại.");
                    }
                } else {
                    session.setAttribute("errorMessage", "Không thể xác nhận phiếu công vào lúc này.");
                }
            } catch (NumberFormatException e) {
                session.setAttribute("errorMessage", "Tham số không hợp lệ.");
            }
        }

        response.sendRedirect(request.getContextPath() + "/employee/timesheet");
    }
}
