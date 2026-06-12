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
