import org.junit.jupiter.api.*;

import java.time.LocalTime;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Unit Test: Hàm Tạo Ca Làm Việc Mới
 *
 * Hàm test: Shift.validate(Shift s)
 * Mục tiêu: 100% Statement Coverage + 100% Decision Coverage
 *
 * Hàm validate() có 6 decision:
 *   D1: s == null
 *   D2: shiftName null hoặc rỗng/khoảng trắng
 *   D3: startTime == null
 *   D4: endTime == null
 *   D5: !nightShift && !start.isBefore(end)
 *   D6: coefficient <= 0
 */
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
class ShiftValidateTest {

    // ════════════════════════════════════════════════════
    // CONDITION 1: Validate tên ca làm việc (shiftName)
    // ════════════════════════════════════════════════════

    @Test @Order(1)
    @DisplayName("TC01 - Shift object = null → lỗi [D1 = True]")
    void TC01_nullShiftObject() {
        String error = model.Shift.validate(null);
        assertNotNull(error);
        assertEquals("Shift không được null", error);
    }

    @Test @Order(2)
    @DisplayName("TC02 - shiftName = null → lỗi [D2 = True]")
    void TC02_nullShiftName() {
        model.Shift s = buildShift(null, "08:00", "17:00", false, 1.0f);
        assertNotNull(model.Shift.validate(s));
    }

    @Test @Order(3)
    @DisplayName("TC03 - shiftName = \"\" (rỗng) → lỗi [D2 = True]")
    void TC03_emptyShiftName() {
        model.Shift s = buildShift("", "08:00", "17:00", false, 1.0f);
        assertNotNull(model.Shift.validate(s));
    }

    @Test @Order(4)
    @DisplayName("TC04 - shiftName = \"   \" (khoảng trắng) → lỗi [D2 = True]")
    void TC04_blankShiftName() {
        model.Shift s = buildShift("   ", "08:00", "17:00", false, 1.0f);
        assertNotNull(model.Shift.validate(s));
    }

    // ════════════════════════════════════════════════════
    // CONDITION 2: Validate thời gian và hệ số lương
    // ════════════════════════════════════════════════════

    @Test @Order(5)
    @DisplayName("TC05 - startTime = null → lỗi [D3 = True]")
    void TC05_nullStartTime() {
        model.Shift s = buildShift("Ca Test", null, "17:00", false, 1.0f);
        String error = model.Shift.validate(s);
        assertNotNull(error);
        assertEquals("Giờ bắt đầu không được để trống", error);
    }

    @Test @Order(6)
    @DisplayName("TC06 - endTime = null → lỗi [D4 = True]")
    void TC06_nullEndTime() {
        model.Shift s = buildShift("Ca Test", "08:00", null, false, 1.0f);
        String error = model.Shift.validate(s);
        assertNotNull(error);
        assertEquals("Giờ kết thúc không được để trống", error);
    }

    @Test @Order(7)
    @DisplayName("TC07 - Ca ngày: end < start (17:00→08:00) → lỗi [D5 = True]")
    void TC07_dayShift_endBeforeStart() {
        model.Shift s = buildShift("Ca Test", "17:00", "08:00", false, 1.0f);
        String error = model.Shift.validate(s);
        assertNotNull(error);
        assertTrue(error.contains("Giờ bắt đầu phải trước"));
    }

    @Test @Order(8)
    @DisplayName("TC08 - Ca ngày: start == end (08:00→08:00) → lỗi [D5 = True, biên]")
    void TC08_dayShift_startEqualsEnd() {
        model.Shift s = buildShift("Ca Test", "08:00", "08:00", false, 1.0f);
        assertNotNull(model.Shift.validate(s));
    }

    @Test @Order(9)
    @DisplayName("TC09 - coefficient = 0.0 → lỗi [D6 = True, biên]")
    void TC09_zeroCoefficient() {
        model.Shift s = buildShift("Ca Test", "08:00", "17:00", false, 0.0f);
        String error = model.Shift.validate(s);
        assertNotNull(error);
        assertTrue(error.contains("Hệ số lương"));
    }

    @Test @Order(10)
    @DisplayName("TC10 - coefficient = -1.0 (âm) → lỗi [D6 = True]")
    void TC10_negativeCoefficient() {
        model.Shift s = buildShift("Ca Test", "08:00", "17:00", false, -1.0f);
        assertNotNull(model.Shift.validate(s));
    }

    @Test @Order(11)
    @DisplayName("TC11 - isNightShift = true → bỏ qua check thứ tự giờ [D5 = False]")
    void TC11_nightShiftFlag_skipTimeCheck() {
        // 22:00 → 06:00 bình thường báo lỗi nếu ca ngày
        // nhưng vì isNightShift=true → D5 = False → không lỗi
        model.Shift s = buildShift("Ca Đêm", "22:00", "06:00", true, 1.5f);
        assertNull(model.Shift.validate(s));
    }

    // ════════════════════════════════════════════════════
    // CONDITION 3: Ca hợp lệ (tất cả decisions = False)
    // ════════════════════════════════════════════════════

    @Test @Order(12)
    @DisplayName("TC12 - Ca ngày hợp lệ hoàn toàn → validate trả null [All D = False]")
    void TC12_validDayShift_returnsNull() {
        // D1=F, D2=F, D3=F, D4=F, D5=F (08:00<17:00), D6=F (1.0>0) → null
        model.Shift s = buildShift("Ca Sáng", "08:00", "17:00", false, 1.0f);
        assertNull(model.Shift.validate(s));
    }

    @Test @Order(13)
    @DisplayName("TC13 - Ca đêm hợp lệ hoàn toàn → validate trả null")
    void TC13_validNightShift_returnsNull() {
        model.Shift s = buildShift("Ca Đêm Chuẩn", "22:00", "06:00", true, 1.3f);
        assertNull(model.Shift.validate(s));
    }

    @Test @Order(14)
    @DisplayName("TC14 - coefficient = 0.01 (dương tối thiểu, biên trên) → hợp lệ")
    void TC14_minPositiveCoefficient_valid() {
        model.Shift s = buildShift("Ca Test", "08:00", "17:00", false, 0.01f);
        assertNull(model.Shift.validate(s));
    }

    @Test @Order(15)
    @DisplayName("TC15 - Ca hành chính chuẩn (08:00→17:30) → hợp lệ [D2 = False path]")
    void TC15_standardOfficeShift_valid() {
        model.Shift s = buildShift("Ca Hành Chính", "08:00", "17:30", false, 1.0f);
        assertNull(model.Shift.validate(s));
    }

    // ════════════════════════════════════════════════════
    // Helper
    // ════════════════════════════════════════════════════

    private model.Shift buildShift(String name, String start, String end,
                                    boolean isNight, float coefficient) {
        model.Shift s = new model.Shift();
        s.setShiftName(name);
        s.setStartTime(start != null ? LocalTime.parse(start) : null);
        s.setEndTime(end != null ? LocalTime.parse(end) : null);
        s.setNightShift(isNight);
        s.setCoefficient(coefficient);
        return s;
    }
}
