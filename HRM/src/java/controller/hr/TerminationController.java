package controller.hr;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDate;
import dao.UserDAO;
import model.User;

/**
 * TerminationController — HR Staff/Manager xử lý nghỉ việc cho nhân viên.
 * URL: /hr/terminate-employee
 * Roles: HR Manager (2), HR Staff (5)
 */
@WebServlet("/hr/terminate-employee")
public class TerminationController extends HttpServlet {

    private final UserDAO lifecycleService = new UserDAO();

    private boolean checkAccess(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("currentUser") : null;
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return false;
        }
        if (user.getRoleId() != 2 && user.getRoleId() != 5) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return false;
        }
        return true;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!checkAccess(req, resp)) return;
        req.getRequestDispatcher("/hr/termination.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!checkAccess(req, resp)) return;
        try {
            int userId = Integer.parseInt(req.getParameter("userId"));
            String reason = req.getParameter("reason");
            LocalDate terminationDate = LocalDate.parse(req.getParameter("terminationDate"));

            boolean success = lifecycleService.terminateEmployee(userId, reason, terminationDate);

            if (success) {
                req.setAttribute("message", "Đã xử lý nghỉ việc thành công.");
            } else {
                req.setAttribute("error", "Xử lý nghỉ việc thất bại. Vui lòng thử lại.");
            }
        } catch (Exception e) {
            req.setAttribute("error", "Dữ liệu nhập không hợp lệ: " + e.getMessage());
        }

        req.getRequestDispatcher("/hr/termination.jsp").forward(req, resp);
    }
}
