package dao;
 
import model.User;
import java.math.BigDecimal;
import java.sql.Date;
import java.time.LocalDate;
import model.RewardDiscipline;
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
        user.setStatus(rs.getInt("status"));
        user.setRoleId(rs.getInt("role_id"));
        user.setDepartmentId(rs.getInt("department_id"));
        user.setPositionId(rs.getInt("position_id"));
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

    // ── Lấy danh sách nhân viên theo phòng ban ──
    public java.util.List<User> getByDepartment(int departmentId) {
        java.util.List<User> list = new java.util.ArrayList<>();
        String sql = "SELECT * FROM users WHERE department_id = ? AND status = 1 ORDER BY full_name";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, departmentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToUser(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("Lỗi getByDepartment: " + e.getMessage());
        }
        return list;
    }

    // ── Lấy danh sách nhân viên theo chức vụ ──
    public java.util.List<User> getByPosition(int positionId) {
        java.util.List<User> list = new java.util.ArrayList<>();
        String sql = "SELECT * FROM users WHERE position_id = ? AND status = 1 ORDER BY full_name";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, positionId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToUser(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("Lỗi getByPosition: " + e.getMessage());
        }
        return list;
    }


    public boolean terminateEmployee(int userId, String reason, LocalDate terminationDate) {
        DBContext dbContext = new DBContext();
        Connection conn = null;
        try {
            conn = dbContext.getConnection();
            conn.setAutoCommit(false); // Start Transaction

            // 1. Insert a major discipline record (Dismissal)
            dao.RewardDisciplineDAO rewardDisciplineDAO = new dao.RewardDisciplineDAO();
            RewardDiscipline rdDismissal = rewardDisciplineDAO.getRewardDisciplineByName("Dismissal");
            int dismissalTypeId = (rdDismissal != null) ? rdDismissal.getId() : 8;

            String insertDisciplineSql = "INSERT INTO employee_rewards_disciplines (user_id, reward_discipline_id, amount, note, applied_date) VALUES (?, ?, ?, ?, ?)";
            try (PreparedStatement ps1 = conn.prepareStatement(insertDisciplineSql)) {
                ps1.setInt(1, userId);
                ps1.setInt(2, dismissalTypeId);
                ps1.setBigDecimal(3, BigDecimal.ZERO);
                ps1.setString(4, "Dismissal: " + reason);
                ps1.setDate(5, Date.valueOf(terminationDate));
                if (ps1.executeUpdate() == 0) throw new SQLException("Failed to insert discipline record");
            }

            // 2. Update users table: Set status = 0
            String updateUserSql = "UPDATE users SET status = 0 WHERE user_id = ?";
            try (PreparedStatement ps2 = conn.prepareStatement(updateUserSql)) {
                ps2.setInt(1, userId);
                if (ps2.executeUpdate() == 0) throw new SQLException("Failed to update user status");
            }

            // 3. Update employee_profiles: Change employment_status_id (assuming ID 3 represents Terminated)
            String updateProfileSql = "UPDATE employee_profiles SET employment_status_id = 3 WHERE user_id = ?";
            try (PreparedStatement ps3 = conn.prepareStatement(updateProfileSql)) {
                ps3.setInt(1, userId);
                // Profile might not exist for some admins, so we don't rigidly throw if 0 rows updated, or maybe we do depending on business rules.
                // Assuming it must exist for a terminating employee.
                if (ps3.executeUpdate() == 0) throw new SQLException("Failed to update employee profile status");
            }

            // 4. Update work_history: set end_date
            String updateWorkHistorySql = "UPDATE work_history SET end_date = ? WHERE user_id = ? AND end_date IS NULL";
            try (PreparedStatement ps4 = conn.prepareStatement(updateWorkHistorySql)) {
                ps4.setDate(1, Date.valueOf(terminationDate));
                ps4.setInt(2, userId);
                ps4.executeUpdate(); // Might update 0 rows if no active work history, which is acceptable
            }

            conn.commit(); // Commit Transaction
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback(); // Rollback on failure
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
        }
    }

    // ── Cập nhật đầy đủ thông tin nhân viên từ form chỉnh sửa ──
    public boolean updateUserFull(int userId, String fullName, String email, String phone,
                                  int departmentId, int positionId, int roleId, int status) {
        String sql = "UPDATE users SET full_name = ?, email = ?, phone = ?, " +
                     "department_id = ?, position_id = ?, role_id = ?, status = ? " +
                     "WHERE user_id = ?";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, fullName);
            ps.setString(2, email);
            ps.setString(3, phone);
            if (departmentId > 0) ps.setInt(4, departmentId);
            else ps.setNull(4, java.sql.Types.INTEGER);
            if (positionId > 0) ps.setInt(5, positionId);
            else ps.setNull(5, java.sql.Types.INTEGER);
            ps.setInt(6, roleId);
            ps.setInt(7, status);
            ps.setInt(8, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi updateUserFull: " + e.getMessage());
        }
        return false;
    }
}
