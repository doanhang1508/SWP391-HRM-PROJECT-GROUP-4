package dao;

import java.math.BigDecimal;
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
        // Auto-migrate schema: Drop old simple table if exists and create new one
        try (Connection conn = DBContext.getConnection();
             Statement stmt = conn.createStatement()) {
            
            // Check if column hr_staff_id exists, if not drop table and recreate
            boolean recreate = false;
            try {
                stmt.executeQuery("SELECT hr_staff_id FROM payroll_claims LIMIT 1");
            } catch (SQLException e) {
                recreate = true;
            }

            if (recreate) {
                stmt.execute("DROP TABLE IF EXISTS payroll_claims;");
            }

            stmt.execute("CREATE TABLE IF NOT EXISTS payroll_claims (" +
                         "claim_id INT PRIMARY KEY AUTO_INCREMENT, " +
                         "payroll_id INT NOT NULL, " +
                         "complaint_type VARCHAR(100) NOT NULL, " +
                         "description TEXT NOT NULL, " +
                         "expected_amount DECIMAL(15,2) DEFAULT 0, " +
                         "evidence VARCHAR(255) DEFAULT NULL, " +
                         "status VARCHAR(50) DEFAULT 'Pending', " +
                         "hr_staff_id INT DEFAULT NULL, " +
                         "hr_staff_note TEXT DEFAULT NULL, " +
                         "accountant_id INT DEFAULT NULL, " +
                         "accountant_note TEXT DEFAULT NULL, " +
                         "proposed_adjustment DECIMAL(15,2) DEFAULT 0, " +
                         "hr_manager_id INT DEFAULT NULL, " +
                         "hr_manager_note TEXT DEFAULT NULL, " +
                         "director_id INT DEFAULT NULL, " +
                         "director_note TEXT DEFAULT NULL, " +
                         "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                         "FOREIGN KEY (payroll_id) REFERENCES payroll(payroll_id) ON DELETE CASCADE, " +
                         "FOREIGN KEY (hr_staff_id) REFERENCES users(user_id) ON DELETE SET NULL, " +
                         "FOREIGN KEY (accountant_id) REFERENCES users(user_id) ON DELETE SET NULL, " +
                         "FOREIGN KEY (hr_manager_id) REFERENCES users(user_id) ON DELETE SET NULL, " +
                         "FOREIGN KEY (director_id) REFERENCES users(user_id) ON DELETE SET NULL" +
                         ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public boolean insertClaim(PayrollClaim claim) {
        String sql = "INSERT INTO payroll_claims (payroll_id, complaint_type, description, expected_amount, evidence, status) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, claim.getPayrollId());
            ps.setString(2, claim.getComplaintType());
            ps.setString(3, claim.getDescription());
            ps.setBigDecimal(4, claim.getExpectedAmount() != null ? claim.getExpectedAmount() : BigDecimal.ZERO);
            ps.setString(5, claim.getEvidence());
            ps.setString(6, claim.getStatus() != null ? claim.getStatus() : "Pending");
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private PayrollClaim mapRow(ResultSet rs) throws SQLException {
        PayrollClaim pc = new PayrollClaim();
        pc.setClaimId(rs.getInt("claim_id"));
        pc.setPayrollId(rs.getInt("payroll_id"));
        pc.setComplaintType(rs.getString("complaint_type"));
        pc.setDescription(rs.getString("description"));
        pc.setExpectedAmount(rs.getBigDecimal("expected_amount"));
        pc.setEvidence(rs.getString("evidence"));
        pc.setStatus(rs.getString("status"));
        
        pc.setHrStaffId(rs.getObject("hr_staff_id") != null ? rs.getInt("hr_staff_id") : null);
        pc.setHrStaffNote(rs.getString("hr_staff_note"));
        pc.setAccountantId(rs.getObject("accountant_id") != null ? rs.getInt("accountant_id") : null);
        pc.setAccountantNote(rs.getString("accountant_note"));
        pc.setProposedAdjustment(rs.getBigDecimal("proposed_adjustment"));
        pc.setHrManagerId(rs.getObject("hr_manager_id") != null ? rs.getInt("hr_manager_id") : null);
        pc.setHrManagerNote(rs.getString("hr_manager_note"));
        pc.setDirectorId(rs.getObject("director_id") != null ? rs.getInt("director_id") : null);
        pc.setDirectorNote(rs.getString("director_note"));
        pc.setCreatedAt(rs.getTimestamp("created_at"));
        
        // Joined fields
        pc.setMonth(rs.getInt("month"));
        pc.setYear(rs.getInt("year"));
        pc.setFullName(rs.getString("full_name"));
        pc.setEmail(rs.getString("email"));
        
        // Optional processor names from left joins
        try {
            pc.setHrStaffName(rs.getString("hr_staff_name"));
            pc.setAccountantName(rs.getString("accountant_name"));
            pc.setHrManagerName(rs.getString("hr_manager_name"));
            pc.setDirectorName(rs.getString("director_name"));
        } catch (SQLException e) {
            // Ignore if columns not queried
        }
        
        return pc;
    }

    public List<PayrollClaim> getClaimsByUserId(int userId) {
        List<PayrollClaim> list = new ArrayList<>();
        String sql = "SELECT pc.*, p.month, p.year, u.full_name, u.email, " +
                     "u_staff.full_name AS hr_staff_name, " +
                     "u_acc.full_name AS accountant_name, " +
                     "u_mgr.full_name AS hr_manager_name, " +
                     "u_dir.full_name AS director_name " +
                     "FROM payroll_claims pc " +
                     "JOIN payroll p ON pc.payroll_id = p.payroll_id " +
                     "JOIN users u ON p.user_id = u.user_id " +
                     "LEFT JOIN users u_staff ON pc.hr_staff_id = u_staff.user_id " +
                     "LEFT JOIN users u_acc ON pc.accountant_id = u_acc.user_id " +
                     "LEFT JOIN users u_mgr ON pc.hr_manager_id = u_mgr.user_id " +
                     "LEFT JOIN users u_dir ON pc.director_id = u_dir.user_id " +
                     "WHERE p.user_id = ? " +
                     "ORDER BY pc.created_at DESC";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
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

    public List<PayrollClaim> getAllClaims() {
        List<PayrollClaim> list = new ArrayList<>();
        String sql = "SELECT pc.*, p.month, p.year, u.full_name, u.email, " +
                     "u_staff.full_name AS hr_staff_name, " +
                     "u_acc.full_name AS accountant_name, " +
                     "u_mgr.full_name AS hr_manager_name, " +
                     "u_dir.full_name AS director_name " +
                     "FROM payroll_claims pc " +
                     "JOIN payroll p ON pc.payroll_id = p.payroll_id " +
                     "JOIN users u ON p.user_id = u.user_id " +
                     "LEFT JOIN users u_staff ON pc.hr_staff_id = u_staff.user_id " +
                     "LEFT JOIN users u_acc ON pc.accountant_id = u_acc.user_id " +
                     "LEFT JOIN users u_mgr ON pc.hr_manager_id = u_mgr.user_id " +
                     "LEFT JOIN users u_dir ON pc.director_id = u_dir.user_id " +
                     "ORDER BY pc.created_at DESC";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public PayrollClaim getClaimById(int claimId) {
        String sql = "SELECT pc.*, p.month, p.year, u.full_name, u.email, " +
                     "u_staff.full_name AS hr_staff_name, " +
                     "u_acc.full_name AS accountant_name, " +
                     "u_mgr.full_name AS hr_manager_name, " +
                     "u_dir.full_name AS director_name " +
                     "FROM payroll_claims pc " +
                     "JOIN payroll p ON pc.payroll_id = p.payroll_id " +
                     "JOIN users u ON p.user_id = u.user_id " +
                     "LEFT JOIN users u_staff ON pc.hr_staff_id = u_staff.user_id " +
                     "LEFT JOIN users u_acc ON pc.accountant_id = u_acc.user_id " +
                     "LEFT JOIN users u_mgr ON pc.hr_manager_id = u_mgr.user_id " +
                     "LEFT JOIN users u_dir ON pc.director_id = u_dir.user_id " +
                     "WHERE pc.claim_id = ?";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, claimId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updateClaimWorkflow(PayrollClaim claim) {
        String sql = "UPDATE payroll_claims SET status = ?, " +
                     "hr_staff_id = ?, hr_staff_note = ?, " +
                     "accountant_id = ?, accountant_note = ?, " +
                     "proposed_adjustment = ?, " +
                     "hr_manager_id = ?, hr_manager_note = ?, " +
                     "director_id = ?, director_note = ? " +
                     "WHERE claim_id = ?";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, claim.getStatus());
            ps.setObject(2, claim.getHrStaffId(), java.sql.Types.INTEGER);
            ps.setString(3, claim.getHrStaffNote());
            ps.setObject(4, claim.getAccountantId(), java.sql.Types.INTEGER);
            ps.setString(5, claim.getAccountantNote());
            ps.setBigDecimal(6, claim.getProposedAdjustment() != null ? claim.getProposedAdjustment() : BigDecimal.ZERO);
            ps.setObject(7, claim.getHrManagerId(), java.sql.Types.INTEGER);
            ps.setString(8, claim.getHrManagerNote());
            ps.setObject(9, claim.getDirectorId(), java.sql.Types.INTEGER);
            ps.setString(10, claim.getDirectorNote());
            ps.setInt(11, claim.getClaimId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public BigDecimal getResolvedAdjustment(int userId, int month, int year) {
        String sql = "SELECT SUM(pc.proposed_adjustment) FROM payroll_claims pc " +
                     "JOIN payroll p ON pc.payroll_id = p.payroll_id " +
                     "WHERE p.user_id = ? AND p.month = ? AND p.year = ? AND pc.status = 'Resolved'";
        DBContext dbContext = new DBContext();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, month);
            ps.setInt(3, year);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    BigDecimal sum = rs.getBigDecimal(1);
                    if (sum != null) return sum;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return BigDecimal.ZERO;
    }
}
