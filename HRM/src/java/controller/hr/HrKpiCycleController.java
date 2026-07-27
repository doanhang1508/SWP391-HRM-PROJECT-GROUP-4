package controller.hr;

import dao.KpiDAO;
import model.KpiCycle;
import model.KpiTemplate;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Date;
import java.sql.Timestamp;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet(name = "HrKpiCycleController", urlPatterns = {"/hr/kpi-cycles"})
public class HrKpiCycleController extends HttpServlet {

    private final KpiDAO kpiDAO = new KpiDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("currentUser");
        if (user.getRoleId() != 2 && user.getRoleId() != 5) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        // List cycles
        List<KpiCycle> cycles = kpiDAO.getAllCycles();
        
        // List templates to choose from when creating a cycle
        List<KpiTemplate> templates = kpiDAO.getAllTemplates().stream()
                .filter(t -> t.getStatus() == 1) // only active templates
                .collect(Collectors.toList());

        request.setAttribute("cycleList", cycles);
        request.setAttribute("templateList", templates);
        request.getRequestDispatcher("/hr/kpi-cycles.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("currentUser");
        if (user.getRoleId() != 2 && user.getRoleId() != 5) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        String action = request.getParameter("action");

        if ("create".equals(action)) {
            String name = request.getParameter("name");
            String startDateStr = request.getParameter("startDate");
            String endDateStr = request.getParameter("endDate");
            String deadlineStr = request.getParameter("deadline");
            String templateIdStr = request.getParameter("templateId");
            String status = request.getParameter("status"); // 'DRAFT' or 'ACTIVE'

            try {
                Date startDate = Date.valueOf(startDateStr);
                Date endDate = Date.valueOf(endDateStr);
                Date deadline = Date.valueOf(deadlineStr);
                int templateId = Integer.parseInt(templateIdStr);

                // Validate: Hạn tự đánh giá của NV không được là ngày trong quá khứ
                java.time.LocalDate today = java.time.LocalDate.now();
                java.time.LocalDate deadlineLocalDate = deadline.toLocalDate();
                if (deadlineLocalDate.isBefore(today)) {
                    response.sendRedirect(request.getContextPath() + "/hr/kpi-cycles?error=deadline_past");
                    return;
                }

                KpiCycle cycle = new KpiCycle(0, name, startDate, endDate, deadline, templateId, status,
                        new Timestamp(System.currentTimeMillis()), user.getUserId(), new Timestamp(System.currentTimeMillis()));

                int cycleId = kpiDAO.insertCycle(cycle);

                if (cycleId > 0 && "ACTIVE".equals(status)) {
                    // Automatically initialize evaluations for active employees
                    kpiDAO.initializeEvaluationsForCycle(cycleId);
                }
                
                response.sendRedirect(request.getContextPath() + "/hr/kpi-cycles?success=1");
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/hr/kpi-cycles?error=invalid_data");
            }

        } else if ("updateStatus".equals(action)) {
            String idStr = request.getParameter("id");
            String newStatus = request.getParameter("status");

            if (idStr != null && !idStr.isEmpty() && newStatus != null) {
                int cycleId = Integer.parseInt(idStr);
                
                // Get the old cycle to see if we transition to ACTIVE
                KpiCycle oldCycle = kpiDAO.getCycleById(cycleId);
                
                boolean updated = kpiDAO.updateCycleStatus(cycleId, newStatus);
                if (updated) {
                    if (oldCycle != null && !"ACTIVE".equals(oldCycle.getStatus()) && "ACTIVE".equals(newStatus)) {
                        // Automatically initialize evaluations when activating a cycle
                        kpiDAO.initializeEvaluationsForCycle(cycleId);
                    }
                    response.sendRedirect(request.getContextPath() + "/hr/kpi-cycles?success=status_updated");
                } else {
                    response.sendRedirect(request.getContextPath() + "/hr/kpi-cycles?error=update_failed");
                }
            } else {
                response.sendRedirect(request.getContextPath() + "/hr/kpi-cycles?error=missing_params");
            }
        }
    }
}
