package controller.admin;

import dao.DepartmentDAO;
import dao.UserDAO;
import dao.OnboardingDAO;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import org.json.JSONArray;
import org.json.JSONObject;

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

        // ── Thống kê Onboarding ──
        OnboardingDAO onboardingDAO = new OnboardingDAO();
        request.setAttribute("onboardingTotal", onboardingDAO.countByStatus("ALL"));
        request.setAttribute("onboardingPending", onboardingDAO.countByStatus("PENDING"));
        request.setAttribute("onboardingApproved", onboardingDAO.countByStatus("APPROVED"));
        request.setAttribute("onboardingRejected", onboardingDAO.countByStatus("REJECTED"));

        // ── Dữ liệu Biểu đồ ──
        // 1. Phân bổ vai trò
        Map<String, Integer> roleDist = userDAO.getUserRoleDistribution();
        JSONArray roleLabels = new JSONArray();
        JSONArray roleValues = new JSONArray();
        for (Map.Entry<String, Integer> entry : roleDist.entrySet()) {
            roleLabels.put(entry.getKey());
            roleValues.put(entry.getValue());
        }
        request.setAttribute("roleLabels", roleLabels.toString());
        request.setAttribute("roleValues", roleValues.toString());

        // 2. Tăng trưởng người dùng 6 tháng qua
        Map<String, Integer> userGrowth = userDAO.getNewUsersLast6Months();
        JSONArray growthLabels = new JSONArray();
        JSONArray growthValues = new JSONArray();
        for (Map.Entry<String, Integer> entry : userGrowth.entrySet()) {
            growthLabels.put(entry.getKey());
            growthValues.put(entry.getValue());
        }
        request.setAttribute("growthLabels", growthLabels.toString());
        request.setAttribute("growthValues", growthValues.toString());

        List<User> recentUsers = userDAO.getAllUsers();
        if (recentUsers.size() > 10) {
            recentUsers = recentUsers.subList(recentUsers.size() - 10, recentUsers.size());
        }
        request.setAttribute("recentUsers", recentUsers);

        request.getRequestDispatcher("/admin/dashboard.jsp").forward(request, response);
    }
}
