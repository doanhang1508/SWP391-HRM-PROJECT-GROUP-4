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
 * HrEmployeeController — Danh sách hồ sơ nhân viên dành cho bộ phận HR.
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

        // Chỉ HR Manager (2) và HR Staff (5) được phép truy cập
        if (roleId != 2 && roleId != 5) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        UserDAO userDAO = new UserDAO();
        DepartmentDAO deptDAO = new DepartmentDAO();
        PositionDAO posDAO = new PositionDAO();

        String keyword = request.getParameter("keyword");
        String deptFilter = request.getParameter("departmentId");
        String posFilter = request.getParameter("positionId");

        if (keyword == null) keyword = "";

        List<User> users;

        if (deptFilter != null && !deptFilter.isEmpty()) {
            try {
                int departmentId = Integer.parseInt(deptFilter);
                users = userDAO.getByDepartment(departmentId);
                for (Department d : deptDAO.getAll()) {
                    if (d.getDepartmentId() == departmentId) {
                        request.setAttribute("filterName", "Phòng " + d.getDepartmentName());
                        break;
                    }
                }
            } catch (NumberFormatException e) {
                users = userDAO.getAllUsers();
            }
        } else if (posFilter != null && !posFilter.isEmpty()) {
            try {
                int positionId = Integer.parseInt(posFilter);
                users = userDAO.getByPosition(positionId);
                for (Position p : posDAO.getAll()) {
                    if (p.getPositionId() == positionId) {
                        request.setAttribute("filterName", "Chức vụ " + p.getPositionName());
                        break;
                    }
                }
            } catch (NumberFormatException e) {
                users = userDAO.getAllUsers();
            }
        } else {
            users = userDAO.searchUsersByName(keyword.trim());
        }

        List<Department> departments = deptDAO.getAll();
        List<Position> positions = posDAO.getAll();

        // Lọc bỏ tài khoản Admin (Role 1) và tài khoản của chính người đang đăng nhập
        List<User> filteredUsers = users.stream()
                .filter(u -> u.getRoleId() != 1 && u.getUserId() != currentUser.getUserId())
                .collect(java.util.stream.Collectors.toList());

        request.setAttribute("users", filteredUsers);
        request.setAttribute("departments", departments);
        request.setAttribute("positions", positions);
        request.setAttribute("keyword", keyword);
        request.setAttribute("selectedDept", deptFilter);
        request.setAttribute("selectedPos", posFilter);

        request.getRequestDispatcher("/hr/employee-list.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
