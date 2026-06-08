package dao;

import model.LeaveRequest;
import java.sql.Date;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

/**
 * Unit Test cho hàm LeaveRequest.validate()
 * KHÔNG cần Database, KHÔNG cần chạy server.
 * Chỉ cần file LeaveRequest.java và thư viện JUnit 4.
 */
public class LeaveRequestValidationTest {

    // ==========================================
    // CONDITION 1: Dữ liệu hợp lệ -> kỳ vọng validate() trả về null
    // ==========================================

    @Test
    public void TC01_ValidLeaveRequest_MultipleDays() {
        LeaveRequest r = new LeaveRequest();
        r.setUserId(2);
        r.setLeaveTypeId(1);
        r.setStartDate(Date.valueOf("2026-06-10"));
        r.setEndDate(Date.valueOf("2026-06-12"));
        r.setTotalDays(3.0);
        r.setReason("Nghỉ ốm");
        assertNull(LeaveRequest.validate(r), "Dữ liệu hợp lệ phải trả null");
    }

    @Test
    public void TC02_ValidLeaveRequest_SingleDay() {
        LeaveRequest r = new LeaveRequest();
        r.setUserId(5);
        r.setLeaveTypeId(2);
        r.setStartDate(Date.valueOf("2026-07-01"));
        r.setEndDate(Date.valueOf("2026-07-01")); // Nghỉ đúng 1 ngày
        r.setTotalDays(1.0);
        r.setReason("Việc gia đình");
        assertNull(LeaveRequest.validate(r), "Nghỉ 1 ngày hợp lệ phải trả null");
    }

    // ==========================================
    // CONDITION 2: Thiếu dữ liệu bắt buộc
    // ==========================================

    @Test
    public void TC03_NullStartDate_ShouldReturnError() {
        LeaveRequest r = new LeaveRequest();
        r.setUserId(2);
        r.setLeaveTypeId(1);
        r.setStartDate(null); // Thiếu ngày bắt đầu
        r.setEndDate(Date.valueOf("2026-06-12"));
        r.setTotalDays(3.0);
        r.setReason("Test");
        assertNotNull(LeaveRequest.validate(r), "StartDate null phải báo lỗi");
    }

    @Test
    public void TC04_NullEndDate_ShouldReturnError() {
        LeaveRequest r = new LeaveRequest();
        r.setUserId(2);
        r.setLeaveTypeId(1);
        r.setStartDate(Date.valueOf("2026-06-10"));
        r.setEndDate(null); // Thiếu ngày kết thúc
        r.setTotalDays(3.0);
        r.setReason("Test");
        assertNotNull(LeaveRequest.validate(r), "EndDate null phải báo lỗi");
    }

    @Test
    public void TC05_EmptyReason_ShouldReturnError() {
        LeaveRequest r = new LeaveRequest();
        r.setUserId(2);
        r.setLeaveTypeId(1);
        r.setStartDate(Date.valueOf("2026-06-10"));
        r.setEndDate(Date.valueOf("2026-06-12"));
        r.setTotalDays(3.0);
        r.setReason(""); // Lý do rỗng
        assertNotNull(LeaveRequest.validate(r), "Reason rỗng phải báo lỗi");
    }

    @Test
    public void TC06_NullReason_ShouldReturnError() {
        LeaveRequest r = new LeaveRequest();
        r.setUserId(2);
        r.setLeaveTypeId(1);
        r.setStartDate(Date.valueOf("2026-06-10"));
        r.setEndDate(Date.valueOf("2026-06-12"));
        r.setTotalDays(3.0);
        r.setReason(null);
        assertNotNull(LeaveRequest.validate(r), "Reason null phải báo lỗi");
    }

    // ==========================================
    // CONDITION 3: Dữ liệu sai logic
    // ==========================================

    @Test
    public void TC07_InvalidUserId_ShouldReturnError() {
        LeaveRequest r = new LeaveRequest();
        r.setUserId(0); // UserId = 0 là không hợp lệ
        r.setLeaveTypeId(1);
        r.setStartDate(Date.valueOf("2026-06-10"));
        r.setEndDate(Date.valueOf("2026-06-12"));
        r.setTotalDays(3.0);
        r.setReason("Test");
        assertNotNull(LeaveRequest.validate(r), "UserId <= 0 phải báo lỗi");
    }

    @Test
    public void TC08_StartDateAfterEndDate_ShouldReturnError() {
        LeaveRequest r = new LeaveRequest();
        r.setUserId(2);
        r.setLeaveTypeId(1);
        r.setStartDate(Date.valueOf("2026-06-20")); // Ngày BĐ sau ngày KT
        r.setEndDate(Date.valueOf("2026-06-10"));
        r.setTotalDays(3.0);
        r.setReason("Lỗi logic ngày");
        assertNotNull(LeaveRequest.validate(r), "StartDate > EndDate phải báo lỗi");
    }

    @Test
    public void TC09_NegativeTotalDays_ShouldReturnError() {
        LeaveRequest r = new LeaveRequest();
        r.setUserId(2);
        r.setLeaveTypeId(1);
        r.setStartDate(Date.valueOf("2026-06-10"));
        r.setEndDate(Date.valueOf("2026-06-12"));
        r.setTotalDays(-1.0); // Số ngày âm
        r.setReason("Test");
        assertNotNull(LeaveRequest.validate(r), "TotalDays âm phải báo lỗi");
    }

    @Test
    public void TC10_InvalidLeaveTypeId_ShouldReturnError() {
        LeaveRequest r = new LeaveRequest();
        r.setUserId(2);
        r.setLeaveTypeId(-5); // ID loại nghỉ phép không hợp lệ
        r.setStartDate(Date.valueOf("2026-06-10"));
        r.setEndDate(Date.valueOf("2026-06-12"));
        r.setTotalDays(3.0);
        r.setReason("Test");
        assertNotNull(LeaveRequest.validate(r), "LeaveTypeId <= 0 phải báo lỗi");
    }
}

