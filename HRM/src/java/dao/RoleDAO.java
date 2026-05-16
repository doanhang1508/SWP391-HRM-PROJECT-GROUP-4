package dao;
 
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.Role;
import util.DBContext;
 
/**
 * RoleDAO - Gộp từ RoleDAO (dao) và RoleDAO (dal).
 *
 * Feature 12: View role list       → getAllRoles()
 * Feature 13: View role detail     → getRoleById()
 * Feature 14: Update role info     → updateRoleInformation(), isRoleNameExistsForOtherRole()
 * Admin toggle/status              → toggleRoleStatus(), updateRoleStatus(), countUsersByRole()
 */
public class RoleDAO {
 
    // ══════════════════════════════════════════════════════════════
    // 1. ĐỌC DỮ LIỆU
    // ══════════════════════════════════════════════════════════════
 
    /**
     * Lấy tất cả role, sắp xếp theo role_id.
     * Feature 12: View role list.
     */
    public List<Role> getAllRoles() {
        List<Role> list = new ArrayList<>();
        String sql = "SELECT role_id, role_name, description, status "
                + "FROM roles "
                + "ORDER BY role_id";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRole(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
 
    /**
     * Lấy thông tin 1 role theo role_id.
     * Feature 13 và 14.
     */
    public Role getRoleById(int roleId) {
        String sql = "SELECT role_id, role_name, description, status "
                + "FROM roles "
                + "WHERE role_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, roleId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRole(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
 
    // ══════════════════════════════════════════════════════════════
    // 2. CẬP NHẬT THÔNG TIN ROLE
    // Nguồn gốc: RoleDAO (dal)
    // ══════════════════════════════════════════════════════════════
 
    /**
     * Cập nhật tên và mô tả role.
     * Feature 14: Chỉ sửa role_name và description.
     * Không sửa permission, không add/delete role.
     */
    public boolean updateRoleInformation(int roleId, String roleName, String description) {
        String sql = "UPDATE roles SET role_name = ?, description = ? WHERE role_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, roleName);
            ps.setString(2, description);
            ps.setInt(3, roleId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
 
    /**
     * Kiểm tra tên role đã tồn tại ở role khác chưa (tránh trùng khi update).
     * Feature 14.
     */
    public boolean isRoleNameExistsForOtherRole(String roleName, int currentRoleId) {
        String sql = "SELECT role_id FROM roles WHERE role_name = ? AND role_id <> ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, roleName);
            ps.setInt(2, currentRoleId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
 
    // ══════════════════════════════════════════════════════════════
    // 3. QUẢN LÝ TRẠNG THÁI ROLE (Active / Deactive)
    // Nguồn gốc: RoleDAO (dao)
    // ══════════════════════════════════════════════════════════════
 
    /**
     * Toggle trạng thái role: Active ↔ Deactive.
     * Khi role bị deactivate, tất cả user thuộc role đó mất quyền truy cập.
     */
    public boolean toggleRoleStatus(int roleId) {
        String sql = "UPDATE roles SET status = CASE WHEN status = 1 THEN 0 ELSE 1 END WHERE role_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, roleId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
 
    /**
     * Set trạng thái role theo giá trị cụ thể.
     *
     * @param status 1 = Active, 0 = Deactive
     */
    public boolean updateRoleStatus(int roleId, int status) {
        String sql = "UPDATE roles SET status = ? WHERE role_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, status);
            ps.setInt(2, roleId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
 
    // ══════════════════════════════════════════════════════════════
    // 4. THỐNG KÊ
    // Nguồn gốc: RoleDAO (dao)
    // ══════════════════════════════════════════════════════════════
 
    /**
     * Đếm số user đang được gán role này.
     * Dùng để cảnh báo admin trước khi deactivate role.
     */
    public int countUsersByRole(int roleId) {
        String sql = "SELECT COUNT(*) AS user_count FROM users WHERE role_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, roleId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("user_count");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
 
    // ══════════════════════════════════════════════════════════════
    // HELPER PRIVATE
    // ══════════════════════════════════════════════════════════════
 
    private Role mapRole(ResultSet rs) throws SQLException {
        Role r = new Role();
        r.setRoleId(rs.getInt("role_id"));
        r.setRoleName(rs.getString("role_name"));
        r.setDescription(rs.getString("description"));
        r.setStatus(rs.getInt("status"));
        return r;
    }
}