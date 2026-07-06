package controller.hr;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import scheduler.ResignationSchedulerListener;

import java.io.IOException;

/**
 * Endpoint thủ công để chạy tác vụ Scheduler (Duyệt hết hạn hợp đồng, báo nghỉ).
 * URL: /hr/resignation-process-now
 * Quyền: Admin (1) hoặc HR Manager (2)
 * Chỉ chấp nhận POST.
 */
@WebServlet(name = "ProcessResignationSchedulerController", urlPatterns = {"/hr/resignation-process-now"})
public class ProcessResignationSchedulerController extends HttpServlet {

    private boolean checkAccess(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("currentUser") : null;
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return false;
        }
        if (user.getRoleId() != 1 && user.getRoleId() != 2) {
            session.setAttribute("errorMessage", "Bạn không có quyền thực hiện chức năng này.");
            resp.sendRedirect(req.getContextPath() + "/hr/resignation-approval");
            return false;
        }
        return true;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED, "Chỉ cho phép POST.");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!checkAccess(req, resp)) return;

        try {
            ResignationSchedulerListener.processExpiredContracts();
            ResignationSchedulerListener.processNoticePeriodEnds();
            req.getSession().setAttribute("successMessage", "Đã chạy thủ công Scheduler thành công.");
        } catch (Exception e) {
            req.getSession().setAttribute("errorMessage", "Lỗi khi chạy Scheduler: " + e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/hr/resignation-approval");
    }
}
