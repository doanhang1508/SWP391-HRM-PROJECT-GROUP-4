package controller.hr;

import dao.InsuranceRateDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import model.InsuranceRate;
import model.User;

/**
 * HR Controller – Quản lý Mức đóng Bảo hiểm (Insurance Rate)
 * URL: /hr/insurance-rate
 * Quyền: HR Manager (roleId=2) hoặc Admin (roleId=1)
 */
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
            dao.delete(Integer.parseInt(idStr));
            request.getSession().setAttribute("successMsg", "Đã xóa mức bảo hiểm thành công.");
            response.sendRedirect(request.getContextPath() + LIST_URL);
            return;
        }

        request.setAttribute("insuranceRateList", dao.getAll());
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
                dao.insert(new InsuranceRate(0, insuranceName, companyRate,
                                             employeeRate, description, true));
                request.getSession().setAttribute("successMsg", "Thêm mức bảo hiểm thành công.");
            } else if ("edit".equals(action) && idStr != null) {
                dao.update(new InsuranceRate(Integer.parseInt(idStr), insuranceName,
                                             companyRate, employeeRate, description, true));
                request.getSession().setAttribute("successMsg", "Cập nhật mức bảo hiểm thành công.");
            }
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("errorMsg", "Tỷ lệ % không hợp lệ.");
        }

        response.sendRedirect(request.getContextPath() + LIST_URL);
    }
}
