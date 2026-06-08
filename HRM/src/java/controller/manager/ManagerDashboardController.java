package controller.manager;

import dao.DepartmentDAO;
import dao.UserDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

@WebServlet(name = "ManagerDashboardController", urlPatterns = {"/manager/dashboard"})
public class ManagerDashboardController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if (currentUser.getRoleId() != 3 && currentUser.getRoleId() != 6) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        UserDAO userDAO = new UserDAO();
        DepartmentDAO deptDAO = new DepartmentDAO();

        int totalEmployees   = userDAO.getTotalUsers();
        int activeEmployees  = userDAO.getActiveUsers();
        int totalDepartments = deptDAO.getAll().size();

        request.setAttribute("totalEmployees",   totalEmployees);
        request.setAttribute("activeEmployees",  activeEmployees);
        request.setAttribute("totalDepartments", totalDepartments);

        request.setAttribute("pendingOT", 0);
        request.setAttribute("todayAttendance", 0);
        request.setAttribute("pendingLeaves", 0);

        request.getRequestDispatcher("/manager/dashboard.jsp").forward(request, response);
    }
}
