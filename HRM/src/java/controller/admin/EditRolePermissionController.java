package controller.admin;

import dao.RoleDAO;
import dao.PermissionDAO;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Permission;
import model.Role;

public class EditRolePermissionController extends HttpServlet {

    private static final String ATTR_CURRENT_USER = "currentUser";
    private static final String LOGIN_PAGE        = "login.jsp";
    private static final String BASE_URL          = "editRolePermission";
    private static final String SELECT_VIEW       = "admin/selectRoleForPermission.jsp";
    private static final String EDIT_VIEW         = "admin/editRolePermission.jsp";

    private final RoleDAO       roleDAO           = new RoleDAO();
    private final PermissionDAO rolePermissionDAO = new PermissionDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) {
        if (!isAuthenticated(request, response)) return;

        String roleIdStr = request.getParameter("roleId");
        if (roleIdStr == null || roleIdStr.trim().isEmpty()) {
            showRoleList(request, response);
            return;
        }

        parseAndShowPermissions(request, response, roleIdStr);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) {
        if (!isAuthenticated(request, response)) return;

        String roleIdStr = request.getParameter("roleId");
        if (roleIdStr == null || roleIdStr.trim().isEmpty()) {
            redirect(response, BASE_URL + "?error=Role+ID+is+required");
            return;
        }

        parseAndUpdatePermissions(request, response, roleIdStr);
    }

    // ── doGet helpers ─────────────────────────────────────

    private void showRoleList(HttpServletRequest request, HttpServletResponse response) {
        List<Role> roleList = roleDAO.getAllRoles();
        request.setAttribute("roleList", roleList);
        forwardToView(request, response, SELECT_VIEW);
    }

    private void parseAndShowPermissions(HttpServletRequest request,
                                         HttpServletResponse response,
                                         String roleIdStr) {
        try {
            int roleId = Integer.parseInt(roleIdStr);
            Role role = roleDAO.getRoleById(roleId);
            if (role == null) {
                redirect(response, BASE_URL + "?error=Role+not+found");
                return;
            }
            loadPermissionsToRequest(request, role, roleId);
            forwardToView(request, response, EDIT_VIEW);
        } catch (NumberFormatException e) {
            redirect(response, BASE_URL + "?error=Invalid+Role+ID");
        }
    }

    private void loadPermissionsToRequest(HttpServletRequest request, Role role, int roleId) {
        List<Permission> allPermissions    = rolePermissionDAO.getAllPermissions();
        List<Integer> assignedPermissionIds = rolePermissionDAO.getPermissionIdsByRoleId(roleId);

        request.setAttribute("role", role);
        request.setAttribute("allPermissions", allPermissions);
        request.setAttribute("assignedPermissionIds", assignedPermissionIds);

        String message = request.getParameter("message");
        String error   = request.getParameter("error");
        if (message != null) request.setAttribute("message", message);
        if (error   != null) request.setAttribute("error",   error);
    }

    // ── doPost helpers ────────────────────────────────────

    private void parseAndUpdatePermissions(HttpServletRequest request,
                                           HttpServletResponse response,
                                           String roleIdStr) {
        try {
            int roleId = Integer.parseInt(roleIdStr);
            Role role = roleDAO.getRoleById(roleId);
            if (role == null) {
                redirect(response, BASE_URL + "?error=Role+not+found");
                return;
            }
            List<Integer> newPermissionIds = parsePermissionIds(request);
            applyPermissionUpdate(response, role, roleId, newPermissionIds);
        } catch (NumberFormatException e) {
            redirect(response, BASE_URL + "?error=Invalid+Role+ID");
        }
    }

    private List<Integer> parsePermissionIds(HttpServletRequest request) {
        String[] permissionIdStrs = request.getParameterValues("permissions");
        List<Integer> ids = new ArrayList<>();
        if (permissionIdStrs == null) return ids;
        for (String idStr : permissionIdStrs) {
            try {
                ids.add(Integer.parseInt(idStr));
            } catch (NumberFormatException e) {
                // Skip invalid permission IDs
            }
        }
        return ids;
    }

    private void applyPermissionUpdate(HttpServletResponse response, Role role,
                                       int roleId, List<Integer> newPermissionIds) {
        boolean success = rolePermissionDAO.updateRolePermissions(roleId, newPermissionIds);
        if (success) {
            String msg = "Permissions+updated+successfully+for+role+'"
                    + role.getRoleName() + "'.+"
                    + newPermissionIds.size() + "+permission(s)+assigned.";
            redirect(response, BASE_URL + "?roleId=" + roleId + "&message=" + msg);
        } else {
            redirect(response, BASE_URL + "?roleId=" + roleId
                    + "&error=Failed+to+update+permissions.+Please+try+again.");
        }
    }

    // ── Auth + I/O helpers ────────────────────────────────

    private boolean isAuthenticated(HttpServletRequest request, HttpServletResponse response) {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute(ATTR_CURRENT_USER) == null) {
            redirect(response, LOGIN_PAGE);
            return false;
        }
        return true;
    }

    private void forwardToView(HttpServletRequest request,
                               HttpServletResponse response, String view) {
        try {
            request.getRequestDispatcher(view).forward(request, response);
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

    @Override
    public String getServletInfo() {
        return "Edit Role Permission Controller";
    }
}