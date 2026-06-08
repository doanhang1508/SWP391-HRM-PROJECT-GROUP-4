package controller.admin;

import dao.RoleDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Role;

import java.io.IOException;
import java.util.List;

public class ActiveDeactiveRoleController extends HttpServlet {

    private static final String ROLE_PREFIX = "Role+'";
    private static final String LOGIN_PAGE = "login.jsp";
    private static final String MAIN_PAGE = "admin/activeDeactiveRole";
    private static final String ACTIVATE = "activate";
    private static final String DEACTIVATE = "deactivate";

    private final RoleDAO roleDAO = new RoleDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAuthenticated(request, response)) return;

        List<Role> roleList = roleDAO.getAllRoles();
        for (Role role : roleList) {
            int userCount = roleDAO.countUsersByRole(role.getRoleId());
            request.setAttribute("userCount_" + role.getRoleId(), userCount);
        }
        request.setAttribute("roleList", roleList);

        String message = request.getParameter("message");
        String error = request.getParameter("error");
        if (message != null) request.setAttribute("message", message);
        if (error != null) request.setAttribute("error", error);

        try {
            request.getRequestDispatcher("/admin/activeDeactiveRole.jsp").forward(request, response);
        } catch (ServletException | IOException e) {
            try {
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Forward failed");
            } catch (IOException ex) {
                Thread.currentThread().interrupt();
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAuthenticated(request, response)) return;

        String roleIdStr = request.getParameter("roleId");
        if (roleIdStr == null || roleIdStr.trim().isEmpty()) {
            redirect(request, response, MAIN_PAGE + "?error=Role+ID+is+required");
            return;
        }
        parseAndProcess(request, response, roleIdStr);
    }

    private void parseAndProcess(HttpServletRequest request, HttpServletResponse response, String roleIdStr) {
        try {
            int roleId = Integer.parseInt(roleIdStr);
            processRoleAction(request, response, roleId);
        } catch (NumberFormatException e) {
            redirect(request, response, MAIN_PAGE + "?error=Invalid+Role+ID");
        } catch (IOException e) {
            redirect(request, response, MAIN_PAGE + "?error=Internal+server+error");
        }
    }

    private void processRoleAction(HttpServletRequest request, HttpServletResponse response, int roleId)
            throws IOException {

        Role currentRole = roleDAO.getRoleById(roleId);
        if (currentRole == null) {
            redirect(request, response, MAIN_PAGE + "?error=Role+not+found");
            return;
        }

        String action = request.getParameter("action");
        String source = request.getParameter("source");
        boolean success = updateRoleByAction(action, roleId);
        String redirectUrl = resolveRedirectUrl(source);
        String separator = redirectUrl.contains("?") ? "&" : "?";

        if (success) {
            String statusMessage = buildStatusMessage(action, currentRole);
            redirect(request, response, redirectUrl + separator + "message=" + statusMessage);
        } else {
            redirect(request, response, redirectUrl + separator + "error=Failed+to+update+role+status");
        }
    }

    private boolean updateRoleByAction(String action, int roleId) {
        if (ACTIVATE.equals(action)) return roleDAO.updateRoleStatus(roleId, 1);
        if (DEACTIVATE.equals(action)) return roleDAO.updateRoleStatus(roleId, 0);
        return roleDAO.toggleRoleStatus(roleId);
    }

    private String buildStatusMessage(String action, Role currentRole) {
        String name = currentRole.getRoleName();
        if (ACTIVATE.equals(action)) return ROLE_PREFIX + name + "'+has+been+activated";
        if (DEACTIVATE.equals(action)) return ROLE_PREFIX + name + "'+has+been+deactivated";
        String newStatus = currentRole.isActive() ? "deactivated" : "activated";
        return ROLE_PREFIX + name + "'+has+been+" + newStatus;
    }

    private String resolveRedirectUrl(String source) {
        if ("roleList".equals(source)) return "role?action=list";
        if ("dashboard".equals(source)) return "admin/dashboard";
        return MAIN_PAGE;
    }

    private boolean isAuthenticated(HttpServletRequest request, HttpServletResponse response) {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            redirect(request, response, LOGIN_PAGE);
            return false;
        }
        return true;
    }

    private void redirect(HttpServletRequest request, HttpServletResponse response, String url) {
        try {
            response.sendRedirect(request.getContextPath() + "/" + url);
        } catch (IOException e) {
            try {
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Redirect failed");
            } catch (IOException ex) {
                Thread.currentThread().interrupt();
            }
        }
    }

    @Override
    public String getServletInfo() {
        return "Active/Deactive Role Controller";
    }
}