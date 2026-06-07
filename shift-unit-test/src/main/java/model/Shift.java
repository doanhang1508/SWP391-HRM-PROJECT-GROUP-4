package model;

import java.time.LocalTime;

/**
 * Shift Entity — maps to the `shifts` table.
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
     *
     * ===================== PHIÊN BẢN ĐÃ FIX (AFTER FIX) =====================
     * FIX 1: Thêm .trim() khi kiểm tra tên ca → bắt được tên chỉ có khoảng trắng
     * FIX 2: Đổi điều kiện thành !isBefore() → bắt cả trường hợp start == end
     * FIX 3: Thêm lại kiểm tra coefficient <= 0
     * =========================================================================
     */
    
    public static String validate(Shift s) {
        if (s == null) return "Shift không được null";

        // FIX 1: Thêm .trim() để bắt tên chỉ có khoảng trắng
        if (s.getShiftName() == null || s.getShiftName().trim().isEmpty())
            return "Tên ca làm việc không được để trống";

        if (s.getStartTime() == null)
            return "Giờ bắt đầu không được để trống";
        if (s.getEndTime() == null)
            return "Giờ kết thúc không được để trống";

        // FIX 2: Dùng !isBefore() thay vì isBefore() → bắt cả start == end
        if (!s.isNightShift() && !s.getStartTime().isBefore(s.getEndTime()))
            return "Giờ bắt đầu phải trước giờ kết thúc (ca không phải ca đêm)";

        // FIX 3: Khôi phục kiểm tra hệ số lương
        if (s.getCoefficient() <= 0)
            return "Hệ số lương phải lớn hơn 0";

        return null; // null = hợp lệ
    }

    
    /*
    public static String validate(Shift s) {
    if (s == null) return "Shift không được null";

    // BUG 1: Thiếu phương thức .trim() -> Không bắt được trường hợp chuỗi chỉ có khoảng trắng "   "
    if (s.getShiftName() == null || s.getShiftName().isEmpty())
        return "Tên ca làm việc không được để trống";

    if (s.getStartTime() == null) return "Giờ bắt đầu không được để trống";
    if (s.getEndTime() == null) return "Giờ kết thúc không được để trống";

    // BUG 2: Điều kiện logic sai -> Không phát hiện được lỗi khi giờ bắt đầu trùng giờ kết thúc (start == end)
    if (!s.isNightShift() && s.getEndTime().isBefore(s.getStartTime()))
        return "Giờ bắt đầu phải trước giờ kết thúc (ca không phải ca đêm)";

    // BUG 3: Dòng lệnh kiểm tra hệ số lương bị thiếu/xóa -> Không chặn được hệ số <= 0
    // if (s.getCoefficient() <= 0) return "Hệ số lương phải lớn hơn 0";

    return null;
}
*/

    
}
