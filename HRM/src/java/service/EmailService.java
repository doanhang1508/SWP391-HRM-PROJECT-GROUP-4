package service;

import util.EmailUtil;
import jakarta.mail.MessagingException;
import java.math.BigDecimal;

/**
 * Dịch vụ xử lý nghiệp vụ gửi Email (Business Layer).
 * Tách biệt hoàn toàn giao diện (HTML) khỏi tầng giao thức mạng.
 */
public class EmailService {

    /**
     * Gửi OTP Quên mật khẩu
     */
    public void sendOtpEmail(String toEmail, String otp) throws MessagingException {
        String subject = "[HRM System] Mã xác nhận đặt lại mật khẩu";
        String htmlBody = "<div style='font-family:sans-serif;max-width:480px;margin:0 auto;border:1px solid #e2e8f0;border-radius:12px;overflow:hidden'>"
             + "<div style='background:#1e293b;padding:24px;text-align:center'>"
             + "<h2 style='color:white;margin:0'>🔐 HRM System</h2></div>"
             + "<div style='padding:32px'>"
             + "<p style='color:#334155;font-size:16px'>Bạn vừa yêu cầu đặt lại mật khẩu. Mã OTP của bạn là:</p>"
             + "<div style='background:#f1f5f9;border-radius:8px;padding:20px;text-align:center;margin:20px 0'>"
             + "<span style='font-size:36px;font-weight:800;color:#0f172a;letter-spacing:8px'>" + otp + "</span></div>"
             + "<p style='color:#64748b;font-size:14px'>Mã OTP có hiệu lực trong <strong>1 phút</strong>. Vui lòng không chia sẻ mã này với bất kỳ ai.</p>"
             + "<p style='color:#94a3b8;font-size:12px'>Nếu bạn không thực hiện yêu cầu này, hãy bỏ qua email này.</p>"
             + "</div></div>";

        EmailUtil.sendHtmlEmail(toEmail, subject, htmlBody);
    }

    /**
     * Gửi mật khẩu mới khi Admin Reset Password
     */
    public void sendResetPasswordEmail(String toEmail, String fullName, String newPassword) throws MessagingException {
        String subject = "[HRM System] Mật khẩu của bạn đã được đặt lại";
        String htmlBody = "<div style='font-family:sans-serif;max-width:480px;margin:0 auto;border:1px solid #e2e8f0;border-radius:12px;overflow:hidden'>"
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

        EmailUtil.sendHtmlEmail(toEmail, subject, htmlBody);
    }

    /**
     * Gửi email chào mừng khi duyệt Onboarding
     */
    public void sendWelcomeEmail(String toEmail, String fullName, String username, String password) throws MessagingException {
        String subject = "[HRM System] Chào mừng bạn gia nhập công ty! (Thông tin đăng nhập)";
        String htmlBody = "<div style='font-family:sans-serif;max-width:500px;margin:0 auto;border:1px solid #e2e8f0;border-radius:12px;overflow:hidden'>"
             + "<div style='background:linear-gradient(135deg,#0d9488,#0f766e);padding:28px;text-align:center'>"
             + "<h2 style='color:white;margin:0;font-size:22px'>🎉 Chào mừng gia nhập công ty!</h2></div>"
             + "<div style='padding:32px'>"
             + "<p style='color:#334155;font-size:16px;line-height:1.6'>Xin chào <strong>" + fullName + "</strong>,</p>"
             + "<p style='color:#334155;font-size:15px;line-height:1.6'>Tài khoản nhân sự của bạn đã được tạo thành công. Dưới đây là thông tin đăng nhập vào hệ thống HRM:</p>"
             + "<div style='background:#f8fafc;border:1px solid #e2e8f0;border-radius:10px;padding:20px;margin:20px 0'>"
             + "<div style='margin-bottom:12px'><span style='color:#64748b;font-size:13px;display:block;margin-bottom:4px'>Tên đăng nhập (Email):</span>"
             + "<span style='font-size:18px;font-weight:700;color:#0f172a;'>" + username + "</span></div>"
             + "<div><span style='color:#64748b;font-size:13px;display:block;margin-bottom:4px'>Mật khẩu:</span>"
             + "<span style='font-size:18px;font-weight:700;color:#0f172a;font-family:monospace;letter-spacing:2px'>" + password + "</span></div>"
             + "</div>"
             + "<p style='color:#ef4444;font-size:14px;font-weight:600'>⚠️ Lưu ý: Vì lý do bảo mật, vui lòng đăng nhập và ĐỔI MẬT KHẨU ngay trong lần truy cập đầu tiên.</p>"
             + "</div>"
             + "<div style='background:#f8fafc;padding:16px;text-align:center;border-top:1px solid #e2e8f0'>"
             + "<p style='color:#94a3b8;font-size:12px;margin:0'>Email này được gửi tự động từ HRM System. Vui lòng không trả lời.</p>"
             + "</div></div>";

        EmailUtil.sendHtmlEmail(toEmail, subject, htmlBody);
    }

    /**
     * Gửi email thông báo đã chuyển khoản lương (Payroll)
     */
    public void sendPayrollEmail(String toEmail, String fullName, int month, int year, BigDecimal netSalary) throws MessagingException {
        String subject = "[HRM System] Ting Ting! Thông báo nhận lương tháng " + month + "/" + year;
        String formattedSalary = netSalary != null ? String.format("%,d", netSalary.longValue()) : "0";
        String htmlBody = "<div style='font-family:sans-serif;max-width:500px;margin:0 auto;border:1px solid #e2e8f0;border-radius:12px;overflow:hidden'>"
             + "<div style='background:linear-gradient(135deg,#059669,#10b981);padding:28px;text-align:center'>"
             + "<h2 style='color:white;margin:0;font-size:22px'>💰 Lương Đã Về Tài Khoản!</h2></div>"
             + "<div style='padding:32px'>"
             + "<p style='color:#334155;font-size:16px;line-height:1.6'>Xin chào <strong>" + fullName + "</strong>,</p>"
             + "<p style='color:#334155;font-size:15px;line-height:1.6'>Phòng Kế toán trân trọng thông báo: Lương tháng <strong>" + month + "/" + year + "</strong> của bạn đã được thanh toán và chuyển khoản thành công.</p>"
             + "<div style='background:#f0fdf4;border:1px solid #bbf7d0;border-radius:10px;padding:20px;margin:20px 0;text-align:center'>"
             + "<span style='color:#166534;font-size:14px;display:block;margin-bottom:8px'>Số tiền thực nhận (Net Salary)</span>"
             + "<span style='font-size:28px;font-weight:800;color:#15803d;'>" + formattedSalary + " VNĐ</span>"
             + "</div>"
             + "<p style='color:#475569;font-size:14px;line-height:1.5'>Bạn có thể đăng nhập vào hệ thống HRM, chọn mục <strong>Xem Phiếu Lương</strong> để kiểm tra chi tiết các khoản thu nhập và khấu trừ.</p>"
             + "</div>"
             + "<div style='background:#f8fafc;padding:16px;text-align:center;border-top:1px solid #e2e8f0'>"
             + "<p style='color:#94a3b8;font-size:12px;margin:0'>Email này được gửi tự động từ HRM System. Vui lòng không trả lời.</p>"
             + "</div></div>";

        EmailUtil.sendHtmlEmail(toEmail, subject, htmlBody);
    }
}
