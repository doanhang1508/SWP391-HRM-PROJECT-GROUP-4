import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;
import org.mindrot.jbcrypt.BCrypt;

public class CheckAttendance {
    public static void main(String[] args) {
        String url = "jdbc:mysql://localhost:3306/hrm_system?useUnicode=true&characterEncoding=UTF-8&serverTimezone=Asia/Ho_Chi_Minh";
        String user = "root";
        String password = "123456";

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(url, user, password);
                 Statement stmt = conn.createStatement()) {
                
                System.out.println("--- CHECK PASSWORDS ---");
                try (ResultSet rs = stmt.executeQuery("SELECT username, password FROM users WHERE username IN ('cong_nhan', 'quan_doc', 'admin')")) {
                    while (rs.next()) {
                        String uname = rs.getString("username");
                        String hash = rs.getString("password");
                        boolean is123456 = BCrypt.checkpw("123456", hash);
                        boolean isAt123456 = BCrypt.checkpw("@123456", hash);
                        boolean isUsername = BCrypt.checkpw(uname, hash);
                        System.out.printf("User: %s | Match 123456: %b | Match @123456: %b | Match username: %b\n", uname, is123456, isAt123456, isUsername);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
