package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.Permission;
import util.DBContext;

public class RolePermissionDAO {

    /**
     * Retrieves all available permissions in the system.
     *
     * @return List of all Permission objects
     */
    public List<Permission> getAllPermissions() {
        List<Permission> permissions = new ArrayList<>();
        String sql = "SELECT permission_id, permission_name, description FROM permissions";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Permission perm = new Permission();
                perm.setPermissionId(rs.getInt("permission_id"));
                perm.setPermissionName(rs.getString("permission_name"));
                perm.setDescription(rs.getString("description"));
                permissions.add(perm);
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
        return permissions;
    }

    /**
     * Retrieves the permissions currently assigned to a specific role.
     *
     * @param roleId the ID of the role
     * @return List of Permission objects assigned to this role
     */
    public List<Permission> getPermissionsByRoleId(int roleId) {
        List<Permission> permissions = new ArrayList<>();
        String sql = "SELECT p.permission_id, p.permission_name, p.description "
                + "FROM permissions p "
                + "INNER JOIN role_permissions rp ON p.permission_id = rp.permission_id "
                + "WHERE rp.role_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, roleId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Permission perm = new Permission();
                    perm.setPermissionId(rs.getInt("permission_id"));
                    perm.setPermissionName(rs.getString("permission_name"));
                    perm.setDescription(rs.getString("description"));
                    permissions.add(perm);
                }
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
        return permissions;
    }

    /**
     * Gets the list of permission IDs currently assigned to a role.
     * Convenient for comparing with the new permission set from the form.
     *
     * @param roleId the ID of the role
     * @return List of permission IDs
     */
    public List<Integer> getPermissionIdsByRoleId(int roleId) {
        List<Integer> permissionIds = new ArrayList<>();
        String sql = "SELECT permission_id FROM role_permissions WHERE role_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, roleId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    permissionIds.add(rs.getInt("permission_id"));
                }
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
        return permissionIds;
    }

    /**
     * Updates the permissions for a role.
     * This method performs a full replacement:
     * 1. Deletes all existing permissions for the role.
     * 2. Inserts the new set of permissions.
     * 
     * Uses a transaction to ensure data consistency — either all changes
     * are committed or none are (atomic operation).
     *
     * @param roleId the ID of the role
     * @param permissionIds the new list of permission IDs to assign
     * @return true if the update was successful, false otherwise
     */
    public boolean updateRolePermissions(int roleId, List<Integer> permissionIds) {
        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false); // Start transaction

            // Step 1: Delete all existing permissions for this role
            String deleteSql = "DELETE FROM role_permissions WHERE role_id = ?";
            try (PreparedStatement deletePs = conn.prepareStatement(deleteSql)) {
                deletePs.setInt(1, roleId);
                deletePs.executeUpdate();
            }

            // Step 2: Insert new permissions (if any)
            if (permissionIds != null && !permissionIds.isEmpty()) {
                String insertSql = "INSERT INTO role_permissions (role_id, permission_id) VALUES (?, ?)";
                try (PreparedStatement insertPs = conn.prepareStatement(insertSql)) {
                    for (int permId : permissionIds) {
                        insertPs.setInt(1, roleId);
                        insertPs.setInt(2, permId);
                        insertPs.addBatch();
                    }
                    insertPs.executeBatch();
                }
            }

            conn.commit(); // Commit transaction
            return true;

        } catch (SQLException | ClassNotFoundException e) {
            // Rollback on error
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
            return false;
        } finally {
            // Restore auto-commit and close connection
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    /**
     * Adds a single permission to a role.
     *
     * @param roleId the ID of the role
     * @param permissionId the ID of the permission to add
     * @return true if successful, false otherwise
     */
    public boolean addPermissionToRole(int roleId, int permissionId) {
        String sql = "INSERT INTO role_permissions (role_id, permission_id) VALUES (?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, roleId);
            ps.setInt(2, permissionId);
            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Removes a single permission from a role.
     *
     * @param roleId the ID of the role
     * @param permissionId the ID of the permission to remove
     * @return true if successful, false otherwise
     */
    public boolean removePermissionFromRole(int roleId, int permissionId) {
        String sql = "DELETE FROM role_permissions WHERE role_id = ? AND permission_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, roleId);
            ps.setInt(2, permissionId);
            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Checks if a role already has a specific permission.
     *
     * @param roleId the ID of the role
     * @param permissionId the ID of the permission
     * @return true if the role has this permission, false otherwise
     */
    public boolean hasPermission(int roleId, int permissionId) {
        String sql = "SELECT COUNT(*) AS cnt FROM role_permissions WHERE role_id = ? AND permission_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, roleId);
            ps.setInt(2, permissionId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("cnt") > 0;
                }
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
        return false;
    }
}
