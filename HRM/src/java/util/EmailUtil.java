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
             + "<p style='color:#64748b;font-size:14px'>Mã OTP có hiệu lực trong <strong>10 phút</strong>. Vui lòng không chia sẻ mã này với bất kỳ ai.</p>"
             + "<p style='color:#94a3b8;font-size:12px'>Nếu bạn không thực hiện yêu cầu này, hãy bỏ qua email này.</p>"
             + "</div></div>";
    }
}
