package controller.hr;

import dao.AttendanceDAO;
import dao.UserDAO;
import model.Attendance;
import model.AttendanceSummary;
import model.User;

import java.io.IOException;
import java.sql.Time;
import java.time.LocalDate;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "HrAttendanceController", urlPatterns = {"/hr/attendance-management"})
public class HrAttendanceController extends HttpServlet {

    private AttendanceDAO attendanceDAO;
    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        attendanceDAO = new AttendanceDAO();
        userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser.getRoleId() != 2 && currentUser.getRoleId() != 5) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập trang này.");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            action = "summary";
        }

        // Get month and year parameter or default to current
        String monthStr = request.getParameter("month");
        String yearStr = request.getParameter("year");
        
        LocalDate now = LocalDate.now();
        int month = (monthStr != null && !monthStr.isEmpty()) ? Integer.parseInt(monthStr) : now.getMonthValue();
        int year = (yearStr != null && !yearStr.isEmpty()) ? Integer.parseInt(yearStr) : now.getYear();

        request.setAttribute("selectedMonth", month);
        request.setAttribute("selectedYear", year);

        switch (action) {
            case "summary":
                viewSummary(request, response, month, year);
                break;
            case "detail":
                viewDetail(request, response, month, year);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/hr/attendance-management?action=summary");
                break;
        }
    }

    private void viewSummary(HttpServletRequest request, HttpServletResponse response, int month, int year)
            throws ServletException, IOException {
        int page = 1;
        int pageSize = 15;
        String pageStr = request.getParameter("page");
        if (pageStr != null && !pageStr.trim().isEmpty()) {
            try { page = Integer.parseInt(pageStr); } catch (Exception e) {}
        }
        
        int totalRecords = attendanceDAO.countAttendanceSummaryAllUsers(month, year);
        int totalPages = (int) Math.ceil((double) totalRecords / pageSize);
        if (page > totalPages && totalPages > 0) page = totalPages;
        int offset = (page - 1) * pageSize;
        if (offset < 0) offset = 0;

        List<AttendanceSummary> summaryList = attendanceDAO.getAttendanceSummaryAllUsersPaginated(month, year, offset, pageSize);
        
        request.setAttribute("summaryList", summaryList);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRecords", totalRecords);
        
        request.getRequestDispatcher("/hr/attendance-summary.jsp").forward(request, response);
    }

    private void viewDetail(HttpServletRequest request, HttpServletResponse response, int month, int year)
            throws ServletException, IOException {
        String userName = request.getParameter("userName");
        String workDateStr = request.getParameter("workDate");
        java.sql.Date workDate = null;
        if (workDateStr != null && !workDateStr.trim().isEmpty()) {
            try {
                workDate = java.sql.Date.valueOf(workDateStr);
            } catch (Exception e) {}
        }
        
        if (userName != null) {
            userName = userName.trim();
        }

        request.setAttribute("selectedUserName", userName);
        request.setAttribute("selectedWorkDate", workDateStr);

        int page = 1;
        int pageSize = 15;
        String pageStr = request.getParameter("page");
        if (pageStr != null && !pageStr.trim().isEmpty()) {
            try { page = Integer.parseInt(pageStr); } catch (Exception e) {}
        }
        
        int totalRecords = attendanceDAO.countAllAttendance(month, year, userName, workDate);
        int totalPages = (int) Math.ceil((double) totalRecords / pageSize);
        if (page > totalPages && totalPages > 0) page = totalPages;
        int offset = (page - 1) * pageSize;
        if (offset < 0) offset = 0;

        List<Attendance> detailList = attendanceDAO.getAllAttendancePaginated(month, year, userName, workDate, offset, pageSize);
        
        request.setAttribute("detailList", detailList);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRecords", totalRecords);
        
        request.getRequestDispatcher("/hr/attendance-detail.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser.getRoleId() != 2 && currentUser.getRoleId() != 5) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền thực hiện hành động này.");
            return;
        }

        String action = request.getParameter("action");
        if ("update".equals(action)) {
            try {
                int attendanceId = Integer.parseInt(request.getParameter("attendanceId"));
                int month = Integer.parseInt(request.getParameter("month"));
                int year = Integer.parseInt(request.getParameter("year"));
                String userName = request.getParameter("userName");
                String workDateStr = request.getParameter("workDate");
                String checkInStr = request.getParameter("checkIn");
                String checkOutStr = request.getParameter("checkOut");
                String status = request.getParameter("status");

                // Check if attendance is locked
                if (attendanceDAO.isAttendanceLocked(attendanceId)) {
                    session.setAttribute("errorMsg", "Không thể sửa dữ liệu chấm công vì bảng công đã được duyệt cuối/khóa!");
                } else {
                    Time checkIn = (checkInStr != null && !checkInStr.trim().isEmpty()) ? Time.valueOf(checkInStr.length() == 5 ? checkInStr + ":00" : checkInStr) : null;
                    Time checkOut = (checkOutStr != null && !checkOutStr.trim().isEmpty()) ? Time.valueOf(checkOutStr.length() == 5 ? checkOutStr + ":00" : checkOutStr) : null;

                    boolean success = attendanceDAO.updateAttendanceHR(attendanceId, checkIn, checkOut, status);
                    if (success) {
                        session.setAttribute("successMsg", "Cập nhật chấm công thành công.");
                    } else {
                        session.setAttribute("errorMsg", "Cập nhật thất bại. Vui lòng thử lại.");
                    }
                }
                
                String redirectUrl = request.getContextPath() + "/hr/attendance-management?action=detail&month=" + month + "&year=" + year;
                if (userName != null && !userName.trim().isEmpty()) {
                    redirectUrl += "&userName=" + java.net.URLEncoder.encode(userName.trim(), "UTF-8");
                }
                if (workDateStr != null && !workDateStr.trim().isEmpty()) {
                    redirectUrl += "&workDate=" + workDateStr;
                }
                response.sendRedirect(redirectUrl);
            } catch (Exception e) {
                e.printStackTrace();
                session.setAttribute("errorMsg", "Dữ liệu không hợp lệ: " + e.getMessage());
                response.sendRedirect(request.getContextPath() + "/hr/attendance-management?action=detail");
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/hr/attendance-management?action=summary");
        }
    }
}
