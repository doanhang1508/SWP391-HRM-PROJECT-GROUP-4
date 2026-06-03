package dao;

import model.Attendance;
import java.sql.Date;
import org.junit.Test;
import static org.junit.Assert.*;

/**
 * Unit Test cho hàm Attendance.validateOTRequest()
 * KHÔNG cần Database, KHÔNG cần chạy server.
 * Chỉ cần file Attendance.java và thư viện JUnit 4.
 *
 * Lưu ý: Chức năng OT (làm thêm giờ) trong dự án này
 * không có bảng riêng mà lưu vào bảng attendance qua cột overtime_hrs.
 */
public class OvertimeValidationTest {

    // ==========================================
    // CONDITION 1: Dữ liệu hợp lệ -> kỳ vọng validateOTRequest() trả về null
    // ==========================================

    @Test
    public void TC01_ValidOTRequest_FullHours() {
        Attendance a = new Attendance();
        a.setUserId(2);
        a.setShiftId(1);
        a.setWorkDate(Date.valueOf("2026-06-15"));
        a.setOvertimeHrs(2.0);
        a.setOtReason("Dự án gấp deadline");
        assertNull("OT hợp lệ phải trả null", Attendance.validateOTRequest(a));
    }

    @Test
    public void TC02_ValidOTRequest_DecimalHours() {
        Attendance a = new Attendance();
        a.setUserId(5);
        a.setShiftId(2);
        a.setWorkDate(Date.valueOf("2026-06-20"));
        a.setOvertimeHrs(1.5); // 1 tiếng rưỡi
        a.setOtReason("Hỗ trợ khách hàng");
        assertNull("OT 1.5h hợp lệ phải trả null", Attendance.validateOTRequest(a));
    }

    // ==========================================
    // CONDITION 2: Thiếu dữ liệu bắt buộc
    // ==========================================

    @Test
    public void TC03_NullWorkDate_ShouldReturnError() {
        Attendance a = new Attendance();
        a.setUserId(2);
        a.setShiftId(1);
        a.setWorkDate(null); // Thiếu ngày làm
        a.setOvertimeHrs(2.0);
        a.setOtReason("Test");
        assertNotNull("WorkDate null phải báo lỗi", Attendance.validateOTRequest(a));
    }

    @Test
    public void TC04_NullReason_ShouldReturnError() {
        Attendance a = new Attendance();
        a.setUserId(2);
        a.setShiftId(1);
        a.setWorkDate(Date.valueOf("2026-06-15"));
        a.setOvertimeHrs(2.0);
        a.setOtReason(null); // Không có lý do
        assertNotNull("OtReason null phải báo lỗi", Attendance.validateOTRequest(a));
    }

    @Test
    public void TC05_EmptyReason_ShouldReturnError() {
        Attendance a = new Attendance();
        a.setUserId(2);
        a.setShiftId(1);
        a.setWorkDate(Date.valueOf("2026-06-15"));
        a.setOvertimeHrs(2.0);
        a.setOtReason("   "); // Lý do chỉ có dấu cách
        assertNotNull("OtReason rỗng phải báo lỗi", Attendance.validateOTRequest(a));
    }

    // ==========================================
    // CONDITION 3: Dữ liệu sai logic nghiệp vụ
    // ==========================================

    @Test
    public void TC06_InvalidUserId_ShouldReturnError() {
        Attendance a = new Attendance();
        a.setUserId(-1); // UserId âm
        a.setShiftId(1);
        a.setWorkDate(Date.valueOf("2026-06-15"));
        a.setOvertimeHrs(2.0);
        a.setOtReason("Test");
        assertNotNull("UserId âm phải báo lỗi", Attendance.validateOTRequest(a));
    }

    @Test
    public void TC07_InvalidShiftId_ShouldReturnError() {
        Attendance a = new Attendance();
        a.setUserId(2);
        a.setShiftId(0); // ShiftId = 0 không hợp lệ
        a.setWorkDate(Date.valueOf("2026-06-15"));
        a.setOvertimeHrs(2.0);
        a.setOtReason("Test");
        assertNotNull("ShiftId = 0 phải báo lỗi", Attendance.validateOTRequest(a));
    }

    @Test
    public void TC08_ZeroOvertimeHours_ShouldReturnError() {
        Attendance a = new Attendance();
        a.setUserId(2);
        a.setShiftId(1);
        a.setWorkDate(Date.valueOf("2026-06-15"));
        a.setOvertimeHrs(0); // OT = 0 không có nghĩa lý
        a.setOtReason("Test");
        assertNotNull("OT = 0 phải báo lỗi", Attendance.validateOTRequest(a));
    }

    @Test
    public void TC09_NegativeOvertimeHours_ShouldReturnError() {
        Attendance a = new Attendance();
        a.setUserId(2);
        a.setShiftId(1);
        a.setWorkDate(Date.valueOf("2026-06-15"));
        a.setOvertimeHrs(-3.0); // Giờ OT âm
        a.setOtReason("Test");
        assertNotNull("OT âm phải báo lỗi", Attendance.validateOTRequest(a));
    }

    @Test
    public void TC10_OvertimeHoursExceed24_ShouldReturnError() {
        Attendance a = new Attendance();
        a.setUserId(2);
        a.setShiftId(1);
        a.setWorkDate(Date.valueOf("2026-06-15"));
        a.setOvertimeHrs(25.0); // Không thể làm thêm hơn 24h/ngày
        a.setOtReason("Test");
        assertNotNull("OT > 24h phải báo lỗi", Attendance.validateOTRequest(a));
    }
}
