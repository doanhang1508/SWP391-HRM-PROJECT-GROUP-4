package controller.admin;

import dao.UserDAO;
import model.Shift;
import model.ShiftAssignment;
import model.User;
import service.ShiftService;
import service.ShiftServiceImpl;
import service.ShiftAssignmentService;
import service.ShiftAssignmentServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeParseException;
import java.time.temporal.TemporalAdjusters;
import java.util.List;
import java.util.Map;

/**
 * ShiftController — Handles Shift CRUD + Schedule Assignment operations.
 *
 * Routes:
 *   /admin/shifts                         → Shift definition list
 *   /admin/shifts?action=schedule         → Weekly schedule dashboard
 *   /admin/shifts?action=assign (POST)    → Assign shift to employee(s)
 */
@WebServlet(name = "ShiftController", urlPatterns = {"/admin/shifts"})
public class ShiftController extends HttpServlet {

    private ShiftService shiftService;
    private ShiftAssignmentService assignmentService;
    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        shiftService = new ShiftServiceImpl();
        assignmentService = new ShiftAssignmentServiceImpl();
        userDAO = new UserDAO();
    }

    // ═══════════════════════════════════════════════════════════════
    // HTTP Handlers
    // ═══════════════════════════════════════════════════════════════

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = getLoginUser(req);
        if (user == null) { resp.sendRedirect(req.getContextPath() + "/login.jsp"); return; }

        switch (getAction(req)) {
            case "schedule":     showSchedule(req, resp);      break;
            case "edit":         showEditForm(req, resp);       break;
            case "delete":       deleteShift(req, resp);        break;
            case "toggleStatus": toggleStatus(req, resp);       break;
            case "deleteAssign": deleteAssignment(req, resp);   break;
            default:             listShifts(req, resp);         break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        User user = getLoginUser(req);
        if (user == null) { resp.sendRedirect(req.getContextPath() + "/login.jsp"); return; }

        switch (getAction(req)) {
            case "create":  createShift(req, resp);  break;
            case "update":  updateShift(req, resp);  break;
            case "assign":  assignShift(req, resp);  break;
            default:        resp.sendRedirect(req.getContextPath() + "/admin/shifts"); break;
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // Shift CRUD Actions
    // ═══════════════════════════════════════════════════════════════

    private void listShifts(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        List<Shift> shifts = shiftService.getAllShifts();

        double[] hours = new double[shifts.size()];
        boolean[] nightFlags = new boolean[shifts.size()];
        for (int i = 0; i < shifts.size(); i++) {
            hours[i] = shiftService.calculateTotalWorkingHours(shifts.get(i));
            nightFlags[i] = shiftService.isNightShift(shifts.get(i));
        }

        req.setAttribute("shifts", shifts);
        req.setAttribute("workingHours", hours);
        req.setAttribute("nightShifts", nightFlags);
        req.getRequestDispatcher("/admin/shift-list.jsp").forward(req, resp);
    }

    private void showEditForm(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Integer id = parseIntParam(req, "shiftId");
        if (id == null) { redirect(resp, req, "error", "ID không hợp lệ"); return; }
        Shift s = shiftService.getShiftById(id);
        if (s == null) { redirect(resp, req, "error", "Không tìm thấy ca"); return; }
        req.setAttribute("editShift", s);
        listShifts(req, resp);
    }

    private void createShift(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String name = trimParam(req, "shiftName");
        if (name == null || name.isEmpty()) { redirect(resp, req, "error", "Tên ca không được để trống"); return; }
        if (name.length() > 50)            { redirect(resp, req, "error", "Tên ca không vượt quá 50 ký tự"); return; }
        if (shiftService.isShiftNameExists(name, 0)) { redirect(resp, req, "error", "Tên ca đã tồn tại"); return; }

        LocalTime start = parseTime(trimParam(req, "startTime"));
        LocalTime end   = parseTime(trimParam(req, "endTime"));
        if (start == null || end == null) { redirect(resp, req, "error", "Giờ bắt đầu và kết thúc là bắt buộc"); return; }

        Shift s = new Shift();
        s.setShiftName(name);
        s.setStartTime(start);
        s.setEndTime(end);
        s.setBreakStart(parseTime(trimParam(req, "breakStart")));
        s.setBreakEnd(parseTime(trimParam(req, "breakEnd")));
        s.setNightShift("on".equals(req.getParameter("isNightShift")) || end.isBefore(start));
        s.setCoefficient(parseFloatParam(req, "coefficient", 1.0f));
        s.setStatus(1);

        boolean ok = shiftService.addShift(s);
        redirect(resp, req, ok ? "message" : "error",
                ok ? "Thêm ca làm việc thành công" : "Thêm ca thất bại");
    }

    private void updateShift(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Integer id = parseIntParam(req, "shiftId");
        if (id == null) { redirect(resp, req, "error", "ID không hợp lệ"); return; }
        Shift existing = shiftService.getShiftById(id);
        if (existing == null) { redirect(resp, req, "error", "Không tìm thấy ca"); return; }

        String name = trimParam(req, "shiftName");
        if (name == null || name.isEmpty()) { redirect(resp, req, "error", "Tên ca không được để trống"); return; }
        if (shiftService.isShiftNameExists(name, id)) { redirect(resp, req, "error", "Tên ca đã tồn tại"); return; }

        LocalTime start = parseTime(trimParam(req, "startTime"));
        LocalTime end   = parseTime(trimParam(req, "endTime"));
        if (start == null || end == null) { redirect(resp, req, "error", "Giờ bắt đầu và kết thúc là bắt buộc"); return; }

        existing.setShiftName(name);
        existing.setStartTime(start);
        existing.setEndTime(end);
        existing.setBreakStart(parseTime(trimParam(req, "breakStart")));
        existing.setBreakEnd(parseTime(trimParam(req, "breakEnd")));
        existing.setNightShift("on".equals(req.getParameter("isNightShift")) || end.isBefore(start));
        existing.setCoefficient(parseFloatParam(req, "coefficient", existing.getCoefficient()));

        boolean ok = shiftService.updateShift(existing);
        redirect(resp, req, ok ? "message" : "error",
                ok ? "Cập nhật ca thành công" : "Cập nhật thất bại");
    }

    private void deleteShift(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Integer id = parseIntParam(req, "shiftId");
        if (id == null) { redirect(resp, req, "error", "ID không hợp lệ"); return; }
        boolean ok = shiftService.deleteShift(id);
        redirect(resp, req, ok ? "message" : "error",
                ok ? "Xóa ca thành công" : "Xóa thất bại");
    }

    private void toggleStatus(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Integer id = parseIntParam(req, "shiftId");
        if (id == null) { redirect(resp, req, "error", "ID không hợp lệ"); return; }
        boolean ok = shiftService.toggleShiftStatus(id);
        redirect(resp, req, ok ? "message" : "error",
                ok ? "Cập nhật trạng thái thành công" : "Cập nhật trạng thái thất bại");
    }

    // ═══════════════════════════════════════════════════════════════
    // Schedule Assignment Actions
    // ═══════════════════════════════════════════════════════════════

    /**
     * Show the weekly scheduling dashboard.
     * Accepts optional ?week=2026-06-01 parameter (any date in the target week).
     */
    private void showSchedule(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Determine the target week (Monday start)
        LocalDate targetDate = parseDate(req.getParameter("week"));
        if (targetDate == null) targetDate = LocalDate.now();
        LocalDate weekStart = targetDate.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));

        // Build the schedule matrix
        Map<Integer, Map<Integer, ShiftAssignment>> matrix =
                assignmentService.buildWeeklyScheduleMatrix(weekStart);

        // Load reference data
        List<Shift> activeShifts = shiftService.getActiveShifts();
        List<User> allUsers = userDAO.getAllUsers();

        // Build date headers (Mon-Sun)
        LocalDate[] weekDates = new LocalDate[7];
        for (int i = 0; i < 7; i++) {
            weekDates[i] = weekStart.plusDays(i);
        }

        req.setAttribute("weekStart", weekStart);
        req.setAttribute("weekDates", weekDates);
        req.setAttribute("matrix", matrix);
        req.setAttribute("activeShifts", activeShifts);
        req.setAttribute("allUsers", allUsers);

        req.getRequestDispatcher("/admin/shift-schedule.jsp").forward(req, resp);
    }

    /**
     * POST: Assign a shift to a user for a date range.
     * Parameters: userId, shiftId, fromDate, toDate
     */
    private void assignShift(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Integer userId  = parseIntParam(req, "userId");
        Integer shiftId = parseIntParam(req, "shiftId");
        LocalDate from  = parseDate(req.getParameter("fromDate"));
        LocalDate to    = parseDate(req.getParameter("toDate"));

        if (userId == null || shiftId == null || from == null || to == null) {
            redirectSchedule(resp, req, "error", "Vui lòng điền đầy đủ thông tin");
            return;
        }
        if (to.isBefore(from)) {
            redirectSchedule(resp, req, "error", "Ngày kết thúc phải sau ngày bắt đầu");
            return;
        }

        int inserted = assignmentService.batchAssign(userId, shiftId, from, to);
        redirectSchedule(resp, req, "message",
                "Đã xếp lịch " + inserted + " ngày thành công");
    }

    private void deleteAssignment(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Integer id = parseIntParam(req, "assignmentId");
        if (id == null) { redirectSchedule(resp, req, "error", "ID không hợp lệ"); return; }
        boolean ok = assignmentService.deleteAssignment(id);
        redirectSchedule(resp, req, ok ? "message" : "error",
                ok ? "Xóa lịch thành công" : "Xóa lịch thất bại");
    }

    // ═══════════════════════════════════════════════════════════════
    // Helpers
    // ═══════════════════════════════════════════════════════════════

    private User getLoginUser(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        return s != null ? (User) s.getAttribute("currentUser") : null;
    }

    private String getAction(HttpServletRequest req) {
        String a = req.getParameter("action");
        return (a != null && !a.trim().isEmpty()) ? a.trim() : "list";
    }

    private String trimParam(HttpServletRequest req, String name) {
        String v = req.getParameter(name);
        return v != null ? v.trim() : null;
    }

    private Integer parseIntParam(HttpServletRequest req, String name) {
        String raw = req.getParameter(name);
        if (raw == null || raw.trim().isEmpty()) return null;
        try { return Integer.parseInt(raw.trim()); }
        catch (NumberFormatException e) { return null; }
    }

    private float parseFloatParam(HttpServletRequest req, String name, float defaultVal) {
        String raw = req.getParameter(name);
        if (raw == null || raw.trim().isEmpty()) return defaultVal;
        try { return Float.parseFloat(raw.trim()); }
        catch (NumberFormatException e) { return defaultVal; }
    }

    private LocalTime parseTime(String s) {
        if (s == null || s.trim().isEmpty()) return null;
        try { return LocalTime.parse(s.trim()); }
        catch (DateTimeParseException e) { return null; }
    }

    private LocalDate parseDate(String s) {
        if (s == null || s.trim().isEmpty()) return null;
        try { return LocalDate.parse(s.trim()); }
        catch (DateTimeParseException e) { return null; }
    }

    private void redirect(HttpServletResponse resp, HttpServletRequest req,
                           String key, String msg) throws IOException {
        resp.sendRedirect(req.getContextPath() + "/admin/shifts?" + key + "=" + encode(msg));
    }

    private void redirectSchedule(HttpServletResponse resp, HttpServletRequest req,
                                   String key, String msg) throws IOException {
        resp.sendRedirect(req.getContextPath() + "/admin/shifts?action=schedule&" + key + "=" + encode(msg));
    }

    private String encode(String s) {
        return java.net.URLEncoder.encode(s, java.nio.charset.StandardCharsets.UTF_8);
    }
}
