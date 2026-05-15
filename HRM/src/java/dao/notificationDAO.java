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
        String sql = "INSERT INTO notifications (employee_id, type, title, body, link) " +
                     "VALUES (?, ?, ?, ?, ?)";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt   (1, n.getEmployeeId());
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
    public int countUnread(int employeeId) {
        String sql = "SELECT COUNT(*) FROM notifications WHERE employee_id=? AND is_read=0";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, employeeId);
            ResultSet rs = ps.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        } catch (SQLException e) { e.printStackTrace(); return 0; }
    }
 
    /* Lấy danh sách thông báo mới nhất */
    public List<notification> findByEmployee(int employeeId, int limit) {
        String sql = "SELECT id, type, title, body, link, is_read, created_at " +
                     "FROM notifications WHERE employee_id=? " +
                     "ORDER BY created_at DESC LIMIT ?";
        List<notification> list = new ArrayList<>();
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, employeeId);
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
 
    /* Đánh dấu 1 thông báo đã đọc (chỉ của đúng employee) */
    public void markRead(int notifId, int employeeId) {
        String sql = "UPDATE notifications SET is_read=1 WHERE id=? AND employee_id=?";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, notifId);
            ps.setInt(2, employeeId);
            ps.executeUpdate();
        } catch (SQLException e) { e.printStackTrace(); }
    }
 
    /* Đánh dấu tất cả đã đọc */
    public void markAllRead(int employeeId) {
        String sql = "UPDATE notifications SET is_read=1 WHERE employee_id=? AND is_read=0";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, employeeId);
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
     *   new NotificationDAO().create(empId, "leave", "Đơn nghỉ phép được duyệt",
     *       "Đơn xin nghỉ 3 ngày của bạn đã được HR duyệt.", "/leave/detail?id=12");
     */
    public void create(int employeeId, String type, String title, String body, String link) {
        String sql = "INSERT INTO notifications (employee_id, type, title, body, link) VALUES (?,?,?,?,?)";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt   (1, employeeId);
            ps.setString(2, type);
            ps.setString(3, title);
            ps.setString(4, body);
            ps.setString(5, link);
            ps.executeUpdate();
        } catch (SQLException e) { e.printStackTrace(); }
    }
}
