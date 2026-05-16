package controller;

import dao.UserDAO;
import model.User;
import util.PasswordUtil;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Controller xử lý chức năng Đổi mật khẩu (Task 6)
 * URL: /change-password (POST)
 * @author Thanh Hang
 */
public class changePasswordController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        // 1. Bảo mật: Chưa đăng nhập thì không được đổi mật khẩu
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String oldPassword     = request.getParameter("oldPassword");
        String newPassword     = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        // 2. Kiểm tra mật khẩu cũ có đúng không (hỗ trợ cả plain-text lẫn BCrypt)
        if (!PasswordUtil.checkPassword(oldPassword, currentUser.getPasswordHash())) {
            request.setAttribute("msgError", "Mật khẩu cũ không chính xác!");
            request.getRequestDispatcher("profile.jsp").forward(request, response);
            return;
        }

        // 3. Kiểm tra 2 ô mật khẩu mới có khớp nhau không
        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("msgError", "Xác nhận mật khẩu mới không khớp!");
            request.getRequestDispatcher("profile.jsp").forward(request, response);
            return;
        }

        // 4. Kiểm tra độ dài tối thiểu
        if (newPassword.length() < 6) {
            request.setAttribute("msgError", "Mật khẩu mới phải có ít nhất 6 ký tự!");
            request.getRequestDispatcher("profile.jsp").forward(request, response);
            return;
        }

        // 5. Mã hóa BCrypt và lưu xuống Database
        String hashedNewPassword = PasswordUtil.hashPassword(newPassword);
        UserDAO userDAO = new UserDAO();

        if (userDAO.updatePassword(currentUser.getUserId(), hashedNewPassword)) {
            // Cập nhật lại Session để lần đổi mật khẩu tiếp theo vẫn đúng
            currentUser.setPassword(hashedNewPassword);
            session.setAttribute("currentUser", currentUser);
            request.setAttribute("msgSuccess", "Đổi mật khẩu thành công! Hãy nhớ mật khẩu mới của bạn.");
        } else {
            request.setAttribute("msgError", "Có lỗi xảy ra khi lưu mật khẩu. Vui lòng thử lại!");
        }

        request.getRequestDispatcher("profile.jsp").forward(request, response);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Truy cập GET thì chuyển về trang hồ sơ
        response.sendRedirect(request.getContextPath() + "/profile");
    }
}

