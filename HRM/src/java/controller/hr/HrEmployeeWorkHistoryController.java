package controller.hr;

import dao.DepartmentDAO;
import dao.PositionDAO;
import dao.UserDAO;
import dao.WorkHistoryDAO;
import model.Department;
import model.Position;
import model.User;
import model.WorkHistory;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

/**
 * HrEmployeeWorkHistoryController — Xem lịch sử công tác của nhân viên (dành cho HR).
 * URL: /hr/employee-work-history?userId=...  (GET)
 */
@WebServlet(name = "HrEmployeeWorkHistoryController", urlPatterns = {"/hr/employee-work-history", "/manager/employee-work-history"})
public class HrEmployeeWorkHistoryController extends HttpServlet {

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

            // Load department & position for profile header
            DepartmentDAO deptDAO = new DepartmentDAO();
            PositionDAO posDAO = new PositionDAO();

            Department dept = null;
            Position pos = null;

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

            // Load work history
            WorkHistoryDAO workHistoryDAO = new WorkHistoryDAO();
            List<WorkHistory> workHistory = workHistoryDAO.getByUserId(userId);

            request.setAttribute("employee", employee);
            request.setAttribute("empDept", dept);
            request.setAttribute("empPos", pos);
            request.setAttribute("workHistory", workHistory);

            request.getRequestDispatcher("/hr/employee-work-history.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/hr/employees");
        }
    }
}
