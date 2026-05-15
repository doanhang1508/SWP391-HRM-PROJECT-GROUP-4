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
 
    // ── Tìm theo Email không lọc status (dùng cho Google OAuth) ──
    public User getUserByEmailAny(String email) {
        String sql = "SELECT * FROM users WHERE email = ?";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapResultSetToUser(rs);
            }
        } catch (SQLException e) {
            System.err.println("Lỗi getUserByEmailAny: " + e.getMessage());
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
 
    // ── Tạo hoặc cập nhật user từ Google OAuth ──
    public User createOrUpdateGoogleUser(String email, String fullName, String avatarUrl) {
        User existing = getUserByEmailAny(email);
        if (existing != null) {
            if (avatarUrl != null && !avatarUrl.isEmpty()) {
                updateAvatar(existing.getUserId(), avatarUrl);
                existing.setAvatarUrl(avatarUrl);
            }
            return existing;
        }
        String sql = "INSERT INTO users (username, password, full_name, email, avatar_url, status, role_id) " +
                     "VALUES (?, '', ?, ?, ?, 1, 3)";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            String username = email.contains("@") ? email.split("@")[0] : email;
            ps.setString(1, username);
            ps.setString(2, fullName != null ? fullName : username);
            ps.setString(3, email);
            ps.setString(4, avatarUrl != null ? avatarUrl : "");
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return getUserByEmailAny(email);
            }
        } catch (SQLException e) {
            System.err.println("Lỗi createOrUpdateGoogleUser: " + e.getMessage());
        }
        return null;
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
}