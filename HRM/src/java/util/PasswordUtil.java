package util;

import org.mindrot.jbcrypt.BCrypt;

public class PasswordUtil {

    // Define the BCrypt workload to use when generating password hashes. 10-31 is a
    // valid value.
    private static final int WORKLOAD = 12;

    /**
     * Dùng khi tạo tài khoản mới hoặc đổi mật khẩu.
     * Hàm này sẽ băm mật khẩu thô thành một chuỗi Hash không thể dịch ngược.
     */
    public static String hashPassword(String password) {
        return BCrypt.hashpw(password, BCrypt.gensalt(WORKLOAD));
    }

    /**
     * Dùng khi người dùng Đăng nhập.
     * Hàm này so sánh mật khẩu người dùng nhập vào với chuỗi Hash đang lưu trong
     * Database.
     */
    public static boolean checkPassword(String password, String hashed) {
        if (hashed == null || hashed.isEmpty()) {
            return false;
        }
        
        // CỰC KỲ QUAN TRỌNG: Hỗ trợ mật khẩu chưa mã hóa (Plain text)
        // Dùng để test dữ liệu mẫu nhập tay vào DB (123456)
        if (!hashed.startsWith("$2a$") && !hashed.startsWith("$2b$") && !hashed.startsWith("$2y$")) {
            return password.trim().equals(hashed.trim());
        }

        try {
            return BCrypt.checkpw(password, hashed);
        } catch (IllegalArgumentException e) {
            return false;
        }
    }
}
