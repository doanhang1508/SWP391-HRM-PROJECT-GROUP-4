package controller;
 
import dao.UserDAO;
import model.User;
import util.EmailUtil;
import util.PasswordUtil;
import java.io.IOException;
import java.util.Random;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Controller xử lý chức năng Quên mật khẩu
 * Luồng: Nhập Email → Nhận OTP → Xác minh OTP → Nhập mật khẩu mới
 * OTP có thời hạn 1 phút.
 */
// FIX: Bỏ @WebServlet ở đây vì đã dùng web.xml để mapping
// Nếu project của bạn dùng annotation thì xóa mapping trong web.xml đi,
// không được dùng cả 2 cùng lúc → conflict
public class ForgotPasswordController extends HttpServlet {
 
    // Thời hạn OTP: 1 phút (60,000 ms)
    private static final long OTP_EXPIRY_MS = 1 * 60 * 1000L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("forgotPassword.jsp").forward(request, response);
    }
 
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
 
        String step = request.getParameter("step");
 
        if ("send_otp".equals(step)) {
            handleSendOtp(request, response);
        } else if ("verify_otp".equals(step)) {
            handleVerifyOtp(request, response);
        } else if ("reset_password".equals(step)) {
            handleResetPassword(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/forgot-password");
        }
    }
 
    // ── BƯỚC 1: Gửi OTP ────────────────────────────────────────
    private void handleSendOtp(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
 
        String email = request.getParameter("email");
 
        // Guard null trước khi trim để tránh NullPointerException
        if (email == null || email.isBlank()) {
            request.setAttribute("step",     "enter_email");
            request.setAttribute("msgError", "Vui lòng nhập địa chỉ email.");
            request.getRequestDispatcher("forgotPassword.jsp").forward(request, response);
            return;
        }
        email = email.trim();
 
        // Kiểm tra email tồn tại trong hệ thống
        UserDAO userDAO = new UserDAO();
        User user = userDAO.getUserByEmail(email);
 
        if (user == null) {
            request.setAttribute("step",        "enter_email");
            request.setAttribute("msgError",    "Email này không tồn tại trong hệ thống!");
            request.setAttribute("inputEmail",  email); // giữ lại email đã nhập
            request.getRequestDispatcher("forgotPassword.jsp").forward(request, response);
            return;
        }
 
        // Tạo OTP 6 chữ số
        String otp = String.format("%06d", new Random().nextInt(1_000_000));
 
        // Lưu vào session
        HttpSession session = request.getSession();
        session.setAttribute("otp_code",     otp);
        session.setAttribute("otp_email",    email);
        session.setAttribute("otp_created",  System.currentTimeMillis());
        session.removeAttribute("otp_verified"); // Reset trạng thái xác minh
 
        // Gửi email
        try {
            EmailUtil.sendOtpEmail(email, otp);
 
            // Thành công → chuyển sang bước 2 (xác minh OTP)
            request.setAttribute("step",     "verify_otp");
            request.setAttribute("otpEmail", email);
 
        } catch (Exception e) {
            System.err.println("[ForgotPassword] Lỗi gửi email tới " + email + ": " + e.getMessage());
            e.printStackTrace();
 
            // Xóa OTP vừa tạo vì chưa gửi được
            session.removeAttribute("otp_code");
            session.removeAttribute("otp_email");
            session.removeAttribute("otp_created");
 
            // Giữ nguyên step enter_email và giữ lại email đã nhập
            request.setAttribute("step",       "enter_email");
            request.setAttribute("inputEmail", email);
            request.setAttribute("msgError",
                "Gửi email thất bại! Nguyên nhân: " + e.getMessage()
                + " — Vui lòng kiểm tra cấu hình SMTP trong EmailUtil.java");
        }
 
        request.getRequestDispatcher("forgotPassword.jsp").forward(request, response);
    }
 
    // ── BƯỚC 2: Xác minh OTP (chỉ kiểm tra OTP, chưa nhập mật khẩu) ──
    private void handleVerifyOtp(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
 
        HttpSession session = request.getSession(false);
 
        // Kiểm tra session null (session hết hạn hoặc chưa có)
        if (session == null) {
            request.setAttribute("step",     "enter_email");
            request.setAttribute("msgError", "Phiên làm việc đã hết hạn. Vui lòng thực hiện lại từ đầu.");
            request.getRequestDispatcher("forgotPassword.jsp").forward(request, response);
            return;
        }
 
        String sessionOtp     = (String) session.getAttribute("otp_code");
        String sessionEmail   = (String) session.getAttribute("otp_email");
        Long   otpCreatedTime = (Long)   session.getAttribute("otp_created");
 
        String inputOtp = request.getParameter("otpCode");
 
        // Kiểm tra OTP hết hạn (1 phút)
        if (otpCreatedTime == null
                || (System.currentTimeMillis() - otpCreatedTime) > OTP_EXPIRY_MS) {
            // Xóa OTP cũ
            session.removeAttribute("otp_code");
            session.removeAttribute("otp_email");
            session.removeAttribute("otp_created");
 
            request.setAttribute("step",     "enter_email");
            request.setAttribute("msgError", "Mã OTP đã hết hạn (1 phút). Vui lòng yêu cầu mã mới.");
            request.getRequestDispatcher("forgotPassword.jsp").forward(request, response);
            return;
        }
 
        // Kiểm tra OTP đúng không
        if (sessionOtp == null || inputOtp == null
                || !sessionOtp.equals(inputOtp.trim())) {
            request.setAttribute("step",     "verify_otp");
            request.setAttribute("otpEmail", sessionEmail);
            request.setAttribute("msgError", "Mã OTP không chính xác! Vui lòng thử lại.");
            request.getRequestDispatcher("forgotPassword.jsp").forward(request, response);
            return;
        }
 
        // OTP đúng → Đánh dấu đã xác minh, chuyển sang bước 3
        session.setAttribute("otp_verified", true);
 
        request.setAttribute("step",     "new_password");
        request.setAttribute("otpEmail", sessionEmail);
        request.getRequestDispatcher("forgotPassword.jsp").forward(request, response);
    }

    // ── BƯỚC 3: Đặt mật khẩu mới (chỉ cho phép khi đã xác minh OTP) ──
    private void handleResetPassword(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // Kiểm tra session
        if (session == null) {
            request.setAttribute("step",     "enter_email");
            request.setAttribute("msgError", "Phiên làm việc đã hết hạn. Vui lòng thực hiện lại từ đầu.");
            request.getRequestDispatcher("forgotPassword.jsp").forward(request, response);
            return;
        }

        // Kiểm tra đã xác minh OTP chưa (chống truy cập trực tiếp bước 3)
        Boolean otpVerified = (Boolean) session.getAttribute("otp_verified");
        String sessionEmail = (String) session.getAttribute("otp_email");

        if (otpVerified == null || !otpVerified) {
            request.setAttribute("step",     "enter_email");
            request.setAttribute("msgError", "Bạn chưa xác minh mã OTP. Vui lòng thực hiện lại từ đầu.");
            request.getRequestDispatcher("forgotPassword.jsp").forward(request, response);
            return;
        }

        String newPassword     = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        // Kiểm tra mật khẩu mới hợp lệ
        if (newPassword == null || newPassword.length() < 6) {
            request.setAttribute("step",     "new_password");
            request.setAttribute("otpEmail", sessionEmail);
            request.setAttribute("msgError", "Mật khẩu mới phải có ít nhất 6 ký tự!");
            request.getRequestDispatcher("forgotPassword.jsp").forward(request, response);
            return;
        }

        // Kiểm tra mật khẩu xác nhận khớp
        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("step",     "new_password");
            request.setAttribute("otpEmail", sessionEmail);
            request.setAttribute("msgError", "Xác nhận mật khẩu mới không khớp!");
            request.getRequestDispatcher("forgotPassword.jsp").forward(request, response);
            return;
        }

        // Cập nhật mật khẩu vào DB
        UserDAO userDAO = new UserDAO();
        User user = userDAO.getUserByEmail(sessionEmail);

        if (user == null) {
            request.setAttribute("step",     "enter_email");
            request.setAttribute("msgError", "Không tìm thấy tài khoản. Vui lòng thực hiện lại.");
            request.getRequestDispatcher("forgotPassword.jsp").forward(request, response);
            return;
        }

        String hashedPassword = PasswordUtil.hashPassword(newPassword);
        boolean updated = userDAO.updatePassword(user.getUserId(), hashedPassword);

        if (updated) {
            // Xóa tất cả dữ liệu OTP khỏi session sau khi dùng xong
            session.removeAttribute("otp_code");
            session.removeAttribute("otp_email");
            session.removeAttribute("otp_created");
            session.removeAttribute("otp_verified");

            request.setAttribute("step", "success");
        } else {
            request.setAttribute("step",     "new_password");
            request.setAttribute("otpEmail", sessionEmail);
            request.setAttribute("msgError", "Có lỗi xảy ra khi cập nhật mật khẩu. Vui lòng thử lại!");
        }

        request.getRequestDispatcher("forgotPassword.jsp").forward(request, response);
    }
}