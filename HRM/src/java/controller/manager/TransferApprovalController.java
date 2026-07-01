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
 * [NEW FLOW] Luồng phê duyệt điều chuyển 3 bước:
 *   Bước 1: Trưởng phòng cũ (role 2/3/6) duyệt EMPLOYEE_CONFIRMED → MANAGER_APPROVED
 *           URL: /manager/transfer-approvals  (HR Manager cũng duyệt ở đây với tư cách TP)
 *   Bước 2: HR Manager (role 2 only) phê duyệt cuối MANAGER_APPROVED → APPROVED (thực thi DB)
 *           URL: /manager/hr-transfer-confirm  (trang riêng cho HR Manager)
 *   Từ chối: EMPLOYEE_CONFIRMED/MANAGER_APPROVED → REJECTED
 */
@WebServlet(name = "TransferApprovalController", urlPatterns = {
        "/manager/transfer-approvals",
        "/manager/transfer-approval-detail",
        "/manager/transfer-approval/approve",
        "/manager/transfer-approval/reject",
        "/manager/hr-transfer-confirm",
        "/manager/hr-transfer-confirm-detail",
        "/manager/hr-transfer-confirm/approve",
        "/manager/hr-transfer-confirm/reject"
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
            // Bước 1: tất cả role 2/3/6 xem EMPLOYEE_CONFIRMED của phòng mình
            handleListView(request, response, currentUser, roleId);
        } else if ("/manager/transfer-approval-detail".equals(path)) {
            handleDetailView(request, response, currentUser, roleId);
        } else if ("/manager/hr-transfer-confirm".equals(path)) {
            // Bước 2: chỉ HR Manager
            if (roleId != ROLE_HR_MANAGER) {
                response.sendRedirect(request.getContextPath() + "/dashboard");
                return;
            }
            handleHrFinalListView(request, response);
        } else if ("/manager/hr-transfer-confirm-detail".equals(path)) {
            if (roleId != ROLE_HR_MANAGER) {
                response.sendRedirect(request.getContextPath() + "/dashboard");
                return;
            }
            handleHrFinalDetailView(request, response);
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
            String redirectUrl = path.startsWith("/manager/hr-transfer-confirm")
                    ? "/manager/hr-transfer-confirm"
                    : "/manager/transfer-approvals";
            response.sendRedirect(request.getContextPath() + redirectUrl);
            return;
        }

        try {
            int id = Integer.parseInt(idStr);
            TransferRequest tr = trDAO.getById(id);

            if (tr == null) {
                session.setAttribute("errorMessage", "Yêu cầu điều chuyển không tồn tại.");
                String redirectUrl = path.startsWith("/manager/hr-transfer-confirm")
                        ? "/manager/hr-transfer-confirm"
                        : "/manager/transfer-approvals";
                response.sendRedirect(request.getContextPath() + redirectUrl);
                return;
            }

            if ("/manager/transfer-approval/approve".equals(path)) {
                // Bước 1: tất cả role duyệt EMPLOYEE_CONFIRMED → MANAGER_APPROVED
                handleDeptApprove(request, response, session, currentUser, roleId, id, tr);
            } else if ("/manager/transfer-approval/reject".equals(path)) {
                handleDeptReject(request, response, session, currentUser, roleId, id, tr);
            } else if ("/manager/hr-transfer-confirm/approve".equals(path)) {
                // Bước 2: HR Manager duyệt cuối MANAGER_APPROVED → APPROVED
                if (roleId != ROLE_HR_MANAGER) {
                    response.sendRedirect(request.getContextPath() + "/dashboard");
                    return;
                }
                handleHrFinalApprove(request, response, session, currentUser, id, tr);
            } else if ("/manager/hr-transfer-confirm/reject".equals(path)) {
                if (roleId != ROLE_HR_MANAGER) {
                    response.sendRedirect(request.getContextPath() + "/dashboard");
                    return;
                }
                handleHrFinalReject(request, response, session, currentUser, id, tr);
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/manager/transfer-approvals");
        }
    }

    // ─── GET handlers ─ Bước 1 (Trưởng phòng) ────────────────────────────────

    /**
     * Trang danh sách phê duyệt Bước 1:
     * Tất cả role 2/3/6 xem EMPLOYEE_CONFIRMED của phòng MÌNH (theo departmentId).
     */
    private void handleListView(HttpServletRequest request, HttpServletResponse response,
                                User currentUser, int roleId)
            throws ServletException, IOException {

        List<TransferRequest> approvalList =
                trDAO.getEmployeeConfirmedRequestsForManager(currentUser.getDepartmentId());
        request.setAttribute("approvals", approvalList);
        request.setAttribute("viewMode", "DEPT_HEAD_APPROVE");
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

            // HR Manager có thể xem tất cả; Trưởng phòng chỉ xem phòng mình
            if (roleId != ROLE_HR_MANAGER && currentUser.getDepartmentId() != tr.getOldDepartmentId()) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN,
                        "Bạn không có quyền xem yêu cầu của phòng ban khác.");
                return;
            }

            // canAct khi status là EMPLOYEE_CONFIRMED (tất cả role 2/3/6 đều được duyệt Bước 1)
            boolean canAct = "EMPLOYEE_CONFIRMED".equals(tr.getStatus());
            if (!canAct) {
                request.setAttribute("readOnly", true);
            }

            request.setAttribute("req", tr);
            request.setAttribute("currentRoleId", roleId);
            request.getRequestDispatcher("/manager/transfer-approval-detail.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/manager/transfer-approvals");
        }
    }

    // ─── GET handlers ─ Bước 2 (HR Manager xác nhận cuối) ────────────────────

    /**
     * Trang danh sách xác nhận cuối: HR Manager xem MANAGER_APPROVED.
     */
    private void handleHrFinalListView(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<TransferRequest> approvalList = trDAO.getManagerApprovedRequests();
        request.setAttribute("approvals", approvalList);
        request.getRequestDispatcher("/manager/hr-transfer-confirm-list.jsp").forward(request, response);
    }

    private void handleHrFinalDetailView(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/manager/hr-transfer-confirm");
            return;
        }

        try {
            int id = Integer.parseInt(idStr);
            TransferRequest tr = trDAO.getById(id);

            if (tr == null) {
                request.getSession().setAttribute("errorMessage", "Yêu cầu điều chuyển không tồn tại.");
                response.sendRedirect(request.getContextPath() + "/manager/hr-transfer-confirm");
                return;
            }

            boolean canAct = "MANAGER_APPROVED".equals(tr.getStatus());
            if (!canAct) {
                request.setAttribute("readOnly", true);
            }

            request.setAttribute("req", tr);
            request.getRequestDispatcher("/manager/hr-transfer-confirm-detail.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/manager/hr-transfer-confirm");
        }
    }

    // ─── POST handlers ─ Bước 1 ──────────────────────────────────────────────

    private void handleDeptApprove(HttpServletRequest request, HttpServletResponse response,
                                   HttpSession session, User currentUser, int roleId,
                                   int id, TransferRequest tr)
            throws IOException {

        if (!"EMPLOYEE_CONFIRMED".equals(tr.getStatus())) {
            session.setAttribute("errorMessage", "Yêu cầu chưa ở trạng thái chờ Trưởng phòng duyệt.");
            response.sendRedirect(request.getContextPath() + "/manager/transfer-approvals");
            return;
        }

        // Trưởng phòng chỉ duyệt phòng mình (HR Manager được xem tất cả nhưng cũng có dept riêng)
        if (roleId != ROLE_HR_MANAGER && currentUser.getDepartmentId() != tr.getOldDepartmentId()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Bạn không có quyền xử lý yêu cầu của phòng ban khác.");
            return;
        }

        boolean ok = trDAO.managerApproveTransferRequest(id, currentUser.getUserId());
        if (ok) {
            session.setAttribute("successMessage",
                    "Đã phê duyệt Bước 1 thành công. Đơn đang chờ HR Manager xác nhận lần cuối.");
        } else {
            session.setAttribute("errorMessage", "Phê duyệt Bước 1 thất bại. Vui lòng kiểm tra lại.");
        }
        response.sendRedirect(request.getContextPath() + "/manager/transfer-approvals");
    }

    private void handleDeptReject(HttpServletRequest request, HttpServletResponse response,
                                  HttpSession session, User currentUser, int roleId,
                                  int id, TransferRequest tr)
            throws IOException {

        String rejectReason = request.getParameter("rejectReason");
        if (rejectReason == null || rejectReason.trim().isEmpty()) {
            session.setAttribute("errorMessage", "Vui lòng nhập lý do từ chối.");
            response.sendRedirect(request.getContextPath() + "/manager/transfer-approval-detail?id=" + id);
            return;
        }

        if (!"EMPLOYEE_CONFIRMED".equals(tr.getStatus())) {
            session.setAttribute("errorMessage", "Yêu cầu không ở trạng thái có thể từ chối tại đây.");
            response.sendRedirect(request.getContextPath() + "/manager/transfer-approvals");
            return;
        }

        if (roleId != ROLE_HR_MANAGER && currentUser.getDepartmentId() != tr.getOldDepartmentId()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Bạn không có quyền xử lý yêu cầu của phòng ban khác.");
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

    // ─── POST handlers ─ Bước 2 (HR Manager) ────────────────────────────────

    private void handleHrFinalApprove(HttpServletRequest request, HttpServletResponse response,
                                      HttpSession session, User currentUser,
                                      int id, TransferRequest tr)
            throws IOException {

        if (!"MANAGER_APPROVED".equals(tr.getStatus())) {
            session.setAttribute("errorMessage", "Yêu cầu chưa ở trạng thái chờ HR Manager xác nhận cuối.");
            response.sendRedirect(request.getContextPath() + "/manager/hr-transfer-confirm");
            return;
        }

        boolean ok = trDAO.approveTransferRequest(id, currentUser.getUserId());
        if (ok) {
            session.setAttribute("successMessage",
                    "Đã phê duyệt cuối và thực thi điều chuyển nhân viên thành công.");
        } else {
            session.setAttribute("errorMessage",
                    "Phê duyệt cuối thất bại. Vui lòng kiểm tra lại hệ thống (nhân viên có thể chưa có hợp đồng active).");
        }
        response.sendRedirect(request.getContextPath() + "/manager/hr-transfer-confirm");
    }

    private void handleHrFinalReject(HttpServletRequest request, HttpServletResponse response,
                                     HttpSession session, User currentUser,
                                     int id, TransferRequest tr)
            throws IOException {

        String rejectReason = request.getParameter("rejectReason");
        if (rejectReason == null || rejectReason.trim().isEmpty()) {
            session.setAttribute("errorMessage", "Vui lòng nhập lý do từ chối.");
            response.sendRedirect(request.getContextPath() + "/manager/hr-transfer-confirm-detail?id=" + id);
            return;
        }

        if (!"MANAGER_APPROVED".equals(tr.getStatus())) {
            session.setAttribute("errorMessage", "Yêu cầu không ở trạng thái có thể từ chối tại đây.");
            response.sendRedirect(request.getContextPath() + "/manager/hr-transfer-confirm");
            return;
        }

        boolean ok = trDAO.rejectTransferRequest(id, currentUser.getUserId(), rejectReason.trim());
        if (ok) {
            session.setAttribute("successMessage", "Đã từ chối yêu cầu điều chuyển.");
        } else {
            session.setAttribute("errorMessage", "Từ chối thất bại. Vui lòng kiểm tra lại.");
        }
        response.sendRedirect(request.getContextPath() + "/manager/hr-transfer-confirm");
    }
}
