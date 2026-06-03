package model;

import java.time.LocalTime;

/**
 * Shift Entity — maps to the `shifts` table (v2 schema).
 * Pure data carrier: only attributes, constructors, getters, setters.
 * All business logic resides in the Service layer.
 *
 * Schema: shift_id, shift_name, start_time, end_time,
 *         break_start, break_end, is_night_shift, coefficient, status
 */
public class Shift {

    private int shiftId;
    private String shiftName;
    private LocalTime startTime;
    private LocalTime endTime;
    private LocalTime breakStart;   // nullable
    private LocalTime breakEnd;     // nullable
    private boolean nightShift;     // BIT column: is_night_shift
    private float coefficient;      // salary multiplier (e.g. 1.0, 1.3, 1.5)
    private int status;             // 1 = active, 0 = inactive

    // ── No-arg constructor ──
    public Shift() {
        this.coefficient = 1.0f;
        this.status = 1;
    }

    // ── Full-arg constructor ──
    public Shift(int shiftId, String shiftName, LocalTime startTime, LocalTime endTime,
                 LocalTime breakStart, LocalTime breakEnd, boolean nightShift,
                 float coefficient, int status) {
        this.shiftId = shiftId;
        this.shiftName = shiftName;
        this.startTime = startTime;
        this.endTime = endTime;
        this.breakStart = breakStart;
        this.breakEnd = breakEnd;
        this.nightShift = nightShift;
        this.coefficient = coefficient;
        this.status = status;
    }

    // ── Getters & Setters ──

    public int getShiftId() { return shiftId; }
    public void setShiftId(int shiftId) { this.shiftId = shiftId; }

    public String getShiftName() { return shiftName; }
    public void setShiftName(String shiftName) { this.shiftName = shiftName; }

    public LocalTime getStartTime() { return startTime; }
    public void setStartTime(LocalTime startTime) { this.startTime = startTime; }

    public LocalTime getEndTime() { return endTime; }
    public void setEndTime(LocalTime endTime) { this.endTime = endTime; }

    public LocalTime getBreakStart() { return breakStart; }
    public void setBreakStart(LocalTime breakStart) { this.breakStart = breakStart; }

    public LocalTime getBreakEnd() { return breakEnd; }
    public void setBreakEnd(LocalTime breakEnd) { this.breakEnd = breakEnd; }

    public boolean isNightShift() { return nightShift; }
    public void setNightShift(boolean nightShift) { this.nightShift = nightShift; }

    public float getCoefficient() { return coefficient; }
    public void setCoefficient(float coefficient) { this.coefficient = coefficient; }

    public int getStatus() { return status; }
    public void setStatus(int status) { this.status = status; }

    /**
     * Kiểm tra dữ liệu ca làm việc hợp lệ.
     * Thuần Java, không cần Database.
     */
    public static String validate(Shift s) {
        if (s == null) return "Shift không được null";
        if (s.getShiftName() == null || s.getShiftName().trim().isEmpty())
            return "Tên ca làm việc không được để trống";
        if (s.getStartTime() == null)
            return "Giờ bắt đầu không được để trống";
        if (s.getEndTime() == null)
            return "Giờ kết thúc không được để trống";
        if (!s.isNightShift() && !s.getStartTime().isBefore(s.getEndTime()))
            return "Giờ bắt đầu phải trước giờ kết thúc (ca không phải ca đêm)";
        if (s.getCoefficient() <= 0)
            return "Hệ số lương phải lớn hơn 0";
        if (s.getBreakStart() != null && s.getBreakEnd() != null) {
            if (!s.getBreakStart().isBefore(s.getBreakEnd()))
                return "Giờ bắt đầu nghỉ phải trước giờ kết thúc nghỉ";
            if (s.getBreakStart().isBefore(s.getStartTime()) || s.getBreakEnd().isAfter(s.getEndTime()))
                return "Giờ nghỉ phải nằm trong khoảng thời gian ca làm";
        }
        return null; // null = hợp lệ
    }
}
