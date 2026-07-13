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
import util.DBContext;

public class HolidayDAO {

    public List<Holiday> getAll() {
        List<Holiday> list = new ArrayList<>();
        String sql = "SELECT * FROM holidays ORDER BY holiday_date";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new Holiday(
                    rs.getInt("holiday_id"),
                    rs.getString("holiday_name"),
                    rs.getDate("holiday_date"),
                    rs.getString("calendar_type"),
                    rs.getBigDecimal("ot_multiplier"),
                    rs.getString("description"),
                    rs.getBoolean("status"),
                    rs.getTimestamp("created_at"),
                    rs.getTimestamp("updated_at")
                ));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Holiday> getActiveByYear(int year) {
        List<Holiday> list = new ArrayList<>();
        String sql = "SELECT * FROM holidays WHERE status = 1 AND YEAR(holiday_date) = ? ORDER BY holiday_date";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, year);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new Holiday(
                        rs.getInt("holiday_id"),
                        rs.getString("holiday_name"),
                        rs.getDate("holiday_date"),
                        rs.getString("calendar_type"),
                        rs.getBigDecimal("ot_multiplier"),
                        rs.getString("description"),
                        rs.getBoolean("status"),
                        rs.getTimestamp("created_at"),
                        rs.getTimestamp("updated_at")
                    ));
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
                    return new Holiday(
                        rs.getInt("holiday_id"),
                        rs.getString("holiday_name"),
                        rs.getDate("holiday_date"),
                        rs.getString("calendar_type"),
                        rs.getBigDecimal("ot_multiplier"),
                        rs.getString("description"),
                        rs.getBoolean("status"),
                        rs.getTimestamp("created_at"),
                        rs.getTimestamp("updated_at")
                    );
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
                    return new Holiday(
                        rs.getInt("holiday_id"),
                        rs.getString("holiday_name"),
                        rs.getDate("holiday_date"),
                        rs.getString("calendar_type"),
                        rs.getBigDecimal("ot_multiplier"),
                        rs.getString("description"),
                        rs.getBoolean("status"),
                        rs.getTimestamp("created_at"),
                        rs.getTimestamp("updated_at")
                    );
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
        String sql = "INSERT INTO holidays (holiday_name, holiday_date, calendar_type, ot_multiplier, description, status) VALUES (?, ?, ?, ?, ?, 1)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, h.getHolidayName());
            ps.setDate(2, h.getHolidayDate());
            ps.setString(3, h.getCalendarType());
            ps.setBigDecimal(4, h.getOtMultiplier());
            ps.setString(5, h.getDescription());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean update(Holiday h) {
        String sql = "UPDATE holidays SET holiday_name=?, holiday_date=?, calendar_type=?, ot_multiplier=?, description=? WHERE holiday_id=?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, h.getHolidayName());
            ps.setDate(2, h.getHolidayDate());
            ps.setString(3, h.getCalendarType());
            ps.setBigDecimal(4, h.getOtMultiplier());
            ps.setString(5, h.getDescription());
            ps.setInt(6, h.getHolidayId());
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
}
