package controller;

import model.User;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Controller xử lý trang Lịch sử công tác
 * URL: /work-history (GET)
 * @author Thanh Hang
 */
@WebServlet(name = "workHistoryController", urlPatterns = {"/work-history"})
public class WorkHistoryController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        dao.WorkHistoryDAO workHistoryDAO = new dao.WorkHistoryDAO();
        java.util.List<model.WorkHistory> history = workHistoryDAO.getByUserId(currentUser.getUserId());
        request.setAttribute("workHistory", history);

        request.getRequestDispatcher("work-history.jsp").forward(request, response);
    }
}
