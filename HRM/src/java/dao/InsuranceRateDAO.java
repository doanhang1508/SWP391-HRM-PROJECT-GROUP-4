package dao;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.InsuranceRate;
import util.DBContext;

public class InsuranceRateDAO {

    private InsuranceRate mapRow(ResultSet rs) throws Exception {
        return new InsuranceRate(
            rs.getInt("insurance_rate_id"),
            rs.getString("insurance_code"),
            rs.getString("insurance_name"),
            rs.getBigDecimal("company_rate"),
            rs.getBigDecimal("employee_rate"),
            rs.getString("description"),
            rs.getDate("effective_from"),
            rs.getDate("effective_to"),
            rs.getTimestamp("created_at"),
            rs.getTimestamp("updated_at"),
            rs.getBoolean("status")
        );
    }

    /** Load all records (all statuses), no filter — for JSP client-side filtering */
    public List<InsuranceRate> getAll() {
        List<InsuranceRate> list = new ArrayList<>();
        String sql = "SELECT * FROM insurance_rates ORDER BY status DESC, insurance_rate_id";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Search by keyword and/or status — kept for backward compatibility.
     * @param keyword      từ khóa (null/blank = tất cả)
     * @param statusFilter "active" | "inactive" | "all" (null treated as "all")
     */
    public List<InsuranceRate> search(String keyword, String statusFilter) {
        List<InsuranceRate> list = new ArrayList<>();
        boolean hasKeyword   = keyword != null && !keyword.isBlank();
        boolean activeOnly   = "active".equalsIgnoreCase(statusFilter);
        boolean inactiveOnly = "inactive".equalsIgnoreCase(statusFilter);

        StringBuilder sql = new StringBuilder("SELECT * FROM insurance_rates WHERE 1=1");
        if (hasKeyword)    sql.append(" AND (insurance_name LIKE ? OR insurance_code LIKE ?)");
        if (activeOnly)    sql.append(" AND status = 1");
        if (inactiveOnly)  sql.append(" AND status = 0");
        sql.append(" ORDER BY status DESC, insurance_rate_id");

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            if (hasKeyword) {
                String like = "%" + keyword.trim() + "%";
                ps.setString(1, like);
                ps.setString(2, like);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public InsuranceRate getById(int id) {
        String sql = "SELECT * FROM insurance_rates WHERE insurance_rate_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean isDuplicate(String insuranceName, int excludeId) {
        String sql = "SELECT COUNT(*) FROM insurance_rates WHERE insurance_name = ? AND insurance_rate_id != ? AND status = 1";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, insuranceName);
            ps.setInt(2, excludeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean isCodeDuplicate(String code, int excludeId) {
        String sql = "SELECT COUNT(*) FROM insurance_rates WHERE insurance_code = ? AND insurance_rate_id != ? AND status = 1";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code);
            ps.setInt(2, excludeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public void insert(InsuranceRate ir) {
        String sql = "INSERT INTO insurance_rates " +
                     "(insurance_code, insurance_name, company_rate, employee_rate, description, effective_from, effective_to, status) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, 1)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, ir.getInsuranceCode());
            ps.setString(2, ir.getInsuranceName());
            ps.setBigDecimal(3, ir.getCompanyRate());
            ps.setBigDecimal(4, ir.getEmployeeRate());
            ps.setString(5, ir.getDescription());
            ps.setDate(6, ir.getEffectiveFrom());
            ps.setDate(7, ir.getEffectiveTo());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void updateWithHistory(InsuranceRate ir, int oldId) {
        String sqlClose = "UPDATE insurance_rates SET status = 0, effective_to = CURRENT_DATE WHERE insurance_rate_id = ?";
        String sqlInsert = "INSERT INTO insurance_rates " +
                           "(insurance_code, insurance_name, company_rate, employee_rate, description, effective_from, effective_to, status) " +
                           "VALUES (?, ?, ?, ?, ?, ?, ?, 1)";
        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement psClose = conn.prepareStatement(sqlClose);
                 PreparedStatement psInsert = conn.prepareStatement(sqlInsert)) {
                 
                psClose.setInt(1, oldId);
                psClose.executeUpdate();
                
                psInsert.setString(1, ir.getInsuranceCode());
                psInsert.setString(2, ir.getInsuranceName());
                psInsert.setBigDecimal(3, ir.getCompanyRate());
                psInsert.setBigDecimal(4, ir.getEmployeeRate());
                psInsert.setString(5, ir.getDescription());
                psInsert.setDate(6, ir.getEffectiveFrom());
                psInsert.setDate(7, ir.getEffectiveTo());
                psInsert.executeUpdate();
                
                conn.commit();
            } catch (Exception e) {
                conn.rollback();
                e.printStackTrace();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void update(InsuranceRate ir) {
        String sql = "UPDATE insurance_rates SET insurance_code=?, insurance_name=?, company_rate=?, " +
                     "employee_rate=?, description=?, effective_from=?, effective_to=? " +
                     "WHERE insurance_rate_id=?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, ir.getInsuranceCode());
            ps.setString(2, ir.getInsuranceName());
            ps.setBigDecimal(3, ir.getCompanyRate());
            ps.setBigDecimal(4, ir.getEmployeeRate());
            ps.setString(5, ir.getDescription());
            ps.setDate(6, ir.getEffectiveFrom());
            ps.setDate(7, ir.getEffectiveTo());
            ps.setInt(8, ir.getInsuranceRateId());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void changeStatus(int id, boolean active) {
        String sql = "UPDATE insurance_rates SET status = ? WHERE insurance_rate_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, active);
            ps.setInt(2, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /** Soft-delete kept for backward compat */
    public void delete(int id) {
        changeStatus(id, false);
    }
}
