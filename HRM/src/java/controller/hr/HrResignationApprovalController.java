package controller.hr;

import dao.ResignationDAO;
import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.ResignationRequest;
import model.User;

import java.io.IOException;
import java.util.List;

/**
 * HrResignationApprovalController — HR duyệt / từ chối đơn xin nghỉ việc.
 * URL: /hr/resignation-approval
 * Role: HR Manager (roleId=2), HR Staff (roleId=5)
 *
 * GET:  Load danh sách đơn (filter theo ?status=PENDING|APPROVED|REJECTED|all)
 * POST: action=approve → cập nhật APPROVED + gọi UserDAO.approveResignation() (transaction)
 *       action=reject  → cập nhật REJECTED + lưu hr_note (không động users/profiles)
 */
@WebServlet(name = "HrResignationApprovalController", urlPatterns = {"/hr/resignation-approval"})
public class HrResignationApprovalController extends HttpServlet {

    private ResignationDAO resignationDAO;
    private UserDAO        userDAO;

    @Override
    public void init() throws ServletException {
        resignationDAO = new ResignationDAO();
        userDAO        = new UserDAO();
    }

    // ── Access Control ─────────────────────────────────────────────────────────

    /** Kiểm tra quyền truy cập: chỉ HR Manager (roleId=2) và HR Staff (roleId=5) mới xem được */
    private boolean checkAccess(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("currentUser") : null;
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return false;
        }
        if (user.getRoleId() != 2 && user.getRoleId() != 5) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return false;
        }
        return true;
    }

    /** Kiểm tra quyền duyệt: chỉ HR Manager (roleId=2) mới được duyệt/từ chối đơn */
    private boolean checkApprovalAccess(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("currentUser") : null;
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return false;
        }
        if (user.getRoleId() != 2) {
            HttpSession s = req.getSession(false);
            if (s != null) s.setAttribute("errorMessage", "Chỉ HR Manager mới có quyền duyệt đơn xin nghỉ việc.");
            resp.sendRedirect(req.getContextPath() + "/hr/resignation-approval");
            return false;
        }
        return true;
    }

    // ── GET: hiển thị danh sách đơn ──────────────────────────────────────────

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!checkAccess(req, resp)) return;

        String statusFilter = req.getParameter("status");
        List<ResignationRequest> list;

        if (statusFilter == null || statusFilter.isBlank() || "all".equalsIgnoreCase(statusFilter)) {
            list = resignationDAO.getAll();
            statusFilter = "all";
        } else {
            list = resignationDAO.getAllByStatus(statusFilter.toUpperCase());
        }

        req.setAttribute("resignationList", list);
        req.setAttribute("statusFilter", statusFilter);
        req.getRequestDispatcher("/hr/resignation-approval.jsp").forward(req, resp);
    }

    // ── POST: approve hoặc reject ─────────────────────────────────────────────

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // Chỉ HR Manager (roleId=2) mới có quyền duyệt/từ chối
        if (!checkApprovalAccess(req, resp)) return;

        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        User hrUser = (User) session.getAttribute("currentUser");

        String action         = req.getParameter("action");
        String resignationIdStr = req.getParameter("resignationId");

        if (resignationIdStr == null || resignationIdStr.isBlank()) {
            session.setAttribute("errorMessage", "Thiếu thông tin đơn. Vui lòng thử lại.");
            resp.sendRedirect(req.getContextPath() + "/hr/resignation-approval");
            return;
        }

        try {
            int resignationId = Integer.parseInt(resignationIdStr);

            if ("approve".equalsIgnoreCase(action)) {
                handleApprove(req, resp, session, hrUser, resignationId);
            } else if ("reject".equalsIgnoreCase(action)) {
                handleReject(req, resp, session, hrUser, resignationId);
            } else {
                session.setAttribute("errorMessage", "Hành động không hợp lệ.");
                resp.sendRedirect(req.getContextPath() + "/hr/resignation-approval");
            }

        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "ID đơn không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/hr/resignation-approval");
        }
    }

    // ── Private: xử lý Approve ───────────────────────────────────────────────

    private void handleApprove(HttpServletRequest req, HttpServletResponse resp,
                               HttpSession session, User hrUser, int resignationId)
            throws IOException {

        // Lấy thông tin đơn để biết userId
        ResignationRequest rr = resignationDAO.getById(resignationId);
        if (rr == null) {
            session.setAttribute("errorMessage", "Không tìm thấy đơn xin nghỉ việc.");
            resp.sendRedirect(req.getContextPath() + "/hr/resignation-approval");
            return;
        }
        if (!"PENDING".equals(rr.getStatus())) {
            session.setAttribute("errorMessage", "Đơn này đã được xử lý rồi (trạng thái: " + rr.getStatus() + ").");
            resp.sendRedirect(req.getContextPath() + "/hr/resignation-approval");
            return;
        }

        // Bước 1: Cập nhật trạng thái đơn → APPROVED
        boolean updatedRequest = resignationDAO.updateStatus(
                resignationId, "APPROVED", hrUser.getUserId(), null);

        if (!updatedRequest) {
            session.setAttribute("errorMessage", "Cập nhật trạng thái đơn thất bại.");
            resp.sendRedirect(req.getContextPath() + "/hr/resignation-approval");
            return;
        }

        // Bước 2: Transaction vô hiệu hóa tài khoản + cập nhật employment_status_id=4
        boolean deactivated = userDAO.approveResignation(rr.getUserId());

        if (deactivated) {
            session.setAttribute("successMessage",
                    "Đã duyệt đơn nghỉ việc. Tài khoản nhân viên đã được vô hiệu hóa.");
        } else {
            // Đơn đã cập nhật APPROVED nhưng deactivate thất bại — báo lỗi rõ ràng
            session.setAttribute("errorMessage",
                    "Đơn đã duyệt nhưng vô hiệu hóa tài khoản thất bại. Vui lòng kiểm tra lại hồ sơ nhân viên ID=" + rr.getUserId() + ".");
        }

        resp.sendRedirect(req.getContextPath() + "/hr/resignation-approval");
    }

    // ── Private: xử lý Reject ────────────────────────────────────────────────

    private void handleReject(HttpServletRequest req, HttpServletResponse resp,
                              HttpSession session, User hrUser, int resignationId)
            throws IOException {

        ResignationRequest rr = resignationDAO.getById(resignationId);
        if (rr == null) {
            session.setAttribute("errorMessage", "Không tìm thấy đơn xin nghỉ việc.");
            resp.sendRedirect(req.getContextPath() + "/hr/resignation-approval");
            return;
        }
        if (!"PENDING".equals(rr.getStatus())) {
            session.setAttribute("errorMessage", "Đơn này đã được xử lý rồi (trạng thái: " + rr.getStatus() + ").");
            resp.sendRedirect(req.getContextPath() + "/hr/resignation-approval");
            return;
        }

        String hrNote = req.getParameter("hrNote");
        if (hrNote == null || hrNote.isBlank()) {
            session.setAttribute("errorMessage", "Vui lòng nhập lý do từ chối.");
            resp.sendRedirect(req.getContextPath() + "/hr/resignation-approval");
            return;
        }

        // Chỉ cập nhật trạng thái đơn — không động vào users hay employee_profiles
        boolean success = resignationDAO.updateStatus(
                resignationId, "REJECTED", hrUser.getUserId(), hrNote.trim());

        if (success) {
            session.setAttribute("successMessage", "Đã từ chối đơn xin nghỉ việc.");
        } else {
            session.setAttribute("errorMessage", "Từ chối đơn thất bại. Vui lòng thử lại.");
        }

        resp.sendRedirect(req.getContextPath() + "/hr/resignation-approval");
    }
}
