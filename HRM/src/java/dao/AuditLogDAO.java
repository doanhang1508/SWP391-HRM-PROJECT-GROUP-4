package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.AuditLog;
import util.DBContext;

/**
 * DAO cho bảng audit_logs - Nhật ký thay đổi.
 */
public class AuditLogDAO {

    public boolean insert(AuditLog log) {
        String sql = "INSERT INTO audit_logs (entity_type, entity_id, action, old_value, " +
                     "new_value, changed_by, ip_address, description) VALUES (?,?,?,?,?,?,?,?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, log.getEntityType());
            ps.setInt(2, log.getEntityId());
            ps.setString(3, log.getAction());
            ps.setString(4, log.getOldValue());
            ps.setString(5, log.getNewValue());
            ps.setInt(6, log.getChangedBy());
            ps.setString(7, log.getIpAddress());
            ps.setString(8, log.getDescription());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    /**
     * Log nhanh 1 hành động.
     */
    public void log(String entityType, int entityId, String action, int changedBy,
                    String description, String ipAddress) {
        AuditLog al = new AuditLog();
        al.setEntityType(entityType);
        al.setEntityId(entityId);
        al.setAction(action);
        al.setChangedBy(changedBy);
        al.setDescription(description);
        al.setIpAddress(ipAddress);
        insert(al);
    }

    /**
     * Log với old/new values.
     */
    public void logWithValues(String entityType, int entityId, String action, int changedBy,
                              String oldVal, String newVal, String description, String ipAddress) {
        AuditLog al = new AuditLog();
        al.setEntityType(entityType);
        al.setEntityId(entityId);
        al.setAction(action);
        al.setChangedBy(changedBy);
        al.setOldValue(oldVal);
        al.setNewValue(newVal);
        al.setDescription(description);
        al.setIpAddress(ipAddress);
        insert(al);
    }

    /**
     * Lấy lịch sử thay đổi theo entity.
     */
    public List<AuditLog> getByEntity(String entityType, int entityId) {
        List<AuditLog> list = new ArrayList<>();
        String sql = "SELECT al.*, u.full_name as changed_by_name FROM audit_logs al " +
                     "LEFT JOIN users u ON al.changed_by = u.user_id " +
                     "WHERE al.entity_type = ? AND al.entity_id = ? ORDER BY al.changed_at DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, entityType);
            ps.setInt(2, entityId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    /**
     * Lấy logs gần nhất (cho audit dashboard).
     */
    public List<AuditLog> getRecentLogs(int limit) {
        List<AuditLog> list = new ArrayList<>();
        String sql = "SELECT al.*, u.full_name as changed_by_name FROM audit_logs al " +
                     "LEFT JOIN users u ON al.changed_by = u.user_id " +
                     "ORDER BY al.changed_at DESC LIMIT ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) { list.add(mapRow(rs)); }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    /**
     * Lấy logs theo loại entity.
     */
    public List<AuditLog> getByEntityType(String entityType, int limit) {
        List<AuditLog> list = new ArrayList<>();
        String sql = "SELECT al.*, u.full_name as changed_by_name FROM audit_logs al " +
                     "LEFT JOIN users u ON al.changed_by = u.user_id " +
                     "WHERE al.entity_type = ? ORDER BY al.changed_at DESC LIMIT ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, entityType);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) { list.add(mapRow(rs)); }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    /**
     * Lấy tất cả logs, có thể lọc theo entityType.
     */
    public List<AuditLog> getAllLogs(String entityType) {
        List<AuditLog> list = new ArrayList<>();
        String sql = "SELECT al.*, u.full_name as changed_by_name FROM audit_logs al " +
                     "LEFT JOIN users u ON al.changed_by = u.user_id ";
        if (entityType != null && !entityType.trim().isEmpty()) {
            sql += "WHERE al.entity_type = ? ";
        }
        sql += "ORDER BY al.changed_at DESC LIMIT 500"; // Limit for safety
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (entityType != null && !entityType.trim().isEmpty()) {
                ps.setString(1, entityType);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) { list.add(mapRow(rs)); }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    private AuditLog mapRow(ResultSet rs) throws SQLException {
        AuditLog al = new AuditLog();
        al.setLogId(rs.getInt("log_id"));
        al.setEntityType(rs.getString("entity_type"));
        al.setEntityId(rs.getInt("entity_id"));
        al.setAction(rs.getString("action"));
        al.setOldValue(rs.getString("old_value"));
        al.setNewValue(rs.getString("new_value"));
        al.setChangedBy(rs.getInt("changed_by"));
        al.setChangedAt(rs.getTimestamp("changed_at"));
        al.setIpAddress(rs.getString("ip_address"));
        al.setDescription(rs.getString("description"));
        try { al.setChangedByName(rs.getString("changed_by_name")); } catch (SQLException ignored) {}
        return al;
    }
}
