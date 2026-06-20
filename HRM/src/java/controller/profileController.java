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

        String targetUserIdParam = request.getParameter("userId");
        User targetUser = currentUser;
        boolean isOwnProfile = true;

        if (targetUserIdParam != null && !targetUserIdParam.isEmpty()) {
            try {
                int targetUserId = Integer.parseInt(targetUserIdParam);
                if (targetUserId != currentUser.getUserId()) {
                    UserDAO userDAO = new UserDAO();
                    User u = userDAO.getUserById(targetUserId);
                    if (u != null) {
                        targetUser = u;
                        isOwnProfile = false;
                    }
                }
            } catch (NumberFormatException e) {
                // Ignore
            }
        }

        request.setAttribute("profileUser", targetUser);
        request.setAttribute("isOwnProfile", isOwnProfile);

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

            if (userDAO.updateProfile(currentUser.getUserId(), fullName, phone)) {
                currentUser.setFullName(fullName);
                currentUser.setPhone(phone);
                session.setAttribute("currentUser", currentUser);
                
                request.setAttribute("msgSuccess", "Cập nhật thông tin thành công!");
            } else {
                request.setAttribute("msgError", "Lỗi cập nhật thông tin!");
            }
        }

        // Cập nhật xong lấy lại thông tin user để hiển thị
        request.setAttribute("profileUser", currentUser);
        request.setAttribute("isOwnProfile", true);
        
        // Chuyển hướng lại trang profile cùng với thông báo
        request.getRequestDispatcher("profile.jsp").forward(request, response);
    }
}
