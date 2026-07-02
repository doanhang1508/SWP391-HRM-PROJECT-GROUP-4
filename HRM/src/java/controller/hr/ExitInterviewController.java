package controller.hr;

import dao.ResignationDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.ExitInterview;
import model.ResignationRequest;
import model.User;

import java.io.IOException;

@WebServlet(name = "ExitInterviewController", urlPatterns = {"/hr/exit-interview"})
public class ExitInterviewController extends HttpServlet {

    private ResignationDAO resignationDAO;

    @Override
    public void init() throws ServletException {
        resignationDAO = new ResignationDAO();
    }

    private boolean checkAccess(HttpServletRequest req, HttpServletResponse resp) throws IOException {
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

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!checkAccess(req, resp)) return;

        String resignationIdStr = req.getParameter("resignationId");
        if (resignationIdStr == null || resignationIdStr.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/hr/resignation-approval");
            return;
        }

        try {
            int resignationId = Integer.parseInt(resignationIdStr);
            ResignationRequest rr = resignationDAO.getById(resignationId);
            if (rr == null) {
                req.getSession().setAttribute("errorMessage", "Không tìm thấy đơn nghỉ việc.");
                resp.sendRedirect(req.getContextPath() + "/hr/resignation-approval");
                return;
            }

            ExitInterview interview = resignationDAO.getExitInterview(resignationId);
            
            req.setAttribute("resignationRequest", rr);
            req.setAttribute("exitInterview", interview);

            req.getRequestDispatcher("/hr/exit-interview.jsp").forward(req, resp);
        } catch (NumberFormatException e) {
            req.getSession().setAttribute("errorMessage", "ID đơn không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/hr/resignation-approval");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!checkAccess(req, resp)) return;
        req.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);

        String resignationIdStr = req.getParameter("resignationId");
        if (resignationIdStr == null || resignationIdStr.isBlank()) {
            session.setAttribute("errorMessage", "Thiếu ID đơn nghỉ việc.");
            resp.sendRedirect(req.getContextPath() + "/hr/resignation-approval");
            return;
        }

        int resignationId = Integer.parseInt(resignationIdStr);
        String reasonCategory = req.getParameter("reasonCategory");
        String comment = req.getParameter("comment");

        if (reasonCategory == null || reasonCategory.isBlank()) {
            session.setAttribute("errorMessage", "Vui lòng chọn loại lý do.");
            resp.sendRedirect(req.getContextPath() + "/hr/exit-interview?resignationId=" + resignationId);
            return;
        }

        ExitInterview exit = new ExitInterview();
        exit.setResignationId(resignationId);
        exit.setReasonCategory(reasonCategory);
        exit.setComment(comment);

        boolean success = resignationDAO.insertExitInterview(exit);
        if (success) {
            session.setAttribute("successMessage", "Đã lưu kết quả phỏng vấn thôi việc.");
        } else {
            session.setAttribute("errorMessage", "Lưu thất bại. Có thể dữ liệu phỏng vấn cho đơn này đã tồn tại.");
        }

        resp.sendRedirect(req.getContextPath() + "/hr/exit-interview?resignationId=" + resignationId);
    }
}
