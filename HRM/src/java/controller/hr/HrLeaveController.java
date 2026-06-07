package controller.hr;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.LeaveType;
import model.User;
import service.LeaveService;
import service.LeaveServiceImpl;

import java.io.IOException;

@WebServlet(name = "HrLeaveController", urlPatterns = {"/hr/leave"})
public class HrLeaveController extends HttpServlet {

    private LeaveService service;

    @Override
    public void init() throws ServletException {
        service = new LeaveServiceImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("currentUser");

        // Only HR Manager (role 2) or Admin (role 1) allowed
        if (user == null || (user.getRoleId() != 1 && user.getRoleId() != 2)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if (service == null) {
            service = new LeaveServiceImpl();
        }

        String action = request.getParameter("action");

        request.setAttribute("leaveTypes", service.getAllLeaveTypes());
        request.setAttribute("allRequests", service.getAllLeaveRequests());
        request.getRequestDispatcher("/hr/hr-leave-management.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("currentUser");

        if (user == null || (user.getRoleId() != 1 && user.getRoleId() != 2)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if (service == null) {
            service = new LeaveServiceImpl();
        }

        String action = request.getParameter("action");
        try {
            if ("addType".equals(action)) {
                LeaveType type = new LeaveType();
                type.setTypeName(request.getParameter("typeName"));
                type.setDescription(request.getParameter("description"));
                type.setPaidLeave(Integer.parseInt(request.getParameter("paidLeave")));
                String maxDaysStr = request.getParameter("maxDaysPerYear");
                if (maxDaysStr != null && !maxDaysStr.trim().isEmpty()) {
                    type.setMaxDaysPerYear(Integer.parseInt(maxDaysStr));
                }
                type.setStatus(1); // Default active
                service.addLeaveType(type);
                session.setAttribute("successMessage", "Thêm loại nghỉ phép thành công.");
            } else if ("editType".equals(action)) {
                LeaveType type = new LeaveType();
                type.setLeaveTypeId(Integer.parseInt(request.getParameter("leaveTypeId")));
                type.setTypeName(request.getParameter("typeName"));
                type.setDescription(request.getParameter("description"));
                type.setPaidLeave(Integer.parseInt(request.getParameter("paidLeave")));
                String maxDaysStr = request.getParameter("maxDaysPerYear");
                if (maxDaysStr != null && !maxDaysStr.trim().isEmpty()) {
                    type.setMaxDaysPerYear(Integer.parseInt(maxDaysStr));
                }
                type.setStatus(Integer.parseInt(request.getParameter("status")));
                service.updateLeaveType(type);
                session.setAttribute("successMessage", "Cập nhật loại nghỉ phép thành công.");
            } else if ("deleteType".equals(action)) {
                int id = Integer.parseInt(request.getParameter("leaveTypeId"));
                service.deleteLeaveType(id);
                session.setAttribute("successMessage", "Đã xóa (vô hiệu hóa) loại nghỉ phép.");
            }
        } catch (Exception e) {
            session.setAttribute("errorMessage", "Lỗi xử lý: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/hr/leave");
    }
}
