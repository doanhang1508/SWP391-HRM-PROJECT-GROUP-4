package dao;

import model.LeaveRequest;
import model.LeaveType;
import util.DBContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class LeaveRequestDAOImpl implements LeaveRequestDAO {

    @Override
    public List<LeaveType> getAllLeaveTypes() {
    List<LeaveType> list = new ArrayList<>();
    String sql = "SELECT * FROM leave_types WHERE status = 1";
    try (Connection c = DBContext.getConnection();
         PreparedStatement ps = c.prepareStatement(sql);
         ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
            LeaveType type = new LeaveType();
            type.setLeaveTypeId(rs.getInt("leave_type_id"));
            type.setTypeName(rs.getString("type_name"));
            type.setDescription(rs.getString("description"));
            type.setPaidLeave(rs.getInt("paid_leave"));
            type.setMaxDaysPerYear((Integer) rs.getObject("max_days_per_year"));
            type.setStatus(rs.getInt("status"));
            list.add(type);
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return list;
}

    @Override
    public List<LeaveRequest> getRequestsByUserId(int userId) {
        List<LeaveRequest> list = new ArrayList<>();
        String sql = "SELECT lr.*, lt.type_name, u.full_name FROM leave_requests lr " +
                     "JOIN leave_types lt ON lr.leave_type_id = lt.leave_type_id " +
                     "JOIN users u ON lr.user_id = u.user_id " +
                     "WHERE lr.user_id = ? ORDER BY lr.created_at DESC";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public List<LeaveRequest> getPendingRequestsByDepartment(int departmentId) {
        List<LeaveRequest> list = new ArrayList<>();
        String sql = "SELECT lr.*, lt.type_name, u.full_name FROM leave_requests lr " +
                     "JOIN leave_types lt ON lr.leave_type_id = lt.leave_type_id " +
                     "JOIN users u ON lr.user_id = u.user_id " +
                     "WHERE lr.status = 'Pending' ";
        if (departmentId > 0) {
            sql += "AND u.department_id = ? ";
        }
        sql += "ORDER BY lr.created_at DESC";
        
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            if (departmentId > 0) {
                ps.setInt(1, departmentId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public boolean submitRequest(LeaveRequest request) {
        String sql = "INSERT INTO leave_requests (user_id, leave_type_id, start_date, end_date, total_days, reason, status) " +
                     "VALUES (?, ?, ?, ?, ?, ?, 'Pending')";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, request.getUserId());
            ps.setInt(2, request.getLeaveTypeId());
            ps.setDate(3, request.getStartDate());
            ps.setDate(4, request.getEndDate());
            ps.setDouble(5, request.getTotalDays());
            ps.setString(6, request.getReason());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean updateRequestStatus(int requestId, String status, int approvedBy) {
        String sql = "UPDATE leave_requests SET status = ?, approved_by = ? WHERE request_id = ?";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, approvedBy);
            ps.setInt(3, requestId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public double getUsedAnnualLeaveDays(int userId, int year) {
        // 1 is 'Nghỉ phép năm' (Annual Leave)
        String sql = "SELECT SUM(total_days) as used_days FROM leave_requests " +
                     "WHERE user_id = ? AND leave_type_id = 1 AND status = 'Approved' " +
                     "AND YEAR(start_date) = ?";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, year);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble("used_days");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    private LeaveRequest mapRow(ResultSet rs) throws SQLException {
        LeaveRequest lr = new LeaveRequest();
        lr.setRequestId(rs.getInt("request_id"));
        lr.setUserId(rs.getInt("user_id"));
        lr.setLeaveTypeId(rs.getInt("leave_type_id"));
        lr.setStartDate(rs.getDate("start_date"));
        lr.setEndDate(rs.getDate("end_date"));
        lr.setTotalDays(rs.getDouble("total_days"));
        lr.setReason(rs.getString("reason"));
        lr.setStatus(rs.getString("status"));
        
        int approvedBy = rs.getInt("approved_by");
        if (!rs.wasNull()) {
            lr.setApprovedBy(approvedBy);
        }
        lr.setCreatedAt(rs.getTimestamp("created_at"));
        
        // Joined columns
        lr.setLeaveTypeName(rs.getString("type_name"));
        lr.setUserName(rs.getString("full_name"));
        return lr;
    }
}
