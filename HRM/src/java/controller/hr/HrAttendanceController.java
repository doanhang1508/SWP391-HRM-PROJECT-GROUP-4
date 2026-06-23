package controller.hr;

import dao.AttendanceDAO;
import dao.UserDAO;
import model.Attendance;
import model.AttendanceSummary;
import model.User;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "HrAttendanceController", urlPatterns = {"/hr/attendance-management"})
public class HrAttendanceController extends HttpServlet {

    private AttendanceDAO attendanceDAO;
    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        attendanceDAO = new AttendanceDAO();
        userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser.getRoleId() != 2 && currentUser.getRoleId() != 5) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập trang này.");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            action = "summary";
        }

        // Get month and year parameter or default to current
        String monthStr = request.getParameter("month");
        String yearStr = request.getParameter("year");
        
        LocalDate now = LocalDate.now();
        int month = (monthStr != null && !monthStr.isEmpty()) ? Integer.parseInt(monthStr) : now.getMonthValue();
        int year = (yearStr != null && !yearStr.isEmpty()) ? Integer.parseInt(yearStr) : now.getYear();

        request.setAttribute("selectedMonth", month);
        request.setAttribute("selectedYear", year);

        switch (action) {
            case "summary":
                viewSummary(request, response, month, year);
                break;
            case "detail":
                viewDetail(request, response, month, year);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/hr/attendance-management?action=summary");
                break;
        }
    }

    private void viewSummary(HttpServletRequest request, HttpServletResponse response, int month, int year)
            throws ServletException, IOException {
        List<AttendanceSummary> summaryList = attendanceDAO.getAttendanceSummaryAllUsers(month, year);
        request.setAttribute("summaryList", summaryList);
        request.getRequestDispatcher("/hr/attendance-summary.jsp").forward(request, response);
    }

    private void viewDetail(HttpServletRequest request, HttpServletResponse response, int month, int year)
            throws ServletException, IOException {
        String userIdStr = request.getParameter("userId");
        Integer userId = null;
        if (userIdStr != null && !userIdStr.isEmpty()) {
            userId = Integer.parseInt(userIdStr);
            request.setAttribute("selectedUserId", userId);
        }

        List<Attendance> detailList = attendanceDAO.getAllAttendance(month, year, userId);
        request.setAttribute("detailList", detailList);
        
        // Load user list for filtering
        List<User> userList = userDAO.getAllUsers();
        request.setAttribute("userList", userList);

        request.getRequestDispatcher("/hr/attendance-detail.jsp").forward(request, response);
    }
}
