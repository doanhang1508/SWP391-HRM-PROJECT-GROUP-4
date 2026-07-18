package util;

import jakarta.mail.*;
import jakarta.mail.internet.*;
import java.util.Properties;

/**
 * Tiện ích gửi Email qua Gmail SMTP (Infrastructure Layer)
 * Nhiệm vụ duy nhất: Mở kết nối và đẩy thư đi.
 * Yêu cầu: Thêm jakarta.mail.jar vào WEB-INF/lib
 */
public class EmailUtil {

    // ===== CẤU HÌNH GMAIL CỦA BẠN Ở ĐÂY =====
    private static final String FROM_EMAIL    = "systemhrm4@gmail.com";      // <-- THAY EMAIL CỦA BẠN
    private static final String APP_PASSWORD  = "saoy jvzs qkoo byab";       // <-- THAY APP PASSWORD CỦA BẠN
    // ============================================

    /**
     * Hàm dùng chung để gửi email dưới định dạng HTML
     * @param toEmail Địa chỉ email người nhận
     * @param subject Tiêu đề email
     * @param htmlContent Nội dung email (chứa thẻ HTML)
     * @throws MessagingException
     */
    public static void sendHtmlEmail(String toEmail, String subject, String htmlContent) throws MessagingException {
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

        MimeMessage message = new MimeMessage(session);
        message.setFrom(new InternetAddress(FROM_EMAIL));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
        message.setSubject(subject, "UTF-8");
        message.setContent(htmlContent, "text/html; charset=UTF-8");

        Transport.send(message);
    }
}
