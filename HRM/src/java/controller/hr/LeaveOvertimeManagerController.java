package controller.hr;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import service.LeaveAndOvertimeService;
import service.LeaveAndOvertimeServiceImpl;

import java.io.IOException;

@WebServlet(name = "LeaveOvertimeManagerController", urlPatterns = {"/manager/leave-ot"})
public class LeaveOvertimeManagerController extends HttpServlet {

    private LeaveAndOvertimeService service;

    @Override
    public void init() throws ServletException {
        service = new LeaveAndOvertimeServiceImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("currentUser");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        int filterDeptId = user.getDepartmentId();
        // Admins, HR Managers, Factory Managers, Directors, HR Staff can see all pending requests
        if (user.getRoleId() == 1 || user.getRoleId() == 2 || user.getRoleId() == 3 || user.getRoleId() == 4 || user.getRoleId() == 5) {
            filterDeptId = 0;
        }

        request.setAttribute("pendingLeaves", service.getPendingLeavesByDepartment(filterDeptId));
        request.setAttribute("pendingOTs", service.getPendingOTByDepartment(filterDeptId));

        request.getRequestDispatcher("/hr/leave-ot-manager.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("currentUser");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        String type = request.getParameter("type");
        int id = Integer.parseInt(request.getParameter("id"));

        try {
            if ("leave".equals(type)) {
                if ("approve".equals(action)) {
                    service.approveLeaveRequest(id, user.getUserId());
                    session.setAttribute("successMessage", "Leave request approved.");
                } else if ("reject".equals(action)) {
                    service.rejectLeaveRequest(id, user.getUserId());
                    session.setAttribute("successMessage", "Leave request rejected.");
                }
            } else if ("ot".equals(type)) {
                if ("approve".equals(action)) {
                    service.approveOTRequest(id);
                    session.setAttribute("successMessage", "Overtime request approved.");
                } else if ("reject".equals(action)) {
                    service.rejectOTRequest(id);
                    session.setAttribute("successMessage", "Overtime request rejected.");
                }
            }
        } catch (Exception e) {
            session.setAttribute("errorMessage", "Error processing request: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/manager/leave-ot");
    }
}
