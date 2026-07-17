import util.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/** Adds the users referenced by NV0021 and NV0027 in the attendance workbook. */
public class InsertMissingUsers {
    public static void main(String[] args) {
        String checkSql = "SELECT user_id, username FROM users WHERE user_id = ? OR username = ?";
        String insertSql = "INSERT INTO users (user_id, username, password, full_name, email, phone, role_id, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement check = conn.prepareStatement(checkSql);
             PreparedStatement insert = conn.prepareStatement(insertSql)) {
            insertIfMissing(check, insert, 21, "NV0021", "Ngô Văn Ốm", "nv0021@test.com", "0123456021");
            insertIfMissing(check, insert, 27, "NV0027", "Vũ Thị Thai Sản", "nv0027@test.com", "0123456027");
        } catch (Exception e) {
            e.printStackTrace();
            System.exit(1);
        }
    }

    private static void insertIfMissing(PreparedStatement check, PreparedStatement insert,
                                        int userId, String username, String fullName,
                                        String email, String phone) throws Exception {
        check.setInt(1, userId);
        check.setString(2, username);
        try (ResultSet rs = check.executeQuery()) {
            if (rs.next()) {
                if (rs.getInt("user_id") != userId || !username.equalsIgnoreCase(rs.getString("username"))) {
                    throw new IllegalStateException("Mã " + username + " đang xung đột với dữ liệu hiện có.");
                }
                System.out.println(username + " already exists");
                return;
            }
        }

        insert.setInt(1, userId);
        insert.setString(2, username);
        insert.setString(3, "$2a$12$9rsQL.viVSSU3uxAqO4aI.LVVYSyc6i1BaZSvrF5SPnAKijaaMmFK");
        insert.setString(4, fullName);
        insert.setString(5, email);
        insert.setString(6, phone);
        insert.setInt(7, 7);
        insert.setInt(8, 1);
        insert.executeUpdate();
        System.out.println("Inserted " + username + " as user_id " + userId);
    }
}
