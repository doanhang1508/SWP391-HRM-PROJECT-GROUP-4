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

        // Lấy tháng/năm từ request, mặc định tháng hiện tại
        int month = LocalDate.now().getMonthValue();
        int year  = LocalDate.now().getYear();
        try {
            if (request.getParameter("month") != null) month = Integer.parseInt(request.getParameter("month"));
            if (request.getParameter("year")  != null) year  = Integer.parseInt(request.getParameter("year"));
        } catch (NumberFormatException ignored) {}

        PayrollDAO payrollDAO = new PayrollDAO();
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
        request.setAttribute("month",         month);
        request.setAttribute("year",          year);
        request.setAttribute("totalCount",    totalCount);
        request.setAttribute("approvedCount", approvedCount);
        request.setAttribute("paidCount",     paidCount);

        request.getRequestDispatcher("/accountant/payroll.jsp").forward(request, response);
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
}
