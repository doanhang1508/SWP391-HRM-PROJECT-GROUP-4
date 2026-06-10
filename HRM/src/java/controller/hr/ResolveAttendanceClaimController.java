package controller.hr;

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
import java.sql.Time;
import java.util.List;

/**
 * Controller: HR xem và giải quyết đơn khiếu nại chấm công.
 * URL: /hr/attendance-claims
 * Roles: HR (2), Admin (1)
 */
@WebServlet(name = "ResolveAttendanceClaimController", urlPatterns = {"/hr/attendance-claims"})
public class  extends HttpServlet {

    private final AttendanceDAO attendanceDAO = new AttendanceDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("currentUser");

        if (user == null || (user.getRoleId() != 1 && user.getRoleId() != 2)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String statusFilter = request.getParameter("status");
        if (statusFilter == null) statusFilter = "PENDING"; // default show pending

        List<AttendanceClaim> claims = attendanceDAO.getAllClaims(statusFilter);
        request.setAttribute("claims", claims);
        request.setAttribute("statusFilter", statusFilter);

        // Count by status for tabs
        request.setAttribute("pendingClaims", attendanceDAO.getAllClaims("PENDING"));
        request.getRequestDispatcher("/hr/attendance-claims.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // ★ Bắt buộc set encoding trước khi đọc bất kỳ parameter nào
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("currentUser");

        if (user == null || (user.getRoleId() != 1 && user.getRoleId() != 2)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");

        if ("resolve".equals(action)) {
            try {
                int claimId = Integer.parseInt(request.getParameter("claimId"));
                String decision = request.getParameter("decision"); // APPROVED or REJECTED
                String hrNote  = request.getParameter("hrNote");
                String newStatus = request.getParameter("newAttendanceStatus"); // e.g. "PRESENT"

                // Đọc giờ sửa (tùy chọn, chỉ áp dụng khi APPROVED)
                String checkInStr  = request.getParameter("correctedCheckIn");   // "HH:mm"
                String checkOutStr = request.getParameter("correctedCheckOut");  // "HH:mm"

                if (!"APPROVED".equals(decision) && !"REJECTED".equals(decision)) {
                    session.setAttribute("errorMessage", "Quyết định không hợp lệ.");
                    response.sendRedirect(request.getContextPath() + "/hr/attendance-claims?status=PENDING");
                    return;
                }

                if (hrNote == null || hrNote.trim().isEmpty()) {
                    session.setAttribute("errorMessage", "Vui lòng nhập ghi chú khi giải quyết đơn.");
                    response.sendRedirect(request.getContextPath() + "/hr/attendance-claims?status=PENDING");
                    return;
                }

                // Chuyển chuỗi giờ "HH:mm" sang java.sql.Time (nếu có)
                Time correctedCheckIn  = null;
                Time correctedCheckOut = null;
                if ("APPROVED".equals(decision)) {
                    if (checkInStr != null && !checkInStr.trim().isEmpty()) {
                        try { correctedCheckIn  = Time.valueOf(checkInStr.trim()  + ":00"); } catch (Exception ignored) {}
                    }
                    if (checkOutStr != null && !checkOutStr.trim().isEmpty()) {
                        try { correctedCheckOut = Time.valueOf(checkOutStr.trim() + ":00"); } catch (Exception ignored) {}
                    }
                }

                boolean ok = attendanceDAO.resolveClaim(
                    claimId, decision, hrNote.trim(), user.getUserId(),
                    "APPROVED".equals(decision) ? newStatus : null,
                    correctedCheckIn,
                    correctedCheckOut
                );

                if (ok) {
                    String msg = "APPROVED".equals(decision)
                        ? "Đã duyệt đơn khiếu nại và cập nhật trạng thái chấm công."
                        : "Đã từ chối đơn khiếu nại.";
                    session.setAttribute("successMessage", msg);
                } else {
                    session.setAttribute("errorMessage", "Xử lý thất bại. Đơn có thể đã được giải quyết hoặc không tồn tại.");
                }

            } catch (NumberFormatException e) {
                session.setAttribute("errorMessage", "Mã đơn khiếu nại không hợp lệ.");
            } catch (Exception e) {
                session.setAttribute("errorMessage", "Lỗi xử lý: " + e.getMessage());
                e.printStackTrace();
            }

            response.sendRedirect(request.getContextPath() + "/hr/attendance-claims?status=PENDING");
        } else {
            response.sendRedirect(request.getContextPath() + "/hr/attendance-claims?status=PENDING");
        }
    }
}
