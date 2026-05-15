package controller;

import dao.UserDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.User;

@WebServlet("/user-detail/*́")
public class UserDetailServlet extends HttpServlet {

    @Override
protected void doGet(HttpServletRequest request,
        HttpServletResponse response)
        throws ServletException, IOException {

    String pathInfo = request.getPathInfo();

    if(pathInfo == null || pathInfo.equals("/")){

        response.getWriter().println("ID is missing!");
        return;
    }

    int id = Integer.parseInt(pathInfo.substring(1));

    UserDAO dao = new UserDAO();

    User u = dao.getUserById(id);

    if(u == null){

        response.getWriter().println("User not found!");
        return;
    }

    request.setAttribute("user", u);

    request.getRequestDispatcher("/user-detail.jsp")
            .forward(request, response);
}
}
