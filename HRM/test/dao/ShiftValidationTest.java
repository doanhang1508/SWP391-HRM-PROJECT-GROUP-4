package dao;

import model.Shift;
import java.time.LocalTime;
import org.junit.Test;
import static org.junit.Assert.*;

/**
 * Unit Test cho hàm Shift.validate()
 * KHÔNG cần Database, KHÔNG cần chạy server.
 * Chỉ cần file Shift.java và thư viện JUnit 4.
 */
public class ShiftValidationTest {

    // ==========================================
    // CONDITION 1: Dữ liệu hợp lệ -> kỳ vọng validate() trả về null
    // ==========================================

    @Test
    public void TC01_ValidShift_NoBreak() {
        Shift s = new Shift();
        s.setShiftName("Ca Sáng");
        s.setStartTime(LocalTime.of(8, 0));
        s.setEndTime(LocalTime.of(12, 0));
        s.setCoefficient(1.0f);
        s.setNightShift(false);
        assertNull("Ca làm không có giờ nghỉ hợp lệ phải trả null", Shift.validate(s));
    }

    @Test
    public void TC02_ValidShift_WithBreak() {
        Shift s = new Shift();
        s.setShiftName("Ca Hành Chính");
        s.setStartTime(LocalTime.of(8, 0));
        s.setEndTime(LocalTime.of(17, 0));
        s.setBreakStart(LocalTime.of(12, 0));
        s.setBreakEnd(LocalTime.of(13, 0));
        s.setCoefficient(1.0f);
        s.setNightShift(false);
        assertNull("Ca có giờ nghỉ hợp lệ phải trả null", Shift.validate(s));
    }

    // ==========================================
    // CONDITION 2: Thiếu dữ liệu bắt buộc
    // ==========================================

    @Test
    public void TC03_NullShiftName_ShouldReturnError() {
        Shift s = new Shift();
        s.setShiftName(null);
        s.setStartTime(LocalTime.of(8, 0));
        s.setEndTime(LocalTime.of(12, 0));
        s.setCoefficient(1.0f);
        assertNotNull("ShiftName null phải báo lỗi", Shift.validate(s));
    }

    @Test
    public void TC04_EmptyShiftName_ShouldReturnError() {
        Shift s = new Shift();
        s.setShiftName("   "); // Chỉ có dấu cách
        s.setStartTime(LocalTime.of(8, 0));
        s.setEndTime(LocalTime.of(12, 0));
        s.setCoefficient(1.0f);
        assertNotNull("ShiftName rỗng phải báo lỗi", Shift.validate(s));
    }

    @Test
    public void TC05_NullStartTime_ShouldReturnError() {
        Shift s = new Shift();
        s.setShiftName("Ca Test");
        s.setStartTime(null);
        s.setEndTime(LocalTime.of(12, 0));
        s.setCoefficient(1.0f);
        assertNotNull("StartTime null phải báo lỗi", Shift.validate(s));
    }

    @Test
    public void TC06_NullEndTime_ShouldReturnError() {
        Shift s = new Shift();
        s.setShiftName("Ca Test");
        s.setStartTime(LocalTime.of(8, 0));
        s.setEndTime(null);
        s.setCoefficient(1.0f);
        assertNotNull("EndTime null phải báo lỗi", Shift.validate(s));
    }

    // ==========================================
    // CONDITION 3: Dữ liệu sai logic
    // ==========================================

    @Test
    public void TC07_StartTimeAfterEndTime_ShouldReturnError() {
        Shift s = new Shift();
        s.setShiftName("Ca Lỗi");
        s.setStartTime(LocalTime.of(17, 0)); // BĐ sau KT
        s.setEndTime(LocalTime.of(8, 0));
        s.setCoefficient(1.0f);
        s.setNightShift(false);
        assertNotNull("StartTime > EndTime phải báo lỗi", Shift.validate(s));
    }

    @Test
    public void TC08_NegativeCoefficient_ShouldReturnError() {
        Shift s = new Shift();
        s.setShiftName("Ca Lỗi Hệ Số");
        s.setStartTime(LocalTime.of(8, 0));
        s.setEndTime(LocalTime.of(12, 0));
        s.setCoefficient(-1.5f); // Hệ số âm
        assertNotNull("Coefficient âm phải báo lỗi", Shift.validate(s));
    }

    @Test
    public void TC09_BreakOutsideShift_ShouldReturnError() {
        Shift s = new Shift();
        s.setShiftName("Ca Lỗi Break");
        s.setStartTime(LocalTime.of(8, 0));
        s.setEndTime(LocalTime.of(12, 0));
        s.setBreakStart(LocalTime.of(13, 0)); // Giờ nghỉ nằm ngoài ca làm
        s.setBreakEnd(LocalTime.of(14, 0));
        s.setCoefficient(1.0f);
        assertNotNull("Break nằm ngoài ca làm phải báo lỗi", Shift.validate(s));
    }

    @Test
    public void TC10_BreakStartAfterBreakEnd_ShouldReturnError() {
        Shift s = new Shift();
        s.setShiftName("Ca Lỗi Break 2");
        s.setStartTime(LocalTime.of(8, 0));
        s.setEndTime(LocalTime.of(17, 0));
        s.setBreakStart(LocalTime.of(14, 0)); // Giờ bắt đầu nghỉ sau giờ kết thúc nghỉ
        s.setBreakEnd(LocalTime.of(12, 0));
        s.setCoefficient(1.0f);
        assertNotNull("BreakStart > BreakEnd phải báo lỗi", Shift.validate(s));
    }
}
