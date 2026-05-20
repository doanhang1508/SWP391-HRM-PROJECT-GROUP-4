package controller.admin;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import dao.UserDAO;
import dao.RoleDAO;
import model.User;
import java.util.List;

@WebServlet(name = "adminUserController", urlPatterns = {"/admin/users"})
public class adminUserController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Kiểm tra quyền (Admin)
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if (currentUser.getRoleId() != 1) {
            response.sendRedirect(request.getContextPath() + "/employee/dashboard");
            return;
        }

        UserDAO userDAO = new UserDAO();
        RoleDAO roleDAO = new RoleDAO();

        // Lấy danh sách để đổ ra bảng
        List<model.User> users = userDAO.getAllUsers();
        List<model.Role> roles = roleDAO.getAllRoles();

        request.setAttribute("users", users);
        request.setAttribute("roles", roles);

        request.getRequestDispatcher("/admin/user-list.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        model.User currentUser = session != null ? (model.User) session.getAttribute("currentUser") : null;
        if (currentUser == null || currentUser.getRoleId() != 1) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        UserDAO userDAO = new UserDAO();

        if ("toggleStatus".equals(action)) {
            String userIdRaw = request.getParameter("userId");
            try {
                int userId = Integer.parseInt(userIdRaw);
                model.User target = userDAO.getUserById(userId);
                if (target != null) {
                    int newStatus = target.getStatus() == 1 ? 0 : 1;
                    boolean ok = userDAO.updateUserStatus(userId, newStatus);
                    if (ok) {
                        response.sendRedirect(request.getContextPath() + "/admin/users?message=User+status+updated");
                        return;
                    }
                }
            } catch (NumberFormatException e) {
            }
            response.sendRedirect(request.getContextPath() + "/admin/users?error=Failed+to+update+status");
            return;
            
        } else if ("updateRole".equals(action)) {
            String userIdRaw = request.getParameter("userId");
            String roleIdRaw = request.getParameter("roleId");
            try {
                int userId = Integer.parseInt(userIdRaw);
                int roleId = Integer.parseInt(roleIdRaw);
                boolean ok = userDAO.updateUserRole(userId, roleId);
                if (ok) {
                    response.sendRedirect(request.getContextPath() + "/admin/users?message=User+role+updated");
                    return;
                }
            } catch (NumberFormatException e) {
            }
            response.sendRedirect(request.getContextPath() + "/admin/users?error=Failed+to+update+role");
            return;
            
        } else if ("addUser".equals(action)) {
            String password = request.getParameter("password");
            String fullName = request.getParameter("fullName");
            String email = request.getParameter("email");
            String phone = request.getParameter("phone");
            String roleIdRaw = request.getParameter("roleId");

            if (email == null || email.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/admin/users?error=Email+is+required");
                return;
            }

            String username = email.contains("@") ? email.split("@")[0] : email;

            if (userDAO.isUserExists(username, email)) {
                response.sendRedirect(request.getContextPath() + "/admin/users?error=Email+already+exists");
                return;
            }

            try {
                int roleId = Integer.parseInt(roleIdRaw);
                model.User newUser = new model.User();
                newUser.setUsername(username.trim());
                newUser.setPassword(password != null && !password.isEmpty() ? password : "@123456");
                newUser.setFullName(fullName);
                newUser.setEmail(email.trim());
                newUser.setPhone(phone);
                newUser.setRoleId(roleId);
                newUser.setStatus(1); 

                boolean ok = userDAO.addUser(newUser);
                if (ok) {
                    response.sendRedirect(request.getContextPath() + "/admin/users?message=User+added+successfully");
                    return;
                } else {
                    response.sendRedirect(request.getContextPath() + "/admin/users?error=Failed+to+add+user");
                    return;
                }
            } catch (NumberFormatException e) {
                response.sendRedirect(request.getContextPath() + "/admin/users?error=Invalid+Role+ID");
                return;
            }
        }
        doGet(request, response);
    }
}
