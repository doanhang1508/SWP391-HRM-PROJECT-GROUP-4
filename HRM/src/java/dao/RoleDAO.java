/*
 * DAO class for Role-related database operations.
 * Handles Active/Deactive Role functionality.
 */
package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.Role;
import util.DBContext;

public class RoleDAO {


    public List<Role> getAllRoles() {
        List<Role> roles = new ArrayList<>();
        String sql = "SELECT role_id, role_name, description, status FROM roles";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Role role = new Role();
                role.setRoleId(rs.getInt("role_id"));
                role.setRoleName(rs.getString("role_name"));
                role.setDescription(rs.getString("description"));
                role.setStatus(rs.getInt("status"));
                roles.add(role);
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
        return roles;
    }

    /**
     *
     * @param roleId the ID of the role to find
     * @return Role object if found, null otherwise
     */
    public Role getRoleById(int roleId) {
        String sql = "SELECT role_id, role_name, description, status FROM roles WHERE role_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, roleId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Role role = new Role();
                    role.setRoleId(rs.getInt("role_id"));
                    role.setRoleName(rs.getString("role_name"));
                    role.setDescription(rs.getString("description"));
                    role.setStatus(rs.getInt("status"));
                    return role;
                }
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Toggles the status of a role (Active ↔ Deactive).
     * If current status is 1 (Active), sets to 0 (Deactive) and vice versa.
     * 
     * When a role is deactivated, ALL users assigned to that role
     * will effectively lose access (their role becomes inactive).
     *
     * @param roleId the ID of the role to toggle
     * @return true if the update was successful, false otherwise
     */
    public boolean toggleRoleStatus(int roleId) {
        // Toggle: if status=1 then set 0, if status=0 then set 1
        String sql = "UPDATE roles SET status = CASE WHEN status = 1 THEN 0 ELSE 1 END WHERE role_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, roleId);
            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Sets the status of a role to a specific value.
     *
     * @param roleId the ID of the role
     * @param status the new status value (1 = Active, 0 = Deactive)
     * @return true if the update was successful, false otherwise
     */
    public boolean updateRoleStatus(int roleId, int status) {
        String sql = "UPDATE roles SET status = ? WHERE role_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, status);
            ps.setInt(2, roleId);
            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Counts the number of users assigned to a specific role.
     * Useful for showing the admin how many users are affected 
     * when activating/deactivating a role.
     *
     * @param roleId the ID of the role
     * @return the number of users with this role
     */
    public int countUsersByRole(int roleId) {
        String sql = "SELECT COUNT(*) AS user_count FROM users WHERE role_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, roleId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("user_count");
                }
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
        return 0;
    }
}
