package dao;
import java.util.Map;
import java.util.LinkedHashMap;
import java.util.HashMap;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.Duration;

import model.ShiftAssignment;
import model.Shift;
import java.sql.Date;
import util.DBContext;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * ShiftAssignmentDAOImpl — JDBC implementation of {@link ShiftAssignmentDAO}.
 * All queries use PreparedStatement via the DBContext connection pool.
 */
public class ShiftAssignmentDAOImpl implements ShiftAssignmentDAO {
    private static final int SWIPE_WINDOW_MINUTES = 60;

    // ── Map ResultSet → ShiftAssignment (basic columns only) ──
    private ShiftAssignment mapRow(ResultSet rs) throws SQLException {
        ShiftAssignment sa = new ShiftAssignment();
        sa.setAssignmentId(rs.getInt("assignment_id"));
        sa.setUserId(rs.getInt("user_id"));
        sa.setShiftId(rs.getInt("shift_id"));
        sa.setAssignedDate(rs.getDate("assigned_date").toLocalDate());
        sa.setCreatedAt(rs.getTimestamp("created_at"));
        return sa;
    }

    // ── Map ResultSet with JOIN data (user_name, shift_name, times, flags) ──
    private ShiftAssignment mapRowWithJoin(ResultSet rs) throws SQLException {
        ShiftAssignment sa = mapRow(rs);
        try { sa.setUserName(rs.getString("full_name")); } catch (SQLException ignored) {}
        try { sa.setShiftName(rs.getString("shift_name")); } catch (SQLException ignored) {}
        try {
            java.sql.Time st = rs.getTime("start_time");
            if (st != null) sa.setStartTime(st.toLocalTime());
        } catch (SQLException ignored) {}
        try {
            java.sql.Time et = rs.getTime("end_time");
            if (et != null) sa.setEndTime(et.toLocalTime());
        } catch (SQLException ignored) {}
        try { sa.setNightShift(rs.getBoolean("is_night_shift")); } catch (SQLException ignored) {}
        try { sa.setCoefficient(rs.getFloat("coefficient")); } catch (SQLException ignored) {}
        return sa;
    }

    // ═══════════════════════════════════════════════════════════════

    @Override
    public List<ShiftAssignment> getByUserAndDateRange(int userId, LocalDate from, LocalDate to) {
        List<ShiftAssignment> list = new ArrayList<>();
        String sql = "SELECT sa.*, s.shift_name, s.start_time, s.end_time, s.is_night_shift, s.coefficient "
                   + "FROM shift_assignments sa "
                   + "JOIN shifts s ON sa.shift_id = s.shift_id "
                   + "WHERE sa.user_id = ? AND sa.assigned_date BETWEEN ? AND ? "
                   + "ORDER BY sa.assigned_date";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setDate(2, Date.valueOf(from));
            ps.setDate(3, Date.valueOf(to));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRowWithJoin(rs));
            }
        } catch (SQLException e) {
            System.err.println("Lỗi getByUserAndDateRange: " + e.getMessage());
        }
        return list;
    }

    @Override
    public List<ShiftAssignment> getByDateRange(LocalDate from, LocalDate to) {
        List<ShiftAssignment> list = new ArrayList<>();
        String sql = "SELECT sa.*, u.full_name, s.shift_name "
                   + "FROM shift_assignments sa "
                   + "JOIN users u ON sa.user_id = u.user_id "
                   + "JOIN shifts s ON sa.shift_id = s.shift_id "
                   + "WHERE sa.assigned_date BETWEEN ? AND ? "
                   + "ORDER BY u.full_name, sa.assigned_date";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(from));
            ps.setDate(2, Date.valueOf(to));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRowWithJoin(rs));
            }
        } catch (SQLException e) {
            System.err.println("Lỗi getByDateRange: " + e.getMessage());
        }
        return list;
    }

    @Override
    public ShiftAssignment getByUserAndDate(int userId, LocalDate date) {
        String sql = "SELECT sa.*, s.shift_name "
                   + "FROM shift_assignments sa "
                   + "JOIN shifts s ON sa.shift_id = s.shift_id "
                   + "WHERE sa.user_id = ? AND sa.assigned_date = ?";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setDate(2, Date.valueOf(date));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRowWithJoin(rs);
            }
        } catch (SQLException e) {
            System.err.println("Lỗi getByUserAndDate: " + e.getMessage());
        }
        return null;
    }

    @Override
    public boolean addAssignment(ShiftAssignment a) {
        String sql = "INSERT IGNORE INTO shift_assignments (user_id, shift_id, assigned_date) "
                   + "VALUES (?, ?, ?)";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, a.getUserId());
            ps.setInt(2, a.getShiftId());
            ps.setDate(3, Date.valueOf(a.getAssignedDate()));
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi addAssignment: " + e.getMessage());
        }
        return false;
    }

    @Override
    public int batchAssignWeekdays(int userId, int shiftId, LocalDate from, LocalDate to) {
        String sql = "INSERT IGNORE INTO shift_assignments (user_id, shift_id, assigned_date) "
                   + "VALUES (?, ?, ?)";
        int inserted = 0;
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {

            LocalDate cursor = from;
            while (!cursor.isAfter(to)) {
                java.time.DayOfWeek day = cursor.getDayOfWeek();
                if (day != java.time.DayOfWeek.SATURDAY && day != java.time.DayOfWeek.SUNDAY) {
                    ps.setInt(1, userId);
                    ps.setInt(2, shiftId);
                    ps.setDate(3, Date.valueOf(cursor));
                    ps.addBatch();
                }
                cursor = cursor.plusDays(1);
            }
            int[] results = ps.executeBatch();
            for (int r : results) {
                if (r > 0) inserted++;
            }
        } catch (SQLException e) {
            System.err.println("Lỗi batchAssignWeekdays: " + e.getMessage());
        }
        return inserted;
    }

    @Override
    public boolean updateAssignment(int assignmentId, int newShiftId) {
        String sql = "UPDATE shift_assignments SET shift_id = ? WHERE assignment_id = ?";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, newShiftId);
            ps.setInt(2, assignmentId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi updateAssignment: " + e.getMessage());
        }
        return false;
    }

    @Override
    public boolean deleteAssignment(int assignmentId) {
        String sql = "DELETE FROM shift_assignments WHERE assignment_id = ?";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, assignmentId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi deleteAssignment: " + e.getMessage());
        }
        return false;
    }

    @Override
    public boolean deleteByUserAndDate(int userId, LocalDate date) {
        String sql = "DELETE FROM shift_assignments WHERE user_id = ? AND assigned_date = ?";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setDate(2, Date.valueOf(date));
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi deleteByUserAndDate: " + e.getMessage());
        }
        return false;
    }

    private dao.ShiftDAO shiftDAO = new dao.ShiftDAOImpl();
    // --- Merged from Service ---


    

    // ═══════════════════════════════════════════════════════════════
    // CRUD Delegates
    // ═══════════════════════════════════════════════════════════════
    

    

    

    

    @Override
    public int batchAssign(int userId, int shiftId, LocalDate from, LocalDate to) {
        Shift newShift = shiftDAO.getShiftById(shiftId);
        if (newShift == null) return 0;
        
        List<ShiftAssignment> existing = this.getByUserAndDateRange(userId, from, to);
        int inserted = 0;
        
        LocalDate cursor = from;
        while (!cursor.isAfter(to)) {
            final LocalDate currentDate = cursor;
            boolean overlaps = false;
            
            for (ShiftAssignment sa : existing) {
                if (sa.getAssignedDate().equals(currentDate)) {
                    Shift existingShift = shiftDAO.getShiftById(sa.getShiftId());
                    if (existingShift != null && isOverlap(newShift, existingShift)) {
                        overlaps = true;
                        break;
                    }
                }
            }
            
            if (!overlaps) {
                ShiftAssignment a = new ShiftAssignment();
                a.setUserId(userId);
                a.setShiftId(shiftId);
                a.setAssignedDate(currentDate);
                if (this.addAssignment(a)) {
                    inserted++;
                }
            }
            cursor = cursor.plusDays(1);
        }
        return inserted;
    }

    private boolean isOverlap(Shift s1, Shift s2) {
        long start1 = s1.getStartTime().toSecondOfDay() / 60;
        long end1 = s1.getEndTime().toSecondOfDay() / 60;
        if (end1 <= start1 || s1.isNightShift()) end1 += 1440;
        
        long start2 = s2.getStartTime().toSecondOfDay() / 60;
        long end2 = s2.getEndTime().toSecondOfDay() / 60;
        if (end2 <= start2 || s2.isNightShift()) end2 += 1440;
        
        return Math.max(start1, start2) < Math.min(end1, end2);
    }

    

    

    // ═══════════════════════════════════════════════════════════════
    // Weekly Schedule Matrix
    // ═══════════════════════════════════════════════════════════════
    /**
     * Build a matrix: userId → { dayIndex(0=Mon..6=Sun) → ShiftAssignment }
     * This powers the visual calendar grid in the JSP.
     */
    @Override
    public Map<Integer, Map<Integer, List<ShiftAssignment>>> buildWeeklyScheduleMatrix(LocalDate weekStart) {
        LocalDate weekEnd = weekStart.plusDays(6); // Monday to Sunday

        List<ShiftAssignment> assignments = this.getByDateRange(weekStart, weekEnd);

        // Build the matrix
        Map<Integer, Map<Integer, List<ShiftAssignment>>> matrix = new LinkedHashMap<>();

        for (ShiftAssignment sa : assignments) {
            int userId = sa.getUserId();
            // Calculate day index: 0=Monday, 6=Sunday
            int dayIndex = (int) (sa.getAssignedDate().toEpochDay() - weekStart.toEpochDay());

            if (dayIndex < 0 || dayIndex > 6) {
                continue; // Safety bound
            }
            matrix.computeIfAbsent(userId, k -> new HashMap<>());
            matrix.get(userId).computeIfAbsent(dayIndex, k -> new ArrayList<>()).add(sa);
        }

        return matrix;
    }

    // ═══════════════════════════════════════════════════════════════
    // Next-Shift Clock-In Filter
    // ═══════════════════════════════════════════════════════════════
    /**
     * Resolve whether a card swipe is a CHECK_OUT (ending current shift) or a
     * CHECK_IN (starting next shift).
     *
     * Algorithm: 1. Look up the user's assignment for swipeDate. 2. Load the
     * assigned Shift to get start_time and end_time. 3. Calculate how close
     * swipeTime is to end_time vs start_time. 4. If swipeTime is within
     * SWIPE_WINDOW_MINUTES of end_time → CHECK_OUT. 5. If swipeTime is within
     * SWIPE_WINDOW_MINUTES of start_time → CHECK_IN. 6. Also check the NEXT
     * day's assignment (for night shift checkout on next day).
     *
     * Example: Shift1 ends 14:00, Shift2 starts 14:00. Swipe at 13:55 → |14:00
     * - 13:55| = 5 min → CHECK_OUT for Shift1. If user has Shift2 on same day,
     * also 5 min from start → ambiguous. Resolution: Prefer CHECK_OUT
     * (finishing work) over CHECK_IN (starting work).
     */
    @Override
    public String resolveSwipeIntent(int userId, LocalTime swipeTime, LocalDate swipeDate) {
        // 1. Get today's assignment
        ShiftAssignment todayAssignment = this.getByUserAndDate(userId, swipeDate);

        if (todayAssignment == null) {
            // Check if there's a PREVIOUS day's night shift that ends today
            ShiftAssignment yesterdayAssignment = this.getByUserAndDate(userId, swipeDate.minusDays(1));
            if (yesterdayAssignment != null) {
                Shift yesterdayShift = shiftDAO.getShiftById(yesterdayAssignment.getShiftId());
                if (yesterdayShift != null && isNightCrossing(yesterdayShift)) {
                    // The swipe might be checking out of yesterday's night shift
                    long toEnd = Math.abs(Duration.between(swipeTime, yesterdayShift.getEndTime()).toMinutes());
                    if (toEnd <= SWIPE_WINDOW_MINUTES) {
                        return "CHECK_OUT";
                    }
                }
            }
            return "UNKNOWN";
        }

        // 2. Load today's shift definition
        Shift todayShift = shiftDAO.getShiftById(todayAssignment.getShiftId());
        if (todayShift == null) {
            return "UNKNOWN";
        }

        // 3. Calculate proximity to start_time and end_time
        long toStart = absDurationMinutes(swipeTime, todayShift.getStartTime());
        long toEnd = absDurationMinutes(swipeTime, todayShift.getEndTime());

        // 4. Determine intent
        //    Priority: CHECK_OUT wins if equally close (employee finishing work first)
        if (toEnd <= SWIPE_WINDOW_MINUTES && toStart <= SWIPE_WINDOW_MINUTES) {
            // Ambiguous — prefer CHECK_OUT (ending a shift is higher priority)
            return "CHECK_OUT";
        }

        if (toEnd <= SWIPE_WINDOW_MINUTES) {
            return "CHECK_OUT";
        }

        if (toStart <= SWIPE_WINDOW_MINUTES) {
            return "CHECK_IN";
        }

        // Not within any window — could be a mid-shift swipe
        return "UNKNOWN";
    }

    // ── Helpers ──
    private boolean isNightCrossing(Shift shift) {
        return shift.isNightShift() || shift.getEndTime().isBefore(shift.getStartTime());
    }

    /**
     * Absolute difference in minutes between two LocalTime values. Handles
     * midnight crossing by taking the minimum of both directions.
     */
    private long absDurationMinutes(LocalTime a, LocalTime b) {
        long diff = Math.abs(Duration.between(a, b).toMinutes());
        // Also check the "other way around" for midnight edge
        long altDiff = 1440 - diff;
        return Math.min(diff, altDiff);
    }

}





