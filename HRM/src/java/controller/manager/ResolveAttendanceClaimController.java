package controller.manager;

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
 * Controller: Quản đốc / Trưởng phòng xem và giải quyết đơn khiếu nại chấm công.
 * URL: /manager/attendance-claims
 * Roles: Admin (1), HR Manager (2), Factory Manager (3), Dept Manager (6)
 */
@WebServlet(name = "ResolveAttendanceClaimController", urlPatterns = {"/manager/attendance-claims"})
public class ResolveAttendanceClaimController extends HttpServlet {

    private final AttendanceDAO attendanceDAO = new AttendanceDAO();

    private boolean checkAccess(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("currentUser");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return false;
        }
        // Admin (1), HR Manager (2), Quản đốc (3), Trưởng phòng (6)
        int roleId = user.getRoleId();
        if (roleId != 1 && roleId != 2 && roleId != 3 && roleId != 6) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return false;
        }
        return true;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!checkAccess(request, response)) return;

        String statusFilter = request.getParameter("status");
        if (statusFilter == null) statusFilter = "PENDING";

        List<AttendanceClaim> claims = attendanceDAO.getAllClaims(statusFilter);
        request.setAttribute("claims", claims);
        request.setAttribute("statusFilter", statusFilter);
        request.setAttribute("pendingClaims", attendanceDAO.getAllClaims("PENDING"));

        request.getRequestDispatcher("/manager/attendance-claims.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        if (!checkAccess(request, response)) return;

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("currentUser");
        String action = request.getParameter("action");

        if ("resolve".equals(action)) {
            try {
                int claimId = Integer.parseInt(request.getParameter("claimId"));
                String decision = request.getParameter("decision"); // APPROVED or REJECTED
                String hrNote   = request.getParameter("hrNote");
                String newStatus = request.getParameter("newAttendanceStatus");

                String checkInStr  = request.getParameter("correctedCheckIn");
                String checkOutStr = request.getParameter("correctedCheckOut");

                if (!"APPROVED".equals(decision) && !"REJECTED".equals(decision)) {
                    session.setAttribute("errorMessage", "Quyết định không hợp lệ.");
                    response.sendRedirect(request.getContextPath() + "/manager/attendance-claims?status=PENDING");
                    return;
                }

                if (hrNote == null || hrNote.trim().isEmpty()) {
                    session.setAttribute("errorMessage", "Vui lòng nhập ghi chú khi giải quyết đơn.");
                    response.sendRedirect(request.getContextPath() + "/manager/attendance-claims?status=PENDING");
                    return;
                }

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
        }

        response.sendRedirect(request.getContextPath() + "/manager/attendance-claims?status=PENDING");
    }
}
