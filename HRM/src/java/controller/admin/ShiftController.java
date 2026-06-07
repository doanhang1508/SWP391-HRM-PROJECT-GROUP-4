package controller.admin;

import model.Shift;
import model.User;
import service.ShiftService;
import service.ShiftServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
<<<<<<< Updated upstream
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeParseException;
import java.util.List;

<<<<<<< Updated upstream
@WebServlet(name = "ShiftController", urlPatterns = {"/admin/shifts"})
public class ShiftController extends HttpServlet {

    private static final String ATTR_ERROR        = "error";
    private static final String ATTR_MESSAGE      = "message";
    private static final String PARAM_SHIFT_ID    = "shiftId";
    private static final String INVALID_ID        = "ID khong hop le";
    private static final String SHIFTS_URL        = "/admin/shifts";
    private static final String SCHEDULE_URL      = SHIFTS_URL + "?action=schedule";
    private static final String LOGIN_URL         = "/login";
    private static final String DASHBOARD_URL     = "/dashboard";
    private static final String SHIFT_LIST_VIEW   = "/hr/shift-list.jsp";
    private static final String SHIFT_SCHED_VIEW  = "/hr/shift-schedule.jsp";

    private ShiftService           shiftService;
    private ShiftAssignmentService assignmentService;
    private UserDAO                userDAO;

    @Override
    public void init() throws ServletException {
        shiftService      = new ShiftServiceImpl();
        assignmentService = new ShiftAssignmentServiceImpl();
        userDAO           = new UserDAO();
    }

    // ── HTTP Handlers ─────────────────────────────────────

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) {
        User user = getLoginUser(req);
        if (!checkAccess(user, resp, req)) return;

        switch (getAction(req)) {
            case "schedule": showSchedule(req, resp);  break;
            case "edit":     showEditForm(req, resp);  break;
            default:         listShifts(req, resp);    break;
=======
/**
 * ShiftController — Chỉ quản lý ĐỊNH NGHĨA ca làm việc (CRUD).
 *
 * URL  : /admin/shifts
 * Role : 2 (HR Manager) — HR Manager tạo/sửa/xóa định nghĩa ca (tên, giờ giấc, bầc công).
 *
 * Việc XẼP CA (gán ca cho công nhân) thuộc về Supervisor (role 3),
 * được xử lý bởi controller.manager.ShiftScheduleController (/manager/shift-schedule).
 */
@WebServlet(name = "ShiftController", urlPatterns = {"/admin/shifts"})
public class ShiftController extends HttpServlet {

    private ShiftService shiftService;

    @Override
    public void init() throws ServletException {
        shiftService = new ShiftServiceImpl();
    }

    // ═══════════════════════════════════════════════════════════════
    // HTTP Handlers
    // ═══════════════════════════════════════════════════════════════
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = getLoginUser(req);
        if (user == null) { resp.sendRedirect(req.getContextPath() + "/login"); return; }

        // Chỉ HR Manager (role 2) mới được định nghĩa ca
        // Supervisor (role 3) xếp lịch tại /manager/shift-schedule
        if (user.getRoleId() != 2) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }

        switch (getAction(req)) {
            case "edit":
                showEditForm(req, resp);
                break;
            default:
                listShifts(req, resp);
                break;
>>>>>>> Stashed changes
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) {
        setEncoding(req);
        User user = getLoginUser(req);
<<<<<<< Updated upstream
        if (!checkAccess(user, resp, req)) return;

        switch (getAction(req)) {
            case "create":       createShift(req, resp);      break;
            case "update":       updateShift(req, resp);      break;
            case "assign":       assignShift(req, resp);      break;
            case "delete":       deleteShift(req, resp);      break;
            case "toggleStatus": toggleStatus(req, resp);     break;
            case "deleteAssign": deleteAssignment(req, resp); break;
            default:             redirect(resp, req.getContextPath() + SHIFTS_URL); break;
=======
        if (user == null) { resp.sendRedirect(req.getContextPath() + "/login"); return; }

        // Chỉ HR Manager (role 2)
        if (user.getRoleId() != 2) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }

        switch (getAction(req)) {
            case "create":
                createShift(req, resp);
                break;
            case "update":
                updateShift(req, resp);
                break;
            case "delete":
                deleteShift(req, resp);
                break;
            case "toggleStatus":
                toggleStatus(req, resp);
                break;
            default:
                resp.sendRedirect(req.getContextPath() + "/admin/shifts");
                break;
>>>>>>> Stashed changes
        }
    }

    // ── Auth ──────────────────────────────────────────────

    private boolean checkAccess(User user, HttpServletResponse resp, HttpServletRequest req) {
        if (user == null) {
            redirect(resp, req.getContextPath() + LOGIN_URL);
            return false;
        }
        if (user.getRoleId() != 2) {
            redirect(resp, req.getContextPath() + DASHBOARD_URL);
            return false;
        }
        return true;
    }

    // ── Shift CRUD ────────────────────────────────────────

    private void listShifts(HttpServletRequest req, HttpServletResponse resp) {
        List<Shift> shifts = shiftService.getAllShifts();
        double[]  hours      = new double[shifts.size()];
        boolean[] nightFlags = new boolean[shifts.size()];

        for (int i = 0; i < shifts.size(); i++) {
            hours[i]      = shiftService.calculateTotalWorkingHours(shifts.get(i));
            nightFlags[i] = shiftService.isNightShift(shifts.get(i));
        }

        req.setAttribute("shifts",       shifts);
        req.setAttribute("workingHours", hours);
        req.setAttribute("nightShifts",  nightFlags);
        forwardToView(req, resp, SHIFT_LIST_VIEW);
    }

    private void showEditForm(HttpServletRequest req, HttpServletResponse resp) {
        Integer id = parseIntParam(req, PARAM_SHIFT_ID);
        if (id == null) { redirectShifts(resp, req, ATTR_ERROR, INVALID_ID); return; }

        Shift s = shiftService.getShiftById(id);
        if (s == null) { redirectShifts(resp, req, ATTR_ERROR, "Khong tim thay ca"); return; }

        req.setAttribute("editShift", s);
        listShifts(req, resp);
    }

    private void createShift(HttpServletRequest req, HttpServletResponse resp) {
        String name = trimParam(req, "shiftName");
        if (name == null || name.isEmpty()) {
            redirectShifts(resp, req, ATTR_ERROR, "Ten ca khong duoc de trong"); return;
        }
        if (name.length() > 50) {
            redirectShifts(resp, req, ATTR_ERROR, "Ten ca khong vuot qua 50 ky tu"); return;
        }
        if (shiftService.isShiftNameExists(name, 0)) {
            redirectShifts(resp, req, ATTR_ERROR, "Ten ca da ton tai"); return;
        }

        LocalTime start = parseTime(trimParam(req, "startTime"));
        LocalTime end   = parseTime(trimParam(req, "endTime"));
        if (start == null || end == null) {
            redirectShifts(resp, req, ATTR_ERROR, "Gio bat dau va ket thuc la bat buoc"); return;
        }

        Shift s = buildShift(req, new Shift(), name, start, end);
        s.setStatus(1);

        boolean ok = shiftService.addShift(s);
        redirectShifts(resp, req,
                ok ? ATTR_MESSAGE : ATTR_ERROR,
                ok ? "Them ca lam viec thanh cong" : "Them ca that bai");
    }

    private void updateShift(HttpServletRequest req, HttpServletResponse resp) {
        Integer id = parseIntParam(req, PARAM_SHIFT_ID);
        if (id == null) { redirectShifts(resp, req, ATTR_ERROR, INVALID_ID); return; }

        Shift existing = shiftService.getShiftById(id);
        if (existing == null) { redirectShifts(resp, req, ATTR_ERROR, "Khong tim thay ca"); return; }

        String name = trimParam(req, "shiftName");
        if (name == null || name.isEmpty()) {
            redirectShifts(resp, req, ATTR_ERROR, "Ten ca khong duoc de trong"); return;
        }
        if (shiftService.isShiftNameExists(name, id)) {
            redirectShifts(resp, req, ATTR_ERROR, "Ten ca da ton tai"); return;
        }

        LocalTime start = parseTime(trimParam(req, "startTime"));
        LocalTime end   = parseTime(trimParam(req, "endTime"));
        if (start == null || end == null) {
            redirectShifts(resp, req, ATTR_ERROR, "Gio bat dau va ket thuc la bat buoc"); return;
        }

        buildShift(req, existing, name, start, end);
        existing.setCoefficient(parseFloatParam(req, "coefficient", existing.getCoefficient()));

        boolean ok = shiftService.updateShift(existing);
        redirectShifts(resp, req,
                ok ? ATTR_MESSAGE : ATTR_ERROR,
                ok ? "Cap nhat ca thanh cong" : "Cap nhat that bai");
    }

    private void deleteShift(HttpServletRequest req, HttpServletResponse resp) {
        Integer id = parseIntParam(req, PARAM_SHIFT_ID);
        if (id == null) { redirectShifts(resp, req, ATTR_ERROR, INVALID_ID); return; }
        boolean ok = shiftService.deleteShift(id);
        redirectShifts(resp, req,
                ok ? ATTR_MESSAGE : ATTR_ERROR,
                ok ? "Xoa ca thanh cong" : "Xoa that bai");
    }

    private void toggleStatus(HttpServletRequest req, HttpServletResponse resp) {
        Integer id = parseIntParam(req, PARAM_SHIFT_ID);
        if (id == null) { redirectShifts(resp, req, ATTR_ERROR, INVALID_ID); return; }
        boolean ok = shiftService.toggleShiftStatus(id);
        redirectShifts(resp, req,
                ok ? ATTR_MESSAGE : ATTR_ERROR,
                ok ? "Cap nhat trang thai thanh cong" : "Cap nhat trang thai that bai");
    }

    // ── Schedule ──────────────────────────────────────────

    private void showSchedule(HttpServletRequest req, HttpServletResponse resp) {
        LocalDate targetDate = parseDate(req.getParameter("week"));
        if (targetDate == null) targetDate = LocalDate.now();
        LocalDate weekStart = targetDate.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));

        Map<Integer, Map<Integer, ShiftAssignment>> matrix =
                assignmentService.buildWeeklyScheduleMatrix(weekStart);

        LocalDate[] weekDates = new LocalDate[7];
        for (int i = 0; i < 7; i++) weekDates[i] = weekStart.plusDays(i);

        req.setAttribute("weekStart",    weekStart);
        req.setAttribute("weekDates",    weekDates);
        req.setAttribute("matrix",       matrix);
        req.setAttribute("activeShifts", shiftService.getActiveShifts());
        req.setAttribute("allUsers",     userDAO.getAllUsers());

        forwardToView(req, resp, SHIFT_SCHED_VIEW);
    }

    private void assignShift(HttpServletRequest req, HttpServletResponse resp) {
        Integer   userId  = parseIntParam(req, "userId");
        Integer   shiftId = parseIntParam(req, PARAM_SHIFT_ID);
        LocalDate from    = parseDate(req.getParameter("fromDate"));
        LocalDate to      = parseDate(req.getParameter("toDate"));

        if (userId == null || shiftId == null || from == null || to == null) {
            redirectSchedule(resp, req, ATTR_ERROR, "Vui long dien day du thong tin"); return;
        }
        if (to.isBefore(from)) {
            redirectSchedule(resp, req, ATTR_ERROR, "Ngay ket thuc phai sau ngay bat dau"); return;
        }

        int inserted = assignmentService.batchAssign(userId, shiftId, from, to);
        redirectSchedule(resp, req, ATTR_MESSAGE, "Da xep lich " + inserted + " ngay thanh cong");
    }

    private void deleteAssignment(HttpServletRequest req, HttpServletResponse resp) {
        Integer id = parseIntParam(req, "assignmentId");
        if (id == null) { redirectSchedule(resp, req, ATTR_ERROR, INVALID_ID); return; }
        boolean ok = assignmentService.deleteAssignment(id);
        redirectSchedule(resp, req,
                ok ? ATTR_MESSAGE : ATTR_ERROR,
                ok ? "Xoa lich thanh cong" : "Xoa lich that bai");
    }

    // ── Builders ──────────────────────────────────────────

    private Shift buildShift(HttpServletRequest req, Shift s,
                             String name, LocalTime start, LocalTime end) {
        s.setShiftName(name);
        s.setStartTime(start);
        s.setEndTime(end);
        s.setBreakStart(parseTime(trimParam(req, "breakStart")));
        s.setBreakEnd(parseTime(trimParam(req, "breakEnd")));
        s.setNightShift("on".equals(req.getParameter("isNightShift")) || end.isBefore(start));
        s.setCoefficient(parseFloatParam(req, "coefficient", 1.0f));
        return s;
    }

    // ── I/O helpers ───────────────────────────────────────

    private void forwardToView(HttpServletRequest req, HttpServletResponse resp, String view) {
        try {
            req.getRequestDispatcher(view).forward(req, resp);
        } catch (ServletException | IOException e) {
            try {
                resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Forward failed");
            } catch (IOException ex) {
                Thread.currentThread().interrupt();
            }
        }
    }

    private void redirect(HttpServletResponse resp, String url) {
        try {
            resp.sendRedirect(url);
        } catch (IOException e) {
            try {
                resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Redirect failed");
            } catch (IOException ex) {
                Thread.currentThread().interrupt();
            }
        }
    }

    private void redirectShifts(HttpServletResponse resp, HttpServletRequest req,
                                String key, String msg) {
        redirect(resp, req.getContextPath() + SHIFTS_URL + "?" + key + "=" + encode(msg));
    }

<<<<<<< Updated upstream
    private void redirectSchedule(HttpServletResponse resp, HttpServletRequest req,
                                  String key, String msg) {
        redirect(resp, req.getContextPath() + SCHEDULE_URL + "&" + key + "=" + encode(msg));
    }

    private void setEncoding(HttpServletRequest req) {
        try {
            req.setCharacterEncoding("UTF-8");
        } catch (Exception e) {
            Thread.currentThread().interrupt();
        }
    }

    // ── Parse helpers ─────────────────────────────────────

=======
    // ═══════════════════════════════════════════════════════════════
    // Helpers
    // ═══════════════════════════════════════════════════════════════
>>>>>>> Stashed changes
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
        try {
            return Integer.parseInt(raw.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private float parseFloatParam(HttpServletRequest req, String name, float defaultVal) {
        String raw = req.getParameter(name);
        if (raw == null || raw.trim().isEmpty()) return defaultVal;
        try {
            return Float.parseFloat(raw.trim());
        } catch (NumberFormatException e) {
            return defaultVal;
        }
    }

    private LocalTime parseTime(String s) {
        if (s == null || s.trim().isEmpty()) return null;
        try {
            return LocalTime.parse(s.trim());
        } catch (DateTimeParseException e) {
            return null;
        }
    }

<<<<<<< Updated upstream
    private LocalDate parseDate(String s) {
        if (s == null || s.trim().isEmpty()) return null;
        try {
            return LocalDate.parse(s.trim());
        } catch (DateTimeParseException e) {
            return null;
        }
=======
    private void redirect(HttpServletResponse resp, HttpServletRequest req,
            String key, String msg) throws IOException {
        resp.sendRedirect(req.getContextPath() + "/admin/shifts?" + key + "=" + encode(msg));
>>>>>>> Stashed changes
    }

    private String encode(String s) {
        return URLEncoder.encode(s, StandardCharsets.UTF_8);
    }
}