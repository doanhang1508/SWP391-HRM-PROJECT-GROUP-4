package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.EmployeeTaxProfile;
import util.DBContext;

public class EmployeeTaxProfileDAO {

    private EmployeeTaxProfile mapRow(ResultSet rs) throws SQLException {
        EmployeeTaxProfile etp = new EmployeeTaxProfile();
        etp.setTaxProfileId(rs.getInt("tax_profile_id"));
        etp.setUserId(rs.getInt("user_id"));
        etp.setTaxCode(rs.getString("tax_code"));
        etp.setTaxRegistration(rs.getBoolean("tax_registration"));
        etp.setDependentCount(rs.getInt("dependent_count"));
        etp.setPersonalDeduction(rs.getBigDecimal("personal_deduction"));
        etp.setDependentDeduction(rs.getBigDecimal("dependent_deduction"));
        etp.setStatus(rs.getInt("status"));
        etp.setNotes(rs.getString("notes"));
        etp.setCreatedAt(rs.getTimestamp("created_at"));
        etp.setUpdatedAt(rs.getTimestamp("updated_at"));
        return etp;
    }

    public EmployeeTaxProfile getByUserId(int userId) {
        String sql = "SELECT * FROM employee_tax_profiles WHERE user_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public EmployeeTaxProfile getOrCreate(int userId) {
        EmployeeTaxProfile profile = getByUserId(userId);
        if (profile != null) return profile;
        int depCount = countDeps(userId);
        String taxCode = getTaxCode(userId);
        String sql = "INSERT INTO employee_tax_profiles (user_id, tax_code, tax_registration, " +
                     "dependent_count, personal_deduction, dependent_deduction) " +
                     "VALUES (?, ?, 1, ?, 11000000, 4400000) ON DUPLICATE KEY UPDATE dependent_count = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId); ps.setString(2, taxCode);
            ps.setInt(3, depCount); ps.setInt(4, depCount);
            ps.executeUpdate();
        } catch (SQLException e) { e.printStackTrace(); }
        return getByUserId(userId);
    }

    private int countDeps(int userId) {
        String sql = "SELECT COUNT(*) FROM dependents WHERE user_id = ? AND status = 1";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) { if (rs.next()) return rs.getInt(1); }
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    private String getTaxCode(int userId) {
        String sql = "SELECT tax_code FROM employee_profiles WHERE user_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) { if (rs.next()) return rs.getString("tax_code"); }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public List<EmployeeTaxProfile> getAllWithNames() {
        List<EmployeeTaxProfile> list = new ArrayList<>();
        String sql = "SELECT etp.*, u.full_name, d.department_name FROM employee_tax_profiles etp " +
                     "LEFT JOIN users u ON etp.user_id = u.user_id " +
                     "LEFT JOIN departments d ON u.department_id = d.department_id ORDER BY u.full_name";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                EmployeeTaxProfile etp = mapRow(rs);
                etp.setFullName(rs.getString("full_name"));
                etp.setDepartmentName(rs.getString("department_name"));
                list.add(etp);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public boolean update(EmployeeTaxProfile etp) {
        String sql = "UPDATE employee_tax_profiles SET tax_code=?, tax_registration=?, dependent_count=?, " +
                     "personal_deduction=?, dependent_deduction=?, status=?, notes=? WHERE tax_profile_id=?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, etp.getTaxCode()); ps.setBoolean(2, etp.isTaxRegistration());
            ps.setInt(3, etp.getDependentCount()); ps.setBigDecimal(4, etp.getPersonalDeduction());
            ps.setBigDecimal(5, etp.getDependentDeduction()); ps.setInt(6, etp.getStatus());
            ps.setString(7, etp.getNotes()); ps.setInt(8, etp.getTaxProfileId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    public boolean syncDependentCount(int userId) {
        int count = countDeps(userId);
        String sql = "UPDATE employee_tax_profiles SET dependent_count = ? WHERE user_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, count); ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }
}
