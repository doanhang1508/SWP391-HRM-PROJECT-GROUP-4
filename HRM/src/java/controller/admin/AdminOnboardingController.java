package controller.admin;

import dao.OnboardingDAO;
import dao.DepartmentDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.OnboardingRequest;
import model.User;
import util.EmailUtil;

import java.io.IOException;
import java.text.Normalizer;

/**
 * Controller phía Admin cho luồng Onboarding
 * URL pattern: /admin/onboarding/*
 *
 * GET  /admin/onboarding/list           → Danh sách tất cả yêu cầu
 * GET  /admin/onboarding/detail?id=X    → Chi tiết yêu cầu
 * POST /admin/onboarding/approve        → Phê duyệt + tạo tài khoản
 * POST /admin/onboarding/reject         → Từ chối + ghi lý do
 */
@WebServlet("/admin/onboarding/*")
public class AdminOnboardingController extends HttpServlet {

    private final OnboardingDAO dao = new OnboardingDAO();
    private final DepartmentDAO deptDAO = new DepartmentDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User admin = getAdmin(req, resp);
        if (admin == null) return;

        String path = getPath(req);

        switch (path) {
            case "/detail":
                int detailId = parseId(req.getParameter("id"), 0);
                if (detailId <= 0) {
                    resp.sendRedirect(req.getContextPath() + "/admin/onboarding/list");
                    return;
                }
                OnboardingRequest detail = dao.getById(detailId);
                if (detail == null) {
                    resp.sendRedirect(req.getContextPath() + "/admin/onboarding/list?error=not_found");
                    return;
                }
                req.setAttribute("request", detail);
                req.getRequestDispatcher("/admin/onboarding-detail.jsp").forward(req, resp);
                break;

            case "/list":
            default:
                String statusFilter = req.getParameter("status"); // ALL, PENDING, APPROVED, REJECTED, DRAFT
                req.setAttribute("requests", dao.getAll(statusFilter));
                req.setAttribute("statusFilter", statusFilter != null ? statusFilter : "ALL");
                req.setAttribute("totalAll",      dao.countByStatus("ALL"));
                req.setAttribute("totalPending",  dao.countByStatus("PENDING"));
                req.setAttribute("totalApproved", dao.countByStatus("APPROVED"));
                req.setAttribute("totalRejected", dao.countByStatus("REJECTED"));
                req.setAttribute("totalDraft",    dao.countByStatus("DRAFT"));
                req.setAttribute("departments", deptDAO.getAll());
                req.getRequestDispatcher("/admin/onboarding-list.jsp").forward(req, resp);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User admin = getAdmin(req, resp);
        if (admin == null) return;

        String path = getPath(req);

        switch (path) {
            case "/approve":
                handleApprove(req, resp, admin);
                break;
            case "/reject":
                handleReject(req, resp, admin);
                break;
            default:
                resp.sendRedirect(req.getContextPath() + "/admin/onboarding/list");
        }
    }

    // ─── APPROVE ─────────────────────────────────────────────────
    private void handleApprove(HttpServletRequest req, HttpServletResponse resp, User admin)
            throws IOException {
        int requestId = parseId(req.getParameter("requestId"), 0);
        if (requestId <= 0) {
            resp.sendRedirect(req.getContextPath() + "/admin/onboarding/list?error=invalid_id");
            return;
        }

        // Kiểm tra request còn PENDING không
        OnboardingRequest onbReq = dao.getById(requestId);
        if (onbReq == null || !"PENDING".equals(onbReq.getStatus())) {
            resp.sendRedirect(req.getContextPath() + "/admin/onboarding/detail?id=" + requestId + "&error=not_pending");
            return;
        }

        // Tạo username từ fullName
        String baseUsername = buildUsername(onbReq.getFullName());
        String finalUsername = ensureUnique(baseUsername);
        String rawPassword   = generatePassword();

        // Transaction: tạo user + cập nhật status
        String createdUsername = dao.approveAndCreateUser(requestId, admin.getUserId(), finalUsername, rawPassword);

        if (createdUsername != null) {
            // Gửi email chứa thông tin đăng nhập
            try {
                EmailUtil.sendWelcomeEmail(onbReq.getEmail(), onbReq.getFullName(),
                                           createdUsername, rawPassword);
            } catch (Exception e) {
                // Log lỗi nhưng không rollback — tài khoản đã tạo rồi
                System.err.println("[AdminOnboarding] Gửi welcome email thất bại: " + e.getMessage());
            }
            resp.sendRedirect(req.getContextPath() + "/admin/onboarding/list?msg=approved&name="
                              + java.net.URLEncoder.encode(onbReq.getFullName(), "UTF-8"));
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/onboarding/detail?id=" + requestId + "&error=approve_failed");
        }
    }

    // ─── REJECT ──────────────────────────────────────────────────
    private void handleReject(HttpServletRequest req, HttpServletResponse resp, User admin)
            throws IOException {
        int requestId = parseId(req.getParameter("requestId"), 0);
        String reason = req.getParameter("rejectReason");

        if (requestId <= 0) {
            resp.sendRedirect(req.getContextPath() + "/admin/onboarding/list?error=invalid_id");
            return;
        }
        if (reason == null || reason.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/admin/onboarding/detail?id=" + requestId + "&error=reason_required");
            return;
        }

        boolean ok = dao.rejectRequest(requestId, admin.getUserId(), reason.trim());
        if (ok) {
            resp.sendRedirect(req.getContextPath() + "/admin/onboarding/list?msg=rejected");
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/onboarding/detail?id=" + requestId + "&error=reject_failed");
        }
    }

    // ─── Helpers ─────────────────────────────────────────────────

    /** Chuyển "Nguyễn Văn An" → "nguyenvanan" */
    private String buildUsername(String fullName) {
        if (fullName == null || fullName.trim().isEmpty()) return "employee";
        String normalized = Normalizer.normalize(fullName.trim().toLowerCase(), Normalizer.Form.NFD)
                                      .replaceAll("\\p{M}", "")
                                      .replaceAll("đ", "d")
                                      .replaceAll("[^a-z0-9]", "");
        return normalized.length() > 20 ? normalized.substring(0, 20) : normalized;
    }

    /** Đảm bảo username không trùng bằng cách thêm số */
    private String ensureUnique(String base) {
        if (!dao.isUsernameExists(base)) return base;
        int suffix = 1;
        while (dao.isUsernameExists(base + suffix)) suffix++;
        return base + suffix;
    }

    /** Mật khẩu ngẫu nhiên 10 ký tự có chữ hoa, thường, số, ký tự đặc biệt */
    private String generatePassword() {
        String chars = "ABCDEFGHJKMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789!@#$";
        StringBuilder sb = new StringBuilder();
        java.util.Random rnd = new java.util.Random();
        for (int i = 0; i < 10; i++) sb.append(chars.charAt(rnd.nextInt(chars.length())));
        return sb.toString();
    }

    private User getAdmin(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("currentUser") : null;
        if (user == null) { resp.sendRedirect(req.getContextPath() + "/login"); return null; }
        if (user.getRoleId() != 1) { resp.sendRedirect(req.getContextPath() + "/dashboard"); return null; }
        return user;
    }

    private String getPath(HttpServletRequest req) {
        String p = req.getPathInfo();
        return (p != null) ? p : "/list";
    }

    private int parseId(String s, int def) {
        if (s == null || s.trim().isEmpty()) return def;
        try { return Integer.parseInt(s.trim()); } catch (NumberFormatException e) { return def; }
    }
}
