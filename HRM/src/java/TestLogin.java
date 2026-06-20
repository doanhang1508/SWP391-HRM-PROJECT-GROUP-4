import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class TestLogin {
    public static void main(String[] args) {
        try {
            // Load DB properties, driver manually if needed since it's a standalone script
            // But util.DBContext does it in static block!
            System.out.println("Testing DB connection...");
            String email = "hr@hrm.com";
            String password = "@123456";

            String sql = "SELECT * FROM users WHERE email = ? AND status = 1";
            try (Connection conn = util.DBContext.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, email);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        System.out.println("User found!");
                        System.out.println("user_id: " + rs.getInt("user_id"));
                        System.out.println("email: " + rs.getString("email"));
                        String dbPassword = rs.getString("password");
                        System.out.println("password in DB: " + dbPassword);
                        
                        // Check using PasswordUtil
                        boolean check = util.PasswordUtil.checkPassword(password, dbPassword);
                        System.out.println("Password check result: " + check);
                    } else {
                        System.out.println("User not found or status != 1");
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
