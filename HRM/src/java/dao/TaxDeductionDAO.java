package dao;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.TaxDeduction;
import util.DBContext;

/**
 * DAO cho bảng tax_deductions - Quản lý giảm trừ thuế.
 */
public class TaxDeductionDAO {

    private TaxDeduction mapRow(ResultSet rs) throws SQLException {
        TaxDeduction td = new TaxDeduction();
        td.setDeductionId(rs.getInt("deduction_id"));
        td.setDeductionType(rs.getString("deduction_type"));
        td.setDeductionName(rs.getString("deduction_name"));
        td.setAmount(rs.getBigDecimal("amount"));
        td.setEffectiveFrom(rs.getDate("effective_from"));
        td.setEffectiveTo(rs.getDate("effective_to"));
        td.setStatus(rs.getInt("status"));
        int createdBy = rs.getInt("created_by");
        td.setCreatedBy(rs.wasNull() ? null : createdBy);
        int updatedBy = rs.getInt("updated_by");
        td.setUpdatedBy(rs.wasNull() ? null : updatedBy);
        td.setCreatedAt(rs.getTimestamp("created_at"));
        td.setUpdatedAt(rs.getTimestamp("updated_at"));
        return td;
    }

    /**
     * Lấy giảm trừ bản thân hiện hành.
     */
    public BigDecimal getPersonalDeduction(Date effectiveDate) {
        String sql = "SELECT amount FROM tax_deductions " +
                     "WHERE deduction_type = 'PERSONAL' AND status = 1 " +
                     "AND effective_from <= ? AND (effective_to IS NULL OR effective_to >= ?) " +
                     "ORDER BY effective_from DESC LIMIT 1";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, effectiveDate);
            ps.setDate(2, effectiveDate);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getBigDecimal("amount");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return new BigDecimal("11000000"); // Fallback
    }

    /**
     * Lấy giảm trừ mỗi người phụ thuộc hiện hành.
     */
    public BigDecimal getDependentDeduction(Date effectiveDate) {
        String sql = "SELECT amount FROM tax_deductions " +
                     "WHERE deduction_type = 'DEPENDENT' AND status = 1 " +
                     "AND effective_from <= ? AND (effective_to IS NULL OR effective_to >= ?) " +
                     "ORDER BY effective_from DESC LIMIT 1";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, effectiveDate);
            ps.setDate(2, effectiveDate);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getBigDecimal("amount");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return new BigDecimal("4400000"); // Fallback
    }

    /**
     * Lấy tất cả giảm trừ (cho admin view).
     */
    public List<TaxDeduction> getAllDeductions() {
        List<TaxDeduction> list = new ArrayList<>();
        String sql = "SELECT * FROM tax_deductions ORDER BY deduction_type, effective_from DESC";
        try (Connection conn = DBContext.getConnection();
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

    /**
     * Lấy giảm trừ hiện hành (active).
     */
    public List<TaxDeduction> getEffectiveDeductions(Date effectiveDate) {
        List<TaxDeduction> list = new ArrayList<>();
        String sql = "SELECT * FROM tax_deductions " +
                     "WHERE status = 1 AND effective_from <= ? " +
                     "AND (effective_to IS NULL OR effective_to >= ?) " +
                     "ORDER BY deduction_type";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, effectiveDate);
            ps.setDate(2, effectiveDate);
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

    public boolean insert(TaxDeduction td) {
        String sql = "INSERT INTO tax_deductions (deduction_type, deduction_name, amount, " +
                     "effective_from, effective_to, status, created_by) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, td.getDeductionType());
            ps.setString(2, td.getDeductionName());
            ps.setBigDecimal(3, td.getAmount());
            ps.setDate(4, td.getEffectiveFrom());
            if (td.getEffectiveTo() != null) {
                ps.setDate(5, td.getEffectiveTo());
            } else {
                ps.setNull(5, java.sql.Types.DATE);
            }
            ps.setInt(6, td.getStatus());
            if (td.getCreatedBy() != null) {
                ps.setInt(7, td.getCreatedBy());
            } else {
                ps.setNull(7, java.sql.Types.INTEGER);
            }
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean update(TaxDeduction td) {
        String sql = "UPDATE tax_deductions SET deduction_type = ?, deduction_name = ?, amount = ?, " +
                     "effective_from = ?, effective_to = ?, status = ?, updated_by = ? WHERE deduction_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, td.getDeductionType());
            ps.setString(2, td.getDeductionName());
            ps.setBigDecimal(3, td.getAmount());
            ps.setDate(4, td.getEffectiveFrom());
            if (td.getEffectiveTo() != null) {
                ps.setDate(5, td.getEffectiveTo());
            } else {
                ps.setNull(5, java.sql.Types.DATE);
            }
            ps.setInt(6, td.getStatus());
            if (td.getUpdatedBy() != null) {
                ps.setInt(7, td.getUpdatedBy());
            } else {
                ps.setNull(7, java.sql.Types.INTEGER);
            }
            ps.setInt(8, td.getDeductionId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public TaxDeduction getById(int id) {
        String sql = "SELECT * FROM tax_deductions WHERE deduction_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
}
