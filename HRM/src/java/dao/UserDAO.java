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

    // ── Tìm theo Username ──
    public User getUserByUsername(String username) {
        String sql = "SELECT * FROM users WHERE username = ? AND status = 1";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapResultSetToUser(rs);
            }
        } catch (SQLException e) {
            System.err.println("Lỗi getUserByUsername: " + e.getMessage());
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

    // ── Lấy danh sách nhân viên theo danh sách role IDs ──
    public java.util.List<User> getByRoles(int... roleIds) {
        java.util.List<User> list = new java.util.ArrayList<>();
        if (roleIds == null || roleIds.length == 0) return list;
        StringBuilder placeholders = new StringBuilder();
        for (int i = 0; i < roleIds.length; i++) {
            if (i > 0) placeholders.append(",");
            placeholders.append("?");
        }
        String sql = "SELECT * FROM users WHERE role_id IN (" + placeholders + ") AND status = 1 ORDER BY full_name";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 0; i < roleIds.length; i++) {
                ps.setInt(i + 1, roleIds[i]);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToUser(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("Lỗi getByRoles: " + e.getMessage());
        }
        return list;
    }

    // ── Lấy tất cả quản lý (Quản đốc + Trưởng phòng) ──
    public java.util.List<User> getAllManagers() {
        return getByRoles(3, 6); // Factory Manager (3) + Dept Manager (6)
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

    /**
     * Transaction duyệt đơn nghỉ việc. Gồm 3 bước trong cùng 1 transaction:
     * 1. Vô hiệu hóa tài khoản (users.status = 0)
     * 2. Cập nhật trạng thái nhân sự → "Đã nghỉ việc" (employee_profiles.employment_status_id = 4)
     * 3. Chuyển hợp đồng đang Active sang Terminated với end_date = lastWorkingDate
     *
     * Bước 3 bắt buộc để:
     * - getAllEligibleEmployeeIds() loại đúng nhân viên nghỉ trước kỳ lương (Case 1).
     * - getContractAsOf() vẫn tìm được hợp đồng cho nhân viên nghỉ giữa kỳ (Case 2).
     *
     * KHÔNG insert vào employee_rewards_disciplines (khác với terminateEmployee).
     * Rollback toàn bộ nếu bất kỳ bước nào lỗi.
     *
     * @param userId          user_id của nhân viên xin nghỉ
     * @param lastWorkingDate ngày làm việc cuối cùng (= desired_last_date từ resignation_requests)
     * @return true nếu transaction thành công
     */
    public boolean approveResignation(int userId, java.sql.Date lastWorkingDate) {
        // Null-safety: nếu desired_last_date bị null (edge case dữ liệu cũ),
        // dùng ngày hiện tại để tránh để hợp đồng open-ended mãi.
        if (lastWorkingDate == null) {
            lastWorkingDate = new java.sql.Date(System.currentTimeMillis());
            System.err.println("[PAYROLL WARNING] approveResignation: lastWorkingDate is null for userId="
                    + userId + ". Defaulting to today: " + lastWorkingDate);
        }

        DBContext dbContext = new DBContext();
        Connection conn = null;
        try {
            conn = dbContext.getConnection();
            conn.setAutoCommit(false); // Start Transaction

            // 1. Vô hiệu hóa tài khoản
            String updateUserSql = "UPDATE users SET status = 0 WHERE user_id = ?";
            try (PreparedStatement ps1 = conn.prepareStatement(updateUserSql)) {
                ps1.setInt(1, userId);
                if (ps1.executeUpdate() == 0) {
                    throw new SQLException("approveResignation: Failed to update user status for userId=" + userId);
                }
            }

            // 2. Cập nhật trạng thái nhân sự = 4 (Đã nghỉ việc)
            String updateProfileSql = "UPDATE employee_profiles SET employment_status_id = 4 WHERE user_id = ?";
            try (PreparedStatement ps2 = conn.prepareStatement(updateProfileSql)) {
                ps2.setInt(1, userId);
                // Nếu employee_profiles không tồn tại (edge case admin), vẫn cho phép
                ps2.executeUpdate();
            }

            // 3. Chuyển hợp đồng Active sang Terminated với actual_end_date = lastWorkingDate.
            //    Điều kiện: chỉ áp dụng cho hợp đồng active chưa có end_date
            //    hoặc có end_date sau ngày nghỉ (tránh update nhầm hợp đồng đã hết hạn đúng trước đó).
            String updateContractSql =
                    "UPDATE employee_contracts " +
                    "SET status = 'Terminated', actual_end_date = ? " +
                    "WHERE user_id = ? " +
                    "  AND status = 'Active' " +
                    "  AND (end_date IS NULL OR end_date > ?)";
            try (PreparedStatement ps3 = conn.prepareStatement(updateContractSql)) {
                ps3.setDate(1, lastWorkingDate);
                ps3.setInt(2, userId);
                ps3.setDate(3, lastWorkingDate);
                int contractsUpdated = ps3.executeUpdate();
                System.out.println("[PAYROLL INFO] approveResignation: userId=" + userId
                        + " — terminated " + contractsUpdated + " contract(s), actual_end_date=" + lastWorkingDate);
            }

            conn.commit(); // Commit Transaction — cả 3 bước
            return true;

        } catch (Exception e) {
            System.err.println("approveResignation error: " + e.getMessage());
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException ex) { ex.printStackTrace(); }
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

    public java.util.List<User> getActiveEmployees() {
        java.util.List<User> list = new java.util.ArrayList<>();
        String sql = "SELECT * FROM users WHERE status = 1 AND role_id != 1 ORDER BY full_name";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToUser(rs));
            }
        } catch (SQLException e) {
            System.err.println("Lỗi getActiveEmployees: " + e.getMessage());
        }
        return list;
    }

    // ── Lấy dữ liệu biểu đồ phân bổ vai trò ──
    public java.util.Map<String, Integer> getUserRoleDistribution() {
        java.util.Map<String, Integer> map = new java.util.LinkedHashMap<>();
        String sql = "SELECT r.role_name, COUNT(u.user_id) as count " +
                     "FROM roles r LEFT JOIN users u ON r.role_id = u.role_id AND u.status = 1 " +
                     "GROUP BY r.role_name " +
                     "ORDER BY count DESC";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                map.put(rs.getString("role_name"), rs.getInt("count"));
            }
        } catch (SQLException e) {
            System.err.println("Lỗi getUserRoleDistribution: " + e.getMessage());
        }
        return map;
    }

    // ── Lấy dữ liệu biểu đồ người dùng mới trong 6 tháng qua ──
    public java.util.Map<String, Integer> getNewUsersLast6Months() {
        java.util.Map<String, Integer> map = new java.util.LinkedHashMap<>();
        
        // Tạo 6 tháng gần nhất (bao gồm cả tháng hiện tại) với giá trị mặc định là 0
        java.time.YearMonth currentMonth = java.time.YearMonth.now();
        java.time.format.DateTimeFormatter formatter = java.time.format.DateTimeFormatter.ofPattern("MM/yyyy");
        for (int i = 5; i >= 0; i--) {
            map.put(currentMonth.minusMonths(i).format(formatter), 0);
        }

        String sql = "SELECT DATE_FORMAT(created_at, '%m/%Y') as month_str, COUNT(user_id) as count " +
                     "FROM users " +
                     "WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH) " +
                     "GROUP BY DATE_FORMAT(created_at, '%m/%Y') " +
                     "ORDER BY MIN(created_at) ASC";
                     
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String monthStr = rs.getString("month_str");
                if (map.containsKey(monthStr)) {
                    map.put(monthStr, rs.getInt("count"));
                }
            }
        } catch (SQLException e) {
            System.err.println("Lỗi getNewUsersLast6Months: " + e.getMessage());
        }
        return map;
    }

    // ── Thống kê cho HR Report ──
    public int countNewEmployeesThisMonth() {
        String sql = "SELECT COUNT(*) FROM users WHERE status = 1 AND MONTH(created_at) = MONTH(CURDATE()) AND YEAR(created_at) = YEAR(CURDATE())";
        return countQuery(sql);
    }

    public java.util.Map<String, Integer> getHeadcountByDepartment() {
        java.util.Map<String, Integer> map = new java.util.LinkedHashMap<>();
        String sql = "SELECT d.department_name, COUNT(u.user_id) as count " +
                     "FROM departments d LEFT JOIN users u ON d.department_id = u.department_id AND u.status = 1 " +
                     "GROUP BY d.department_name " +
                     "ORDER BY count DESC";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                map.put(rs.getString("department_name"), rs.getInt("count"));
            }
        } catch (SQLException e) {
            System.err.println("Lỗi getHeadcountByDepartment: " + e.getMessage());
        }
        return map;
    }
}
