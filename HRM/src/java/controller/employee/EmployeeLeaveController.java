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
            try {
                java.time.LocalDate startDate = java.time.LocalDate.parse(startDateStr);
                java.time.LocalDate endDate   = java.time.LocalDate.parse(endDateStr);

                double days = service.calculateTotalLeaveDays(user.getUserId(), startDate, endDate);

                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"days\": " + days + "}");
                return;
            } catch (Exception e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.setContentType("application/json");
                response.getWriter().write("{\"error\": \"" + e.getMessage() + "\"}");
                return;
            }
        }

        // ── Load danh sách loại nghỉ — lọc bỏ type 6 ──
        List<LeaveType> allLeaveTypes = service.getAllLeaveTypes();
        java.util.List<LeaveType> filteredLeaveTypes = new java.util.ArrayList<>();

        for (LeaveType t : allLeaveTypes) {
            if (t.getLeaveTypeId() == 6) continue; // Loại bỏ type 6
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
                if (leaveTypeId == 6) {
                    session.setAttribute("errorMessage", "Loại nghỉ này không còn được hỗ trợ.");
                    response.sendRedirect(request.getContextPath() + "/employee/leave");
                    return;
                }

                LeaveRequest lr = new LeaveRequest();
                lr.setUserId(user.getUserId());
                lr.setLeaveTypeId(leaveTypeId);
                lr.setStartDate(Date.valueOf(request.getParameter("startDate")));
                lr.setEndDate(Date.valueOf(request.getParameter("endDate")));

                // ── Server tính lại totalDays — không tin giá trị từ frontend ──
                java.time.LocalDate startDate = lr.getStartDate().toLocalDate();
                java.time.LocalDate endDate   = lr.getEndDate().toLocalDate();
                double serverDays = service.calculateTotalLeaveDays(user.getUserId(), startDate, endDate);
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
