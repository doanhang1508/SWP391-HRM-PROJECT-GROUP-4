package controller.manager;

import dao.KpiDAO;
import model.KpiCycle;
import model.KpiEvaluation;
import model.KpiEvaluationItem;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "ManagerKpiApprovalController", urlPatterns = {"/manager/kpi-approvals"})
public class ManagerKpiApprovalController extends HttpServlet {

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
        // Department heads, HR Manager, Director, Admin can access approval workspace
        if (user.getRoleId() == 7 || user.getRoleId() == 8) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        // Get list of all cycles
        List<KpiCycle> cycles = kpiDAO.getAllCycles();
        request.setAttribute("cycles", cycles);

        String cycleIdStr = request.getParameter("cycleId");
        int cycleId = -1;
        if (cycleIdStr != null && !cycleIdStr.isEmpty()) {
            cycleId = Integer.parseInt(cycleIdStr);
        } else if (!cycles.isEmpty()) {
            cycleId = cycles.get(0).getCycleId();
        }

        List<KpiEvaluation> submittedEvaluations = new ArrayList<>();
        if (cycleId > 0) {
            // Get all evaluations for the cycle
            List<KpiEvaluation> allEvals = kpiDAO.getEvaluationsByCycle(cycleId);
            
            // Filter evaluations depending on the user's role:
            // Admin, HR Manager, Director see everything
            // Department Managers / Factory Managers only see evaluations they need to review 
            // (e.g. subordinates in their department, or they might review evaluations from other managers under calibration)
            // Let's list submitted ones for approval.
            for (KpiEvaluation eval : allEvals) {
                if ("SUBMITTED".equals(eval.getStatus()) || "APPROVED".equals(eval.getStatus()) || "REJECTED".equals(eval.getStatus())) {
                    if (user.getRoleId() == 1 || user.getRoleId() == 2 || user.getRoleId() == 4) {
                        submittedEvaluations.add(eval);
                    } else {
                        // For other reviewers, only show evaluations of their department or where they are designated reviewer
                        // Wait, a Department Manager also evaluates their own employees. For calibration/approval, usually HR or Director approves.
                        // But if they are department heads, they can approve subordinate managers.
                        // Let's show evaluations where department matches or manager is correct.
                        // Since they are department managers, we can let them see evaluations of employees in their department.
                        if (eval.getManagerId() == user.getUserId()) {
                            submittedEvaluations.add(eval);
                        }
                    }
                }
            }
        }

        // Handle detailed viewing of evaluation items for a popup/details panel
        String viewIdStr = request.getParameter("viewId");
        if (viewIdStr != null && !viewIdStr.isEmpty()) {
            int viewId = Integer.parseInt(viewIdStr);
            KpiEvaluation detailEval = kpiDAO.getEvaluationById(viewId);
            if (detailEval != null) {
                List<KpiEvaluationItem> detailItems = kpiDAO.getEvaluationItems(viewId);
                request.setAttribute("detailEval", detailEval);
                request.setAttribute("detailItems", detailItems);
                request.setAttribute("statusHistory", kpiDAO.getStatusHistory(viewId));
                request.setAttribute("auditLogs", kpiDAO.getAuditLogs(viewId));
            }
        }

        request.setAttribute("selectedCycleId", cycleId);
        request.setAttribute("evaluations", submittedEvaluations);
        request.getRequestDispatcher("/manager/kpi-approvals.jsp").forward(request, response);
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
        if (user.getRoleId() == 7 || user.getRoleId() == 8) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        String action = request.getParameter("action");
        String evaluationIdStr = request.getParameter("evaluationId");
        String note = request.getParameter("note");

        if (evaluationIdStr != null && !evaluationIdStr.isEmpty() && action != null) {
            int evaluationId = Integer.parseInt(evaluationIdStr);
            KpiEvaluation eval = kpiDAO.getEvaluationById(evaluationId);

            if (eval != null && "SUBMITTED".equals(eval.getStatus())) {
                String targetStatus = "approve".equals(action) ? "APPROVED" : "REJECTED";
                
                boolean updated = kpiDAO.updateEvaluationStatus(evaluationId, targetStatus, user.getUserId(), note);
                if (updated) {
                    response.sendRedirect(request.getContextPath() + "/manager/kpi-approvals?cycleId=" + eval.getCycleId() + "&success=" + targetStatus.toLowerCase());
                    return;
                }
            }
        }
        response.sendRedirect(request.getContextPath() + "/manager/kpi-approvals?error=action_failed");
    }
}
