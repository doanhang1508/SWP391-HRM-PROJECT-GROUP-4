package controller.hr;

import dao.TimesheetConfirmationDAO;
import dao.AuditLogDAO;
import model.Attendance;
import model.TimesheetConfirmation;
import model.Department;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

@WebServlet(name = "TimesheetConfirmationController", urlPatterns = {"/manager/timesheet-confirm"})
public class TimesheetConfirmationController extends HttpServlet {

    private final TimesheetConfirmationDAO tcDAO = new TimesheetConfirmationDAO();
    private final AuditLogDAO auditDAO = new AuditLogDAO();

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

        // Allow HR Manager (2), Factory Manager (3), HR Staff (5), Department Manager (6)
        if (roleId != 2 && roleId != 3 && roleId != 5 && roleId != 6) {
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

        if (roleId == 6 || roleId == 3 || roleId == 2) { // Department Manager, Factory Manager, HR Manager (as dept manager)
            int deptId = currentUser.getDepartmentId();
            TimesheetConfirmation confirmation = tcDAO.getConfirmationByPeriodAndDept(month, year, deptId);
            if (confirmation == null) {
                List<Department> activeDepts = tcDAO.getDepartmentsWithAttendance(month, year);
                boolean hasAttendance = false;
                for (Department d : activeDepts) {
                    if (d.getDepartmentId() == deptId) {
                        hasAttendance = true;
                        break;
                    }
                }
                if (hasAttendance) {
                    TimesheetConfirmation tc = new TimesheetConfirmation();
                    tc.setMonth(month);
                    tc.setYear(year);
                    tc.setDepartmentId(deptId);
                    tc.setStatus("DRAFT");
                    tc.setCreatedBy(currentUser.getUserId());
                    tcDAO.insert(tc);
                    confirmation = tcDAO.getConfirmationByPeriodAndDept(month, year, deptId);
                }
            }
            List<Attendance> attendanceList = tcDAO.getDepartmentAttendance(month, year, deptId);
            List<TimesheetConfirmationDAO.EmployeeTimesheetSummary> empSummaryList = tcDAO.getDepartmentEmployeeSummary(month, year, deptId);
            boolean allEmployeesConfirmed = tcDAO.haveAllEmployeesConfirmed(month, year, deptId);

            request.setAttribute("confirmation", confirmation);
            request.setAttribute("attendanceList", attendanceList);
            request.setAttribute("empSummaryList", empSummaryList);
            request.setAttribute("allEmployeesConfirmed", allEmployeesConfirmed);
            request.getRequestDispatcher("/manager/timesheet-confirm.jsp").forward(request, response);
        } else { // Admin, HR Staff
            List<Department> activeDepts = tcDAO.getDepartmentsWithAttendance(month, year);
            for (Department dept : activeDepts) {
                TimesheetConfirmation existing = tcDAO.getConfirmationByPeriodAndDept(month, year, dept.getDepartmentId());
                if (existing == null) {
                    TimesheetConfirmation tc = new TimesheetConfirmation();
                    tc.setMonth(month);
                    tc.setYear(year);
                    tc.setDepartmentId(dept.getDepartmentId());
                    tc.setStatus("DRAFT");
                    tc.setCreatedBy(currentUser.getUserId());
                    tcDAO.insert(tc);
                }
            }
            List<TimesheetConfirmation> confirmations = tcDAO.getConfirmationsByPeriod(month, year);

            int approvedCount = 0;
            for (TimesheetConfirmation c : confirmations) {
                if ("HR_MANAGER_APPROVED".equals(c.getStatus())) {
                    approvedCount++;
                }
            }

            request.setAttribute("confirmations", confirmations);
            request.setAttribute("activeDepts", activeDepts);
            request.setAttribute("approvedCount", approvedCount);
            request.getRequestDispatcher("/manager/timesheet-confirm.jsp").forward(request, response);
        }
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
        String ipAddress = request.getRemoteAddr();

        String action = request.getParameter("action");
        String monthStr = request.getParameter("month");
        String yearStr = request.getParameter("year");
        
        int month = (monthStr != null && !monthStr.isEmpty()) ? Integer.parseInt(monthStr) : LocalDate.now().getMonthValue();
        int year = (yearStr != null && !yearStr.isEmpty()) ? Integer.parseInt(yearStr) : LocalDate.now().getYear();

        if ("generateDrafts".equals(action)) {
            if (roleId != 1 && roleId != 5) { // Admin or HR Staff
                session.setAttribute("errorMessage", "Chỉ HR Staff hoặc Admin mới có quyền khởi tạo bảng công.");
                response.sendRedirect(request.getContextPath() + "/manager/timesheet-confirm?month=" + month + "&year=" + year);
                return;
            }

            List<Department> activeDepts = tcDAO.getDepartmentsWithAttendance(month, year);
            if (activeDepts.isEmpty()) {
                session.setAttribute("errorMessage", "Không tìm thấy dữ liệu chấm công tháng " + month + "/" + year + " để khởi tạo.");
                response.sendRedirect(request.getContextPath() + "/manager/timesheet-confirm?month=" + month + "&year=" + year);
                return;
            }

            int created = 0;
            for (Department dept : activeDepts) {
                TimesheetConfirmation existing = tcDAO.getConfirmationByPeriodAndDept(month, year, dept.getDepartmentId());
                if (existing == null) {
                    TimesheetConfirmation tc = new TimesheetConfirmation();
                    tc.setMonth(month);
                    tc.setYear(year);
                    tc.setDepartmentId(dept.getDepartmentId());
                    tc.setStatus("DRAFT");
                    tc.setCreatedBy(currentUser.getUserId());
                    if (tcDAO.insert(tc)) {
                        created++;
                        auditDAO.log("timesheet_confirmations", tc.getId(), "CREATE", currentUser.getUserId(),
                                "Khởi tạo bảng công phòng ban " + dept.getDepartmentName() + " ở trạng thái DRAFT", ipAddress);
                    }
                }
            }

            session.setAttribute("successMessage", "Đã khởi tạo " + created + " bảng công phòng ban.");
            response.sendRedirect(request.getContextPath() + "/manager/timesheet-confirm?month=" + month + "&year=" + year);
            return;
        }

        if ("sendAllToDepartments".equals(action)) {
            if (roleId != 1 && roleId != 5) {
                session.setAttribute("errorMessage", "Bạn không có quyền thực hiện hành động này.");
                response.sendRedirect(request.getContextPath() + "/manager/timesheet-confirm?month=" + month + "&year=" + year);
                return;
            }

            List<TimesheetConfirmation> confirmations = tcDAO.getConfirmationsByPeriod(month, year);
            int sentCount = 0;
            for (TimesheetConfirmation c : confirmations) {
                if ("DRAFT".equals(c.getStatus()) || "DEPARTMENT_REJECTED".equals(c.getStatus()) || "HR_MANAGER_REJECTED".equals(c.getStatus())) {
                    if (tcDAO.updateStatus(c.getId(), "SENT_TO_DEPARTMENT", currentUser.getUserId(), null)) {
                        auditDAO.logWithValues("timesheet_confirmations", c.getId(), "SEND_TO_DEPARTMENT", currentUser.getUserId(),
                                c.getStatus(), "SENT_TO_DEPARTMENT", "HR gửi hàng loạt bảng công cho phòng ban xác nhận", ipAddress);
                        sentCount++;
                    }
                }
            }

            session.setAttribute("successMessage", "Đã gửi thành công " + sentCount + " bảng công tới các phòng ban.");
            response.sendRedirect(request.getContextPath() + "/manager/timesheet-confirm?month=" + month + "&year=" + year);
            return;
        }

        // Status update actions
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            session.setAttribute("errorMessage", "Thiếu ID bảng công.");
            response.sendRedirect(request.getContextPath() + "/manager/timesheet-confirm?month=" + month + "&year=" + year);
            return;
        }

        int id = Integer.parseInt(idStr);
        TimesheetConfirmation tc = tcDAO.getConfirmationById(id);
        if (tc == null) {
            session.setAttribute("errorMessage", "Bảng công không tồn tại.");
            response.sendRedirect(request.getContextPath() + "/manager/timesheet-confirm?month=" + month + "&year=" + year);
            return;
        }

        if ("sendToDepartment".equals(action)) {
            if (roleId != 1 && roleId != 5) {
                session.setAttribute("errorMessage", "Bạn không có quyền thực hiện hành động này.");
            } else if (!"DRAFT".equals(tc.getStatus()) && !"DEPARTMENT_REJECTED".equals(tc.getStatus()) && !"HR_MANAGER_REJECTED".equals(tc.getStatus())) {
                session.setAttribute("errorMessage", "Trạng thái hiện tại không hợp lệ để gửi cho phòng ban.");
            } else {
                if (tcDAO.updateStatus(id, "SENT_TO_DEPARTMENT", currentUser.getUserId(), null)) {
                    auditDAO.logWithValues("timesheet_confirmations", id, "SEND_TO_DEPARTMENT", currentUser.getUserId(),
                            tc.getStatus(), "SENT_TO_DEPARTMENT", "HR gửi bảng công cho phòng ban xác nhận", ipAddress);
                    session.setAttribute("successMessage", "Đã gửi bảng công cho phòng ban " + tc.getDepartmentName() + ".");
                } else {
                    session.setAttribute("errorMessage", "Cập nhật trạng thái thất bại.");
                }
            }
        } 
        else if ("departmentConfirm".equals(action)) {
            if (roleId != 1 && roleId != 6 && roleId != 3 && roleId != 2) {
                session.setAttribute("errorMessage", "Bạn không có quyền thực hiện hành động này.");
            } else if ((roleId == 6 || roleId == 3 || roleId == 2) && currentUser.getDepartmentId() != tc.getDepartmentId()) {
                session.setAttribute("errorMessage", "Bạn chỉ được duyệt bảng công của phòng ban mình.");
            } else if (!"SENT_TO_DEPARTMENT".equals(tc.getStatus())) {
                session.setAttribute("errorMessage", "Trạng thái hiện tại không hợp lệ để xác nhận.");
            } else if (!tcDAO.haveAllEmployeesConfirmed(tc.getMonth(), tc.getYear(), tc.getDepartmentId())) {
                session.setAttribute("errorMessage", "Còn nhân viên chưa xác nhận phiếu công.");
            } else {
                if (tcDAO.updateStatus(id, "DEPARTMENT_CONFIRMED", currentUser.getUserId(), null)) {
                    auditDAO.logWithValues("timesheet_confirmations", id, "DEPARTMENT_CONFIRM", currentUser.getUserId(),
                            tc.getStatus(), "DEPARTMENT_CONFIRMED", "Trưởng phòng xác nhận bảng công", ipAddress);
                    session.setAttribute("successMessage", "Đã xác nhận bảng công phòng ban.");
                } else {
                    session.setAttribute("errorMessage", "Xác nhận thất bại.");
                }
            }
        } 
        else if ("departmentReject".equals(action)) {
            String reason = request.getParameter("reason");
            if (reason == null || reason.trim().isEmpty()) {
                session.setAttribute("errorMessage", "Vui lòng nhập lý do từ chối.");
            } else if (roleId != 1 && roleId != 6 && roleId != 3 && roleId != 2) {
                session.setAttribute("errorMessage", "Bạn không có quyền thực hiện hành động này.");
            } else if ((roleId == 6 || roleId == 3 || roleId == 2) && currentUser.getDepartmentId() != tc.getDepartmentId()) {
                session.setAttribute("errorMessage", "Bạn chỉ được phản hồi bảng công của phòng ban mình.");
            } else if (!"SENT_TO_DEPARTMENT".equals(tc.getStatus())) {
                session.setAttribute("errorMessage", "Trạng thái hiện tại không hợp lệ để từ chối.");
            } else {
                if (tcDAO.updateStatus(id, "DEPARTMENT_REJECTED", currentUser.getUserId(), reason.trim())) {
                    auditDAO.logWithValues("timesheet_confirmations", id, "DEPARTMENT_REJECT", currentUser.getUserId(),
                            tc.getStatus(), "DEPARTMENT_REJECTED", "Trưởng phòng phản hồi sai lệch: " + reason.trim(), ipAddress);
                    session.setAttribute("successMessage", "Đã gửi phản hồi sai lệch cho HR.");
                } else {
                    session.setAttribute("errorMessage", "Phản hồi thất bại.");
                }
            }
        } 
        else if ("sendToHRManager".equals(action)) {
            if (roleId != 1 && roleId != 5) {
                session.setAttribute("errorMessage", "Bạn không có quyền thực hiện hành động này.");
            } else if (!"DEPARTMENT_CONFIRMED".equals(tc.getStatus())) {
                session.setAttribute("errorMessage", "Chỉ được gửi lên HR Manager khi phòng ban đã xác nhận.");
            } else {
                if (tcDAO.updateStatus(id, "SENT_TO_HR_MANAGER", currentUser.getUserId(), null)) {
                    auditDAO.logWithValues("timesheet_confirmations", id, "SEND_TO_HR_MANAGER", currentUser.getUserId(),
                            tc.getStatus(), "SENT_TO_HR_MANAGER", "HR Staff gửi bảng công lên HR Manager duyệt", ipAddress);
                    session.setAttribute("successMessage", "Đã gửi bảng công lên HR Manager.");
                } else {
                    session.setAttribute("errorMessage", "Gửi duyệt thất bại.");
                }
            }
        } 
        else if ("hrManagerApprove".equals(action)) {
            if (roleId != 1 && roleId != 2) {
                session.setAttribute("errorMessage", "Chỉ Trưởng phòng Nhân sự (HR Manager) mới có quyền duyệt.");
            } else if (!"SENT_TO_HR_MANAGER".equals(tc.getStatus())) {
                session.setAttribute("errorMessage", "Bảng công chưa được gửi lên HR Manager.");
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
            String reason = request.getParameter("reason");
            if (reason == null || reason.trim().isEmpty()) {
                session.setAttribute("errorMessage", "Vui lòng nhập lý do từ chối.");
            } else if (roleId != 1 && roleId != 2) {
                session.setAttribute("errorMessage", "Chỉ Trưởng phòng Nhân sự (HR Manager) mới có quyền từ chối.");
            } else if (!"SENT_TO_HR_MANAGER".equals(tc.getStatus())) {
                session.setAttribute("errorMessage", "Bảng công chưa được gửi lên HR Manager.");
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

        response.sendRedirect(request.getContextPath() + "/manager/timesheet-confirm?month=" + month + "&year=" + year);
    }
}
