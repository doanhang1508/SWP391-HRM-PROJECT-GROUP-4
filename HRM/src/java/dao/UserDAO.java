package dao;
 
import model.User;
import util.DBContext;
import util.PasswordUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
 
public class UserDAO {
 
    // ── Đăng nhập: tìm theo USERNAME + kiểm tra password bằng BCrypt ──
    // FIX: đổi tên thành findByUsernameAndPassword cho đúng với loginController
    // FIX: bỏ so sánh plain text, dùng PasswordUtil.checkPassword (hỗ trợ cả plain lẫn BCrypt)
    public User findByUsernameAndPassword(String username, String password) {
        String sql = "SELECT * FROM users WHERE username = ? AND status = 1";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User user = mapResultSetToUser(rs);
                    // FIX: dùng BCrypt check thay vì .equals()
                    // PasswordUtil.checkPassword hỗ trợ cả plain text lẫn BCrypt hash
                    if (PasswordUtil.checkPassword(password, user.getPassword())) {
                        return user;
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("Lỗi login: " + e.getMessage());
        }
        return null;
    }
 
    // ── Tìm theo Email + Password (giữ lại cho các nơi khác dùng) ──
    public User findByEmailAndPassword(String email, String password) {
        String sql = "SELECT * FROM users WHERE email = ? AND status = 1";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User user = mapResultSetToUser(rs);
                    if (PasswordUtil.checkPassword(password, user.getPassword())) {
                        return user;
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("Lỗi login by email: " + e.getMessage());
        }
        return null;
    }
 
    // ── Tìm theo Email (dùng cho quên mật khẩu, chỉ lấy active) ──
    public User getUserByEmail(String email) {
        String sql = "SELECT * FROM users WHERE email = ? AND status = 1";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapResultSetToUser(rs);
            }
        } catch (SQLException e) {
            System.err.println("Lỗi getUserByEmail: " + e.getMessage());
        }
        return null;
    }
 

    // ── Cập nhật mật khẩu ──
    public boolean updatePassword(int userId, String newHashedPassword) {
        String sql = "UPDATE users SET password = ? WHERE user_id = ?";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newHashedPassword);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi updatePassword: " + e.getMessage());
        }
        return false;
    }
 
    // ── Cập nhật avatar ──
    public boolean updateAvatar(int userId, String avatarUrl) {
        String sql = "UPDATE users SET avatar_url = ? WHERE user_id = ?";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, avatarUrl);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi updateAvatar: " + e.getMessage());
        }
        return false;
    }
 
    // ── Cập nhật hồ sơ ──
    public boolean updateProfile(int userId, String fullName, String phone) {
        String sql = "UPDATE users SET full_name = ?, phone = ? WHERE user_id = ?";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, fullName);
            ps.setString(2, phone);
            ps.setInt(3, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi updateProfile: " + e.getMessage());
        }
        return false;
    }
 

    // ── Thống kê cho Admin Dashboard ──
    public int getTotalUsers() {
        return countQuery("SELECT COUNT(*) FROM users");
    }
 
    public int getActiveUsers() {
        return countQuery("SELECT COUNT(*) FROM users WHERE status = 1");
    }
 
    public int getTotalRoles() {
        return countQuery("SELECT COUNT(*) FROM roles WHERE status = 1");
    }
 
    private int countQuery(String sql) {
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            System.err.println("Lỗi countQuery: " + e.getMessage());
        }
        return 0;
    }
 
    // ── Map ResultSet → User ──
    private User mapResultSetToUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setUserId(rs.getInt("user_id"));
        user.setUsername(rs.getString("username"));
        user.setPassword(rs.getString("password"));
        user.setFullName(rs.getString("full_name"));
        user.setEmail(rs.getString("email"));
        user.setPhone(rs.getString("phone"));
        user.setAvatarUrl(rs.getString("avatar_url"));
        user.setStatus(rs.getInt("status"));
        user.setRoleId(rs.getInt("role_id"));
        user.setCreatedAt(rs.getTimestamp("created_at"));
        user.setUpdatedAt(rs.getTimestamp("updated_at"));
        return user;
    }

    // ── Lấy danh sách tất cả người dùng (Admin view) ──
    public java.util.List<User> getAllUsers() {
        java.util.List<User> list = new java.util.ArrayList<>();
        String sql = "SELECT * FROM users ORDER BY user_id";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToUser(rs));
            }
        } catch (SQLException e) {
            System.err.println("Lỗi getAllUsers: " + e.getMessage());
        }
        return list;
    }

    // ── Lấy user theo ID ──
    public User getUserById(int userId) {
        String sql = "SELECT * FROM users WHERE user_id = ?";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapResultSetToUser(rs);
            }
        } catch (SQLException e) {
            System.err.println("Lỗi getUserById: " + e.getMessage());
        }
        return null;
    }

    // ── Cập nhật trạng thái (active = 1 / inactive = 0) ──
    public boolean updateUserStatus(int userId, int status) {
        String sql = "UPDATE users SET status = ? WHERE user_id = ?";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, status);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi updateUserStatus: " + e.getMessage());
        }
        return false;
    }

    // ── Cập nhật role của user ──
    public boolean updateUserRole(int userId, int roleId) {
        String sql = "UPDATE users SET role_id = ? WHERE user_id = ?";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, roleId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi updateUserRole: " + e.getMessage());
        }
        return false;
    }

    // ── Kiểm tra username hoặc email đã tồn tại ──
    public boolean isUserExists(String username, String email) {
        String sql = "SELECT 1 FROM users WHERE username = ? OR email = ?";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, email);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            System.err.println("Lỗi isUserExists: " + e.getMessage());
        }
        return false;
    }

    // ── Thêm người dùng mới ──
    public boolean addUser(User user) {
        String sql = "INSERT INTO users (username, password, full_name, email, phone, role_id, status) VALUES (?, ?, ?, ?, ?, ?, ?)";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user.getUsername());
            // Mã hóa mật khẩu trước khi chèn vào database
            String hashedPassword = PasswordUtil.hashPassword(user.getPassword());
            ps.setString(2, hashedPassword);
            ps.setString(3, user.getFullName());
            ps.setString(4, user.getEmail());
            ps.setString(5, user.getPhone());
            ps.setInt(6, user.getRoleId());
            ps.setInt(7, user.getStatus());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi addUser: " + e.getMessage());
        }
        return false;
    }
    
        // ── Tìm kiếm theo tên nhân viên ──
    public java.util.List<User> searchUsersByName(String keyword) {

        java.util.List<User> list = new java.util.ArrayList<>();

        String sql = """
                     SELECT *
                     FROM users
                     WHERE full_name LIKE ?
                     ORDER BY user_id
                     """;

        DBContext dbContext = new DBContext();

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, "%" + keyword + "%");

            try (ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {

                    list.add(mapResultSetToUser(rs));
                }
            }

        } catch (SQLException e) {

            System.err.println("Lỗi searchUsersByName: " + e.getMessage());
        }

        return list;
    }

    // ── Tìm kiếm theo tên + lọc role ──
    public java.util.List<User> searchUsers(String keyword, int roleId) {

        java.util.List<User> list = new java.util.ArrayList<>();

        String sql = """
                     SELECT *
                     FROM users
                     WHERE full_name LIKE ?
                     AND role_id = ?
                     ORDER BY user_id
                     """;

        DBContext dbContext = new DBContext();

        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, "%" + keyword + "%");
            ps.setInt(2, roleId);

            try (ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {

                    list.add(mapResultSetToUser(rs));
                }
            }

        } catch (SQLException e) {

            System.err.println("Lỗi searchUsers: " + e.getMessage());
        }

        return list;
    }
}
