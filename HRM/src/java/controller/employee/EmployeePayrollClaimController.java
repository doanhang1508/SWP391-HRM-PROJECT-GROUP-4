package controller.employee;

import dao.PayrollDAO;
import dao.PayrollClaimDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.Payroll;
import model.PayrollClaim;
import model.User;

@WebServlet(name = "EmployeePayrollClaimController", urlPatterns = {"/employee/payroll-claim"})
public class EmployeePayrollClaimController extends HttpServlet {

    private final PayrollDAO payrollDAO = new PayrollDAO();
    private final PayrollClaimDAO claimDAO = new PayrollClaimDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String payrollIdStr = request.getParameter("payrollId");
        if (payrollIdStr == null || payrollIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/employee/payroll");
            return;
        }

        try {
            int payrollId = Integer.parseInt(payrollIdStr);
            Payroll p = payrollDAO.getById(payrollId);

            if (p == null || p.getUserId() != currentUser.getUserId()) {
                session.setAttribute("errorMessage", "Không tìm thấy thông tin bảng lương phù hợp.");
                response.sendRedirect(request.getContextPath() + "/employee/payroll");
                return;
            }

            request.setAttribute("payroll", p);
            request.getRequestDispatcher("/employee/payroll-claim.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/employee/payroll");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String payrollIdStr = request.getParameter("payrollId");
        String reason = request.getParameter("reason");

        if (payrollIdStr == null || reason == null || reason.trim().isEmpty()) {
            request.setAttribute("errorMsg", "Vui lòng nhập đầy đủ thông tin khiếu nại.");
            doGet(request, response);
            return;
        }

        try {
            int payrollId = Integer.parseInt(payrollIdStr);
            Payroll p = payrollDAO.getById(payrollId);

            if (p == null || p.getUserId() != currentUser.getUserId()) {
                session.setAttribute("errorMessage", "Không tìm thấy thông tin bảng lương phù hợp.");
                response.sendRedirect(request.getContextPath() + "/employee/payroll");
                return;
            }

            PayrollClaim claim = new PayrollClaim();
            claim.setPayrollId(payrollId);
            claim.setReason(reason.trim());
            claim.setStatus("Pending");

            if (claimDAO.insertClaim(claim)) {
                session.setAttribute("toastSuccess", "Gửi khiếu nại thành công! Vui lòng chờ bộ phận HCNS xử lý.");
            } else {
                session.setAttribute("errorMessage", "Gửi khiếu nại thất bại. Vui lòng thử lại sau.");
            }
            response.sendRedirect(request.getContextPath() + "/employee/payroll");
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/employee/payroll");
        }
    }
}
