/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

import java.sql.Timestamp;

/**
 *
 * @author Thanh Hang
 */
public class User {
    private int userId;
    private String username;
    private String password;
    private String fullName;
    private String email;
    private String phone;
    private String avatarUrl;
    private int status;
    private int roleId;
    private int departmentId;
    private int positionId;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public User() {
    }

    public User(int userId, String username, String password, String fullName, String email, 
                String phone, String avatarUrl, int status, int roleId, Timestamp createdAt, Timestamp updatedAt) {
        this.userId = userId;
        this.username = username;
        this.password = password;
        this.fullName = fullName;
        this.email = email;
        this.phone = phone;
        this.avatarUrl = avatarUrl;
        this.status = status;
        this.roleId = roleId;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    // Các hàm Getters và Setters
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; } // Sẽ chứa mã băm BCrypt

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getAvatarUrl() { return avatarUrl; }
    public void setAvatarUrl(String avatarUrl) { this.avatarUrl = avatarUrl; }

    public int getStatus() { return status; }
    public void setStatus(int status) { this.status = status; }

    public int getRoleId() { return roleId; }
    public void setRoleId(int roleId) { this.roleId = roleId; }

    public int getDepartmentId() { return departmentId; }
    public void setDepartmentId(int departmentId) { this.departmentId = departmentId; }

    public int getPositionId() { return positionId; }
    public void setPositionId(int positionId) { this.positionId = positionId; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
    public String getPasswordHash() {
        return this.password;
    }

    /**
     * Kiểm tra dữ liệu hợp lệ trước khi lưu vào DB.
     * Hàm này là thuần Java, không cần kết nối Database.
     */
    public static String validate(User u) {
        if (u == null) return "User không được null";
        if (u.getUsername() == null || u.getUsername().trim().isEmpty())
            return "Username không được để trống";
        if (u.getUsername().length() > 50)
            return "Username không được vượt quá 50 ký tự";
        if (u.getPassword() == null || u.getPassword().trim().isEmpty())
            return "Password không được để trống";
        if (u.getEmail() == null || u.getEmail().trim().isEmpty())
            return "Email không được để trống";
        if (!u.getEmail().contains("@"))
            return "Email không đúng định dạng";
        if (u.getRoleId() <= 0)
            return "RoleId phải lớn hơn 0";
        if (u.getStatus() != 0 && u.getStatus() != 1)
            return "Status chỉ được là 0 hoặc 1";
        if (u.getPhone() != null && u.getPhone().length() > 15)
            return "Số điện thoại không được vượt quá 15 ký tự";
        return null; // null = hợp lệ
    }
}
