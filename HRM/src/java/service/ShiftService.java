package service;

import model.Shift;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

/**
 * ShiftService — Service interface for Shift definition & business logic.
 * All computational logic lives here, NOT in the Model entity.
 */
public interface ShiftService {

    // ── CRUD Delegates ──
    List<Shift> getAllShifts();
    List<Shift> getActiveShifts();
    Shift getShiftById(int shiftId);
    boolean addShift(Shift shift);
    boolean updateShift(Shift shift);
    boolean deleteShift(int shiftId);
    boolean toggleShiftStatus(int shiftId);
    boolean isShiftNameExists(String shiftName, int excludeShiftId);

    // ═══════════════════════════════════════════════════════════════
    // Business Logic
    // ═══════════════════════════════════════════════════════════════

    /**
     * Calculate net working hours for a shift.
     * Handles the midnight-crossing edge case for night shifts.
     * Formula: grossHours - breakHours, never negative.
     */
    double calculateTotalWorkingHours(Shift shift);

    /**
     * Detect if a shift crosses midnight (endTime before startTime on 24h clock,
     * OR the is_night_shift flag is explicitly set in the database).
     */
    boolean isNightShift(Shift shift);

    /**
     * Determine the correct work_date for attendance records.
     *
     * HR Rule: "The check-in date OWNS the shift."
     * If an employee checks in at 22:00 on May 31 and checks out at 06:00 on June 1,
     * the work_date = 2026-05-31.
     *
     * For night shifts, this returns the assigned_date (check-in date).
     * For day shifts, assigned_date and checkout_date are the same.
     */
    LocalDate resolveWorkDate(Shift shift, LocalDate assignedDate);

    /**
     * Check if a clock-in timestamp is within the grace period.
     * Default grace = 5 minutes.
     *
     * @param shiftStart the shift's official start time.
     * @param clockIn    the employee's actual clock-in time.
     * @return true if the clock-in is within acceptable range (on-time).
     */
    boolean isWithinGracePeriod(LocalTime shiftStart, LocalTime clockIn);

    /**
     * Calculate lateness in minutes (0 if on-time or early).
     * Takes the grace period into account.
     */
    long calculateLatenessMinutes(LocalTime shiftStart, LocalTime clockIn);

    /**
     * Determine if an early check-in should count as overtime.
     * Returns 0 unless an official OT request is linked.
     * Early arrivals (e.g. 07:50 for an 08:00 shift) do NOT grant overtime.
     */
    long calculateEarlyCheckInOvertimeMinutes(LocalTime shiftStart, LocalTime clockIn,
                                               boolean hasOvertimeRequest);
}
