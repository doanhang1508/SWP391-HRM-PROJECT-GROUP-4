package dao;

import model.ShiftAssignment;
import java.util.Map;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import model.Shift;
import java.time.LocalDate;
import java.time.LocalTime;

/**
 * ShiftAssignmentDAO — Data Access interface for `shift_assignments`.
 * Supports batch scheduling and weekly/monthly calendar queries.
 */
public interface ShiftAssignmentDAO {

    /**
     * Get all assignments for a user within a date range.
     */
    List<ShiftAssignment> getByUserAndDateRange(int userId, LocalDate from, LocalDate to);

    /**
     * Get all assignments for a given date range (all users), with JOIN data.
     * Used for the weekly schedule dashboard.
     */
    List<ShiftAssignment> getByDateRange(LocalDate from, LocalDate to);

    /**
     * Get the specific assignment for a user on a specific date.
     * @return the assignment, or null if not scheduled.
     */
    ShiftAssignment getByUserAndDate(int userId, LocalDate date);

    /**
     * Insert a single assignment. Uses INSERT IGNORE to respect UNIQUE(user_id, assigned_date).
     * @return true if a row was inserted (not a duplicate).
     */
    boolean addAssignment(ShiftAssignment assignment);

    /**
     * Batch-insert assignments for a user across a date range (e.g. weekly/monthly scheduling).
     * Skips dates that already have an assignment for the user.
     * @return number of rows actually inserted.
     */
    int batchAssign(int userId, int shiftId, LocalDate from, LocalDate to);

    /**
     * Batch-insert assignments for a user across a date range, exclusively for weekdays (Monday to Friday).
     * @return number of rows actually inserted.
     */
    int batchAssignWeekdays(int userId, int shiftId, LocalDate from, LocalDate to);

    /**
     * Update the shift for an existing assignment.
     */
    boolean updateAssignment(int assignmentId, int newShiftId);

    /**
     * Delete an assignment by its primary key.
     */
    boolean deleteAssignment(int assignmentId);

    /**
     * Delete all assignments for a user on a specific date.
     */
    boolean deleteByUserAndDate(int userId, LocalDate date);

    Map<Integer, Map<Integer, List<ShiftAssignment>>> buildWeeklyScheduleMatrix(LocalDate weekStart);
    String resolveSwipeIntent(int userId, LocalTime swipeTime, LocalDate swipeDate);
}


