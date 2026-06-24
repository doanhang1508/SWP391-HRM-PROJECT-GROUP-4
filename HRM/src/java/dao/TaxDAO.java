package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.TaxBracket;
import model.TaxDeduction;
import util.DBContext;

public class TaxDAO {

    private TaxBracket mapTaxBracket(ResultSet rs) throws Exception {
        TaxBracket b = new TaxBracket();
        b.setBracketId(rs.getInt("bracket_id"));
        b.setBracketNo(rs.getInt("bracket_no"));
        b.setIncomeFrom(rs.getBigDecimal("income_from"));
        b.setIncomeTo(rs.getBigDecimal("income_to"));
        b.setRate(rs.getBigDecimal("rate"));
        b.setEffectiveFrom(rs.getDate("effective_from"));
        b.setEffectiveTo(rs.getDate("effective_to"));
        b.setRoundingRule(rs.getString("rounding_rule"));
        b.setStatus(rs.getBoolean("status"));
        b.setCreatedBy(rs.getInt("created_by"));
        b.setUpdatedBy(rs.getInt("updated_by"));
        return b;
    }

    private TaxDeduction mapTaxDeduction(ResultSet rs) throws Exception {
        TaxDeduction d = new TaxDeduction();
        d.setDeductionId(rs.getInt("deduction_id"));
        d.setDeductionType(rs.getString("deduction_type"));
        d.setDeductionName(rs.getString("deduction_name"));
        d.setAmount(rs.getBigDecimal("amount"));
        d.setEffectiveFrom(rs.getDate("effective_from"));
        d.setEffectiveTo(rs.getDate("effective_to"));
        d.setStatus(rs.getBoolean("status"));
        d.setCreatedBy(rs.getInt("created_by"));
        d.setUpdatedBy(rs.getInt("updated_by"));
        return d;
    }

    // --- TAX BRACKETS ---

    public List<TaxBracket> getAllTaxBrackets() {
        List<TaxBracket> list = new ArrayList<>();
        String sql = "SELECT * FROM tax_brackets ORDER BY bracket_no";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapTaxBracket(rs));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public void insertTaxBracket(TaxBracket b) {
        String sql = "INSERT INTO tax_brackets (bracket_no, income_from, income_to, rate, effective_from, effective_to, rounding_rule, status, created_by) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, b.getBracketNo());
            ps.setBigDecimal(2, b.getIncomeFrom());
            ps.setBigDecimal(3, b.getIncomeTo());
            ps.setBigDecimal(4, b.getRate());
            ps.setDate(5, b.getEffectiveFrom());
            ps.setDate(6, b.getEffectiveTo());
            ps.setString(7, b.getRoundingRule() != null ? b.getRoundingRule() : "HALF_UP");
            ps.setInt(8, b.isStatus() ? 1 : 0);
            ps.setObject(9, b.getCreatedBy() > 0 ? b.getCreatedBy() : null);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void updateTaxBracket(TaxBracket b) {
        String sql = "UPDATE tax_brackets SET bracket_no=?, income_from=?, income_to=?, rate=?, effective_from=?, effective_to=?, rounding_rule=?, status=?, updated_by=? " +
                     "WHERE bracket_id=?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, b.getBracketNo());
            ps.setBigDecimal(2, b.getIncomeFrom());
            ps.setBigDecimal(3, b.getIncomeTo());
            ps.setBigDecimal(4, b.getRate());
            ps.setDate(5, b.getEffectiveFrom());
            ps.setDate(6, b.getEffectiveTo());
            ps.setString(7, b.getRoundingRule() != null ? b.getRoundingRule() : "HALF_UP");
            ps.setInt(8, b.isStatus() ? 1 : 0);
            ps.setObject(9, b.getUpdatedBy() > 0 ? b.getUpdatedBy() : null);
            ps.setInt(10, b.getBracketId());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void deleteTaxBracket(int bracketId) {
        String sql = "DELETE FROM tax_brackets WHERE bracket_id=?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bracketId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // --- TAX DEDUCTIONS ---

    public List<TaxDeduction> getAllTaxDeductions() {
        List<TaxDeduction> list = new ArrayList<>();
        String sql = "SELECT * FROM tax_deductions ORDER BY deduction_id";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapTaxDeduction(rs));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public void insertTaxDeduction(TaxDeduction d) {
        String sql = "INSERT INTO tax_deductions (deduction_type, deduction_name, amount, effective_from, effective_to, status, created_by) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, d.getDeductionType());
            ps.setString(2, d.getDeductionName());
            ps.setBigDecimal(3, d.getAmount());
            ps.setDate(4, d.getEffectiveFrom());
            ps.setDate(5, d.getEffectiveTo());
            ps.setInt(6, d.isStatus() ? 1 : 0);
            ps.setObject(7, d.getCreatedBy() > 0 ? d.getCreatedBy() : null);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void updateTaxDeduction(TaxDeduction d) {
        String sql = "UPDATE tax_deductions SET deduction_type=?, deduction_name=?, amount=?, effective_from=?, effective_to=?, status=?, updated_by=? " +
                     "WHERE deduction_id=?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, d.getDeductionType());
            ps.setString(2, d.getDeductionName());
            ps.setBigDecimal(3, d.getAmount());
            ps.setDate(4, d.getEffectiveFrom());
            ps.setDate(5, d.getEffectiveTo());
            ps.setInt(6, d.isStatus() ? 1 : 0);
            ps.setObject(7, d.getUpdatedBy() > 0 ? d.getUpdatedBy() : null);
            ps.setInt(8, d.getDeductionId());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void deleteTaxDeduction(int deductionId) {
        String sql = "DELETE FROM tax_deductions WHERE deduction_id=?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, deductionId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
