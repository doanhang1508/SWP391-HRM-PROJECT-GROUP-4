package controller.hr;

import dao.PayrollDAO;
import dao.UserDAO;
import dao.AttendanceDAO;
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
import util.DBContext;
import dao.EmployeeContractDAO;
import dao.InsuranceRateDAO;
import dao.PayrollConfigDAO;
import dao.RewardDisciplineDAO;
import model.EmployeeContract;
import model.EmployeeRewardDiscipline;
import model.InsuranceRate;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet(name = "HrPayrollController", urlPatterns = {"/hr/payroll"})
public class HrPayrollController extends HttpServlet {

    private final PayrollDAO payrollDAO = new PayrollDAO();
    private final UserDAO userDAO = new UserDAO();

    private boolean checkAccess(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("currentUser") : null;
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return false;
        }
        // HR Manager (2) và HR Staff (5)
        if (user.getRoleId() != 2 && user.getRoleId() != 5) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return false;
        }
        return true;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!checkAccess(request, response)) return;
        HttpSession session = request.getSession(false);
        User currentUser = (User) session.getAttribute("currentUser");
        int roleId = currentUser.getRoleId();
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
            case "recalculate" -> recalculatePreview(request, response);
            case "details_json" -> getPayslipDetailsJson(request, response);
            default -> response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!checkAccess(request, response)) return;
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        User currentUser = (User) session.getAttribute("currentUser");
        int roleId = currentUser.getRoleId();

        String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/hr/payroll");
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
            
            AttendanceDAO attendanceDAO = new AttendanceDAO();
            List<AttendanceDAO.MonthYearOption> periods = attendanceDAO.getAvailableAttendancePeriods();
            request.setAttribute("attendancePeriods", periods);
            
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
        String period = request.getParameter("period");
        int month = 0;
        int year = 0;
        if (period != null && !period.isBlank()) {
            try {
                String[] parts = period.split("-");
                if (parts.length == 2) {
                    month = Integer.parseInt(parts[0]);
                    year = Integer.parseInt(parts[1]);
                }
            } catch (NumberFormatException ignored) {}
        }
        
        if (month == 0 || year == 0) {
            month = getParamOrDefault(request, "month", getCurrentMonth());
            year = getParamOrDefault(request, "year", getCurrentYear());
        }

        if (month < 1 || month > 12 || year < 2000) {
            request.getSession().setAttribute("errorMessage", "Tháng hoặc năm không hợp lệ.");
            response.sendRedirect(request.getContextPath() + "/hr/payroll");
            return;
        }

        dao.AttendanceDAO attDAO = new dao.AttendanceDAO();
        if (!attDAO.isMonthLocked(month, year)) {
            request.getSession().setAttribute("errorMessage", "Bảng công tháng " + month + "/" + year + " chưa được khóa. Vui lòng khóa bảng công trước khi tạo bảng lương nháp.");
            response.sendRedirect(request.getContextPath() + "/hr/payroll");
            return;
        }

        dao.TimesheetConfirmationDAO tcDAO = new dao.TimesheetConfirmationDAO();
        java.util.List<String> unapprovedDepts = tcDAO.getUnapprovedDepartments(month, year);
        if (!unapprovedDepts.isEmpty()) {
            request.getSession().setAttribute("errorMessage", "Bảng công chưa được HR Manager duyệt, không thể tạo bảng lương nháp.");
            response.sendRedirect(request.getContextPath() + "/hr/payroll");
            return;
        }

        dao.PayrollDAO.PayrollGenerationResult result = payrollDAO.generatePayrollDraft(month, year);
        if (result.isNoAttendanceData()) {
            request.getSession().setAttribute("errorMessage", "Chưa có dữ liệu chấm công tháng. Vui lòng import chấm công trước khi tạo payroll draft.");
            response.sendRedirect(request.getContextPath() + "/hr/payroll");
        } else {
            String msg = "Khởi tạo bảng lương tháng " + month + "/" + year + " thành công: " +
                         "Tạo mới " + result.getCreatedCount() + ", " +
                         "Cập nhật " + result.getUpdatedCount() + ", " +
                         "Bỏ qua " + result.getSkippedCount() + " (đã duyệt/khóa).";
            request.getSession().setAttribute("successMessage", msg);
            response.sendRedirect(request.getContextPath() + "/hr/payroll?month=" + month + "&year=" + year);
        }
    }

    /**
     * TASK 2: HR chỉ nhập overtime, allowance, bonus, deduction.
     * Insurance và Tax được hệ thống tự động tính lại trong PayrollDAO.updatePayrollDraft().
     */
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

            double workingDays = Double.parseDouble(request.getParameter("workingDays"));
            BigDecimal overtimeAmount = new BigDecimal(request.getParameter("overtimeAmount").replaceAll(",", ""));
            BigDecimal allowanceAmount = new BigDecimal(request.getParameter("allowanceAmount").replaceAll(",", ""));
            BigDecimal bonusAmount = new BigDecimal(request.getParameter("bonusAmount").replaceAll(",", ""));
            BigDecimal deductionAmount = new BigDecimal(request.getParameter("deductionAmount").replaceAll(",", ""));

            if (workingDays < 0) {
                request.getSession().setAttribute("errorMessage", "Số ngày làm việc không được âm.");
                response.sendRedirect(request.getContextPath() + "/hr/payroll?action=edit&id=" + payrollId);
                return;
            }
            if (overtimeAmount.compareTo(BigDecimal.ZERO) < 0 || allowanceAmount.compareTo(BigDecimal.ZERO) < 0
                || bonusAmount.compareTo(BigDecimal.ZERO) < 0 || deductionAmount.compareTo(BigDecimal.ZERO) < 0) {
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
            // Insurance và Tax sẽ được tự động tính trong PayrollDAO.updatePayrollDraft()

            boolean success = payrollDAO.updatePayrollDraft(updateModel);
            if (success) {
                request.getSession().setAttribute("successMessage", "Cập nhật bảng lương nháp thành công. Bảo hiểm và Thuế TNCN đã được tính toán lại tự động.");
            } else {
                request.getSession().setAttribute("errorMessage", "Cập nhật thất bại. Vui lòng kiểm tra lại dữ liệu.");
            }
            response.sendRedirect(request.getContextPath() + "/hr/payroll?month=" + current.getMonth() + "&year=" + current.getYear());
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("errorMessage", "Dữ liệu nhập vào không đúng định dạng số.");
            response.sendRedirect(request.getContextPath() + "/hr/payroll?action=edit&id=" + idStr);
        }
    }

    /**
     * TASK 2: AJAX endpoint — tính toán preview (insurance, tax, gross, net) khi HR thay đổi giá trị.
     * Trả về JSON response. KHÔNG lưu vào DB.
     */
    private void recalculatePreview(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        try {
            int payrollId = Integer.parseInt(request.getParameter("payrollId"));
            BigDecimal overtime = parseBigDecimalSafe(request.getParameter("overtimeAmount"));
            BigDecimal allowance = parseBigDecimalSafe(request.getParameter("allowanceAmount"));
            BigDecimal bonus = parseBigDecimalSafe(request.getParameter("bonusAmount"));
            BigDecimal deduction = parseBigDecimalSafe(request.getParameter("deductionAmount"));
            
            Payroll preview = payrollDAO.recalculatePayrollPreview(payrollId, overtime, allowance, bonus, deduction);
            if (preview == null) {
                response.getWriter().write("{\"error\":\"Không tìm thấy bảng lương\"}");
                return;
            }
            
            String json = "{" +
                "\"insuranceAmount\":" + preview.getInsuranceAmount().toPlainString() + "," +
                "\"taxAmount\":" + preview.getTaxAmount().toPlainString() + "," +
                "\"grossSalary\":" + preview.getGrossSalary().toPlainString() + "," +
                "\"netSalary\":" + preview.getNetSalary().toPlainString() + "," +
                "\"insuranceBenefit\":" + (preview.getInsuranceBenefit() != null ? preview.getInsuranceBenefit().toPlainString() : "0") +
                "}";
            response.getWriter().write(json);
        } catch (NumberFormatException e) {
            response.getWriter().write("{\"error\":\"Dữ liệu không hợp lệ\"}");
        }
    }

    private void getPayslipDetailsJson(HttpServletRequest request, HttpServletResponse response) throws IOException {
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
            int userId = Integer.parseInt(userIdStr);
            int month = Integer.parseInt(monthStr);
            int year = Integer.parseInt(yearStr);

            Payroll p = payrollDAO.getPayroll(userId, month, year);
            if (p == null) {
                response.getWriter().write("{\"error\": \"Payroll not found\"}");
                return;
            }

            StringBuilder json = new StringBuilder();
            json.append("{");

            // Dùng getPayrollStandardWorkDays để hiển thị cùng mẫu số với generatePayrollDraft.
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
            BigDecimal overtimeHours = attDao.getTotalOvertimeHoursFromAttendance(userId, month, year);
            json.append("\"overtimeHours\":").append(overtimeHours).append(",");

            // Tính hourlyRate để phục vụ việc chia nhỏ OT
            BigDecimal hourlyRate = BigDecimal.ZERO;
            if (p.getBaseSalary().compareTo(BigDecimal.ZERO) > 0 && standardWorkDays.compareTo(BigDecimal.ZERO) > 0) {
                BigDecimal monthlyWorkingHours = standardWorkDays.multiply(new BigDecimal("8"));
                hourlyRate = p.getBaseSalary().divide(monthlyWorkingHours, 4, java.math.RoundingMode.HALF_UP);
            }
            List<dao.AttendanceDAO.OvertimeBreakdownItem> otBreakdown = attDao.getOvertimeBreakdown(userId, month, year, hourlyRate);
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
            EmployeeContract activeContract = ecDAO.getActiveContract(userId);
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
            int tenureMonths = alwDao.getTenureMonths(userId);
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
            List<EmployeeRewardDiscipline> erdRecords = rdDAO.getRecordsByUserIdAndMonthYear(userId, month, year);
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

            PayrollDAO.TaxProfileInfo taxProfile = payrollDAO.getTaxProfile(userId);
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

    private BigDecimal parseBigDecimalSafe(String value) {
        if (value == null || value.isBlank()) return BigDecimal.ZERO;
        try {
            return new BigDecimal(value.replaceAll(",", ""));
        } catch (NumberFormatException e) {
            return BigDecimal.ZERO;
        }
    }

    private void submitForApproval(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String idStr = request.getParameter("payrollId");
        String monthStr = request.getParameter("month");
        String yearStr = request.getParameter("year");

        if (idStr != null && !idStr.isBlank()) {
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
        if (val == null || val.isBlank()) return def;
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
            writer.println("  th { background-color: #6366f1; color: #ffffff; font-weight: bold; border: 0.5pt solid #cbd5e1; text-align: center; vertical-align: middle; height: 30px; font-size: 10pt; }");
            writer.println("  td { border: 0.5pt solid #e2e8f0; vertical-align: middle; height: 25px; font-size: 10pt; }");
            writer.println("  .number-format { mso-number-format: \"\\#\\,\\#\\#0\"; text-align: right; }");
            writer.println("  .status-draft { background-color: #f1f5f9; color: #475569; text-align: center; font-weight: bold; }");
            writer.println("  .status-pending { background-color: #fef3c7; color: #d97706; text-align: center; font-weight: bold; }");
            writer.println("  .status-approved { background-color: #d1fae5; color: #059669; text-align: center; font-weight: bold; }");
            writer.println("  .status-rejected { background-color: #fee2e2; color: #b91c1c; text-align: center; font-weight: bold; }");
            writer.println("  .status-paid { background-color: #dbeafe; color: #2563eb; text-align: center; font-weight: bold; }");
            writer.println("  .total-val { font-weight: bold; background-color: #f8fafc; mso-number-format: \"\\#\\,\\#\\#0\"; text-align: right; }");
            writer.println("</style>");
            writer.println("</head><body>");
            writer.println("<table>");
            writer.println("  <tr><td colspan=\"16\" class=\"title-row\">BẢNG LƯƠNG CHI TIẾT NHÂN VIÊN</td></tr>");
            writer.println("  <tr><td colspan=\"16\" style=\"text-align:center;color:#64748b\">Kỳ lương: Tháng " + month + " năm " + year + "</td></tr>");
            writer.println("</table>");
            writer.println("<table><thead><tr>");
            writer.println("  <th>STT</th><th>Mã NV</th><th>Họ và tên</th><th>Tháng</th><th>Năm</th>");
            writer.println("  <th>Lương cơ bản</th><th>Ngày công</th><th>Tiền tăng ca</th><th>Phụ cấp</th>");
            writer.println("  <th>Thưởng</th><th>Khấu trừ</th><th>Bảo hiểm</th><th>Thuế TNCN</th>");
            writer.println("  <th>Lương Gross</th><th>Lương Net</th><th>Trạng thái</th>");
            writer.println("</tr></thead><tbody>");

            BigDecimal totalBase = BigDecimal.ZERO, totalOT = BigDecimal.ZERO, totalAllowance = BigDecimal.ZERO;
            BigDecimal totalBonus = BigDecimal.ZERO, totalDeduction = BigDecimal.ZERO, totalInsurance = BigDecimal.ZERO;
            BigDecimal totalTax = BigDecimal.ZERO, totalGross = BigDecimal.ZERO, totalNet = BigDecimal.ZERO;
            double totalWorkDays = 0;
            int stt = 1;

            for (Payroll p : list) {
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

                String statusText = p.getStatus() != null ? p.getStatus() : "";
                String statusClass = "";
                if ("Draft".equalsIgnoreCase(statusText)) statusClass = "status-draft";
                else if ("Pending".equalsIgnoreCase(statusText)) statusClass = "status-pending";
                else if ("Approved".equalsIgnoreCase(statusText)) statusClass = "status-approved";
                else if ("Rejected".equalsIgnoreCase(statusText)) statusClass = "status-rejected";
                else if ("Paid".equalsIgnoreCase(statusText)) statusClass = "status-paid";

                writer.println("<tr>");
                writer.println("  <td style=\"text-align:center\">" + stt++ + "</td>");
                writer.println("  <td style=\"text-align:center\">" + p.getUserId() + "</td>");
                writer.println("  <td>" + escapeHtml(p.getFullName()) + "</td>");
                writer.println("  <td style=\"text-align:center\">" + p.getMonth() + "</td>");
                writer.println("  <td style=\"text-align:center\">" + p.getYear() + "</td>");
                writer.println("  <td class=\"number-format\">" + formatNum(p.getBaseSalary()) + "</td>");
                writer.println("  <td style=\"text-align:center\">" + p.getWorkingDays() + "</td>");
                writer.println("  <td class=\"number-format\">" + formatNum(p.getOvertimeAmount()) + "</td>");
                writer.println("  <td class=\"number-format\">" + formatNum(p.getAllowanceAmount()) + "</td>");
                writer.println("  <td class=\"number-format\">" + formatNum(p.getBonusAmount()) + "</td>");
                writer.println("  <td class=\"number-format\">" + formatNum(p.getDeductionAmount()) + "</td>");
                writer.println("  <td class=\"number-format\">" + formatNum(p.getInsuranceAmount()) + "</td>");
                writer.println("  <td class=\"number-format\">" + formatNum(p.getTaxAmount()) + "</td>");
                writer.println("  <td class=\"number-format\">" + formatNum(p.getGrossSalary()) + "</td>");
                writer.println("  <td class=\"number-format\">" + formatNum(p.getNetSalary()) + "</td>");
                writer.println("  <td class=\"" + statusClass + "\">" + statusText + "</td>");
                writer.println("</tr>");
            }

            writer.println("<tr><td colspan=\"3\" style=\"font-weight:bold;text-align:center\">TỔNG CỘNG</td>");
            writer.println("  <td></td><td></td>");
            writer.println("  <td class=\"total-val\">" + totalBase.toPlainString() + "</td>");
            writer.println("  <td style=\"text-align:center;font-weight:bold\">" + totalWorkDays + "</td>");
            writer.println("  <td class=\"total-val\">" + totalOT.toPlainString() + "</td>");
            writer.println("  <td class=\"total-val\">" + totalAllowance.toPlainString() + "</td>");
            writer.println("  <td class=\"total-val\">" + totalBonus.toPlainString() + "</td>");
            writer.println("  <td class=\"total-val\">" + totalDeduction.toPlainString() + "</td>");
            writer.println("  <td class=\"total-val\">" + totalInsurance.toPlainString() + "</td>");
            writer.println("  <td class=\"total-val\">" + totalTax.toPlainString() + "</td>");
            writer.println("  <td class=\"total-val\">" + totalGross.toPlainString() + "</td>");
            writer.println("  <td class=\"total-val\">" + totalNet.toPlainString() + "</td>");
            writer.println("  <td></td></tr>");
            writer.println("</tbody></table></body></html>");
        }
    }

    private String escapeHtml(String val) {
        if (val == null) return "";
        return val.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                  .replace("\"", "&quot;").replace("'", "&#39;");
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
