package controller.employee;

import dao.TransferRequestDAO;
import dao.notificationDAO;
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
 * Controller cho phép Nhân viên xem và xác nhận/từ chối yêu cầu điều chuyển.
 * URL: /employee/transfer-confirm (GET) — Xem danh sách đơn đang chờ xác nhận
 * URL: /employee/transfer-confirm/accept (POST) — Xác nhận đồng ý
 * URL: /employee/transfer-confirm/reject (POST) — Từ chối
 *
 * [NEW FLOW] Đây là Bước 1 trong luồng điều chuyển mới:
 * HR Staff tạo đơn (PENDING) → NV xác nhận → EMPLOYEE_CONFIRMED
 */
@WebServlet(name = "EmployeeTransferController", urlPatterns = {
        "/employee/transfer-confirm",
        "/employee/transfer-confirm/accept",
        "/employee/transfer-confirm/reject"
})
public class EmployeeTransferController extends HttpServlet {

    private final TransferRequestDAO trDAO = new TransferRequestDAO();

    // Các role được phép xem màn hình này (bản thân nhân viên)
    // role 7=Employee, 5=HR Staff, 8=Accountant
    private static final int[] ALLOWED_ROLES = {5, 7, 8};

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");
        if (!isAllowedRole(currentUser.getRoleId())) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        // Lấy danh sách đơn PENDING của chính nhân viên đang đăng nhập
        List<TransferRequest> pendingList = trDAO.getPendingForEmployee(currentUser.getUserId());
        request.setAttribute("pendingTransfers", pendingList);
        request.getRequestDispatcher("/employee/transfer-confirm.jsp").forward(request, response);
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
        if (!isAllowedRole(currentUser.getRoleId())) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        String path = request.getServletPath();
        String requestIdStr = request.getParameter("requestId");

        if (requestIdStr == null || requestIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/employee/transfer-confirm?msg=error");
            return;
        }

        try {
            int requestId = Integer.parseInt(requestIdStr);

            if ("/employee/transfer-confirm/accept".equals(path)) {
                handleAccept(request, response, currentUser, requestId);
            } else if ("/employee/transfer-confirm/reject".equals(path)) {
                handleReject(request, response, currentUser, requestId);
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/employee/transfer-confirm?msg=error");
        }
    }

    /**
     * Nhân viên xác nhận đồng ý điều chuyển: PENDING → EMPLOYEE_CONFIRMED
     */
    private void handleAccept(HttpServletRequest request, HttpServletResponse response,
                              User currentUser, int requestId) throws IOException {
        boolean ok = trDAO.employeeConfirmTransfer(requestId, currentUser.getUserId());
        if (ok) {
            new notificationDAO().create(currentUser.getUserId(), "system", "Đã xác nhận điều chuyển",
                "Bạn đã xác nhận đồng ý với yêu cầu điều chuyển #" + requestId + ".",
                "/employee/transfer-confirm");
            response.sendRedirect(request.getContextPath() + "/employee/transfer-confirm?msg=accept_success");
        } else {
            // Thất bại: đơn không còn PENDING hoặc không thuộc về nhân viên này
            response.sendRedirect(request.getContextPath() + "/employee/transfer-confirm?msg=accept_error");
        }
    }

    /**
     * Nhân viên từ chối điều chuyển: PENDING → EMPLOYEE_REJECTED
     */
    private void handleReject(HttpServletRequest request, HttpServletResponse response,
                              User currentUser, int requestId) throws IOException {
        String rejectReason = request.getParameter("rejectReason");
        if (rejectReason == null || rejectReason.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/employee/transfer-confirm?msg=reject_reason_required");
            return;
        }

        boolean ok = trDAO.employeeRejectTransfer(requestId, currentUser.getUserId(), rejectReason.trim());
        if (ok) {
            new notificationDAO().create(currentUser.getUserId(), "system", "Đã từ chối điều chuyển",
                "Bạn đã từ chối yêu cầu điều chuyển #" + requestId + ".",
                "/employee/transfer-confirm");
            response.sendRedirect(request.getContextPath() + "/employee/transfer-confirm?msg=reject_success");
        } else {
            response.sendRedirect(request.getContextPath() + "/employee/transfer-confirm?msg=reject_error");
        }
    }

    private boolean isAllowedRole(int roleId) {
        for (int r : ALLOWED_ROLES) {
            if (r == roleId) return true;
        }
        return false;
    }
}
