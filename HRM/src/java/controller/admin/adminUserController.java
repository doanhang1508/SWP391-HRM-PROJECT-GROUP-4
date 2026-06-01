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
import model.Role;
import util.PasswordUtil;

import java.util.List;

@WebServlet(name = "adminUserController", urlPatterns = {"/admin/users"})
public class adminUserController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Kiểm tra đăng nhập + quyền admin
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

        // ===== LẤY GIÁ TRỊ SEARCH + FILTER =====
        String keyword    = request.getParameter("keyword");
        String roleFilter = request.getParameter("roleId");
        String deptFilter = request.getParameter("departmentId");
        String posFilter  = request.getParameter("positionId");

        if (keyword == null) keyword = "";

        List<User> users;

        // ===== FILTER BY DEPARTMENT (từ trang department) =====
        if (deptFilter != null && !deptFilter.isEmpty()) {
            try {
                int departmentId = Integer.parseInt(deptFilter);
                users = userDAO.getByDepartment(departmentId);
            } catch (NumberFormatException e) {
                users = userDAO.getAllUsers();
            }
        } else if (posFilter != null && !posFilter.isEmpty()) {
            try {
                int positionId = Integer.parseInt(posFilter);
                users = userDAO.getByPosition(positionId);
            } catch (NumberFormatException e) {
                users = userDAO.getAllUsers();
            }
        } else if (roleFilter != null && !roleFilter.isEmpty()) {
            try {
                int roleId = Integer.parseInt(roleFilter);
                users = userDAO.searchUsers(keyword.trim(), roleId);
            } catch (NumberFormatException e) {
                users = userDAO.getAllUsers();
            }
        } else {
            users = userDAO.searchUsersByName(keyword.trim());
        }

        // Lấy danh sách role
        List<Role> roles = roleDAO.getAllRoles();

        // Lấy tên phòng ban/chức vụ nếu đang filter
        if (deptFilter != null && !deptFilter.isEmpty()) {
            try {
                dao.DepartmentDAO deptDao = new dao.DepartmentDAO();
                java.util.List<model.Department> allDepts = deptDao.getAll();
                int deptId = Integer.parseInt(deptFilter);
                for (model.Department d : allDepts) {
                    if (d.getDepartmentId() == deptId) {
                        request.setAttribute("filterName", "Phòng " + d.getDepartmentName());
                        break;
                    }
                }
            } catch (NumberFormatException ignored) {}
        } else if (posFilter != null && !posFilter.isEmpty()) {
            try {
                dao.PositionDAO posDao = new dao.PositionDAO();
                java.util.List<model.Position> allPos = posDao.getAll();
                int posId = Integer.parseInt(posFilter);
                for (model.Position p : allPos) {
                    if (p.getPositionId() == posId) {
                        request.setAttribute("filterName", "Chức vụ " + p.getPositionName());
                        break;
                    }
                }
            } catch (NumberFormatException ignored) {}
        }

        // Đẩy dữ liệu sang JSP
        request.setAttribute("users", users);
        request.setAttribute("roles", roles);
        request.setAttribute("keyword", keyword);
        request.setAttribute("selectedRole", roleFilter);
        request.setAttribute("selectedDept", deptFilter);

        request.getRequestDispatcher("/admin/user-list.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        User currentUser = session != null
                ? (User) session.getAttribute("currentUser")
                : null;

        // Kiểm tra quyền admin
        if (currentUser == null || currentUser.getRoleId() != 1) {

            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");

        UserDAO userDAO = new UserDAO();

        // =================================================
        // TOGGLE USER STATUS
        // =================================================
        if ("toggleStatus".equals(action)) {

            String userIdRaw = request.getParameter("userId");

            try {

                int userId = Integer.parseInt(userIdRaw);

                User target = userDAO.getUserById(userId);

                if (target != null) {

                    int newStatus = target.getStatus() == 1 ? 0 : 1;

                    boolean ok = userDAO.updateUserStatus(userId, newStatus);

                    if (ok) {

                        response.sendRedirect(
                                request.getContextPath()
                                + "/admin/users?message=User+status+updated"
                        );
                        return;
                    }
                }

            } catch (NumberFormatException e) {

            }

            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/users?error=Failed+to+update+status"
            );
            return;
        }

        // =================================================
        // UPDATE ROLE
        // =================================================
        else if ("updateRole".equals(action)) {

            String userIdRaw = request.getParameter("userId");
            String roleIdRaw = request.getParameter("roleId");

            try {

                int userId = Integer.parseInt(userIdRaw);
                int roleId = Integer.parseInt(roleIdRaw);

                boolean ok = userDAO.updateUserRole(userId, roleId);

                if (ok) {

                    response.sendRedirect(
                            request.getContextPath()
                            + "/admin/users?message=User+role+updated"
                    );
                    return;
                }

            } catch (NumberFormatException e) {

            }

            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/users?error=Failed+to+update+role"
            );
            return;
        }

        // =================================================
        // ADD USER
        // =================================================
        else if ("addUser".equals(action)) {

            String password = request.getParameter("password");
            String fullName = request.getParameter("fullName");
            String email = request.getParameter("email");
            String phone = request.getParameter("phone");
            String roleIdRaw = request.getParameter("roleId");

            // Validate email
            if (email == null || email.trim().isEmpty()) {

                response.sendRedirect(
                        request.getContextPath()
                        + "/admin/users?error=Email+is+required"
                );
                return;
            }

            // Tạo username từ email
            String username = email.contains("@")
                    ? email.split("@")[0]
                    : email;

            // Check tồn tại
            if (userDAO.isUserExists(username, email)) {

                response.sendRedirect(
                        request.getContextPath()
                        + "/admin/users?error=Email+already+exists"
                );
                return;
            }

            try {

                int roleId = Integer.parseInt(roleIdRaw);

                User newUser = new User();

                newUser.setUsername(username.trim());

                newUser.setPassword(
                        PasswordUtil.hashPassword(
                            password != null && !password.isEmpty()
                            ? password
                            : "@123456"
                        )
                );

                newUser.setFullName(fullName);

                newUser.setEmail(email.trim());

                newUser.setPhone(phone);

                newUser.setRoleId(roleId);

                newUser.setStatus(1);

                boolean ok = userDAO.addUser(newUser);

                if (ok) {

                    response.sendRedirect(
                            request.getContextPath()
                            + "/admin/users?message=User+added+successfully"
                    );
                    return;

                } else {

                    response.sendRedirect(
                            request.getContextPath()
                            + "/admin/users?error=Failed+to+add+user"
                    );
                    return;
                }

            } catch (NumberFormatException e) {

                response.sendRedirect(
                        request.getContextPath()
                        + "/admin/users?error=Invalid+Role+ID"
                );
                return;
            }
        }

        doGet(request, response);
    }
}
