package controller;

import dao.DepartmentDAO;
import dao.LeaveRequestDAOImpl;
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

/**
 * UnifiedDashboardController — Một controller duy nhất phục vụ /dashboard.
 *
 * Phân quyền theo roleId:
 *   1 = Admin        → stat: users, roles, locked accounts
 *   2 = HR Manager   → stat: employees, departments, pending leaves
 *   3 = Factory Mgr  → stat: employees, shifts, pending OT
 *   4 = Director     → stat: all employees, departments, summary
 *
 * Forward tới /dashboard.jsp (một file JSP duy nhất,
 * sử dụng <c:choose> để render nội dung theo role).
 */
@WebServlet(name = "UnifiedDashboardController", urlPatterns = {"/dashboard"})
public class UnifiedDashboardController extends HttpServlet {

    private static final int ROLE_ADMIN    = 1;
    private static final int ROLE_HR       = 2;
    private static final int ROLE_FACTORY  = 3;
    private static final int ROLE_DIRECTOR = 4;
    private static final int ROLE_HR_STAFF = 5;
    private static final int ROLE_DEPT_MGR = 6;
    private static final int ROLE_EMPLOYEE = 7;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        // Chưa đăng nhập
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        int roleId = currentUser.getRoleId();

        // Chỉ Employee (role 7) và role không xác định (0) mới bị đẩy ra employee/dashboard
        if (roleId == 0 || roleId == ROLE_EMPLOYEE) {
            response.sendRedirect(request.getContextPath() + "/employee/dashboard");
            return;
        }

        // ── Load dữ liệu chung ──
        UserDAO userDAO       = new UserDAO();
        DepartmentDAO deptDAO = new DepartmentDAO();

        int totalEmployees   = userDAO.getTotalUsers();
        int activeEmployees  = userDAO.getActiveUsers();
        int totalDepartments = deptDAO.getAll().size();

        request.setAttribute("totalEmployees",   totalEmployees);
        request.setAttribute("activeEmployees",  activeEmployees);
        request.setAttribute("totalDepartments", totalDepartments);

        // ── Load dữ liệu theo role ──
        if (roleId == ROLE_ADMIN) {
            loadAdminData(request, userDAO);
        } else if (roleId == ROLE_HR || roleId == ROLE_HR_STAFF) {
            // HR Manager (2) và HR Staff (5) dùng chung HR dashboard
            loadHrData(request, userDAO);
        } else if (roleId == ROLE_FACTORY) {
            loadFactoryData(request, userDAO);
        } else if (roleId == ROLE_DIRECTOR) {
            loadDirectorData(request, userDAO, deptDAO);
        } else if (roleId == ROLE_DEPT_MGR) {
            // Department Manager (6)
            loadDeptManagerData(request, userDAO);
        }

        request.getRequestDispatcher("/dashboard.jsp").forward(request, response);
    }

    // ── Admin: user stats, locked accounts, pending requests ──
    private void loadAdminData(HttpServletRequest request, UserDAO userDAO) {
        int totalUsers   = userDAO.getTotalUsers();
        int activeUsers  = userDAO.getActiveUsers();
        int lockedUsers  = totalUsers - activeUsers;
        int totalRoles   = userDAO.getTotalRoles();

        request.setAttribute("totalUsers",  totalUsers);
        request.setAttribute("activeUsers", activeUsers);
        request.setAttribute("lockedUsers", lockedUsers);
        request.setAttribute("totalRoles",  totalRoles);

        // Danh sách người dùng gần đây (10 người)
        List<User> recentUsers = userDAO.getAllUsers();
        if (recentUsers.size() > 10) {
            recentUsers = recentUsers.subList(recentUsers.size() - 10, recentUsers.size());
        }
        request.setAttribute("recentUsers", recentUsers);
    }

    // ── HR Manager: employees, departments, leaves ──
    private void loadHrData(HttpServletRequest request, UserDAO userDAO) {
        // Nhân viên mới nhất (5 người)
        List<User> recentEmployees = userDAO.getAllUsers();
        if (recentEmployees.size() > 5) {
            recentEmployees = recentEmployees.subList(
                    recentEmployees.size() - 5, recentEmployees.size());
        }
        request.setAttribute("recentEmployees", recentEmployees);

        // Placeholder — thay bằng DAO thực khi có
        request.setAttribute("expiringContracts", 0);
        request.setAttribute("pendingLeaves", 0);
    }

    // ── Factory Manager: employees in factory, shifts, OT ──
    private void loadFactoryData(HttpServletRequest request, UserDAO userDAO) {
        request.setAttribute("pendingOT", 0);
        request.setAttribute("todayAttendance", 0);
    }

    // ── Director: full overview ──
    private void loadDirectorData(HttpServletRequest request,
                                  UserDAO userDAO, DepartmentDAO deptDAO) {
        request.setAttribute("totalRoles",  userDAO.getTotalRoles());
        // Placeholder KPIs — thay bằng DAO thực khi có
        request.setAttribute("monthlyRevenue",    0);
        request.setAttribute("employeeGrowth",    0);
    }

    // ── Department Manager: nhân viên trong phòng ban ──
    private void loadDeptManagerData(HttpServletRequest request, UserDAO userDAO) {
        // Placeholder — thay bằng DAO thực khi có
        request.setAttribute("pendingLeaves",     0);
        request.setAttribute("pendingOT",         0);
        request.setAttribute("todayAttendance",   0);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
