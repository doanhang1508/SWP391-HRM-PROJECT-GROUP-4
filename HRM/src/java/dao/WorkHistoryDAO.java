package dao;

import model.WorkHistory;
import util.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class WorkHistoryDAO {

    public List<WorkHistory> getByUserId(int userId) {
        List<WorkHistory> list = new ArrayList<>();
        String sql = "SELECT * FROM work_history WHERE user_id = ? ORDER BY start_date DESC";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    WorkHistory wh = new WorkHistory();
                    wh.setHistoryId(rs.getInt("history_id"));
                    wh.setUserId(rs.getInt("user_id"));
                    wh.setPositionTitle(rs.getString("position_title"));
                    wh.setCompanyName(rs.getString("company_name"));
                    wh.setLocation(rs.getString("location"));
                    wh.setStartDate(rs.getDate("start_date"));
                    wh.setEndDate(rs.getDate("end_date"));
                    wh.setDescription(rs.getString("description"));
                    wh.setCurrent(rs.getInt("is_current") == 1);
                    list.add(wh);
                }
            }
        } catch (SQLException e) {
            System.err.println("Lỗi WorkHistoryDAO.getByUserId: " + e.getMessage());
        }
        return list;
    }

    public void closeCurrentHistory(Connection conn, int userId, java.sql.Date effectiveDate) throws SQLException {
        String sql = "UPDATE work_history SET end_date = DATE_SUB(?, INTERVAL 1 DAY), is_current = 0 " +
                     "WHERE user_id = ? AND (is_current = 1 OR end_date IS NULL)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, effectiveDate);
            ps.setInt(2, userId);
            ps.executeUpdate();
        }
    }

    public void insertTransferHistory(Connection conn, int userId, String positionTitle, String departmentName, java.sql.Date startDate, String description) throws SQLException {
        String sql = "INSERT INTO work_history (user_id, position_title, company_name, location, start_date, end_date, description, is_current) " +
                     "VALUES (?, ?, ?, 'Nội bộ', ?, NULL, ?, 1)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, positionTitle);
            ps.setString(3, departmentName);
            ps.setDate(4, startDate);
            ps.setString(5, description);
            ps.executeUpdate();
        }
    }
}
