package controller.hr;

import dao.AllowanceDAO;
import dao.PositionDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.HashSet;
import java.util.Set;
import model.User;

/**
 * Màn hình cấu hình phụ cấp theo chức vụ (ma trận checkbox).
 *
 * GET  /hr/position-allowance              → hiển thị toàn bộ ma trận
 * GET  /hr/position-allowance?posId=X      → chọn sẵn chức vụ X
 * POST /hr/position-allowance              → lưu thay đổi (replace strategy)
 */
@WebServlet(name = "PositionAllowanceController", urlPatterns = {"/hr/position-allowance"})
public class PositionAllowanceController extends HttpServlet {

    private static final String JSP      = "/hr/position-allowance.jsp";
    private static final String LIST_URL = "/hr/position-allowance";

    private final AllowanceDAO allowanceDAO = new AllowanceDAO();
    private final PositionDAO  positionDAO  = new PositionDAO();

    /** Cho phép: Admin (1), HR Manager (2), HR Staff (5) */
    private boolean checkAccess(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return false;
        }
        User u = (User) session.getAttribute("currentUser");
        if (u.getRoleId() != 5) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return false;
        }
        return true;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!checkAccess(request, response)) return;

        // Danh sách chức vụ (chỉ active) và tất cả phụ cấp active
        request.setAttribute("positionList",  positionDAO.getAll());
        request.setAttribute("allowanceList", allowanceDAO.getActive());

        // Chức vụ đang được chọn
        String posIdStr = request.getParameter("posId");
        if (posIdStr != null && !posIdStr.isBlank()) {
            try {
                int posId = Integer.parseInt(posIdStr);
                request.setAttribute("selectedPosId", posId);
                // Tập hợp allowance_id đã được gán cho chức vụ này
                request.setAttribute("assignedIds", allowanceDAO.getAssignedAllowanceIds(posId));
            } catch (NumberFormatException ignored) { }
        }

        request.getRequestDispatcher(JSP).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        if (!checkAccess(request, response)) return;

        String posIdStr = request.getParameter("posId");
        if (posIdStr == null || posIdStr.isBlank()) {
            request.getSession().setAttribute("errorMsg", "Vui lòng chọn chức vụ trước khi lưu.");
            response.sendRedirect(request.getContextPath() + LIST_URL);
            return;
        }

        int posId;
        try {
            posId = Integer.parseInt(posIdStr);
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("errorMsg", "ID chức vụ không hợp lệ.");
            response.sendRedirect(request.getContextPath() + LIST_URL);
            return;
        }

        // Đọc các checkbox được tick
        String[] checkedIds = request.getParameterValues("allowanceId");
        Set<Integer> selected = new HashSet<>();
        if (checkedIds != null) {
            for (String s : checkedIds) {
                try { selected.add(Integer.parseInt(s)); }
                catch (NumberFormatException ignored) { }
            }
        }

        boolean ok = allowanceDAO.setAllowancesForPosition(posId, selected);
        if (ok) {
            request.getSession().setAttribute("successMsg",
                "Cập nhật phụ cấp cho chức vụ thành công. (" + selected.size() + " phụ cấp được gán)");
        } else {
            request.getSession().setAttribute("errorMsg",
                "Có lỗi xảy ra khi lưu cấu hình. Vui lòng thử lại.");
        }
        response.sendRedirect(request.getContextPath() + LIST_URL + "?posId=" + posId);
    }
}
