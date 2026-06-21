package dao;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import model.PayrollConfig;
import util.DBContext;

public class PayrollConfigDAO {

    public PayrollConfigDAO() {
        createTableIfNotExists();
    }

    private void createTableIfNotExists() {
        String sql = "CREATE TABLE IF NOT EXISTS payroll_configs (" +
                     "id INT AUTO_INCREMENT PRIMARY KEY, " +
                     "config_key VARCHAR(100) UNIQUE NOT NULL, " +
                     "config_value DECIMAL(18,4) NOT NULL, " +
                     "description VARCHAR(255))";
        String insertSql = "INSERT IGNORE INTO payroll_configs (config_key, config_value, description) VALUES " +
                           "('STANDARD_WORK_DAYS', 22, 'Số ngày làm việc chuẩn trong tháng'), " +
                           "('PERSONAL_DEDUCTION', 11000000, 'Giảm trừ gia cảnh bản thân'), " +
                           "('DEPENDENT_DEDUCTION', 4400000, 'Giảm trừ người phụ thuộc'), " +
                           "('OT_MULTIPLIER_WEEKDAY', 1.5, 'Hệ số làm thêm ngày thường'), " +
                           "('OT_MULTIPLIER_WEEKEND', 2.0, 'Hệ số làm thêm cuối tuần'), " +
                           "('REGIONAL_BASE_SALARY', 4680000, 'Lương tối thiểu vùng')";
        try (Connection conn = DBContext.getConnection();
             Statement stmt = conn.createStatement()) {
            stmt.execute(sql);
            stmt.execute(insertSql);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public List<PayrollConfig> getAllConfigs() {
        List<PayrollConfig> list = new ArrayList<>();
        String sql = "SELECT * FROM payroll_configs ORDER BY id ASC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                PayrollConfig c = new PayrollConfig();
                c.setId(rs.getInt("id"));
                c.setConfigKey(rs.getString("config_key"));
                c.setConfigValue(rs.getBigDecimal("config_value"));
                c.setDescription(rs.getString("description"));
                list.add(c);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean updateConfig(int id, BigDecimal value) {
        String sql = "UPDATE payroll_configs SET config_value = ? WHERE id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBigDecimal(1, value);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public BigDecimal getConfigValue(String key, BigDecimal defaultValue) {
        String sql = "SELECT config_value FROM payroll_configs WHERE config_key = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, key);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getBigDecimal("config_value");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return defaultValue;
    }
}
