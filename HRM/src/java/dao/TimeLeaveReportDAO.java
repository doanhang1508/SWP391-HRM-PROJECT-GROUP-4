package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.TimeLeaveReport;
import util.DBContext;

public class TimeLeaveReportDAO {

    public int countReport(int month, int year, Integer departmentId) {
        String sql = "SELECT COUNT(DISTINCT u.user_id) " +
                     "FROM users u " +
                     "LEFT JOIN employee_profiles ep ON u.user_id = ep.user_id " +
                     "WHERE u.role_id NOT IN (1, 4) ";
        if (departmentId != null && departmentId > 0) {
            sql += " AND ep.department_id = ? ";
        }
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            if (departmentId != null && departmentId > 0) {
                ps.setInt(1, departmentId);
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public List<TimeLeaveReport> getReport(int month, int year, Integer departmentId, int offset, int limit) {
        List<TimeLeaveReport> list = new ArrayList<>();
        String sql = "SELECT u.user_id, u.full_name, d.department_name, " +
                     "SUM(CASE WHEN UPPER(a.status) IN ('PRESENT', 'P', 'LEAVE', 'LATE', 'T') THEN 1 ELSE 0 END) AS total_work_days, " +
                     "SUM(CASE WHEN UPPER(a.status) IN ('LATE', 'T') THEN 1 ELSE 0 END) AS late_cnt, " +
                     "SUM(IFNULL(a.overtime_hrs, 0)) AS total_ot_hrs, " +
                     "(SELECT COALESCE(SUM(lr.total_days), 0) FROM leave_requests lr " +
                     " WHERE lr.user_id = u.user_id AND lr.leave_type_id = 1 " +
                     " AND lr.status = 'Approved' AND YEAR(lr.start_date) = ?) AS annual_leave_used, " +
                     "(SELECT COALESCE(max_days_per_year, 12) FROM leave_types WHERE leave_type_id = 1) AS max_annual_leave " +
                     "FROM users u " +
                     "LEFT JOIN employee_profiles ep ON u.user_id = ep.user_id " +
                     "LEFT JOIN departments d ON ep.department_id = d.department_id " +
                     "LEFT JOIN attendance a ON u.user_id = a.user_id AND MONTH(a.work_date) = ? AND YEAR(a.work_date) = ? " +
                     "WHERE u.role_id NOT IN (1, 4) ";
                     
        if (departmentId != null && departmentId > 0) {
            sql += " AND ep.department_id = ? ";
        }
        
        sql += "GROUP BY u.user_id, u.full_name, d.department_name " +
               "ORDER BY u.full_name ";
               
        if (limit > 0) {
            sql += " LIMIT ? OFFSET ?";
        }

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
             
            int paramIndex = 1;
            ps.setInt(paramIndex++, year);
            ps.setInt(paramIndex++, month);
            ps.setInt(paramIndex++, year);
            
            if (departmentId != null && departmentId > 0) {
                ps.setInt(paramIndex++, departmentId);
            }
            if (limit > 0) {
                ps.setInt(paramIndex++, limit);
                ps.setInt(paramIndex++, offset);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    TimeLeaveReport r = new TimeLeaveReport();
                    r.setUserId(rs.getInt("user_id"));
                    r.setFullName(rs.getString("full_name"));
                    r.setDepartmentName(rs.getString("department_name"));
                    r.setTotalWorkDays(rs.getInt("total_work_days"));
                    r.setLateCount(rs.getInt("late_cnt"));
                    r.setOtHours(rs.getDouble("total_ot_hrs"));
                    
                    double usedLeave = rs.getDouble("annual_leave_used");
                    double maxLeave = rs.getDouble("max_annual_leave");
                    
                    r.setAnnualLeaveUsed(usedLeave);
                    r.setAnnualLeaveRemaining(Math.max(0, maxLeave - usedLeave));
                    
                    list.add(r);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}
