package controller.employee;

import model.OvertimeAssignment;
import model.User;
import service.OvertimeService;
import service.OvertimeServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

/**
 * EmployeeOvertimeController — Employee (role 7) Self-Service OT Views.
 *
 * URL  : /employee/overtime
 * Role : All logged-in users (AuthFilter protects /employee/*)
 *
 * Use Case Diagram — Actor: Employee:
 *   - View Assigned OT  → GET action=assigned (default)
 *   - View OT History   → GET action=history
 */
@WebServlet(name = "EmployeeOvertimeController", urlPatterns = {"/employee/overtime"})
public class EmployeeOvertimeController extends HttpServlet {

    private OvertimeService overtimeService;

    @Override
    public void init() throws ServletException {
        overtimeService = new OvertimeServiceImpl();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = getCurrentUser(req);
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");
        if (action == null || action.trim().isEmpty()) action = "assigned";

        switch (action.trim()) {
            case "history":
                showOTHistory(req, resp, user);
                break;
            case "assigned":
            default:
                showAssignedOT(req, resp, user);
                break;
        }
    }

    /**
     * View Assigned OT — Display upcoming OT plans the employee is assigned to.
     */
    private void showAssignedOT(HttpServletRequest req, HttpServletResponse resp, User user)
            throws ServletException, IOException {

        List<OvertimeAssignment> upcoming = overtimeService.getUpcomingAssignmentsByUser(user.getUserId());
        req.setAttribute("upcomingOT", upcoming);
        req.setAttribute("activeTab", "assigned");

        // Also load history for the combined view
        List<OvertimeAssignment> past = overtimeService.getPastAssignmentsByUser(user.getUserId());
        req.setAttribute("pastOT", past);

        req.getRequestDispatcher("/employee/overtime-view.jsp").forward(req, resp);
    }

    /**
     * View OT History — Display past overtime records and their approval statuses.
     */
    private void showOTHistory(HttpServletRequest req, HttpServletResponse resp, User user)
            throws ServletException, IOException {

        List<OvertimeAssignment> past = overtimeService.getPastAssignmentsByUser(user.getUserId());
        req.setAttribute("pastOT", past);
        req.setAttribute("activeTab", "history");

        // Also load upcoming for the combined view
        List<OvertimeAssignment> upcoming = overtimeService.getUpcomingAssignmentsByUser(user.getUserId());
        req.setAttribute("upcomingOT", upcoming);

        req.getRequestDispatcher("/employee/overtime-view.jsp").forward(req, resp);
    }

    private User getCurrentUser(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        return s != null ? (User) s.getAttribute("currentUser") : null;
    }
}
