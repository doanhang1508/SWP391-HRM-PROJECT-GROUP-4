package controller.hr;

import dao.AllowanceDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
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
        if (user.getRoleId() != 1 && user.getRoleId() != 2 && user.getRoleId() != 5) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return false;
        }
        return true;
    }

    /** Đọc tham số tìm kiếm và load danh sách phụ cấp */
    private void loadList(HttpServletRequest request) {
        String keyword      = request.getParameter("keyword");
        String statusFilter = request.getParameter("statusFilter");
        if (statusFilter == null || statusFilter.isBlank()) statusFilter = "all";

        request.setAttribute("allowanceList", dao.search(keyword, statusFilter));
        request.setAttribute("keyword",       keyword != null ? keyword : "");
        request.setAttribute("statusFilter",  statusFilter);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!checkAccess(request, response)) return;

        String action = request.getParameter("action");
        String idStr  = request.getParameter("id");

        // ── Chi tiết (AJAX / JSON) ──────────────────────────────────────────
        if ("detail".equals(action) && idStr != null) {
            response.setContentType("application/json;charset=UTF-8");
            PrintWriter out = response.getWriter();
            try {
                int id = Integer.parseInt(idStr);
                Allowance a = dao.getById(id);
                if (a != null) {
                    out.write(allowanceToJson(a));
                } else {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    out.write("{\"error\":\"Không tìm thấy phụ cấp.\"}");
                }
            } catch (NumberFormatException e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.write("{\"error\":\"ID không hợp lệ.\"}");
            }
            return;
        }

        // ── Vô hiệu hóa ────────────────────────────────────────────────────
        if (("delete".equals(action) || "deactivate".equals(action)) && idStr != null) {
            dao.deactivate(Integer.parseInt(idStr));
            request.getSession().setAttribute("successMsg", "Đã vô hiệu hóa loại phụ cấp thành công.");
            response.sendRedirect(request.getContextPath() + LIST_URL);
            return;
        }

        // ── Kích hoạt lại ───────────────────────────────────────────────────
        if ("activate".equals(action) && idStr != null) {
            dao.activate(Integer.parseInt(idStr));
            request.getSession().setAttribute("successMsg", "Kích hoạt lại loại phụ cấp thành công.");
            response.sendRedirect(request.getContextPath() + LIST_URL);
            return;
        }

        // ── Danh sách ───────────────────────────────────────────────────────
        loadList(request);

        // Hỗ trợ mở edit modal trực tiếp từ query param ?openEdit=<id>
        String openEdit = request.getParameter("openEdit");
        if (openEdit != null && !openEdit.isBlank()) {
            request.setAttribute("openEditId", openEdit);
        }

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
        String calculationType= request.getParameter("calculationType");
        boolean isBhxhApplied = request.getParameter("isBhxhApplied") != null;
        boolean isTaxable     = request.getParameter("isTaxable") != null;

        if (calculationType == null || calculationType.isBlank()) {
            calculationType = "FIXED";
        }

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
                if (dao.isDuplicate(allowanceName.trim(), 0)) {
                    request.getSession().setAttribute("errorMsg",
                        "Tên phụ cấp \"" + allowanceName + "\" đã tồn tại.");
                } else {
                    dao.insert(new Allowance(0, allowanceName.trim(), description, amount, applyCondition, calculationType, isBhxhApplied, isTaxable, true));
                    request.getSession().setAttribute("successMsg", "Thêm loại phụ cấp thành công.");
                }
            } else if ("edit".equals(action) && idStr != null) {
                int id = Integer.parseInt(idStr);
                if (dao.isDuplicate(allowanceName.trim(), id)) {
                    request.getSession().setAttribute("errorMsg",
                        "Tên phụ cấp \"" + allowanceName + "\" đã tồn tại.");
                } else {
                    dao.update(new Allowance(id, allowanceName.trim(), description, amount, applyCondition, calculationType, isBhxhApplied, isTaxable, true));
                    request.getSession().setAttribute("successMsg", "Cập nhật loại phụ cấp thành công.");
                }
            }
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("errorMsg", "Mức tiền không hợp lệ. Vui lòng kiểm tra lại.");
        }

        response.sendRedirect(request.getContextPath() + LIST_URL);
    }

    /** Chuyển Allowance thành JSON string — không cần thư viện ngoài */
    private String allowanceToJson(Allowance a) {
        return "{"
            + "\"allowanceId\":"   + a.getAllowanceId()                        + ","
            + "\"allowanceName\":" + jsonStr(a.getAllowanceName())              + ","
            + "\"description\":"   + jsonStr(a.getDescription())               + ","
            + "\"amount\":"        + (a.getAmount() != null ? a.getAmount().toPlainString() : "0") + ","
            + "\"applyCondition\":" + jsonStr(a.getApplyCondition())           + ","
            + "\"calculationType\":"+ jsonStr(a.getCalculationType())          + ","
            + "\"isBhxhApplied\":"  + a.isBhxhApplied()                        + ","
            + "\"isTaxable\":"      + a.isTaxable()                            + ","
            + "\"status\":"        + a.isStatus()
            + "}";
    }

    /** Escape chuỗi thành JSON string literal (bao gồm null → null) */
    private String jsonStr(String s) {
        if (s == null) return "null";
        return "\"" + s.replace("\\", "\\\\")
                       .replace("\"", "\\\"")
                       .replace("\n", "\\n")
                       .replace("\r", "\\r")
                       .replace("\t", "\\t")
               + "\"";
    }
}
