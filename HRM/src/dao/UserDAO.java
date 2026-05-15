package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import model.User;
import utils.DBContext;

public class UserDAO extends DBContext {

    // 7. View User List
    public List<User> getAllUsers() {

    List<User> list = new ArrayList<>();

    String sql = "SELECT * FROM Users";

    try {

        PreparedStatement ps = connection.prepareStatement(sql);

        ResultSet rs = ps.executeQuery();

        while (rs.next()) {

            User u = new User();

            u.setId(rs.getInt("UserID"));

            u.setFullName(rs.getString("FullName"));

            u.setEmail(rs.getString("Email"));

            u.setPassword(rs.getString("Password"));

            u.setRole("Role");

            
           

            u.setDepartment(rs.getString("Department"));
            u.setStatus(rs.getBoolean("Status"));

            list.add(u);

            System.out.println("FOUND USER");
        }

        System.out.println("SIZE = " + list.size());

    } catch (Exception e) {

        e.printStackTrace();
    }

    return list;
}

    // 8. View User Information
   public User getUserById(int id) {

    String sql = "SELECT * FROM Users WHERE UserID = ?";

    try {

        PreparedStatement ps = connection.prepareStatement(sql);

        ps.setInt(1, id);

        ResultSet rs = ps.executeQuery();

        if (rs.next()) {

            User u = new User();

            u.setId(rs.getInt("UserID"));

            u.setFullName(rs.getString("FullName"));

            u.setEmail(rs.getString("Email"));

            u.setPassword(rs.getString("Password"));

            u.setRole(rs.getString("Role"));

            u.setDepartment(rs.getString("Department"));

            u.setStatus(rs.getBoolean("Status"));

            return u;
        }

    } catch (Exception e) {

        e.printStackTrace();
    }

    return null;
}
    // 9. Add New User
   public void insertUser(User u) {

    String sql = """
        INSERT INTO Users
        (FullName, Email, Password, Role, Department, Status)
        VALUES (?, ?, ?, ?, ?, ?)
        """;

    try {

        PreparedStatement ps =
                connection.prepareStatement(sql);

        // FullName
        ps.setString(1, u.getFullName());

        // Email
        ps.setString(2, u.getEmail());

        // Password
        ps.setString(3, u.getPassword());

        // Role
        ps.setString(4, u.getRole());

        // Department
        ps.setString(5, u.getDepartment());

        // Status
        ps.setBoolean(6, u.isStatus());

        ps.executeUpdate();

        System.out.println("INSERT SUCCESS");

    } catch (Exception e) {

        e.printStackTrace();
    }
}
}
