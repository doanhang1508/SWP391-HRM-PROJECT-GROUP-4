package controller.admin;

import java.io.IOException;
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
        // Redirect về unified dashboard
        response.sendRedirect(request.getContextPath() + "/dashboard");
    } 

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        // Dashboard mới chỉ để hiển thị biểu đồ, không xử lý POST nữa.
        doGet(request, response);
    }
}
