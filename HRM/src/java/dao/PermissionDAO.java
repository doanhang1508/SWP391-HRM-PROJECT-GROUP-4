package dao;
 
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.Permission;
import util.DBContext;
 
/**
 * PermissionDAO - Gộp từ RolePermissionDAO (dao) và PermissionDAO (dal).
 *
 * Phân biệt 2 loại hasPermission:
 *  - hasPermissionByRole(roleId, permissionId)   → dùng khi đã có roleId (admin UI)
 *  - hasPermission(userId, permissionName)        → dùng khi kiểm tra quyền động theo user
 */
public class PermissionDAO {
 
    // ══════════════════════════════════════════════════════════════
    // 1. KIỂM TRA QUYỀN
    // ══════════════════════════════════════════════════════════════
 
    /**
     * Kiểm tra quyền động: user có permission tên X không?
     * Join qua users → roles → role_permissions → permissions.
     * Nguồn gốc: PermissionDAO (dal)
     */
    public boolean hasPermission(int userId, String permissionName) {
        String sql = "SELECT p.permission_id "
                + "FROM users u "
                + "JOIN roles r ON u.role_id = r.role_id "
                + "JOIN role_permissions rp ON r.role_id = rp.role_id "
                + "JOIN permissions p ON rp.permission_id = p.permission_id "
                + "WHERE u.user_id = ? "
                + "AND p.permission_name = ? "
                + "AND u.status = 1 "
                + "AND r.status = 1";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, permissionName);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
 
    /**
     * Kiểm tra role có permission cụ thể không (theo ID).
     * Dùng trong admin UI quản lý role.
     * Nguồn gốc: RolePermissionDAO (dao)
     */
    public boolean hasPermissionByRole(int roleId, int permissionId) {
        String sql = "SELECT COUNT(*) AS cnt FROM role_permissions WHERE role_id = ? AND permission_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, roleId);
            ps.setInt(2, permissionId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("cnt") > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
 
    // ══════════════════════════════════════════════════════════════
    // 2. CÁC HELPER KIỂM TRA QUYỀN THEO TÊN (Feature guards)
    // Nguồn gốc: PermissionDAO (dal)
    // ══════════════════════════════════════════════════════════════
 
    /** Feature 12: Xem danh sách role */
    public boolean canViewRoleList(int userId) {
        return hasPermission(userId, "ROLE_VIEW");
    }
 
    /** Feature 13: Xem quyền của role */
    public boolean canViewRolePermissions(int userId) {
        return hasPermission(userId, "ROLE_PERMISSION_VIEW");
    }
 
    /** Feature 14: Cập nhật thông tin role */
    public boolean canUpdateRoleInformation(int userId) {
        return hasPermission(userId, "ROLE_UPDATE_INFORMATION");
    }
 
    // ══════════════════════════════════════════════════════════════
    // 3. LẤY DANH SÁCH PERMISSION
    // ══════════════════════════════════════════════════════════════
 
    /**
     * Lấy tất cả permission trong hệ thống.
     * Nguồn gốc: RolePermissionDAO (dao)
     */
    public List<Permission> getAllPermissions() {
        List<Permission> permissions = new ArrayList<>();
        String sql = "SELECT permission_id, permission_name, description FROM permissions";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                permissions.add(mapPermission(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return permissions;
    }
 
    /**
     * Lấy danh sách permission của 1 role (trả về object).
     * Nguồn gốc: cả 2 file (giống nhau, giữ 1)
     */
    public List<Permission> getPermissionsByRoleId(int roleId) {
        List<Permission> list = new ArrayList<>();
        String sql = "SELECT p.permission_id, p.permission_name, p.description "
                + "FROM role_permissions rp "
                + "JOIN permissions p ON rp.permission_id = p.permission_id "
                + "WHERE rp.role_id = ? "
                + "ORDER BY p.permission_id";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, roleId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapPermission(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
 
    /**
     * Lấy danh sách permission ID của 1 role (tiện so sánh khi cập nhật).
     * Nguồn gốc: RolePermissionDAO (dao)
     */
    public List<Integer> getPermissionIdsByRoleId(int roleId) {
        List<Integer> ids = new ArrayList<>();
        String sql = "SELECT permission_id FROM role_permissions WHERE role_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, roleId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) ids.add(rs.getInt("permission_id"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return ids;
    }
 
    // ══════════════════════════════════════════════════════════════
    // 4. CẬP NHẬT PERMISSION CHO ROLE
    // Nguồn gốc: RolePermissionDAO (dao)
    // ══════════════════════════════════════════════════════════════
 
    /**
     * Thay thế toàn bộ permission của 1 role (xóa cũ, thêm mới).
     * Dùng transaction để đảm bảo tính nhất quán.
     */
    public boolean updateRolePermissions(int roleId, List<Integer> permissionIds) {
        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);
 
            // Xóa toàn bộ permission cũ
            try (PreparedStatement deletePs = conn.prepareStatement(
                    "DELETE FROM role_permissions WHERE role_id = ?")) {
                deletePs.setInt(1, roleId);
                deletePs.executeUpdate();
            }
 
            // Thêm permission mới (nếu có)
            if (permissionIds != null && !permissionIds.isEmpty()) {
                try (PreparedStatement insertPs = conn.prepareStatement(
                        "INSERT INTO role_permissions (role_id, permission_id) VALUES (?, ?)")) {
                    for (int permId : permissionIds) {
                        insertPs.setInt(1, roleId);
                        insertPs.setInt(2, permId);
                        insertPs.addBatch();
                    }
                    insertPs.executeBatch();
                }
            }
 
            conn.commit();
            return true;
 
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            return false;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
 
    /**
     * Thêm 1 permission vào role.
     * Nguồn gốc: RolePermissionDAO (dao)
     */
    public boolean addPermissionToRole(int roleId, int permissionId) {
        String sql = "INSERT INTO role_permissions (role_id, permission_id) VALUES (?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, roleId);
            ps.setInt(2, permissionId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
 
    /**
     * Xóa 1 permission khỏi role.
     * Nguồn gốc: RolePermissionDAO (dao)
     */
    public boolean removePermissionFromRole(int roleId, int permissionId) {
        String sql = "DELETE FROM role_permissions WHERE role_id = ? AND permission_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, roleId);
            ps.setInt(2, permissionId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
 
    // ══════════════════════════════════════════════════════════════
    // HELPER PRIVATE
    // ══════════════════════════════════════════════════════════════
 
    private Permission mapPermission(ResultSet rs) throws SQLException {
        Permission p = new Permission();
        p.setPermissionId(rs.getInt("permission_id"));
        p.setPermissionName(rs.getString("permission_name"));
        p.setDescription(rs.getString("description"));
        return p;
    }
}