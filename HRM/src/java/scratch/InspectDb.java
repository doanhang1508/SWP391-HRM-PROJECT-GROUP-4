package scratch;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

public class InspectDb {
    public static void main(String[] args) {
        String url = "jdbc:mysql://localhost:3306/hrm_system?useUnicode=true&characterEncoding=UTF-8&serverTimezone=Asia/Ho_Chi_Minh";
        String user = "root";
        String password = "123456";

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(url, user, password);
                 Statement stmt = conn.createStatement()) {
                
                System.out.println("=== Users ===");
                try (ResultSet rs = stmt.executeQuery("SELECT user_id, username, password, role_id, email, status FROM users")) {
                    while (rs.next()) {
                        System.out.printf("ID: %d | User: %s | Pwd: %s | Role: %d | Email: %s | Status: %s\n",
                            rs.getInt("user_id"), rs.getString("username"), rs.getString("password"),
                            rs.getInt("role_id"), rs.getString("email"), rs.getString("status"));
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
