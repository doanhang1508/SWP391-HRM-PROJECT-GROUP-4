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
import java.util.ArrayList;
import java.util.List;

/**
 * [2-STEP] Luồng phê duyệt 2 bước:
 *   Bước 1: Trưởng phòng CŨ của nhân viên duyệt PENDING → MANAGER_APPROVED
 *   Bước 2: HR Manager (role 2) xác nhận MANAGER_APPROVED → APPROVED
 *
 * ⚠️ EDGE CASE: Nếu HR Manager (role 2) đồng thời là Trưởng phòng của nhân viên
 *    (department_id trùng với old_department_id của đơn), họ phải thực hiện CẢ HAI bước:
 *    - Bước 1: với tư cách Trưởng phòng (PENDING → MANAGER_APPROVED)
 *    - Bước 2: với tư cách HR Manager (MANAGER_APPROVED → APPROVED)
 *
 * Logic quyết định hành động: dựa vào TRẠNG THÁI ĐƠN + PHÒNG BAN, không chỉ roleId.
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

    // ─── Helpers ─────────────────────────────────────────────────────────────

    /**
     * Kiểm tra người dùng có phải là Trưởng phòng của phòng ban cũ trong đơn hay không.
     * Áp dụng cho cả Trưởng phòng thuần (role 3/6) và HR Manager kiêm Trưởng phòng (role 2).
     */
    private boolean isActingAsDeptHead(User user, int roleId, TransferRequest tr) {
        // role 3/6: luôn là Trưởng phòng — kiểm tra phòng ban khớp
        if (roleId == ROLE_FACTORY_MANAGER || roleId == ROLE_DEPT_MANAGER) {
            return user.getDepartmentId() == tr.getOldDepartmentId();
        }
        // role 2 (HR Manager): trưởng phòng kiêm nhiệm — chỉ khi phòng ban trùng
        if (roleId == ROLE_HR_MANAGER) {
            return user.getDepartmentId() == tr.getOldDepartmentId();
        }
        return false;
    }

    // ─── GET handlers ────────────────────────────────────────────────────────

    private void handleListView(HttpServletRequest request, HttpServletResponse response,
                                User currentUser, int roleId)
            throws ServletException, IOException {

        if (roleId == ROLE_HR_MANAGER) {
            // HR Manager luôn thấy danh sách MANAGER_APPROVED (bước 2)
            List<TransferRequest> hrList = trDAO.getManagerApprovedRequests();
            request.setAttribute("approvals", hrList);
            request.setAttribute("viewMode", "HR_CONFIRM");

            // ⚠️ EDGE CASE: Nếu HR Manager cũng là Trưởng phòng của một số nhân viên,
            // họ cũng cần thấy đơn PENDING của phòng mình (để duyệt bước 1)
            if (currentUser.getDepartmentId() > 0) {
                List<TransferRequest> pendingFromMyDept =
                        trDAO.getPendingRequestsForManager(currentUser.getDepartmentId());
                if (!pendingFromMyDept.isEmpty()) {
                    // Gộp 2 danh sách: PENDING (bước 1) + MANAGER_APPROVED (bước 2)
                    List<TransferRequest> combined = new ArrayList<>(pendingFromMyDept);
                    combined.addAll(hrList);
                    request.setAttribute("approvals", combined);
                    request.setAttribute("viewMode", "HR_DUAL"); // HR Manager kiêm Trưởng phòng
                    request.setAttribute("pendingCount", pendingFromMyDept.size());
                    request.setAttribute("hrConfirmCount", hrList.size());
                }
            }

        } else {
            // Trưởng phòng thuần (3/6): chỉ thấy PENDING của phòng mình
            List<TransferRequest> pendingMgr =
                    trDAO.getPendingRequestsForManager(currentUser.getDepartmentId());
            request.setAttribute("approvals", pendingMgr);
            request.setAttribute("viewMode", "DEPT_HEAD_APPROVE");
        }

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

            boolean actingAsDeptHead = isActingAsDeptHead(currentUser, roleId, tr);

            if (roleId == ROLE_FACTORY_MANAGER || roleId == ROLE_DEPT_MANAGER) {
                // Trưởng phòng thuần: chỉ được xem đơn của phòng mình
                if (!actingAsDeptHead) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN,
                            "Bạn không có quyền xem yêu cầu của phòng ban khác.");
                    return;
                }
                if (!"PENDING".equals(tr.getStatus())) {
                    request.setAttribute("readOnly", true);
                }

            } else if (roleId == ROLE_HR_MANAGER) {
                // HR Manager:
                if ("PENDING".equals(tr.getStatus())) {
                    if (actingAsDeptHead) {
                        // Trường hợp kiêm nhiệm: HR Manager duyệt bước 1 với tư cách Trưởng phòng
                        request.setAttribute("hrActingAsDeptHead", true);
                    } else {
                        // HR Manager thuần: không xử lý được PENDING của phòng khác
                        request.setAttribute("readOnly", true);
                    }
                } else if ("MANAGER_APPROVED".equals(tr.getStatus())) {
                    // Bình thường: HR Manager xác nhận bước 2
                    // (không cần set gì thêm)
                } else {
                    request.setAttribute("readOnly", true);
                }
            }

            request.setAttribute("req", tr);
            request.setAttribute("currentRoleId", roleId);
            request.setAttribute("currentUserDeptId", currentUser.getDepartmentId());
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

        boolean actingAsDeptHead = isActingAsDeptHead(currentUser, roleId, tr);

        if ("PENDING".equals(tr.getStatus())) {
            // ── BƯỚC 1: Ai có quyền duyệt? ──────────────────────────────────
            // - Trưởng phòng thuần (3/6) cùng phòng
            // - HR Manager (2) kiêm Trưởng phòng (cùng phòng)
            if (!actingAsDeptHead) {
                session.setAttribute("errorMessage",
                        "Bạn không phải Trưởng phòng của nhân viên này. Không thể duyệt bước 1.");
                response.sendRedirect(request.getContextPath() + "/manager/transfer-approvals");
                return;
            }
            boolean ok = trDAO.managerApproveTransferRequest(id, currentUser.getUserId());
            if (ok) {
                String msg = (roleId == ROLE_HR_MANAGER)
                        ? "Đã duyệt bước 1 (với tư cách Trưởng phòng). Vui lòng quay lại để xác nhận bước 2 với tư cách HR Manager."
                        : "Đã duyệt bước 1 thành công. Yêu cầu đã được chuyển cho HR Manager xác nhận cuối.";
                session.setAttribute("successMessage", msg);
            } else {
                session.setAttribute("errorMessage",
                        "Duyệt bước 1 thất bại. Vui lòng kiểm tra lại trạng thái yêu cầu.");
            }

        } else if ("MANAGER_APPROVED".equals(tr.getStatus())) {
            // ── BƯỚC 2: Chỉ HR Manager (role 2) được xác nhận cuối ──────────
            if (roleId != ROLE_HR_MANAGER) {
                session.setAttribute("errorMessage",
                        "Chỉ HR Manager mới có quyền xác nhận bước 2 cuối cùng.");
                response.sendRedirect(request.getContextPath() + "/manager/transfer-approvals");
                return;
            }
            boolean ok = trDAO.approveTransferRequest(id, currentUser.getUserId());
            if (ok) {
                session.setAttribute("successMessage",
                        "Đã xác nhận và thực thi điều chuyển thành công. Hồ sơ nhân viên đã được cập nhật.");
            } else {
                session.setAttribute("errorMessage",
                        "Xác nhận điều chuyển thất bại. Vui lòng kiểm tra lại hệ thống (nhân viên có thể chưa có hợp đồng active).");
            }

        } else {
            session.setAttribute("errorMessage",
                    "Không thể duyệt. Trạng thái đơn hiện tại: " + tr.getStatus());
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

        boolean actingAsDeptHead = isActingAsDeptHead(currentUser, roleId, tr);

        if ("PENDING".equals(tr.getStatus())) {
            // Từ chối bước 1: phải là Trưởng phòng (kể cả HR Manager kiêm nhiệm)
            if (!actingAsDeptHead) {
                session.setAttribute("errorMessage",
                        "Bạn không phải Trưởng phòng của nhân viên này. Không thể từ chối ở bước 1.");
                response.sendRedirect(request.getContextPath() + "/manager/transfer-approvals");
                return;
            }

        } else if ("MANAGER_APPROVED".equals(tr.getStatus())) {
            // Từ chối bước 2: chỉ HR Manager
            if (roleId != ROLE_HR_MANAGER) {
                session.setAttribute("errorMessage",
                        "Chỉ HR Manager mới có quyền từ chối ở bước 2.");
                response.sendRedirect(request.getContextPath() + "/manager/transfer-approvals");
                return;
            }

        } else {
            session.setAttribute("errorMessage",
                    "Không thể từ chối. Trạng thái đơn hiện tại: " + tr.getStatus());
            response.sendRedirect(request.getContextPath() + "/manager/transfer-approvals");
            return;
        }

        boolean ok = trDAO.rejectTransferRequest(id, currentUser.getUserId(), rejectReason.trim());
        if (ok) {
            session.setAttribute("successMessage", "Đã từ chối yêu cầu điều chuyển.");
        } else {
            session.setAttribute("errorMessage", "Từ chối thất bại. Vui lòng kiểm tra lại trạng thái yêu cầu.");
        }
        response.sendRedirect(request.getContextPath() + "/manager/transfer-approvals");
    }
}
