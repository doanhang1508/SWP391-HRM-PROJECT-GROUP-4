package service;

import model.ShiftAssignment;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Map;

/**
 * ShiftAssignmentService — Scheduling coordinator interface. Handles assigning
 * shifts to employees and resolving clock-in ambiguity.
 */
public interface ShiftAssignmentService {

    // ── CRUD & Query ──
    List<ShiftAssignment> getByDateRange(LocalDate from, LocalDate to);

    List<ShiftAssignment> getByUserAndDateRange(int userId, LocalDate from, LocalDate to);

    ShiftAssignment getByUserAndDate(int userId, LocalDate date);

    boolean addAssignment(ShiftAssignment assignment);

    int batchAssign(int userId, int shiftId, LocalDate from, LocalDate to);

    boolean updateAssignment(int assignmentId, int newShiftId);

    boolean deleteAssignment(int assignmentId);

    // ── Schedule Dashboard ──
    /**
     * Build a weekly schedule matrix for the dashboard. Returns a map: userId →
     * (Map of dayOfWeek-index → ShiftAssignment). The outer map is keyed by
     * userId; inner map has 7 entries (Mon=0..Sun=6).
     *
     * @param weekStart the Monday of the target week.
     */
    Map<Integer, Map<Integer, ShiftAssignment>> buildWeeklyScheduleMatrix(LocalDate weekStart);

    // ── Next-Shift Clock-In Filter ──
    /**
     * Resolve clock-in/out ambiguity at shift boundaries.
     *
     * Scenario: At 13:55, Factory Shift 1 ends (14:00) and Shift 2 starts
     * (14:00). When a card swipe occurs, this method checks the user's
     * assignment for the given date to determine the correct interpretation.
     *
     * @param userId the employee who swiped.
     * @param swipeTime the actual clock timestamp.
     * @param swipeDate the date of the swipe.
     * @return "CHECK_OUT" if this swipe is an end-of-shift-1 checkout,
     * "CHECK_IN" if this is a start-of-shift-2 check-in, "UNKNOWN" if no
     * assignment found.
     */
    String resolveSwipeIntent(int userId, LocalTime swipeTime, LocalDate swipeDate);
}
