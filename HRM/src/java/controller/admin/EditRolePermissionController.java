package controller.admin;

import dao.RoleDAO;
import dao.PermissionDAO;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Permission;
import model.Role;

/**
 *
 * 
 * @author HRM Group 4
 */
public class EditRolePermissionController extends HttpServlet {

    private final RoleDAO roleDAO = new RoleDAO();
    private final PermissionDAO rolePermissionDAO = new PermissionDAO();

    /**
     * 
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String roleIdStr = request.getParameter("roleId");

        if (roleIdStr == null || roleIdStr.trim().isEmpty()) {
            // Không cung cấp roleId → hiển thị danh sách tất cả các vai trò để lựa chọn
            List<Role> roleList = roleDAO.getAllRoles();
            request.setAttribute("roleList", roleList);
            request.getRequestDispatcher("admin/selectRoleForPermission.jsp").forward(request, response);
            return;
        }

        try {
            int roleId = Integer.parseInt(roleIdStr);

            // Lấy thông tin về vai trò
            Role role = roleDAO.getRoleById(roleId);
            if (role == null) {
                response.sendRedirect("editRolePermission?error=Role+not+found");
                return;
            }

            // Lấy tất cả các quyền có sẵn
            List<Permission> allPermissions = rolePermissionDAO.getAllPermissions();

            // Lấy ID quyền hiện được gán cho vai trò này
            List<Integer> assignedPermissionIds = rolePermissionDAO.getPermissionIdsByRoleId(roleId);

            request.setAttribute("role", role);
            request.setAttribute("allPermissions", allPermissions);
            request.setAttribute("assignedPermissionIds", assignedPermissionIds);

            // Kiểm tra thông báo thành công/lỗi
            String message = request.getParameter("message");
            String error = request.getParameter("error");
            if (message != null) {
                request.setAttribute("message", message);
            }
            if (error != null) {
                request.setAttribute("error", error);
            }

            request.getRequestDispatcher("admin/editRolePermission.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect("editRolePermission?error=Invalid+Role+ID");
        }
    }

    /**
     * 
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Kiểm tra xem người dùng đã đăng nhập và có quyền quản trị hay chưa.
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String roleIdStr = request.getParameter("roleId");

        // Xác thực roleId
        if (roleIdStr == null || roleIdStr.trim().isEmpty()) {
            response.sendRedirect("editRolePermission?error=Role+ID+is+required");
            return;
        }

        try {
            int roleId = Integer.parseInt(roleIdStr);

           // Lấy vai trò để xác minh xem nó có tồn tại hay không
            Role role = roleDAO.getRoleById(roleId);
            if (role == null) {
                response.sendRedirect("editRolePermission?error=Role+not+found");
                return;
            }

            // Lấy ID quyền được chọn từ biểu mẫu (ô chọn)
            String[] permissionIdStrs = request.getParameterValues("permissions");
            List<Integer> newPermissionIds = new ArrayList<>();

            if (permissionIdStrs != null) {
                for (String idStr : permissionIdStrs) {
                    try {
                        newPermissionIds.add(Integer.parseInt(idStr));
                    } catch (NumberFormatException e) {
                        // Skip invalid permission IDs
                    }
                }
            }

            // Cập nhật quyền hạn của vai trò trong cơ sở dữ liệu
            boolean success = rolePermissionDAO.updateRolePermissions(roleId, newPermissionIds);

            if (success) {
                int permCount = newPermissionIds.size();
                String msg = "Permissions+updated+successfully+for+role+'"
                        + role.getRoleName() + "'.+"
                        + permCount + "+permission(s)+assigned.";
                response.sendRedirect("editRolePermission?roleId=" + roleId + "&message=" + msg);
            } else {
                response.sendRedirect("editRolePermission?roleId=" + roleId
                        + "&error=Failed+to+update+permissions.+Please+try+again.");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect("editRolePermission?error=Invalid+Role+ID");
        }
    }

    @Override
    public String getServletInfo() {
        return "Edit Role Permission Controller - Fine-tune permissions for each role";
    }
}
