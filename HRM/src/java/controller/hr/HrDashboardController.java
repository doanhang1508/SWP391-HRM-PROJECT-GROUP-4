package controller.hr;

import dao.DepartmentDAO;
import dao.UserDAO;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

@WebServlet(name = "HrDashboardController", urlPatterns = {"/hr/dashboard"})
public class HrDashboardController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        // Chưa đăng nhập → về trang login
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Không phải HR (roleId = 3) → từ chối
        if (currentUser.getRoleId() != 3) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        // ── Thống kê ──
        UserDAO userDAO = new UserDAO();
        DepartmentDAO deptDAO = new DepartmentDAO();

        int totalEmployees  = userDAO.getTotalUsers();
        int totalDepartments = deptDAO.getAll().size();

        // Nhân viên mới nhất (5 người)
        List<User> recentEmployees = userDAO.getAllUsers();
        if (recentEmployees.size() > 5) {
            recentEmployees = recentEmployees.subList(
                    recentEmployees.size() - 5, recentEmployees.size());
        }

        // Placeholder — sẽ thay bằng DAO thực khi có bảng contracts / leaves
        int expiringContracts = 0;
        int pendingLeaves     = 0;

        request.setAttribute("totalEmployees",   totalEmployees);
        request.setAttribute("totalDepartments", totalDepartments);
        request.setAttribute("expiringContracts", expiringContracts);
        request.setAttribute("pendingLeaves",    pendingLeaves);
        request.setAttribute("recentEmployees",  recentEmployees);

        request.getRequestDispatcher("/hr/dashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
