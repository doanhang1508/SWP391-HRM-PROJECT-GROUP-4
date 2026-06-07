package controller.manager;

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

/**
 * LeaveOvertimeManagerController — Duyệt nghỉ phép / OT cho Supervisor & Dept Manager.
 *
 * URL: /manager/leave-ot
 * Được phép truy cập: role 2 (HR Manager), 3 (Supervisor), 6 (Dept Manager)
 * JSP: /manager/leave-ot.jsp
 *
 * Logic lọc dữ liệu theo phạm vi:
 *   - Supervisor (3) và Dept Manager (6): chỉ thấy nhân viên thuộc department của mình
 *   - HR Manager (2) / Admin (1): thấy toàn bộ (filterDeptId = 0)
 */
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

        // Admin (1), HR Manager (2): xem tất cả
        // Supervisor (3), Dept Manager (6): chỉ xem phạm vi department mình
        if (user.getRoleId() == 1 || user.getRoleId() == 2) {
            filterDeptId = 0; // 0 = không lọc, lấy tất cả
        }

        request.setAttribute("pendingLeaves", service.getPendingLeavesByDepartment(filterDeptId));
        request.setAttribute("pendingOTs",    service.getPendingOTByDepartment(filterDeptId));

        request.getRequestDispatcher("/manager/leave-ot.jsp").forward(request, response);
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
        String type   = request.getParameter("type");
        int    id     = Integer.parseInt(request.getParameter("id"));

        try {
            if ("leave".equals(type)) {
                if ("approve".equals(action)) {
                    service.approveLeaveRequest(id, user.getUserId());
                    session.setAttribute("successMessage", "Đã duyệt đơn nghỉ phép thành công.");
                } else if ("reject".equals(action)) {
                    service.rejectLeaveRequest(id, user.getUserId());
                    session.setAttribute("successMessage", "Đã từ chối đơn nghỉ phép.");
                }
            } else if ("ot".equals(type)) {
                if ("approve".equals(action)) {
                    service.approveOTRequest(id);
                    session.setAttribute("successMessage", "Đã duyệt yêu cầu tăng ca thành công.");
                } else if ("reject".equals(action)) {
                    service.rejectOTRequest(id);
                    session.setAttribute("successMessage", "Đã từ chối yêu cầu tăng ca.");
                }
            }
        } catch (Exception e) {
            session.setAttribute("errorMessage", "Lỗi xử lý yêu cầu: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/manager/leave-ot");
    }
}
