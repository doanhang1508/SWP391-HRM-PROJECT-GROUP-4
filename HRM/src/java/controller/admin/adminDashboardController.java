/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller.admin;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import dao.UserDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpSession;
import model.User;

@WebServlet(name = "adminDashboardController", urlPatterns = {"/admin/dashboard"})
public class adminDashboardController extends HttpServlet {
   
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        
        // 1. Kiểm tra bảo mật: Phải đăng nhập và phải là Admin (role_id = 1)
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");
        
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        if (currentUser.getRoleId() != 1) {
            // Không phải Admin thì đẩy về trang dashboard nhân viên hoặc báo lỗi 403
            response.sendRedirect(request.getContextPath() + "/employee/dashboard");
            return;
        }

        // 2. Kéo dữ liệu thống kê thật từ Database thông qua DAO
        UserDAO userDAO = new UserDAO();
        int totalUsers = userDAO.getTotalUsers();
        int activeUsers = userDAO.getActiveUsers();
        int totalRoles = userDAO.getTotalRoles();
        
        // Giả lập số phòng ban và số đơn nghỉ phép chờ duyệt (Chưa có bảng trong DB)
        int totalDepartments = 5; 
        int pendingLeaves = 12;

        // 3. Đẩy dữ liệu sang JSP
        request.setAttribute("totalUsers", totalUsers);
        request.setAttribute("activeUsers", activeUsers);
        request.setAttribute("totalRoles", totalRoles);
        request.setAttribute("totalDepartments", totalDepartments);
        request.setAttribute("pendingLeaves", pendingLeaves);

        // 4. Gọi giao diện Admin Dashboard
        request.getRequestDispatcher("/admin/dashboard.jsp").forward(request, response);
    } 

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        doGet(request, response);
    }
}
