package controller;

import dao.UserDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.User;

@WebServlet("/add-user")
public class AddUserServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String role = request.getParameter("role");
        String department = request.getParameter("department");
        User u = new User();

        u.setFullName(fullName);
        u.setEmail(email);
        u.setPassword(password);
        u.setRole(role);
        u.setStatus(true);
        u.setDepartment(department);
        UserDAO dao = new UserDAO();

        dao.insertUser(u);

        response.sendRedirect("user-list");
    }

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.getRequestDispatcher("/add-user.jsp")
                .forward(request, response);
    }
}
