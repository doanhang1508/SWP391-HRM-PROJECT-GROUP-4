package controller.manager;

import dao.UserDAO;
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
 * EmployeeManagerController — Quản lý nhân viên thuộc phòng ban/xưởng cho Trưởng phòng/Quản đốc.
 */
@WebServlet(name = "EmployeeManagerController", urlPatterns = {"/manager/employees"})
public class EmployeeManagerController extends HttpServlet {

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

        // Chỉ Quản đốc (3) và Trưởng phòng (6) được phép xem
        if (roleId != 3 && roleId != 6) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        UserDAO userDAO = new UserDAO();
        // Lấy danh sách nhân viên thuộc cùng phòng ban / xưởng
        List<User> allInDept = userDAO.getByDepartment(currentUser.getDepartmentId());
        
        // Lọc bỏ chính tài khoản của Quản lý/Trưởng phòng ra khỏi danh sách
        List<User> employees = allInDept.stream()
                .filter(u -> u.getUserId() != currentUser.getUserId())
                .collect(java.util.stream.Collectors.toList());

        request.setAttribute("employees", employees);
        request.setAttribute("managerRole", roleId);

        request.getRequestDispatcher("/manager/employee-list.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
