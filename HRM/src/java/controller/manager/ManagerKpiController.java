package controller.manager;

import dao.KpiDAO;
import model.KpiCycle;
import model.KpiEvaluation;
import model.KpiEvaluationItem;
import model.KpiComment;
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

@WebServlet(name = "ManagerKpiController", urlPatterns = {"/manager/employee-kpi"})
public class ManagerKpiController extends HttpServlet {

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
        // Only managers (role 3, 6), HR (role 2, 5), Director (role 4), and Admin (role 1) can access
        if (user.getRoleId() == 7 || user.getRoleId() == 8) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        // Get active cycles
        List<KpiCycle> activeCycles = kpiDAO.getActiveCycles();
        request.setAttribute("activeCycles", activeCycles);

        String cycleIdStr = request.getParameter("cycleId");
        int cycleId = -1;
        if (cycleIdStr != null && !cycleIdStr.isEmpty()) {
            cycleId = Integer.parseInt(cycleIdStr);
        } else if (!activeCycles.isEmpty()) {
            cycleId = activeCycles.get(0).getCycleId();
        }

        List<KpiEvaluation> evaluations = new ArrayList<>();
        KpiCycle selectedCycle = null;

        if (cycleId > 0) {
            selectedCycle = kpiDAO.getCycleById(cycleId);
            // Dynamic check: Auto-initialize evaluations in case new employees were added
            kpiDAO.initializeEvaluationsForCycle(cycleId);
            
            // Get evaluations of this manager's subordinates
            evaluations = kpiDAO.getEvaluationsByCycleAndManager(cycleId, user.getUserId());
            
            // If the manager is HR or Director or Admin, they might want to see all evaluations in the system
            if (user.getRoleId() == 1 || user.getRoleId() == 2 || user.getRoleId() == 4) {
                String viewAll = request.getParameter("viewAll");
                if ("true".equals(viewAll)) {
                    evaluations = kpiDAO.getEvaluationsByCycle(cycleId);
                    request.setAttribute("viewAll", true);
                }
            }

            // Fetch evaluation items for each evaluation to render inline grid
            for (KpiEvaluation eval : evaluations) {
                eval.setEvaluationItems(kpiDAO.getEvaluationItems(eval.getEvaluationId()));
            }

            // Fetch the template items (criteria) for dynamic headers
            if (selectedCycle != null) {
                List<model.KpiTemplateItem> criteria = kpiDAO.getTemplateItems(selectedCycle.getTemplateId());
                request.setAttribute("criteria", criteria);
            }
        }

        request.setAttribute("selectedCycleId", cycleId);
        request.setAttribute("selectedCycle", selectedCycle);
        request.setAttribute("evaluations", evaluations);

        // Load detail evaluation items for editing or viewing
        String editIdStr = request.getParameter("editId");
        if (editIdStr != null && !editIdStr.isEmpty()) {
            int editId = Integer.parseInt(editIdStr);
            // Authorization check: verify this manager is authorized for this evaluation
            if (!kpiDAO.isManagerAuthorizedForEvaluation(user.getUserId(), user.getRoleId(), editId)) {
                response.sendRedirect(request.getContextPath() + "/manager/employee-kpi?error=unauthorized");
                return;
            }
            KpiEvaluation detailEval = kpiDAO.getEvaluationById(editId);
            if (detailEval != null) {
                List<KpiEvaluationItem> detailItems = kpiDAO.getEvaluationItems(editId);
                request.setAttribute("detailEval", detailEval);
                request.setAttribute("detailItems", detailItems);
                request.setAttribute("statusHistory", kpiDAO.getStatusHistory(editId));
                request.setAttribute("comments", kpiDAO.getComments(editId));
                boolean isLocked = kpiDAO.isCycleLockedByEvaluationId(editId);
                request.setAttribute("isEditMode", !isLocked);
            }
        }

        String viewIdStr = request.getParameter("viewId");
        if (viewIdStr != null && !viewIdStr.isEmpty()) {
            int viewId = Integer.parseInt(viewIdStr);
            // Authorization check: verify this manager is authorized to view this evaluation
            if (!kpiDAO.isManagerAuthorizedForEvaluation(user.getUserId(), user.getRoleId(), viewId)) {
                response.sendRedirect(request.getContextPath() + "/manager/employee-kpi?error=unauthorized");
                return;
            }
            KpiEvaluation detailEval = kpiDAO.getEvaluationById(viewId);
            if (detailEval != null) {
                List<KpiEvaluationItem> detailItems = kpiDAO.getEvaluationItems(viewId);
                request.setAttribute("detailEval", detailEval);
                request.setAttribute("detailItems", detailItems);
                request.setAttribute("statusHistory", kpiDAO.getStatusHistory(viewId));
                request.setAttribute("comments", kpiDAO.getComments(viewId));
                request.setAttribute("isEditMode", false);
            }
        }

        request.getRequestDispatcher("/manager/employee-kpi.jsp").forward(request, response);
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

        if ("autosave".equals(action)) {
            String evaluationIdStr = request.getParameter("evaluationId");
            String comment = request.getParameter("comment");
            String[] templateItemIdStrs = request.getParameterValues("templateItemId");
            String[] scoreStrs = request.getParameterValues("score");
            String[] itemCommentStrs = request.getParameterValues("itemComment");

            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");

            if (evaluationIdStr == null || evaluationIdStr.isEmpty()) {
                response.getWriter().write("{\"status\":\"error\", \"message\":\"Thiếu ID đánh giá\"}");
                return;
            }

            int evaluationId = Integer.parseInt(evaluationIdStr);

            // Authorization check: verify this manager is authorized for this evaluation
            if (!kpiDAO.isManagerAuthorizedForEvaluation(user.getUserId(), user.getRoleId(), evaluationId)) {
                response.getWriter().write("{\"status\":\"error\", \"message\":\"Bạn không có quyền chỉnh sửa đánh giá của phòng ban khác\"}");
                return;
            }

            if (kpiDAO.isCycleLockedByEvaluationId(evaluationId)) {
                response.getWriter().write("{\"status\":\"error\", \"message\":\"Đợt đánh giá đã khóa sổ (LOCKED), không thể chỉnh sửa\"}");
                return;
            }

            KpiEvaluation eval = kpiDAO.getEvaluationById(evaluationId);

            if (eval == null) {
                response.getWriter().write("{\"status\":\"error\", \"message\":\"Không tìm thấy bản đánh giá\"}");
                return;
            }

            // Verify status: Only draft or rejected evaluations can be edited
            if (!"DRAFT".equals(eval.getStatus()) && !"REJECTED".equals(eval.getStatus())) {
                response.getWriter().write("{\"status\":\"error\", \"message\":\"Bản đánh giá đã nộp hoặc được duyệt, không thể chỉnh sửa\"}");
                return;
            }

            List<KpiEvaluationItem> items = new ArrayList<>();
            if (templateItemIdStrs != null) {
                for (int i = 0; i < templateItemIdStrs.length; i++) {
                    int templateItemId = Integer.parseInt(templateItemIdStrs[i]);
                    double score = 0;
                    if (scoreStrs != null && scoreStrs.length > i && !scoreStrs[i].isEmpty()) {
                        try {
                            score = Double.parseDouble(scoreStrs[i]);
                        } catch (NumberFormatException ignored) {}
                    }
                    String itemComment = (itemCommentStrs != null && itemCommentStrs.length > i) ? itemCommentStrs[i] : "";

                    // Score range validation
                    if (score < 0 || score > 10) {
                        response.getWriter().write("{\"status\":\"error\", \"message\":\"Điểm số phải nằm trong khoảng từ 0 đến 10\"}");
                        return;
                    }

                    KpiEvaluationItem item = new KpiEvaluationItem(0, evaluationId, templateItemId, score, itemComment);
                    items.add(item);
                }
            }

            // Save items and recalculate
            boolean success = kpiDAO.saveOrUpdateEvaluationItems(evaluationId, items, user.getUserId());
            if (success) {
                // Fetch updated scores from DB to keep eval object in sync
                KpiEvaluation freshEval = kpiDAO.getEvaluationById(evaluationId);
                if (freshEval != null) {
                    eval.setScore(freshEval.getScore());
                    eval.setWeightedScore(freshEval.getWeightedScore());
                }

                // Update general comment
                eval.setComment(comment);
                eval.setUpdatedBy(user.getUserId());
                kpiDAO.updateEvaluation(eval);

                // Fetch updated scores
                KpiEvaluation updatedEval = kpiDAO.getEvaluationById(evaluationId);
                response.getWriter().write("{\"status\":\"success\", \"score\":" + updatedEval.getScore() + 
                                           ", \"weightedScore\":" + updatedEval.getWeightedScore() + "}");
            } else {
                response.getWriter().write("{\"status\":\"error\", \"message\":\"Lỗi hệ thống hoặc đợt đánh giá đã khóa sổ\"}");
            }

        } else if ("addComment".equals(action)) {
            String evaluationIdStr = request.getParameter("evaluationId");
            String commentText = request.getParameter("commentText");
            String viewAllStr = request.getParameter("viewAll");

            if (evaluationIdStr != null && !evaluationIdStr.isEmpty() && commentText != null && !commentText.trim().isEmpty()) {
                int evaluationId = Integer.parseInt(evaluationIdStr);

                // Authorization check: verify this manager is authorized for this evaluation
                if (!kpiDAO.isManagerAuthorizedForEvaluation(user.getUserId(), user.getRoleId(), evaluationId)) {
                    response.sendRedirect(request.getContextPath() + "/manager/employee-kpi?error=unauthorized");
                    return;
                }

                if (kpiDAO.isCycleLockedByEvaluationId(evaluationId)) {
                    response.sendRedirect(request.getContextPath() + "/manager/employee-kpi?error=cycle_locked");
                    return;
                }

                KpiEvaluation eval = kpiDAO.getEvaluationById(evaluationId);

                if (eval != null) {
                    KpiComment comment = new KpiComment();
                    comment.setEvaluationId(evaluationId);
                    comment.setUserId(user.getUserId());
                    comment.setCommentText(commentText.trim());
                    
                    String type = "MANAGER";
                    if (user.getRoleId() == 1 || user.getRoleId() == 2 || user.getRoleId() == 4) {
                        type = "REVIEWER";
                    }
                    comment.setType(type);

                    boolean success = kpiDAO.insertComment(comment);
                    if (success) {
                        String redirectUrl = request.getContextPath() + "/manager/employee-kpi?cycleId=" + eval.getCycleId() + "&viewId=" + evaluationId;
                        if ("true".equals(viewAllStr)) {
                            redirectUrl += "&viewAll=true";
                        }
                        redirectUrl += "&success=comment_added";
                        response.sendRedirect(redirectUrl);
                        return;
                    }
                }
            }
            response.sendRedirect(request.getContextPath() + "/manager/employee-kpi?error=comment_failed");
            return;
        } else if ("submit".equals(action)) {
            String evaluationIdStr = request.getParameter("evaluationId");
            String note = request.getParameter("note");

            if (evaluationIdStr != null && !evaluationIdStr.isEmpty()) {
                int evaluationId = Integer.parseInt(evaluationIdStr);

                // Authorization check: verify this manager is authorized for this evaluation
                if (!kpiDAO.isManagerAuthorizedForEvaluation(user.getUserId(), user.getRoleId(), evaluationId)) {
                    response.sendRedirect(request.getContextPath() + "/manager/employee-kpi?error=unauthorized");
                    return;
                }

                if (kpiDAO.isCycleLockedByEvaluationId(evaluationId)) {
                    response.sendRedirect(request.getContextPath() + "/manager/employee-kpi?error=cycle_locked");
                    return;
                }

                KpiEvaluation eval = kpiDAO.getEvaluationById(evaluationId);

                if (eval != null) {
                    if ("DRAFT".equals(eval.getStatus()) || "REJECTED".equals(eval.getStatus())) {
                        boolean updated = kpiDAO.updateEvaluationStatus(evaluationId, "SUBMITTED", user.getUserId(), note);
                        if (updated) {
                            response.sendRedirect(request.getContextPath() + "/manager/employee-kpi?cycleId=" + eval.getCycleId() + "&success=submitted");
                            return;
                        }
                    }
                }
            }
            response.sendRedirect(request.getContextPath() + "/manager/employee-kpi?error=submit_failed");
        } else if ("bulk-submit".equals(action)) {
            String cycleIdStr = request.getParameter("cycleId");
            String note = request.getParameter("note");
            if (cycleIdStr != null && !cycleIdStr.isEmpty()) {
                int cycleId = Integer.parseInt(cycleIdStr);
                if (kpiDAO.isCycleLocked(cycleId)) {
                    response.sendRedirect(request.getContextPath() + "/manager/employee-kpi?cycleId=" + cycleId + "&error=cycle_locked");
                    return;
                }

                List<KpiEvaluation> evals = kpiDAO.getEvaluationsByCycleAndManager(cycleId, user.getUserId());
                int successCount = 0;
                for (KpiEvaluation eval : evals) {
                    if ("DRAFT".equals(eval.getStatus()) || "REJECTED".equals(eval.getStatus())) {
                        boolean updated = kpiDAO.updateEvaluationStatus(eval.getEvaluationId(), "SUBMITTED", user.getUserId(), note != null ? note : "Nộp hàng loạt báo cáo KPI");
                        if (updated) {
                            successCount++;
                        }
                    }
                }
                response.sendRedirect(request.getContextPath() + "/manager/employee-kpi?cycleId=" + cycleId + "&success=bulk_submitted&count=" + successCount);
                return;
            }
            response.sendRedirect(request.getContextPath() + "/manager/employee-kpi?error=submit_failed");
        }
    }
}
