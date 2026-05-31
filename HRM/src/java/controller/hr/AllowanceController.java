package controller.hr;

import dao.AllowanceDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.Allowance;
import model.User;

/**
 * HR Controller – Quản lý Loại Phụ cấp (Allowance)
 * URL: /hr/allowance
 * Quyền: HR Manager (roleId=2) hoặc Admin (roleId=1)
 */
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
            if (dao.countEmployees(id) > 0) {
                request.getSession().setAttribute("errorMsg",
                    "Không thể xóa: vẫn còn nhân viên đang được áp dụng loại phụ cấp này!");
            } else {
                dao.delete(id);
                request.getSession().setAttribute("successMsg", "Đã xóa loại phụ cấp thành công.");
            }
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

        String action        = request.getParameter("action");
        String allowanceName = request.getParameter("allowanceName");
        String description   = request.getParameter("description");
        String idStr         = request.getParameter("id");

        if ("add".equals(action)) {
            dao.insert(new Allowance(0, allowanceName, description, true));
            request.getSession().setAttribute("successMsg", "Thêm loại phụ cấp thành công.");
        } else if ("edit".equals(action) && idStr != null) {
            dao.update(new Allowance(Integer.parseInt(idStr), allowanceName, description, true));
            request.getSession().setAttribute("successMsg", "Cập nhật loại phụ cấp thành công.");
        }

        response.sendRedirect(request.getContextPath() + LIST_URL);
    }
}
