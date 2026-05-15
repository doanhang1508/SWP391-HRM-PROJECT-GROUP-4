package controller;

import dao.UserDAO;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.User;

@WebServlet("/user-list")
public class UserListServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
        HttpServletResponse response)
        throws ServletException, IOException {

    System.out.println("UserListServlet Running");

    UserDAO dao = new UserDAO();

    List<User> list = dao.getAllUsers();

    request.setAttribute("userList", list);

    request.getRequestDispatcher("/user-list.jsp")
            .forward(request, response);
}
}
