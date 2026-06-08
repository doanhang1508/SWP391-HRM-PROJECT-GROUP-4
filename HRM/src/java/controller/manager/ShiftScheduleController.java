package controller.manager;

import dao.UserDAO;
import model.Shift;
import model.ShiftAssignment;
import model.User;
import dao.ShiftAssignmentDAO;
import dao.ShiftAssignmentDAOImpl;
import dao.ShiftDAO;
import dao.ShiftDAOImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.time.temporal.TemporalAdjusters;
import java.util.List;
import java.util.Map;

/**
 * ShiftScheduleController — Xếp lịch ca và phân tăng ca cho công nhân xưởng.
 *
 * URL   : /manager/shift-schedule
 * Role  : 3 (Supervisor / Quản đốc) — AuthFilter đã bảo vệ /manager/*
 *
 * Khác với ShiftController (/admin/shifts) chỉ dành cho HR Manager định nghĩa
 * ca (tạo/sửa/xoá), controller này cho phép Supervisor XẾP CA (gán ca đã có
 * sẵn cho công nhân trong tuần) và phân ca tăng ca (OT).
 *
 * GET  ?action=schedule  → hiển thị bảng lịch tuần
 * POST ?action=assign    → gán ca cho nhân viên (date range)
 * POST ?action=delete    → xoá một lịch ca đã gán
 */
@WebServlet(name = "ShiftScheduleController", urlPatterns = {"/manager/shift-schedule"})
public class ShiftScheduleController extends HttpServlet {

    private static final int ROLE_SUPERVISOR = 3;

    private ShiftDAO           shiftService;
    private ShiftAssignmentDAO assignmentService;
    private UserDAO                userDAO;

    @Override
    public void init() throws ServletException {
        shiftService      = new ShiftDAOImpl();
        assignmentService = new ShiftAssignmentDAOImpl();
        userDAO           = new UserDAO();
    }

    // ════════════════════════════════════════════════════════
    //  GET
    // ════════════════════════════════════════════════════════
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = getCurrentUser(req);
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        // Chỉ Supervisor (role 3) mới được xếp ca
        if (user.getRoleId() != ROLE_SUPERVISOR) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }

        String action = getAction(req);
        if ("delete".equals(action)) {
            deleteAssignment(req, resp);
        } else {
            showSchedule(req, resp, user);
        }
    }

    // ════════════════════════════════════════════════════════
    //  POST
    // ════════════════════════════════════════════════════════
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        User user = getCurrentUser(req);
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        if (user.getRoleId() != ROLE_SUPERVISOR) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }

        String action = getAction(req);
        switch (action) {
            case "assign":
                assignShift(req, resp);
                break;
            case "delete":
                deleteAssignment(req, resp);
                break;
            default:
                resp.sendRedirect(req.getContextPath() + "/manager/shift-schedule");
        }
    }

    // ════════════════════════════════════════════════════════
    //  Business Logic
    // ════════════════════════════════════════════════════════

    /**
     * Hiển thị bảng xếp lịch ca theo tuần.
     * Supervisor chỉ thấy công nhân thuộc department của mình.
     */
    private void showSchedule(HttpServletRequest req, HttpServletResponse resp, User supervisor)
            throws ServletException, IOException {

        // Xác định tuần cần xem
        LocalDate targetDate = parseDate(req.getParameter("week"));
        if (targetDate == null) targetDate = LocalDate.now();
        LocalDate weekStart = targetDate.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));

        // Ma trận lịch tuần
        Map<Integer, Map<Integer, List<ShiftAssignment>>> matrix =
                assignmentService.buildWeeklyScheduleMatrix(weekStart);

        // Danh sách ca đang hoạt động (để Supervisor chọn khi gán)
        List<Shift> activeShifts = shiftService.getActiveShifts();

        // Danh sách nhân viên: lọc theo department của Supervisor
        // getByDepartment lọc nhân viên đang active theo department_id của Supervisor
        List<User> workers = userDAO.getByDepartment(supervisor.getDepartmentId());

        // Build mảng ngày trong tuần
        LocalDate[] weekDates = new LocalDate[7];
        for (int i = 0; i < 7; i++) weekDates[i] = weekStart.plusDays(i);

        req.setAttribute("weekStart",    weekStart);
        req.setAttribute("weekDates",    weekDates);
        req.setAttribute("matrix",       matrix);
        req.setAttribute("activeShifts", activeShifts);
        req.setAttribute("workers",      workers);

        req.getRequestDispatcher("/manager/shift-schedule.jsp").forward(req, resp);
    }

    /**
     * Gán ca cho nhân viên theo khoảng ngày (fromDate → toDate).
     * Supervisor dùng để phân ca hành chính lẫn tăng ca.
     */
    private void assignShift(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        Integer  userId  = parseIntParam(req, "userId");
        LocalDate from   = parseDate(req.getParameter("fromDate"));
        LocalDate to     = parseDate(req.getParameter("toDate"));
        String startTimeStr = req.getParameter("startTime");
        String endTimeStr   = req.getParameter("endTime");

        if (userId == null || from == null || to == null || startTimeStr == null || endTimeStr == null || startTimeStr.isEmpty() || endTimeStr.isEmpty()) {
            redirectSchedule(req, resp, "error", "Vui lòng điền đầy đủ thông tin");
            return;
        }
        
        java.time.LocalTime startTime = java.time.LocalTime.parse(startTimeStr);
        java.time.LocalTime endTime   = java.time.LocalTime.parse(endTimeStr);
        
        // Find or create the OT shift dynamically
        int shiftId = shiftService.findOrCreateCustomShift(startTime, endTime);
        if (to.isBefore(from)) {
            redirectSchedule(req, resp, "error", "Ngày kết thúc phải sau ngày bắt đầu");
            return;
        }

        int inserted = assignmentService.batchAssign(userId, shiftId, from, to);
        if (inserted > 0) {
            redirectSchedule(req, resp, "message", "Đã xếp lịch " + inserted + " ngày thành công.");
        } else {
            redirectSchedule(req, resp, "error", "Lỗi: Ca mới bị trùng giờ với ca cũ hoặc đã tồn tại.");
        }
    }

    /** Xoá một lịch ca đã gán. */
    private void deleteAssignment(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        Integer id = parseIntParam(req, "assignmentId");
        if (id == null) {
            redirectSchedule(req, resp, "error", "ID không hợp lệ");
            return;
        }
        boolean ok = assignmentService.deleteAssignment(id);
        redirectSchedule(req, resp, ok ? "message" : "error",
                ok ? "Xóa lịch thành công" : "Xóa lịch thất bại");
    }

    // ════════════════════════════════════════════════════════
    //  Helpers
    // ════════════════════════════════════════════════════════
    private User getCurrentUser(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        return s != null ? (User) s.getAttribute("currentUser") : null;
    }

    private String getAction(HttpServletRequest req) {
        String a = req.getParameter("action");
        return (a != null && !a.trim().isEmpty()) ? a.trim() : "schedule";
    }

    private Integer parseIntParam(HttpServletRequest req, String name) {
        String raw = req.getParameter(name);
        if (raw == null || raw.trim().isEmpty()) return null;
        try { return Integer.parseInt(raw.trim()); }
        catch (NumberFormatException e) { return null; }
    }

    private LocalDate parseDate(String s) {
        if (s == null || s.trim().isEmpty()) return null;
        try { return LocalDate.parse(s.trim()); }
        catch (DateTimeParseException e) { return null; }
    }

    private void redirectSchedule(HttpServletRequest req, HttpServletResponse resp,
                                  String key, String msg) throws IOException {
        resp.sendRedirect(req.getContextPath() + "/manager/shift-schedule?"
                + key + "=" + java.net.URLEncoder.encode(msg, java.nio.charset.StandardCharsets.UTF_8));
    }
}
