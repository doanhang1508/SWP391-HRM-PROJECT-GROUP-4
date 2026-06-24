package controller.hr;

import dao.DepartmentDAO;
import dao.PositionDAO;
import dao.UserDAO;
import model.Department;
import model.Position;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

/**
 * HrEmployeeController — Danh sách hồ sơ nhân viên dành cho HR Staff và HR Manager.
 */
@WebServlet(name = "HrEmployeeController", urlPatterns = {"/hr/employees"})
public class HrEmployeeController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");
        int roleId = currentUser.getRoleId();

        // HR Manager (2) và HR Staff (5)
        if (roleId != 2 && roleId != 5) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        UserDAO userDAO = new UserDAO();
        DepartmentDAO deptDAO = new DepartmentDAO();
        PositionDAO posDAO = new PositionDAO();

        List<User> users = userDAO.getAllUsers();

        List<Department> departments = deptDAO.getAll();
        List<Position> positions = posDAO.getAll();

        // Lọc bỏ tài khoản Admin và tài khoản của chính người đang đăng nhập
        List<User> filteredUsers = users.stream()
                .filter(u -> u.getRoleId() != 1 && u.getUserId() != currentUser.getUserId())
                .collect(java.util.stream.Collectors.toList());

        request.setAttribute("users", filteredUsers);
        request.setAttribute("departments", departments);
        request.setAttribute("positions", positions);

        request.getRequestDispatcher("/hr/employee-list.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
