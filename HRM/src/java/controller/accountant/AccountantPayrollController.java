package controller.accountant;

import dao.PayrollDAO;
import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDate;
import java.util.List;
import model.Payroll;
import model.User;

/**
 * AccountantPayrollController
 * URL: /accountant/payroll
 *
 * GET  → Hiển thị danh sách bảng lương theo tháng/năm (chỉ status=Approved)
 * POST → Đánh dấu đã chuyển khoản (status: Approved → Paid)
 *
 * Chỉ roleId=8 (Accountant) được truy cập (đã bảo vệ bởi AuthFilter).
 */
@WebServlet(name = "AccountantPayrollController", urlPatterns = {"/accountant/payroll"})
public class AccountantPayrollController extends HttpServlet {

    private static final int ROLE_ACCOUNTANT = 8;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        if (currentUser.getRoleId() != ROLE_ACCOUNTANT) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        String action = request.getParameter("action");
        if ("exportExcel".equals(action)) {
            exportExcel(request, response);
            return;
        }

        String monthStr = request.getParameter("month");
        String yearStr = request.getParameter("year");

        PayrollDAO payrollDAO = new PayrollDAO();

        if (monthStr == null || monthStr.isBlank() || yearStr == null || yearStr.isBlank()) {
            List<dao.PayrollDAO.PayrollMonthSummary> summaries = payrollDAO.getMonthlySummaries();
            request.setAttribute("monthlySummaries", summaries);
            request.setAttribute("viewMode", "months");
            request.getRequestDispatcher("/accountant/payroll.jsp").forward(request, response);
            return;
        }

        try {
            int month = Integer.parseInt(monthStr);
            int year = Integer.parseInt(yearStr);

            List<Payroll> payrollList = payrollDAO.getByMonthYear(month, year);

            // Thống kê nhanh
            long totalCount    = payrollList.size();
            long approvedCount = payrollList.stream().filter(p -> "Approved".equals(p.getStatus())).count();
            long paidCount     = payrollList.stream().filter(p -> "Paid".equals(p.getStatus())).count();

            // Gắn tên nhân viên
            UserDAO userDAO = new UserDAO();
            for (Payroll p : payrollList) {
                User u = userDAO.getUserById(p.getUserId());
                if (u != null) p.setFullName(u.getFullName());
            }

            request.setAttribute("payrollList",   payrollList);
            request.setAttribute("selectedMonth", month);
            request.setAttribute("selectedYear",  year);
            request.setAttribute("month",         month);
            request.setAttribute("year",          year);
            request.setAttribute("totalCount",    totalCount);
            request.setAttribute("approvedCount", approvedCount);
            request.setAttribute("paidCount",     paidCount);
            request.setAttribute("viewMode",      "employees");

            request.getRequestDispatcher("/accountant/payroll.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/accountant/payroll");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null || currentUser.getRoleId() != ROLE_ACCOUNTANT) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action    = request.getParameter("action");
        String monthStr  = request.getParameter("month");
        String yearStr   = request.getParameter("year");

        int month = LocalDate.now().getMonthValue();
        int year  = LocalDate.now().getYear();
        try {
            if (monthStr != null) month = Integer.parseInt(monthStr);
            if (yearStr  != null) year  = Integer.parseInt(yearStr);
        } catch (NumberFormatException ignored) {}

        if ("markPaid".equals(action)) {
            String payrollIdStr = request.getParameter("payrollId");
            if (payrollIdStr != null) {
                try {
                    int payrollId = Integer.parseInt(payrollIdStr);
                    PayrollDAO payrollDAO = new PayrollDAO();
                    payrollDAO.markAsPaid(payrollId);
                    session.setAttribute("successMessage", "Đã xác nhận chuyển khoản thành công!");
                } catch (NumberFormatException e) {
                    session.setAttribute("errorMessage", "Dữ liệu không hợp lệ.");
                }
            }
        } else if ("markAllPaid".equals(action)) {
            PayrollDAO payrollDAO = new PayrollDAO();
            int updated = payrollDAO.markAllApprovedAsPaid(month, year);
            session.setAttribute("successMessage", "Đã xác nhận chuyển khoản cho " + updated + " nhân viên!");
        }

        response.sendRedirect(request.getContextPath() + "/accountant/payroll?month=" + month + "&year=" + year);
    }

    private int getParamOrDefault(HttpServletRequest request, String name, int def) {
        String val = request.getParameter(name);
        if (val == null || val.isBlank()) {
            return def;
        }
        try {
            return Integer.parseInt(val);
        } catch (NumberFormatException e) {
            return def;
        }
    }

    private int getCurrentMonth() {
        return java.util.Calendar.getInstance().get(java.util.Calendar.MONTH) + 1;
    }

    private int getCurrentYear() {
        return java.util.Calendar.getInstance().get(java.util.Calendar.YEAR);
    }

    private String escapeHtml(String val) {
        if (val == null) return "";
        return val.replace("&", "&amp;")
                  .replace("<", "&lt;")
                  .replace(">", "&gt;")
                  .replace("\"", "&quot;")
                  .replace("'", "&#39;");
    }

    private String formatNum(java.math.BigDecimal val) {
        return val != null ? val.toPlainString() : "0";
    }

    private void exportExcel(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int month = getParamOrDefault(request, "month", getCurrentMonth());
        int year = getParamOrDefault(request, "year", getCurrentYear());

        PayrollDAO payrollDAO = new PayrollDAO();
        List<Payroll> list = payrollDAO.getPayrollsWithBankDetails(month, year);

        // Set response headers for XLS download (HTML-based Excel)
        String fileName = "DanhSachChuyenKhoanLuong_Thang" + month + "_" + year + ".xls";
        response.setContentType("application/vnd.ms-excel; charset=UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");
        response.setCharacterEncoding("UTF-8");

        try (java.io.PrintWriter writer = response.getWriter()) {
            writer.println("<html xmlns:o=\"urn:schemas-microsoft-com:office:office\" xmlns:x=\"urn:schemas-microsoft-com:office:excel\" xmlns=\"http://www.w3.org/TR/REC-html40\">");
            writer.println("<head>");
            writer.println("<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">");
            writer.println("<!--[if gte mso 9]>");
            writer.println("<xml>");
            writer.println(" <x:ExcelWorkbook>");
            writer.println("  <x:ExcelWorksheets>");
            writer.println("   <x:ExcelWorksheet>");
            writer.println("    <x:Name>Chuyển Khoản Lương</x:Name>");
            writer.println("    <x:WorksheetOptions>");
            writer.println("     <x:DisplayGridlines/>");
            writer.println("    </x:WorksheetOptions>");
            writer.println("   </x:ExcelWorksheet>");
            writer.println("  </x:ExcelWorksheets>");
            writer.println(" </x:ExcelWorkbook>");
            writer.println("</xml>");
            writer.println("<![endif]-->");
            writer.println("<style>");
            writer.println("  body { font-family: 'Segoe UI', Arial, sans-serif; }");
            writer.println("  .title-row { font-size: 16pt; font-weight: bold; color: #0f766e; text-align: center; height: 40px; }");
            writer.println("  .subtitle-row { font-size: 11pt; color: #64748b; text-align: center; height: 25px; }");
            writer.println("  th { background-color: #0d9488; color: #ffffff; font-weight: bold; border: 0.5pt solid #cbd5e1; text-align: center; vertical-align: middle; height: 35px; font-size: 10pt; }");
            writer.println("  td { border: 0.5pt solid #e2e8f0; vertical-align: middle; height: 28px; font-size: 10pt; }");
            writer.println("  .text-center { text-align: center; }");
            writer.println("  .text-left { text-align: left; }");
            writer.println("  .text-right { text-align: right; }");
            writer.println("  .number-format { mso-number-format: \"\\#\\,\\#\\#0\"; text-align: right; }");
            writer.println("  .text-format { mso-number-format: \"\\@\"; text-align: center; }");
            writer.println("  .status-approved { background-color: #d1fae5; color: #059669; text-align: center; font-weight: bold; }");
            writer.println("  .status-paid { background-color: #dbeafe; color: #2563eb; text-align: center; font-weight: bold; }");
            writer.println("  .status-pending { background-color: #fef3c7; color: #d97706; text-align: center; font-weight: bold; }");
            writer.println("  .status-rejected { background-color: #fee2e2; color: #b91c1c; text-align: center; font-weight: bold; }");
            writer.println("  .status-draft { background-color: #f1f5f9; color: #475569; text-align: center; font-weight: bold; }");
            writer.println("  .total-label { font-weight: bold; background-color: #f8fafc; border-top: 1pt double #0d9488; border-bottom: 1pt double #0d9488; }");
            writer.println("  .total-val { font-weight: bold; background-color: #f8fafc; mso-number-format: \"\\#\\,\\#\\#0\"; text-align: right; border-top: 1pt double #0d9488; border-bottom: 1pt double #0d9488; }");
            writer.println("</style>");
            writer.println("</head>");
            writer.println("<body>");

            // Title block
            writer.println("<table>");
            writer.println("  <tr><td colspan=\"8\" class=\"title-row\">DANH SÁCH CHUYỂN KHOẢN LƯƠNG NHÂN VIÊN</td></tr>");
            writer.println("  <tr><td colspan=\"8\" class=\"subtitle-row\">Kỳ lương: Tháng " + month + " năm " + year + "</td></tr>");
            writer.println("  <tr><td colspan=\"8\" style=\"height: 15px;\"></td></tr>");
            writer.println("</table>");

            // Table headers
            writer.println("<table>");
            writer.println("  <thead>");
            writer.println("    <tr>");
            writer.println("      <th style=\"width: 50px;\">STT</th>");
            writer.println("      <th style=\"width: 80px;\">Mã NV</th>");
            writer.println("      <th style=\"width: 200px;\">Họ và tên</th>");
            writer.println("      <th style=\"width: 150px;\">Số tài khoản</th>");
            writer.println("      <th style=\"width: 180px;\">Ngân hàng thụ hưởng</th>");
            writer.println("      <th style=\"width: 130px;\">Số tiền chuyển (VND)</th>");
            writer.println("      <th style=\"width: 300px;\">Nội dung chuyển khoản</th>");
            writer.println("      <th style=\"width: 120px;\">Trạng thái</th>");
            writer.println("    </tr>");
            writer.println("  </thead>");
            writer.println("  <tbody>");

            java.math.BigDecimal totalTransfer = java.math.BigDecimal.ZERO;
            int stt = 1;
            for (Payroll p : list) {
                if (p.getNetSalary() != null) {
                    totalTransfer = totalTransfer.add(p.getNetSalary());
                }

                // Check bank details
                String account = p.getBankAccount() != null ? p.getBankAccount() : "—";
                String bank = p.getBankName() != null ? p.getBankName() : "—";
                String fullName = p.getFullName() != null ? p.getFullName() : "";
                String content = "Chuyen khoan luong thang " + month + "/" + year + " cho " + fullName;

                String statusClass = "";
                String statusText = p.getStatus() != null ? p.getStatus() : "";
                if ("Approved".equalsIgnoreCase(statusText)) {
                    statusClass = "status-approved";
                    statusText = "Chờ CK";
                } else if ("Paid".equalsIgnoreCase(statusText)) {
                    statusClass = "status-paid";
                    statusText = "Đã TK";
                } else if ("Pending".equalsIgnoreCase(statusText)) {
                    statusClass = "status-pending";
                    statusText = "Chờ duyệt";
                } else if ("Rejected".equalsIgnoreCase(statusText)) {
                    statusClass = "status-rejected";
                    statusText = "Từ chối";
                } else {
                    statusClass = "status-draft";
                    statusText = "Nháp";
                }

                writer.println("    <tr>");
                writer.println("      <td class=\"text-center\">" + stt++ + "</td>");
                writer.println("      <td class=\"text-center\">" + p.getUserId() + "</td>");
                writer.println("      <td class=\"text-left\">" + escapeHtml(fullName) + "</td>");
                writer.println("      <td class=\"text-format\">" + account + "</td>");
                writer.println("      <td class=\"text-left\">" + escapeHtml(bank) + "</td>");
                writer.println("      <td class=\"number-format\">" + formatNum(p.getNetSalary()) + "</td>");
                writer.println("      <td class=\"text-left\">" + escapeHtml(content) + "</td>");
                writer.println("      <td class=\"" + statusClass + "\">" + statusText + "</td>");
                writer.println("    </tr>");
            }

            // Totals Row
            writer.println("    <tr>");
            writer.println("      <td colspan=\"3\" class=\"total-label text-center\">TỔNG CỘNG</td>");
            writer.println("      <td class=\"total-label\"></td>");
            writer.println("      <td class=\"total-label\"></td>");
            writer.println("      <td class=\"total-val\">" + totalTransfer.toPlainString() + "</td>");
            writer.println("      <td class=\"total-label\"></td>");
            writer.println("      <td class=\"total-label\"></td>");
            writer.println("    </tr>");

            writer.println("  </tbody>");
            writer.println("</table>");
            writer.println("</body>");
            writer.println("</html>");
        }
    }
}
