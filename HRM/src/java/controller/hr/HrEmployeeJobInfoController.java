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

/**
 * HrEmployeeJobInfoController — Xem thông tin công việc của nhân viên (dành cho HR).
 * URL: /hr/employee-job-info?userId=...  (GET)
 */
@WebServlet(name = "HrEmployeeJobInfoController", urlPatterns = {"/hr/employee-job-info", "/manager/employee-job-info"})
public class HrEmployeeJobInfoController extends HttpServlet {

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

        // HR Manager(2), HR Staff(5), Quản đốc(3), Trưởng phòng(6)
        if (roleId != 2 && roleId != 3 && roleId != 5 && roleId != 6) {
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

            // Load department & position for profile header and job info tab
            DepartmentDAO deptDAO = new DepartmentDAO();
            PositionDAO posDAO = new PositionDAO();
            RoleDAO roleDAO = new RoleDAO();

            Department dept = null;
            Position pos = null;
            Role userRole = roleDAO.getRoleById(employee.getRoleId());

            for (Department d : deptDAO.getAll()) {
                if (d.getDepartmentId() == employee.getDepartmentId()) {
                    dept = d;
                    break;
                }
            }

            for (Position p : posDAO.getAll()) {
                if (p.getPositionId() == employee.getPositionId()) {
                    pos = p;
                    break;
                }
            }

            request.setAttribute("employee", employee);
            request.setAttribute("empDept", dept);
            request.setAttribute("empPos", pos);
            request.setAttribute("userRole", userRole);

            request.getRequestDispatcher("/hr/employee-job-info.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/hr/employees");
        }
    }
}
