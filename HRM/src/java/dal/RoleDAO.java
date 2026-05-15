package dal;

import context.DBContext;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.Role;
import constant.PageConstant;

public class RoleDAO extends DBContext {

    /*
        Feature 12: View role list
        Lấy danh sách role để hiển thị.
    */
    public List<Role> getAllRoles() {
        List<Role> list = new ArrayList<>();

        String sql = "SELECT role_id, role_name, description, status "
                + "FROM roles "
                + "ORDER BY role_id";

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Role r = new Role();
                r.setRoleId(rs.getInt("role_id"));
                r.setRoleName(rs.getString("role_name"));
                r.setDescription(rs.getString("description"));
                r.setStatus(rs.getInt("status"));

                list.add(r);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    /*
        Dùng cho feature 13 và 14.
        Lấy thông tin 1 role theo role_id.
    */
    public Role getRoleById(int roleId) {
        String sql = "SELECT role_id, role_name, description, status "
                + "FROM roles "
                + "WHERE role_id = ?";

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, roleId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                Role r = new Role();
                r.setRoleId(rs.getInt("role_id"));
                r.setRoleName(rs.getString("role_name"));
                r.setDescription(rs.getString("description"));
                r.setStatus(rs.getInt("status"));

                return r;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    /*
        Feature 14: Update role information
        Chỉ cho sửa role_name và description.
        Không sửa permission.
        Không add role.
        Không delete role.
    */
    public boolean updateRoleInformation(int roleId, String roleName, String description) {
        String sql = "UPDATE roles "
                + "SET role_name = ?, description = ? "
                + "WHERE role_id = ?";

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setString(1, roleName);
            ps.setString(2, description);
            ps.setInt(3, roleId);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    // CHECK TRUNG TEN ROLE KHI UPDATE
    
    public boolean isRoleNameExistsForOtherRole(String roleName, int currentRoleId) {
        String sql = "SELECT role_id "
                + "FROM roles "
                + "WHERE role_name = ? "
                + "AND role_id <> ?";

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setString(1, roleName);
            ps.setInt(2, currentRoleId);

            ResultSet rs = ps.executeQuery();
            return rs.next();

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }
}