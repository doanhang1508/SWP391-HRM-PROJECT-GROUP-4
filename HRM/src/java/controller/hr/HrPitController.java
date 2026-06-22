package controller.hr;

import dao.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;
import java.util.*;
import model.*;
import service.TaxEngineService;

/**
 * Controller xử lý tính thuế TNCN lũy tiến (Progressive PIT).
 * 
 * URL mapping: /hr/pit
 * 
 *   - (default) dashboard    : Trang tính thuế chính
 *   - taxProfiles           : Hồ sơ thuế nhân viên
 *   - employeeTaxDetail     : Chi tiết thuế 1 nhân viên
 * 
 * POST actions:
 *   - calculate             : Tính thuế cho cả kỳ lương
 *   - calculateSingle       : Tính thuế cho 1 nhân viên
 *   - recalculate           : Tính lại thuế
 *   - updateTaxProfile      : Cập nhật hồ sơ thuế NV
 */
@WebServlet(name = "HrPitController", urlPatterns = {"/hr/pit"})
public class HrPitController extends HttpServlet {

    private final TaxEngineService taxEngine = new TaxEngineService();
    private final TaxBracketDAO bracketDAO = new TaxBracketDAO();
    private final TaxDeductionDAO deductionDAO = new TaxDeductionDAO();
    private final EmployeeTaxProfileDAO taxProfileDAO = new EmployeeTaxProfileDAO();
    private final PayrollDAO payrollDAO = new PayrollDAO();
    private final PayrollPeriodDAO periodDAO = new PayrollPeriodDAO();
    private final AuditLogDAO auditDAO = new AuditLogDAO();

    private boolean checkAccess(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("currentUser") : null;
        if (user == null) { resp.sendRedirect(req.getContextPath() + "/login"); return false; }
        // HR Manager (2), HR Staff (5), Admin (1)
        if (user.getRoleId() != 1 && user.getRoleId() != 2 && user.getRoleId() != 5) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return false;
        }
        return true;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!checkAccess(req, resp)) return;
        String action = req.getParameter("action");
        if (action == null) action = "dashboard";

        switch (action) {
            case "dashboard"          -> showDashboard(req, resp);
            case "taxProfiles"        -> showTaxProfiles(req, resp);
            case "employeeTaxDetail"  -> showEmployeeTaxDetail(req, resp);
            default                   -> resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!checkAccess(req, resp)) return;
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        if (action == null) { resp.sendRedirect(req.getContextPath() + "/hr/pit"); return; }

        switch (action) {
            case "calculate"        -> doCalculate(req, resp);
            case "calculateSingle"  -> doCalculateSingle(req, resp);
            case "recalculate"      -> doRecalculate(req, resp);
            case "updateTaxProfile" -> doUpdateTaxProfile(req, resp);
            default                 -> resp.sendRedirect(req.getContextPath() + "/hr/pit");
        }
    }

    // ═══════════════════════════════════════
    // GET ACTIONS
    // ═══════════════════════════════════════

    private void showDashboard(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int month = getInt(req, "month", Calendar.getInstance().get(Calendar.MONTH) + 1);
        int year = getInt(req, "year", Calendar.getInstance().get(Calendar.YEAR));

        // Lấy danh sách payroll cho tháng
        List<Payroll> payrolls = payrollDAO.getPayrollsWithNames(month, year);

        // Tính kết quả thuế cho mỗi nhân viên
        List<Map<String, Object>> results = new ArrayList<>();
        BigDecimal totalGross = BigDecimal.ZERO, totalPIT = BigDecimal.ZERO, totalNet = BigDecimal.ZERO;

        for (Payroll p : payrolls) {
            TaxEngineService.TaxResult taxResult = taxEngine.calculateForEmployee(p.getUserId(), month, year);
            Map<String, Object> row = new HashMap<>();
            row.put("payroll", p);
            row.put("taxResult", taxResult);
            results.add(row);
            totalGross = totalGross.add(taxResult.grossIncome);
            totalPIT = totalPIT.add(taxResult.pitAmount);
            totalNet = totalNet.add(taxResult.netSalary);
        }

        // Tax brackets hiện hành
        Date effectiveDate = Date.valueOf(year + "-" + String.format("%02d", month) + "-01");
        List<TaxBracket> brackets = bracketDAO.getEffectiveBrackets(effectiveDate);

        req.setAttribute("results", results);
        req.setAttribute("brackets", brackets);
        req.setAttribute("selectedMonth", month);
        req.setAttribute("selectedYear", year);
        req.setAttribute("totalGross", totalGross);
        req.setAttribute("totalPIT", totalPIT);
        req.setAttribute("totalNet", totalNet);
        req.setAttribute("totalEmployees", payrolls.size());

        req.getRequestDispatcher("/hr/pit-dashboard.jsp").forward(req, resp);
    }


    private void showTaxProfiles(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setAttribute("profiles", taxProfileDAO.getAllWithNames());
        req.getRequestDispatcher("/hr/pit-tax-profiles.jsp").forward(req, resp);
    }

    private void showEmployeeTaxDetail(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int userId = getInt(req, "userId", -1);
        int month = getInt(req, "month", Calendar.getInstance().get(Calendar.MONTH) + 1);
        int year = getInt(req, "year", Calendar.getInstance().get(Calendar.YEAR));

        if (userId < 0) {
            req.getSession().setAttribute("errorMessage", "ID nhân viên không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/hr/pit");
            return;
        }

        TaxEngineService.TaxResult result = taxEngine.calculateForEmployee(userId, month, year);
        Payroll payroll = payrollDAO.getPayroll(userId, month, year);
        EmployeeTaxProfile profile = taxProfileDAO.getOrCreate(userId);

        Date effectiveDate = Date.valueOf(year + "-" + String.format("%02d", month) + "-01");
        List<TaxBracket> brackets = bracketDAO.getEffectiveBrackets(effectiveDate);

        // Audit history for this payroll
        List<AuditLog> auditLogs = new ArrayList<>();
        if (payroll != null) {
            auditLogs = auditDAO.getByEntity("payroll", payroll.getPayrollId());
        }

        req.setAttribute("taxResult", result);
        req.setAttribute("payroll", payroll);
        req.setAttribute("taxProfile", profile);
        req.setAttribute("brackets", brackets);
        req.setAttribute("auditLogs", auditLogs);
        req.setAttribute("selectedMonth", month);
        req.setAttribute("selectedYear", year);
        req.setAttribute("userId", userId);

        req.getRequestDispatcher("/hr/pit-employee-detail.jsp").forward(req, resp);
    }


    // ═══════════════════════════════════════
    // POST ACTIONS
    // ═══════════════════════════════════════

    private void doCalculate(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int month = getInt(req, "month", -1);
        int year = getInt(req, "year", -1);
        if (month < 1 || month > 12 || year < 2000) {
            req.getSession().setAttribute("errorMessage", "Tháng hoặc năm không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/hr/pit");
            return;
        }

        User user = (User) req.getSession().getAttribute("currentUser");
        int count = taxEngine.calculateBatch(month, year, user.getUserId(), req.getRemoteAddr());

        req.getSession().setAttribute("successMessage",
                "Đã tính thuế TNCN thành công cho " + count + " nhân viên trong kỳ " + month + "/" + year + ".");
        resp.sendRedirect(req.getContextPath() + "/hr/pit?month=" + month + "&year=" + year);
    }

    private void doCalculateSingle(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int userId = getInt(req, "userId", -1);
        int month = getInt(req, "month", -1);
        int year = getInt(req, "year", -1);

        User currentUser = (User) req.getSession().getAttribute("currentUser");
        TaxEngineService.TaxResult result = taxEngine.calculateAndUpdate(userId, month, year,
                currentUser.getUserId(), req.getRemoteAddr());

        if (result.hasWarning && result.warningMessage != null && result.warningMessage.contains("Không thể")) {
            req.getSession().setAttribute("errorMessage", result.warningMessage);
        } else {
            String msg = String.format("Đã tính thuế cho NV #%d: PIT = %s VNĐ, Net = %s VNĐ",
                    userId, result.pitAmount.toPlainString(), result.netSalary.toPlainString());
            if (result.hasWarning) msg += " ⚠ " + result.warningMessage;
            req.getSession().setAttribute("successMessage", msg);
        }
        resp.sendRedirect(req.getContextPath() + "/hr/pit?action=employeeTaxDetail&userId=" + userId + "&month=" + month + "&year=" + year);
    }

    private void doRecalculate(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        // Same as calculate but with audit tag RECALCULATE
        doCalculate(req, resp);
    }

    private void doUpdateTaxProfile(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int profileId = getInt(req, "taxProfileId", -1);
        if (profileId < 0) {
            req.getSession().setAttribute("errorMessage", "Profile không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/hr/pit?action=taxProfiles");
            return;
        }

        EmployeeTaxProfile etp = new EmployeeTaxProfile();
        etp.setTaxProfileId(profileId);
        etp.setTaxCode(req.getParameter("taxCode"));
        etp.setTaxRegistration("1".equals(req.getParameter("taxRegistration")));
        etp.setDependentCount(getInt(req, "dependentCount", 0));
        etp.setPersonalDeduction(new BigDecimal(req.getParameter("personalDeduction").replaceAll(",", "")));
        etp.setDependentDeduction(new BigDecimal(req.getParameter("dependentDeduction").replaceAll(",", "")));
        etp.setStatus(getInt(req, "status", 1));
        etp.setNotes(req.getParameter("notes"));

        boolean success = taxProfileDAO.update(etp);
        if (success) {
            User user = (User) req.getSession().getAttribute("currentUser");
            auditDAO.log("employee_tax_profile", profileId, "UPDATE", user.getUserId(),
                    "Updated tax profile", req.getRemoteAddr());
            req.getSession().setAttribute("successMessage", "Cập nhật hồ sơ thuế thành công.");
        } else {
            req.getSession().setAttribute("errorMessage", "Cập nhật hồ sơ thuế thất bại.");
        }
        resp.sendRedirect(req.getContextPath() + "/hr/pit?action=taxProfiles");
    }

    private int getInt(HttpServletRequest req, String name, int def) {
        String val = req.getParameter(name);
        if (val == null || val.isBlank()) return def;
        try { return Integer.parseInt(val); }
        catch (NumberFormatException e) { return def; }
    }
}
