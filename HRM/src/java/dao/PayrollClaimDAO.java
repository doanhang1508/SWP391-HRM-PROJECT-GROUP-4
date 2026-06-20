package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import model.PayrollClaim;
import util.DBContext;

public class PayrollClaimDAO {

    static {
        // Auto-create table if not exists
        try (Connection conn = DBContext.getConnection();
             Statement stmt = conn.createStatement()) {
            stmt.execute("CREATE TABLE IF NOT EXISTS payroll_claims (" +
                         "claim_id INT PRIMARY KEY AUTO_INCREMENT, " +
                         "payroll_id INT NOT NULL, " +
                         "reason TEXT NOT NULL, " +
                         "status VARCHAR(20) DEFAULT 'Pending', " +
                         "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                         "FOREIGN KEY (payroll_id) REFERENCES payroll(payroll_id) ON DELETE CASCADE" +
                         ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public boolean insertClaim(PayrollClaim claim) {
        String sql = "INSERT INTO payroll_claims (payroll_id, reason, status) VALUES (?, ?, ?)";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, claim.getPayrollId());
            ps.setString(2, claim.getReason());
            ps.setString(3, claim.getStatus() != null ? claim.getStatus() : "Pending");
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<PayrollClaim> getClaimsByUserId(int userId) {
        List<PayrollClaim> list = new ArrayList<>();
        String sql = "SELECT pc.*, p.month, p.year, u.full_name, u.email " +
                     "FROM payroll_claims pc " +
                     "JOIN payroll p ON pc.payroll_id = p.payroll_id " +
                     "JOIN users u ON p.user_id = u.user_id " +
                     "WHERE p.user_id = ? " +
                     "ORDER BY pc.created_at DESC";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    PayrollClaim pc = new PayrollClaim();
                    pc.setClaimId(rs.getInt("claim_id"));
                    pc.setPayrollId(rs.getInt("payroll_id"));
                    pc.setReason(rs.getString("reason"));
                    pc.setStatus(rs.getString("status"));
                    pc.setCreatedAt(rs.getTimestamp("created_at"));
                    pc.setMonth(rs.getInt("month"));
                    pc.setYear(rs.getInt("year"));
                    pc.setFullName(rs.getString("full_name"));
                    pc.setEmail(rs.getString("email"));
                    list.add(pc);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<PayrollClaim> getAllClaims() {
        List<PayrollClaim> list = new ArrayList<>();
        String sql = "SELECT pc.*, p.month, p.year, u.full_name, u.email " +
                     "FROM payroll_claims pc " +
                     "JOIN payroll p ON pc.payroll_id = p.payroll_id " +
                     "JOIN users u ON p.user_id = u.user_id " +
                     "ORDER BY pc.created_at DESC";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                PayrollClaim pc = new PayrollClaim();
                pc.setClaimId(rs.getInt("claim_id"));
                pc.setPayrollId(rs.getInt("payroll_id"));
                pc.setReason(rs.getString("reason"));
                pc.setStatus(rs.getString("status"));
                pc.setCreatedAt(rs.getTimestamp("created_at"));
                pc.setMonth(rs.getInt("month"));
                pc.setYear(rs.getInt("year"));
                pc.setFullName(rs.getString("full_name"));
                pc.setEmail(rs.getString("email"));
                list.add(pc);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean resolveClaim(int claimId) {
        String sql = "UPDATE payroll_claims SET status = 'Resolved' WHERE claim_id = ?";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, claimId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public PayrollClaim getClaimById(int claimId) {
        String sql = "SELECT pc.*, p.month, p.year, u.user_id, u.full_name, u.email " +
                     "FROM payroll_claims pc " +
                     "JOIN payroll p ON pc.payroll_id = p.payroll_id " +
                     "JOIN users u ON p.user_id = u.user_id " +
                     "WHERE pc.claim_id = ?";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, claimId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    PayrollClaim pc = new PayrollClaim();
                    pc.setClaimId(rs.getInt("claim_id"));
                    pc.setPayrollId(rs.getInt("payroll_id"));
                    pc.setReason(rs.getString("reason"));
                    pc.setStatus(rs.getString("status"));
                    pc.setCreatedAt(rs.getTimestamp("created_at"));
                    pc.setMonth(rs.getInt("month"));
                    pc.setYear(rs.getInt("year"));
                    pc.setFullName(rs.getString("full_name"));
                    pc.setEmail(rs.getString("email"));
                    return pc;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
}
