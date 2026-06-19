package controller.employee;

import dao.PayrollDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import model.Payroll;
import model.User;

/**
 * Employee PayrollController
 * URL: /employee/payroll
 *
 * GET (no action) → Hiển thị danh sách phiếu lương của nhân viên đang đăng nhập
 * GET action=view  → Xem chi tiết 1 phiếu lương
 *
 * Chỉ hiển thị payroll có status Approved hoặc Paid.
 */
@WebServlet(name = "EmployeePayrollController", urlPatterns = {"/employee/payroll"})
public class PayrollController extends HttpServlet {

    private final PayrollDAO payrollDAO = new PayrollDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");

        if ("view".equals(action)) {
            // Xem chi tiết 1 phiếu lương
            String monthStr = request.getParameter("month");
            String yearStr  = request.getParameter("year");

            if (monthStr != null && yearStr != null) {
                try {
                    int month = Integer.parseInt(monthStr);
                    int year  = Integer.parseInt(yearStr);
                    int userId = currentUser.getUserId();

                    Payroll payroll = payrollDAO.getPayroll(userId, month, year);

                    // Chỉ cho xem nếu đã Approved hoặc Paid
                    if (payroll != null && ("Approved".equals(payroll.getStatus()) || "Paid".equals(payroll.getStatus()))) {
                        request.setAttribute("payroll", payroll);
                        request.setAttribute("viewMode", "detail");
                    } else {
                        request.getSession().setAttribute("errorMessage", "Phiếu lương không tồn tại hoặc chưa được duyệt.");
                        response.sendRedirect(request.getContextPath() + "/employee/payroll");
                        return;
                    }
                } catch (NumberFormatException e) {
                    response.sendRedirect(request.getContextPath() + "/employee/payroll");
                    return;
                }
            }
        } else if ("print".equals(action)) {
            // Xem để in/xuất PDF 1 phiếu lương
            String monthStr = request.getParameter("month");
            String yearStr  = request.getParameter("year");

            if (monthStr != null && yearStr != null) {
                try {
                    int month = Integer.parseInt(monthStr);
                    int year  = Integer.parseInt(yearStr);
                    int userId = currentUser.getUserId();

                    Payroll payroll = payrollDAO.getPayroll(userId, month, year);

                    if (payroll != null && ("Approved".equals(payroll.getStatus()) || "Paid".equals(payroll.getStatus()))) {
                        request.setAttribute("payroll", payroll);
                        request.setAttribute("employeeName", currentUser.getFullName());
                        request.getRequestDispatcher("/employee/payslip-print.jsp").forward(request, response);
                        return;
                    } else {
                        response.getWriter().write("Phiếu lương không tồn tại hoặc chưa được duyệt.");
                        return;
                    }
                } catch (NumberFormatException e) {
                    response.sendRedirect(request.getContextPath() + "/employee/payroll");
                    return;
                }
            }
        } else if ("export".equals(action)) {
            // Xuất excel danh sách phiếu lương của nhân viên
            String monthStr = request.getParameter("month");
            String yearStr  = request.getParameter("year");

            List<Payroll> payslips = payrollDAO.getVisiblePayslips(currentUser.getUserId());

            // Lọc danh sách theo tháng/năm được chọn
            if (monthStr != null && !"all".equals(monthStr) && !monthStr.isEmpty()) {
                try {
                    int m = Integer.parseInt(monthStr);
                    payslips.removeIf(p -> p.getMonth() != m);
                } catch (NumberFormatException e) {}
            }
            if (yearStr != null && !"all".equals(yearStr) && !yearStr.isEmpty()) {
                try {
                    int y = Integer.parseInt(yearStr);
                    payslips.removeIf(p -> p.getYear() != y);
                } catch (NumberFormatException e) {}
            }

            String suffix = "";
            if (monthStr != null && !"all".equals(monthStr)) suffix += "_Thang" + monthStr;
            if (yearStr != null && !"all".equals(yearStr)) suffix += "_Nam" + yearStr;

            String fileName = "LichSuPhieuLuong_" + currentUser.getFullName().replace(" ", "_") + suffix + ".xls";
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
                writer.println("    <x:Name>Lich Su Phieu Luong</x:Name>");
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
                writer.println("  .title-row { font-size: 16pt; font-weight: bold; color: #0f172a; text-align: center; height: 40px; }");
                writer.println("  .subtitle-row { font-size: 11pt; color: #475569; text-align: center; height: 25px; }");
                writer.println("  th { background-color: #0d9488; color: #ffffff; font-weight: bold; border: 0.5pt solid #cbd5e1; text-align: center; vertical-align: middle; height: 30px; font-size: 10pt; }");
                writer.println("  td { border: 0.5pt solid #e2e8f0; vertical-align: middle; height: 25px; font-size: 10pt; }");
                writer.println("  .text-center { text-align: center; }");
                writer.println("  .text-left { text-align: left; }");
                writer.println("  .text-right { text-align: right; }");
                writer.println("  .number-format { mso-number-format: \"\\#\\,\\#\\#0\"; text-align: right; }");
                writer.println("  .status-approved { background-color: #d1fae5; color: #059669; text-align: center; font-weight: bold; }");
                writer.println("  .status-paid { background-color: #dbeafe; color: #2563eb; text-align: center; font-weight: bold; }");
                writer.println("  .total-label { font-weight: bold; background-color: #f8fafc; border-top: 1pt double #0d9488; border-bottom: 1pt double #0d9488; }");
                writer.println("  .total-val { font-weight: bold; background-color: #f8fafc; mso-number-format: \"\\#\\,\\#\\#0\"; text-align: right; border-top: 1pt double #0d9488; border-bottom: 1pt double #0d9488; }");
                writer.println("</style>");
                writer.println("</head>");
                writer.println("<body>");

                // Title
                writer.println("<table>");
                writer.println("  <tr><td colspan=\"13\" class=\"title-row\">LỊCH SỬ PHIẾU LƯƠNG NHÂN VIÊN</td></tr>");
                writer.println("  <tr><td colspan=\"13\" class=\"subtitle-row\">Nhân viên: " + currentUser.getFullName() + " (Mã NV: " + currentUser.getUserId() + ")</td></tr>");
                writer.println("  <tr><td colspan=\"13\" style=\"height: 15px;\"></td></tr>");
                writer.println("</table>");

                // Table headers
                writer.println("<table>");
                writer.println("  <thead>");
                writer.println("    <tr>");
                writer.println("      <th style=\"width: 60px;\">Tháng</th>");
                writer.println("      <th style=\"width: 60px;\">Năm</th>");
                writer.println("      <th style=\"width: 120px;\">Lương cơ bản</th>");
                writer.println("      <th style=\"width: 80px;\">Ngày công</th>");
                writer.println("      <th style=\"width: 120px;\">Tiền tăng ca</th>");
                writer.println("      <th style=\"width: 120px;\">Phụ cấp</th>");
                writer.println("      <th style=\"width: 120px;\">Thưởng</th>");
                writer.println("      <th style=\"width: 120px;\">Khấu trừ</th>");
                writer.println("      <th style=\"width: 120px;\">Bảo hiểm</th>");
                writer.println("      <th style=\"width: 120px;\">Thuế TNCN</th>");
                writer.println("      <th style=\"width: 120px;\">Lương Gross</th>");
                writer.println("      <th style=\"width: 120px;\">Lương Net</th>");
                writer.println("      <th style=\"width: 100px;\">Trạng thái</th>");
                writer.println("    </tr>");
                writer.println("  </thead>");
                writer.println("  <tbody>");

                java.math.BigDecimal totalNet = java.math.BigDecimal.ZERO;
                for (Payroll p : payslips) {
                    writer.println("    <tr>");
                    writer.println("      <td class=\"text-center\">" + p.getMonth() + "</td>");
                    writer.println("      <td class=\"text-center\">" + p.getYear() + "</td>");
                    writer.println("      <td class=\"number-format\">" + p.getBaseSalary() + "</td>");
                    writer.println("      <td class=\"text-center\">" + p.getWorkingDays() + "</td>");
                    writer.println("      <td class=\"number-format\">" + (p.getOvertimeAmount() != null ? p.getOvertimeAmount() : 0) + "</td>");
                    writer.println("      <td class=\"number-format\">" + (p.getAllowanceAmount() != null ? p.getAllowanceAmount() : 0) + "</td>");
                    writer.println("      <td class=\"number-format\">" + (p.getBonusAmount() != null ? p.getBonusAmount() : 0) + "</td>");
                    writer.println("      <td class=\"number-format\">" + (p.getDeductionAmount() != null ? p.getDeductionAmount() : 0) + "</td>");
                    writer.println("      <td class=\"number-format\">" + (p.getInsuranceAmount() != null ? p.getInsuranceAmount() : 0) + "</td>");
                    writer.println("      <td class=\"number-format\">" + (p.getTaxAmount() != null ? p.getTaxAmount() : 0) + "</td>");
                    writer.println("      <td class=\"number-format\">" + (p.getGrossSalary() != null ? p.getGrossSalary() : 0) + "</td>");
                    writer.println("      <td class=\"number-format\">" + (p.getNetSalary() != null ? p.getNetSalary() : 0) + "</td>");
                    
                    String statusCls = "status-approved";
                    if ("Paid".equals(p.getStatus())) {
                        statusCls = "status-paid";
                    }
                    writer.println("      <td class=\"" + statusCls + "\">" + p.getStatus() + "</td>");
                    writer.println("    </tr>");
                    
                    if (p.getNetSalary() != null) {
                        totalNet = totalNet.add(p.getNetSalary());
                    }
                }

                // Summary row
                writer.println("    <tr>");
                writer.println("      <td colspan=\"11\" class=\"total-label text-right\">Tổng thực nhận (VND):</td>");
                writer.println("      <td class=\"total-val\">" + totalNet + "</td>");
                writer.println("      <td class=\"total-label\"></td>");
                writer.println("    </tr>");

                writer.println("  </tbody>");
                writer.println("</table>");
                writer.println("</body>");
                writer.println("</html>");
            }
            return;
        } else {
            // Mặc định: Hiển thị danh sách
            List<Payroll> payslips = payrollDAO.getVisiblePayslips(currentUser.getUserId());
            request.setAttribute("payslipList", payslips);
            request.setAttribute("viewMode", "list");
        }

        request.setAttribute("employeeName", currentUser.getFullName());
        request.getRequestDispatcher("/employee/payslip.jsp").forward(request, response);
    }
}
