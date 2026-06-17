package controller.hr;

import dao.PayrollDAO;
import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import model.Payroll;
import model.User;

@WebServlet(name = "HrPayrollController", urlPatterns = {"/hr/payroll"})
public class HrPayrollController extends HttpServlet {

    private final PayrollDAO payrollDAO = new PayrollDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        int roleId = currentUser.getRoleId();
        if (roleId != 2 && roleId != 5) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        if ("edit".equals(action) && roleId != 5) {
            session.setAttribute("errorMessage", "Bạn không có quyền thực hiện hành động này.");
            response.sendRedirect(request.getContextPath() + "/hr/payroll");
            return;
        }

        switch (action) {
            case "list" -> showList(request, response);
            case "edit" -> showEditForm(request, response);
            case "exportExcel" -> exportExcel(request, response);
            default -> response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        int roleId = currentUser.getRoleId();
        if (roleId != 2 && roleId != 5) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        if (roleId == 5) { // HR Staff
            switch (action) {
                case "generateDraft" -> generateDraft(request, response);
                case "updateDraft" -> updateDraft(request, response);
                case "submit" -> submitForApproval(request, response);
                default -> {
                    session.setAttribute("errorMessage", "Hành động không được phép cho HR Staff.");
                    response.sendRedirect(request.getContextPath() + "/hr/payroll");
                }
            }
        } else if (roleId == 2) { // HR Manager
            switch (action) {
                case "hrApprove" -> hrApprove(request, response);
                case "hrReject" -> hrReject(request, response);
                case "hrApproveAll" -> hrApproveAll(request, response);
                default -> {
                    session.setAttribute("errorMessage", "Hành động không được phép cho HR Manager.");
                    response.sendRedirect(request.getContextPath() + "/hr/payroll");
                }
            }
        }
    }

    private void showList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String monthStr = request.getParameter("month");
        String yearStr = request.getParameter("year");

        if (monthStr == null || monthStr.isBlank() || yearStr == null || yearStr.isBlank()) {
            List<dao.PayrollDAO.PayrollMonthSummary> summaries = payrollDAO.getMonthlySummaries();
            request.setAttribute("monthlySummaries", summaries);
            request.setAttribute("viewMode", "months");
            request.getRequestDispatcher("/hr/payroll-list.jsp").forward(request, response);
            return;
        }

        int month = Integer.parseInt(monthStr);
        int year = Integer.parseInt(yearStr);

        List<Payroll> list = payrollDAO.getByMonthYear(month, year);
        
        long draftCount    = list.stream().filter(p -> "Draft".equals(p.getStatus())).count();
        long pendingCount  = list.stream().filter(p -> "Pending".equals(p.getStatus())).count();
        long verifiedCount = list.stream().filter(p -> "Verified".equals(p.getStatus())).count();
        long approvedCount = list.stream().filter(p -> "Approved".equals(p.getStatus())).count();
        long rejectedCount = list.stream().filter(p -> "Rejected".equals(p.getStatus())).count();
        long paidCount     = list.stream().filter(p -> "Paid".equals(p.getStatus())).count();
        long totalCount    = list.size();

        request.setAttribute("payrollList", list);
        request.setAttribute("selectedMonth", month);
        request.setAttribute("selectedYear", year);
        request.setAttribute("viewMode", "employees");
        request.setAttribute("draftCount", draftCount);
        request.setAttribute("pendingCount", pendingCount);
        request.setAttribute("verifiedCount", verifiedCount);
        request.setAttribute("approvedCount", approvedCount);
        request.setAttribute("rejectedCount", rejectedCount);
        request.setAttribute("paidCount", paidCount);
        request.setAttribute("totalCount", totalCount);

        // Fetch employee names mapping
        List<User> users = userDAO.getAllUsers();
        Map<Integer, String> userNames = new HashMap<>();
        for (User u : users) {
            userNames.put(u.getUserId(), u.getFullName());
        }
        request.setAttribute("userNames", userNames);

        request.getRequestDispatcher("/hr/payroll-list.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isBlank()) {
            request.getSession().setAttribute("errorMessage", "Không tìm thấy ID bảng lương.");
            response.sendRedirect(request.getContextPath() + "/hr/payroll");
            return;
        }

        try {
            int payrollId = Integer.parseInt(idStr);
            Payroll payroll = payrollDAO.getById(payrollId);
            if (payroll == null) {
                request.getSession().setAttribute("errorMessage", "Bảng lương không tồn tại.");
                response.sendRedirect(request.getContextPath() + "/hr/payroll");
                return;
            }

            // Only allow editing if status is Draft or Rejected
            String status = payroll.getStatus();
            if (!"Draft".equals(status) && !"Rejected".equals(status)) {
                request.getSession().setAttribute("errorMessage", "Chỉ có thế chỉnh sửa bảng lương trạng thái Draft hoặc Rejected.");
                response.sendRedirect(request.getContextPath() + "/hr/payroll?month=" + payroll.getMonth() + "&year=" + payroll.getYear());
                return;
            }

            User employee = userDAO.getUserById(payroll.getUserId());
            request.setAttribute("payroll", payroll);
            request.setAttribute("employeeName", employee != null ? employee.getFullName() : "Unknown");

            request.getRequestDispatcher("/hr/payroll-edit.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("errorMessage", "ID bảng lương không hợp lệ.");
            response.sendRedirect(request.getContextPath() + "/hr/payroll");
        }
    }

    private void generateDraft(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int month = getParamOrDefault(request, "month", getCurrentMonth());
        int year = getParamOrDefault(request, "year", getCurrentYear());

        if (month < 1 || month > 12 || year < 2000) {
            request.getSession().setAttribute("errorMessage", "Tháng hoặc năm không hợp lệ.");
            response.sendRedirect(request.getContextPath() + "/hr/payroll?month=" + month + "&year=" + year);
            return;
        }

        int count = payrollDAO.generatePayrollDraft(month, year);
        request.getSession().setAttribute("successMessage", "Đã tạo thành công " + count + " bản ghi bảng lương nháp.");
        response.sendRedirect(request.getContextPath() + "/hr/payroll?month=" + month + "&year=" + year);
    }

    private void updateDraft(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String idStr = request.getParameter("payrollId");
        if (idStr == null || idStr.isBlank()) {
            request.getSession().setAttribute("errorMessage", "Không tìm thấy ID bảng lương.");
            response.sendRedirect(request.getContextPath() + "/hr/payroll");
            return;
        }

        try {
            int payrollId = Integer.parseInt(idStr);
            Payroll current = payrollDAO.getById(payrollId);
            if (current == null) {
                request.getSession().setAttribute("errorMessage", "Bảng lương không tồn tại.");
                response.sendRedirect(request.getContextPath() + "/hr/payroll");
                return;
            }

            if (!"Draft".equals(current.getStatus()) && !"Rejected".equals(current.getStatus())) {
                request.getSession().setAttribute("errorMessage", "Chỉ được phép sửa bảng lương ở trạng thái Draft hoặc Rejected.");
                response.sendRedirect(request.getContextPath() + "/hr/payroll?month=" + current.getMonth() + "&year=" + current.getYear());
                return;
            }

            int workingDays = Integer.parseInt(request.getParameter("workingDays"));
            BigDecimal overtimeAmount = new BigDecimal(request.getParameter("overtimeAmount").replaceAll(",", ""));
            BigDecimal allowanceAmount = new BigDecimal(request.getParameter("allowanceAmount").replaceAll(",", ""));
            BigDecimal bonusAmount = new BigDecimal(request.getParameter("bonusAmount").replaceAll(",", ""));
            BigDecimal deductionAmount = new BigDecimal(request.getParameter("deductionAmount").replaceAll(",", ""));
            BigDecimal insuranceAmount = new BigDecimal(request.getParameter("insuranceAmount").replaceAll(",", ""));
            BigDecimal taxAmount = new BigDecimal(request.getParameter("taxAmount").replaceAll(",", ""));

            if (workingDays < 0) {
                request.getSession().setAttribute("errorMessage", "Số ngày làm việc không được âm.");
                response.sendRedirect(request.getContextPath() + "/hr/payroll?action=edit&id=" + payrollId);
                return;
            }
            if (overtimeAmount.compareTo(BigDecimal.ZERO) < 0 || allowanceAmount.compareTo(BigDecimal.ZERO) < 0 
                || bonusAmount.compareTo(BigDecimal.ZERO) < 0 || deductionAmount.compareTo(BigDecimal.ZERO) < 0 
                || insuranceAmount.compareTo(BigDecimal.ZERO) < 0 || taxAmount.compareTo(BigDecimal.ZERO) < 0) {
                request.getSession().setAttribute("errorMessage", "Các số tiền không được là số âm.");
                response.sendRedirect(request.getContextPath() + "/hr/payroll?action=edit&id=" + payrollId);
                return;
            }

            Payroll updateModel = new Payroll();
            updateModel.setPayrollId(payrollId);
            updateModel.setWorkingDays(workingDays);
            updateModel.setOvertimeAmount(overtimeAmount);
            updateModel.setAllowanceAmount(allowanceAmount);
            updateModel.setBonusAmount(bonusAmount);
            updateModel.setDeductionAmount(deductionAmount);
            updateModel.setInsuranceAmount(insuranceAmount);
            updateModel.setTaxAmount(taxAmount);

            boolean success = payrollDAO.updatePayrollDraft(updateModel);
            if (success) {
                request.getSession().setAttribute("successMessage", "Cập nhật bảng lương nháp thành công.");
            } else {
                request.getSession().setAttribute("errorMessage", "Cập nhật thất bại. Vui lòng kiểm tra lại dữ liệu.");
            }
            response.sendRedirect(request.getContextPath() + "/hr/payroll?month=" + current.getMonth() + "&year=" + current.getYear());
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("errorMessage", "Dữ liệu nhập vào không đúng định dạng số.");
            response.sendRedirect(request.getContextPath() + "/hr/payroll?action=edit&id=" + idStr);
        }
    }

    private void submitForApproval(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String idStr = request.getParameter("payrollId");
        String monthStr = request.getParameter("month");
        String yearStr = request.getParameter("year");

        if (idStr != null && !idStr.isBlank()) {
            // Submit single
            try {
                int payrollId = Integer.parseInt(idStr);
                Payroll p = payrollDAO.getById(payrollId);
                if (p == null) {
                    request.getSession().setAttribute("errorMessage", "Bảng lương không tồn tại.");
                    response.sendRedirect(request.getContextPath() + "/hr/payroll");
                    return;
                }
                boolean success = payrollDAO.submitPayrollForApproval(payrollId);
                if (success) {
                    request.getSession().setAttribute("successMessage", "Đã gửi duyệt bảng lương thành công.");
                } else {
                    request.getSession().setAttribute("errorMessage", "Gửi duyệt thất bại (chỉ bảng lương Draft hoặc Rejected mới có thể gửi duyệt).");
                }
                response.sendRedirect(request.getContextPath() + "/hr/payroll?month=" + p.getMonth() + "&year=" + p.getYear());
            } catch (NumberFormatException e) {
                request.getSession().setAttribute("errorMessage", "ID không hợp lệ.");
                response.sendRedirect(request.getContextPath() + "/hr/payroll");
            }
        } else if (monthStr != null && yearStr != null) {
            // Submit monthly
            try {
                int month = Integer.parseInt(monthStr);
                int year = Integer.parseInt(yearStr);
                int count = payrollDAO.submitMonthlyPayrollForApproval(month, year);
                request.getSession().setAttribute("successMessage", "Đã đệ trình duyệt thành công " + count + " bảng lương.");
                response.sendRedirect(request.getContextPath() + "/hr/payroll?month=" + month + "&year=" + year);
            } catch (NumberFormatException e) {
                request.getSession().setAttribute("errorMessage", "Tháng hoặc năm không hợp lệ.");
                response.sendRedirect(request.getContextPath() + "/hr/payroll");
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/hr/payroll");
        }
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

    private void exportExcel(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int month = getParamOrDefault(request, "month", getCurrentMonth());
        int year = getParamOrDefault(request, "year", getCurrentYear());

        List<Payroll> list = payrollDAO.getPayrollsWithNames(month, year);

        // Set response headers for XLS download (HTML-based Excel)
        String fileName = "BangLuong_Thang" + month + "_" + year + ".xls";
        response.setContentType("application/vnd.ms-excel; charset=UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");
        response.setCharacterEncoding("UTF-8");

        try (PrintWriter writer = response.getWriter()) {
            writer.println("<html xmlns:o=\"urn:schemas-microsoft-com:office:office\" xmlns:x=\"urn:schemas-microsoft-com:office:excel\" xmlns=\"http://www.w3.org/TR/REC-html40\">");
            writer.println("<head>");
            writer.println("<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">");
            writer.println("<!--[if gte mso 9]>");
            writer.println("<xml>");
            writer.println(" <x:ExcelWorkbook>");
            writer.println("  <x:ExcelWorksheets>");
            writer.println("   <x:ExcelWorksheet>");
            writer.println("    <x:Name>Bảng Lương Tháng " + month + "-" + year + "</x:Name>");
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
            writer.println("  .title-row { font-size: 16pt; font-weight: bold; color: #1e293b; text-align: center; height: 40px; }");
            writer.println("  .subtitle-row { font-size: 11pt; color: #64748b; text-align: center; height: 25px; }");
            writer.println("  th { background-color: #6366f1; color: #ffffff; font-weight: bold; border: 0.5pt solid #cbd5e1; text-align: center; vertical-align: middle; height: 30px; font-size: 10pt; }");
            writer.println("  td { border: 0.5pt solid #e2e8f0; vertical-align: middle; height: 25px; font-size: 10pt; }");
            writer.println("  .text-center { text-align: center; }");
            writer.println("  .text-left { text-align: left; }");
            writer.println("  .text-right { text-align: right; }");
            writer.println("  .number-format { mso-number-format: \"\\#\\,\\#\\#0\"; text-align: right; }");
            writer.println("  .decimal-format { mso-number-format: \"0\\.0\"; text-align: center; }");
            writer.println("  .status-draft { background-color: #f1f5f9; color: #475569; text-align: center; font-weight: bold; }");
            writer.println("  .status-pending { background-color: #fef3c7; color: #d97706; text-align: center; font-weight: bold; }");
            writer.println("  .status-approved { background-color: #d1fae5; color: #059669; text-align: center; font-weight: bold; }");
            writer.println("  .status-rejected { background-color: #fee2e2; color: #b91c1c; text-align: center; font-weight: bold; }");
            writer.println("  .status-paid { background-color: #dbeafe; color: #2563eb; text-align: center; font-weight: bold; }");
            writer.println("  .total-label { font-weight: bold; background-color: #f8fafc; border-top: 1pt double #6366f1; border-bottom: 1pt double #6366f1; }");
            writer.println("  .total-val { font-weight: bold; background-color: #f8fafc; mso-number-format: \"\\#\\,\\#\\#0\"; text-align: right; border-top: 1pt double #6366f1; border-bottom: 1pt double #6366f1; }");
            writer.println("</style>");
            writer.println("</head>");
            writer.println("<body>");

            // Title block
            writer.println("<table>");
            writer.println("  <tr><td colspan=\"16\" class=\"title-row\">BẢNG LƯƠNG CHI TIẾT NHÂN VIÊN</td></tr>");
            writer.println("  <tr><td colspan=\"16\" class=\"subtitle-row\">Kỳ lương: Tháng " + month + " năm " + year + "</td></tr>");
            writer.println("  <tr><td colspan=\"16\" style=\"height: 15px;\"></td></tr>");
            writer.println("</table>");

            // Table headers
            writer.println("<table>");
            writer.println("  <thead>");
            writer.println("    <tr>");
            writer.println("      <th style=\"width: 50px;\">STT</th>");
            writer.println("      <th style=\"width: 80px;\">Mã NV</th>");
            writer.println("      <th style=\"width: 200px;\">Họ và tên</th>");
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

            // Totals trackers
            BigDecimal totalBase = BigDecimal.ZERO;
            double totalWorkDays = 0.0;
            BigDecimal totalOT = BigDecimal.ZERO;
            BigDecimal totalAllowance = BigDecimal.ZERO;
            BigDecimal totalBonus = BigDecimal.ZERO;
            BigDecimal totalDeduction = BigDecimal.ZERO;
            BigDecimal totalInsurance = BigDecimal.ZERO;
            BigDecimal totalTax = BigDecimal.ZERO;
            BigDecimal totalGross = BigDecimal.ZERO;
            BigDecimal totalNet = BigDecimal.ZERO;

            int stt = 1;
            for (Payroll p : list) {
                // Accumulate totals
                if (p.getBaseSalary() != null) totalBase = totalBase.add(p.getBaseSalary());
                totalWorkDays += p.getWorkingDays();
                if (p.getOvertimeAmount() != null) totalOT = totalOT.add(p.getOvertimeAmount());
                if (p.getAllowanceAmount() != null) totalAllowance = totalAllowance.add(p.getAllowanceAmount());
                if (p.getBonusAmount() != null) totalBonus = totalBonus.add(p.getBonusAmount());
                if (p.getDeductionAmount() != null) totalDeduction = totalDeduction.add(p.getDeductionAmount());
                if (p.getInsuranceAmount() != null) totalInsurance = totalInsurance.add(p.getInsuranceAmount());
                if (p.getTaxAmount() != null) totalTax = totalTax.add(p.getTaxAmount());
                if (p.getGrossSalary() != null) totalGross = totalGross.add(p.getGrossSalary());
                if (p.getNetSalary() != null) totalNet = totalNet.add(p.getNetSalary());

                // Status style class
                String statusClass = "";
                String statusText = p.getStatus() != null ? p.getStatus() : "";
                if ("Draft".equalsIgnoreCase(statusText)) statusClass = "status-draft";
                else if ("Pending".equalsIgnoreCase(statusText)) statusClass = "status-pending";
                else if ("Approved".equalsIgnoreCase(statusText)) statusClass = "status-approved";
                else if ("Rejected".equalsIgnoreCase(statusText)) statusClass = "status-rejected";
                else if ("Paid".equalsIgnoreCase(statusText)) statusClass = "status-paid";

                writer.println("    <tr>");
                writer.println("      <td class=\"text-center\">" + stt++ + "</td>");
                writer.println("      <td class=\"text-center\">" + p.getUserId() + "</td>");
                writer.println("      <td class=\"text-left\">" + escapeHtml(p.getFullName()) + "</td>");
                writer.println("      <td class=\"text-center\">" + p.getMonth() + "</td>");
                writer.println("      <td class=\"text-center\">" + p.getYear() + "</td>");
                writer.println("      <td class=\"number-format\">" + formatNum(p.getBaseSalary()) + "</td>");
                writer.println("      <td class=\"decimal-format\">" + p.getWorkingDays() + "</td>");
                writer.println("      <td class=\"number-format\">" + formatNum(p.getOvertimeAmount()) + "</td>");
                writer.println("      <td class=\"number-format\">" + formatNum(p.getAllowanceAmount()) + "</td>");
                writer.println("      <td class=\"number-format\">" + formatNum(p.getBonusAmount()) + "</td>");
                writer.println("      <td class=\"number-format\">" + formatNum(p.getDeductionAmount()) + "</td>");
                writer.println("      <td class=\"number-format\">" + formatNum(p.getInsuranceAmount()) + "</td>");
                writer.println("      <td class=\"number-format\">" + formatNum(p.getTaxAmount()) + "</td>");
                writer.println("      <td class=\"number-format\">" + formatNum(p.getGrossSalary()) + "</td>");
                writer.println("      <td class=\"number-format\">" + formatNum(p.getNetSalary()) + "</td>");
                writer.println("      <td class=\"" + statusClass + "\">" + statusText + "</td>");
                writer.println("    </tr>");
            }

            // Totals Row
            writer.println("    <tr>");
            writer.println("      <td colspan=\"3\" class=\"total-label text-center\">TỔNG CỘNG</td>");
            writer.println("      <td class=\"total-label\"></td>");
            writer.println("      <td class=\"total-label\"></td>");
            writer.println("      <td class=\"total-val\">" + totalBase.toPlainString() + "</td>");
            writer.println("      <td class=\"total-label text-center\" style=\"mso-number-format: '0\\.0';\">" + totalWorkDays + "</td>");
            writer.println("      <td class=\"total-val\">" + totalOT.toPlainString() + "</td>");
            writer.println("      <td class=\"total-val\">" + totalAllowance.toPlainString() + "</td>");
            writer.println("      <td class=\"total-val\">" + totalBonus.toPlainString() + "</td>");
            writer.println("      <td class=\"total-val\">" + totalDeduction.toPlainString() + "</td>");
            writer.println("      <td class=\"total-val\">" + totalInsurance.toPlainString() + "</td>");
            writer.println("      <td class=\"total-val\">" + totalTax.toPlainString() + "</td>");
            writer.println("      <td class=\"total-val\">" + totalGross.toPlainString() + "</td>");
            writer.println("      <td class=\"total-val\">" + totalNet.toPlainString() + "</td>");
            writer.println("      <td class=\"total-label\"></td>");
            writer.println("    </tr>");

            writer.println("  </tbody>");
            writer.println("</table>");
            writer.println("</body>");
            writer.println("</html>");
        }
    }

    private String escapeHtml(String val) {
        if (val == null) return "";
        return val.replace("&", "&amp;")
                  .replace("<", "&lt;")
                  .replace(">", "&gt;")
                  .replace("\"", "&quot;")
                  .replace("'", "&#39;");
    }

    private String formatNum(BigDecimal val) {
        return val != null ? val.toPlainString() : "0";
    }

    private void hrApprove(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String idStr = request.getParameter("payrollId");
        String monthStr = request.getParameter("month");
        String yearStr = request.getParameter("year");
        
        int month = getCurrentMonth();
        int year = getCurrentYear();
        try {
            if (monthStr != null) month = Integer.parseInt(monthStr);
            if (yearStr != null) year = Integer.parseInt(yearStr);
        } catch (NumberFormatException ignored) {}

        if (idStr != null) {
            try {
                int payrollId = Integer.parseInt(idStr);
                boolean success = payrollDAO.hrApprovePayroll(payrollId);
                if (success) {
                    request.getSession().setAttribute("successMessage", "HR Manager đã duyệt bảng lương thành công!");
                } else {
                    request.getSession().setAttribute("errorMessage", "Duyệt thất bại. Trạng thái bảng lương không hợp lệ.");
                }
            } catch (NumberFormatException e) {
                request.getSession().setAttribute("errorMessage", "ID không hợp lệ.");
            }
        }
        response.sendRedirect(request.getContextPath() + "/hr/payroll?month=" + month + "&year=" + year);
    }

    private void hrReject(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String idStr = request.getParameter("payrollId");
        String reason = request.getParameter("rejectReason");
        String monthStr = request.getParameter("month");
        String yearStr = request.getParameter("year");

        int month = getCurrentMonth();
        int year = getCurrentYear();
        try {
            if (monthStr != null) month = Integer.parseInt(monthStr);
            if (yearStr != null) year = Integer.parseInt(yearStr);
        } catch (NumberFormatException ignored) {}

        if (idStr != null) {
            try {
                int payrollId = Integer.parseInt(idStr);
                if (reason == null || reason.isBlank()) {
                    reason = "Từ chối bởi HR Manager";
                }
                boolean success = payrollDAO.hrRejectPayroll(payrollId, reason);
                if (success) {
                    request.getSession().setAttribute("successMessage", "Đã từ chối bảng lương thành công.");
                } else {
                    request.getSession().setAttribute("errorMessage", "Từ chối thất bại. Trạng thái bảng lương không hợp lệ.");
                }
            } catch (NumberFormatException e) {
                request.getSession().setAttribute("errorMessage", "ID không hợp lệ.");
            }
        }
        response.sendRedirect(request.getContextPath() + "/hr/payroll?month=" + month + "&year=" + year);
    }

    private void hrApproveAll(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String monthStr = request.getParameter("month");
        String yearStr = request.getParameter("year");

        int month = getCurrentMonth();
        int year = getCurrentYear();
        try {
            if (monthStr != null) month = Integer.parseInt(monthStr);
            if (yearStr != null) year = Integer.parseInt(yearStr);
        } catch (NumberFormatException ignored) {}

        int count = payrollDAO.hrApproveAllPending(month, year);
        request.getSession().setAttribute("successMessage", "HR Manager đã duyệt thành công " + count + " bảng lương!");
        response.sendRedirect(request.getContextPath() + "/hr/payroll?month=" + month + "&year=" + year);
    }

    private int getCurrentMonth() {
        return Calendar.getInstance().get(Calendar.MONTH) + 1;
    }

    private int getCurrentYear() {
        return Calendar.getInstance().get(Calendar.YEAR);
    }
}
