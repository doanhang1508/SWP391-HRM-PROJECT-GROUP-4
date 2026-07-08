/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;
import model.notification;
import util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
/**
 *
 * @author Thanh Hang
 */
public class notificationDAO {
    // ── Tạo thông báo (nhận object Notification) ───────────────
    public void create(notification n) {
        String sql = "INSERT INTO notifications (user_id, type, title, body, link) " +
                     "VALUES (?, ?, ?, ?, ?)";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt   (1, n.getUserId());
            ps.setString(2, n.getType());
            ps.setString(3, n.getTitle());
            ps.setString(4, n.getBody()  != null ? n.getBody()  : "");
            ps.setString(5, n.getLink()  != null ? n.getLink()  : null);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
     /* Đếm thông báo chưa đọc */
    public int countUnread(int userId) {
        String sql = "SELECT COUNT(*) FROM notifications WHERE user_id=? AND is_read=0";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }
 
    /* Lấy danh sách thông báo mới nhất */
    public List<notification> findByEmployee(int userId, int limit) {
        String sql = "SELECT id, type, title, body, link, is_read, created_at " +
                     "FROM notifications WHERE user_id=? " +
                     "ORDER BY created_at DESC LIMIT ?";
        List<notification> list = new ArrayList<>();
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, limit);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                notification dao = new notification();
                dao.setId(rs.getInt("id"));
                dao.setType(rs.getString("type"));
                dao.setTitle(rs.getString("title"));
                dao.setBody(rs.getString("body"));
                dao.setLink(rs.getString("link"));
                dao.setRead(rs.getInt("is_read") == 1);
                LocalDateTime createdAt = rs.getTimestamp("created_at").toLocalDateTime();
                dao.setCreatedAt(createdAt);
                dao.setTimeAgo(toTimeAgo(createdAt));
                list.add(dao);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }
 
    /* Đánh dấu 1 thông báo đã đọc (chỉ của đúng user) */
    public void markRead(int notifId, int userId) {
        String sql = "UPDATE notifications SET is_read=1 WHERE id=? AND user_id=?";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, notifId);
            ps.setInt(2, userId);
            ps.executeUpdate();
        } catch (SQLException e) { e.printStackTrace(); }
    }
 
    /* Đánh dấu tất cả đã đọc */
    public void markAllRead(int userId) {
        String sql = "UPDATE notifications SET is_read=1 WHERE user_id=? AND is_read=0";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        } catch (SQLException e) { e.printStackTrace(); }
    }
 
    /* Helper: chuyển thời gian thành "5 phút trước", "Hôm qua 14:30"… */
    private String toTimeAgo(LocalDateTime dt) {
        LocalDateTime now = LocalDateTime.now();
        long minutes = ChronoUnit.MINUTES.between(dt, now);
        if (minutes < 1)   return "Vừa xong";
        if (minutes < 60)  return minutes + " phút trước";
        long hours = ChronoUnit.HOURS.between(dt, now);
        if (hours < 24)    return hours + " giờ trước";
        long days = ChronoUnit.DAYS.between(dt.toLocalDate(), now.toLocalDate());
        if (days == 1)     return "Hôm qua " + String.format("%02d:%02d", dt.getHour(), dt.getMinute());
        if (days < 7)      return days + " ngày trước";
        return dt.getDayOfMonth() + "/" + dt.getMonthValue() + "/" + dt.getYear();
    }
 
    /*
     * ── Utility: tạo thông báo từ các module khác ──
     *
     * Gọi trong LeaveServlet, AttendanceServlet, PayrollServlet, v.v.:
     *   new notificationDAO().create(empId, "leave", "Đơn nghỉ phép được duyệt",
     *       "Đơn xin nghỉ 3 ngày của bạn đã được HR duyệt.", "/leave/detail?id=12");
     */
    public void create(int userId, String type, String title, String body, String link) {
        String sql = "INSERT INTO notifications (user_id, type, title, body, link) VALUES (?,?,?,?,?)";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt   (1, userId);
            ps.setString(2, type);
            ps.setString(3, title);
            ps.setString(4, body);
            ps.setString(5, link);
            ps.executeUpdate();
        } catch (SQLException e) { e.printStackTrace(); }
    }

    /*
     * ── Utility: gửi thông báo cho TẤT CẢ user thuộc một hoặc nhiều role ──
     *
     * Dùng khi nhân viên thực hiện hành động cần thông báo cho các bên liên quan
     * theo vai trò (VD: HR Manager, HR Staff) mà không phụ thuộc phòng ban.
     *
     *   new notificationDAO().createForRoles(new int[]{2, 5}, "system",
     *       "Đơn xin nghỉ việc mới", "Nguyễn Văn A vừa gửi đơn xin nghỉ việc.", "/hr/resignation-approval");
     */
    public void createForRoles(int[] roleIds, String type, String title, String body, String link) {
        if (roleIds == null || roleIds.length == 0) return;
        StringBuilder placeholders = new StringBuilder();
        for (int i = 0; i < roleIds.length; i++) {
            if (i > 0) placeholders.append(",");
            placeholders.append("?");
        }
        String sql = "SELECT user_id FROM users WHERE role_id IN (" + placeholders + ") AND status = 1";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            for (int i = 0; i < roleIds.length; i++) {
                ps.setInt(i + 1, roleIds[i]);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    create(rs.getInt("user_id"), type, title, body, link);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
    }

    /*
     * ── Utility: gửi thông báo cho Trưởng phòng / Tổ trưởng của một phòng ban ──
     *
     * Dùng khi nhân viên thực hiện hành động cần thông báo cho quản lý trực tiếp
     * của phòng ban mình (role Factory Manager=3 hoặc Department Manager=6).
     * Nếu không tìm thấy Trưởng phòng, sẽ không gửi (không có lỗi phát sinh).
     */
    public void createForDepartmentHead(int departmentId, String type, String title, String body, String link) {
        String sql = "SELECT user_id FROM users WHERE department_id = ? AND role_id IN (3, 6) AND status = 1 " +
                     "ORDER BY user_id ASC LIMIT 1";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, departmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    create(rs.getInt("user_id"), type, title, body, link);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
    }
}
