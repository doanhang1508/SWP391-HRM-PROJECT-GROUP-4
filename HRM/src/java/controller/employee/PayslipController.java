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
import util.DBContext;
import dao.EmployeeContractDAO;
import dao.InsuranceRateDAO;
import dao.PayrollConfigDAO;
import dao.RewardDisciplineDAO;
import model.EmployeeContract;
import model.EmployeeRewardDiscipline;
import model.InsuranceRate;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/**
 * Personal PayslipController
 * URL: /employee/payslip
 *
 * GET (no action) → Hiển thị danh sách phiếu lương của nhân viên đang đăng nhập
 * GET action=view  → Xem chi tiết 1 phiếu lương
 *
 * Chỉ hiển thị payroll có status Approved hoặc Paid.
 */
@WebServlet(name = "PayslipController", urlPatterns = {"/employee/payslip"})
public class PayslipController extends HttpServlet {

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
        if (action == null) {
            action = "list";
        }

        if ("details_json".equals(action)) {
            getPayslipDetailsJson(request, response, currentUser.getUserId());
            return;
        }

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
                        response.sendRedirect(request.getContextPath() + "/employee/payslip");
                        return;
                    }
                } catch (NumberFormatException e) {
                    response.sendRedirect(request.getContextPath() + "/employee/payslip");
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
                    response.sendRedirect(request.getContextPath() + "/employee/payslip");
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

    private void getPayslipDetailsJson(HttpServletRequest request, HttpServletResponse response, int loggedInUserId) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String userIdStr = request.getParameter("userId");
        String monthStr = request.getParameter("month");
        String yearStr = request.getParameter("year");

        if (userIdStr == null || monthStr == null || yearStr == null) {
            response.getWriter().write("{\"error\": \"Missing parameters\"}");
            return;
        }

        try {
            int requestedUserId = Integer.parseInt(userIdStr);
            if (requestedUserId != loggedInUserId) {
                response.getWriter().write("{\"error\": \"Unauthorized\"}");
                return;
            }

            int month = Integer.parseInt(monthStr);
            int year = Integer.parseInt(yearStr);

            Payroll p = payrollDAO.getPayroll(requestedUserId, month, year);
            if (p == null || (!"Approved".equals(p.getStatus()) && !"Paid".equals(p.getStatus()))) {
                response.getWriter().write("{\"error\": \"Payroll not found or not approved\"}");
                return;
            }

            StringBuilder json = new StringBuilder();
            json.append("{");

            // D\u00f9ng getPayrollStandardWorkDays \u0111\u1ec3 hi\u1ec3n th\u1ecb c\u00f9ng m\u1eabu s\u1ed1 v\u1edbi generatePayrollDraft.
            BigDecimal standardWorkDays = new BigDecimal(new dao.HolidayDAO().getPayrollStandardWorkDays(month, year));
            BigDecimal baseWorkedSalary = BigDecimal.ZERO;
            if (standardWorkDays.compareTo(BigDecimal.ZERO) > 0) {
                BigDecimal daysRatio = new BigDecimal(p.getWorkingDays()).divide(standardWorkDays, 4, java.math.RoundingMode.HALF_UP);
                baseWorkedSalary = p.getBaseSalary().multiply(daysRatio).setScale(2, java.math.RoundingMode.HALF_UP);
            }
            json.append("\"baseSalary\":").append(p.getBaseSalary()).append(",");
            json.append("\"baseWorkedSalary\":").append(baseWorkedSalary).append(",");
            json.append("\"workingDays\":").append(p.getWorkingDays()).append(",");
            json.append("\"standardWorkDays\":").append(standardWorkDays).append(",");
            json.append("\"insuranceBenefit\":").append(p.getInsuranceBenefit() != null ? p.getInsuranceBenefit() : BigDecimal.ZERO).append(",");
            json.append("\"insuranceBaseAmount\":").append(p.getInsuranceBaseAmount() != null ? p.getInsuranceBaseAmount() : BigDecimal.ZERO).append(",");
            json.append("\"taxableIncomeBase\":").append(p.getTaxableIncomeBase() != null ? p.getTaxableIncomeBase() : BigDecimal.ZERO).append(",");


            dao.AttendanceDAO attDao = new dao.AttendanceDAO();
            BigDecimal overtimeHours = attDao.getTotalOvertimeHoursFromAttendance(requestedUserId, month, year);
            json.append("\"overtimeHours\":").append(overtimeHours).append(",");

            // Tính hourlyRate để phục vụ việc chia nhỏ OT
            BigDecimal hourlyRate = BigDecimal.ZERO;
            if (p.getBaseSalary().compareTo(BigDecimal.ZERO) > 0 && standardWorkDays.compareTo(BigDecimal.ZERO) > 0) {
                BigDecimal monthlyWorkingHours = standardWorkDays.multiply(new BigDecimal("8"));
                hourlyRate = p.getBaseSalary().divide(monthlyWorkingHours, 4, java.math.RoundingMode.HALF_UP);
            }
            List<dao.AttendanceDAO.OvertimeBreakdownItem> otBreakdown = attDao.getOvertimeBreakdown(requestedUserId, month, year, hourlyRate);
            json.append("\"overtimeDetails\":[");
            boolean firstOt = true;
            for (dao.AttendanceDAO.OvertimeBreakdownItem otItem : otBreakdown) {
                if (!firstOt) json.append(",");
                json.append("{");
                json.append("\"type\":\"").append(otItem.getType()).append("\",");
                json.append("\"hours\":").append(otItem.getHours()).append(",");
                json.append("\"multiplier\":").append(otItem.getMultiplier()).append(",");
                json.append("\"amount\":").append(otItem.getAmount());
                json.append("}");
                firstOt = false;
            }
            json.append("],");

            EmployeeContractDAO ecDAO = new EmployeeContractDAO();
            EmployeeContract activeContract = ecDAO.getActiveContract(requestedUserId);
            int activeContractId = (activeContract != null) ? activeContract.getContractId() : 0;
            
            json.append("\"allowances\":[");
            String sqlAllowance = "SELECT a.allowance_name, a.amount, a.calculation_type, a.is_bhxh_applied " +
                                  "FROM position_allowances pa " +
                                  "JOIN allowances a ON pa.allowance_id = a.allowance_id " +
                                  "WHERE pa.position_id = ? AND a.status = 1";
            boolean firstAllow = true;
            
            // Lấy positionId từ hợp đồng
            int positionId = (activeContract != null) ? activeContract.getPositionId() : -1;
            
            if (positionId > 0) {
                try (Connection conn = DBContext.getConnection();
                     PreparedStatement ps = conn.prepareStatement(sqlAllowance)) {
                    ps.setInt(1, positionId);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            if (!firstAllow) json.append(",");
                            json.append("{");
                            json.append("\"name\":\"").append(escapeHtml(rs.getString("allowance_name"))).append("\",");
                            
                            BigDecimal amount = rs.getBigDecimal("amount");
                            String calcType = rs.getString("calculation_type");
                            BigDecimal earned = amount;
                            if ("PER_DAY".equals(calcType) && standardWorkDays.compareTo(BigDecimal.ZERO) > 0) {
                                BigDecimal dailyRate = amount.divide(standardWorkDays, 4, java.math.RoundingMode.HALF_UP);
                                earned = dailyRate.multiply(new BigDecimal(p.getWorkingDays())).setScale(2, java.math.RoundingMode.HALF_UP);
                            }
                            
                            json.append("\"amount\":").append(earned).append(",");
                            json.append("\"isBhxh\":").append(rs.getInt("is_bhxh_applied") == 1);
                            json.append("}");
                            firstAllow = false;
                        }
                    }
                }
            }
            
            // Tinh tham nien — luon chiu BHXH va thue TNCN
            dao.AllowanceDAO alwDao = new dao.AllowanceDAO();
            int tenureMonths = alwDao.getTenureMonths(requestedUserId);
            BigDecimal seniorityAmount = alwDao.getSeniorityAmount(tenureMonths);
            if (seniorityAmount.compareTo(BigDecimal.ZERO) > 0) {
                if (!firstAllow) json.append(",");
                json.append("{");
                json.append("\"name\":\"").append(escapeHtml("Ph\u1ee5 c\u1ea5p th\u00e2m ni\u00ean")).append("\",");
                json.append("\"amount\":").append(seniorityAmount).append(",");
                json.append("\"isBhxh\":true");
                json.append("}");
            }
            
            json.append("],");

            json.append("\"insurances\":[");
            InsuranceRateDAO irDAO = new InsuranceRateDAO();
            List<InsuranceRate> rates = irDAO.getAllActiveRates();
            boolean firstIns = true;
            // Tinh tren nen BHXH (da luu san trong cot insurance_base_amount)
            // = baseSalary + phu cap is_bhxh_applied=1 + thuong is_bhxh_applied=1
            BigDecimal insuranceBase = p.getInsuranceBaseAmount() != null && p.getInsuranceBaseAmount().compareTo(BigDecimal.ZERO) > 0
                    ? p.getInsuranceBaseAmount()
                    : p.getBaseSalary(); // fallback neu ban ghi cu chua co nen BHXH
            for (InsuranceRate r : rates) {
                if ("Employee".equalsIgnoreCase(r.getAppliedTo())) {
                    if (!firstIns) json.append(",");
                    BigDecimal amt = insuranceBase.multiply(r.getRatePercentage()).divide(new BigDecimal("100")).setScale(2, java.math.RoundingMode.HALF_UP);
                    json.append("{");
                    json.append("\"name\":\"").append(escapeHtml(r.getName())).append(" (").append(r.getRatePercentage()).append("%)\",");
                    json.append("\"amount\":").append(amt);
                    json.append("}");
                    firstIns = false;
                }
            }
            json.append("],");

            json.append("\"bonuses\":[");
            RewardDisciplineDAO rdDAO = new RewardDisciplineDAO();
            List<EmployeeRewardDiscipline> erdRecords = rdDAO.getRecordsByUserIdAndMonthYear(requestedUserId, month, year);
            boolean firstBonus = true;
            for (EmployeeRewardDiscipline erd : erdRecords) {
                if ("Reward".equalsIgnoreCase(erd.getType())) {
                    if (!firstBonus) json.append(",");
                    json.append("{");
                    String noteVal = formatNoteSafe(erd.getNote());
                    String note = !noteVal.isEmpty() ? " - " + noteVal : "";
                    json.append("\"name\":\"").append(escapeHtml(erd.getRewardDisciplineName() + note)).append("\",");
                    json.append("\"amount\":").append(erd.getAmount()).append(",");
                    json.append("\"isBhxh\":").append(erd.isBhxhApplied()).append(",");
                    json.append("\"isTaxable\":").append(erd.isTaxable());
                    json.append("}");
                    firstBonus = false;
                }
            }
            json.append("],");

            json.append("\"deductions\":[");
            boolean firstDed = true;
            for (EmployeeRewardDiscipline erd : erdRecords) {
                if ("Discipline".equalsIgnoreCase(erd.getType())) {
                    if (!firstDed) json.append(",");
                    json.append("{");
                    String noteVal = formatNoteSafe(erd.getNote());
                    String note = !noteVal.isEmpty() ? " - " + noteVal : "";
                    json.append("\"name\":\"").append(escapeHtml(erd.getRewardDisciplineName() + note)).append("\",");
                    json.append("\"amount\":").append(erd.getAmount());
                    json.append("}");
                    firstDed = false;
                }
            }
            json.append("],");

            PayrollDAO.TaxProfileInfo taxProfile = payrollDAO.getTaxProfile(requestedUserId);
            json.append("\"taxProfile\":{");
            json.append("\"personalDeduction\":").append(taxProfile.personalDeduction).append(",");
            json.append("\"dependentCount\":").append(taxProfile.dependentCount).append(",");
            json.append("\"dependentDeduction\":").append(taxProfile.dependentDeduction);
            json.append("}");

            json.append("}");
            response.getWriter().write(json.toString());
            
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"error\": \"Server error\"}");
        }
    }

    private String formatNoteSafe(String note) {
        if (note == null) return "";
        if (note.contains("KPI Score:")) {
            try {
                java.util.regex.Pattern p = java.util.regex.Pattern.compile("KPI Score:\\s*([0-9.]+)\\s*%");
                java.util.regex.Matcher m = p.matcher(note);
                if (m.find()) {
                    double val = Double.parseDouble(m.group(1));
                    String formattedVal;
                    if (val == (long) val) {
                        formattedVal = String.format("%d", (long) val);
                    } else {
                        formattedVal = String.format(java.util.Locale.US, "%.1f", val);
                        if (formattedVal.endsWith(".0")) {
                            formattedVal = formattedVal.substring(0, formattedVal.length() - 2);
                        }
                    }
                    return "KPI Score: " + formattedVal + "%";
                }
            } catch (Exception ignored) {}
        }
        return note;
    }

    private String escapeHtml(String val) {
        if (val == null) return "";
        return val.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                  .replace("\"", "&quot;").replace("'", "&#39;");
    }
}
