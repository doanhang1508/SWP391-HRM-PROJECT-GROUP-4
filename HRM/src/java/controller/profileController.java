package controller;

import dao.UserDAO;
import model.User;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "profileController", urlPatterns = {"/profile"})
public class profileController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");
        
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Admin có thể xem profile của user khác bằng ?userId=...
        String userIdParam = request.getParameter("userId");
        if (userIdParam != null && currentUser.getRoleId() == 1) {
            try {
                int targetUserId = Integer.parseInt(userIdParam);
                UserDAO userDAO = new UserDAO();
                User targetUser = userDAO.getUserById(targetUserId);
                if (targetUser != null) {
                    request.setAttribute("viewUser", targetUser);
                }
            } catch (NumberFormatException e) {
                // ignore
            }
        }

        request.getRequestDispatcher("profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");
        
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        UserDAO userDAO = new UserDAO();

        if ("update_profile".equals(action)) {
            String fullName = request.getParameter("fullName");
            String phone = request.getParameter("phone");
            String targetUserIdParam = request.getParameter("targetUserId");

            // Detect: admin editing another user, or user editing their own
            int editUserId = currentUser.getUserId();
            if (targetUserIdParam != null && currentUser.getRoleId() == 1) {
                try {
                    editUserId = Integer.parseInt(targetUserIdParam);
                } catch (NumberFormatException e) { /* ignore */ }
            }

            if (userDAO.updateProfile(editUserId, fullName, phone)) {
                if (editUserId == currentUser.getUserId()) {
                    // Update session if editing own profile
                    currentUser.setFullName(fullName);
                    currentUser.setPhone(phone);
                    session.setAttribute("currentUser", currentUser);
                }
                request.setAttribute("msgSuccess", "Cập nhật thông tin thành công!");
            } else {
                request.setAttribute("msgError", "Lỗi cập nhật thông tin!");
            }

            // Reload user data for admin viewing others
            if (editUserId != currentUser.getUserId()) {
                User reloaded = userDAO.getUserById(editUserId);
                request.setAttribute("viewUser", reloaded);
            }
        }

        // Chuyển hướng lại trang profile cùng với thông báo
        request.getRequestDispatcher("profile.jsp").forward(request, response);
    }
}
