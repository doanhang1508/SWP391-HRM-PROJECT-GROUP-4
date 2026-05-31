package service;

import dao.ShiftDAO;
import dao.ShiftDAOImpl;
import model.Shift;

import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

/**
 * ShiftServiceImpl — ALL business logic for Shift management.
 * Handles midnight crossing, grace periods, lateness, and OT prevention.
 */
public class ShiftServiceImpl implements ShiftService {

    /** Configurable grace period in minutes (HR policy) */
    private static final int GRACE_PERIOD_MINUTES = 5;

    private final ShiftDAO shiftDAO;

    public ShiftServiceImpl() {
        this.shiftDAO = new ShiftDAOImpl();
    }

    public ShiftServiceImpl(ShiftDAO shiftDAO) {
        this.shiftDAO = shiftDAO;
    }

    // ═══════════════════════════════════════════════════════════════
    // CRUD Delegates
    // ═══════════════════════════════════════════════════════════════

    @Override public List<Shift> getAllShifts()     { return shiftDAO.getAllShifts(); }
    @Override public List<Shift> getActiveShifts()  { return shiftDAO.getActiveShifts(); }
    @Override public Shift getShiftById(int id)     { return shiftDAO.getShiftById(id); }
    @Override public boolean addShift(Shift s)      { return shiftDAO.addShift(s); }
    @Override public boolean updateShift(Shift s)   { return shiftDAO.updateShift(s); }
    @Override public boolean deleteShift(int id)    { return shiftDAO.deleteShift(id); }
    @Override public boolean toggleShiftStatus(int id)                  { return shiftDAO.toggleShiftStatus(id); }
    @Override public boolean isShiftNameExists(String n, int exId)      { return shiftDAO.isShiftNameExists(n, exId); }

    // ═══════════════════════════════════════════════════════════════
    // Business Logic
    // ═══════════════════════════════════════════════════════════════

    /**
     * Calculate net working hours.
     *
     * Normal: 08:00→17:00, break 12:00-13:00 → 9h - 1h = 8.0h
     * Night:  22:00→06:00, no break           → (24-22)+6 = 8.0h
     *
     * Algorithm:
     * 1. Compute raw minutes = Duration.between(start, end).toMinutes()
     * 2. If end.isBefore(start) OR is_night_shift flag → add 1440 minutes
     * 3. Subtract break minutes (same midnight-safe logic)
     * 4. Ensure non-negative result
     */
    @Override
    public double calculateTotalWorkingHours(Shift shift) {
        if (shift == null || shift.getStartTime() == null || shift.getEndTime() == null) {
            return 0.0;
        }

        LocalTime start = shift.getStartTime();
        LocalTime end   = shift.getEndTime();

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
     * A shift is a night shift if:
     * - The is_night_shift flag is explicitly set in the DB, OR
     * - The end_time is chronologically before start_time (crosses midnight)
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
     * For a night shift (22:00 May 31 → 06:00 Jun 1):
     *   → work_date = assigned_date (May 31)
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
     * On-time = clockIn is between (shiftStart - any early) and (shiftStart + gracePeriod).
     * Example: shift 08:00, grace 5 min → clock-in at 08:04 → ON TIME ✓
     *          shift 08:00, grace 5 min → clock-in at 08:06 → LATE ✗
     */
    @Override
    public boolean isWithinGracePeriod(LocalTime shiftStart, LocalTime clockIn) {
        if (shiftStart == null || clockIn == null) return false;

        long diffMinutes = Duration.between(shiftStart, clockIn).toMinutes();

        // Handle midnight crossing for the comparison
        if (diffMinutes < -720) {  // More than 12h "early" = actually late across midnight
            diffMinutes += 24 * 60;
        }

        // On-time: arrived early (diff ≤ 0) or within grace period
        return diffMinutes <= GRACE_PERIOD_MINUTES;
    }

    /**
     * Calculate how many minutes late the employee is.
     * Returns 0 if on-time or early.
     * Subtracts the grace period from the raw lateness.
     */
    @Override
    public long calculateLatenessMinutes(LocalTime shiftStart, LocalTime clockIn) {
        if (shiftStart == null || clockIn == null) return 0;

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
     * If employee clocks in at 07:50 for an 08:00 shift, that's 10 minutes early.
     * Those 10 minutes do NOT count as overtime UNLESS an official OT request exists.
     *
     * @return overtime minutes (0 if no OT request is linked).
     */
    @Override
    public long calculateEarlyCheckInOvertimeMinutes(LocalTime shiftStart, LocalTime clockIn,
                                                      boolean hasOvertimeRequest) {
        if (shiftStart == null || clockIn == null) return 0;

        long diffMinutes = Duration.between(clockIn, shiftStart).toMinutes();

        // Handle midnight crossing
        if (diffMinutes < -720) {
            diffMinutes += 24 * 60;
        }

        // Only positive diff means the employee arrived early
        if (diffMinutes <= 0) return 0;

        // Early arrival is only OT if there's an approved request
        return hasOvertimeRequest ? diffMinutes : 0;
    }
}
