package controller.director;

import dao.UserDAO;
import dao.KpiDAO;
import dao.ResignationDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.StringJoiner;

/**
 * DirectorDashboardController — Dashboard tổng quan cho Giám đốc (role 4).
 */
@WebServlet(name = "DirectorDashboardController", urlPatterns = {"/director/dashboard"})
public class DirectorDashboardController extends HttpServlet {

    private static final int ROLE_DIRECTOR = 4;

    private UserDAO userDAO;
    private KpiDAO kpiDAO;
    private ResignationDAO resignationDAO;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
        kpiDAO = new KpiDAO();
        resignationDAO = new ResignationDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = getCurrentUser(req);
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        if (user.getRoleId() != ROLE_DIRECTOR) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }

        // Số liệu tổng hợp
        req.setAttribute("totalEmployees", userDAO.getTotalUsers());
        req.setAttribute("activeEmployees", userDAO.getActiveUsers());

        // 1. KPI Average Scores
        List<Map<String, Object>> kpiData = kpiDAO.getAverageKpiScorePerCycle();
        StringJoiner kpiLabels = new StringJoiner("','", "'", "'");
        StringJoiner kpiScores = new StringJoiner(",");
        if (kpiData.isEmpty()) {
            kpiLabels = new StringJoiner("");
            kpiScores = new StringJoiner("");
        } else {
            for (Map<String, Object> map : kpiData) {
                kpiLabels.add((String) map.get("cycleName"));
                kpiScores.add(String.valueOf(map.get("avgScore")));
            }
        }
        req.setAttribute("kpiLabels", kpiLabels.toString());
        req.setAttribute("kpiScores", kpiScores.toString());
        req.setAttribute("kpiHasData", !kpiData.isEmpty());

        // 2. Turnover Rates
        List<Map<String, Object>> turnoverData = resignationDAO.getMonthlyTurnoverStats();
        StringJoiner turnoverLabels = new StringJoiner("','", "'", "'");
        StringJoiner turnoverRates = new StringJoiner(",");
        int activeUsers = userDAO.getActiveUsers();
        if (activeUsers == 0) activeUsers = 1; // Prevent div by 0

        if (turnoverData.isEmpty()) {
            turnoverLabels = new StringJoiner("");
            turnoverRates = new StringJoiner("");
        } else {
            for (Map<String, Object> map : turnoverData) {
                turnoverLabels.add((String) map.get("month"));
                int resCount = (int) map.get("resignationCount");
                // Tỉ lệ = (Số người nghỉ / Tổng nhân sự active hiện tại) * 100
                double rate = (double) resCount / activeUsers * 100;
                turnoverRates.add(String.format(java.util.Locale.US, "%.2f", rate));
            }
        }
        req.setAttribute("turnoverLabels", turnoverLabels.toString());
        req.setAttribute("turnoverRates", turnoverRates.toString());
        req.setAttribute("turnoverHasData", !turnoverData.isEmpty());

        req.getRequestDispatcher("/director/dashboard.jsp").forward(req, resp);
    }

    private User getCurrentUser(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        return s != null ? (User) s.getAttribute("currentUser") : null;
    }
}
