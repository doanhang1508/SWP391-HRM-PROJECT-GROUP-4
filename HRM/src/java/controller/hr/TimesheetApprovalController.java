package controller.hr;

import dao.TimesheetConfirmationDAO;
import dao.AuditLogDAO;
import dao.AttendanceDAO;
import model.TimesheetConfirmation;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "TimesheetApprovalController", urlPatterns = {"/hr/timesheet-approval"})
public class TimesheetApprovalController extends HttpServlet {

    private final TimesheetConfirmationDAO tcDAO = new TimesheetConfirmationDAO();
    private final AuditLogDAO auditDAO = new AuditLogDAO();
    private final AttendanceDAO attendanceDAO = new AttendanceDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");
        int roleId = currentUser.getRoleId();

        // Allow Admin (1), HR Manager (2)
        if (roleId != 1 && roleId != 2) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập chức năng này.");
            return;
        }

        String monthStr = request.getParameter("month");
        String yearStr = request.getParameter("year");

        LocalDate now = LocalDate.now();
        int month = (monthStr != null && !monthStr.isEmpty()) ? Integer.parseInt(monthStr) : now.getMonthValue();
        int year = (yearStr != null && !yearStr.isEmpty()) ? Integer.parseInt(yearStr) : now.getYear();

        request.setAttribute("selectedMonth", month);
        request.setAttribute("selectedYear", year);

        boolean isMonthLocked = attendanceDAO.isMonthLocked(month, year);
        int recordCount = attendanceDAO.countAttendanceInMonth(month, year);
        request.setAttribute("isMonthLocked", isMonthLocked);
        request.setAttribute("recordCount", recordCount);

        List<TimesheetConfirmation> allConfirmations = tcDAO.getConfirmationsByPeriod(month, year);
        List<TimesheetConfirmation> pendingConfirmations = new ArrayList<>();
        
        for (TimesheetConfirmation c : allConfirmations) {
            // Show confirmations that are DEPARTMENT_CONFIRMED or SENT_TO_HR_MANAGER, or already processed (approved/rejected) to view history
            if ("DEPARTMENT_CONFIRMED".equals(c.getStatus()) 
                    || "SENT_TO_HR_MANAGER".equals(c.getStatus())
                    || "HR_MANAGER_APPROVED".equals(c.getStatus())
                    || "HR_MANAGER_REJECTED".equals(c.getStatus())) {
                pendingConfirmations.add(c);
            }
        }

        request.setAttribute("confirmations", pendingConfirmations);
        boolean allDeptsConfirmed = tcDAO.areAllActiveDepartmentsConfirmed(month, year);
        request.setAttribute("allDeptsConfirmed", allDeptsConfirmed);
        request.getRequestDispatcher("/hr/timesheet-approval.jsp").forward(request, response);
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
        int roleId = currentUser.getRoleId();
        String ipAddress = request.getRemoteAddr();

        String action = request.getParameter("action");
        String monthStr = request.getParameter("month");
        String yearStr = request.getParameter("year");
        
        int month = (monthStr != null && !monthStr.isEmpty()) ? Integer.parseInt(monthStr) : LocalDate.now().getMonthValue();
        int year = (yearStr != null && !yearStr.isEmpty()) ? Integer.parseInt(yearStr) : LocalDate.now().getYear();

        String idStr = request.getParameter("id");

        if ("lockMonth".equals(action)) {
            if (roleId != 2) {
                session.setAttribute("errorMessage", "Chỉ HR Manager mới có quyền khóa bảng công.");
            } else {
                String note = request.getParameter("note");
                int recordCount = attendanceDAO.countAttendanceInMonth(month, year);
                if (recordCount == 0) {
                    session.setAttribute("errorMessage", "Không có dữ liệu chấm công cho tháng " + month + "/" + year + ". Không thể khóa.");
                } else {
                    if (attendanceDAO.lockMonth(month, year, currentUser.getUserId(), note)) {
                        session.setAttribute("successMessage", "Đã KHÓA (DUYỆT CUỐI) dữ liệu chấm công tháng " + month + "/" + year + ".");
                    } else {
                        session.setAttribute("errorMessage", "Khóa thất bại.");
                    }
                }
            }
        } else if ("unlockMonth".equals(action)) {
            if (roleId != 2) {
                session.setAttribute("errorMessage", "Chỉ HR Manager mới có quyền mở khóa bảng công.");
            } else {
                if (attendanceDAO.unlockMonth(month, year)) {
                    session.setAttribute("successMessage", "Đã MỞ KHÓA bảng công tháng " + month + "/" + year + ".");
                } else {
                    session.setAttribute("errorMessage", "Mở khóa thất bại.");
                }
            }
        } else if ("hrManagerApprove".equals(action)) {
            if (idStr == null || idStr.isEmpty()) {
                session.setAttribute("errorMessage", "Thiếu ID bảng công.");
                response.sendRedirect(request.getContextPath() + "/hr/timesheet-approval?month=" + month + "&year=" + year);
                return;
            }
            int id = Integer.parseInt(idStr);
            TimesheetConfirmation tc = tcDAO.getConfirmationById(id);
            if (tc == null) {
                session.setAttribute("errorMessage", "Bảng công không tồn tại.");
                response.sendRedirect(request.getContextPath() + "/hr/timesheet-approval?month=" + month + "&year=" + year);
                return;
            }

            if (roleId != 1 && roleId != 2) {
                session.setAttribute("errorMessage", "Chỉ Trưởng phòng Nhân sự (HR Manager) mới có quyền duyệt.");
            } else if (!"SENT_TO_HR_MANAGER".equals(tc.getStatus()) && !"DEPARTMENT_CONFIRMED".equals(tc.getStatus())) {
                session.setAttribute("errorMessage", "Bảng công chưa ở trạng thái sẵn sàng duyệt.");
            } else if (!tcDAO.areAllActiveDepartmentsConfirmed(tc.getMonth(), tc.getYear())) {
                session.setAttribute("errorMessage", "Chưa thể duyệt cuối do một số phòng ban chưa hoàn thành xác nhận bảng công.");
            } else {
                if (tcDAO.updateStatus(id, "HR_MANAGER_APPROVED", currentUser.getUserId(), null)) {
                    auditDAO.logWithValues("timesheet_confirmations", id, "HR_MANAGER_APPROVE", currentUser.getUserId(),
                            tc.getStatus(), "HR_MANAGER_APPROVED", "HR Manager duyệt bảng công", ipAddress);
                    session.setAttribute("successMessage", "Đã duyệt bảng công của phòng ban " + tc.getDepartmentName() + ".");
                } else {
                    session.setAttribute("errorMessage", "Duyệt thất bại.");
                }
            }
        } 
        else if ("hrManagerReject".equals(action)) {
            if (idStr == null || idStr.isEmpty()) {
                session.setAttribute("errorMessage", "Thiếu ID bảng công.");
                response.sendRedirect(request.getContextPath() + "/hr/timesheet-approval?month=" + month + "&year=" + year);
                return;
            }
            int id = Integer.parseInt(idStr);
            TimesheetConfirmation tc = tcDAO.getConfirmationById(id);
            if (tc == null) {
                session.setAttribute("errorMessage", "Bảng công không tồn tại.");
                response.sendRedirect(request.getContextPath() + "/hr/timesheet-approval?month=" + month + "&year=" + year);
                return;
            }

            String reason = request.getParameter("reason");
            if (reason == null || reason.trim().isEmpty()) {
                session.setAttribute("errorMessage", "Vui lòng nhập lý do từ chối.");
            } else if (roleId != 1 && roleId != 2) {
                session.setAttribute("errorMessage", "Chỉ Trưởng phòng Nhân sự (HR Manager) mới có quyền từ chối.");
            } else if (!"SENT_TO_HR_MANAGER".equals(tc.getStatus()) && !"DEPARTMENT_CONFIRMED".equals(tc.getStatus())) {
                session.setAttribute("errorMessage", "Bảng công chưa ở trạng thái sẵn sàng duyệt.");
            } else {
                if (tcDAO.updateStatus(id, "HR_MANAGER_REJECTED", currentUser.getUserId(), reason.trim())) {
                    auditDAO.logWithValues("timesheet_confirmations", id, "HR_MANAGER_REJECT", currentUser.getUserId(),
                            tc.getStatus(), "HR_MANAGER_REJECTED", "HR Manager từ chối duyệt: " + reason.trim(), ipAddress);
                    session.setAttribute("successMessage", "Đã từ chối duyệt bảng công.");
                } else {
                    session.setAttribute("errorMessage", "Từ chối thất bại.");
                }
            }
        }

        response.sendRedirect(request.getContextPath() + "/hr/timesheet-approval?month=" + month + "&year=" + year);
    }
}
