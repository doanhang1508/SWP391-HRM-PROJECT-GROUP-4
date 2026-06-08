package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.User;

@WebServlet(name = "GeneralDashboardController", urlPatterns = {"/dashboard"})
public class DashboardController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("currentUser");
        int roleId = user.getRoleId();
        String redirectUrl = "";

        switch (roleId) {
            case 1:
                redirectUrl = "/admin/dashboard";
                break;
            case 2:
            case 5:
                redirectUrl = "/hr/dashboard";
                break;
            case 3:
            case 6:
                redirectUrl = "/manager/dashboard";
                break;
            case 4:
                redirectUrl = "/director/dashboard";
                break;
            default:
                redirectUrl = "/employee/dashboard";
                break;
        }

        response.sendRedirect(request.getContextPath() + redirectUrl);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
