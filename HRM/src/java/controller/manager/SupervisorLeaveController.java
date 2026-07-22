package controller.manager;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import dao.LeaveRequestDAO;
import dao.LeaveRequestDAOImpl;

import java.io.IOException;

/**
 * SupervisorLeaveController — Duyệt nghỉ phép cho Supervisor & Dept Manager.
 *
 * URL: /manager/leave Được phép truy cập: role 1 (Admin), 2 (HR Manager), 3
 * (Supervisor), 6 (Dept Manager) JSP: /manager/supervisor-leave-approval.jsp
 *
 * Logic lọc dữ liệu theo phạm vi: - Supervisor (3), Dept Manager (6) và HR
 * Manager (2): chỉ thấy nhân viên thuộc department của mình - Admin (1): thấy
 * toàn bộ (filterDeptId = 0)
 */
@WebServlet(name = "SupervisorLeaveController", urlPatterns = {"/manager/leave"})
public class SupervisorLeaveController extends HttpServlet {

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
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if (user.getRoleId() != 1 && user.getRoleId() != 2 && user.getRoleId() != 3 && user.getRoleId() != 6) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        int filterDeptId = user.getDepartmentId();

        // Admin (1): xem tất cả
        // Supervisor (3), Dept Manager (6), HR Manager (2): chỉ xem phạm vi department mình
        if (user.getRoleId() == 1) {
            filterDeptId = 0; // 0 = không lọc, lấy tất cả
        }

        request.setAttribute("pendingLeaves", service.getPendingLeavesByDepartment(filterDeptId));
        request.setAttribute("approvedLeaves", service.getApprovedLeavesByDepartment(filterDeptId));
        request.setAttribute("allLeaves", service.getAllLeavesByDepartment(filterDeptId));

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

        if (user.getRoleId() != 1 && user.getRoleId() != 2 && user.getRoleId() != 3 && user.getRoleId() != 6) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        String action = request.getParameter("action");
        String type = request.getParameter("type");
        int id = Integer.parseInt(request.getParameter("id"));

        try {
            if ("leave".equals(type)) {
                model.LeaveRequest leaveRequest = service.getRequestById(id);
                if ("approve".equals(action)) {
                    service.approveLeaveRequest(id, user.getUserId());
                    if (leaveRequest != null) {
                        new dao.notificationDAO().create(leaveRequest.getUserId(), "leave",
                                "Đơn nghỉ phép đã được duyệt",
                                "Quản lý " + user.getFullName() + " đã duyệt đơn nghỉ phép của bạn.",
                                "/employee/leave");
                    }
                    session.setAttribute("successMessage", "Đã duyệt đơn nghỉ phép thành công.");
                } else if ("reject".equals(action)) {
                    String rejectReason = request.getParameter("rejectReason");
                    service.rejectLeaveRequest(id, user.getUserId(), rejectReason);
                    if (leaveRequest != null) {
                        new dao.notificationDAO().create(leaveRequest.getUserId(), "leave",
                                "Đơn nghỉ phép đã bị từ chối",
                                "Quản lý " + user.getFullName() + " đã từ chối đơn nghỉ phép của bạn. Lý do: "
                                + (rejectReason != null ? rejectReason : "Không có lý do"),
                                "/employee/leave");
                    }
                    session.setAttribute("successMessage", "Đã từ chối đơn nghỉ phép.");
                }
            }
        } catch (Exception e) {
            session.setAttribute("errorMessage", "Lỗi xử lý yêu cầu: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/manager/leave");
    }
}
