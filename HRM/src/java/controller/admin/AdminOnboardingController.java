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
import service.EmailService;
import dao.notificationDAO;

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

        // Sử dụng email làm username luôn vì hệ thống đăng nhập bằng email
        String finalUsername = onbReq.getEmail();
        String rawPassword   = generatePassword();

        // Transaction: tạo user + cập nhật status
        String createdUsername = dao.approveAndCreateUser(requestId, admin.getUserId(), finalUsername, rawPassword);

        if (createdUsername != null) {
            // Gửi email chứa thông tin đăng nhập
            boolean emailSent = false;
            String emailError = "";
            try {
                EmailService emailService = new EmailService();
                emailService.sendWelcomeEmail(onbReq.getEmail(), onbReq.getFullName(),
                                           createdUsername, rawPassword);
                emailSent = true;
            } catch (Exception e) {
                // Log lỗi nhưng không rollback — tài khoản đã tạo rồi
                System.err.println("[AdminOnboarding] Gửi welcome email thất bại: " + e.getMessage());
                emailError = e.getMessage();
            }

            // Lưu log vào notifications, kèm theo trạng thái gửi email
            String notifBody = "Tài khoản cho " + onbReq.getFullName() + " đã được tạo thành công.";
            if (emailSent) {
                notifBody += " Email thông tin đăng nhập đã được gửi tới ứng viên.";
            } else {
                notifBody += " Tuy nhiên, lỗi khi gửi email: " + emailError;
                
                // Tự động báo cho HR biết để sửa lại email
                new notificationDAO().create(onbReq.getCreatedBy(), "system", "Lỗi gửi email cấp quyền", 
                    "Tài khoản cho " + onbReq.getFullName() + " đã được duyệt. Tuy nhiên, hệ thống không thể gửi email. Vui lòng vào Quản lý nhân viên kiểm tra lại địa chỉ email.", 
                    "/hr/employee/list");
            }

            new notificationDAO().create(admin.getUserId(), "system", "Phê duyệt ứng viên", 
                notifBody, 
                "/admin/onboarding/detail?id=" + requestId);
            
            String redirectUrl = req.getContextPath() + "/admin/onboarding/list?msg=approved&name="
                              + java.net.URLEncoder.encode(onbReq.getFullName(), "UTF-8");
            
            if (emailSent) {
                redirectUrl += "&emailStatus=success";
            } else {
                redirectUrl += "&emailStatus=failed&emailError=" + java.net.URLEncoder.encode(emailError != null ? emailError : "Unknown error", "UTF-8");
            }
            resp.sendRedirect(redirectUrl);
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
            // Lưu log vào notifications
            new notificationDAO().create(admin.getUserId(), "system", "Từ chối ứng viên", 
                "Bạn đã từ chối yêu cầu tuyển dụng (ID: " + requestId + ").", 
                "/admin/onboarding/detail?id=" + requestId);

            resp.sendRedirect(req.getContextPath() + "/admin/onboarding/list?msg=rejected");
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/onboarding/detail?id=" + requestId + "&error=reject_failed");
        }
    }

    // ─── Helpers ─────────────────────────────────────────────────



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
