package dao;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.TaxBracket;
import util.DBContext;

/**
 * DAO cho bảng tax_brackets - Quản lý biểu thuế lũy tiến.
 * Hỗ trợ versioning theo ngày hiệu lực.
 */
public class TaxBracketDAO {

    private TaxBracket mapRow(ResultSet rs) throws SQLException {
        TaxBracket tb = new TaxBracket();
        tb.setBracketId(rs.getInt("bracket_id"));
        tb.setBracketNo(rs.getInt("bracket_no"));
        tb.setIncomeFrom(rs.getBigDecimal("income_from"));
        tb.setIncomeTo(rs.getBigDecimal("income_to"));
        tb.setRate(rs.getBigDecimal("rate"));
        tb.setEffectiveFrom(rs.getDate("effective_from"));
        tb.setEffectiveTo(rs.getDate("effective_to"));
        tb.setRoundingRule(rs.getString("rounding_rule"));
        tb.setStatus(rs.getInt("status"));
        int createdBy = rs.getInt("created_by");
        tb.setCreatedBy(rs.wasNull() ? null : createdBy);
        int updatedBy = rs.getInt("updated_by");
        tb.setUpdatedBy(rs.wasNull() ? null : updatedBy);
        tb.setCreatedAt(rs.getTimestamp("created_at"));
        tb.setUpdatedAt(rs.getTimestamp("updated_at"));
        return tb;
    }

    /**
     * Lấy biểu thuế hiện hành (effective tại ngày cho trước).
     */
    public List<TaxBracket> getEffectiveBrackets(Date effectiveDate) {
        List<TaxBracket> list = new ArrayList<>();
        String sql = "SELECT * FROM tax_brackets " +
                     "WHERE status = 1 AND effective_from <= ? " +
                     "AND (effective_to IS NULL OR effective_to >= ?) " +
                     "ORDER BY bracket_no ASC";
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

    /**
     * Lấy tất cả biểu thuế (cho admin config view).
     */
    public List<TaxBracket> getAllBrackets() {
        List<TaxBracket> list = new ArrayList<>();
        String sql = "SELECT * FROM tax_brackets ORDER BY effective_from DESC, bracket_no ASC";
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
     * Lấy biểu thuế hiện tại đang active.
     */
    public List<TaxBracket> getCurrentBrackets() {
        return getEffectiveBrackets(new Date(System.currentTimeMillis()));
    }

    /**
     * Thêm mới 1 bậc thuế.
     */
    public boolean insert(TaxBracket tb) {
        String sql = "INSERT INTO tax_brackets (bracket_no, income_from, income_to, rate, " +
                     "effective_from, effective_to, rounding_rule, status, created_by) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, tb.getBracketNo());
            ps.setBigDecimal(2, tb.getIncomeFrom());
            if (tb.getIncomeTo() != null) {
                ps.setBigDecimal(3, tb.getIncomeTo());
            } else {
                ps.setNull(3, java.sql.Types.DECIMAL);
            }
            ps.setBigDecimal(4, tb.getRate());
            ps.setDate(5, tb.getEffectiveFrom());
            if (tb.getEffectiveTo() != null) {
                ps.setDate(6, tb.getEffectiveTo());
            } else {
                ps.setNull(6, java.sql.Types.DATE);
            }
            ps.setString(7, tb.getRoundingRule() != null ? tb.getRoundingRule() : "HALF_UP");
            ps.setInt(8, tb.getStatus());
            if (tb.getCreatedBy() != null) {
                ps.setInt(9, tb.getCreatedBy());
            } else {
                ps.setNull(9, java.sql.Types.INTEGER);
            }
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Cập nhật 1 bậc thuế.
     */
    public boolean update(TaxBracket tb) {
        String sql = "UPDATE tax_brackets SET bracket_no = ?, income_from = ?, income_to = ?, " +
                     "rate = ?, effective_from = ?, effective_to = ?, rounding_rule = ?, " +
                     "status = ?, updated_by = ? WHERE bracket_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, tb.getBracketNo());
            ps.setBigDecimal(2, tb.getIncomeFrom());
            if (tb.getIncomeTo() != null) {
                ps.setBigDecimal(3, tb.getIncomeTo());
            } else {
                ps.setNull(3, java.sql.Types.DECIMAL);
            }
            ps.setBigDecimal(4, tb.getRate());
            ps.setDate(5, tb.getEffectiveFrom());
            if (tb.getEffectiveTo() != null) {
                ps.setDate(6, tb.getEffectiveTo());
            } else {
                ps.setNull(6, java.sql.Types.DATE);
            }
            ps.setString(7, tb.getRoundingRule());
            ps.setInt(8, tb.getStatus());
            if (tb.getUpdatedBy() != null) {
                ps.setInt(9, tb.getUpdatedBy());
            } else {
                ps.setNull(9, java.sql.Types.INTEGER);
            }
            ps.setInt(10, tb.getBracketId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Lấy 1 bậc thuế theo ID.
     */
    public TaxBracket getById(int bracketId) {
        String sql = "SELECT * FROM tax_brackets WHERE bracket_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bracketId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Tính PIT lũy tiến từ DB brackets.
     * @param taxableIncome Thu nhập tính thuế (sau giảm trừ)
     * @param effectiveDate Ngày hiệu lực để chọn version biểu thuế
     * @return Tổng PIT phải nộp
     */
    public BigDecimal calculateProgressivePIT(BigDecimal taxableIncome, Date effectiveDate) {
        if (taxableIncome == null || taxableIncome.compareTo(BigDecimal.ZERO) <= 0) {
            return BigDecimal.ZERO;
        }

        List<TaxBracket> brackets = getEffectiveBrackets(effectiveDate);
        if (brackets.isEmpty()) {
            // Fallback: dùng biểu thuế hiện tại
            brackets = getCurrentBrackets();
        }

        BigDecimal totalPIT = BigDecimal.ZERO;
        BigDecimal remainingIncome = taxableIncome;

        for (TaxBracket bracket : brackets) {
            if (remainingIncome.compareTo(BigDecimal.ZERO) <= 0) break;

            BigDecimal bracketSize;
            if (bracket.getIncomeTo() != null) {
                bracketSize = bracket.getIncomeTo().subtract(bracket.getIncomeFrom());
            } else {
                bracketSize = remainingIncome; // Bậc cuối: không giới hạn
            }

            BigDecimal taxableInBracket = remainingIncome.min(bracketSize);
            BigDecimal rateDecimal = bracket.getRate().divide(new BigDecimal("100"), 10, RoundingMode.HALF_UP);
            BigDecimal pitInBracket = taxableInBracket.multiply(rateDecimal);

            totalPIT = totalPIT.add(pitInBracket);
            remainingIncome = remainingIncome.subtract(taxableInBracket);
        }

        return totalPIT.setScale(0, RoundingMode.HALF_UP);
    }

    /**
     * Tính PIT breakdown chi tiết theo bậc (trả về JSON string).
     */
    public String calculatePITBreakdown(BigDecimal taxableIncome, Date effectiveDate) {
        if (taxableIncome == null || taxableIncome.compareTo(BigDecimal.ZERO) <= 0) {
            return "[]";
        }

        List<TaxBracket> brackets = getEffectiveBrackets(effectiveDate);
        if (brackets.isEmpty()) brackets = getCurrentBrackets();

        StringBuilder json = new StringBuilder("[");
        BigDecimal remainingIncome = taxableIncome;
        boolean first = true;

        for (TaxBracket bracket : brackets) {
            if (remainingIncome.compareTo(BigDecimal.ZERO) <= 0) break;

            BigDecimal bracketSize;
            if (bracket.getIncomeTo() != null) {
                bracketSize = bracket.getIncomeTo().subtract(bracket.getIncomeFrom());
            } else {
                bracketSize = remainingIncome;
            }

            BigDecimal taxableInBracket = remainingIncome.min(bracketSize);
            BigDecimal rateDecimal = bracket.getRate().divide(new BigDecimal("100"), 10, RoundingMode.HALF_UP);
            BigDecimal pitInBracket = taxableInBracket.multiply(rateDecimal).setScale(0, RoundingMode.HALF_UP);

            if (!first) json.append(",");
            json.append("{");
            json.append("\"bracket\":").append(bracket.getBracketNo()).append(",");
            json.append("\"from\":").append(bracket.getIncomeFrom().toPlainString()).append(",");
            json.append("\"to\":").append(bracket.getIncomeTo() != null ? bracket.getIncomeTo().toPlainString() : "null").append(",");
            json.append("\"rate\":").append(bracket.getRate().toPlainString()).append(",");
            json.append("\"taxableAmount\":").append(taxableInBracket.toPlainString()).append(",");
            json.append("\"pitAmount\":").append(pitInBracket.toPlainString());
            json.append("}");
            first = false;

            remainingIncome = remainingIncome.subtract(taxableInBracket);
        }
        json.append("]");
        return json.toString();
    }
}
