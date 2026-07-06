package controller.hr;

import dao.ResignationDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.ResignationChecklist;
import model.ResignationRequest;
import model.User;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "ResignationChecklistController", urlPatterns = {"/hr/resignation-checklist"})
public class ResignationChecklistController extends HttpServlet {

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
        if (user.getRoleId() != 2 && user.getRoleId() != 5) { // HR Manager / HR Staff
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

            List<ResignationChecklist> checklist = resignationDAO.getChecklistByResignationId(resignationId);
            req.setAttribute("resignationRequest", rr);
            req.setAttribute("checklist", checklist);

            req.getRequestDispatcher("/hr/resignation-checklist.jsp").forward(req, resp);
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
        User hrUser = (User) session.getAttribute("currentUser");

        String action = req.getParameter("action");
        String resignationIdStr = req.getParameter("resignationId");

        if (resignationIdStr == null || resignationIdStr.isBlank()) {
            session.setAttribute("errorMessage", "Thiếu ID đơn nghỉ việc.");
            resp.sendRedirect(req.getContextPath() + "/hr/resignation-approval");
            return;
        }

        int resignationId = Integer.parseInt(resignationIdStr);

        try {
            if ("add".equals(action)) {
                String itemName = req.getParameter("itemName");
                if (itemName != null && !itemName.isBlank()) {
                    resignationDAO.insertChecklistItem(resignationId, itemName.trim());
                    session.setAttribute("successMessage", "Thêm mục mới thành công.");
                }
            } else if ("update".equals(action)) {
                String checklistIdStr = req.getParameter("checklistId");
                String isCompletedStr = req.getParameter("isCompleted");
                String note = req.getParameter("note");
                
                if (checklistIdStr != null) {
                    int checklistId = Integer.parseInt(checklistIdStr);
                    boolean isCompleted = "true".equalsIgnoreCase(isCompletedStr) || "on".equalsIgnoreCase(isCompletedStr);
                    resignationDAO.updateChecklistItem(checklistId, isCompleted, isCompleted ? hrUser.getUserId() : 0, note);
                    
                    // Nếu tất cả đã hoàn thành, có thể tự động đổi trạng thái đơn thành COMPLETED
                    // Tạm thời chưa tự động, HR có thể click nút hoàn thành toàn bộ.
                    session.setAttribute("successMessage", "Cập nhật thành công.");
                }
            } else if ("delete".equals(action)) {
                String checklistIdStr = req.getParameter("checklistId");
                if (checklistIdStr != null) {
                    int checklistId = Integer.parseInt(checklistIdStr);
                    resignationDAO.deleteChecklistItem(checklistId);
                    session.setAttribute("successMessage", "Đã xóa mục.");
                }
            } else if ("completeAll".equals(action)) {
                if (hrUser.getRoleId() != 2) {
                    session.setAttribute("errorMessage", "Chỉ HR Manager mới có quyền hoàn tất thủ tục nghỉ việc.");
                } else {
                    resignationDAO.updateStatus(resignationId, "COMPLETED", "APPROVED", hrUser.getUserId(), null, null);
                    session.setAttribute("successMessage", "Đã hoàn thành toàn bộ thủ tục bàn giao. Trạng thái đơn được chuyển sang COMPLETED.");
                }
            }
        } catch (Exception e) {
            session.setAttribute("errorMessage", "Lỗi: " + e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/hr/resignation-checklist?resignationId=" + resignationId);
    }
}
