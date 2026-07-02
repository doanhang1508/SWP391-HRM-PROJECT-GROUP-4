package controller.employee;

import dao.KpiDAO;
import model.KpiComment;
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
import java.util.List;

@WebServlet(name = "EmployeeKpiController", urlPatterns = {"/employee/kpi-view"})
public class EmployeeKpiController extends HttpServlet {

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

        // Fetch evaluations for the logged-in employee
        List<KpiEvaluation> evaluations = kpiDAO.getEvaluationsByEmployee(user.getUserId());
        request.setAttribute("evaluations", evaluations);

        String idStr = request.getParameter("id");
        if (idStr != null && !idStr.isEmpty()) {
            int evaluationId = Integer.parseInt(idStr);
            KpiEvaluation eval = kpiDAO.getEvaluationById(evaluationId);

            // Access control: Employee can only see their own evaluation
            if (eval != null && eval.getEmployeeId() == user.getUserId()) {
                List<KpiEvaluationItem> items = kpiDAO.getEvaluationItems(evaluationId);
                List<KpiComment> comments = kpiDAO.getComments(evaluationId);

                request.setAttribute("selectedEval", eval);
                request.setAttribute("items", items);
                request.setAttribute("comments", comments);
            } else {
                request.setAttribute("error", "Bạn không có quyền truy cập bản đánh giá này.");
            }
        }

        request.getRequestDispatcher("/employee/kpi-view.jsp").forward(request, response);
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
        String action = request.getParameter("action");

        if ("addComment".equals(action)) {
            String evaluationIdStr = request.getParameter("evaluationId");
            String commentText = request.getParameter("commentText");

            if (evaluationIdStr != null && !evaluationIdStr.isEmpty() && commentText != null && !commentText.trim().isEmpty()) {
                int evaluationId = Integer.parseInt(evaluationIdStr);
                if (kpiDAO.isCycleLockedByEvaluationId(evaluationId)) {
                    response.sendRedirect(request.getContextPath() + "/employee/kpi-view?id=" + evaluationId + "&error=cycle_locked");
                    return;
                }
                KpiEvaluation eval = kpiDAO.getEvaluationById(evaluationId);

                // Access control
                if (eval != null && eval.getEmployeeId() == user.getUserId()) {
                    KpiComment comment = new KpiComment();
                    comment.setEvaluationId(evaluationId);
                    comment.setUserId(user.getUserId());
                    comment.setCommentText(commentText.trim());
                    
                    // Determine role type for comment
                    String type = "EMPLOYEE";
                    if (user.getRoleId() == 3 || user.getRoleId() == 6) {
                        type = "MANAGER";
                    } else if (user.getRoleId() == 2 || user.getRoleId() == 4) {
                        type = "REVIEWER";
                    }
                    comment.setType(type);

                    boolean success = kpiDAO.insertComment(comment);
                    if (success) {
                        response.sendRedirect(request.getContextPath() + "/employee/kpi-view?id=" + evaluationId + "&success=comment_added");
                        return;
                    }
                }
            }
        }
        response.sendRedirect(request.getContextPath() + "/employee/kpi-view?error=comment_failed");
    }
}
