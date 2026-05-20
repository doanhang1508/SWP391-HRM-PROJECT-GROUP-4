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
}
