package model;

import java.time.LocalDate;
import java.time.LocalTime;
import java.sql.Timestamp;

/**
 * ShiftAssignment Entity — maps to the `shift_assignments` table.
 * Pure data carrier. Represents a pre-scheduled shift for an employee on a specific date.
 *
 * Schema: assignment_id, user_id, shift_id, assigned_date, created_at
 * UNIQUE constraint on (user_id, assigned_date) — one shift per employee per day.
 */
public class ShiftAssignment {

    private int assignmentId;
    private int userId;
    private int shiftId;
    private LocalDate assignedDate;
    private Timestamp createdAt;

    // ── Transient: joined data for display (not persisted) ──
    private String userName;    // from users.full_name
    private String shiftName;   // from shifts.shift_name
    private LocalTime startTime;  // from shifts.start_time
    private LocalTime endTime;    // from shifts.end_time
    private boolean nightShift;   // from shifts.is_night_shift
    private float coefficient;    // from shifts.coefficient

    // ── No-arg constructor ──
    public ShiftAssignment() {
    }

    // ── Core constructor ──
    public ShiftAssignment(int userId, int shiftId, LocalDate assignedDate) {
        this.userId = userId;
        this.shiftId = shiftId;
        this.assignedDate = assignedDate;
    }

    // ── Full-arg constructor ──
    public ShiftAssignment(int assignmentId, int userId, int shiftId,
                           LocalDate assignedDate, Timestamp createdAt) {
        this.assignmentId = assignmentId;
        this.userId = userId;
        this.shiftId = shiftId;
        this.assignedDate = assignedDate;
        this.createdAt = createdAt;
    }

    // ── Getters & Setters ──

    public int getAssignmentId() { return assignmentId; }
    public void setAssignmentId(int assignmentId) { this.assignmentId = assignmentId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public int getShiftId() { return shiftId; }
    public void setShiftId(int shiftId) { this.shiftId = shiftId; }

    public LocalDate getAssignedDate() { return assignedDate; }
    public void setAssignedDate(LocalDate assignedDate) { this.assignedDate = assignedDate; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }

    public String getShiftName() { return shiftName; }
    public void setShiftName(String shiftName) { this.shiftName = shiftName; }

    public LocalTime getStartTime() { return startTime; }
    public void setStartTime(LocalTime startTime) { this.startTime = startTime; }

    public LocalTime getEndTime() { return endTime; }
    public void setEndTime(LocalTime endTime) { this.endTime = endTime; }

    public boolean isNightShift() { return nightShift; }
    public void setNightShift(boolean nightShift) { this.nightShift = nightShift; }

    public float getCoefficient() { return coefficient; }
    public void setCoefficient(float coefficient) { this.coefficient = coefficient; }
}
