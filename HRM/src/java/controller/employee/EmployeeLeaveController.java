package controller.employee;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.LeaveRequest;
import model.User;
import dao.LeaveRequestDAO;
import dao.LeaveRequestDAOImpl;
import dao.notificationDAO;

import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.sql.Date;
import java.util.List;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.Part;
import model.LeaveType;

@WebServlet(name = "EmployeeLeaveController", urlPatterns = {"/employee/leave"})
@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 2, maxFileSize = 1024 * 1024 * 10, maxRequestSize = 1024 * 1024 * 50)
public class EmployeeLeaveController extends HttpServlet {

    private LeaveRequestDAO service;

    /** leaveTypeId = 3: Nghỉ thai sản nữ. Thai sản nam (type_id = 6) đã bị loại bỏ. */
    private static final int FEMALE_MATERNITY_LEAVE_TYPE_ID = 3;
    /** leaveTypeId = 6: Nghỉ thai sản nam — đã bị loại bỏ khỏi hệ thống. */
    private static final int REMOVED_MALE_MATERNITY_TYPE_ID = 6;

    @Override
    public void init() throws ServletException {
        service = new LeaveRequestDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("currentUser");
        
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if (service == null) {
            service = new LeaveRequestDAOImpl();
        }

        String action = request.getParameter("action");

        // ── calculateDays — AJAX: tính số ngày nghỉ theo loại ──
        if ("calculateDays".equals(action)) {
            String startDateStr = request.getParameter("startDate");
            String endDateStr   = request.getParameter("endDate");
            String leaveTypeStr = request.getParameter("leaveTypeId");
            try {
                java.time.LocalDate startDate = java.time.LocalDate.parse(startDateStr);
                java.time.LocalDate endDate   = java.time.LocalDate.parse(endDateStr);
                int leaveTypeId = 0;
                if (leaveTypeStr != null && !leaveTypeStr.isEmpty()) {
                    leaveTypeId = Integer.parseInt(leaveTypeStr);
                }

                double days;
                if (leaveTypeId == FEMALE_MATERNITY_LEAVE_TYPE_ID) {
                    // Thai sản nữ: tính theo ngày lịch (bao gồm CN, T7, lễ)
                    days = java.time.temporal.ChronoUnit.DAYS.between(startDate, endDate) + 1;
                    if (days < 0) days = 0;
                } else {
                    days = service.calculateTotalLeaveDays(user.getUserId(), startDate, endDate);
                }

                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"days\": " + days + "}");
                return;
            } catch (NumberFormatException e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.setContentType("application/json");
                response.getWriter().write("{\"error\": \"Tham số leaveTypeId không hợp lệ.\"}");
                return;
            } catch (Exception e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.setContentType("application/json");
                response.getWriter().write("{\"error\": \"" + e.getMessage() + "\"}");
                return;
            }
        }

        // ── Load danh sách loại nghỉ — lọc bỏ type 6 và type 3 với nam ──
        List<LeaveType> allLeaveTypes = service.getAllLeaveTypes();
        java.util.List<LeaveType> filteredLeaveTypes = new java.util.ArrayList<>();

        // Lấy giới tính nhân viên để lọc thai sản nữ
        Integer gender = null;
        try {
            dao.EmployeeProfileDAO profileDAO = new dao.EmployeeProfileDAO();
            model.EmployeeProfile profile = profileDAO.getByUserId(user.getUserId());
            if (profile != null) gender = profile.getGender();
        } catch (Exception ignored) {}

        for (LeaveType t : allLeaveTypes) {
            if (t.getLeaveTypeId() == REMOVED_MALE_MATERNITY_TYPE_ID) continue; // Loại bỏ type 6
            if (t.getLeaveTypeId() == FEMALE_MATERNITY_LEAVE_TYPE_ID && gender != null && gender == 1) {
                continue; // Nam không thấy option thai sản nữ
            }
            filteredLeaveTypes.add(t);
        }

        java.util.Map<Integer, Double> balances = new java.util.HashMap<>();
        for (model.LeaveType t : filteredLeaveTypes) {
            try {
                balances.put(t.getLeaveTypeId(), service.checkRemainingLeaveBalance(user.getUserId(), t.getLeaveTypeId()));
            } catch (Exception e) {
                balances.put(t.getLeaveTypeId(), 0.0);
            }
        }
        
        request.setAttribute("leaveBalances", balances);
        request.setAttribute("leaveTypes", filteredLeaveTypes);
        request.setAttribute("leaveHistory", service.getLeaveHistoryByUserId(user.getUserId()));
        // Truyền gender để JSP biết ẩn/hiện các label phù hợp
        request.setAttribute("employeeGender", gender);

        request.getRequestDispatcher("/employee/employee-leave.jsp").forward(request, response);
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

        if (service == null) {
            service = new LeaveRequestDAOImpl();
        }

        String action = request.getParameter("action");
        try {
            if ("submitLeave".equals(action)) {
                // ── Parse và validate leaveTypeId ──
                int leaveTypeId;
                try {
                    leaveTypeId = Integer.parseInt(request.getParameter("leaveTypeId"));
                } catch (NumberFormatException e) {
                    session.setAttribute("errorMessage", "Loại nghỉ phép không hợp lệ.");
                    response.sendRedirect(request.getContextPath() + "/employee/leave");
                    return;
                }

                // ── Server-side: từ chối type 6 ──
                if (leaveTypeId == REMOVED_MALE_MATERNITY_TYPE_ID) {
                    session.setAttribute("errorMessage", "Loại nghỉ thai sản nam không còn được hỗ trợ.");
                    response.sendRedirect(request.getContextPath() + "/employee/leave");
                    return;
                }

                // ── Server-side: kiểm tra giới tính cho thai sản nữ ──
                if (leaveTypeId == FEMALE_MATERNITY_LEAVE_TYPE_ID) {
                    try {
                        dao.EmployeeProfileDAO profileDAO = new dao.EmployeeProfileDAO();
                        model.EmployeeProfile profile = profileDAO.getByUserId(user.getUserId());
                        if (profile == null || profile.getGender() == null) {
                            session.setAttribute("errorMessage", "Không thể gửi đơn nghỉ thai sản: thông tin giới tính chưa được cập nhật.");
                            response.sendRedirect(request.getContextPath() + "/employee/leave");
                            return;
                        }
                        if (profile.getGender() == 1) { // 1 = Nam
                            session.setAttribute("errorMessage", "Chỉ nhân viên nữ được gửi đơn nghỉ thai sản.");
                            response.sendRedirect(request.getContextPath() + "/employee/leave");
                            return;
                        }
                    } catch (Exception e) {
                        session.setAttribute("errorMessage", "Lỗi kiểm tra thông tin nhân viên: " + e.getMessage());
                        response.sendRedirect(request.getContextPath() + "/employee/leave");
                        return;
                    }
                }

                LeaveRequest lr = new LeaveRequest();
                lr.setUserId(user.getUserId());
                lr.setLeaveTypeId(leaveTypeId);
                lr.setStartDate(Date.valueOf(request.getParameter("startDate")));
                lr.setEndDate(Date.valueOf(request.getParameter("endDate")));

                // ── Server tính lại totalDays — không tin giá trị từ frontend ──
                java.time.LocalDate startDate = lr.getStartDate().toLocalDate();
                java.time.LocalDate endDate   = lr.getEndDate().toLocalDate();
                double serverDays;
                if (leaveTypeId == FEMALE_MATERNITY_LEAVE_TYPE_ID) {
                    serverDays = java.time.temporal.ChronoUnit.DAYS.between(startDate, endDate) + 1;
                    if (serverDays < 0) serverDays = 0;
                } else {
                    serverDays = service.calculateTotalLeaveDays(user.getUserId(), startDate, endDate);
                }
                lr.setTotalDays(serverDays);
                lr.setReason(request.getParameter("reason"));

                Part filePart = request.getPart("attachment");
                if (filePart != null && filePart.getSize() > 0) {
                    String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
                    if (fileName != null && !fileName.isEmpty()) {
                        String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
                        File uploadDir = new File(uploadPath);
                        if (!uploadDir.exists()) uploadDir.mkdir();
                        
                        String finalFileName = System.currentTimeMillis() + "_" + fileName.replaceAll("[^a-zA-Z0-9.-]", "_");
                        filePart.write(uploadPath + File.separator + finalFileName);
                        lr.setAttachment("uploads/" + finalFileName);
                    }
                }

                boolean success = service.submitLeaveRequest(lr);
                if (success) {
                    session.setAttribute("successMessage", "Đơn xin nghỉ đã được gửi thành công.");
                    new notificationDAO().create(user.getUserId(), "leave", "Đơn xin nghỉ phép đã được gửi",
                        "Bạn đã gửi đơn xin nghỉ phép từ " + request.getParameter("startDate") +
                        " đến " + request.getParameter("endDate") + ". Vui lòng chờ phê duyệt.",
                        "/employee/leave");
                    new notificationDAO().createForDepartmentHead(user.getDepartmentId(), "leave",
                        "Đơn xin nghỉ phép mới cần duyệt",
                        user.getFullName() + " đã gửi đơn xin nghỉ phép từ " + request.getParameter("startDate") +
                        " đến " + request.getParameter("endDate") + ".",
                        "/manager/leave");
                } else {
                    session.setAttribute("errorMessage", "Không thể gửi đơn nghỉ. Vui lòng kiểm tra kết nối cơ sở dữ liệu hoặc schema.");
                }
            }
        } catch (Exception e) {
            session.setAttribute("errorMessage", "Lỗi: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/employee/leave");
    }
}
