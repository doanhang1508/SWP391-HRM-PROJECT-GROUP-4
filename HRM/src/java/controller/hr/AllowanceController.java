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

        // FIX: Xử lý action=detail
        if ("detail".equals(action) && idStr != null) {
            try {
                int id = Integer.parseInt(idStr);
                Allowance a = dao.getById(id);
                if (a != null) {
                    request.setAttribute("detailAllowance", a);
                } else {
                    request.getSession().setAttribute("errorMsg", "Không tìm thấy phụ cấp.");
                }
            } catch (NumberFormatException e) {
                request.getSession().setAttribute("errorMsg", "ID không hợp lệ.");
            }
            request.setAttribute("allowanceList", dao.getAll());
            request.getRequestDispatcher(LIST_JSP).forward(request, response);
            return;
        }

        // FIX: Gộp delete và deactivate thành 1 (tránh trùng lặp)
        if (("delete".equals(action) || "deactivate".equals(action)) && idStr != null) {
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

        String action         = request.getParameter("action");
        String allowanceName  = request.getParameter("allowanceName");
        String description    = request.getParameter("description");
        String amountStr      = request.getParameter("amount");
        String applyCondition = request.getParameter("applyCondition");
        String idStr          = request.getParameter("id");

        // Validate tên
        if (allowanceName == null || allowanceName.isBlank()) {
            request.getSession().setAttribute("errorMsg", "Tên phụ cấp không được để trống.");
            response.sendRedirect(request.getContextPath() + LIST_URL);
            return;
        }

        try {
            BigDecimal amount = (amountStr != null && !amountStr.isBlank())
                    ? new BigDecimal(amountStr.replaceAll(",", "")) : BigDecimal.ZERO;

            if (amount.compareTo(BigDecimal.ZERO) < 0) {
                request.getSession().setAttribute("errorMsg", "Mức tiền phụ cấp không được âm.");
                response.sendRedirect(request.getContextPath() + LIST_URL);
                return;
            }

            if ("add".equals(action)) {
                // FIX: Kiểm tra trùng tên trước khi thêm
                if (dao.isDuplicate(allowanceName.trim(), 0)) {
                    request.getSession().setAttribute("errorMsg",
                        "Tên phụ cấp \"" + allowanceName + "\" đã tồn tại.");
                } else {
                    dao.insert(new Allowance(0, allowanceName.trim(), description, amount, applyCondition, true));
                    request.getSession().setAttribute("successMsg", "Thêm loại phụ cấp thành công.");
                }
            } else if ("edit".equals(action) && idStr != null) {
                int id = Integer.parseInt(idStr);
                // FIX: Kiểm tra trùng tên khi edit (bỏ qua chính nó)
                if (dao.isDuplicate(allowanceName.trim(), id)) {
                    request.getSession().setAttribute("errorMsg",
                        "Tên phụ cấp \"" + allowanceName + "\" đã tồn tại.");
                } else {
                    dao.update(new Allowance(id, allowanceName.trim(), description, amount, applyCondition, true));
                    request.getSession().setAttribute("successMsg", "Cập nhật loại phụ cấp thành công.");
                }
            }
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("errorMsg", "Mức tiền không hợp lệ. Vui lòng kiểm tra lại.");
        }

        response.sendRedirect(request.getContextPath() + LIST_URL);
    }
}
