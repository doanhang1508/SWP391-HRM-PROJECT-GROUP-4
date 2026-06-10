package util;

import jakarta.mail.*;
import jakarta.mail.internet.*;
import java.util.Properties;

/**
 * Tiện ích gửi Email qua Gmail SMTP
 * Yêu cầu: Thêm jakarta.mail.jar vào WEB-INF/lib
 */
public class EmailUtil {

    // ===== CẤU HÌNH GMAIL CỦA BẠN Ở ĐÂY =====
    private static final String FROM_EMAIL    = "systemhrm4@gmail.com";      // <-- THAY EMAIL CỦA BẠN
    private static final String APP_PASSWORD  = "saoy jvzs qkoo byab";       // <-- THAY APP PASSWORD CỦA BẠN
    // ============================================

    public static void sendOtpEmail(String toEmail, String otp) throws MessagingException {
        Properties props = new Properties();
        props.put("mail.smtp.auth",            "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host",            "smtp.gmail.com");
        props.put("mail.smtp.port",            "587");
        props.put("mail.smtp.ssl.trust",       "smtp.gmail.com");

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(FROM_EMAIL, APP_PASSWORD);
            }
        });

        Message message = new MimeMessage(session);
        message.setFrom(new InternetAddress(FROM_EMAIL));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
        message.setSubject("[HRM System] Mã xác nhận đặt lại mật khẩu");
        message.setContent(buildEmailBody(otp), "text/html; charset=UTF-8");

        Transport.send(message);
    }

    private static String buildEmailBody(String otp) {
        return "<div style='font-family:sans-serif;max-width:480px;margin:0 auto;border:1px solid #e2e8f0;border-radius:12px;overflow:hidden'>"
             + "<div style='background:#1e293b;padding:24px;text-align:center'>"
             + "<h2 style='color:white;margin:0'>🔐 HRM System</h2></div>"
             + "<div style='padding:32px'>"
             + "<p style='color:#334155;font-size:16px'>Bạn vừa yêu cầu đặt lại mật khẩu. Mã OTP của bạn là:</p>"
             + "<div style='background:#f1f5f9;border-radius:8px;padding:20px;text-align:center;margin:20px 0'>"
             + "<span style='font-size:36px;font-weight:800;color:#0f172a;letter-spacing:8px'>" + otp + "</span></div>"
             + "<p style='color:#64748b;font-size:14px'>Mã OTP có hiệu lực trong <strong>1 phút</strong>. Vui lòng không chia sẻ mã này với bất kỳ ai.</p>"
             + "<p style='color:#94a3b8;font-size:12px'>Nếu bạn không thực hiện yêu cầu này, hãy bỏ qua email này.</p>"
             + "</div></div>";
    }

    /**
     * Gửi email thông báo mật khẩu mới (Admin reset password)
     */
    public static void sendResetPasswordEmail(String toEmail, String fullName, String newPassword) throws MessagingException {
        Properties props = new Properties();
        props.put("mail.smtp.auth",            "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host",            "smtp.gmail.com");
        props.put("mail.smtp.port",            "587");
        props.put("mail.smtp.ssl.trust",       "smtp.gmail.com");

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(FROM_EMAIL, APP_PASSWORD);
            }
        });

        Message message = new MimeMessage(session);
        message.setFrom(new InternetAddress(FROM_EMAIL));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
        message.setSubject("[HRM System] Mật khẩu của bạn đã được đặt lại");
        message.setContent(buildResetPasswordBody(fullName, newPassword), "text/html; charset=UTF-8");

        Transport.send(message);
    }

    private static String buildResetPasswordBody(String fullName, String newPassword) {
        return "<div style='font-family:sans-serif;max-width:480px;margin:0 auto;border:1px solid #e2e8f0;border-radius:12px;overflow:hidden'>"
             + "<div style='background:linear-gradient(135deg,#1e293b,#334155);padding:24px;text-align:center'>"
             + "<h2 style='color:white;margin:0'>🔑 HRM System</h2></div>"
             + "<div style='padding:32px'>"
             + "<p style='color:#334155;font-size:16px'>Xin chào <strong>" + (fullName != null ? fullName : "bạn") + "</strong>,</p>"
             + "<p style='color:#334155;font-size:15px'>Quản trị viên đã đặt lại mật khẩu cho tài khoản của bạn. Mật khẩu mới của bạn là:</p>"
             + "<div style='background:#f1f5f9;border-radius:8px;padding:20px;text-align:center;margin:20px 0'>"
             + "<span style='font-size:24px;font-weight:800;color:#0f172a;letter-spacing:4px;font-family:monospace'>" + newPassword + "</span></div>"
             + "<p style='color:#ef4444;font-size:14px;font-weight:600'>⚠️ Vui lòng đăng nhập và đổi mật khẩu ngay sau khi nhận được email này.</p>"
             + "<p style='color:#64748b;font-size:13px'>Nếu bạn không yêu cầu thay đổi này, hãy liên hệ quản trị viên ngay lập tức.</p>"
             + "</div>"
             + "<div style='background:#f8fafc;padding:16px;text-align:center;border-top:1px solid #e2e8f0'>"
             + "<p style='color:#94a3b8;font-size:12px;margin:0'>Email này được gửi tự động từ HRM System. Vui lòng không trả lời.</p>"
             + "</div></div>";
    }

    /**
     * Gửi email chào mừng khi Admin duyệt yêu cầu Onboarding và tạo tài khoản thành công
     */
    public static void sendWelcomeEmail(String toEmail, String fullName, String username, String password) throws MessagingException {
        Properties props = new Properties();
        props.put("mail.smtp.auth",            "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host",            "smtp.gmail.com");
        props.put("mail.smtp.port",            "587");
        props.put("mail.smtp.ssl.trust",       "smtp.gmail.com");

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(FROM_EMAIL, APP_PASSWORD);
            }
        });

        Message message = new MimeMessage(session);
        message.setFrom(new InternetAddress(FROM_EMAIL));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
        message.setSubject("[HRM System] Chào mừng bạn gia nhập công ty! (Thông tin đăng nhập)");
        message.setContent(buildWelcomeBody(toEmail, fullName, password), "text/html; charset=UTF-8");

        Transport.send(message);
    }

    private static String buildWelcomeBody(String toEmail, String fullName, String password) {
        return "<div style='font-family:sans-serif;max-width:500px;margin:0 auto;border:1px solid #e2e8f0;border-radius:12px;overflow:hidden'>"
             + "<div style='background:linear-gradient(135deg,#0d9488,#0f766e);padding:28px;text-align:center'>"
             + "<h2 style='color:white;margin:0;font-size:22px'>🎉 Chào mừng gia nhập công ty!</h2></div>"
             + "<div style='padding:32px'>"
             + "<p style='color:#334155;font-size:16px;line-height:1.6'>Xin chào <strong>" + fullName + "</strong>,</p>"
             + "<p style='color:#334155;font-size:15px;line-height:1.6'>Tài khoản nhân sự của bạn đã được tạo thành công. Dưới đây là thông tin đăng nhập vào hệ thống HRM:</p>"
             + "<div style='background:#f8fafc;border:1px solid #e2e8f0;border-radius:10px;padding:20px;margin:20px 0'>"
             + "<div style='margin-bottom:12px'><span style='color:#64748b;font-size:13px;display:block;margin-bottom:4px'>Tài khoản Email:</span>"
             + "<span style='font-size:18px;font-weight:700;color:#0f172a;'>" + toEmail + "</span></div>"
             + "<div><span style='color:#64748b;font-size:13px;display:block;margin-bottom:4px'>Mật khẩu:</span>"
             + "<span style='font-size:18px;font-weight:700;color:#0f172a;font-family:monospace;letter-spacing:2px'>" + password + "</span></div>"
             + "</div>"
             + "<p style='color:#ef4444;font-size:14px;font-weight:600'>⚠️ Lưu ý: Vì lý do bảo mật, vui lòng đăng nhập và ĐỔI MẬT KHẨU ngay trong lần truy cập đầu tiên.</p>"
             + "</div>"
             + "<div style='background:#f8fafc;padding:16px;text-align:center;border-top:1px solid #e2e8f0'>"
             + "<p style='color:#94a3b8;font-size:12px;margin:0'>Email này được gửi tự động từ HRM System. Vui lòng không trả lời.</p>"
             + "</div></div>";
    }
}
