package controller.hr;

import dao.AttendanceDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.TimesheetLock;
import model.User;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

/**
 * Controller: HR khóa/mở khóa dữ liệu chấm công theo tháng để xử lý payroll.
 * URL: /hr/timesheet-lock
 * Roles: HR (2), Admin (1)
 */
@WebServlet(name = "LockTimesheetController", urlPatterns = {"/hr/timesheet-lock"})
public class LockTimesheetController extends HttpServlet {

    private final AttendanceDAO attendanceDAO = new AttendanceDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("currentUser");

        if (user == null || (user.getRoleId() != 2 && user.getRoleId() != 5)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        List<TimesheetLock> locks = attendanceDAO.getAllLocks();
        request.setAttribute("locks", locks);

        // Current month stats for preview
        int curMonth = LocalDate.now().getMonthValue();
        int curYear = LocalDate.now().getYear();
        int recordCount = attendanceDAO.countAttendanceInMonth(curMonth, curYear);
        boolean isCurrentLocked = attendanceDAO.isMonthLocked(curMonth, curYear);

        request.setAttribute("currentMonth", curMonth);
        request.setAttribute("currentYear", curYear);
        request.setAttribute("currentRecordCount", recordCount);
        request.setAttribute("isCurrentLocked", isCurrentLocked);

        request.getRequestDispatcher("/hr/timesheet-lock.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("currentUser");

        if (user == null || (user.getRoleId() != 2 && user.getRoleId() != 5)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        int month = Integer.parseInt(request.getParameter("month"));
        int year = Integer.parseInt(request.getParameter("year"));

        if ("lock".equals(action)) {
            if (user.getRoleId() == 5) {
                session.setAttribute("errorMessage", "Bạn không có quyền khóa bảng công.");
                response.sendRedirect(request.getContextPath() + "/hr/timesheet-lock");
                return;
            }
            String note = request.getParameter("note");
            int recordCount = attendanceDAO.countAttendanceInMonth(month, year);

            if (recordCount == 0) {
                session.setAttribute("errorMessage",
                    "Không có dữ liệu chấm công cho tháng " + month + "/" + year + ". Không thể khóa.");
                response.sendRedirect(request.getContextPath() + "/hr/timesheet-lock");
                return;
            }

            if (attendanceDAO.lockMonth(month, year, user.getUserId(), note)) {
                session.setAttribute("successMessage",
                    "Đã khóa dữ liệu chấm công tháng " + month + "/" + year +
                    " (" + recordCount + " bản ghi). Dữ liệu sẵn sàng cho xử lý lương.");
            } else {
                session.setAttribute("errorMessage", "Khóa thất bại. Vui lòng thử lại.");
            }

        } else if ("unlock".equals(action)) {
            // Only admin can unlock
            if (user.getRoleId() != 2) {
                session.setAttribute("errorMessage", "Chỉ HR Manager mới có thể mở khóa tháng đã khóa.");
                response.sendRedirect(request.getContextPath() + "/hr/timesheet-lock");
                return;
            }
            if (attendanceDAO.unlockMonth(month, year)) {
                session.setAttribute("successMessage",
                    "Đã mở khóa tháng " + month + "/" + year + ". Dữ liệu có thể chỉnh sửa.");
            } else {
                session.setAttribute("errorMessage", "Mở khóa thất bại.");
            }
        }

        response.sendRedirect(request.getContextPath() + "/hr/timesheet-lock");
    }
}
