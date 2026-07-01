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

/**
 * Luồng phê duyệt 1 bước đơn giản:
 *   Trưởng phòng của phòng ban cũ (role 3/6, hoặc HR Manager role 2 nếu quản lý phòng ban cũ)
 *   duyệt PENDING → APPROVED (thực thi DB trực tiếp) hoặc từ chối PENDING → REJECTED.
 */
@WebServlet(name = "TransferApprovalController", urlPatterns = {
        "/manager/transfer-approvals",
        "/manager/transfer-approval-detail",
        "/manager/transfer-approval/approve",
        "/manager/transfer-approval/reject"
})
public class TransferApprovalController extends HttpServlet {

    private final TransferRequestDAO trDAO = new TransferRequestDAO();

    private static final int ROLE_FACTORY_MANAGER = 3;
    private static final int ROLE_DEPT_MANAGER    = 6;
    private static final int ROLE_HR_MANAGER      = 2;

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

        // Chỉ cho phép các vai trò quản lý
        if (roleId != ROLE_HR_MANAGER && roleId != ROLE_FACTORY_MANAGER && roleId != ROLE_DEPT_MANAGER) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        String path = request.getServletPath();

        if ("/manager/transfer-approvals".equals(path)) {
            handleListView(request, response, currentUser, roleId);
        } else if ("/manager/transfer-approval-detail".equals(path)) {
            handleDetailView(request, response, currentUser, roleId);
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

        if (roleId != ROLE_HR_MANAGER && roleId != ROLE_FACTORY_MANAGER && roleId != ROLE_DEPT_MANAGER) {
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

            if ("/manager/transfer-approval/approve".equals(path)) {
                handleApprove(request, response, session, currentUser, roleId, id, tr);
            } else if ("/manager/transfer-approval/reject".equals(path)) {
                handleReject(request, response, session, currentUser, roleId, id, tr);
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/manager/transfer-approvals");
        }
    }

    // ─── GET handlers ────────────────────────────────────────────────────────

    private void handleListView(HttpServletRequest request, HttpServletResponse response,
                                User currentUser, int roleId)
            throws ServletException, IOException {

        // Lấy tất cả yêu cầu điều chuyển đang PENDING của phòng ban của manager hiện tại
        List<TransferRequest> pendingList = trDAO.getPendingRequestsForManager(currentUser.getDepartmentId());
        request.setAttribute("approvals", pendingList);
        request.getRequestDispatcher("/manager/transfer-approval-list.jsp").forward(request, response);
    }

    private void handleDetailView(HttpServletRequest request, HttpServletResponse response,
                                  User currentUser, int roleId)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/manager/transfer-approvals");
            return;
        }

        try {
            int id = Integer.parseInt(idStr);
            TransferRequest tr = trDAO.getById(id);

            if (tr == null) {
                request.getSession().setAttribute("errorMessage", "Yêu cầu điều chuyển không tồn tại.");
                response.sendRedirect(request.getContextPath() + "/manager/transfer-approvals");
                return;
            }

            // Kiểm tra xem manager hiện tại có đúng là quản lý phòng ban cũ của nhân viên không
            if (currentUser.getDepartmentId() != tr.getOldDepartmentId()) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN,
                        "Bạn không có quyền xem yêu cầu của phòng ban khác.");
                return;
            }

            // Nếu đơn không còn PENDING thì chuyển sang chế độ chỉ đọc
            if (!"PENDING".equals(tr.getStatus())) {
                request.setAttribute("readOnly", true);
            }

            request.setAttribute("req", tr);
            request.setAttribute("currentRoleId", roleId);
            request.getRequestDispatcher("/manager/transfer-approval-detail.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/manager/transfer-approvals");
        }
    }

    // ─── POST handlers ───────────────────────────────────────────────────────

    private void handleApprove(HttpServletRequest request, HttpServletResponse response,
                               HttpSession session, User currentUser, int roleId,
                               int id, TransferRequest tr)
            throws IOException {

        if (!"PENDING".equals(tr.getStatus())) {
            session.setAttribute("errorMessage", "Yêu cầu đã được xử lý hoặc không ở trạng thái Chờ duyệt.");
            response.sendRedirect(request.getContextPath() + "/manager/transfer-approvals");
            return;
        }

        if (currentUser.getDepartmentId() != tr.getOldDepartmentId()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền xử lý yêu cầu của phòng ban khác.");
            return;
        }

        // Thực thi duyệt trực tiếp từ PENDING thành APPROVED và cập nhật hồ sơ, tạo phụ lục hợp đồng
        boolean ok = trDAO.approveTransferRequest(id, currentUser.getUserId());
        if (ok) {
            session.setAttribute("successMessage", "Đã phê duyệt và thực thi điều chuyển nhân viên thành công.");
        } else {
            session.setAttribute("errorMessage", "Phê duyệt thất bại. Vui lòng kiểm tra lại hệ thống (nhân viên có thể chưa có hợp đồng active).");
        }

        response.sendRedirect(request.getContextPath() + "/manager/transfer-approvals");
    }

    private void handleReject(HttpServletRequest request, HttpServletResponse response,
                              HttpSession session, User currentUser, int roleId,
                              int id, TransferRequest tr)
            throws IOException {

        String rejectReason = request.getParameter("rejectReason");
        if (rejectReason == null || rejectReason.trim().isEmpty()) {
            session.setAttribute("errorMessage", "Vui lòng nhập lý do từ chối.");
            response.sendRedirect(request.getContextPath() + "/manager/transfer-approval-detail?id=" + id);
            return;
        }

        if (!"PENDING".equals(tr.getStatus())) {
            session.setAttribute("errorMessage", "Yêu cầu đã được xử lý hoặc không ở trạng thái Chờ duyệt.");
            response.sendRedirect(request.getContextPath() + "/manager/transfer-approvals");
            return;
        }

        if (currentUser.getDepartmentId() != tr.getOldDepartmentId()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền xử lý yêu cầu của phòng ban khác.");
            return;
        }

        boolean ok = trDAO.rejectTransferRequest(id, currentUser.getUserId(), rejectReason.trim());
        if (ok) {
            session.setAttribute("successMessage", "Đã từ chối yêu cầu điều chuyển.");
        } else {
            session.setAttribute("errorMessage", "Từ chối thất bại. Vui lòng kiểm tra lại.");
        }

        response.sendRedirect(request.getContextPath() + "/manager/transfer-approvals");
    }
}
