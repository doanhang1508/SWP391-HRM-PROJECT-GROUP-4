package controller.employee;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.LeaveRequest;
import model.User;
import dao.LeaveRequestDAO;
import dao.LeaveRequestDAOImpl;

import java.io.IOException;
import java.sql.Date;
import java.util.List;
import model.LeaveType;

@WebServlet(name = "EmployeeLeaveController", urlPatterns = {"/employee/leave"})
public class EmployeeLeaveController extends HttpServlet {

    private LeaveRequestDAO service;

    @Override
    public void init() throws ServletException {
        service = new LeaveRequestDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("currentUser");
        
        if (user == null) {
            System.out.println("User is null in EmployeeLeaveController! Redirecting to login...");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if (service == null) {
            service = new LeaveRequestDAOImpl();
        }

        List<LeaveType> leaveTypes = service.getAllLeaveTypes();
        java.util.Map<Integer, Double> balances = new java.util.HashMap<>();
        
        for (model.LeaveType t : leaveTypes) {
            try {
                balances.put(t.getLeaveTypeId(), service.checkRemainingLeaveBalance(user.getUserId(), t.getLeaveTypeId()));
            } catch (Exception e) {
                balances.put(t.getLeaveTypeId(), 0.0);
            }
        }
        
        request.setAttribute("leaveBalances", balances);
        request.setAttribute("leaveTypes", leaveTypes);
        request.setAttribute("leaveHistory", service.getLeaveHistoryByUserId(user.getUserId()));

        request.getRequestDispatcher("/employee/employee-leave.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("currentUser");
        
        if (user == null) {
            System.out.println("User is null in EmployeeLeaveController doPost! Redirecting to login...");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if (service == null) {
            service = new LeaveRequestDAOImpl();
        }

        String action = request.getParameter("action");
        try {
            if ("submitLeave".equals(action)) {
                LeaveRequest lr = new LeaveRequest();
                lr.setUserId(user.getUserId());
                lr.setLeaveTypeId(Integer.parseInt(request.getParameter("leaveTypeId")));
                lr.setStartDate(Date.valueOf(request.getParameter("startDate")));
                lr.setEndDate(Date.valueOf(request.getParameter("endDate")));
                lr.setTotalDays(Double.parseDouble(request.getParameter("totalDays")));
                lr.setReason(request.getParameter("reason"));

                service.submitLeaveRequest(lr);
                session.setAttribute("successMessage", "Leave request submitted successfully.");

            }
        } catch (Exception e) {
            session.setAttribute("errorMessage", "Error: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/employee/leave");
    }
}
