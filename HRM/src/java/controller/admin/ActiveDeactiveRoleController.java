package controller.admin;

import dao.RoleDAO;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Role;

/**
 *
 * @author HRM Group 4
 */
public class ActiveDeactiveRoleController extends HttpServlet {

    private final RoleDAO roleDAO = new RoleDAO();

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

        // Kiểm tra xem người dùng đã đăng nhập và có quyền quản trị hay chưa
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // Lấy tất cả các vai trò từ cơ sở dữ liệu
        List<Role> roleList = roleDAO.getAllRoles();

        // Với mỗi vai trò, hãy lấy số lượng người dùng được chỉ định cho vai trò đó
        for (Role role : roleList) {
            int userCount = roleDAO.countUsersByRole(role.getRoleId());
            request.setAttribute("userCount_" + role.getRoleId(), userCount);
        }

        request.setAttribute("roleList", roleList);

        // Kiểm tra thông báo thành công/lỗi từ các thao tác trước đó
        String message = request.getParameter("message");
        String error = request.getParameter("error");
        if (message != null) {
            request.setAttribute("message", message);
        }
        if (error != null) {
            request.setAttribute("error", error);
        }

        request.getRequestDispatcher("activeDeactiveRole.jsp").forward(request, response);
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

        // Check if user is logged in and is Admin
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String roleIdStr = request.getParameter("roleId");
        String action = request.getParameter("action"); // "activate", "deactivate", or "toggle"

        // Validate roleId parameter
        if (roleIdStr == null || roleIdStr.trim().isEmpty()) {
            response.sendRedirect("activeDeactiveRole?error=Role+ID+is+required");
            return;
        }

        try {
            int roleId = Integer.parseInt(roleIdStr);

            // Lấy thông tin vai trò hiện tại để đăng nhập
            Role currentRole = roleDAO.getRoleById(roleId);
            if (currentRole == null) {
                response.sendRedirect("activeDeactiveRole?error=Role+not+found");
                return;
            }

            boolean success;
            String statusMessage;

            if ("activate".equals(action)) {
                // Explicitly set to Active
                success = roleDAO.updateRoleStatus(roleId, 1);
                statusMessage = "Role+'" + currentRole.getRoleName() + "'+has+been+activated";
            } else if ("deactivate".equals(action)) {
                // Explicitly set to Deactive
                success = roleDAO.updateRoleStatus(roleId, 0);
                statusMessage = "Role+'" + currentRole.getRoleName() + "'+has+been+deactivated";
            } else {
                // Default: Toggle the status
                success = roleDAO.toggleRoleStatus(roleId);
                String newStatus = currentRole.isActive() ? "deactivated" : "activated";
                statusMessage = "Role+'" + currentRole.getRoleName() + "'+has+been+" + newStatus;
            }

            String source = request.getParameter("source");
            String redirectUrl = "activeDeactiveRole";
            if ("roleList".equals(source)) {
                redirectUrl = "role?action=list";
            } else if ("dashboard".equals(source)) {
                redirectUrl = "admin/dashboard";
            }

            if (success) {
                response.sendRedirect(redirectUrl + (redirectUrl.contains("?") ? "&" : "?") + "message=" + statusMessage);
            } else {
                response.sendRedirect(redirectUrl + (redirectUrl.contains("?") ? "&" : "?") + "error=Failed+to+update+role+status");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect("activeDeactiveRole?error=Invalid+Role+ID");
        }
    }

    @Override
    public String getServletInfo() {
        return "Active/Deactive Role Controller - Enables or disables roles for all assigned users";
    }
}
