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
import java.time.LocalDate;
import dao.notificationDAO;
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
    private dao.EmployeeProfileDAO profileDAO;

    @Override
    public void init() throws ServletException {
        resignationDAO = new ResignationDAO();
        userDAO        = new UserDAO();
        profileDAO     = new dao.EmployeeProfileDAO();
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
            } else if ("approveWithdraw".equalsIgnoreCase(action)) {
                handleApproveWithdraw(req, resp, session, hrUser, resignationId);
            } else if ("rejectWithdraw".equalsIgnoreCase(action)) {
                handleRejectWithdraw(req, resp, session, hrUser, resignationId);
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

        String lastWorkingDayStr = req.getParameter("lastWorkingDay");
        if (lastWorkingDayStr == null || lastWorkingDayStr.isBlank()) {
            session.setAttribute("errorMessage", "Vui lòng chọn ngày làm việc cuối cùng.");
            resp.sendRedirect(req.getContextPath() + "/hr/resignation-approval");
            return;
        }

        java.sql.Date lastWorkingDay;
        try {
            lastWorkingDay = java.sql.Date.valueOf(lastWorkingDayStr);
            if (lastWorkingDay.toLocalDate().isBefore(LocalDate.now())) {
                session.setAttribute("errorMessage", "Ngày làm việc cuối cùng không được nhỏ hơn hôm nay.");
                resp.sendRedirect(req.getContextPath() + "/hr/resignation-approval");
                return;
            }
        } catch (Exception e) {
            session.setAttribute("errorMessage", "Định dạng ngày không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/hr/resignation-approval");
            return;
        }

        int currentStatus = profileDAO.getEmploymentStatusId(rr.getUserId());
        
        boolean transactionSuccess = resignationDAO.approveResignationRequestTransaction(
                resignationId, rr.getUserId(), hrUser.getUserId(), lastWorkingDay, currentStatus);

        if (transactionSuccess) {
            String[] items = {"Laptop", "ID Card", "Uniform", "Document", "Knowledge Transfer", "Company Assets"};
            for(String item : items) {
                resignationDAO.insertChecklistItem(resignationId, item);
            }
            new notificationDAO().create(rr.getUserId(), "system", "Đơn nghỉ việc đã duyệt", "Nhân sự đã duyệt đơn nghỉ việc của bạn.", "/employee/resignation");
            session.setAttribute("successMessage", "Đã duyệt đơn nghỉ việc. Nhân viên đang trong thời gian báo trước.");
        } else {
            session.setAttribute("errorMessage", "Cập nhật đơn thất bại hoặc đơn đã bị thay đổi bởi người khác.");
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
                resignationId, "REJECTED", "PENDING", hrUser.getUserId(), hrNote.trim(), null);

        if (success) {
            new notificationDAO().create(rr.getUserId(), "system", "Đơn nghỉ việc bị từ chối", "Đơn xin nghỉ việc của bạn đã bị từ chối.", "/employee/resignation");
            session.setAttribute("successMessage", "Đã từ chối đơn xin nghỉ việc.");
        } else {
            session.setAttribute("errorMessage", "Từ chối đơn thất bại. Có thể đơn đã bị thay đổi.");
        }

        resp.sendRedirect(req.getContextPath() + "/hr/resignation-approval");
    }

    private void handleApproveWithdraw(HttpServletRequest req, HttpServletResponse resp,
                              HttpSession session, User hrUser, int resignationId)
            throws IOException {
        ResignationRequest rr = resignationDAO.getById(resignationId);
        if (rr == null || !"WITHDRAW_REQUESTED".equals(rr.getStatus())) {
            session.setAttribute("errorMessage", "Đơn không ở trạng thái yêu cầu rút.");
            resp.sendRedirect(req.getContextPath() + "/hr/resignation-approval");
            return;
        }

        int previousStatus = 2; // Fallback Active
        if (rr.getPreviousEmploymentStatusId() != null) {
            previousStatus = rr.getPreviousEmploymentStatusId();
        } else {
            System.err.println("[WARNING] Đơn " + resignationId + " không có previous_employment_status_id, fallback về 2.");
        }

        boolean success = resignationDAO.approveWithdrawResignationTransaction(resignationId, rr.getUserId(), hrUser.getUserId(), previousStatus);
        
        if (success) {
            new notificationDAO().create(rr.getUserId(), "system", "Rút đơn được duyệt", "Yêu cầu rút đơn xin nghỉ việc đã được nhân sự phê duyệt.", "/employee/resignation");
            session.setAttribute("successMessage", "Đã duyệt yêu cầu rút đơn.");
        } else {
            session.setAttribute("errorMessage", "Duyệt yêu cầu thất bại. Có thể đơn đã bị thay đổi.");
        }
        resp.sendRedirect(req.getContextPath() + "/hr/resignation-approval");
    }

    private void handleRejectWithdraw(HttpServletRequest req, HttpServletResponse resp,
                              HttpSession session, User hrUser, int resignationId)
            throws IOException {
        ResignationRequest rr = resignationDAO.getById(resignationId);
        if (rr == null || !"WITHDRAW_REQUESTED".equals(rr.getStatus())) {
            session.setAttribute("errorMessage", "Đơn không ở trạng thái yêu cầu rút.");
            resp.sendRedirect(req.getContextPath() + "/hr/resignation-approval");
            return;
        }

        boolean success = resignationDAO.updateStatus(resignationId, "APPROVED", "WITHDRAW_REQUESTED", hrUser.getUserId(), "Từ chối rút đơn", null);
        if (success) {
            new notificationDAO().create(rr.getUserId(), "system", "Rút đơn bị từ chối", "Yêu cầu rút đơn xin nghỉ việc đã bị từ chối.", "/employee/resignation");
            session.setAttribute("successMessage", "Đã từ chối yêu cầu rút đơn.");
        } else {
            session.setAttribute("errorMessage", "Từ chối yêu cầu thất bại.");
        }
        resp.sendRedirect(req.getContextPath() + "/hr/resignation-approval");
    }
}
