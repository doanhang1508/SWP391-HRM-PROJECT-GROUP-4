package controller.hr;

import dao.AllowanceDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import model.Allowance;
import model.User;

/**
 * HR Controller – Quản lý Loại Phụ cấp (Allowance)
 * URL: /hr/allowance
 * Quyền: HR Manager (roleId=2) hoặc Admin (roleId=1)
 */
@WebServlet(name = "AllowanceController", urlPatterns = {"/hr/allowance"})
public class AllowanceController extends HttpServlet {

    private static final String LIST_JSP = "/hr/allowance.jsp";
    private static final String LIST_URL = "/hr/allowance";

    private final AllowanceDAO dao = new AllowanceDAO();

    private boolean checkAccess(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return false;
        }
        User user = (User) session.getAttribute("currentUser");
        if (user.getRoleId() != 1 && user.getRoleId() != 2) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return false;
        }
        return true;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!checkAccess(request, response)) return;

        String action = request.getParameter("action");
        String idStr  = request.getParameter("id");

        if ("delete".equals(action) && idStr != null) {
            int id = Integer.parseInt(idStr);
            // Soft-delete (deactivate) thay vì xóa cứng
            dao.deactivate(id);
            request.getSession().setAttribute("successMsg", "Đã vô hiệu hóa loại phụ cấp thành công.");
            response.sendRedirect(request.getContextPath() + LIST_URL);
            return;
        }
        if ("deactivate".equals(action) && idStr != null) {
            dao.deactivate(Integer.parseInt(idStr));
            request.getSession().setAttribute("successMsg", "Đã vô hiệu hóa loại phụ cấp thành công.");
            response.sendRedirect(request.getContextPath() + LIST_URL);
            return;
        }
        if ("activate".equals(action) && idStr != null) {
            dao.activate(Integer.parseInt(idStr));
            request.getSession().setAttribute("successMsg", "Kích hoạt lại loại phụ cấp thành công.");
            response.sendRedirect(request.getContextPath() + LIST_URL);
            return;
        }

        request.setAttribute("allowanceList", dao.getAll());
        request.getRequestDispatcher(LIST_JSP).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        if (!checkAccess(request, response)) return;

        String action          = request.getParameter("action");
        String allowanceName   = request.getParameter("allowanceName");
        String description     = request.getParameter("description");
        String amountStr       = request.getParameter("amount");
        String applyCondition  = request.getParameter("applyCondition");
        String idStr           = request.getParameter("id");

        try {
            BigDecimal amount = (amountStr != null && !amountStr.isEmpty())
                    ? new BigDecimal(amountStr.replaceAll(",", "")) : BigDecimal.ZERO;

            if ("add".equals(action)) {
                dao.insert(new Allowance(0, allowanceName, description, amount, applyCondition, true));
                request.getSession().setAttribute("successMsg", "Thêm loại phụ cấp thành công.");
            } else if ("edit".equals(action) && idStr != null) {
                dao.update(new Allowance(Integer.parseInt(idStr), allowanceName, description, amount, applyCondition, true));
                request.getSession().setAttribute("successMsg", "Cập nhật loại phụ cấp thành công.");
            }
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("errorMsg", "Dữ liệu mức tiền không hợp lệ.");
        }

        response.sendRedirect(request.getContextPath() + LIST_URL);
    }
}
