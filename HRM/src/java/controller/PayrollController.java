package controller;

import dao.PayrollDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDate;
import model.Payroll;
import service.PayrollService;
import service.PayrollServiceImpl;

@WebServlet("/employee/payroll")
public class PayrollController extends HttpServlet {
    private PayrollService payrollService = new PayrollServiceImpl();
    private PayrollDAO payrollDAO = new PayrollDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        if ("calculate".equals(action)) {
            int userId = Integer.parseInt(req.getParameter("userId"));
            int month = Integer.parseInt(req.getParameter("month"));
            int year = Integer.parseInt(req.getParameter("year"));
            payrollService.calculateMonthlyPayroll(userId, month, year);
            resp.sendRedirect(req.getContextPath() + "/employee/payroll?userId=" + userId + "&month=" + month + "&year=" + year);
            return;
        }

        String userIdStr = req.getParameter("userId");
        if (userIdStr != null) {
            int userId = Integer.parseInt(userIdStr);
            int month = req.getParameter("month") != null ? Integer.parseInt(req.getParameter("month")) : LocalDate.now().getMonthValue();
            int year = req.getParameter("year") != null ? Integer.parseInt(req.getParameter("year")) : LocalDate.now().getYear();
            
            Payroll payroll = payrollDAO.getPayroll(userId, month, year);
            req.setAttribute("payroll", payroll);
            req.setAttribute("userId", userId);
            req.setAttribute("month", month);
            req.setAttribute("year", year);
        }
        
        req.getRequestDispatcher("/employee/payslip.jsp").forward(req, resp);
    }
}
