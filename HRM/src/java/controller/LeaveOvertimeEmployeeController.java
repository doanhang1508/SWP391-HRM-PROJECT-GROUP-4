package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.LeaveRequest;
import model.User;
import service.LeaveAndOvertimeService;
import service.LeaveAndOvertimeServiceImpl;

import java.io.IOException;
import java.sql.Date;
import java.time.LocalDate;

@WebServlet(name = "LeaveOvertimeEmployeeController", urlPatterns = {"/employee/leave-ot"})
public class LeaveOvertimeEmployeeController extends HttpServlet {

    private LeaveAndOvertimeService service;

    @Override
    public void init() throws ServletException {
        service = new LeaveAndOvertimeServiceImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        int year = LocalDate.now().getYear();
        request.setAttribute("remainingAnnualLeave", service.getRemainingAnnualLeave(user.getUserId(), year));
        request.setAttribute("leaveTypes", service.getAllLeaveTypes());
        request.setAttribute("leaveHistory", service.getLeaveHistoryByUserId(user.getUserId()));
        request.setAttribute("otHistory", service.getOTHistoryByUserId(user.getUserId()));

        request.getRequestDispatcher("/leave-ot-employee.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
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

            } else if ("submitOT".equals(action)) {
                int shiftId = Integer.parseInt(request.getParameter("shiftId"));
                Date workDate = Date.valueOf(request.getParameter("workDate"));
                double hours = Double.parseDouble(request.getParameter("estimatedHours"));
                String reason = request.getParameter("otReason");

                service.submitOTRequest(user.getUserId(), shiftId, workDate, hours, reason);
                session.setAttribute("successMessage", "Overtime request submitted successfully.");
            }
        } catch (Exception e) {
            session.setAttribute("errorMessage", "Error: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/employee/leave-ot");
    }
}
