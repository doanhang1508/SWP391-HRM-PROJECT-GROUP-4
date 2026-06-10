package controller.hr;

import dao.PayrollDAO;
import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
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
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "list" -> showList(request, response);
            case "edit" -> showEditForm(request, response);
            default -> response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        switch (action) {
            case "generateDraft" -> generateDraft(request, response);
            case "updateDraft" -> updateDraft(request, response);
            case "submit" -> submitForApproval(request, response);
            default -> response.sendError(HttpServletResponse.SC_NOT_FOUND);
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
        request.setAttribute("payrollList", list);
        request.setAttribute("selectedMonth", month);
        request.setAttribute("selectedYear", year);
        request.setAttribute("viewMode", "employees");

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

    private int getCurrentMonth() {
        return Calendar.getInstance().get(Calendar.MONTH) + 1;
    }

    private int getCurrentYear() {
        return Calendar.getInstance().get(Calendar.YEAR);
    }
}
