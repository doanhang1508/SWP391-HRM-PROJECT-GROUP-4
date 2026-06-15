package dao;

import model.Shift;
import util.DBContext;

import java.sql.*;
import java.time.LocalTime;
import java.time.LocalDate;
import java.time.Duration;
import model.DepartmentShift;
import model.User;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

/**
 * ShiftDAOImpl — JDBC implementation of {@link ShiftDAO} for v2 schema.
 * Columns: shift_id, shift_name, start_time, end_time,
 *          break_start, break_end, is_night_shift, coefficient, status
 */
public class ShiftDAOImpl implements ShiftDAO {
    private static final int GRACE_PERIOD_MINUTES = 15;

    // ── Map ResultSet → Shift ──
    private Shift mapRow(ResultSet rs) throws SQLException {
        Shift s = new Shift();
        s.setShiftId(rs.getInt("shift_id"));
        s.setShiftName(rs.getString("shift_name"));
        s.setStartTime(rs.getTime("start_time").toLocalTime());
        s.setEndTime(rs.getTime("end_time").toLocalTime());

        Time bs = rs.getTime("break_start");
        s.setBreakStart(bs != null ? bs.toLocalTime() : null);

        Time be = rs.getTime("break_end");
        s.setBreakEnd(be != null ? be.toLocalTime() : null);

        s.setNightShift(rs.getBoolean("is_night_shift"));
        s.setCoefficient(rs.getFloat("coefficient"));
        s.setStatus(rs.getInt("status"));
        return s;
    }

    // ── Helper: set nullable TIME ──
    private void setNullableTime(PreparedStatement ps, int idx, LocalTime t) throws SQLException {
        if (t != null) ps.setTime(idx, Time.valueOf(t));
        else ps.setNull(idx, Types.TIME);
    }

    // ═══════════════════════════════════════════════════════════════
    // CRUD
    // ═══════════════════════════════════════════════════════════════

    @Override
    public List<Shift> getAllShifts() {
        List<Shift> list = new ArrayList<>();
        // Exclude OT custom shifts (coefficient >= 1.5) from HR manager view
        String sql = "SELECT * FROM shifts WHERE coefficient < 1.5 ORDER BY shift_id";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            Logger.getAnonymousLogger("Lỗi getAllShifts: " + e.getMessage());
        }
        return list;
    }

    @Override
    public List<Shift> getActiveShifts() {
        List<Shift> list = new ArrayList<>();
        // Exclude OT custom shifts (coefficient >= 1.5) from HR manager view
        String sql = "SELECT * FROM shifts WHERE status = 1 AND coefficient < 1.5 ORDER BY start_time";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            Logger.getAnonymousLogger("Lỗi getActiveShifts: " + e.getMessage());
        }
        return list;
    }

    @Override
    public Shift getShiftById(int shiftId) {
        String sql = "SELECT * FROM shifts WHERE shift_id = ?";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, shiftId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            System.err.println("Lỗi getShiftById: " + e.getMessage());
        }
        return null;
    }

    @Override
    public boolean addShift(Shift s) {
        String sql = "INSERT INTO shifts (shift_name, start_time, end_time, "
                   + "break_start, break_end, is_night_shift, coefficient, status) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, s.getShiftName());
            ps.setTime(2, Time.valueOf(s.getStartTime()));
            ps.setTime(3, Time.valueOf(s.getEndTime()));
            setNullableTime(ps, 4, s.getBreakStart());
            setNullableTime(ps, 5, s.getBreakEnd());
            ps.setBoolean(6, s.isNightShift());
            ps.setFloat(7, s.getCoefficient());
            ps.setInt(8, s.getStatus());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi addShift: " + e.getMessage());
        }
        return false;
    }

    @Override
    public boolean updateShift(Shift s) {
        String sql = "UPDATE shifts SET shift_name=?, start_time=?, end_time=?, "
                   + "break_start=?, break_end=?, is_night_shift=?, coefficient=?, status=? "
                   + "WHERE shift_id=?";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, s.getShiftName());
            ps.setTime(2, Time.valueOf(s.getStartTime()));
            ps.setTime(3, Time.valueOf(s.getEndTime()));
            setNullableTime(ps, 4, s.getBreakStart());
            setNullableTime(ps, 5, s.getBreakEnd());
            ps.setBoolean(6, s.isNightShift());
            ps.setFloat(7, s.getCoefficient());
            ps.setInt(8, s.getStatus());
            ps.setInt(9, s.getShiftId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi updateShift: " + e.getMessage());
        }
        return false;
    }

    @Override
    public boolean deleteShift(int shiftId) {
        String[] cascadeSqls = {
            "DELETE FROM attendance WHERE shift_id = ?",
            "DELETE FROM department_shifts WHERE shift_id = ?",
            "DELETE FROM employee_shifts WHERE shift_id = ?",
            "DELETE FROM shift_assignments WHERE shift_id = ?"
        };
        String deleteSql = "DELETE FROM shifts WHERE shift_id = ?";
        
        try (Connection c = DBContext.getConnection()) {
            c.setAutoCommit(false);
            try {
                for (String sql : cascadeSqls) {
                    try (PreparedStatement ps = c.prepareStatement(sql)) {
                        ps.setInt(1, shiftId);
                        ps.executeUpdate();
                    }
                }
                boolean result = false;
                try (PreparedStatement ps = c.prepareStatement(deleteSql)) {
                    ps.setInt(1, shiftId);
                    result = ps.executeUpdate() > 0;
                }
                c.commit();
                return result;
            } catch (SQLException e) {
                c.rollback();
                System.err.println("Lỗi deleteShift transaction: " + e.getMessage());
            } finally {
                c.setAutoCommit(true);
            }
        } catch (SQLException e) {
            System.err.println("Lỗi deleteShift: " + e.getMessage());
        }
        return false;
    }

    @Override
    public boolean toggleShiftStatus(int shiftId) {
        String sql = "UPDATE shifts SET status = 1 - status WHERE shift_id = ?";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, shiftId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi toggleShiftStatus: " + e.getMessage());
        }
        return false;
    }

    @Override
    public boolean isShiftNameExists(String shiftName, int excludeShiftId) {
        String sql = "SELECT 1 FROM shifts WHERE shift_name = ? AND shift_id != ?";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, shiftName);
            ps.setInt(2, excludeShiftId);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        } catch (SQLException e) {
            System.err.println("Lỗi isShiftNameExists: " + e.getMessage());
        }
        return false;
    }

    private dao.DepartmentShiftDAO departmentShiftDAO = new dao.DepartmentShiftDAOImpl();
    // --- Merged from Service ---


    

    // ═══════════════════════════════════════════════════════════════
    // CRUD Delegates
    // ═══════════════════════════════════════════════════════════════
    

    

    

    

    

    

    

    



    // ═══════════════════════════════════════════════════════════════
    // <<include>> Validate Shift Data
    //
    // Use Case: Called by both "Create Shift" and "Edit Shift".
    // Ensures data integrity before persisting to database.
    // ═══════════════════════════════════════════════════════════════
    @Override
    public String validateShiftData(Shift shift, int excludeShiftId) {
        // 1. Null check
        if (shift == null) {
            return "Dữ liệu ca làm việc không được null";
        }

        // 2. Shift name validation
        if (shift.getShiftName() == null || shift.getShiftName().trim().isEmpty()) {
            return "Tên ca làm việc không được để trống";
        }
        if (shift.getShiftName().trim().length() > 50) {
            return "Tên ca làm việc không được vượt quá 50 ký tự";
        }

        // 3. Time format validation
        if (shift.getStartTime() == null) {
            return "Giờ bắt đầu không được để trống";
        }
        if (shift.getEndTime() == null) {
            return "Giờ kết thúc không được để trống";
        }

        // 4. Coefficient validation
        if (shift.getCoefficient() <= 0) {
            return "Hệ số lương phải lớn hơn 0";
        }

        // 5. Break time validation
        if (shift.getBreakStart() != null && shift.getBreakEnd() != null) {
            if (!shift.getBreakStart().isBefore(shift.getBreakEnd())) {
                return "Giờ bắt đầu nghỉ phải trước giờ kết thúc nghỉ";
            }
        }

        // 6. Duplicate name check (DB query)
        if (this.isShiftNameExists(shift.getShiftName().trim(), excludeShiftId)) {
            return "Tên ca làm việc đã tồn tại trong hệ thống";
        }

        return null; // null = valid
    }

    // ═══════════════════════════════════════════════════════════════
    // <<extend>> Auto Detect Night Shift
    //
    // Use Case: Conditionally triggered by "Create Shift" and "Edit Shift".
    // If end_time.isBefore(start_time), this is a night shift that crosses
    // midnight. The system automatically sets:
    //   - isNightShift = true
    //   - coefficient = 1.3 (night shift premium)
    // ═══════════════════════════════════════════════════════════════
    @Override
    public void autoDetectNightShift(Shift shift) {
        if (shift == null || shift.getStartTime() == null || shift.getEndTime() == null) {
            return;
        }

        if (shift.getEndTime().isBefore(shift.getStartTime())) {
            // End time before start time → crosses midnight → Night Shift
            shift.setNightShift(true);
            shift.setCoefficient(1.3f);
        } else {
            shift.setNightShift(false);
            // Keep coefficient as specified by user (default 1.0)
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // Department Shift Mapping
    // ═══════════════════════════════════════════════════════════════
    @Override
    public List<DepartmentShift> getAllDepartmentShifts() {
        return this.departmentShiftDAO.getAll();
    }

    @Override
    public List<DepartmentShift> getDepartmentShiftsByDeptId(int deptId) {
        return this.departmentShiftDAO.getByDepartmentId(deptId);
    }

    @Override
    public boolean assignDefaultShiftToDepartment(int departmentId, int shiftId) {
        boolean ok = this.departmentShiftDAO.add(departmentId, shiftId);
        if (ok) {
            // Automatically assign this shift to all users in the department 
            // for Monday to Friday, spanning the next 90 days.
            UserDAO userDAO = new UserDAO();
            List<User> users = userDAO.getByDepartment(departmentId);
            ShiftAssignmentDAO saDAO = new ShiftAssignmentDAOImpl();
            
            LocalDate today = LocalDate.now();
            LocalDate end = today.plusDays(90); // default to 90 days ahead
            
            for (User u : users) {
                saDAO.batchAssignWeekdays(u.getUserId(), shiftId, today, end);
            }
        }
        return ok;
    }

    @Override
    public boolean removeDepartmentShift(int id) {
        return this.departmentShiftDAO.delete(id);
    }

    // ═══════════════════════════════════════════════════════════════
    // Business Logic
    // ═══════════════════════════════════════════════════════════════
    /**
     * Calculate net working hours.
     *
     * Normal: 08:00→17:00, break 12:00-13:00 → 9h - 1h = 8.0h Night:
     * 22:00→06:00, no break → (24-22)+6 = 8.0h
     *
     * Algorithm: 1. Compute raw minutes = Duration.between(start,
     * end).toMinutes() 2. If end.isBefore(start) OR is_night_shift flag → add
     * 1440 minutes 3. Subtract break minutes (same midnight-safe logic) 4.
     * Ensure non-negative result
     */
    @Override
    public double calculateTotalWorkingHours(Shift shift) {
        if (shift == null || shift.getStartTime() == null || shift.getEndTime() == null) {
            return 0.0;
        }

        LocalTime start = shift.getStartTime();
        LocalTime end = shift.getEndTime();

        // Step 1: Raw duration
        long shiftMinutes = Duration.between(start, end).toMinutes();

        // Step 2: Midnight correction
        // Use BOTH the explicit flag AND the time comparison for safety
        if (end.isBefore(start) || shift.isNightShift()) {
            if (shiftMinutes <= 0) {
                shiftMinutes += 24 * 60;
            }
        }

        // Step 3: Subtract break
        long breakMinutes = 0;
        if (shift.getBreakStart() != null && shift.getBreakEnd() != null) {
            breakMinutes = Duration.between(shift.getBreakStart(), shift.getBreakEnd()).toMinutes();
            if (shift.getBreakEnd().isBefore(shift.getBreakStart())) {
                breakMinutes += 24 * 60;
            }
        }

        // Step 4: Net result, never negative
        long netMinutes = Math.max(0, shiftMinutes - breakMinutes);
        return netMinutes / 60.0;
    }

    /**
     * A shift is a night shift if: - The is_night_shift flag is explicitly set
     * in the DB, OR - The end_time is chronologically before start_time
     * (crosses midnight)
     */
    @Override
    public boolean isNightShift(Shift shift) {
        if (shift == null || shift.getStartTime() == null || shift.getEndTime() == null) {
            return false;
        }
        return shift.isNightShift() || shift.getEndTime().isBefore(shift.getStartTime());
    }

    /**
     * HR Rule: "The check-in date OWNS the shift."
     *
     * For a night shift (22:00 May 31 → 06:00 Jun 1): → work_date =
     * assigned_date (May 31)
     *
     * For a day shift: assigned_date is the work_date itself.
     */
    @Override
    public LocalDate resolveWorkDate(Shift shift, LocalDate assignedDate) {
        // The assigned_date is always the check-in date, which IS the work_date.
        // Night shifts don't change this — the checkout happens on assignedDate + 1,
        // but the work record belongs to assignedDate.
        return assignedDate;
    }

    /**
     * Check if clock-in is within grace period.
     *
     * On-time = clockIn is between (shiftStart - any early) and (shiftStart +
     * gracePeriod). Example: shift 08:00, grace 5 min → clock-in at 08:04 → ON
     * TIME ✓ shift 08:00, grace 5 min → clock-in at 08:06 → LATE ✗
     */
    @Override
    public boolean isWithinGracePeriod(LocalTime shiftStart, LocalTime clockIn) {
        if (shiftStart == null || clockIn == null) {
            return false;
        }

        long diffMinutes = Duration.between(shiftStart, clockIn).toMinutes();

        // Handle midnight crossing for the comparison
        if (diffMinutes < -720) {  // More than 12h "early" = actually late across midnight
            diffMinutes += 24 * 60;
        }

        // On-time: arrived early (diff ≤ 0) or within grace period
        return diffMinutes <= GRACE_PERIOD_MINUTES;
    }

    /**
     * Calculate how many minutes late the employee is. Returns 0 if on-time or
     * early. Subtracts the grace period from the raw lateness.
     */
    @Override
    public long calculateLatenessMinutes(LocalTime shiftStart, LocalTime clockIn) {
        if (shiftStart == null || clockIn == null) {
            return 0;
        }

        long diffMinutes = Duration.between(shiftStart, clockIn).toMinutes();

        // Handle midnight crossing
        if (diffMinutes < -720) {
            diffMinutes += 24 * 60;
        }

        // If within grace or early, not late
        if (diffMinutes <= GRACE_PERIOD_MINUTES) {
            return 0;
        }

        // Late by (diff - grace) minutes
        return diffMinutes - GRACE_PERIOD_MINUTES;
    }

    /**
     * Early check-in OT prevention.
     *
     * If employee clocks in at 07:50 for an 08:00 shift, that's 10 minutes
     * early. Those 10 minutes do NOT count as overtime UNLESS an official OT
     * request exists.
     *
     * @return overtime minutes (0 if no OT request is linked).
     */
    @Override
    public long calculateEarlyCheckInOvertimeMinutes(LocalTime shiftStart, LocalTime clockIn,
            boolean hasOvertimeRequest) {
        if (shiftStart == null || clockIn == null) {
            return 0;
        }

        long diffMinutes = Duration.between(clockIn, shiftStart).toMinutes();

        // Handle midnight crossing
        if (diffMinutes < -720) {
            diffMinutes += 24 * 60;
        }

        // Only positive diff means the employee arrived early
        if (diffMinutes <= 0) {
            return 0;
        }

        // Early arrival is only OT if there's an approved request
        return hasOvertimeRequest ? diffMinutes : 0;
    }

    @Override
    public int findOrCreateCustomShift(LocalTime start, LocalTime end) {
        if (start == null || end == null) {
            return -1;
        }
        String expectedName = "Ca Hành Chính";
        boolean expectedIsNight = false;
        if (start.getHour() >= 18 || start.getHour() < 6 || end.isBefore(start)) {
            expectedName = "Ca 3 (Đêm)";
            expectedIsNight = true;
        }

        // 1. Find if an OT shift with these exact times already exists
        String sqlFind = "SELECT shift_id, shift_name FROM shifts WHERE start_time = ? AND end_time = ? AND coefficient > 1.0";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sqlFind)) {
            ps.setTime(1, java.sql.Time.valueOf(start));
            ps.setTime(2, java.sql.Time.valueOf(end));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int id = rs.getInt("shift_id");
                    String currentName = rs.getString("shift_name");
                    if (!currentName.equals(expectedName)) {
                        String sqlUpdate = "UPDATE shifts SET shift_name = ?, is_night_shift = ? WHERE shift_id = ?";
                        try (PreparedStatement updatePs = c.prepareStatement(sqlUpdate)) {
                            updatePs.setString(1, expectedName);
                            updatePs.setBoolean(2, expectedIsNight);
                            updatePs.setInt(3, id);
                            updatePs.executeUpdate();
                        }
                    }
                    return id;
                }
            }
        } catch (SQLException e) {
            Logger.getAnonymousLogger().severe("Lỗi SQL findOrCreateCustomShift: " + e.getMessage());
        }

        // 2. If not, insert new OT custom shift
        String sqlInsert = "INSERT INTO shifts (shift_name, start_time, end_time, "
                         + "break_start, break_end, is_night_shift, coefficient, status) "
                         + "VALUES (?, ?, ?, null, null, ?, 1.5, 1)";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sqlInsert, PreparedStatement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, expectedName);
            ps.setTime(2, java.sql.Time.valueOf(start));
            ps.setTime(3, java.sql.Time.valueOf(end));
            ps.setBoolean(4, expectedIsNight);

            if (ps.executeUpdate() > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        } catch (SQLException e) {
            Logger.getAnonymousLogger().severe("Lỗi SQL insert custom shift: " + e.getMessage());
        }

        // Default fallback if insertion fails
        return expectedIsNight ? 4 : 1;
    }
}






