package controller.manager;

import dao.TransferRequestDAO;
import model.TransferRequest;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "TransferApprovalController", urlPatterns = {
        "/manager/transfer-approvals",
        "/manager/transfer-approval-detail",
        "/manager/transfer-approval/approve",
        "/manager/transfer-approval/reject"
})
public class TransferApprovalController extends HttpServlet {

    private final TransferRequestDAO trDAO = new TransferRequestDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");
        int roleId = currentUser.getRoleId();

        // Admin (1), HR Manager (2), Factory Manager (3), Department Manager (6)
        if (roleId != 1 && roleId != 2 && roleId != 3 && roleId != 6) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        String path = request.getServletPath();

        if ("/manager/transfer-approvals".equals(path)) {
            List<TransferRequest> approvals;
            if (roleId == 1 || roleId == 2) {
                // Admin/HR Manager can see all pending requests
                // Let's load all transfer requests and filter for PENDING, or use a filtered query
                approvals = trDAO.getAllTransferRequests();
                approvals.removeIf(req -> !"PENDING".equals(req.getStatus()));
            } else {
                // Factory Manager (3) / Department Manager (6) can see pending requests in their department
                approvals = trDAO.getPendingRequestsForManager(currentUser.getDepartmentId());
            }

            request.setAttribute("approvals", approvals);
            request.getRequestDispatcher("/manager/transfer-approval-list.jsp").forward(request, response);

        } else if ("/manager/transfer-approval-detail".equals(path)) {
            String idStr = request.getParameter("id");
            if (idStr == null || idStr.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/manager/transfer-approvals");
                return;
            }

            try {
                int id = Integer.parseInt(idStr);
                TransferRequest tr = trDAO.getById(id);

                if (tr == null) {
                    session.setAttribute("errorMessage", "Yêu cầu điều chuyển không tồn tại.");
                    response.sendRedirect(request.getContextPath() + "/manager/transfer-approvals");
                    return;
                }

                // Check access control
                if (roleId == 3 || roleId == 6) {
                    if (tr.getOldDepartmentId() != currentUser.getDepartmentId()) {
                        response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền xem yêu cầu của phòng ban khác.");
                        return;
                    }
                }

                request.setAttribute("req", tr);
                request.getRequestDispatcher("/manager/transfer-approval-detail.jsp").forward(request, response);

            } catch (NumberFormatException e) {
                response.sendRedirect(request.getContextPath() + "/manager/transfer-approvals");
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");
        int roleId = currentUser.getRoleId();

        // Admin (1), HR Manager (2), Factory Manager (3), Department Manager (6)
        if (roleId != 1 && roleId != 2 && roleId != 3 && roleId != 6) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        String path = request.getServletPath();
        String idStr = request.getParameter("requestId");

        if (idStr == null || idStr.isEmpty()) {
            session.setAttribute("errorMessage", "Thiếu ID yêu cầu điều chuyển.");
            response.sendRedirect(request.getContextPath() + "/manager/transfer-approvals");
            return;
        }

        try {
            int id = Integer.parseInt(idStr);
            TransferRequest tr = trDAO.getById(id);

            if (tr == null) {
                session.setAttribute("errorMessage", "Yêu cầu điều chuyển không tồn tại.");
                response.sendRedirect(request.getContextPath() + "/manager/transfer-approvals");
                return;
            }

            if (!"PENDING".equals(tr.getStatus())) {
                session.setAttribute("errorMessage", "Yêu cầu này đã được xử lý rồi (Trạng thái: " + tr.getStatus() + ").");
                response.sendRedirect(request.getContextPath() + "/manager/transfer-approvals");
                return;
            }

            // Check access control
            if (roleId == 3 || roleId == 6) {
                if (tr.getOldDepartmentId() != currentUser.getDepartmentId()) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền xử lý yêu cầu của phòng ban khác.");
                    return;
                }
            }

            if ("/manager/transfer-approval/approve".equals(path)) {
                boolean success = trDAO.approveTransferRequest(id, currentUser.getUserId());
                if (success) {
                    session.setAttribute("successMessage", "Đã phê duyệt yêu cầu điều chuyển thành công.");
                } else {
                    session.setAttribute("errorMessage", "Phê duyệt thất bại. Vui lòng kiểm tra lại hệ thống.");
                }
                response.sendRedirect(request.getContextPath() + "/manager/transfer-approvals");

            } else if ("/manager/transfer-approval/reject".equals(path)) {
                String rejectReason = request.getParameter("rejectReason");
                if (rejectReason == null || rejectReason.trim().isEmpty()) {
                    session.setAttribute("errorMessage", "Vui lòng nhập lý do từ chối.");
                    response.sendRedirect(request.getContextPath() + "/manager/transfer-approval-detail?id=" + id);
                    return;
                }

                boolean success = trDAO.rejectTransferRequest(id, currentUser.getUserId(), rejectReason.trim());
                if (success) {
                    session.setAttribute("successMessage", "Đã từ chối yêu cầu điều chuyển.");
                } else {
                    session.setAttribute("errorMessage", "Từ chối yêu cầu thất bại.");
                }
                response.sendRedirect(request.getContextPath() + "/manager/transfer-approvals");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/manager/transfer-approvals");
        }
    }
}
