package controller.hr;

import dao.PayrollConfigDAO;
import model.PayrollConfig;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

@WebServlet(name = "PayrollConfigController", urlPatterns = {"/hr/payroll-configs"})
public class PayrollConfigController extends HttpServlet {

    private PayrollConfigDAO configDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        configDAO = new PayrollConfigDAO();
    }

    private boolean checkAccess(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        User user = (User) req.getSession().getAttribute("currentUser");
        if (user == null || (user.getRoleId() != 2 && user.getRoleId() != 5)) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return false;
        }
        return true;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!checkAccess(req, resp)) return;

        List<PayrollConfig> configs = configDAO.getAllConfigs();
        req.setAttribute("configs", configs);
        req.getRequestDispatcher("/hr/payroll-configs.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!checkAccess(req, resp)) return;

        try {
            String[] ids = req.getParameterValues("configId");
            if (ids != null) {
                for (String idStr : ids) {
                    int id = Integer.parseInt(idStr);
                    String valStr = req.getParameter("configValue_" + id);
                    if (valStr != null && !valStr.isBlank()) {
                        BigDecimal value = new BigDecimal(valStr.trim());
                        configDAO.updateConfig(id, value);
                    }
                }
            }
            req.getSession().setAttribute("successMessage", "Cập nhật tham số lương thành công!");
        } catch (Exception e) {
            req.getSession().setAttribute("errorMessage", "Lỗi cập nhật cấu hình: " + e.getMessage());
        }
        resp.sendRedirect(req.getContextPath() + "/hr/payroll-configs");
    }
}
