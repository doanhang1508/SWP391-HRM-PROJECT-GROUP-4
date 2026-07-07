package dao;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import model.LeaveInsuranceRate;
import util.DBContext;

/**
 * DAO cho bảng leave_insurance_rates.
 * Quản lý tỷ lệ bảo hiểm xã hội (BHXH) chi trả cho từng loại nghỉ phép.
 * 
 * Bảng này tách riêng để dễ dàng cấu hình tỷ lệ BHXH cho từng loại nghỉ:
 *   - Nghỉ ốm: 75%
 *   - Nghỉ thai sản (nữ): 100%
 *   - Nghỉ thai sản (nam/paternity): 100%
 * 
 * Thay vì hardcode các giá trị trong PayrollDAO, giờ đọc từ bảng này.
 */
public class LeaveInsuranceRateDAO {

    private LeaveInsuranceRate mapRow(ResultSet rs) throws SQLException {
        LeaveInsuranceRate rate = new LeaveInsuranceRate();
        rate.setLeaveInsuranceRateId(rs.getInt("leave_insurance_rate_id"));
        rate.setLeaveTypeId(rs.getInt("leave_type_id"));
        rate.setInsuranceRatePercent(rs.getBigDecimal("insurance_rate_percent"));
        rate.setDescription(rs.getString("description"));
        rate.setEffectiveFrom(rs.getDate("effective_from"));
        rate.setEffectiveTo(rs.getDate("effective_to"));
        rate.setStatus(rs.getBoolean("status"));
        rate.setCreatedAt(rs.getTimestamp("created_at"));
        rate.setUpdatedAt(rs.getTimestamp("updated_at"));
        return rate;
    }

    /**
     * Lấy tất cả leave insurance rates (all statuses).
     */
    public List<LeaveInsuranceRate> getAll() {
        List<LeaveInsuranceRate> list = new ArrayList<>();
        String sql = "SELECT lir.*, lt.type_name FROM leave_insurance_rates lir " +
                     "JOIN leave_types lt ON lir.leave_type_id = lt.leave_type_id " +
                     "ORDER BY lir.status DESC, lir.leave_type_id";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                LeaveInsuranceRate rate = mapRow(rs);
                rate.setLeaveTypeName(rs.getString("type_name"));
                list.add(rate);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy tất cả leave insurance rates đang hoạt động (status=1).
     */
    public List<LeaveInsuranceRate> getAllActive() {
        List<LeaveInsuranceRate> list = new ArrayList<>();
        String sql = "SELECT lir.*, lt.type_name FROM leave_insurance_rates lir " +
                     "JOIN leave_types lt ON lir.leave_type_id = lt.leave_type_id " +
                     "WHERE lir.status = 1 " +
                     "ORDER BY lir.leave_type_id";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                LeaveInsuranceRate rate = mapRow(rs);
                rate.setLeaveTypeName(rs.getString("type_name"));
                list.add(rate);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy insurance rate theo leave_type_id (chỉ bản ghi active).
     * 
     * @return LeaveInsuranceRate hoặc null nếu loại nghỉ phép không có tỷ lệ BHXH
     */
    public LeaveInsuranceRate getByLeaveTypeId(int leaveTypeId) {
        String sql = "SELECT lir.*, lt.type_name FROM leave_insurance_rates lir " +
                     "JOIN leave_types lt ON lir.leave_type_id = lt.leave_type_id " +
                     "WHERE lir.leave_type_id = ? AND lir.status = 1 " +
                     "ORDER BY lir.effective_from DESC LIMIT 1";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, leaveTypeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    LeaveInsuranceRate rate = mapRow(rs);
                    rate.setLeaveTypeName(rs.getString("type_name"));
                    return rate;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Lấy Map<leaveTypeId, insuranceRatePercent> cho tất cả loại nghỉ phép có BHXH.
     * Dùng trong PayrollDAO để tính insurance benefit mà không cần hardcode.
     * 
     * @return Map từ leaveTypeId → tỷ lệ % (e.g. {2: 75.00, 3: 100.00, 4: 100.00})
     */
    public Map<Integer, BigDecimal> getActiveRateMap() {
        Map<Integer, BigDecimal> map = new HashMap<>();
        String sql = "SELECT leave_type_id, insurance_rate_percent " +
                     "FROM leave_insurance_rates WHERE status = 1";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                int leaveTypeId = rs.getInt("leave_type_id");
                BigDecimal rate = rs.getBigDecimal("insurance_rate_percent");
                map.put(leaveTypeId, rate);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return map;
    }

    public LeaveInsuranceRate getById(int id) {
        String sql = "SELECT lir.*, lt.type_name FROM leave_insurance_rates lir " +
                     "JOIN leave_types lt ON lir.leave_type_id = lt.leave_type_id " +
                     "WHERE lir.leave_insurance_rate_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    LeaveInsuranceRate rate = mapRow(rs);
                    rate.setLeaveTypeName(rs.getString("type_name"));
                    return rate;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean insert(LeaveInsuranceRate rate) {
        String sql = "INSERT INTO leave_insurance_rates " +
                     "(leave_type_id, insurance_rate_percent, description, effective_from, effective_to, status) " +
                     "VALUES (?, ?, ?, ?, ?, 1)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, rate.getLeaveTypeId());
            ps.setBigDecimal(2, rate.getInsuranceRatePercent());
            ps.setString(3, rate.getDescription());
            ps.setDate(4, rate.getEffectiveFrom());
            ps.setDate(5, rate.getEffectiveTo());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean update(LeaveInsuranceRate rate) {
        String sql = "UPDATE leave_insurance_rates SET " +
                     "leave_type_id = ?, insurance_rate_percent = ?, description = ?, " +
                     "effective_from = ?, effective_to = ? " +
                     "WHERE leave_insurance_rate_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, rate.getLeaveTypeId());
            ps.setBigDecimal(2, rate.getInsuranceRatePercent());
            ps.setString(3, rate.getDescription());
            ps.setDate(4, rate.getEffectiveFrom());
            ps.setDate(5, rate.getEffectiveTo());
            ps.setInt(6, rate.getLeaveInsuranceRateId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean changeStatus(int id, boolean active) {
        String sql = "UPDATE leave_insurance_rates SET status = ? WHERE leave_insurance_rate_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, active);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /** Soft-delete */
    public boolean delete(int id) {
        return changeStatus(id, false);
    }
}
