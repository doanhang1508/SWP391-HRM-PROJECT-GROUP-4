package controller.employee;

import dao.PayrollPeriodDAO;
import dao.EmployeeTaxProfileDAO;
import model.User;
import model.EmployeeTaxProfile;
import service.TaxEngineService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDate;

@WebServlet(name = "EmployeePitController", urlPatterns = {"/employee/pit"})
public class EmployeePitController extends HttpServlet {

    private TaxEngineService taxEngine;
    private EmployeeTaxProfileDAO taxProfileDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        taxEngine = new TaxEngineService();
        taxProfileDAO = new EmployeeTaxProfileDAO();
    }

    private boolean checkAccess(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        User user = (User) req.getSession().getAttribute("currentUser");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return false;
        }
        return true;
    }

    private int getInt(HttpServletRequest req, String param, int defaultVal) {
        try {
            String val = req.getParameter(param);
            if (val != null && !val.isBlank()) {
                return Integer.parseInt(val);
            }
        } catch (NumberFormatException e) {
            // ignore
        }
        return defaultVal;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!checkAccess(req, resp)) return;

        User user = (User) req.getSession().getAttribute("currentUser");
        int userId = user.getUserId();
        
        int month = getInt(req, "month", LocalDate.now().getMonthValue());
        int year = getInt(req, "year", LocalDate.now().getYear());

        TaxEngineService.TaxResult result = taxEngine.calculateForEmployee(userId, month, year);
        EmployeeTaxProfile profile = taxProfileDAO.getOrCreate(userId);

        req.setAttribute("taxResult", result);
        req.setAttribute("taxProfile", profile);
        req.setAttribute("selectedMonth", month);
        req.setAttribute("selectedYear", year);
        req.setAttribute("userId", userId);

        req.getRequestDispatcher("/employee/pit-detail.jsp").forward(req, resp);
    }
}
