package controller.hr;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDate;
import service.EmployeeLifecycleService;
import service.EmployeeLifecycleServiceImpl;

@WebServlet("/hr/terminate-employee")
public class TerminationController extends HttpServlet {

    private EmployeeLifecycleService lifecycleService = new EmployeeLifecycleServiceImpl();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            int userId = Integer.parseInt(req.getParameter("userId"));
            String reason = req.getParameter("reason");
            LocalDate terminationDate = LocalDate.parse(req.getParameter("terminationDate"));

            boolean success = lifecycleService.terminateEmployee(userId, reason, terminationDate);

            if (success) {
                // In a real application, you might redirect to an employee list or show a success message
                req.setAttribute("message", "Employee terminated successfully.");
            } else {
                req.setAttribute("error", "Termination workflow failed. Changes rolled back.");
            }
        } catch (Exception e) {
            req.setAttribute("error", "Invalid input for termination.");
        }
        
        // Forward back to a view, e.g., the termination form (for now, reusing a common HR dashboard or manual form)
        req.getRequestDispatcher("/hr/termination.jsp").forward(req, resp);
    }
}
