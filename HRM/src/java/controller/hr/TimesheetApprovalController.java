package controller.hr;

import dao.TimesheetConfirmationDAO;
import dao.AttendanceDAO;
import dao.PayrollDAO;
import dao.notificationDAO;
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

@WebServlet(name = "TimesheetApprovalController", urlPatterns = { "/hr/timesheet-approval" })
public class TimesheetApprovalController extends HttpServlet {

    private final TimesheetConfirmationDAO tcDAO = new TimesheetConfirmationDAO();
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

        // Allow HR Manager (2)
        if (roleId != 2) {
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

        boolean isLocked = attendanceDAO.isMonthLocked(month, year);
        boolean allDeptsConfirmed = tcDAO.areAllActiveDepartmentsConfirmed(month, year);
        boolean hasPayrollDraft = new PayrollDAO().hasPayrollGenerated(month, year);
        request.setAttribute("isLocked", isLocked);
        request.setAttribute("allDeptsConfirmed", allDeptsConfirmed);
        request.setAttribute("hasPayrollDraft", hasPayrollDraft);

        List<TimesheetConfirmation> allConfirmations = tcDAO.getConfirmationsByPeriod(month, year);
        List<TimesheetConfirmation> pendingConfirmations = new ArrayList<>();

        for (TimesheetConfirmation c : allConfirmations) {
            // Show confirmations that are DEPARTMENT_CONFIRMED or SENT_TO_HR_MANAGER, or
            // already processed (approved/rejected) to view history
            if ("DEPARTMENT_CONFIRMED".equals(c.getStatus())
                    || "SENT_TO_HR_MANAGER".equals(c.getStatus())
                    || "HR_MANAGER_APPROVED".equals(c.getStatus())
                    || "HR_MANAGER_REJECTED".equals(c.getStatus())) {
                pendingConfirmations.add(c);
            }
        }

        request.setAttribute("confirmations", pendingConfirmations);
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
        if (roleId == 1) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập chức năng này.");
            return;
        }
        String action = request.getParameter("action");
        String monthStr = request.getParameter("month");
        String yearStr = request.getParameter("year");

        int month = (monthStr != null && !monthStr.isEmpty()) ? Integer.parseInt(monthStr)
                : LocalDate.now().getMonthValue();
        int year = (yearStr != null && !yearStr.isEmpty()) ? Integer.parseInt(yearStr) : LocalDate.now().getYear();

        int id = 0;
        TimesheetConfirmation tc = null;
        if ("hrManagerApprove".equals(action) || "hrManagerReject".equals(action)) {
            String idStr = request.getParameter("id");
            if (idStr == null || idStr.isEmpty()) {
                session.setAttribute("errorMessage", "Thiếu ID bảng công.");
                response.sendRedirect(request.getContextPath() + "/hr/timesheet-approval?month=" + month + "&year=" + year);
                return;
            }
            try {
                id = Integer.parseInt(idStr);
                tc = tcDAO.getConfirmationById(id);
                if (tc == null) {
                    session.setAttribute("errorMessage", "Bảng công không tồn tại.");
                    response.sendRedirect(request.getContextPath() + "/hr/timesheet-approval?month=" + month + "&year=" + year);
                    return;
                }
            } catch (NumberFormatException e) {
                session.setAttribute("errorMessage", "ID bảng công không hợp lệ.");
                response.sendRedirect(request.getContextPath() + "/hr/timesheet-approval?month=" + month + "&year=" + year);
                return;
            }
        }

        if ("hrManagerApprove".equals(action)) {
            if (roleId != 1 && roleId != 2) {
                session.setAttribute("errorMessage", "Chỉ Trưởng phòng Nhân sự (HR Manager) mới có quyền duyệt.");
            } else if (!"SENT_TO_HR_MANAGER".equals(tc.getStatus()) && !"DEPARTMENT_CONFIRMED".equals(tc.getStatus())) {
                session.setAttribute("errorMessage", "Bảng công chưa ở trạng thái sẵn sàng duyệt.");
            } else {
                if (tcDAO.updateStatus(id, "HR_MANAGER_APPROVED", currentUser.getUserId(), null)) {
                    session.setAttribute("successMessage",
                            "Đã duyệt bảng công của phòng ban " + tc.getDepartmentName() + ".");
                    notificationDAO notif = new notificationDAO();
                    notif.createForDepartmentHead(tc.getDepartmentId(), "attendance", "Bảng công đã được phê duyệt",
                        "Bảng công phòng ban Tháng " + tc.getMonth() + "/" + tc.getYear() + " đã được Trưởng phòng Nhân sự phê duyệt.",
                        "/manager/timesheet-confirm?month=" + tc.getMonth() + "&year=" + tc.getYear());
                    notif.createForRoles(new int[]{5}, "attendance", "Bảng công đã được phê duyệt",
                        "Bảng công phòng ban " + tc.getDepartmentName() + " Tháng " + tc.getMonth() + "/" + tc.getYear() + " đã được phê duyệt.",
                        "/manager/timesheet-confirm?month=" + tc.getMonth() + "&year=" + tc.getYear());
                } else {
                    session.setAttribute("errorMessage", "Duyệt thất bại.");
                }
            }
        } else if ("hrManagerReject".equals(action)) {
            String reason = request.getParameter("reason");
            if (reason == null || reason.trim().isEmpty()) {
                session.setAttribute("errorMessage", "Vui lòng nhập lý do từ chối.");
            } else if (roleId != 1 && roleId != 2) {
                session.setAttribute("errorMessage", "Chỉ Trưởng phòng Nhân sự (HR Manager) mới có quyền từ chối.");
            } else if (!"SENT_TO_HR_MANAGER".equals(tc.getStatus()) && !"DEPARTMENT_CONFIRMED".equals(tc.getStatus())) {
                session.setAttribute("errorMessage", "Bảng công chưa ở trạng thái sẵn sàng duyệt.");
            } else {
                if (tcDAO.updateStatus(id, "HR_MANAGER_REJECTED", currentUser.getUserId(), reason.trim())) {
                    tcDAO.resetConfirmationsForDept(tc.getMonth(), tc.getYear(), tc.getDepartmentId());
                    session.setAttribute("successMessage", "Đã từ chối duyệt bảng công.");
                    notificationDAO notif = new notificationDAO();
                    notif.createForRoles(new int[]{5}, "attendance", "Bảng công bị từ chối duyệt",
                        "Bảng công phòng ban " + tc.getDepartmentName() + " Tháng " + tc.getMonth() + "/" + tc.getYear() + " bị Trưởng phòng Nhân sự từ chối. Lý do: " + reason,
                        "/manager/timesheet-confirm?month=" + tc.getMonth() + "&year=" + tc.getYear());
                    notif.createForDepartmentHead(tc.getDepartmentId(), "attendance", "Bảng công bị từ chối duyệt",
                        "Bảng công phòng ban Tháng " + tc.getMonth() + "/" + tc.getYear() + " bị từ chối bởi Trưởng phòng Nhân sự. Lý do: " + reason,
                        "/manager/timesheet-confirm?month=" + tc.getMonth() + "&year=" + tc.getYear());
                    notif.createForDepartmentEmployees(tc.getDepartmentId(), "attendance", "Bảng công bị từ chối duyệt",
                        "Bảng công phòng ban Tháng " + tc.getMonth() + "/" + tc.getYear() + " bị từ chối bởi Trưởng phòng Nhân sự. Vui lòng kiểm tra lại sau khi cập nhật.",
                        "/employee/timesheet?month=" + tc.getMonth() + "&year=" + tc.getYear());
                } else {
                    session.setAttribute("errorMessage", "Từ chối thất bại.");
                }
            }
        } else if ("lockMonth".equals(action)) {
            if (roleId != 2) {
                session.setAttribute("errorMessage", "Chỉ Trưởng phòng Nhân sự (HR Manager) mới có quyền khóa.");
            } else {
                int recordCount = attendanceDAO.countAttendanceInMonth(month, year);
                if (recordCount == 0) {
                    session.setAttribute("errorMessage", "Không có dữ liệu chấm công cho tháng " + month + "/" + year + ". Không thể khóa.");
                } else {
                    if (attendanceDAO.lockMonth(month, year, currentUser.getUserId(), "Khóa từ màn hình duyệt công")) {
                        session.setAttribute("successMessage", "Đã khóa bảng công tháng " + month + "/" + year + " thành công.");
                    } else {
                        session.setAttribute("errorMessage", "Khóa thất bại.");
                    }
                }
            }
        } else if ("unlockMonth".equals(action)) {
            if (roleId != 2) {
                session.setAttribute("errorMessage", "Chỉ Trưởng phòng Nhân sự (HR Manager) mới có quyền mở khóa.");
            } else if (new PayrollDAO().hasPayrollGenerated(month, year)) {
                session.setAttribute("errorMessage", "Không thể mở khóa bảng công tháng " + month + "/" + year + ": Đã tồn tại bảng lương nháp cho kỳ này. Vui lòng xóa bảng lương nháp trước.");
            } else {
                if (attendanceDAO.unlockMonth(month, year)) {
                    session.setAttribute("successMessage", "Đã mở khóa bảng công tháng " + month + "/" + year + " thành công.");
                } else {
                    session.setAttribute("errorMessage", "Mở khóa thất bại.");
                }
            }
        }

        response.sendRedirect(request.getContextPath() + "/hr/timesheet-approval?month=" + month + "&year=" + year);
    }
}
