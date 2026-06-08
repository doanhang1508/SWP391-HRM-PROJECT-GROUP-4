package controller.hr;

import dao.RewardDisciplineDAO;
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


@WebServlet("/hr/reward-disciplines")
public class RewardDisciplineCategoryController extends HttpServlet {

    private static final String ATTR_CURRENT_USER = "currentUser";
    private static final String BASE_URL          = "/hr/reward-disciplines";
    private static final String VIEW_PAGE         = "/hr/reward-discipline-category.jsp";

    private final RewardDisciplineDAO rdDAO = new RewardDisciplineDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) {
        if (!isAuthorized(request, response)) return;

        loadViewDetail(request);
        loadCategoryList(request);
        forwardToView(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) {
        setEncoding(request);
        if (!isAuthorized(request, response)) return;

        String action = request.getParameter("action");
        String idStr  = request.getParameter("id");

        if ("delete".equals(action) && idStr != null) {
            handleDelete(response, idStr);
            return;
        }

        if ("add".equals(action) || "edit".equals(action)) {
            handleAddOrEdit(request, response, action, idStr);
            return;
        }

        redirect(response, request.getContextPath() + BASE_URL);
    }

    // Ã¢â€â‚¬Ã¢â€â‚¬ doGet helpers Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬

    private void loadViewDetail(HttpServletRequest request) {
        String viewId = request.getParameter("viewId");
        if (viewId == null || viewId.isEmpty()) return;
        try {
            int id = Integer.parseInt(viewId);
            RewardDiscipline detail = rdDAO.getById(id);
            if (detail != null) request.setAttribute("detail", detail);
        } catch (NumberFormatException ignored) {
            // No detail loaded
        }
    }

    private void loadCategoryList(HttpServletRequest request) {
        String keyword    = request.getParameter("keyword");
        String typeFilter = request.getParameter("typeFilter");
        try {
            List<RewardDiscipline> list = resolveList(keyword, typeFilter);
            request.setAttribute("categories", list);
            request.setAttribute("keyword", keyword);
            request.setAttribute("typeFilter", typeFilter);
        } catch (Exception e) {
            request.setAttribute("error", "Loi tai danh muc: " + e.getMessage());
        }
    }

    private List<RewardDiscipline> resolveList(String keyword, String typeFilter) {
        boolean hasKeyword = keyword != null && !keyword.trim().isEmpty();
        boolean hasType    = typeFilter != null
                && !typeFilter.trim().isEmpty()
                && !"all".equalsIgnoreCase(typeFilter);
        if (hasKeyword || hasType) {
            return rdDAO.searchCategories(keyword, typeFilter);
        }
        return rdDAO.getAllRewardDisciplines();
    }

    // Ã¢â€â‚¬Ã¢â€â‚¬ doPost handlers Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬

    private void handleDelete(HttpServletResponse response, String idStr) {
        try {
            rdDAO.deleteCategory(parseInt(idStr));
        } catch (Exception e) {
            // Log suppressed; redirect proceeds regardless
        }
        redirect(response, BASE_URL);
    }

    private void handleAddOrEdit(HttpServletRequest request, HttpServletResponse response,
                                 String action, String idStr) {
        String name        = request.getParameter("name");
        String type        = request.getParameter("type");
        String description = request.getParameter("description");
        String applyLevel  = request.getParameter("applyLevel");

        String validationError = validate(name, type);
        if (validationError != null) {
            redirectWithError(request, response, validationError);
            return;
        }

        int id = "edit".equals(action) ? parseInt(idStr) : 0;

        if (rdDAO.isNameExists(name.trim(), id)) {
            redirectWithError(request, response, "Ten hang muc da ton tai.");
            return;
        }

        RewardDiscipline rd = buildRd(id, name, type, description, applyLevel);

        if ("add".equals(action)) {
            setCreator(request, rd);
            rdDAO.insertCategory(rd);
        } else {
            rdDAO.updateCategory(rd);
        }

        redirect(response, request.getContextPath() + BASE_URL);
    }

    private String validate(String name, String type) {
        if (name == null || name.isBlank()) return "Ten hang muc khong duoc de trong.";
        if (name.length() > 100)           return "Ten hang muc khong duoc qua 100 ky tu.";
        if (type == null || (!"Reward".equals(type) && !"Discipline".equals(type))) {
            return "Phan loai khong hop le.";
        }
        return null;
    }

    private RewardDiscipline buildRd(int id, String name, String type,
                                     String description, String applyLevel) {
        RewardDiscipline rd = new RewardDiscipline();
        rd.setId(id);
        rd.setName(name.trim());
        rd.setType(type);
        rd.setDescription(description != null ? description.trim() : null);
        rd.setApplyLevel(applyLevel != null ? applyLevel.trim() : "Ca nhan");
        return rd;
    }

    private void setCreator(HttpServletRequest request, RewardDiscipline rd) {
        HttpSession session = request.getSession(false);
        if (session == null) return;
        User user = (User) session.getAttribute(ATTR_CURRENT_USER);
        if (user != null) rd.setCreatedBy(user.getUserId());
    }

    // Ã¢â€â‚¬Ã¢â€â‚¬ Auth Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬

    private boolean isAuthorized(HttpServletRequest request, HttpServletResponse response) {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute(ATTR_CURRENT_USER) == null) {
            redirect(response, request.getContextPath() + "/login");
            return false;
        }
        User user = (User) session.getAttribute(ATTR_CURRENT_USER);
        if (user.getRoleId() != 2) {
            redirect(response, request.getContextPath() + "/dashboard");
            return false;
        }
        return true;
    }

    // Ã¢â€â‚¬Ã¢â€â‚¬ I/O helpers Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬

    private void forwardToView(HttpServletRequest request, HttpServletResponse response) {
        try {
            request.getRequestDispatcher(VIEW_PAGE).forward(request, response);
        } catch (Exception e) {
            try {
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Forward failed");
            } catch (IOException ex) {
                Thread.currentThread().interrupt();
            }
        }
    }

    private void redirect(HttpServletResponse response, String url) {
        try {
            response.sendRedirect(url);
        } catch (IOException e) {
            try {
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Redirect failed");
            } catch (IOException ex) {
                Thread.currentThread().interrupt();
            }
        }
    }

    private void redirectWithError(HttpServletRequest request,
                                   HttpServletResponse response, String message) {
        String encoded = URLEncoder.encode(message, StandardCharsets.UTF_8);
        redirect(response, request.getContextPath() + BASE_URL + "?error=" + encoded);
    }

    private void setEncoding(HttpServletRequest request) {
        try {
            request.setCharacterEncoding("UTF-8");
        } catch (Exception e) {
            Thread.currentThread().interrupt();
        }
    }

    private int parseInt(String value) {
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return 0;
        }
    }
}

