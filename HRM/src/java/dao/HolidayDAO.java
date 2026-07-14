package dao;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import model.Holiday;
import model.HolidayRule;
import util.DBContext;

public class HolidayDAO {

    private Holiday mapResultSetToHoliday(ResultSet rs) throws Exception {
        return new Holiday(
                rs.getInt("holiday_id"),
                rs.getString("holiday_name"),
                rs.getDate("holiday_date"),
                rs.getInt("holiday_year"),
                rs.getString("rule_code"),
                rs.getString("source"),
                rs.getBoolean("is_makeup_day"),
                rs.getString("calendar_type"),
                rs.getBigDecimal("ot_multiplier"),
                rs.getString("description"),
                rs.getBoolean("status"),
                rs.getTimestamp("created_at"),
                rs.getTimestamp("updated_at")
        );
    }

    public List<Holiday> getAll() {
        List<Holiday> list = new ArrayList<>();
        String sql = "SELECT * FROM holidays ORDER BY holiday_date DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToHoliday(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Holiday> getByYear(int year) {
        List<Holiday> list = new ArrayList<>();
        String sql = "SELECT * FROM holidays WHERE holiday_year = ? ORDER BY holiday_date ASC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, year);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToHoliday(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Holiday> getActiveByYear(int year) {
        List<Holiday> list = new ArrayList<>();
        String sql = "SELECT * FROM holidays WHERE status = 1 AND holiday_year = ? ORDER BY holiday_date";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, year);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToHoliday(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public Holiday getById(int id) {
        String sql = "SELECT * FROM holidays WHERE holiday_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToHoliday(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public Holiday getActiveHolidayByDate(Date date) {
        String sql = "SELECT * FROM holidays WHERE status = 1 AND holiday_date = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, date);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToHoliday(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public Map<String, BigDecimal> getMultiplierMapForMonth(int month, int year) {
        Map<String, BigDecimal> map = new HashMap<>();
        String sql = "SELECT holiday_date, ot_multiplier FROM holidays WHERE status = 1 AND MONTH(holiday_date) = ? AND YEAR(holiday_date) = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, month);
            ps.setInt(2, year);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Date date = rs.getDate("holiday_date");
                    BigDecimal multiplier = rs.getBigDecimal("ot_multiplier");
                    map.put(date.toString(), multiplier);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return map;
    }

    public boolean insert(Holiday h) {
        String sql = "INSERT INTO holidays (holiday_name, holiday_date, holiday_year, rule_code, source, is_makeup_day, calendar_type, ot_multiplier, description, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 1)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, h.getHolidayName());
            ps.setDate(2, h.getHolidayDate());
            ps.setInt(3, h.getHolidayYear());
            ps.setString(4, h.getRuleCode());
            ps.setString(5, h.getSource());
            ps.setInt(6, h.isMakeupDay() ? 1 : 0);
            ps.setString(7, h.getCalendarType());
            ps.setBigDecimal(8, h.getOtMultiplier());
            ps.setString(9, h.getDescription());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public void bulkInsert(List<Holiday> holidays) {
        if (holidays == null || holidays.isEmpty()) return;
        String sql = "INSERT INTO holidays (holiday_name, holiday_date, holiday_year, rule_code, source, is_makeup_day, calendar_type, ot_multiplier, description, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 1)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            conn.setAutoCommit(false);
            for (Holiday h : holidays) {
                ps.setString(1, h.getHolidayName());
                ps.setDate(2, h.getHolidayDate());
                ps.setInt(3, h.getHolidayYear());
                ps.setString(4, h.getRuleCode());
                ps.setString(5, h.getSource());
                ps.setInt(6, h.isMakeupDay() ? 1 : 0);
                ps.setString(7, h.getCalendarType());
                ps.setBigDecimal(8, h.getOtMultiplier());
                ps.setString(9, h.getDescription());
                ps.addBatch();
            }
            ps.executeBatch();
            conn.commit();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public boolean update(Holiday h) {
        String sql = "UPDATE holidays SET holiday_name=?, holiday_date=?, holiday_year=?, calendar_type=?, ot_multiplier=?, description=?, source=? WHERE holiday_id=?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, h.getHolidayName());
            ps.setDate(2, h.getHolidayDate());
            ps.setInt(3, h.getHolidayYear());
            ps.setString(4, h.getCalendarType());
            ps.setBigDecimal(5, h.getOtMultiplier());
            ps.setString(6, h.getDescription());
            ps.setString(7, h.getSource()); // Updating might change AUTO to MANUAL
            ps.setInt(8, h.getHolidayId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean changeStatus(int id, boolean status) {
        String sql = "UPDATE holidays SET status = ? WHERE holiday_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, status ? 1 : 0);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean delete(int id) {
        String sql = "DELETE FROM holidays WHERE holiday_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean existsAutoGeneratedForYear(int year) {
        String sql = "SELECT 1 FROM holidays WHERE holiday_year = ? AND source = 'AUTO' LIMIT 1";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, year);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Integer> getAvailableYears() {
        List<Integer> years = new ArrayList<>();
        String sql = "SELECT DISTINCT holiday_year FROM holidays ORDER BY holiday_year DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                years.add(rs.getInt("holiday_year"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return years;
    }

    public List<HolidayRule> getAllActiveRules() {
        List<HolidayRule> rules = new ArrayList<>();
        String sql = "SELECT * FROM holiday_rules WHERE active = 1";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                rules.add(new HolidayRule(
                        rs.getString("rule_code"),
                        rs.getString("rule_name"),
                        rs.getString("calendar_type"),
                        rs.getInt("ref_month"),
                        rs.getInt("ref_day"),
                        rs.getInt("day_offset"),
                        rs.getBigDecimal("ot_multiplier"),
                        rs.getBoolean("active")
                ));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return rules;
    }
}
