package controller.hr;

import dao.LeaveTypeDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;
import model.LeaveType;
import model.User;

@WebServlet("/hr/leave-types")
public class LeaveTypeController extends HttpServlet {

    private static final String ATTR_CURRENT_USER = "currentUser";
    private static final String BASE_URL          = "/hr/leave-types";
    private static final String VIEW_PAGE         = "/hr/leave-type.jsp";

    private final LeaveTypeDAO leaveTypeDAO = new LeaveTypeDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) {
        if (!isAuthorized(request, response)) return;

        try {
            List<LeaveType> list = leaveTypeDAO.getAll();
            request.setAttribute("leaveTypes", list);
        } catch (Exception e) {
            request.setAttribute("error", "Loi tai danh muc nghi phep: " + e.getMessage());
        }

        forwardToView(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) {
        setEncoding(request);
        if (!isAuthorized(request, response)) return;

        String action      = request.getParameter("action");
        String idStr       = request.getParameter("id");
        String typeName    = request.getParameter("name");
        String description = request.getParameter("description");
        String paidLeaveStr = request.getParameter("paidLeave");
        String maxDaysStr  = request.getParameter("maxDaysPerYear");

        if ("delete".equals(action) && idStr != null) {
            leaveTypeDAO.delete(parseInt(idStr));
            redirect(response, request.getContextPath() + BASE_URL);
            return;
        }

        if ("add".equals(action) || "edit".equals(action)) {
            handleAddOrEdit(request, response, action, idStr, typeName, description, paidLeaveStr, maxDaysStr);
            return;
        }

        redirect(response, request.getContextPath() + BASE_URL);
    }

    // ── Action handlers ───────────────────────────────────

    private void handleAddOrEdit(HttpServletRequest request, HttpServletResponse response,
                                 String action, String idStr, String typeName,
                                 String description, String paidLeaveStr, String maxDaysStr) {
        Integer id = "edit".equals(action) ? parseInt(idStr) : 0;
        LeaveType lt = buildLeaveType(id, typeName, description, paidLeaveStr, maxDaysStr);

        if (lt == null) {
            redirectWithError(request, response, "Du lieu khong hop le.");
            return;
        }
        if (leaveTypeDAO.isTypeNameExists(lt.getTypeName(), id)) {
            redirectWithError(request, response, "Ten loai nghi phep da ton tai.");
            return;
        }

        if ("add".equals(action)) {
            leaveTypeDAO.insert(lt);
        } else {
            leaveTypeDAO.update(lt);
        }

        redirect(response, request.getContextPath() + BASE_URL);
    }

    // ── Auth ──────────────────────────────────────────────

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

    // ── Builder ───────────────────────────────────────────

    private LeaveType buildLeaveType(int id, String name, String description,
                                     String paidLeaveStr, String maxDaysStr) {
        if (name == null || name.isBlank() || name.length() > 255) return null;

        String desc = description != null ? description.trim() : null;
        if (desc != null && desc.length() > 500) return null;

        int paidLeave  = "1".equals(paidLeaveStr) ? 1 : 0;
        Integer maxDays = parseOptionalInt(maxDaysStr);
        if (maxDays != null && (maxDays < 0 || maxDays > 365)) return null;

        return new LeaveType(id, name.trim(), desc, paidLeave, maxDays, 1);
    }

    // ── I/O helpers ───────────────────────────────────────

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

    // ── Parse helpers ─────────────────────────────────────

    private int parseInt(String value) {
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    private Integer parseOptionalInt(String value) {
        if (value == null || value.isBlank()) return null;
        try {
            return Integer.valueOf(value);
        } catch (NumberFormatException e) {
            return null;
        }
    }
}