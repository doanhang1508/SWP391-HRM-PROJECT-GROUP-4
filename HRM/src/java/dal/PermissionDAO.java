package dal;

import context.DBContext;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.Permission;
import constant.PageConstant;

public class PermissionDAO extends DBContext {
    
    //Check quyen dong
    
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

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setString(2, permissionName);

            ResultSet rs = ps.executeQuery();
            return rs.next();

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    // xem quyen cua 1 role
    
    public List<Permission> getPermissionsByRoleId(int roleId) {
        List<Permission> list = new ArrayList<>();

        String sql = "SELECT p.permission_id, p.permission_name, p.description "
                + "FROM role_permissions rp "
                + "JOIN permissions p ON rp.permission_id = p.permission_id "
                + "WHERE rp.role_id = ? "
                + "ORDER BY p.permission_id";

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, roleId);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Permission p = new Permission();
                p.setPermissionId(rs.getInt("permission_id"));
                p.setPermissionName(rs.getString("permission_name"));
                p.setDescription(rs.getString("description"));

                list.add(p);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    //Feature 12: view role list
        
    public boolean canViewRoleList(int userId) {
        return hasPermission(userId, "ROLE_VIEW");
    }

    // Feature 13: View role permissions
    
    public boolean canViewRolePermissions(int userId) {
        return hasPermission(userId, "ROLE_PERMISSION_VIEW");
    }

    // Feature 14: Update role information
    public boolean canUpdateRoleInformation(int userId) {
        return hasPermission(userId, "ROLE_UPDATE_INFORMATION");
    }
}
