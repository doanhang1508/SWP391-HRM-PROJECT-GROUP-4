package controller.hr;

import dao.SalaryGradeDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import model.SalaryGrade;
import model.User;

@WebServlet(name = "SalaryGradeController", urlPatterns = {"/hr/salary-grade"})
public class SalaryGradeController extends HttpServlet {

    private static final String LIST_JSP = "/hr/salary-grade.jsp";
    private static final String LIST_URL = "/hr/salary-grade";

    private final SalaryGradeDAO dao = new SalaryGradeDAO();

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

        // FIX: Xử lý action=detail (JSP có link xem chi tiết)
        if ("detail".equals(action) && idStr != null) {
            try {
                int id = Integer.parseInt(idStr);
                SalaryGrade sg = dao.getById(id);
                if (sg != null) {
                    request.setAttribute("detailGrade", sg);
                } else {
                    request.getSession().setAttribute("errorMsg", "Không tìm thấy ngạch lương.");
                }
            } catch (NumberFormatException e) {
                request.getSession().setAttribute("errorMsg", "ID không hợp lệ.");
            }
            request.setAttribute("salaryGradeList", dao.getAll());
            request.getRequestDispatcher(LIST_JSP).forward(request, response);
            return;
        }

        // Deactivate qua GET (link trực tiếp)
        if ("delete".equals(action) && idStr != null) {
            int id = Integer.parseInt(idStr);
            if (dao.countLinkedEmployees(id) > 0) {
                request.getSession().setAttribute("errorMsg",
                    "Không thể xóa: vẫn còn nhân viên đang sử dụng ngạch lương này!");
            } else {
                dao.deactivate(id);
                request.getSession().setAttribute("successMsg", "Đã vô hiệu hóa ngạch lương thành công.");
            }
            response.sendRedirect(request.getContextPath() + LIST_URL);
            return;
        }

        // Load danh sách
        request.setAttribute("salaryGradeList", dao.getAll());
        request.getRequestDispatcher(LIST_JSP).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        if (!checkAccess(request, response)) return;

        String action = request.getParameter("action");
        String idStr  = request.getParameter("id");

        // Deactivate
        if ("deactivate".equals(action) && idStr != null) {
            int id = Integer.parseInt(idStr);
            if (dao.countLinkedEmployees(id) > 0) {
                request.getSession().setAttribute("errorMsg",
                    "Không thể vô hiệu hóa: vẫn còn nhân viên đang sử dụng ngạch lương này!");
            } else {
                dao.deactivate(id);
                request.getSession().setAttribute("successMsg", "Đã vô hiệu hóa ngạch lương thành công.");
            }
            response.sendRedirect(request.getContextPath() + LIST_URL);
            return;
        }

        // Activate
        if ("activate".equals(action) && idStr != null) {
            dao.activate(Integer.parseInt(idStr));
            request.getSession().setAttribute("successMsg", "Kích hoạt lại ngạch lương thành công.");
            response.sendRedirect(request.getContextPath() + LIST_URL);
            return;
        }

        // Add / Edit
        String gradeName    = request.getParameter("gradeName");
        String baseSalaryS  = request.getParameter("baseSalary");
        String coefficientS = request.getParameter("coefficient");
        String description  = request.getParameter("description");

        // Validate input
        if (gradeName == null || gradeName.isBlank()) {
            request.getSession().setAttribute("errorMsg", "Tên ngạch lương không được để trống.");
            response.sendRedirect(request.getContextPath() + LIST_URL);
            return;
        }

        try {
            BigDecimal baseSalary  = new BigDecimal(baseSalaryS.replaceAll(",", ""));
            BigDecimal coefficient = new BigDecimal(coefficientS);

            if (baseSalary.compareTo(BigDecimal.ZERO) <= 0) {
                request.getSession().setAttribute("errorMsg", "Lương cơ bản phải lớn hơn 0.");
                response.sendRedirect(request.getContextPath() + LIST_URL);
                return;
            }
            if (coefficient.compareTo(BigDecimal.ZERO) <= 0) {
                request.getSession().setAttribute("errorMsg", "Hệ số lương phải lớn hơn 0.");
                response.sendRedirect(request.getContextPath() + LIST_URL);
                return;
            }

            if ("add".equals(action)) {
                // FIX: Kiểm tra trùng tên trước khi thêm
                if (dao.isDuplicate(gradeName.trim(), 0)) {
                    request.getSession().setAttribute("errorMsg",
                        "Tên ngạch lương \"" + gradeName + "\" đã tồn tại.");
                } else {
                    dao.insert(new SalaryGrade(0, gradeName.trim(), baseSalary, coefficient, description, true));
                    request.getSession().setAttribute("successMsg", "Thêm ngạch lương thành công.");
                }
            } else if ("edit".equals(action) && idStr != null) {
                int id = Integer.parseInt(idStr);
                // FIX: Kiểm tra trùng tên khi edit (bỏ qua chính nó)
                if (dao.isDuplicate(gradeName.trim(), id)) {
                    request.getSession().setAttribute("errorMsg",
                        "Tên ngạch lương \"" + gradeName + "\" đã tồn tại.");
                } else {
                    dao.update(new SalaryGrade(id, gradeName.trim(), baseSalary, coefficient, description, true));
                    request.getSession().setAttribute("successMsg", "Cập nhật ngạch lương thành công.");
                }
            }
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("errorMsg", "Dữ liệu số không hợp lệ. Vui lòng kiểm tra lại.");
        }

        response.sendRedirect(request.getContextPath() + LIST_URL);
    }
}
