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
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");
        
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        if (currentUser.getRoleId() != 1) {
            response.sendRedirect(request.getContextPath() + "/employee/dashboard");
            return;
        }

        // Lấy thông số thống kê cho biểu đồ
        UserDAO userDAO = new UserDAO();
        int totalUsers = userDAO.getTotalUsers();
        int activeUsers = userDAO.getActiveUsers();
        int totalRoles = userDAO.getTotalRoles();
        
        int totalDepartments = 5; 
        int pendingLeaves = 12;

        request.setAttribute("totalUsers", totalUsers);
        request.setAttribute("activeUsers", activeUsers);
        request.setAttribute("totalRoles", totalRoles);
        request.setAttribute("totalDepartments", totalDepartments);
        request.setAttribute("pendingLeaves", pendingLeaves);

        request.getRequestDispatcher("/admin/dashboard.jsp").forward(request, response);
    } 

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        // Dashboard mới chỉ để hiển thị biểu đồ, không xử lý POST nữa.
        doGet(request, response);
    }
}

    }
}
