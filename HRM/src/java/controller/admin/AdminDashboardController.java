package controller.admin;

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

@WebServlet(name = "AdminDashboardController", urlPatterns = {"/admin/dashboard"})
public class AdminDashboardController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if (currentUser.getRoleId() != 1) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        UserDAO userDAO = new UserDAO();

        int totalUsers   = userDAO.getTotalUsers();
        int activeUsers  = userDAO.getActiveUsers();
        int lockedUsers  = totalUsers - activeUsers;
        int totalRoles   = userDAO.getTotalRoles();

        request.setAttribute("totalUsers",  totalUsers);
        request.setAttribute("activeUsers", activeUsers);
        request.setAttribute("lockedUsers", lockedUsers);
        request.setAttribute("totalRoles",  totalRoles);

        List<User> recentUsers = userDAO.getAllUsers();
        if (recentUsers.size() > 10) {
            recentUsers = recentUsers.subList(recentUsers.size() - 10, recentUsers.size());
        }
        request.setAttribute("recentUsers", recentUsers);

        request.getRequestDispatcher("/admin/dashboard.jsp").forward(request, response);
    }
}
