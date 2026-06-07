package controller.director;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

import java.io.IOException;

/**
 * DirectorDashboardController — Dashboard tổng quan cho Giám đốc (role 4).
 *
 * URL  : /director/dashboard
 * Role : 4 (Director / Giám đốc)
 *
 * Hiển thị số liệu tổng hợp cấp cao:
 *   - Tổng nhân sự toàn công ty
 *   - Số phòng ban / xưởng
 *   - Hợp đồng sắp hết hạn (TODO Iter 2)
 *   - Bảng lương chờ duyệt chốt (TODO Iter 2)
 */
@WebServlet(name = "DirectorDashboardController", urlPatterns = {"/director/dashboard"})
public class DirectorDashboardController extends HttpServlet {

    private static final int ROLE_DIRECTOR = 4;

    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = getCurrentUser(req);
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        if (user.getRoleId() != ROLE_DIRECTOR) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }

        // Số liệu tổng hợp
        req.setAttribute("totalEmployees", userDAO.getTotalUsers());
        req.setAttribute("activeEmployees", userDAO.getActiveUsers());

        // TODO Iteration 2: thêm số liệu:
        //   - Tổng quỹ lương tháng hiện tại (PayrollDAO)
        //   - Số hợp đồng sắp hết hạn trong 30 ngày (ContractDAO)
        //   - Số bảng lương chờ Director duyệt chốt (PayrollDAO)

        req.getRequestDispatcher("/director/dashboard.jsp").forward(req, resp);
    }

    private User getCurrentUser(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        return s != null ? (User) s.getAttribute("currentUser") : null;
    }
}
