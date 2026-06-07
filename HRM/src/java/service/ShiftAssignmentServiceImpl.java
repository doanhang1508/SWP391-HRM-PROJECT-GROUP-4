package service;

import dao.ShiftAssignmentDAO;
import dao.ShiftAssignmentDAOImpl;
import dao.ShiftDAO;
import dao.ShiftDAOImpl;
import model.Shift;
import model.ShiftAssignment;

import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.*;

/**
 * ShiftAssignmentServiceImpl — Scheduling coordinator. Builds weekly schedule
 * matrices, batch-assigns shifts, and resolves clock-in/out ambiguity at shift
 * boundaries.
 */
public class ShiftAssignmentServiceImpl implements ShiftAssignmentService {

    /**
     * Maximum minutes before a shift's start/end that a swipe is considered
     * related to that shift (window = 30 minutes).
     */
    private static final int SWIPE_WINDOW_MINUTES = 30;

    private final ShiftAssignmentDAO assignmentDAO;
    private final ShiftDAO shiftDAO;

    public ShiftAssignmentServiceImpl() {
        this.assignmentDAO = new ShiftAssignmentDAOImpl();
        this.shiftDAO = new ShiftDAOImpl();
    }

    public ShiftAssignmentServiceImpl(ShiftAssignmentDAO assignmentDAO, ShiftDAO shiftDAO) {
        this.assignmentDAO = assignmentDAO;
        this.shiftDAO = shiftDAO;
    }

    // ═══════════════════════════════════════════════════════════════
    // CRUD Delegates
    // ═══════════════════════════════════════════════════════════════
    @Override
    public List<ShiftAssignment> getByDateRange(LocalDate from, LocalDate to) {
        return assignmentDAO.getByDateRange(from, to);
    }

    @Override
    public List<ShiftAssignment> getByUserAndDateRange(int userId, LocalDate from, LocalDate to) {
        return assignmentDAO.getByUserAndDateRange(userId, from, to);
    }

    @Override
    public ShiftAssignment getByUserAndDate(int userId, LocalDate date) {
        return assignmentDAO.getByUserAndDate(userId, date);
    }

    @Override
    public boolean addAssignment(ShiftAssignment assignment) {
        return assignmentDAO.addAssignment(assignment);
    }

    @Override
    public int batchAssign(int userId, int shiftId, LocalDate from, LocalDate to) {
        return assignmentDAO.batchAssign(userId, shiftId, from, to);
    }

    @Override
    public boolean updateAssignment(int assignmentId, int newShiftId) {
        return assignmentDAO.updateAssignment(assignmentId, newShiftId);
    }

    @Override
    public boolean deleteAssignment(int assignmentId) {
        return assignmentDAO.deleteAssignment(assignmentId);
    }

    // ═══════════════════════════════════════════════════════════════
    // Weekly Schedule Matrix
    // ═══════════════════════════════════════════════════════════════
    /**
     * Build a matrix: userId → { dayIndex(0=Mon..6=Sun) → ShiftAssignment }
     * This powers the visual calendar grid in the JSP.
     */
    @Override
    public Map<Integer, Map<Integer, ShiftAssignment>> buildWeeklyScheduleMatrix(LocalDate weekStart) {
        LocalDate weekEnd = weekStart.plusDays(6); // Monday to Sunday

        List<ShiftAssignment> assignments = assignmentDAO.getByDateRange(weekStart, weekEnd);

        // Build the matrix
        Map<Integer, Map<Integer, ShiftAssignment>> matrix = new LinkedHashMap<>();

        for (ShiftAssignment sa : assignments) {
            int userId = sa.getUserId();
            // Calculate day index: 0=Monday, 6=Sunday
            int dayIndex = (int) (sa.getAssignedDate().toEpochDay() - weekStart.toEpochDay());

            if (dayIndex < 0 || dayIndex > 6) {
                continue; // Safety bound
            }
            matrix.computeIfAbsent(userId, k -> new HashMap<>());
            matrix.get(userId).put(dayIndex, sa);
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
        ShiftAssignment todayAssignment = assignmentDAO.getByUserAndDate(userId, swipeDate);

        if (todayAssignment == null) {
            // Check if there's a PREVIOUS day's night shift that ends today
            ShiftAssignment yesterdayAssignment = assignmentDAO.getByUserAndDate(userId, swipeDate.minusDays(1));
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
