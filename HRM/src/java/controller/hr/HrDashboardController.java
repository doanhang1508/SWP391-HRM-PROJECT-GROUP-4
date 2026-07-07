package controller.hr;

import dao.DepartmentDAO;
import dao.EmployeeContractDAO;
import dao.OnboardingDAO;
import dao.PayrollDAO;
import dao.UserDAO;
import java.io.IOException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.EmployeeContract;
import model.OnboardingRequest;
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

        //HR Staff Dashboard — thêm attribute khi roleId == 5 ──
        if (currentUser.getRoleId() == 5) {
            try {
                EmployeeContractDAO contractDAO = new EmployeeContractDAO();
                OnboardingDAO onboardingDAO = new OnboardingDAO();
                PayrollDAO payrollDAO = new PayrollDAO();
                int userId = currentUser.getUserId();

                // === STAT CARDS ===
                List<EmployeeContract> expiringList = contractDAO.getExpiringContracts(30);
                request.setAttribute("expiringContractCount", expiringList.size());

                int pendingSignatureCount = contractDAO.countPendingSignatureContracts();
                request.setAttribute("pendingSignatureCount", pendingSignatureCount);

                Map<String, Integer> onboardingCounts = onboardingDAO.getStatusCountsByCreator(userId);
                int onboardingPending  = onboardingCounts.getOrDefault("PENDING",  0);
                int onboardingRejected = onboardingCounts.getOrDefault("REJECTED", 0);
                int onboardingDraft    = onboardingCounts.getOrDefault("DRAFT",    0);
                int onboardingApproved = onboardingCounts.getOrDefault("APPROVED", 0);
                request.setAttribute("onboardingPendingCount",  onboardingPending);
                request.setAttribute("onboardingRejectedCount", onboardingRejected);

                // === CHART 1: Phân bố trạng thái hợp đồng (donut) ===
                Map<String, Integer> contractCounts = contractDAO.getContractCounts();
                int cActive     = contractCounts.getOrDefault("active",     0);
                int cPending    = contractCounts.getOrDefault("pending",    0);
                int cExpired    = contractCounts.getOrDefault("expired",    0);
                int cExpiring   = contractCounts.getOrDefault("expiring",   0);
                int cTerminated = contractCounts.getOrDefault("terminated", 0);
                request.setAttribute("contractCountActive",     cActive);
                request.setAttribute("contractCountPending",    cPending);
                request.setAttribute("contractCountExpired",    cExpired);
                request.setAttribute("contractCountExpiring",   cExpiring);
                request.setAttribute("contractCountTerminated", cTerminated);
                // flag: có dữ liệu không (tránh chart rỗng)
                request.setAttribute("contractChartHasData", (cActive + cPending + cExpired + cExpiring + cTerminated) > 0);

                // === CHART 2: Pipeline Onboarding của HR Staff này (bar) ===
                request.setAttribute("onboardingDraftCount",      onboardingDraft);
                request.setAttribute("onboardingPendingCountAll", onboardingPending);
                request.setAttribute("onboardingApprovedCount",   onboardingApproved);
                request.setAttribute("onboardingRejectedCountAll",onboardingRejected);
                request.setAttribute("onboardingChartHasData",
                    (onboardingDraft + onboardingPending + onboardingApproved + onboardingRejected) > 0);

                // === CHART 3: Loại hợp đồng (donut) ===
                List<Map<String, Object>> contractTypeStats = contractDAO.getContractTypeStats();
                List<String> ctLabels = new ArrayList<>();
                List<Integer> ctData  = new ArrayList<>();
                for (Map<String, Object> row : contractTypeStats) {
                    ctLabels.add((String) row.get("typeName"));
                    ctData.add(((Number) row.get("count")).intValue());
                }
                request.setAttribute("contractTypeLabels", ctLabels);
                request.setAttribute("contractTypeData",   ctData);
                request.setAttribute("contractTypeHasData", !ctLabels.isEmpty());

                // === CHART 4: Tổng quỹ lương chi trả 6 tháng gần nhất ===
                LocalDate now = LocalDate.now();
                List<PayrollDAO.PayrollMonthSummary> allSummaries = payrollDAO.getMonthlySummaries();
                Map<String, java.math.BigDecimal> salaryMap = new java.util.HashMap<>();
                for (PayrollDAO.PayrollMonthSummary s : allSummaries) {
                    salaryMap.put(s.getYear() + "-" + s.getMonth(), s.getTotalNet());
                }

                List<String> payrollLabels      = new ArrayList<>();
                List<java.math.BigDecimal> payrollAmounts = new ArrayList<>();
                boolean payrollHasData = false;

                for (int i = 5; i >= 0; i--) {
                    LocalDate m = now.minusMonths(i);
                    int mo = m.getMonthValue(), yr = m.getYear();
                    String label = String.format("%02d/%d", mo, yr);
                    payrollLabels.add(label);

                    java.math.BigDecimal totalNet = salaryMap.getOrDefault(yr + "-" + mo, java.math.BigDecimal.ZERO);
                    if (totalNet == null) {
                        totalNet = java.math.BigDecimal.ZERO;
                    }
                    payrollAmounts.add(totalNet);
                    if (totalNet.compareTo(java.math.BigDecimal.ZERO) > 0) {
                        payrollHasData = true;
                    }
                }
                request.setAttribute("payrollLabels",    payrollLabels);
                request.setAttribute("payrollAmounts",   payrollAmounts);
                request.setAttribute("payrollHasData",   payrollHasData);

                // Stat card lương: tháng hiện tại
                int currentMonth = now.getMonthValue(), currentYear = now.getYear();
                int payrollDraftNow    = payrollDAO.countByStatus(currentMonth, currentYear, "Draft");
                int payrollPendingNow  = payrollDAO.countByStatus(currentMonth, currentYear, "Pending");
                int payrollApprovedNow = payrollDAO.countByStatus(currentMonth, currentYear, "Approved");
                int payrollPaidNow     = payrollDAO.countByStatus(currentMonth, currentYear, "Paid");
                request.setAttribute("payrollDraftCount",    payrollDraftNow);
                request.setAttribute("payrollPendingCount",  payrollPendingNow);
                request.setAttribute("payrollApprovedCount", payrollApprovedNow);
                request.setAttribute("payrollPaidCount",     payrollPaidNow);
                request.setAttribute("currentMonthLabel",    String.format("T%02d/%d", currentMonth, currentYear));

                // === BẢNG 1: Hợp đồng sắp hết hạn (top 5) ===
                List<EmployeeContract> top5Expiring = expiringList.size() > 5
                        ? expiringList.subList(0, 5) : expiringList;
                request.setAttribute("top5ExpiringContracts", top5Expiring);

                // === BẢNG 2: Hồ sơ onboarding gần nhất của HR Staff này (top 5) ===
                List<OnboardingRequest> myOnboarding = onboardingDAO.getByCreator(userId);
                List<OnboardingRequest> top5Onboarding = myOnboarding.size() > 5
                        ? myOnboarding.subList(0, 5) : myOnboarding;
                request.setAttribute("recentOnboarding", top5Onboarding);

            } catch (Exception e) {
                e.printStackTrace();
                // Safe defaults
                request.setAttribute("expiringContractCount", 0);
                request.setAttribute("pendingSignatureCount", 0);
                request.setAttribute("onboardingPendingCount", 0);
                request.setAttribute("onboardingRejectedCount", 0);
                request.setAttribute("contractCountActive", 0);
                request.setAttribute("contractCountPending", 0);
                request.setAttribute("contractCountExpired", 0);
                request.setAttribute("contractCountExpiring", 0);
                request.setAttribute("contractCountTerminated", 0);
                request.setAttribute("contractChartHasData", false);
                request.setAttribute("onboardingDraftCount", 0);
                request.setAttribute("onboardingPendingCountAll", 0);
                request.setAttribute("onboardingApprovedCount", 0);
                request.setAttribute("onboardingRejectedCountAll", 0);
                request.setAttribute("onboardingChartHasData", false);
                request.setAttribute("contractTypeLabels", new ArrayList<>());
                request.setAttribute("contractTypeData", new ArrayList<>());
                request.setAttribute("contractTypeHasData", false);
                request.setAttribute("payrollLabels", new ArrayList<>());
                request.setAttribute("payrollAmounts", new ArrayList<>());
                request.setAttribute("payrollHasData", false);
                request.setAttribute("payrollDraftCount", 0);
                request.setAttribute("payrollPendingCount", 0);
                request.setAttribute("payrollApprovedCount", 0);
                request.setAttribute("payrollPaidCount", 0);
                request.setAttribute("currentMonthLabel", "—");
                request.setAttribute("top5ExpiringContracts", new ArrayList<>());
                request.setAttribute("recentOnboarding", new ArrayList<>());
            }
        }

        request.getRequestDispatcher("/hr/dashboard.jsp").forward(request, response);
    }
}
