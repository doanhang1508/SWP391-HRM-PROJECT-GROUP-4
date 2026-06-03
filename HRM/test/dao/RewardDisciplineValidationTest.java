package dao;

import model.EmployeeRewardDiscipline;
import java.math.BigDecimal;
import java.sql.Date;
import org.junit.Test;
import static org.junit.Assert.*;

/**
 * Unit Test cho hàm EmployeeRewardDiscipline.validate()
 * KHÔNG cần Database, KHÔNG cần chạy server.
 * Chỉ cần file EmployeeRewardDiscipline.java và thư viện JUnit 4.
 */
public class RewardDisciplineValidationTest {

    // ==========================================
    // CONDITION 1: Dữ liệu hợp lệ -> kỳ vọng validate() trả về null
    // ==========================================

    @Test
    public void TC01_ValidReward_WithAmount() {
        EmployeeRewardDiscipline r = new EmployeeRewardDiscipline();
        r.setUserId(2);
        r.setRewardDisciplineId(1);
        r.setAmount(new BigDecimal("500000"));
        r.setNote("Thưởng hoàn thành dự án");
        r.setAppliedDate(Date.valueOf("2026-06-01"));
        assertNull("Thưởng hợp lệ phải trả null", EmployeeRewardDiscipline.validate(r));
    }

    @Test
    public void TC02_ValidDiscipline_ZeroAmount() {
        EmployeeRewardDiscipline r = new EmployeeRewardDiscipline();
        r.setUserId(3);
        r.setRewardDisciplineId(2);
        r.setAmount(BigDecimal.ZERO); // Kỷ luật cảnh cáo, không trừ tiền
        r.setNote("Cảnh cáo đi muộn");
        r.setAppliedDate(Date.valueOf("2026-06-01"));
        assertNull("Kỷ luật 0đ hợp lệ phải trả null", EmployeeRewardDiscipline.validate(r));
    }

    // ==========================================
    // CONDITION 2: Thiếu dữ liệu bắt buộc
    // ==========================================

    @Test
    public void TC03_NullAmount_ShouldReturnError() {
        EmployeeRewardDiscipline r = new EmployeeRewardDiscipline();
        r.setUserId(2);
        r.setRewardDisciplineId(1);
        r.setAmount(null);
        r.setNote("Test");
        r.setAppliedDate(Date.valueOf("2026-06-01"));
        assertNotNull("Amount null phải báo lỗi", EmployeeRewardDiscipline.validate(r));
    }

    @Test
    public void TC04_NullNote_ShouldReturnError() {
        EmployeeRewardDiscipline r = new EmployeeRewardDiscipline();
        r.setUserId(2);
        r.setRewardDisciplineId(1);
        r.setAmount(new BigDecimal("500000"));
        r.setNote(null);
        r.setAppliedDate(Date.valueOf("2026-06-01"));
        assertNotNull("Note null phải báo lỗi", EmployeeRewardDiscipline.validate(r));
    }

    @Test
    public void TC05_EmptyNote_ShouldReturnError() {
        EmployeeRewardDiscipline r = new EmployeeRewardDiscipline();
        r.setUserId(2);
        r.setRewardDisciplineId(1);
        r.setAmount(new BigDecimal("500000"));
        r.setNote("   "); // Chỉ có dấu cách
        r.setAppliedDate(Date.valueOf("2026-06-01"));
        assertNotNull("Note rỗng phải báo lỗi", EmployeeRewardDiscipline.validate(r));
    }

    @Test
    public void TC06_NullAppliedDate_ShouldReturnError() {
        EmployeeRewardDiscipline r = new EmployeeRewardDiscipline();
        r.setUserId(2);
        r.setRewardDisciplineId(1);
        r.setAmount(new BigDecimal("500000"));
        r.setNote("Test");
        r.setAppliedDate(null);
        assertNotNull("AppliedDate null phải báo lỗi", EmployeeRewardDiscipline.validate(r));
    }

    // ==========================================
    // CONDITION 3: Dữ liệu sai logic
    // ==========================================

    @Test
    public void TC07_InvalidUserId_ShouldReturnError() {
        EmployeeRewardDiscipline r = new EmployeeRewardDiscipline();
        r.setUserId(0); // UserId = 0 không hợp lệ
        r.setRewardDisciplineId(1);
        r.setAmount(new BigDecimal("500000"));
        r.setNote("Test");
        r.setAppliedDate(Date.valueOf("2026-06-01"));
        assertNotNull("UserId = 0 phải báo lỗi", EmployeeRewardDiscipline.validate(r));
    }

    @Test
    public void TC08_InvalidRewardId_ShouldReturnError() {
        EmployeeRewardDiscipline r = new EmployeeRewardDiscipline();
        r.setUserId(2);
        r.setRewardDisciplineId(-1); // ID loại không hợp lệ
        r.setAmount(new BigDecimal("500000"));
        r.setNote("Test");
        r.setAppliedDate(Date.valueOf("2026-06-01"));
        assertNotNull("RewardDisciplineId âm phải báo lỗi", EmployeeRewardDiscipline.validate(r));
    }

    @Test
    public void TC09_NegativeAmount_ShouldReturnError() {
        EmployeeRewardDiscipline r = new EmployeeRewardDiscipline();
        r.setUserId(2);
        r.setRewardDisciplineId(1);
        r.setAmount(new BigDecimal("-100000")); // Số tiền âm
        r.setNote("Test");
        r.setAppliedDate(Date.valueOf("2026-06-01"));
        assertNotNull("Amount âm phải báo lỗi", EmployeeRewardDiscipline.validate(r));
    }

    @Test
    public void TC10_NullObject_ShouldReturnError() {
        // Trường hợp object null hoàn toàn
        assertNotNull("Object null phải báo lỗi", EmployeeRewardDiscipline.validate(null));
    }
}
