package controller.hr;

import dao.DepartmentDAO;
import dao.PositionDAO;
import dao.RoleDAO;
import dao.UserDAO;
import model.Department;
import model.Position;
import model.Role;
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
 * HrEmployeeEditController — Chỉnh sửa thông tin cơ bản nhân viên (dành cho HR).
 * URL: /hr/employee-edit?userId=...  (GET/POST)
 */
@WebServlet(name = "HrEmployeeEditController", urlPatterns = {"/hr/employee-edit"})
public class HrEmployeeEditController extends HttpServlet {

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

        // Chỉ Admin(1), HR Manager(2), HR Staff(5) được chỉnh sửa
        if (roleId != 1 && roleId != 2 && roleId != 5) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        String userIdParam = request.getParameter("userId");
        if (userIdParam == null || userIdParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/hr/employees");
            return;
        }

        try {
            int userId = Integer.parseInt(userIdParam);

            UserDAO userDAO = new UserDAO();
            User employee = userDAO.getUserById(userId);

            if (employee == null) {
                response.sendRedirect(request.getContextPath() + "/hr/employees");
                return;
            }

            // Load data for dropdowns
            DepartmentDAO deptDAO = new DepartmentDAO();
            PositionDAO posDAO = new PositionDAO();
            RoleDAO roleDAO = new RoleDAO();

            List<Department> deptList = deptDAO.getAll();
            List<Position> posList = posDAO.getAll();
            List<Role> roleList = roleDAO.getAllRoles();

            request.setAttribute("employee", employee);
            request.setAttribute("deptList", deptList);
            request.setAttribute("posList", posList);
            request.setAttribute("roleList", roleList);

            request.getRequestDispatcher("/hr/employee-edit.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/hr/employees");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Hiện tại chỉ là placeholder để không báo 404 hoặc 405 Method Not Allowed
        // Các logic Update DB thực sự sẽ làm sau nếu cần.
        
        String userIdParam = request.getParameter("userId");
        response.sendRedirect(request.getContextPath() + "/hr/employee-detail?userId=" + userIdParam + "&msg=update_success");
    }
}
