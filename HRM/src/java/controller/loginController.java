/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.UserDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import util.CookieUtil;
import util.PasswordUtil;

/**
 *
 * @author Thanh Hang
 */
public class loginController extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet loginController</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet loginController at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }
    private final UserDAO userDAO = new UserDAO();

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String userEmailCookie = CookieUtil.getCookieValue(request, CookieUtil.REMEMBER_EMAIL_COOKIE);
        if (userEmailCookie != null && !userEmailCookie.isEmpty()) {
            request.setAttribute("email", userEmailCookie);
            request.setAttribute("rememberChecked", "checked");
        }

        String error = request.getParameter("error");
        if ("pending".equals(error)) {
            request.setAttribute("errorMsg", "Tài khoản của bạn đang chờ phê duyệt. Vui lòng liên hệ bộ phận HCNS.");
        }

        request.getRequestDispatcher("login.jsp").forward(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        //processRequest(request, response);
        String email = request.getParameter("email");    // đổi từ "username"
        String password = request.getParameter("password");

        if (email == null || email.isBlank()
                || password == null || password.isBlank()) {
            request.setAttribute("errorMsg", "Vui lòng nhập đầy đủ email và mật khẩu.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        User user = userDAO.findByEmailAndPassword(email.trim(), password);

        if (user == null) {
            // Sai tài khoản / mật khẩu
            request.setAttribute("errorMsg", "Tên đăng nhập hoặc mật khẩu không đúng.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        if (user.getStatus() == 0) {
            // Tài khoản bị khóa hoặc đang chờ duyệt
            request.setAttribute("errorMsg", "Tài khoản của bạn đang bị khóa hoặc chưa được phê duyệt. Vui lòng liên hệ bộ phận HCNS.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }
        
        if (user.getRoleId() != 1) { // Không phải Admin
            dao.EmployeeProfileDAO epDAO = new dao.EmployeeProfileDAO();
            model.EmployeeProfile profile = epDAO.getByUserId(user.getUserId());
            if (profile != null && profile.getEmploymentStatusId() == 4) { // 4 = Đã nghỉ việc
                request.setAttribute("errorMsg", "Tài khoản của bạn đã bị vô hiệu hóa do đã nghỉ việc hoặc hết hạn hợp đồng.");
                request.getRequestDispatcher("login.jsp").forward(request, response);
                return;
            }
        }

        // --- Tạo session ---
        HttpSession session = request.getSession(true);
        session.setAttribute("currentUser", user);
        session.setMaxInactiveInterval(60 * 60 * 8); // 8 tiếng

        String remember = request.getParameter("remember");
       
        boolean isSecure = request.isSecure();
        if (remember != null) {
            // Nếu có tích "Ghi nhớ": Thời gian sống 30 ngày (30 * 24 * 60 * 60 giây)
            util.CookieUtil.addSecureCookie(response, util.CookieUtil.REMEMBER_EMAIL_COOKIE, email.trim(), 2592000, isSecure);
        } else {
            // Nếu KHÔNG tích: Gọi hàm deleteCookie để xóa nó đi
            util.CookieUtil.deleteCookie(response, util.CookieUtil.REMEMBER_EMAIL_COOKIE, isSecure);
        }

        // --- Flash message hiện toast Góc dưới màn hình ---
        String displayName = (user.getFullName() != null && !user.getFullName().isBlank())
                ? user.getFullName() : user.getEmail();
        session.setAttribute("toastSuccess", "Đăng nhập thành công! Chào mừng, " + displayName + ".");

        String redirect;
        int roleId = user.getRoleId();
        if (roleId == 1) {
            redirect = "/admin/dashboard";
        } else if (roleId == 2 || roleId == 5) {
            redirect = "/hr/dashboard";
        } else if (roleId == 3 || roleId == 6) {
            redirect = "/manager/dashboard";
        } else if (roleId == 4) {
            redirect = "/director/dashboard";
        } else {
            redirect = "/employee/dashboard";
        }
        response.sendRedirect(request.getContextPath() + redirect);
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>



}
