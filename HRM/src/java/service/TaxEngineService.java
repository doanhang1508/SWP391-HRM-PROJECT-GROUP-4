package service;

import dao.EmployeeTaxProfileDAO;
import dao.PayrollDAO;
import dao.TaxBracketDAO;
import dao.TaxDeductionDAO;
import dao.AuditLogDAO;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Date;
import java.util.List;
import model.EmployeeTaxProfile;
import model.Payroll;

/**
 * TaxEngineService - Lõi tính thuế TNCN lũy tiến.
 *
 * Pipeline:
 *   Gross Income
 *   → Trừ Bảo hiểm (BHXH + BHYT + BHTN)
 *   → Trừ Giảm trừ bản thân (11,000,000)
 *   → Trừ Giảm trừ NPT (dependent_count × 4,400,000)
 *   → Taxable Income
 *   → Progressive PIT theo 7 bậc
 *   → Làm tròn HALF_UP
 *   → Net Salary = Gross - Insurance - PIT - Other Deductions
 */
public class TaxEngineService {

    private final TaxBracketDAO bracketDAO = new TaxBracketDAO();
    private final TaxDeductionDAO deductionDAO = new TaxDeductionDAO();
    private final EmployeeTaxProfileDAO taxProfileDAO = new EmployeeTaxProfileDAO();
    private final PayrollDAO payrollDAO = new PayrollDAO();
    private final AuditLogDAO auditDAO = new AuditLogDAO();

    /**
     * Kết quả tính thuế chi tiết cho 1 nhân viên.
     */
    public static class TaxResult {
        public BigDecimal grossIncome = BigDecimal.ZERO;
        public BigDecimal insuranceAmount = BigDecimal.ZERO;
        public BigDecimal personalDeduction = BigDecimal.ZERO;
        public BigDecimal dependentDeduction = BigDecimal.ZERO;
        public BigDecimal totalDeduction = BigDecimal.ZERO;
        public BigDecimal taxableIncome = BigDecimal.ZERO;
        public BigDecimal pitAmount = BigDecimal.ZERO;
        public BigDecimal netSalary = BigDecimal.ZERO;
        public String pitBreakdown = "[]";
        public int dependentCount = 0;
        public boolean hasWarning = false;
        public String warningMessage = null;
    }

    /**
     * Tính thuế TNCN lũy tiến cho 1 nhân viên dựa trên payroll đã có.
     *
     * @param userId       ID nhân viên
     * @param month        Tháng lương
     * @param year         Năm lương
     * @return TaxResult chứa toàn bộ thông tin tính thuế
     */
    public TaxResult calculateForEmployee(int userId, int month, int year) {
        TaxResult result = new TaxResult();

        // 1. Lấy payroll hiện tại
        Payroll payroll = payrollDAO.getPayroll(userId, month, year);
        if (payroll == null) {
            result.hasWarning = true;
            result.warningMessage = "Chưa có bảng lương cho tháng " + month + "/" + year;
            return result;
        }

        // 2. Tính Gross Income
        BigDecimal baseSalary = safe(payroll.getBaseSalary());
        BigDecimal overtime = safe(payroll.getOvertimeAmount());
        BigDecimal allowance = safe(payroll.getAllowanceAmount());
        BigDecimal bonus = safe(payroll.getBonusAmount());
        result.grossIncome = baseSalary.add(overtime).add(allowance).add(bonus);

        // 3. Tính Bảo hiểm
        result.insuranceAmount = PayrollDAO.calculateInsurance(result.grossIncome);

        // 4. Lấy thông tin giảm trừ từ tax profile
        Date effectiveDate = Date.valueOf(year + "-" + String.format("%02d", month) + "-01");
        EmployeeTaxProfile taxProfile = taxProfileDAO.getOrCreate(userId);
        
        result.personalDeduction = deductionDAO.getPersonalDeduction(effectiveDate);
        BigDecimal perDepDeduction = deductionDAO.getDependentDeduction(effectiveDate);
        result.dependentCount = (taxProfile != null) ? taxProfile.getDependentCount() : 0;
        result.dependentDeduction = perDepDeduction.multiply(BigDecimal.valueOf(result.dependentCount));
        result.totalDeduction = result.personalDeduction.add(result.dependentDeduction);

        // 5. Tính Taxable Income
        BigDecimal incomeAfterInsurance = result.grossIncome.subtract(result.insuranceAmount);
        result.taxableIncome = incomeAfterInsurance.subtract(result.totalDeduction);
        
        if (result.taxableIncome.compareTo(BigDecimal.ZERO) < 0) {
            result.taxableIncome = BigDecimal.ZERO;
        }

        // 6. Tính PIT lũy tiến từ DB
        result.pitAmount = bracketDAO.calculateProgressivePIT(result.taxableIncome, effectiveDate);
        result.pitBreakdown = bracketDAO.calculatePITBreakdown(result.taxableIncome, effectiveDate);

        // 7. Tính Net Salary
        BigDecimal otherDeduction = safe(payroll.getDeductionAmount());
        result.netSalary = result.grossIncome
                .subtract(result.insuranceAmount)
                .subtract(result.pitAmount)
                .subtract(otherDeduction);

        if (result.netSalary.compareTo(BigDecimal.ZERO) < 0) {
            result.hasWarning = true;
            result.warningMessage = "Lương thực nhận âm: " + result.netSalary.toPlainString();
            result.netSalary = BigDecimal.ZERO;
        }

        // 8. Kiểm tra biến động thu nhập
        checkIncomeDeviation(userId, month, year, result);

        return result;
    }

    /**
     * Tính thuế và cập nhật vào payroll (idempotent).
     * Nếu đã tính rồi sẽ ghi đè kết quả cũ.
     */
    public TaxResult calculateAndUpdate(int userId, int month, int year, int calculatedBy, String ipAddress) {
        TaxResult result = calculateForEmployee(userId, month, year);

        Payroll payroll = payrollDAO.getPayroll(userId, month, year);
        if (payroll == null) return result;

        // Chỉ cập nhật nếu status là Draft hoặc Rejected
        String status = payroll.getStatus();
        if (!"Draft".equals(status) && !"Rejected".equals(status)) {
            result.hasWarning = true;
            result.warningMessage = "Không thể cập nhật payroll có status: " + status;
            return result;
        }

        // Cập nhật các trường thuế/bảo hiểm
        payroll.setGrossSalary(result.grossIncome);
        payroll.setInsuranceAmount(result.insuranceAmount);
        payroll.setTaxAmount(result.pitAmount);
        payroll.setNetSalary(result.netSalary);

        payrollDAO.insertOrUpdatePayroll(payroll);

        // Audit log
        String desc = String.format("PIT calculated: Gross=%s, Insurance=%s, Taxable=%s, PIT=%s, Net=%s",
                result.grossIncome.toPlainString(),
                result.insuranceAmount.toPlainString(),
                result.taxableIncome.toPlainString(),
                result.pitAmount.toPlainString(),
                result.netSalary.toPlainString());
        auditDAO.log("payroll", payroll.getPayrollId(), "CALCULATE", calculatedBy, desc, ipAddress);

        return result;
    }

    /**
     * Tính thuế cho TẤT CẢ nhân viên trong kỳ lương.
     */
    public int calculateBatch(int month, int year, int calculatedBy, String ipAddress) {
        List<Integer> empIds = payrollDAO.getAllEligibleEmployeeIds(month, year);
        int successCount = 0;
        for (int userId : empIds) {
            try {
                Payroll existing = payrollDAO.getPayroll(userId, month, year);
                if (existing != null && ("Draft".equals(existing.getStatus()) || "Rejected".equals(existing.getStatus()))) {
                    calculateAndUpdate(userId, month, year, calculatedBy, ipAddress);
                    successCount++;
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        
        auditDAO.log("payroll_batch", 0, "BATCH_CALCULATE", calculatedBy,
                "Batch PIT calculation: month=" + month + ", year=" + year + ", count=" + successCount, ipAddress);
        
        return successCount;
    }

    /**
     * Kiểm tra biến động thu nhập so với tháng trước (>30% cảnh báo).
     */
    private void checkIncomeDeviation(int userId, int month, int year, TaxResult current) {
        int prevMonth = month - 1;
        int prevYear = year;
        if (prevMonth < 1) { prevMonth = 12; prevYear--; }

        Payroll prev = payrollDAO.getPayroll(userId, prevMonth, prevYear);
        if (prev == null || prev.getGrossSalary() == null) return;

        BigDecimal prevGross = prev.getGrossSalary();
        if (prevGross.compareTo(BigDecimal.ZERO) == 0) return;

        BigDecimal deviation = current.grossIncome.subtract(prevGross)
                .abs()
                .divide(prevGross, 4, RoundingMode.HALF_UP)
                .multiply(new BigDecimal("100"));

        if (deviation.compareTo(new BigDecimal("30")) > 0) {
            current.hasWarning = true;
            String msg = String.format("Thu nhập biến động %.1f%% so với tháng trước (trước: %s, sau: %s)",
                    deviation.doubleValue(), prevGross.toPlainString(), current.grossIncome.toPlainString());
            current.warningMessage = (current.warningMessage != null) ? current.warningMessage + "; " + msg : msg;
        }
    }

    private BigDecimal safe(BigDecimal val) {
        return val != null ? val : BigDecimal.ZERO;
    }
}
