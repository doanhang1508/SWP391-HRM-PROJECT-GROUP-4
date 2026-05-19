/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller;

import dao.notificationDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import model.User;
import model.notification;

/**
 * REST-style controller xử lý các API thông báo.
 *
 * Endpoints:
 *   GET  /notifications/count      → {"unread": N}
 *   GET  /notifications/list       → {"unreadCount": N, "notifications": [...]}
 *   POST /notifications/read       → đánh dấu 1 thông báo đã đọc
 *   POST /notifications/read-all   → đánh dấu tất cả đã đọc
 *
 * @author Thanh Hang
 */
public class notificationController extends HttpServlet {

    private final notificationDAO notiDAO = new notificationDAO();

    // ── Lấy userId từ session, trả -1 nếu chưa login ──
    private int getUserId(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return -1;
        User user = (User) session.getAttribute("currentUser");
        return user != null ? user.getUserId() : -1;
    }

    // ── Gửi JSON response ──
    private void sendJson(HttpServletResponse response, String json) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.print(json);
            out.flush();
        }
    }

    // ── Escape chuỗi cho JSON (tránh lỗi khi body/title chứa ký tự đặc biệt) ──
    private String escJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }

    /* ================================================================
       GET  /notifications/count  → {"unread": N}
       GET  /notifications/list   → {"unreadCount": N, "notifications": [...]}
       ================================================================ */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int userId = getUserId(request);
        if (userId < 0) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            sendJson(response, "{\"error\":\"Chưa đăng nhập\"}");
            return;
        }

        // Xác định sub-path: /notifications/count hoặc /notifications/list
        String pathInfo = request.getPathInfo(); // "/count", "/list", hoặc null

        if (pathInfo == null || "/".equals(pathInfo)) {
            // Mặc định: trả count
            pathInfo = "/count";
        }

        switch (pathInfo) {
            case "/count" -> {
                int unread = notiDAO.countUnread(userId);
                sendJson(response, "{\"unread\":" + unread + "}");
            }
            case "/list" -> {
                int limit = 20;
                try {
                    String limitParam = request.getParameter("limit");
                    if (limitParam != null) limit = Integer.parseInt(limitParam);
                } catch (NumberFormatException ignored) {}

                int unread = notiDAO.countUnread(userId);
                List<notification> list = notiDAO.findByEmployee(userId, limit);

                StringBuilder sb = new StringBuilder();
                sb.append("{\"unreadCount\":").append(unread)
                  .append(",\"notifications\":[");

                for (int i = 0; i < list.size(); i++) {
                    notification n = list.get(i);
                    if (i > 0) sb.append(",");
                    sb.append("{")
                      .append("\"id\":").append(n.getId()).append(",")
                      .append("\"type\":\"").append(escJson(n.getType())).append("\",")
                      .append("\"title\":\"").append(escJson(n.getTitle())).append("\",")
                      .append("\"body\":\"").append(escJson(n.getBody())).append("\",")
                      .append("\"link\":").append(n.getLink() != null ? "\"" + escJson(n.getLink()) + "\"" : "null").append(",")
                      .append("\"isRead\":").append(n.isRead()).append(",")
                      .append("\"timeAgo\":\"").append(escJson(n.getTimeAgo())).append("\"")
                      .append("}");
                }

                sb.append("]}");
                sendJson(response, sb.toString());
            }
            default -> {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                sendJson(response, "{\"error\":\"Endpoint không tồn tại\"}");
            }
        }
    }

    /* ================================================================
       POST /notifications/read      → đánh dấu 1 thông báo đã đọc
       POST /notifications/read-all  → đánh dấu tất cả đã đọc
       ================================================================ */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int userId = getUserId(request);
        if (userId < 0) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            sendJson(response, "{\"error\":\"Chưa đăng nhập\"}");
            return;
        }

        String pathInfo = request.getPathInfo();
        if (pathInfo == null) pathInfo = "";

        switch (pathInfo) {
            case "/read" -> {
                // Đánh dấu 1 thông báo đã đọc: POST /notifications/read?id=X
                String idParam = request.getParameter("id");
                if (idParam == null || idParam.isBlank()) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    sendJson(response, "{\"error\":\"Thiếu tham số id\"}");
                    return;
                }
                try {
                    int notifId = Integer.parseInt(idParam);
                    notiDAO.markRead(notifId, userId);
                    sendJson(response, "{\"success\":true}");
                } catch (NumberFormatException e) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    sendJson(response, "{\"error\":\"id không hợp lệ\"}");
                }
            }
            case "/read-all" -> {
                // Đánh dấu tất cả đã đọc: POST /notifications/read-all
                notiDAO.markAllRead(userId);
                sendJson(response, "{\"success\":true}");
            }
            default -> {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                sendJson(response, "{\"error\":\"Endpoint không tồn tại\"}");
            }
        }
    }

    @Override
    public String getServletInfo() {
        return "Notification REST API Controller";
    }
}
