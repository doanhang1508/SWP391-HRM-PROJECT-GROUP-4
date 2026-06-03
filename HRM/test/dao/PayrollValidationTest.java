package dao;

import model.Payroll;
import java.math.BigDecimal;
import org.junit.Test;
import static org.junit.Assert.*;

/**
 * Unit Test cho hàm Payroll.validate()
 * KHÔNG cần Database, KHÔNG cần chạy server.
 * Chỉ cần file Payroll.java và thư viện JUnit 4.
 */
public class PayrollValidationTest {

    // ==========================================
    // CONDITION 1: Dữ liệu hợp lệ -> kỳ vọng validate() trả về null
    // ==========================================

    @Test
    public void TC01_ValidPayroll_Normal() {
        Payroll p = new Payroll();
        p.setUserId(2);
        p.setMonth(6);
        p.setYear(2026);
        p.setBaseSalary(new BigDecimal("10000000"));
        p.setBonusAmount(new BigDecimal("2000000"));
        p.setDeductionAmount(new BigDecimal("500000"));
        p.setNetSalary(new BigDecimal("11500000"));
        assertNull("Payroll hợp lệ phải trả null", Payroll.validate(p));
    }

    @Test
    public void TC02_ValidPayroll_ZeroBonusAndDeduction() {
        Payroll p = new Payroll();
        p.setUserId(3);
        p.setMonth(12);
        p.setYear(2026);
        p.setBaseSalary(new BigDecimal("8000000"));
        p.setBonusAmount(BigDecimal.ZERO); // Không thưởng
        p.setDeductionAmount(BigDecimal.ZERO); // Không trừ
        p.setNetSalary(new BigDecimal("8000000"));
        assertNull("Payroll không thưởng/trừ hợp lệ phải trả null", Payroll.validate(p));
    }

    // ==========================================
    // CONDITION 2: Thiếu dữ liệu bắt buộc
    // ==========================================

    @Test
    public void TC03_NullBaseSalary_ShouldReturnError() {
        Payroll p = new Payroll();
        p.setUserId(2);
        p.setMonth(6);
        p.setYear(2026);
        p.setBaseSalary(null); // Thiếu lương cơ bản
        p.setBonusAmount(BigDecimal.ZERO);
        p.setDeductionAmount(BigDecimal.ZERO);
        assertNotNull("BaseSalary null phải báo lỗi", Payroll.validate(p));
    }

    @Test
    public void TC04_NullBonusAmount_ShouldReturnError() {
        Payroll p = new Payroll();
        p.setUserId(2);
        p.setMonth(6);
        p.setYear(2026);
        p.setBaseSalary(new BigDecimal("10000000"));
        p.setBonusAmount(null); // Thiếu tiền thưởng
        p.setDeductionAmount(BigDecimal.ZERO);
        assertNotNull("BonusAmount null phải báo lỗi", Payroll.validate(p));
    }

    @Test
    public void TC05_NullDeductionAmount_ShouldReturnError() {
        Payroll p = new Payroll();
        p.setUserId(2);
        p.setMonth(6);
        p.setYear(2026);
        p.setBaseSalary(new BigDecimal("10000000"));
        p.setBonusAmount(BigDecimal.ZERO);
        p.setDeductionAmount(null); // Thiếu tiền khấu trừ
        assertNotNull("DeductionAmount null phải báo lỗi", Payroll.validate(p));
    }

    // ==========================================
    // CONDITION 3: Dữ liệu sai logic
    // ==========================================

    @Test
    public void TC06_InvalidMonth_Zero_ShouldReturnError() {
        Payroll p = new Payroll();
        p.setUserId(2);
        p.setMonth(0); // Tháng = 0 không tồn tại
        p.setYear(2026);
        p.setBaseSalary(new BigDecimal("10000000"));
        p.setBonusAmount(BigDecimal.ZERO);
        p.setDeductionAmount(BigDecimal.ZERO);
        assertNotNull("Month = 0 phải báo lỗi", Payroll.validate(p));
    }

    @Test
    public void TC07_InvalidMonth_13_ShouldReturnError() {
        Payroll p = new Payroll();
        p.setUserId(2);
        p.setMonth(13); // Tháng 13 không tồn tại
        p.setYear(2026);
        p.setBaseSalary(new BigDecimal("10000000"));
        p.setBonusAmount(BigDecimal.ZERO);
        p.setDeductionAmount(BigDecimal.ZERO);
        assertNotNull("Month = 13 phải báo lỗi", Payroll.validate(p));
    }

    @Test
    public void TC08_ZeroBaseSalary_ShouldReturnError() {
        Payroll p = new Payroll();
        p.setUserId(2);
        p.setMonth(6);
        p.setYear(2026);
        p.setBaseSalary(BigDecimal.ZERO); // Lương cơ bản = 0
        p.setBonusAmount(BigDecimal.ZERO);
        p.setDeductionAmount(BigDecimal.ZERO);
        assertNotNull("BaseSalary = 0 phải báo lỗi", Payroll.validate(p));
    }

    @Test
    public void TC09_NegativeNetSalary_ShouldReturnError() {
        Payroll p = new Payroll();
        p.setUserId(2);
        p.setMonth(6);
        p.setYear(2026);
        p.setBaseSalary(new BigDecimal("5000000"));
        p.setBonusAmount(BigDecimal.ZERO);
        p.setDeductionAmount(new BigDecimal("8000000")); // Trừ nhiều hơn lương
        p.setNetSalary(new BigDecimal("-3000000")); // Lương thực nhận âm
        assertNotNull("NetSalary âm phải báo lỗi", Payroll.validate(p));
    }

    @Test
    public void TC10_InvalidYear_ShouldReturnError() {
        Payroll p = new Payroll();
        p.setUserId(2);
        p.setMonth(6);
        p.setYear(1999); // Năm quá cũ, không hợp lệ
        p.setBaseSalary(new BigDecimal("10000000"));
        p.setBonusAmount(BigDecimal.ZERO);
        p.setDeductionAmount(BigDecimal.ZERO);
        assertNotNull("Year < 2000 phải báo lỗi", Payroll.validate(p));
    }
}
