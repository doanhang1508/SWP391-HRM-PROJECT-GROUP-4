/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.UserDAO;
import dao.notificationDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import model.User;
import model.notification;
import util.CookieUtil;
import util.PasswordUtil;

/**
 *
 * @author Thanh Hang
 */
public class loginController extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet loginController</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet loginController at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }
    private final UserDAO userDAO = new UserDAO();
    private final notificationDAO notificationDAO = new notificationDAO();

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Set URL cho nút Google OAuth
        request.setAttribute("googleLoginUrl", request.getContextPath() + "/auth/google");

        String userEmailCookie = CookieUtil.getCookieValue(request, CookieUtil.REMEMBER_EMAIL_COOKIE);
        if (userEmailCookie != null && !userEmailCookie.isEmpty()) {
            request.setAttribute("email", userEmailCookie);
            request.setAttribute("rememberChecked", "checked");
        }

        request.getRequestDispatcher("login.jsp").forward(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        //processRequest(request, response);
        String email = request.getParameter("email");    // đổi từ "username"
        String password = request.getParameter("password");

        if (email == null || email.isBlank()
                || password == null || password.isBlank()) {
            request.setAttribute("errorMsg", "Vui lòng nhập đầy đủ email và mật khẩu.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        User user = userDAO.findByEmailAndPassword(email.trim(), password);

        if (user == null) {
            // Sai tài khoản / mật khẩu
            request.setAttribute("errorMsg", "Tên đăng nhập hoặc mật khẩu không đúng.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        if (user.getStatus() == 0) {
            // Tài khoản bị khóa
            request.setAttribute("errorMsg", "Tài khoản của bạn đã bị khóa. Vui lòng liên hệ Admin.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        // --- Tạo session ---
        HttpSession session = request.getSession(true);
        session.setAttribute("currentUser", user);
        session.setMaxInactiveInterval(60 * 60 * 8); // 8 tiếng

        // --- Gửi thông báo đăng nhập thành công ---
        sendLoginNotification(user, request);

        // --- Redirect theo role ---
        String redirect = switch (user.getRoleId()) {
            case 1 ->
                "/admin/dashboard";
            case 2 ->
                "/manager/dashboard";
            default ->
                "employee/dashboard";
        };
        response.sendRedirect(request.getContextPath() + redirect);
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

    private void sendLoginNotification(User user, HttpServletRequest req) {
        try {
            // Thông tin thiết bị / trình duyệt (lấy từ User-Agent)
            String userAgent = req.getHeader("User-Agent");
            String device = parseDevice(userAgent);

            // Lấy IP người dùng (hỗ trợ cả proxy)
            String ip = req.getHeader("X-Forwarded-For");
            if (ip == null || ip.isBlank()) {
                ip = req.getRemoteAddr();
            }

            // Thời điểm đăng nhập (định dạng thân thiện)
            String timeStr = LocalDateTime.now()
                    .format(DateTimeFormatter.ofPattern("HH:mm - dd/MM/yyyy"));

            notification notif = new notification();
            notif.setEmployeeId(user.getUserId());
            notif.setType("system");
            notif.setTitle("Đăng nhập thành công");
            notif.setBody(String.format(
                    "Bạn vừa đăng nhập lúc %s từ %s (IP: %s). Nếu không phải bạn, hãy đổi mật khẩu ngay.",
                    timeStr, device, ip));
            notif.setLink("/profile/security");

            notificationDAO.create(notif);

        } catch (Exception e) {
            // Không để lỗi thông báo ảnh hưởng đến luồng đăng nhập
            e.printStackTrace();
        }
    }

    // ── Parse tên thiết bị từ User-Agent ───────────────────────
    private String parseDevice(String ua) {
        if (ua == null) {
            return "Thiết bị không xác định";
        }
        ua = ua.toLowerCase();

        String os;
        if (ua.contains("windows")) {
            os = "Windows";
        } else if (ua.contains("macintosh") || ua.contains("mac os")) {
            os = "macOS";
        } else if (ua.contains("android")) {
            os = "Android";
        } else if (ua.contains("iphone") || ua.contains("ipad")) {
            os = "iOS";
        } else if (ua.contains("linux")) {
            os = "Linux";
        } else {
            os = "Hệ điều hành khác";
        }

        String browser;
        if (ua.contains("edg")) {
            browser = "Microsoft Edge";
        } else if (ua.contains("opr") || ua.contains("opera")) {
            browser = "Opera";
        } else if (ua.contains("chrome")) {
            browser = "Chrome";
        } else if (ua.contains("firefox")) {
            browser = "Firefox";
        } else if (ua.contains("safari")) {
            browser = "Safari";
        } else {
            browser = "Trình duyệt khác";
        }

        return browser + " / " + os;
    }

}
