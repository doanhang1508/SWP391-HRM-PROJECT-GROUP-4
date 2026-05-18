/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller.admin;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import dao.UserDAO;
import dao.RoleDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpSession;
import model.User;

@WebServlet(name = "adminDashboardController", urlPatterns = {"/admin/dashboard"})
public class adminDashboardController extends HttpServlet {
   
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        
        // 1. Kiểm tra bảo mật: Phải đăng nhập và phải là Admin (role_id = 1)
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");
        
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        if (currentUser.getRoleId() != 1) {
            // Không phải Admin thì đẩy về trang dashboard nhân viên hoặc báo lỗi 403
            response.sendRedirect(request.getContextPath() + "/employee/dashboard");
            return;
        }

        // 2. Kéo dữ liệu thống kê thật từ Database thông qua DAO
        UserDAO userDAO = new UserDAO();
        int totalUsers = userDAO.getTotalUsers();
        int activeUsers = userDAO.getActiveUsers();
        int totalRoles = userDAO.getTotalRoles();
        
        // 2b. Lấy danh sách người dùng và vai trò để hiển thị trang quản trị hợp nhất
        java.util.List<model.User> users = userDAO.getAllUsers();
        RoleDAO roleDAO = new RoleDAO();
        java.util.List<model.Role> roles = roleDAO.getAllRoles();
        
        // Giả lập số phòng ban và số đơn nghỉ phép chờ duyệt (Chưa có bảng trong DB)
        int totalDepartments = 5; 
        int pendingLeaves = 12;

        // 3. Đẩy dữ liệu sang JSP
        request.setAttribute("totalUsers", totalUsers);
        request.setAttribute("activeUsers", activeUsers);
        request.setAttribute("totalRoles", totalRoles);
        request.setAttribute("users", users);
        request.setAttribute("roles", roles);
        request.setAttribute("totalDepartments", totalDepartments);
        request.setAttribute("pendingLeaves", pendingLeaves);

        // 4. Gọi giao diện Admin Dashboard
        request.getRequestDispatcher("/admin/dashboard.jsp").forward(request, response);
    } 

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        // Xử lý các thao tác quản trị trên user: toggle status, update role
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
                        response.sendRedirect(request.getContextPath() + "/admin/dashboard?message=User+status+updated");
                        return;
                    }
                }
            } catch (NumberFormatException e) {
                // ignore
            }
            response.sendRedirect(request.getContextPath() + "/admin/dashboard?error=Failed+to+update+status");
            return;
        } else if ("updateRole".equals(action)) {
            String userIdRaw = request.getParameter("userId");
            String roleIdRaw = request.getParameter("roleId");
            try {
                int userId = Integer.parseInt(userIdRaw);
                int roleId = Integer.parseInt(roleIdRaw);
                boolean ok = userDAO.updateUserRole(userId, roleId);
                if (ok) {
                    response.sendRedirect(request.getContextPath() + "/admin/dashboard?message=User+role+updated");
                    return;
                }
            } catch (NumberFormatException e) {
                // ignore
            }
            response.sendRedirect(request.getContextPath() + "/admin/dashboard?error=Failed+to+update+role");
            return;
        } else if ("addUser".equals(action)) {
            String password = request.getParameter("password");
            String fullName = request.getParameter("fullName");
            String email = request.getParameter("email");
            String phone = request.getParameter("phone");
            String roleIdRaw = request.getParameter("roleId");

            if (email == null || email.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/admin/dashboard?error=Email+is+required");
                return;
            }
            
            // Auto-generate username from email
            String username = email.contains("@") ? email.split("@")[0] : email;

            // Kiểm tra trùng lặp
            if (userDAO.isUserExists(username, email)) {
                response.sendRedirect(request.getContextPath() + "/admin/dashboard?error=Email+already+exists");
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
                newUser.setStatus(1); // Active default

                boolean ok = userDAO.addUser(newUser);
                if (ok) {
                    response.sendRedirect(request.getContextPath() + "/admin/dashboard?message=User+added+successfully");
                    return;
                } else {
                    response.sendRedirect(request.getContextPath() + "/admin/dashboard?error=Failed+to+add+user");
                    return;
                }
            } catch (NumberFormatException e) {
                response.sendRedirect(request.getContextPath() + "/admin/dashboard?error=Invalid+Role+ID");
                return;
            }
        }

        // Fallback: delegate to GET to re-render page
        doGet(request, response);
    }
}
