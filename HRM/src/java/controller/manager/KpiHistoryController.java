package controller.manager;

import dao.DepartmentDAO;
import dao.KpiDAO;
import model.Department;
import model.KpiEvaluation;
import model.KpiEvaluationItem;
import model.KpiStatusHistory;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "KpiHistoryController", urlPatterns = {"/manager/kpi-history"})
public class KpiHistoryController extends HttpServlet {

    private final KpiDAO kpiDAO = new KpiDAO();
    private final DepartmentDAO departmentDAO = new DepartmentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("currentUser");
        int roleId = user.getRoleId();

        // Only allow Admin (1), HR Manager (2), Supervisor/Factory Manager (3), Director (4), HR Staff (5), Department Manager (6)
        if (roleId == 7 || roleId == 8) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        // Determine if user can view all company evaluations
        boolean viewAllCompany = (roleId == 1 || roleId == 2 || roleId == 4 || roleId == 5);

        // Fetch inputs
        String monthStr = request.getParameter("month");
        String yearStr = request.getParameter("year");
        String deptStr = request.getParameter("departmentId");
        String viewIdStr = request.getParameter("viewId");

        Integer month = null;
        if (monthStr != null && !monthStr.trim().isEmpty()) {
            try {
                month = Integer.parseInt(monthStr);
            } catch (NumberFormatException ignored) {}
        }

        Integer year = null;
        if (yearStr != null && !yearStr.trim().isEmpty()) {
            try {
                year = Integer.parseInt(yearStr);
            } catch (NumberFormatException ignored) {}
        }

        Integer departmentId = null;
        if (deptStr != null && !deptStr.trim().isEmpty()) {
            try {
                departmentId = Integer.parseInt(deptStr);
            } catch (NumberFormatException ignored) {}
        }

        // Enforce department filter if not authorized to view all company
        if (!viewAllCompany) {
            departmentId = user.getDepartmentId();
        }

        // Fetch filtered data
        List<KpiEvaluation> evaluations = kpiDAO.getEvaluationsHistory(
            month, 
            year, 
            departmentId, 
            user.getUserId(), 
            viewAllCompany
        );

        // Handle single evaluation view modal
        if (viewIdStr != null && !viewIdStr.trim().isEmpty()) {
            try {
                int viewId = Integer.parseInt(viewIdStr);
                KpiEvaluation detailEval = kpiDAO.getEvaluationById(viewId);
                if (detailEval != null) {
                    boolean authorized = viewAllCompany;
                    if (!authorized) {
                        // Find the employee's department
                        dao.UserDAO userDAO = new dao.UserDAO();
                        User employee = userDAO.getUserById(detailEval.getEmployeeId());
                        if (employee != null) {
                            authorized = (employee.getDepartmentId() == user.getDepartmentId());
                        }
                    }
                    
                    if (authorized) {
                        List<KpiEvaluationItem> detailItems = kpiDAO.getEvaluationItems(viewId);
                        List<KpiStatusHistory> statusHistory = kpiDAO.getStatusHistory(viewId);
                        
                        request.setAttribute("detailEval", detailEval);
                        request.setAttribute("detailItems", detailItems);
                        request.setAttribute("statusHistory", statusHistory);
                    }
                }
            } catch (NumberFormatException ignored) {}
        }

        // Fetch list of departments for dropdown
        List<Department> departments = departmentDAO.getAll();

        // Fetch unique years from cycle data for dropdown
        List<Integer> years = kpiDAO.getUniqueCycleYears();

        // Build list of months (1-12)
        List<Integer> months = new ArrayList<>();
        for (int m = 1; m <= 12; m++) {
            months.add(m);
        }

        // Set attributes
        request.setAttribute("evaluations", evaluations);
        request.setAttribute("departments", departments);
        request.setAttribute("years", years);
        request.setAttribute("months", months);

        request.setAttribute("selectedMonth", month);
        request.setAttribute("selectedYear", year);
        request.setAttribute("selectedDeptId", departmentId);
        request.setAttribute("viewAllCompany", viewAllCompany);

        // Forward to the JSP page
        request.getRequestDispatcher("/manager/kpi-history.jsp").forward(request, response);
    }
}
