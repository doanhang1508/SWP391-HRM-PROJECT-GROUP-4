package controller.employee;

import dao.ResignationDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.ResignationRequest;
import model.User;

import java.io.IOException;
import java.sql.Date;
import java.util.List;
import dao.EmployeeProfileDAO;
import dao.notificationDAO;

/**
 * ResignationController — Nhân viên tự nộp đơn xin nghỉ việc.
 * URL: /employee/resignation
 * Role: Employee (roleId = 7)
 *
 * GET:  Load danh sách đơn đã nộp của nhân viên hiện tại → forward resignation-form.jsp
 * POST: Validate & insert đơn mới (status = PENDING) → redirect GET (PRG pattern)
 */
@WebServlet(name = "ResignationController", urlPatterns = {"/employee/resignation"})
public class ResignationController extends HttpServlet {

    private ResignationDAO resignationDAO;

    @Override
    public void init() throws ServletException {
        resignationDAO = new ResignationDAO();
    }

    // ── Access Control ─────────────────────────────────────────────────────────

    private boolean checkAccess(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("currentUser") : null;
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return false;
        }
        if (user.getRoleId() != 7) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return false;
        }
        return true;
    }

    // ── GET: hiển thị form + lịch sử ─────────────────────────────────────────

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!checkAccess(req, resp)) return;

        HttpSession session = req.getSession(false);
        User user = (User) session.getAttribute("currentUser");

        List<ResignationRequest> history = resignationDAO.getByUserId(user.getUserId());
        req.setAttribute("resignationHistory", history);

        // Kiểm tra xem nhân viên có đơn đang chờ duyệt không (để ẩn form)
        boolean hasPending = resignationDAO.hasPendingResignation(user.getUserId());
        req.setAttribute("hasPending", hasPending);

        boolean isAlreadyResigned = new EmployeeProfileDAO().isEmployeeAlreadyResigned(user.getUserId());
        req.setAttribute("isAlreadyResigned", isAlreadyResigned);

        req.getRequestDispatcher("/employee/resignation-form.jsp").forward(req, resp);
    }

    // ── POST: nộp đơn mới ─────────────────────────────────────────────────────

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!checkAccess(req, resp)) return;

        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        User user = (User) session.getAttribute("currentUser");

        String action = req.getParameter("action");

        if ("cancel".equals(action)) {
            String idStr = req.getParameter("resignationId");
            try {
                int id = Integer.parseInt(idStr);
                ResignationRequest r = resignationDAO.getById(id);
                if (r != null && r.getUserId() == user.getUserId() && "PENDING".equals(r.getStatus())) {
                    resignationDAO.updateStatus(id, "CANCELLED", "PENDING", 0, null, null);
                    session.setAttribute("successMessage", "Đã hủy đơn xin nghỉ việc.");
                } else {
                    session.setAttribute("errorMessage", "Không thể hủy đơn này.");
                }
            } catch (Exception e) {
                session.setAttribute("errorMessage", "Hủy đơn thất bại.");
            }
            resp.sendRedirect(req.getContextPath() + "/employee/resignation");
            return;
        } else if ("withdraw".equals(action)) {
            String idStr = req.getParameter("resignationId");
            try {
                int id = Integer.parseInt(idStr);
                ResignationRequest r = resignationDAO.getById(id);
                if (r != null && r.getUserId() == user.getUserId() && "APPROVED".equals(r.getStatus())) {
                    EmployeeProfileDAO profileDAO = new EmployeeProfileDAO();
                    if (profileDAO.isEmployeeAlreadyResigned(user.getUserId())) {
                        session.setAttribute("errorMessage", "Hợp đồng đã kết thúc, không thể rút đơn.");
                    } else {
                        // Gọi updateStatus với expectedOldStatus
                        boolean updated = resignationDAO.updateStatus(id, "WITHDRAW_REQUESTED", "APPROVED", 0, null, null);
                        if (updated) {
                            session.setAttribute("successMessage", "Đã gửi yêu cầu rút đơn. Vui lòng chờ HR phê duyệt.");
                            new notificationDAO().create(user.getUserId(), "system", "Yêu cầu rút đơn", "Yêu cầu rút đơn xin nghỉ việc của bạn đã được gửi tới HR.", "/employee/resignation");
                        } else {
                            session.setAttribute("errorMessage", "Đơn đã bị thay đổi, vui lòng tải lại trang.");
                        }
                    }
                } else {
                    session.setAttribute("errorMessage", "Không thể xin rút đơn này.");
                }
            } catch (Exception e) {
                session.setAttribute("errorMessage", "Xin rút đơn thất bại.");
            }
            resp.sendRedirect(req.getContextPath() + "/employee/resignation");
            return;
        }

        String reason          = req.getParameter("reason");
        String desiredLastDateStr = req.getParameter("desiredLastDate");

        // ── Validation ──
        if (reason == null || reason.isBlank()) {
            session.setAttribute("errorMessage", "Vui lòng nhập lý do xin nghỉ việc.");
            resp.sendRedirect(req.getContextPath() + "/employee/resignation");
            return;
        }
        if (desiredLastDateStr == null || desiredLastDateStr.isBlank()) {
            session.setAttribute("errorMessage", "Vui lòng chọn ngày muốn nghỉ.");
            resp.sendRedirect(req.getContextPath() + "/employee/resignation");
            return;
        }

        try {
            Date expectedLeaveDate = Date.valueOf(desiredLastDateStr);
            java.time.LocalDate today = java.time.LocalDate.now();
            java.time.LocalDate leaveDate = expectedLeaveDate.toLocalDate();

            // Ngày nghỉ phải từ hôm nay trở đi
            if (leaveDate.isBefore(today)) {
                session.setAttribute("errorMessage", "Ngày nghỉ phải từ hôm nay trở đi.");
                resp.sendRedirect(req.getContextPath() + "/employee/resignation");
                return;
            }

            int noticePeriodDays = (int) java.time.temporal.ChronoUnit.DAYS.between(today, leaveDate);

            ResignationRequest r = new ResignationRequest();
            r.setUserId(user.getUserId());
            r.setReason(reason.trim());
            r.setDesiredLastDate(expectedLeaveDate);
            r.setExpectedLeaveDate(expectedLeaveDate);
            r.setNoticePeriodDays(noticePeriodDays);

            boolean success = resignationDAO.insert(r);
            if (success) {
                session.setAttribute("successMessage", "Đơn xin nghỉ việc đã được gửi thành công. Vui lòng chờ HR xem xét.");
            } else {
                session.setAttribute("errorMessage",
                    "Gửi đơn thất bại. Có thể bảng resignation_requests chưa tồn tại trong database. " +
                    "Vui lòng liên hệ Admin chạy script resignation_migration.sql và thử lại.");
            }

        } catch (IllegalArgumentException e) {
            session.setAttribute("errorMessage", "Định dạng ngày không hợp lệ: " + e.getMessage());
        } catch (Exception e) {
            String msg = e.getMessage() != null ? e.getMessage() : e.getClass().getSimpleName();
            System.err.println("[ResignationController] Lỗi khi gửi đơn: " + msg);
            session.setAttribute("errorMessage", "Lỗi hệ thống khi gửi đơn: " + msg);
        }

        // PRG pattern: redirect về GET để tránh double-submit
        resp.sendRedirect(req.getContextPath() + "/employee/resignation");
    }
}
