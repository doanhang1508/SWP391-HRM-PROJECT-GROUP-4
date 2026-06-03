package controller.hr;

import dao.InsuranceRateDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;
import model.InsuranceRate;
import model.User;

/**
 * HR Controller – Quản lý Mức đóng Bảo hiểm (Insurance Rate)
 * URL: /hr/insurance-rate
 * Quyền: HR Manager (roleId=2) hoặc HR Staff (roleId=5)
 */
@WebServlet(name = "InsuranceRateController", urlPatterns = {"/hr/insurance-rate"})
public class InsuranceRateController extends HttpServlet {

    private static final String LIST_JSP = "/hr/insurance-rate.jsp";
    private static final String LIST_URL = "/hr/insurance-rate";

    private final InsuranceRateDAO dao = new InsuranceRateDAO();

    private boolean checkAccess(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return false;
        }
        User user = (User) session.getAttribute("currentUser");
        if (user.getRoleId() != 2 && user.getRoleId() != 5) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return false;
        }
        return true;
    }

    /**
     * Đọc tham số tìm kiếm, load danh sách bảo hiểm và tính tổng/trung bình.
     * Đây là điểm duy nhất gom logic load list, tránh lặp code.
     */
    private void loadList(HttpServletRequest request) {
        String keyword      = request.getParameter("keyword");
        String statusFilter = request.getParameter("statusFilter");

        // Bảo hiểm cũ chỉ có status=1, mặc định active để giữ behaviour cũ
        if (statusFilter == null || statusFilter.isBlank()) statusFilter = "active";

        List<InsuranceRate> list = dao.search(keyword, statusFilter);

        BigDecimal totalCompany  = BigDecimal.ZERO;
        BigDecimal totalEmployee = BigDecimal.ZERO;
        for (InsuranceRate ir : list) {
            totalCompany  = totalCompany.add(ir.getCompanyRate());
            totalEmployee = totalEmployee.add(ir.getEmployeeRate());
        }
        BigDecimal avgCompany  = list.isEmpty() ? BigDecimal.ZERO
            : totalCompany.divide(new BigDecimal(list.size()), 2, java.math.RoundingMode.HALF_UP);
        BigDecimal avgEmployee = list.isEmpty() ? BigDecimal.ZERO
            : totalEmployee.divide(new BigDecimal(list.size()), 2, java.math.RoundingMode.HALF_UP);

        request.setAttribute("insuranceRateList", list);
        request.setAttribute("avgCompanyRate",    avgCompany);
        request.setAttribute("avgEmployeeRate",   avgEmployee);
        request.setAttribute("keyword",           keyword      != null ? keyword      : "");
        request.setAttribute("statusFilter",      statusFilter);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!checkAccess(request, response)) return;

        String action = request.getParameter("action");
        String idStr  = request.getParameter("id");

        if ("delete".equals(action) && idStr != null) {
            dao.delete(Integer.parseInt(idStr));
            request.getSession().setAttribute("successMsg", "Đã xóa mức bảo hiểm thành công.");
            response.sendRedirect(request.getContextPath() + LIST_URL);
            return;
        }

        // Hiển thị danh sách (có thể kèm tìm kiếm qua GET param ?keyword=...&statusFilter=...)
        loadList(request);
        request.getRequestDispatcher(LIST_JSP).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        if (!checkAccess(request, response)) return;

        String action         = request.getParameter("action");
        String insuranceName  = request.getParameter("insuranceName");
        String companyRateS   = request.getParameter("companyRate");
        String employeeRateS  = request.getParameter("employeeRate");
        String description    = request.getParameter("description");
        String idStr          = request.getParameter("id");

        try {
            BigDecimal companyRate  = new BigDecimal(companyRateS);
            BigDecimal employeeRate = new BigDecimal(employeeRateS);

            if ("add".equals(action)) {
                if (dao.isDuplicate(insuranceName, 0)) {
                    request.getSession().setAttribute("errorMsg", "Tên loại bảo hiểm đã tồn tại.");
                } else {
                    dao.insert(new InsuranceRate(0, insuranceName, companyRate,
                                                 employeeRate, description, true));
                    request.getSession().setAttribute("successMsg", "Thêm mức bảo hiểm thành công.");
                }
            } else if ("edit".equals(action) && idStr != null) {
                int editId = Integer.parseInt(idStr);
                if (dao.isDuplicate(insuranceName, editId)) {
                    request.getSession().setAttribute("errorMsg", "Tên loại bảo hiểm đã tồn tại.");
                } else {
                    dao.update(new InsuranceRate(editId, insuranceName,
                                                 companyRate, employeeRate, description, true));
                    request.getSession().setAttribute("successMsg", "Cập nhật mức bảo hiểm thành công.");
                }
            }
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("errorMsg", "Tỷ lệ % không hợp lệ.");
        }

        response.sendRedirect(request.getContextPath() + LIST_URL);
    }
}
