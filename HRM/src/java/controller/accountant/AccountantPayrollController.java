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
            // Lọc chỉ hiển thị các bảng lương đã được Director phê duyệt (Approved) hoặc đã chi trả (Paid)
            payrollList.removeIf(p -> !"Approved".equals(p.getStatus()) && !"Paid".equals(p.getStatus()));

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
                    payrollDAO.markAsPaidWithTracking(payrollId, currentUser.getUserId());
                    
                    // Gửi email ngầm cho 1 người
                    List<Payroll> list = payrollDAO.getByMonthYear(month, year);
                    Payroll target = list.stream().filter(p -> p.getPayrollId() == payrollId).findFirst().orElse(null);
                    if (target != null) {
                        UserDAO userDAO = new UserDAO();
                        User u = userDAO.getUserById(target.getUserId());
                        if (u != null && u.getEmail() != null && !u.getEmail().isBlank()) {
                            final int mailMonth = month;
                            final int mailYear = year;
                            final int accountantId = currentUser.getUserId();
                            new Thread(() -> {
                                try {
                                    service.EmailService emailService = new service.EmailService();
                                    emailService.sendPayrollEmail(u.getEmail(), u.getFullName(), mailMonth, mailYear, target.getNetSalary());
                                } catch (Exception e) {
                                    dao.notificationDAO notiDAO = new dao.notificationDAO();
                                    notiDAO.create(accountantId, "error", "Gửi email lương thất bại", 
                                        "Lỗi gửi email lương cho " + u.getFullName() + " (" + u.getEmail() + ").", 
                                        "/accountant/payroll?month=" + mailMonth + "&year=" + mailYear);
                                }
                            }).start();
                        }
                    }
                    
                    session.setAttribute("successMessage", "Đã xác nhận chuyển khoản thành công và đang gửi Email!");
                } catch (NumberFormatException e) {
                    session.setAttribute("errorMessage", "Dữ liệu không hợp lệ.");
                }
            }
        } else if ("markAllPaid".equals(action)) {
            PayrollDAO payrollDAO = new PayrollDAO();
            
            // Lấy danh sách cần gửi email TRƯỚC khi update status
            List<Payroll> approvedList = payrollDAO.getByMonthYear(month, year);
            approvedList.removeIf(p -> !"Approved".equals(p.getStatus()));
            
            int updated = payrollDAO.markAllApprovedAsPaid(month, year, currentUser.getUserId());
            
            if (updated > 0) {
                UserDAO userDAO = new UserDAO();
                final int mailMonth = month;
                final int mailYear = year;
                final int accountantId = currentUser.getUserId();
                new Thread(() -> {
                    service.EmailService emailService = new service.EmailService();
                    dao.notificationDAO notiDAO = new dao.notificationDAO();
                    for (Payroll p : approvedList) {
                        User u = userDAO.getUserById(p.getUserId());
                        if (u != null && u.getEmail() != null && !u.getEmail().isBlank()) {
                            try {
                                emailService.sendPayrollEmail(u.getEmail(), u.getFullName(), mailMonth, mailYear, p.getNetSalary());
                            } catch (Exception e) {
                                notiDAO.create(accountantId, "error", "Gửi email lương thất bại", 
                                    "Lỗi gửi email lương cho " + u.getFullName() + " (" + u.getEmail() + ").", 
                                    "/accountant/payroll?month=" + mailMonth + "&year=" + mailYear);
                            }
                        }
                    }
                }).start();
            }
            
            session.setAttribute("successMessage", "Đã xác nhận chuyển khoản cho " + updated + " nhân viên! Hệ thống đang tự động gửi Email báo lương.");
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

        // Xuất định dạng chuẩn .xlsx của Microsoft Excel
        String fileName = "DanhSachChuyenKhoanLuong_Thang" + month + "_" + year + ".xlsx";
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");

        try (org.apache.poi.xssf.usermodel.XSSFWorkbook workbook = new org.apache.poi.xssf.usermodel.XSSFWorkbook()) {
            org.apache.poi.xssf.usermodel.XSSFSheet sheet = workbook.createSheet("Chuyen Khoan Luong");

            // Tạo CellStyle cho dòng Tiêu đề (Header)
            org.apache.poi.xssf.usermodel.XSSFCellStyle headerStyle = workbook.createCellStyle();
            headerStyle.setFillForegroundColor(org.apache.poi.ss.usermodel.IndexedColors.TEAL.getIndex());
            headerStyle.setFillPattern(org.apache.poi.ss.usermodel.FillPatternType.SOLID_FOREGROUND);
            
            org.apache.poi.xssf.usermodel.XSSFFont headerFont = workbook.createFont();
            headerFont.setColor(org.apache.poi.ss.usermodel.IndexedColors.WHITE.getIndex());
            headerFont.setBold(true);
            headerStyle.setFont(headerFont);

            // Cấu hình format số tiền (VND)
            org.apache.poi.xssf.usermodel.XSSFCellStyle moneyStyle = workbook.createCellStyle();
            org.apache.poi.xssf.usermodel.XSSFDataFormat format = workbook.createDataFormat();
            moneyStyle.setDataFormat(format.getFormat("#,##0"));

            // Khởi tạo dòng Header
            org.apache.poi.ss.usermodel.Row headerRow = sheet.createRow(0);
            String[] columns = {"STT", "Mã NV", "Họ và tên", "Số tài khoản", "Ngân hàng thụ hưởng", "Số tiền chuyển (VND)", "Nội dung chuyển khoản", "Trạng thái"};
            for (int i = 0; i < columns.length; i++) {
                org.apache.poi.ss.usermodel.Cell cell = headerRow.createCell(i);
                cell.setCellValue(columns[i]);
                cell.setCellStyle(headerStyle);
            }

            // Bơm dữ liệu
            int rowNum = 1;
            int stt = 1;
            java.math.BigDecimal totalTransfer = java.math.BigDecimal.ZERO;

            for (Payroll p : list) {
                if (p.getNetSalary() != null) {
                    totalTransfer = totalTransfer.add(p.getNetSalary());
                }

                org.apache.poi.ss.usermodel.Row row = sheet.createRow(rowNum++);
                
                String account = p.getBankAccount() != null ? p.getBankAccount() : "—";
                String bank = p.getBankName() != null ? p.getBankName() : "—";
                String fullName = p.getFullName() != null ? p.getFullName() : "";
                String content = "Chuyen khoan luong thang " + month + "/" + year + " cho " + fullName;
                String statusText = p.getStatus() != null ? p.getStatus() : "Draft";

                // Dịch trạng thái sang tiếng Việt cho Kế toán dễ đọc
                if ("Approved".equalsIgnoreCase(statusText)) statusText = "Chờ CK";
                else if ("Paid".equalsIgnoreCase(statusText)) statusText = "Đã CK";

                row.createCell(0).setCellValue(stt++);
                row.createCell(1).setCellValue(p.getUserId());
                row.createCell(2).setCellValue(fullName);
                row.createCell(3).setCellValue(account);
                row.createCell(4).setCellValue(bank);
                
                org.apache.poi.ss.usermodel.Cell moneyCell = row.createCell(5);
                if (p.getNetSalary() != null) {
                    moneyCell.setCellValue(p.getNetSalary().doubleValue());
                    moneyCell.setCellStyle(moneyStyle);
                } else {
                    moneyCell.setCellValue(0);
                }

                row.createCell(6).setCellValue(content);
                row.createCell(7).setCellValue(statusText);
            }

            // Dòng Tổng Cộng
            org.apache.poi.ss.usermodel.Row totalRow = sheet.createRow(rowNum);
            org.apache.poi.ss.usermodel.Cell totalLabelCell = totalRow.createCell(4);
            totalLabelCell.setCellValue("TỔNG CỘNG:");
            totalLabelCell.setCellStyle(headerStyle); // Dùng lại màu xanh cho nổi

            org.apache.poi.ss.usermodel.Cell totalValueCell = totalRow.createCell(5);
            totalValueCell.setCellValue(totalTransfer.doubleValue());
            totalValueCell.setCellStyle(moneyStyle);

            // Auto-size các cột để vừa nội dung
            for (int i = 0; i < columns.length; i++) {
                sheet.autoSizeColumn(i);
            }

            workbook.write(response.getOutputStream());
        }
    }
}
