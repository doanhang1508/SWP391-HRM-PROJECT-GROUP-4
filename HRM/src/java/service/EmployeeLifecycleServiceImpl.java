package service;

import dao.RewardDisciplineDAO;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.time.LocalDate;
import model.EmployeeRewardDiscipline;
import model.RewardDiscipline;
import util.DBContext;

public class EmployeeLifecycleServiceImpl implements EmployeeLifecycleService {

    private RewardDisciplineDAO rewardDisciplineDAO = new RewardDisciplineDAO();

    @Override
    public boolean terminateEmployee(int userId, String reason, LocalDate terminationDate) {
        DBContext dbContext = new DBContext();
        Connection conn = null;
        try {
            conn = dbContext.getConnection();
            conn.setAutoCommit(false); // Start Transaction

            // 1. Insert a major discipline record (Dismissal)
            RewardDiscipline rdDismissal = rewardDisciplineDAO.getRewardDisciplineByName("Dismissal");
            int dismissalTypeId = (rdDismissal != null) ? rdDismissal.getId() : 8;

            String insertDisciplineSql = "INSERT INTO employee_rewards_disciplines (user_id, reward_discipline_id, amount, note, applied_date) VALUES (?, ?, ?, ?, ?)";
            try (PreparedStatement ps1 = conn.prepareStatement(insertDisciplineSql)) {
                ps1.setInt(1, userId);
                ps1.setInt(2, dismissalTypeId);
                ps1.setBigDecimal(3, BigDecimal.ZERO);
                ps1.setString(4, "Dismissal: " + reason);
                ps1.setDate(5, Date.valueOf(terminationDate));
                if (ps1.executeUpdate() == 0) throw new SQLException("Failed to insert discipline record");
            }

            // 2. Update users table: Set status = 0
            String updateUserSql = "UPDATE users SET status = 0 WHERE user_id = ?";
            try (PreparedStatement ps2 = conn.prepareStatement(updateUserSql)) {
                ps2.setInt(1, userId);
                if (ps2.executeUpdate() == 0) throw new SQLException("Failed to update user status");
            }

            // 3. Update employee_profiles: Change employment_status_id (assuming ID 3 represents Terminated)
            String updateProfileSql = "UPDATE employee_profiles SET employment_status_id = 3 WHERE user_id = ?";
            try (PreparedStatement ps3 = conn.prepareStatement(updateProfileSql)) {
                ps3.setInt(1, userId);
                // Profile might not exist for some admins, so we don't rigidly throw if 0 rows updated, or maybe we do depending on business rules.
                // Assuming it must exist for a terminating employee.
                if (ps3.executeUpdate() == 0) throw new SQLException("Failed to update employee profile status");
            }

            // 4. Update work_history: set end_date
            String updateWorkHistorySql = "UPDATE work_history SET end_date = ? WHERE user_id = ? AND end_date IS NULL";
            try (PreparedStatement ps4 = conn.prepareStatement(updateWorkHistorySql)) {
                ps4.setDate(1, Date.valueOf(terminationDate));
                ps4.setInt(2, userId);
                ps4.executeUpdate(); // Might update 0 rows if no active work history, which is acceptable
            }

            conn.commit(); // Commit Transaction
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback(); // Rollback on failure
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
        }
    }
}
