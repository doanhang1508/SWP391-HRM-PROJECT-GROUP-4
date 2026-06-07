package controller.admin;

import java.io.IOException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import dao.UserDAO;
import dao.RoleDAO;
import dao.DepartmentDAO;
import dao.PositionDAO;

import model.User;
import model.Role;
import model.Department;
import model.Position;
import util.PasswordUtil;

import java.util.List;

@WebServlet(name = "AdminUserController", urlPatterns = {"/admin/users"})
public class AdminUserController extends HttpServlet {

    private static final String LOGIN_URL     = "/login";
    private static final String USERS_URL     = "/admin/users";
    private static final String DASHBOARD_URL = "/employee/dashboard";
    private static final String VIEW_PAGE     = "/admin/user-list.jsp";
    private static final String ATTR_MESSAGE  = "message";
    private static final String ATTR_ERROR    = "error";
    private static final String PARAM_ROLE_ID = "roleId";
    private static final String PARAM_USER_ID = "userId";
    private static final String DEFAULT_PASS  = "@123456";

    private final UserDAO       userDAO = new UserDAO();
    private final RoleDAO       roleDAO = new RoleDAO();
    private final DepartmentDAO deptDAO = new DepartmentDAO();
    private final PositionDAO   posDAO  = new PositionDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) {
        if (!isAdmin(request, response)) return;

        String keyword    = nullToEmpty(request.getParameter("keyword"));
        String roleFilter = request.getParameter(PARAM_ROLE_ID);
        String deptFilter = request.getParameter("departmentId");
        String posFilter  = request.getParameter("positionId");

        List<User> users = resolveUserList(keyword, roleFilter, deptFilter, posFilter);
        resolveFilterName(request, deptFilter, posFilter);

        List<Role> roles = roleDAO.getAllRoles();
        request.setAttribute("users", users);
        request.setAttribute("roles", roles);
        request.setAttribute("keyword", keyword);
        request.setAttribute("selectedRole", roleFilter);
        request.setAttribute("selectedDept", deptFilter);

        forwardToView(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) {
        HttpSession session = request.getSession(false);
        User currentUser = session != null ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null || currentUser.getRoleId() != 1) {
            redirect(response, request.getContextPath() + LOGIN_URL);
            return;
        }

        setEncoding(request);

        String action = request.getParameter("action");

        if ("toggleStatus".equals(action)) {
            handleToggleStatus(request, response);
        } else if ("updateRole".equals(action)) {
            handleUpdateRole(request, response);
        } else if ("addUser".equals(action)) {
            handleAddUser(request, response);
        } else {
            doGet(request, response);
        }
    }

    // ── Handlers ──────────────────────────────────────────

    private void handleToggleStatus(HttpServletRequest request, HttpServletResponse response) {
        String base = request.getContextPath() + USERS_URL;
        try {
            int userId = Integer.parseInt(request.getParameter(PARAM_USER_ID));
            User target = userDAO.getUserById(userId);
            if (target != null) {
                int newStatus = target.getStatus() == 1 ? 0 : 1;
                if (userDAO.updateUserStatus(userId, newStatus)) {
                    redirect(response, base + "?" + ATTR_MESSAGE + "=User+status+updated");
                    return;
                }
            }
        } catch (NumberFormatException e) {
            // fall through to error redirect
        }
        redirect(response, base + "?" + ATTR_ERROR + "=Failed+to+update+status");
    }

    private void handleUpdateRole(HttpServletRequest request, HttpServletResponse response) {
        String base = request.getContextPath() + USERS_URL;
        try {
            int userId = Integer.parseInt(request.getParameter(PARAM_USER_ID));
            int roleId = Integer.parseInt(request.getParameter(PARAM_ROLE_ID));
            if (userDAO.updateUserRole(userId, roleId)) {
                redirect(response, base + "?" + ATTR_MESSAGE + "=User+role+updated");
                return;
            }
        } catch (NumberFormatException e) {
            // fall through to error redirect
        }
        redirect(response, base + "?" + ATTR_ERROR + "=Failed+to+update+role");
    }

    private void handleAddUser(HttpServletRequest request, HttpServletResponse response) {
        String base  = request.getContextPath() + USERS_URL;
        String email = request.getParameter("email");

        if (email == null || email.trim().isEmpty()) {
            redirect(response, base + "?" + ATTR_ERROR + "=Email+is+required");
            return;
        }

        String username = email.contains("@") ? email.split("@")[0] : email;

        if (userDAO.isUserExists(username, email)) {
            redirect(response, base + "?" + ATTR_ERROR + "=Email+already+exists");
            return;
        }

        try {
            int roleId = Integer.parseInt(request.getParameter(PARAM_ROLE_ID));
            User newUser = buildNewUser(request, username, email, roleId);
            if (userDAO.addUser(newUser)) {
                redirect(response, base + "?" + ATTR_MESSAGE + "=User+added+successfully");
            } else {
                redirect(response, base + "?" + ATTR_ERROR + "=Failed+to+add+user");
            }
        } catch (NumberFormatException e) {
            redirect(response, base + "?" + ATTR_ERROR + "=Invalid+Role+ID");
        }
    }

    // ── Helpers ───────────────────────────────────────────

    private List<User> resolveUserList(String keyword, String roleFilter,
                                       String deptFilter, String posFilter) {
        if (deptFilter != null && !deptFilter.isEmpty()) {
            return parseAndFetch(deptFilter, id -> userDAO.getByDepartment(id));
        }
        if (posFilter != null && !posFilter.isEmpty()) {
            return parseAndFetch(posFilter, id -> userDAO.getByPosition(id));
        }
        if (roleFilter != null && !roleFilter.isEmpty()) {
            return parseAndFetch(roleFilter, id -> userDAO.searchUsers(keyword.trim(), id));
        }
        return userDAO.searchUsersByName(keyword.trim());
    }

    private List<User> parseAndFetch(String raw, java.util.function.IntFunction<List<User>> fetcher) {
        try {
            return fetcher.apply(Integer.parseInt(raw));
        } catch (NumberFormatException e) {
            return userDAO.getAllUsers();
        }
    }

    private void resolveFilterName(HttpServletRequest request, String deptFilter, String posFilter) {
        if (deptFilter != null && !deptFilter.isEmpty()) {
            setDeptFilterName(request, deptFilter);
        } else if (posFilter != null && !posFilter.isEmpty()) {
            setPosFilterName(request, posFilter);
        }
    }

    private void setDeptFilterName(HttpServletRequest request, String deptFilter) {
        try {
            int deptId = Integer.parseInt(deptFilter);
            for (Department d : deptDAO.getAll()) {
                if (d.getDepartmentId() == deptId) {
                    request.setAttribute("filterName", "Phong " + d.getDepartmentName());
                    break;
                }
            }
        } catch (NumberFormatException ignored) {
            // no filter name set
        }
    }

    private void setPosFilterName(HttpServletRequest request, String posFilter) {
        try {
            int posId = Integer.parseInt(posFilter);
            for (Position p : posDAO.getAll()) {
                if (p.getPositionId() == posId) {
                    request.setAttribute("filterName", "Chuc vu " + p.getPositionName());
                    break;
                }
            }
        } catch (NumberFormatException ignored) {
            // no filter name set
        }
    }

    private User buildNewUser(HttpServletRequest request, String username, String email, int roleId) {
        String password = request.getParameter("password");
        String rawPass  = (password != null && !password.isEmpty()) ? password : DEFAULT_PASS;

        User u = new User();
        u.setUsername(username.trim());
        u.setPassword(PasswordUtil.hashPassword(rawPass));
        u.setFullName(request.getParameter("fullName"));
        u.setEmail(email.trim());
        u.setPhone(request.getParameter("phone"));
        u.setRoleId(roleId);
        u.setStatus(1);
        return u;
    }

    private boolean isAdmin(HttpServletRequest request, HttpServletResponse response) {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            redirect(response, request.getContextPath() + LOGIN_URL);
            return false;
        }
        if (currentUser.getRoleId() != 1) {
            redirect(response, request.getContextPath() + DASHBOARD_URL);
            return false;
        }
        return true;
    }

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

    private void setEncoding(HttpServletRequest request) {
        try {
            request.setCharacterEncoding("UTF-8");
        } catch (Exception e) {
            Thread.currentThread().interrupt();
        }
    }

    private String nullToEmpty(String value) {
        return value == null ? "" : value;
    }

    @Override
    public String getServletInfo() {
        return "Admin User Controller";
    }
}