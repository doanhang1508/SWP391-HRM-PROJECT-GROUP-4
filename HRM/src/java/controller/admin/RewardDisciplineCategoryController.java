package controller.admin;

import dao.RewardDisciplineDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;
import model.RewardDiscipline;
import model.User;

@WebServlet("/admin/reward-disciplines")
public class RewardDisciplineCategoryController extends HttpServlet {

    private final RewardDisciplineDAO rdDAO = new RewardDisciplineDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!isAuthorized(request, response)) {
            return;
        }

        String keyword = request.getParameter("keyword");
        String typeFilter = request.getParameter("typeFilter");
        String viewId = request.getParameter("viewId");

        // View Details — single category
        if (viewId != null && !viewId.isEmpty()) {
            try {
                int id = Integer.parseInt(viewId);
                RewardDiscipline detail = rdDAO.getById(id);
                if (detail != null) {
                    request.setAttribute("detail", detail);
                }
            } catch (NumberFormatException ignored) {}
        }

        // List — with optional search/filter
        try {
            List<RewardDiscipline> list;
            if ((keyword != null && !keyword.trim().isEmpty())
                    || (typeFilter != null && !typeFilter.trim().isEmpty() && !"all".equalsIgnoreCase(typeFilter))) {
                list = rdDAO.searchCategories(keyword, typeFilter);
            } else {
                list = rdDAO.getAllRewardDisciplines();
            }
            request.setAttribute("categories", list);
            request.setAttribute("keyword", keyword);
            request.setAttribute("typeFilter", typeFilter);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi tải danh mục: " + e.getMessage());
        }

        request.getRequestDispatcher("/hr/reward-discipline-category.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        if (!isAuthorized(request, response)) {
            return;
        }

        String action = request.getParameter("action");
        String idStr = request.getParameter("id");

        // DELETE
        if ("delete".equals(action) && idStr != null) {
            try {
                int id = Integer.parseInt(idStr);
                rdDAO.deleteCategory(id);
            } catch (Exception e) {
                e.printStackTrace();
            }
            response.sendRedirect(request.getContextPath() + "/admin/reward-disciplines");
            return;
        }

        // ADD or EDIT
        if ("add".equals(action) || "edit".equals(action)) {
            String name = request.getParameter("name");
            String type = request.getParameter("type");
            String description = request.getParameter("description");
            String applyLevel = request.getParameter("applyLevel");

            // Validation
            if (name == null || name.isBlank()) {
                redirectWithError(request, response, "Tên hạng mục không được để trống.");
                return;
            }
            if (name.length() > 100) {
                redirectWithError(request, response, "Tên hạng mục không được quá 100 ký tự.");
                return;
            }
            if (type == null || (!"Reward".equals(type) && !"Discipline".equals(type))) {
                redirectWithError(request, response, "Phân loại không hợp lệ.");
                return;
            }

            int id = "edit".equals(action) ? parseInt(idStr) : 0;

            // Duplicate check
            if (rdDAO.isNameExists(name.trim(), id)) {
                redirectWithError(request, response, "Tên hạng mục đã tồn tại.");
                return;
            }

            RewardDiscipline rd = new RewardDiscipline();
            rd.setId(id);
            rd.setName(name.trim());
            rd.setType(type);
            rd.setDescription(description != null ? description.trim() : null);
            rd.setApplyLevel(applyLevel != null ? applyLevel.trim() : "Cá nhân");

            if ("add".equals(action)) {
                // Set creator from session
                HttpSession session = request.getSession(false);
                if (session != null && session.getAttribute("currentUser") != null) {
                    User user = (User) session.getAttribute("currentUser");
                    rd.setCreatedBy(user.getUserId());
                }
                rdDAO.insertCategory(rd);
            } else {
                rdDAO.updateCategory(rd);
            }
        }

        response.sendRedirect(request.getContextPath() + "/admin/reward-disciplines");
    }

    /**
     * Kiểm tra quyền truy cập: chỉ HR Manager (role 2)
     */
    private boolean isAuthorized(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return false;
        }
        User user = (User) session.getAttribute("currentUser");
        if (user.getRoleId() != 2) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return false;
        }
        return true;
    }

    private int parseInt(String value) {
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    private void redirectWithError(HttpServletRequest request, HttpServletResponse response, String message) throws IOException {
        String encoded = URLEncoder.encode(message, StandardCharsets.UTF_8);
        response.sendRedirect(request.getContextPath() + "/admin/reward-disciplines?error=" + encoded);
    }
}
