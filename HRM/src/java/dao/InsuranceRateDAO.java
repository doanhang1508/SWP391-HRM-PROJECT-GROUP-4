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

    public List<InsuranceRate> getAll() {
        List<InsuranceRate> list = new ArrayList<>();
        String sql = "SELECT * FROM insurance_rates WHERE status = 1 ORDER BY insurance_rate_id";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new InsuranceRate(
                    rs.getInt("insurance_rate_id"),
                    rs.getString("insurance_name"),
                    rs.getBigDecimal("company_rate"),
                    rs.getBigDecimal("employee_rate"),
                    rs.getString("description"),
                    rs.getBoolean("status")
                ));
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
                if (rs.next()) {
                    return new InsuranceRate(
                        rs.getInt("insurance_rate_id"),
                        rs.getString("insurance_name"),
                        rs.getBigDecimal("company_rate"),
                        rs.getBigDecimal("employee_rate"),
                        rs.getString("description"),
                        rs.getBoolean("status")
                    );
                }
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

    public void insert(InsuranceRate ir) {
        String sql = "INSERT INTO insurance_rates (insurance_name, company_rate, employee_rate, description, status) VALUES (?, ?, ?, ?, 1)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, ir.getInsuranceName());
            ps.setBigDecimal(2, ir.getCompanyRate());
            ps.setBigDecimal(3, ir.getEmployeeRate());
            ps.setString(4, ir.getDescription());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void update(InsuranceRate ir) {
        String sql = "UPDATE insurance_rates SET insurance_name=?, company_rate=?, employee_rate=?, description=? WHERE insurance_rate_id=?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, ir.getInsuranceName());
            ps.setBigDecimal(2, ir.getCompanyRate());
            ps.setBigDecimal(3, ir.getEmployeeRate());
            ps.setString(4, ir.getDescription());
            ps.setInt(5, ir.getInsuranceRateId());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void delete(int id) {
        String sql = "UPDATE insurance_rates SET status = 0 WHERE insurance_rate_id=?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
