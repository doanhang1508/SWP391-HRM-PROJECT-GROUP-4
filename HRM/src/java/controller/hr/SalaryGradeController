package controller.hr;

import dao.SalaryGradeDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import model.SalaryGrade;
import model.User;

/**
 * HR Controller – Quản lý Ngạch lương (Salary Grade)
 * URL: /hr/salary-grade
 * Quyền: HR Manager (roleId=2) hoặc Admin (roleId=1)
 */
public class SalaryGradeController extends HttpServlet {

    private static final String LIST_JSP = "/hr/salary-grade.jsp";
    private static final String LIST_URL = "/hr/salary-grade";

    private final SalaryGradeDAO dao = new SalaryGradeDAO();

    // ── Kiểm tra phiên & quyền HR ──────────────────────────────────────
    private boolean checkAccess(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return false;
        }
        User user = (User) session.getAttribute("currentUser");
        // Cho phép Admin (1) và HR Manager (2)
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
            // Cảnh báo nếu còn nhân viên đang dùng ngạch này
            if (dao.countEmployees(id) > 0) {
                request.getSession().setAttribute("errorMsg",
                    "Không thể xóa: vẫn còn nhân viên đang sử dụng ngạch lương này!");
            } else {
                dao.delete(id);
                request.getSession().setAttribute("successMsg", "Đã xóa ngạch lương thành công.");
            }
            response.sendRedirect(request.getContextPath() + LIST_URL);
            return;
        }

        request.setAttribute("salaryGradeList", dao.getAll());
        request.getRequestDispatcher(LIST_JSP).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        if (!checkAccess(request, response)) return;

        String action      = request.getParameter("action");
        String gradeName   = request.getParameter("gradeName");
        String baseSalaryS = request.getParameter("baseSalary");
        String coefficientS= request.getParameter("coefficient");
        String description = request.getParameter("description");
        String idStr       = request.getParameter("id");

        try {
            BigDecimal baseSalary  = new BigDecimal(baseSalaryS.replaceAll(",", ""));
            BigDecimal coefficient = new BigDecimal(coefficientS);

            if ("add".equals(action)) {
                dao.insert(new SalaryGrade(0, gradeName, baseSalary, coefficient, description, true));
                request.getSession().setAttribute("successMsg", "Thêm ngạch lương thành công.");
            } else if ("edit".equals(action) && idStr != null) {
                dao.update(new SalaryGrade(Integer.parseInt(idStr), gradeName,
                                           baseSalary, coefficient, description, true));
                request.getSession().setAttribute("successMsg", "Cập nhật ngạch lương thành công.");
            }
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("errorMsg", "Dữ liệu số không hợp lệ.");
        }

        response.sendRedirect(request.getContextPath() + LIST_URL);
    }
}
