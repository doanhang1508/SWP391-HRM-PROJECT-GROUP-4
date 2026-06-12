package controller.director;

import dao.PayrollDAO;
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
 * DirectorPayrollController
 * URL: /director/payroll
 *
 * GET  → Hiển thị danh sách bảng lương Pending theo tháng/năm để Director duyệt
 * POST → Approve / Reject / ApproveAll
 *
 * Chỉ roleId=4 (Director) được truy cập.
 */
@WebServlet(name = "DirectorPayrollController", urlPatterns = {"/director/payroll"})
public class DirectorPayrollController extends HttpServlet {

    private static final int ROLE_DIRECTOR = 4;
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
        if (currentUser.getRoleId() != ROLE_DIRECTOR) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        String monthStr = request.getParameter("month");
        String yearStr = request.getParameter("year");

        if (monthStr == null || monthStr.isBlank() || yearStr == null || yearStr.isBlank()) {
            List<dao.PayrollDAO.PayrollMonthSummary> summaries = payrollDAO.getMonthlySummaries();
            request.setAttribute("monthlySummaries", summaries);
            request.setAttribute("viewMode", "months");
            request.getRequestDispatcher("/director/payroll-approval.jsp").forward(request, response);
            return;
        }

        try {
            int month = Integer.parseInt(monthStr);
            int year = Integer.parseInt(yearStr);

            // Lấy danh sách payroll kèm tên nhân viên
            List<Payroll> payrollList = payrollDAO.getPayrollsWithNames(month, year);

            // Thống kê
            long pendingCount  = payrollList.stream().filter(p -> "Pending".equals(p.getStatus())).count();
            long approvedCount = payrollList.stream().filter(p -> "Approved".equals(p.getStatus())).count();
            long rejectedCount = payrollList.stream().filter(p -> "Rejected".equals(p.getStatus())).count();
            long paidCount     = payrollList.stream().filter(p -> "Paid".equals(p.getStatus())).count();
            long totalCount    = payrollList.size();

            request.setAttribute("payrollList",    payrollList);
            request.setAttribute("selectedMonth",  month);
            request.setAttribute("selectedYear",   year);
            request.setAttribute("month",          month);
            request.setAttribute("year",           year);
            request.setAttribute("pendingCount",   pendingCount);
            request.setAttribute("approvedCount",  approvedCount);
            request.setAttribute("rejectedCount",  rejectedCount);
            request.setAttribute("paidCount",      paidCount);
            request.setAttribute("totalCount",     totalCount);
            request.setAttribute("viewMode",       "employees");

            request.getRequestDispatcher("/director/payroll-approval.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/director/payroll");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null || currentUser.getRoleId() != ROLE_DIRECTOR) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action   = request.getParameter("action");
        String monthStr = request.getParameter("month");
        String yearStr  = request.getParameter("year");

        int month = LocalDate.now().getMonthValue();
        int year  = LocalDate.now().getYear();
        try {
            if (monthStr != null) month = Integer.parseInt(monthStr);
            if (yearStr  != null) year  = Integer.parseInt(yearStr);
        } catch (NumberFormatException ignored) {}

        switch (action != null ? action : "") {
            case "approve" -> {
                String payrollIdStr = request.getParameter("payrollId");
                if (payrollIdStr != null) {
                    try {
                        int payrollId = Integer.parseInt(payrollIdStr);
                        boolean success = payrollDAO.approvePayroll(payrollId, currentUser.getUserId());
                        if (success) {
                            session.setAttribute("successMessage", "Đã duyệt bảng lương thành công!");
                        } else {
                            session.setAttribute("errorMessage", "Không thể duyệt. Bảng lương không ở trạng thái Pending.");
                        }
                    } catch (NumberFormatException e) {
                        session.setAttribute("errorMessage", "Dữ liệu không hợp lệ.");
                    }
                }
            }
            case "reject" -> {
                String payrollIdStr = request.getParameter("payrollId");
                String reason       = request.getParameter("rejectReason");
                if (payrollIdStr != null) {
                    try {
                        int payrollId = Integer.parseInt(payrollIdStr);
                        if (reason == null || reason.isBlank()) {
                            reason = "Không có lý do cụ thể";
                        }
                        boolean success = payrollDAO.rejectPayroll(payrollId, reason);
                        if (success) {
                            session.setAttribute("successMessage", "Đã từ chối bảng lương.");
                        } else {
                            session.setAttribute("errorMessage", "Không thể từ chối. Bảng lương không ở trạng thái Pending.");
                        }
                    } catch (NumberFormatException e) {
                        session.setAttribute("errorMessage", "Dữ liệu không hợp lệ.");
                    }
                }
            }
            case "approveAll" -> {
                int count = payrollDAO.approveAllPending(month, year, currentUser.getUserId());
                session.setAttribute("successMessage", "Đã duyệt thành công " + count + " bảng lương!");
            }
            default -> session.setAttribute("errorMessage", "Hành động không hợp lệ.");
        }

        response.sendRedirect(request.getContextPath() + "/director/payroll?month=" + month + "&year=" + year);
    }
}
