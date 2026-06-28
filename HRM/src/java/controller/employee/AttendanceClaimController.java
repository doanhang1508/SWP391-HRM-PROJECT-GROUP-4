package controller.employee;

import dao.AttendanceDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.AttendanceClaim;
import model.User;

import java.io.IOException;
import java.sql.Date;
import java.util.List;

/**
 * Controller: Nhân viên nộp và xem đơn khiếu nại chấm công.
 * URL: /employee/attendance-claim
 * Roles: tất cả nhân viên đã đăng nhập
 */
@WebServlet(name = "AttendanceClaimController", urlPatterns = {"/employee/attendance-claim"})
public class AttendanceClaimController extends HttpServlet {

    private final AttendanceDAO attendanceDAO = new AttendanceDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("currentUser");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        List<AttendanceClaim> myClaims = attendanceDAO.getClaimsByUser(user.getUserId());
        request.setAttribute("myClaims", myClaims);

        // Pre-fill ngày làm việc nếu click từ trang attendance
        String workDateParam = request.getParameter("workDate");
        if (workDateParam != null) {
            request.setAttribute("prefillWorkDate", workDateParam);
        }

        request.getRequestDispatcher("/employee/attendance-claim.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("currentUser");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");

        if ("submit".equals(action)) {
            try {
                String workDateStr = request.getParameter("workDate");
                String claimType = request.getParameter("claimType");
                String description = request.getParameter("description");

                // Validate
                if (description == null || description.trim().length() < 10) {
                    session.setAttribute("errorMessage", "Mô tả khiếu nại phải có ít nhất 10 ký tự.");
                    response.sendRedirect(request.getContextPath() + "/employee/attendance-claim");
                    return;
                }
                if (description.trim().length() > 500) {
                    session.setAttribute("errorMessage", "Mô tả không được vượt quá 500 ký tự.");
                    response.sendRedirect(request.getContextPath() + "/employee/attendance-claim");
                    return;
                }

                // Tra cứu attendance_id từ userId (session) + ngày làm việc
                Date workDate = Date.valueOf(workDateStr);
                int attendanceId = attendanceDAO.getAttendanceIdByUserIdAndDate(user.getUserId(), workDate);
                if (attendanceId == -1) {
                    String empCode = String.format("NV%04d", user.getUserId());
                    session.setAttribute("errorMessage",
                        "Không tìm thấy bản ghi chấm công cho mã nhân viên " + empCode +
                        " vào ngày " + workDateStr + ". Vui lòng kiểm tra lại ngày làm việc.");
                    response.sendRedirect(request.getContextPath() + "/employee/attendance-claim");
                    return;
                }

                // Check duplicate pending claim
                if (attendanceDAO.hasPendingClaim(attendanceId)) {
                    session.setAttribute("errorMessage",
                        "Đã có đơn khiếu nại đang chờ xử lý cho ngày công này. " +
                        "Vui lòng chờ HR giải quyết trước.");
                    response.sendRedirect(request.getContextPath() + "/employee/attendance-claim");
                    return;
                }

                AttendanceClaim claim = new AttendanceClaim();
                claim.setAttendanceId(attendanceId);
                claim.setUserId(user.getUserId());
                claim.setWorkDate(workDate);
                claim.setClaimType(claimType);
                claim.setDescription(description.trim());

                if (attendanceDAO.submitClaim(claim)) {
                    session.setAttribute("successMessage",
                        "Đơn khiếu nại đã được gửi thành công. HR sẽ xem xét trong thời gian sớm nhất.");
                } else {
                    session.setAttribute("errorMessage", "Gửi đơn thất bại. Vui lòng thử lại.");
                }

            } catch (Exception e) {
                session.setAttribute("errorMessage", "Lỗi xử lý: " + e.getMessage());
            }

            response.sendRedirect(request.getContextPath() + "/employee/attendance-claim");
        } else {
            response.sendRedirect(request.getContextPath() + "/employee/attendance-claim");
        }
    }
}
