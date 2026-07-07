package controller.hr;

import dao.DepartmentDAO;
import dao.EmployeeContractDAO;
import dao.EmployeeProfileDAO;
import dao.OnboardingDAO;
import dao.UserDAO;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

@WebServlet(name = "HrDashboardController", urlPatterns = {"/hr/dashboard"})
public class HrDashboardController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if (currentUser.getRoleId() != 2 && currentUser.getRoleId() != 5) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        // ── Code gốc — chạy cho CẢ HAI role (2 + 5), giữ nguyên 100% ──
        UserDAO userDAO = new UserDAO();
        DepartmentDAO deptDAO = new DepartmentDAO();

        int totalEmployees   = userDAO.getTotalUsers();
        int activeEmployees  = userDAO.getActiveUsers();
        int totalDepartments = deptDAO.getAll().size();

        request.setAttribute("totalEmployees",   totalEmployees);
        request.setAttribute("activeEmployees",  activeEmployees);
        request.setAttribute("totalDepartments", totalDepartments);

        List<User> recentEmployees = userDAO.getAllUsers();
        if (recentEmployees.size() > 5) {
            recentEmployees = recentEmployees.subList(recentEmployees.size() - 5, recentEmployees.size());
        }
        request.setAttribute("recentEmployees", recentEmployees);

        request.setAttribute("expiringContracts", 0);
        request.setAttribute("pendingLeaves", 0);

        // ── TuVV: HR Staff Dashboard — thêm attribute khi roleId == 5 ──
        if (currentUser.getRoleId() == 5) {
            try {
                EmployeeContractDAO contractDAO = new EmployeeContractDAO();
                OnboardingDAO onboardingDAO = new OnboardingDAO();
                EmployeeProfileDAO profileDAO = new EmployeeProfileDAO();
                int userId = currentUser.getUserId();

                // Card: Hợp đồng sắp hết hạn (30 ngày tới)
                int expiringContractCount = contractDAO.getExpiringContracts(30).size();
                request.setAttribute("expiringContractCount", expiringContractCount);

                // Card: Hợp đồng sắp hết hạn (7 ngày tới) — dùng cho bảng "việc cần xử lý"
                int expiringContract7Days = contractDAO.getExpiringContracts(7).size();
                request.setAttribute("expiringContract7Days", expiringContract7Days);

                // Card: Chờ nhân viên ký
                int pendingSignatureCount = contractDAO.countPendingSignatureContracts();
                request.setAttribute("pendingSignatureCount", pendingSignatureCount);

                // Card: Hồ sơ onboarding chờ duyệt (PENDING, do user tạo)
                int onboardingPendingCount = onboardingDAO.countByCreatorAndStatus(userId, "PENDING");
                request.setAttribute("onboardingPendingCount", onboardingPendingCount);

                // Card: Hồ sơ onboarding bị từ chối (REJECTED, do user tạo)
                int onboardingRejectedCount = onboardingDAO.countByCreatorAndStatus(userId, "REJECTED");
                request.setAttribute("onboardingRejectedCount", onboardingRejectedCount);

                // Khu vực: Tiến độ nhập hồ sơ — lấy tất cả status 1 lần
                Map<String, Integer> onboardingStatusCounts = onboardingDAO.getStatusCountsByCreator(userId);
                request.setAttribute("onboardingDraftCount",    onboardingStatusCounts.getOrDefault("DRAFT", 0));
                request.setAttribute("onboardingPendingCountAll", onboardingStatusCounts.getOrDefault("PENDING", 0));
                request.setAttribute("onboardingApprovedCount", onboardingStatusCounts.getOrDefault("APPROVED", 0));
                request.setAttribute("onboardingRejectedCountAll", onboardingStatusCounts.getOrDefault("REJECTED", 0));

                // Khu vực: Cảnh báo dữ liệu còn thiếu
                Map<String, Integer> missingData = profileDAO.countMissingDataFields();
                request.setAttribute("missingBankCount",      missingData.getOrDefault("missingBank", 0));
                request.setAttribute("missingTaxCount",       missingData.getOrDefault("missingTax", 0));
                request.setAttribute("missingSocialInsCount", missingData.getOrDefault("missingSocialIns", 0));

                // Bảng: Việc cần xử lý — tổng hợp thành list
                List<Map<String, Object>> taskList = new ArrayList<>();

                Map<String, Object> task1 = new HashMap<>();
                task1.put("name", "Hợp đồng hết hạn trong 7 ngày");
                task1.put("count", expiringContract7Days);
                task1.put("level", expiringContract7Days > 0 ? "danger" : "success");
                task1.put("link", request.getContextPath() + "/hr/contracts?status=expiring");
                taskList.add(task1);

                Map<String, Object> task2 = new HashMap<>();
                task2.put("name", "Hợp đồng chờ nhân viên ký");
                task2.put("count", pendingSignatureCount);
                task2.put("level", pendingSignatureCount > 0 ? "warning" : "success");
                task2.put("link", request.getContextPath() + "/hr/contracts");
                taskList.add(task2);

                Map<String, Object> task3 = new HashMap<>();
                task3.put("name", "Hồ sơ onboarding bị từ chối");
                task3.put("count", onboardingRejectedCount);
                task3.put("level", onboardingRejectedCount > 0 ? "danger" : "success");
                task3.put("link", request.getContextPath() + "/hr/onboarding/list");
                taskList.add(task3);

                Map<String, Object> task4 = new HashMap<>();
                task4.put("name", "Hồ sơ onboarding chờ duyệt");
                task4.put("count", onboardingPendingCount);
                task4.put("level", onboardingPendingCount > 0 ? "warning" : "success");
                task4.put("link", request.getContextPath() + "/hr/onboarding/list");
                taskList.add(task4);

                request.setAttribute("taskList", taskList);

            } catch (Exception e) {
                // Fallback an toàn — set default nếu DAO lỗi
                e.printStackTrace();
                request.setAttribute("expiringContractCount", 0);
                request.setAttribute("expiringContract7Days", 0);
                request.setAttribute("pendingSignatureCount", 0);
                request.setAttribute("onboardingPendingCount", 0);
                request.setAttribute("onboardingRejectedCount", 0);
                request.setAttribute("onboardingDraftCount", 0);
                request.setAttribute("onboardingPendingCountAll", 0);
                request.setAttribute("onboardingApprovedCount", 0);
                request.setAttribute("onboardingRejectedCountAll", 0);
                request.setAttribute("missingBankCount", 0);
                request.setAttribute("missingTaxCount", 0);
                request.setAttribute("missingSocialInsCount", 0);
                request.setAttribute("taskList", new ArrayList<>());
            }
        }

        request.getRequestDispatcher("/hr/dashboard.jsp").forward(request, response);
    }
}
