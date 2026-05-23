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
import util.EmailUtil;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@WebServlet(name = "adminUserController", urlPatterns = {"/admin/users"})
public class adminUserController extends HttpServlet {

    private static final int DEFAULT_PAGE_SIZE = 10;

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

        // Lấy danh sách gốc
        List<User> allUsers = userDAO.getAllUsers();
        List<Role> roles = roleDAO.getAllRoles();

        // ═══════════════════════════════════════════
        // 1. TÌM KIẾM & LỌC
        // ═══════════════════════════════════════════
        String search = request.getParameter("search");
        String filterRole = request.getParameter("filterRole");
        String filterStatus = request.getParameter("filterStatus");

        // Lọc theo keyword (tên / email / username)
        if (search != null && !search.trim().isEmpty()) {
            String keyword = search.trim().toLowerCase();
            allUsers = allUsers.stream()
                    .filter(u -> (u.getFullName() != null && u.getFullName().toLowerCase().contains(keyword))
                    || (u.getEmail() != null && u.getEmail().toLowerCase().contains(keyword))
                    || (u.getUsername() != null && u.getUsername().toLowerCase().contains(keyword)))
                    .collect(Collectors.toList());
        }

        // Lọc theo vai trò
        if (filterRole != null && !filterRole.trim().isEmpty()) {
            try {
                int roleId = Integer.parseInt(filterRole);
                allUsers = allUsers.stream()
                        .filter(u -> u.getRoleId() == roleId)
                        .collect(Collectors.toList());
            } catch (NumberFormatException ignored) {
            }
        }

        // Lọc theo trạng thái
        if (filterStatus != null && !filterStatus.trim().isEmpty()) {
            try {
                int status = Integer.parseInt(filterStatus);
                allUsers = allUsers.stream()
                        .filter(u -> u.getStatus() == status)
                        .collect(Collectors.toList());
            } catch (NumberFormatException ignored) {
            }
        }

        // ═══════════════════════════════════════════
        // 2. SẮP XẾP
        // ═══════════════════════════════════════════
        String sortBy = request.getParameter("sortBy");
        String sortDir = request.getParameter("sortDir");
        if (sortDir == null || (!sortDir.equals("asc") && !sortDir.equals("desc"))) {
            sortDir = "asc";
        }

        if (sortBy != null && !sortBy.trim().isEmpty()) {
            Comparator<User> comparator;
            switch (sortBy) {
                case "name":
                    comparator = Comparator.comparing(u -> u.getFullName() != null ? u.getFullName().toLowerCase() : "");
                    break;
                case "email":
                    comparator = Comparator.comparing(u -> u.getEmail() != null ? u.getEmail().toLowerCase() : "");
                    break;
                case "username":
                    comparator = Comparator.comparing(u -> u.getUsername() != null ? u.getUsername().toLowerCase() : "");
                    break;
                case "createdAt":
                    comparator = Comparator.comparing(u -> u.getCreatedAt() != null ? u.getCreatedAt().getTime() : 0L);
                    break;
                case "status":
                    comparator = Comparator.comparingInt(User::getStatus);
                    break;
                default:
                    comparator = Comparator.comparingInt(User::getUserId);
                    break;
            }
            if ("desc".equals(sortDir)) {
                comparator = comparator.reversed();
            }
            allUsers.sort(comparator);
        }

        // ═══════════════════════════════════════════
        // 3. PHÂN TRANG
        // ═══════════════════════════════════════════
        int totalUsers = allUsers.size();
        int pageSize = DEFAULT_PAGE_SIZE;
        String pageSizeParam = request.getParameter("pageSize");
        if (pageSizeParam != null) {
            try {
                pageSize = Integer.parseInt(pageSizeParam);
                if (pageSize < 5) pageSize = 5;
                if (pageSize > 100) pageSize = 100;
            } catch (NumberFormatException ignored) {
            }
        }

        int totalPages = (int) Math.ceil((double) totalUsers / pageSize);
        if (totalPages < 1) totalPages = 1;

        int currentPage = 1;
        String pageParam = request.getParameter("page");
        if (pageParam != null) {
            try {
                currentPage = Integer.parseInt(pageParam);
            } catch (NumberFormatException ignored) {
            }
        }
        if (currentPage < 1) currentPage = 1;
        if (currentPage > totalPages) currentPage = totalPages;

        int fromIndex = (currentPage - 1) * pageSize;
        int toIndex = Math.min(fromIndex + pageSize, totalUsers);
        List<User> pagedUsers = allUsers.subList(fromIndex, toIndex);

        // ═══════════════════════════════════════════
        // 4. ĐẶT ATTRIBUTE & FORWARD
        // ═══════════════════════════════════════════
        request.setAttribute("users", pagedUsers);
        request.setAttribute("roles", roles);

        // Pagination info
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalUsers", totalUsers);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("fromIndex", fromIndex + 1);
        request.setAttribute("toIndex", toIndex);

        // Preserve filter/sort params
        request.setAttribute("search", search != null ? search : "");
        request.setAttribute("filterRole", filterRole != null ? filterRole : "");
        request.setAttribute("filterStatus", filterStatus != null ? filterStatus : "");
        request.setAttribute("sortBy", sortBy != null ? sortBy : "");
        request.setAttribute("sortDir", sortDir);

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

        } else if ("resetPassword".equals(action)) {
            // ═══════════════════════════════════════════
            // RESET MẬT KHẨU - Tạo mật khẩu mới & gửi email
            // ═══════════════════════════════════════════
            String userIdRaw = request.getParameter("userId");
            try {
                int userId = Integer.parseInt(userIdRaw);
                model.User target = userDAO.getUserById(userId);

                if (target == null) {
                    response.sendRedirect(request.getContextPath() + "/admin/users?error=User+not+found");
                    return;
                }

                // Tạo mật khẩu mới ngẫu nhiên (8 ký tự)
                String newPassword = generateRandomPassword(8);
                String hashedPassword = PasswordUtil.hashPassword(newPassword);

                boolean ok = userDAO.updatePassword(userId, hashedPassword);
                if (ok) {
                    // Gửi email thông báo mật khẩu mới
                    try {
                        EmailUtil.sendResetPasswordEmail(target.getEmail(), target.getFullName(), newPassword);
                        response.sendRedirect(request.getContextPath() + "/admin/users?message=Password+reset+successfully.+New+password+sent+to+" + target.getEmail());
                    } catch (Exception emailEx) {
                        System.err.println("Lỗi gửi email reset password: " + emailEx.getMessage());
                        // Vẫn reset thành công nhưng email lỗi
                        response.sendRedirect(request.getContextPath() + "/admin/users?message=Password+reset+OK+but+email+failed.+New+password:+" + newPassword);
                    }
                    return;
                } else {
                    response.sendRedirect(request.getContextPath() + "/admin/users?error=Failed+to+reset+password");
                    return;
                }
            } catch (NumberFormatException e) {
                response.sendRedirect(request.getContextPath() + "/admin/users?error=Invalid+user+ID");
                return;
            }
        }
        doGet(request, response);
    }

    /**
     * Tạo mật khẩu ngẫu nhiên gồm chữ hoa, chữ thường, số và ký tự đặc biệt
     */
    private String generateRandomPassword(int length) {
        String upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        String lower = "abcdefghijklmnopqrstuvwxyz";
        String digits = "0123456789";
        String special = "@#$%&!";
        String all = upper + lower + digits + special;

        StringBuilder sb = new StringBuilder();
        java.util.Random rng = new java.security.SecureRandom();

        // Đảm bảo ít nhất 1 ký tự từ mỗi nhóm
        sb.append(upper.charAt(rng.nextInt(upper.length())));
        sb.append(lower.charAt(rng.nextInt(lower.length())));
        sb.append(digits.charAt(rng.nextInt(digits.length())));
        sb.append(special.charAt(rng.nextInt(special.length())));

        for (int i = 4; i < length; i++) {
            sb.append(all.charAt(rng.nextInt(all.length())));
        }

        // Trộn ngẫu nhiên
        char[] chars = sb.toString().toCharArray();
        for (int i = chars.length - 1; i > 0; i--) {
            int j = rng.nextInt(i + 1);
            char tmp = chars[i];
            chars[i] = chars[j];
            chars[j] = tmp;
        }
        return new String(chars);
    }
}
