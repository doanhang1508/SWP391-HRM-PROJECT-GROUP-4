package controller.admin;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import model.User;

@WebServlet(name="AdminProfileController", urlPatterns={"/admin/profile"})
public class AdminProfileController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        if(currentUser == null){
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String userIdRaw = request.getParameter("userId");

        UserDAO userDAO = new UserDAO();

        User user;

        // admin xem user khác
        if(userIdRaw != null){
            int userId = Integer.parseInt(userIdRaw);
            user = userDAO.getUserById(userId);
        } else {
            // xem chính mình
            user = currentUser;
        }

        request.setAttribute("user", user);

        request.getRequestDispatcher("/admin/profile.jsp")
                .forward(request, response);
    }
    
    @Override
protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

    request.setCharacterEncoding("UTF-8");

    String userIdRaw = request.getParameter("userId");
    String fullName = request.getParameter("fullName");
    String phone = request.getParameter("phone");

    try {

        int userId = Integer.parseInt(userIdRaw);

        UserDAO userDAO = new UserDAO();

        boolean updated = userDAO.updateProfile(userId, fullName, phone);

        if(updated){
            response.sendRedirect(
                request.getContextPath()
                + "/admin/profile?userId="
                + userId
                + "&message=updated"
            );
        } else {
            response.sendRedirect(
                request.getContextPath()
                + "/admin/profile?userId="
                + userId
                + "&error=failed"
            );
        }

    } catch(Exception e){
        e.printStackTrace();

        response.sendRedirect(
            request.getContextPath()
            + "/admin/dashboard"
        );
    }
}
}
