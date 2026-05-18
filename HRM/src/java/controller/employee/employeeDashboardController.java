package controller.employee;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "EmployeeDashboardController", urlPatterns = {"/employee/dashboard"})
public class employeeDashboardController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        // Kiểm tra xem người dùng đã đăng nhập chưa
        jakarta.servlet.http.HttpSession session = request.getSession();
        if (session.getAttribute("currentUser") == null) {
            // Chưa đăng nhập -> Chuyển hướng về trang Đăng nhập
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        // Đã đăng nhập -> Hiển thị Dashboard tùy theo vai trò
        model.User currentUser = (model.User) session.getAttribute("currentUser");
        
        if (currentUser.getRoleId() == 1) { // 1 là Admin
            response.sendRedirect(request.getContextPath() + "/admin/dashboard");
        } else { // 2 là Manager, 3 là Employee
            request.getRequestDispatcher("/employee/dashboard.jsp").forward(request, response);
        }
    } 

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        doGet(request, response);
    }
}
