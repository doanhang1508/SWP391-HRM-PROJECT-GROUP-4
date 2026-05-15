package controller;

import dal.PermissionDAO;
import dal.RoleDAO;
import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import constant.PageConstant;
import model.Permission;
import model.Role;
import model.User;

@WebServlet(name = "RoleController", urlPatterns = {"/role"})
public class RoleController extends HttpServlet {

    private RoleDAO roleDAO;
    private PermissionDAO permissionDAO;

    @Override
    public void init() throws ServletException {
        roleDAO = new RoleDAO();
        permissionDAO = new PermissionDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        processRequest(request, response);
    }

    private void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = getLoginUser(request);

        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");

        if (action == null || action.trim().isEmpty()) {
            action = "list";
        }

        switch (action) {
            case "list":
                viewRoleList(request, response, user);
                break;

            case "permissions":
                viewRolePermissions(request, response, user);
                break;

            case "update":
                if ("POST".equalsIgnoreCase(request.getMethod())) {
                    updateRoleInformation(request, response, user);
                } else {
                    showUpdateRoleForm(request, response, user);
                }
                break;

            default:
                viewRoleList(request, response, user);
                break;
        }
    }

    private User getLoginUser(HttpServletRequest request) {
        HttpSession session = request.getSession();
        return (User) session.getAttribute("account");
    }

    private void viewRoleList(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {

        if (!permissionDAO.canViewRoleList(user.getUserId())) {
            request.setAttribute("error", "Bạn không có quyền xem danh sách vai trò.");
            request.getRequestDispatcher(PageConstant.NO_PERMISSION_PAGE).forward(request, response);
            return;
        }

        boolean canViewPermission = permissionDAO.canViewRolePermissions(user.getUserId());
        boolean canUpdateRole = permissionDAO.canUpdateRoleInformation(user.getUserId());

        List<Role> roles = roleDAO.getAllRoles();

        request.setAttribute("roles", roles);
        request.setAttribute("canViewPermission", canViewPermission);
        request.setAttribute("canUpdateRole", canUpdateRole);

        request.getRequestDispatcher(PageConstant.ROLE_LIST_PAGE).forward(request, response);
    }

    private void viewRolePermissions(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {

        if (!permissionDAO.canViewRolePermissions(user.getUserId())) {
            request.setAttribute("error", "Bạn không có quyền xem quyền của vai trò.");
            request.getRequestDispatcher(PageConstant.NO_PERMISSION_PAGE).forward(request, response);
            return;
        }

        Integer roleId = getRoleIdFromRequest(request);

        if (roleId == null) {
            request.setAttribute("error", "Role ID không hợp lệ.");
            request.getRequestDispatcher(PageConstant.ROLE_PERMISSIONS_PAGE).forward(request, response);
            return;
        }

        Role role = roleDAO.getRoleById(roleId);

        if (role == null) {
            request.setAttribute("error", "Không tìm thấy role.");
            request.getRequestDispatcher(PageConstant.ROLE_PERMISSIONS_PAGE).forward(request, response);
            return;
        }

        List<Permission> permissions = permissionDAO.getPermissionsByRoleId(roleId);

        request.setAttribute("role", role);
        request.setAttribute("permissions", permissions);

        request.getRequestDispatcher(PageConstant.ROLE_PERMISSIONS_PAGE).forward(request, response);
    }

    private void showUpdateRoleForm(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {

        if (!permissionDAO.canUpdateRoleInformation(user.getUserId())) {
            request.setAttribute("error", "Bạn không có quyền cập nhật thông tin vai trò.");
            request.getRequestDispatcher(PageConstant.NO_PERMISSION_PAGE).forward(request, response);
            return;
        }

        Integer roleId = getRoleIdFromRequest(request);

        if (roleId == null) {
            request.setAttribute("error", "Role ID không hợp lệ.");
            request.getRequestDispatcher(PageConstant.ROLE_UPDATE_PAGE).forward(request, response);
            return;
        }

        Role role = roleDAO.getRoleById(roleId);

        if (role == null) {
            request.setAttribute("error", "Không tìm thấy role.");
            request.getRequestDispatcher(PageConstant.ROLE_UPDATE_PAGE).forward(request, response);
            return;
        }

        if ("1".equals(request.getParameter("success"))) {
            request.setAttribute("success", "Cập nhật thông tin role thành công.");
        }

        request.setAttribute("role", role);
        request.getRequestDispatcher(PageConstant.ROLE_UPDATE_PAGE).forward(request, response);
    }

    private void updateRoleInformation(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {

        if (!permissionDAO.canUpdateRoleInformation(user.getUserId())) {
            request.setAttribute("error", "Bạn không có quyền cập nhật thông tin vai trò.");
            request.getRequestDispatcher(PageConstant.NO_PERMISSION_PAGE).forward(request, response);
            return;
        }

        Integer roleId = getRoleIdFromRequest(request);

        if (roleId == null) {
            request.setAttribute("error", "Role ID không hợp lệ.");
            request.getRequestDispatcher(PageConstant.ROLE_UPDATE_PAGE).forward(request, response);
            return;
        }

        Role role = roleDAO.getRoleById(roleId);

        if (role == null) {
            request.setAttribute("error", "Không tìm thấy role.");
            request.getRequestDispatcher(PageConstant.ROLE_UPDATE_PAGE).forward(request, response);
            return;
        }

        String roleName = request.getParameter("roleName");
        String description = request.getParameter("description");

        if (roleName != null) {
            roleName = roleName.trim();
        }

        if (description != null) {
            description = description.trim();
        }

        role.setRoleName(roleName);
        role.setDescription(description);

        if (roleName == null || roleName.isEmpty()) {
            request.setAttribute("role", role);
            request.setAttribute("error", "Role name không được để trống.");
            request.getRequestDispatcher(PageConstant.ROLE_UPDATE_PAGE).forward(request, response);
            return;
        }

        if (roleName.length() > 50) {
            request.setAttribute("role", role);
            request.setAttribute("error", "Role name không được vượt quá 50 ký tự.");
            request.getRequestDispatcher(PageConstant.ROLE_UPDATE_PAGE).forward(request, response);
            return;
        }

        if (description != null && description.length() > 255) {
            request.setAttribute("role", role);
            request.setAttribute("error", "Description không được vượt quá 255 ký tự.");
            request.getRequestDispatcher(PageConstant.ROLE_UPDATE_PAGE).forward(request, response);
            return;
        }

        if (roleDAO.isRoleNameExistsForOtherRole(roleName, roleId)) {
            request.setAttribute("role", role);
            request.setAttribute("error", "Role name này đã tồn tại.");
            request.getRequestDispatcher(PageConstant.ROLE_UPDATE_PAGE).forward(request, response);
            return;
        }

        boolean updated = roleDAO.updateRoleInformation(roleId, roleName, description);

        if (updated) {
            response.sendRedirect("role?action=update&roleId=" + roleId + "&success=1");
        } else {
            request.setAttribute("role", role);
            request.setAttribute("error", "Cập nhật thất bại. Vui lòng thử lại.");
            request.getRequestDispatcher(PageConstant.ROLE_UPDATE_PAGE).forward(request, response);
        }
    }

    private Integer getRoleIdFromRequest(HttpServletRequest request) {
        String roleIdRaw = request.getParameter("roleId");

        if (roleIdRaw == null || roleIdRaw.trim().isEmpty()) {
            return null;
        }

        try {
            return Integer.parseInt(roleIdRaw);
        } catch (NumberFormatException e) {
            return null;
        }
    }
}