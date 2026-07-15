package controller.hr;

import dao.DepartmentDAO;
import dao.PayrollDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Department;
import model.Payroll;
import model.User;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.Calendar;
import java.util.List;

/**
 * MasterPayrollReportController
 * URL: /hr/master-payroll-report
 *
 * Man hinh "Bao cao Bang luong Tong hop" — chi doc, danh cho HR Manager / Director / Admin.
 * Tach biet hoan toan voi HrPayrollController (thao tac draft/approve) va
 * AccountantPayrollController (chi luong). Khong sua DB, khong tao record moi.
 *
 * GET  (khong co action) -> Hien thi bao cao theo thang/nam/phong ban
 * GET  action=exportExcel -> Xuat file .xlsx 2-sheet (Bang luong tong + Uy nhiem chi)
 *
 * Role duoc xem: 1 (Admin), 2 (HR Manager), 4 (Director)
 */
@WebServlet(name = "MasterPayrollReportController", urlPatterns = {"/hr/master-payroll-report"})
public class MasterPayrollReportController extends HttpServlet {

    // --- Phan quyen ---------------------------------------------------------------

    private boolean hasAccess(User user) {
        if (user == null) return false;
        int r = user.getRoleId();
        return r == 1 || r == 2 || r == 4;
    }

    // --- doGet -------------------------------------------------------------------

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (!hasAccess(currentUser)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        if ("exportExcel".equals(action)) {
            exportExcel(request, response);
            return;
        }

        // -- Bo loc --
        int month       = getParamOrDefault(request, "month", getCurrentMonth());
        int year        = getParamOrDefault(request, "year",  getCurrentYear());
        Integer deptId  = parseDeptId(request.getParameter("departmentId"));

        // -- Lay du lieu --
        PayrollDAO payrollDAO = new PayrollDAO();
        DepartmentDAO deptDAO = new DepartmentDAO();

        List<Payroll>    reportData  = payrollDAO.getMasterPayrollReport(month, year, deptId);
        List<Department> departments = deptDAO.getAll();

        // -- Tinh dong TONG CONG --
        BigDecimal totalBase      = BigDecimal.ZERO;
        BigDecimal totalAllowance = BigDecimal.ZERO;
        BigDecimal totalBonus     = BigDecimal.ZERO;
        BigDecimal totalDeduction = BigDecimal.ZERO;
        BigDecimal totalNet       = BigDecimal.ZERO;

        for (Payroll p : reportData) {
            totalBase      = totalBase     .add(nz(p.getBaseSalary()));
            totalAllowance = totalAllowance.add(nz(p.getAllowanceAmount()));
            totalBonus     = totalBonus    .add(nz(p.getBonusAmount()));
            totalDeduction = totalDeduction.add(p.getTotalDeductionAll());
            totalNet       = totalNet      .add(nz(p.getNetSalary()));
        }

        // -- Day attributes sang JSP --
        request.setAttribute("reportData",           reportData);
        request.setAttribute("departments",          departments);
        request.setAttribute("selectedMonth",        month);
        request.setAttribute("selectedYear",         year);
        request.setAttribute("selectedDepartmentId", deptId != null ? deptId : -1);
        request.setAttribute("totalBase",            totalBase);
        request.setAttribute("totalAllowance",       totalAllowance);
        request.setAttribute("totalBonus",           totalBonus);
        request.setAttribute("totalDeduction",       totalDeduction);
        request.setAttribute("totalNet",             totalNet);

        request.getRequestDispatcher("/hr/master-payroll-report.jsp").forward(request, response);
    }

    // --- exportExcel ---------------------------------------------------------------

    private void exportExcel(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        int month      = getParamOrDefault(request, "month", getCurrentMonth());
        int year       = getParamOrDefault(request, "year",  getCurrentYear());
        Integer deptId = parseDeptId(request.getParameter("departmentId"));

        PayrollDAO payrollDAO = new PayrollDAO();
        List<Payroll> list = payrollDAO.getMasterPayrollReport(month, year, deptId);

        String fileName = "BaoCaoBangLuongTongHop_Thang" + month + "_" + year + ".xlsx";
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");

        try (org.apache.poi.xssf.usermodel.XSSFWorkbook workbook =
                     new org.apache.poi.xssf.usermodel.XSSFWorkbook()) {

            // -- Style chung --
            org.apache.poi.xssf.usermodel.XSSFCellStyle headerStyle = workbook.createCellStyle();
            headerStyle.setFillForegroundColor(
                    org.apache.poi.ss.usermodel.IndexedColors.TEAL.getIndex());
            headerStyle.setFillPattern(
                    org.apache.poi.ss.usermodel.FillPatternType.SOLID_FOREGROUND);
            org.apache.poi.xssf.usermodel.XSSFFont headerFont = workbook.createFont();
            headerFont.setColor(org.apache.poi.ss.usermodel.IndexedColors.WHITE.getIndex());
            headerFont.setBold(true);
            headerStyle.setFont(headerFont);

            org.apache.poi.xssf.usermodel.XSSFDataFormat fmt = workbook.createDataFormat();

            org.apache.poi.xssf.usermodel.XSSFCellStyle moneyStyle = workbook.createCellStyle();
            moneyStyle.setDataFormat(fmt.getFormat("#,##0"));

            org.apache.poi.xssf.usermodel.XSSFCellStyle totalStyle = workbook.createCellStyle();
            totalStyle.setFillForegroundColor(
                    org.apache.poi.ss.usermodel.IndexedColors.LIGHT_YELLOW.getIndex());
            totalStyle.setFillPattern(
                    org.apache.poi.ss.usermodel.FillPatternType.SOLID_FOREGROUND);
            org.apache.poi.xssf.usermodel.XSSFFont totalFont = workbook.createFont();
            totalFont.setBold(true);
            totalStyle.setFont(totalFont);
            totalStyle.setDataFormat(fmt.getFormat("#,##0"));

            writeSheetBangLuong(workbook, headerStyle, moneyStyle, totalStyle, list, month, year);
            writeSheetUyNhiemChi(workbook, headerStyle, moneyStyle, totalStyle, list, month, year);

            workbook.write(response.getOutputStream());
        }
    }

    // Sheet 1: Chi tiet luong day du
    private void writeSheetBangLuong(
            org.apache.poi.xssf.usermodel.XSSFWorkbook wb,
            org.apache.poi.xssf.usermodel.XSSFCellStyle headerStyle,
            org.apache.poi.xssf.usermodel.XSSFCellStyle moneyStyle,
            org.apache.poi.xssf.usermodel.XSSFCellStyle totalStyle,
            List<Payroll> list, int month, int year) {

        org.apache.poi.xssf.usermodel.XSSFSheet sheet = wb.createSheet("Bang Luong Tong Hop");

        String[] cols = {
            "STT", "Ma NV", "Ho va ten", "Phong ban",
            "Luong co ban (VND)", "Thuong (VND)", "Phu cap (VND)",
            "Khau tru-Phat (VND)", "Bao hiem NV (VND)", "Thue TNCN (VND)",
            "Tong khoan tru (VND)", "Thuc linh (VND)"
        };

        org.apache.poi.ss.usermodel.Row hRow = sheet.createRow(0);
        for (int i = 0; i < cols.length; i++) {
            org.apache.poi.ss.usermodel.Cell c = hRow.createCell(i);
            c.setCellValue(cols[i]);
            c.setCellStyle(headerStyle);
        }

        int rowNum = 1, stt = 1;
        BigDecimal sumBase = BigDecimal.ZERO, sumBonus = BigDecimal.ZERO,
                   sumAllow = BigDecimal.ZERO, sumDed = BigDecimal.ZERO,
                   sumIns = BigDecimal.ZERO,   sumTax = BigDecimal.ZERO,
                   sumTotDed = BigDecimal.ZERO, sumNet = BigDecimal.ZERO;

        for (Payroll p : list) {
            org.apache.poi.ss.usermodel.Row row = sheet.createRow(rowNum++);
            row.createCell(0).setCellValue(stt++);
            row.createCell(1).setCellValue("NV" + String.format("%04d", p.getUserId()));
            row.createCell(2).setCellValue(p.getFullName()       != null ? p.getFullName()       : "");
            row.createCell(3).setCellValue(p.getDepartmentName() != null ? p.getDepartmentName() : "-");

            setMoney(row, 4,  p.getBaseSalary(),       moneyStyle);
            setMoney(row, 5,  p.getBonusAmount(),       moneyStyle);
            setMoney(row, 6,  p.getAllowanceAmount(),    moneyStyle);
            setMoney(row, 7,  p.getDeductionAmount(),   moneyStyle);
            setMoney(row, 8,  p.getInsuranceAmount(),   moneyStyle);
            setMoney(row, 9,  p.getTaxAmount(),         moneyStyle);
            setMoney(row, 10, p.getTotalDeductionAll(), moneyStyle);
            setMoney(row, 11, p.getNetSalary(),         moneyStyle);

            sumBase   = sumBase  .add(nz(p.getBaseSalary()));
            sumBonus  = sumBonus .add(nz(p.getBonusAmount()));
            sumAllow  = sumAllow .add(nz(p.getAllowanceAmount()));
            sumDed    = sumDed   .add(nz(p.getDeductionAmount()));
            sumIns    = sumIns   .add(nz(p.getInsuranceAmount()));
            sumTax    = sumTax   .add(nz(p.getTaxAmount()));
            sumTotDed = sumTotDed.add(p.getTotalDeductionAll());
            sumNet    = sumNet   .add(nz(p.getNetSalary()));
        }

        // Dong tong cong
        org.apache.poi.ss.usermodel.Row tRow = sheet.createRow(rowNum);
        org.apache.poi.ss.usermodel.Cell tLbl = tRow.createCell(3);
        tLbl.setCellValue("TONG CONG:");
        tLbl.setCellStyle(headerStyle);
        setMoney(tRow, 4,  sumBase,   totalStyle);
        setMoney(tRow, 5,  sumBonus,  totalStyle);
        setMoney(tRow, 6,  sumAllow,  totalStyle);
        setMoney(tRow, 7,  sumDed,    totalStyle);
        setMoney(tRow, 8,  sumIns,    totalStyle);
        setMoney(tRow, 9,  sumTax,    totalStyle);
        setMoney(tRow, 10, sumTotDed, totalStyle);
        setMoney(tRow, 11, sumNet,    totalStyle);

        for (int i = 0; i < cols.length; i++) sheet.autoSizeColumn(i);
    }

    // Sheet 2: Uy nhiem chi (clone pattern tu AccountantPayrollController)
    private void writeSheetUyNhiemChi(
            org.apache.poi.xssf.usermodel.XSSFWorkbook wb,
            org.apache.poi.xssf.usermodel.XSSFCellStyle headerStyle,
            org.apache.poi.xssf.usermodel.XSSFCellStyle moneyStyle,
            org.apache.poi.xssf.usermodel.XSSFCellStyle totalStyle,
            List<Payroll> list, int month, int year) {

        org.apache.poi.xssf.usermodel.XSSFSheet sheet = wb.createSheet("Uy Nhiem Chi");
        String[] cols = {
            "STT", "Ma NV", "Ho va ten", "So tai khoan",
            "Ngan hang thu huong", "So tien chuyen (VND)",
            "Noi dung chuyen khoan", "Trang thai"
        };

        org.apache.poi.ss.usermodel.Row hRow = sheet.createRow(0);
        for (int i = 0; i < cols.length; i++) {
            org.apache.poi.ss.usermodel.Cell c = hRow.createCell(i);
            c.setCellValue(cols[i]);
            c.setCellStyle(headerStyle);
        }

        int rowNum = 1, stt = 1;
        BigDecimal totalTransfer = BigDecimal.ZERO;

        for (Payroll p : list) {
            org.apache.poi.ss.usermodel.Row row = sheet.createRow(rowNum++);
            String account  = p.getBankAccount() != null ? p.getBankAccount() : "-";
            String bank     = p.getBankName()    != null ? p.getBankName()    : "-";
            String fullName = p.getFullName()    != null ? p.getFullName()    : "";
            String content  = "Chuyen khoan luong thang " + month + "/" + year + " cho " + fullName;
            String status   = "Approved".equalsIgnoreCase(p.getStatus()) ? "Cho CK"
                            : "Paid"    .equalsIgnoreCase(p.getStatus()) ? "Da CK"
                            : p.getStatus();

            row.createCell(0).setCellValue(stt++);
            row.createCell(1).setCellValue("NV" + String.format("%04d", p.getUserId()));
            row.createCell(2).setCellValue(fullName);
            row.createCell(3).setCellValue(account);
            row.createCell(4).setCellValue(bank);
            setMoney(row, 5, p.getNetSalary(), moneyStyle);
            row.createCell(6).setCellValue(content);
            row.createCell(7).setCellValue(status);

            totalTransfer = totalTransfer.add(nz(p.getNetSalary()));
        }

        // Dong tong
        org.apache.poi.ss.usermodel.Row tRow = sheet.createRow(rowNum);
        org.apache.poi.ss.usermodel.Cell tLbl = tRow.createCell(4);
        tLbl.setCellValue("TONG CONG:");
        tLbl.setCellStyle(headerStyle);
        setMoney(tRow, 5, totalTransfer, totalStyle);

        for (int i = 0; i < cols.length; i++) sheet.autoSizeColumn(i);
    }

    // -- Helpers ------------------------------------------------------------------

    private void setMoney(org.apache.poi.ss.usermodel.Row row, int col, BigDecimal val,
                          org.apache.poi.xssf.usermodel.XSSFCellStyle style) {
        org.apache.poi.ss.usermodel.Cell c = row.createCell(col);
        c.setCellValue(val != null ? val.doubleValue() : 0);
        c.setCellStyle(style);
    }

    private BigDecimal nz(BigDecimal v) {
        return v != null ? v : BigDecimal.ZERO;
    }

    private Integer parseDeptId(String str) {
        if (str == null || str.isBlank() || "-1".equals(str)) return null;
        try { return Integer.parseInt(str); } catch (NumberFormatException e) { return null; }
    }

    private int getParamOrDefault(HttpServletRequest request, String name, int def) {
        String val = request.getParameter(name);
        if (val == null || val.isBlank()) return def;
        try { return Integer.parseInt(val); } catch (NumberFormatException e) { return def; }
    }

    private int getCurrentMonth() {
        return Calendar.getInstance().get(Calendar.MONTH) + 1;
    }

    private int getCurrentYear() {
        return Calendar.getInstance().get(Calendar.YEAR);
    }
}
