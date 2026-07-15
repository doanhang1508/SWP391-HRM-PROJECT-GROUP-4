package controller.employee;

import dao.OvertimeAssignmentDAO;
import dao.OvertimeAssignmentDAOImpl;
import dao.notificationDAO;
import model.OvertimeAssignment;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

/**
 * EmployeeOvertimeController — Nhân viên xem & phản hồi đơn tăng ca.
 *
 * URL  : /employee/overtime
 * Role : 5 (Employee) — tất cả nhân viên bình thường
 *
 * Use Case:
 *   GET  default          → Xem danh sách đơn tăng ca (sắp tới + lịch sử)
 *   POST action=accept    → Nhân viên chấp nhận tăng ca
 *   POST action=decline   → Nhân viên từ chối tăng ca (bắt buộc nhập lý do)
 */
@WebServlet(name = "EmployeeOvertimeController", urlPatterns = {"/employee/overtime"})
public class EmployeeOvertimeController extends HttpServlet {

    private static final String OT_URL = "/employee/overtime";
    private OvertimeAssignmentDAO overtimeService;

    @Override
    public void init() throws ServletException {
        overtimeService = new OvertimeAssignmentDAOImpl();
    }

    // ════════════════════════════════════════════════════════
    //  GET — Xem danh sách đơn tăng ca
    // ════════════════════════════════════════════════════════
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = getUser(req);
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        int userId = user.getUserId();

        // Đơn tăng ca sắp tới (target_date >= today, chưa Cancelled)
        List<OvertimeAssignment> upcoming = overtimeService.getUpcomingAssignmentsByUser(userId);

        // Lịch sử tăng ca (target_date < today)
        List<OvertimeAssignment> past = overtimeService.getPastAssignmentsByUser(userId);

        req.setAttribute("upcomingOT", upcoming);
        req.setAttribute("pastOT", past);
        req.setAttribute("currentUser", user);

        req.getRequestDispatcher("/employee/employee-overtime.jsp").forward(req, resp);
    }

    // ════════════════════════════════════════════════════════
    //  POST — Nhân viên phản hồi đơn tăng ca
    // ════════════════════════════════════════════════════════
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        User user = getUser(req);
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");

        if ("accept".equals(action) || "decline".equals(action)) {
            Integer assignmentId = parseIntParam(req, "assignmentId");
            if (assignmentId == null) {
                redirectOT(req, resp, "error", "ID đơn tăng ca không hợp lệ");
                return;
            }

            // Kiểm tra assignment có thuộc về nhân viên này không
            OvertimeAssignment assignment = overtimeService.getById(assignmentId);
            if (assignment == null || assignment.getUserId() != user.getUserId()) {
                redirectOT(req, resp, "error", "Đơn tăng ca không tồn tại hoặc không thuộc về bạn");
                return;
            }

            String response = "accept".equals(action) ? "ACCEPTED" : "DECLINED";
            String note = req.getParameter("note");
            if (note != null) note = note.trim();

            try {
                boolean ok = overtimeService.respondToAssignment(assignmentId, response, note);
                if (ok) {
                    // Gửi notification cho supervisor
                    if ("ACCEPTED".equals(response)) {
                        new notificationDAO().create(
                            assignment.getUserId(), "overtime",
                            "Bạn đã chấp nhận tăng ca",
                            "Bạn đã xác nhận tăng ca " + assignment.getAssignedHours() + " giờ ngày " + assignment.getTargetDate() + ".",
                            OT_URL
                        );
                        redirectOT(req, resp, "message", "Đã xác nhận chấp nhận tăng ca");
                    } else {
                        new notificationDAO().create(
                            assignment.getUserId(), "overtime",
                            "Bạn đã từ chối tăng ca",
                            "Bạn đã từ chối tăng ca ngày " + assignment.getTargetDate() + ". Lý do: " + note,
                            OT_URL
                        );
                        redirectOT(req, resp, "message", "Đã ghi nhận từ chối tăng ca");
                    }
                } else {
                    redirectOT(req, resp, "error", "Cập nhật thất bại, vui lòng thử lại");
                }
            } catch (Exception e) {
                redirectOT(req, resp, "error", e.getMessage());
            }
        } else {
            resp.sendRedirect(req.getContextPath() + OT_URL);
        }
    }

    // ════════════════════════════════════════════════════════
    //  Helpers
    // ════════════════════════════════════════════════════════

    private User getUser(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        return s != null ? (User) s.getAttribute("currentUser") : null;
    }

    private Integer parseIntParam(HttpServletRequest req, String name) {
        String raw = req.getParameter(name);
        if (raw == null || raw.trim().isEmpty()) return null;
        try { return Integer.parseInt(raw.trim()); }
        catch (NumberFormatException e) { return null; }
    }

    private void redirectOT(HttpServletRequest req, HttpServletResponse resp,
                            String key, String msg) throws IOException {
        resp.sendRedirect(req.getContextPath() + OT_URL + "?" + key + "="
                + URLEncoder.encode(msg, StandardCharsets.UTF_8));
    }
}
