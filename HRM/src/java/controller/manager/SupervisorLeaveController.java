package controller.manager;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import service.LeaveService;
import service.LeaveServiceImpl;

import java.io.IOException;

/**
 * SupervisorLeaveController — Duyệt nghỉ phép cho Supervisor & Dept Manager.
 *
 * URL: /manager/leave
 * Được phép truy cập: role 1 (Admin), 3 (Supervisor), 6 (Dept Manager)
 * JSP: /manager/supervisor-leave-approval.jsp
 *
 * Logic lọc dữ liệu theo phạm vi:
 *   - Supervisor (3) và Dept Manager (6): chỉ thấy nhân viên thuộc department của mình
 *   - Admin (1): thấy toàn bộ (filterDeptId = 0)
 *   - HR Manager (2) đã bị GỠ BỎ QUYỀN DUYỆT NGHỈ PHÉP (Chỉ xem lịch sử tại /hr/leave)
 */
@WebServlet(name = "SupervisorLeaveController", urlPatterns = {"/manager/leave"})
public class SupervisorLeaveController extends HttpServlet {

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

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        int filterDeptId = user.getDepartmentId();

        // Khóa HR Manager (Role 2) - HR Manager không còn quyền duyệt nghỉ phép
        if (user.getRoleId() == 2) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        // Admin (1): xem tất cả
        // Supervisor (3), Dept Manager (6): chỉ xem phạm vi department mình
        if (user.getRoleId() == 1) {
            filterDeptId = 0; // 0 = không lọc, lấy tất cả
        }

        request.setAttribute("pendingLeaves", service.getPendingLeavesByDepartment(filterDeptId));

        request.getRequestDispatcher("/manager/supervisor-leave-approval.jsp").forward(request, response);
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

        // Khóa HR Manager (Role 2) - HR Manager không còn quyền duyệt nghỉ phép
        if (user.getRoleId() == 2) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
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
            }
        } catch (Exception e) {
            session.setAttribute("errorMessage", "Lỗi xử lý yêu cầu: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/manager/leave");
    }
}
