package controller.hr;

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
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalTime;
import java.time.format.DateTimeParseException;
import java.util.List;

/**
 * ShiftController — Chỉ quản lý ĐỊNH NGHĨA ca làm việc (CRUD).
 *
 * URL  : /admin/shifts
 * Role : 2 (HR Manager) — HR Manager tạo/sửa/xóa định nghĩa ca (tên, giờ giấc, bậc công).
 *
 * Việc XẾP CA (gán ca cho công nhân) thuộc về Supervisor (role 3),
 * được xử lý bởi controller.manager.ShiftScheduleController (/manager/shift-schedule).
 */
@WebServlet(name = "ShiftController", urlPatterns = {"/hr/shifts"})
public class ShiftController extends HttpServlet {

    private static final String ATTR_ERROR     = "error";
    private static final String ATTR_MESSAGE   = "message";
    private static final String PARAM_SHIFT_ID = "shiftId";
    private static final String INVALID_ID     = "ID khong hop le";
    private static final String SHIFTS_URL     = "/hr/shifts";

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
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

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
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        setEncoding(req);
        User user = getLoginUser(req);
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

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
                resp.sendRedirect(req.getContextPath() + SHIFTS_URL);
                break;
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // Shift CRUD
    // ═══════════════════════════════════════════════════════════════

    private void listShifts(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        List<Shift> shifts = shiftService.getAllShifts();
        double[]    hours      = new double[shifts.size()];
        boolean[]   nightFlags = new boolean[shifts.size()];

        for (int i = 0; i < shifts.size(); i++) {
            hours[i]      = shiftService.calculateTotalWorkingHours(shifts.get(i));
            nightFlags[i] = shiftService.isNightShift(shifts.get(i));
        }

        req.setAttribute("shifts",       shifts);
        req.setAttribute("workingHours", hours);
        req.setAttribute("nightShifts",  nightFlags);
        req.getRequestDispatcher("/hr/shift-list.jsp").forward(req, resp);
    }

    private void showEditForm(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Integer id = parseIntParam(req, PARAM_SHIFT_ID);
        if (id == null) {
            redirect(resp, req, ATTR_ERROR, INVALID_ID);
            return;
        }

        Shift s = shiftService.getShiftById(id);
        if (s == null) {
            redirect(resp, req, ATTR_ERROR, "Khong tim thay ca");
            return;
        }

        req.setAttribute("editShift", s);
        listShifts(req, resp);
    }

    private void createShift(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        String name = trimParam(req, "shiftName");
        if (name == null || name.isEmpty()) {
            redirect(resp, req, ATTR_ERROR, "Ten ca khong duoc de trong");
            return;
        }
        if (name.length() > 50) {
            redirect(resp, req, ATTR_ERROR, "Ten ca khong vuot qua 50 ky tu");
            return;
        }
        if (shiftService.isShiftNameExists(name, 0)) {
            redirect(resp, req, ATTR_ERROR, "Ten ca da ton tai");
            return;
        }

        LocalTime start = parseTime(trimParam(req, "startTime"));
        LocalTime end   = parseTime(trimParam(req, "endTime"));
        if (start == null || end == null) {
            redirect(resp, req, ATTR_ERROR, "Gio bat dau va ket thuc la bat buoc");
            return;
        }

        Shift s = buildShift(req, new Shift(), name, start, end);
        s.setStatus(1);

        boolean ok = shiftService.addShift(s);
        redirect(resp, req,
                ok ? ATTR_MESSAGE : ATTR_ERROR,
                ok ? "Them ca lam viec thanh cong" : "Them ca that bai");
    }

    private void updateShift(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        Integer id = parseIntParam(req, PARAM_SHIFT_ID);
        if (id == null) {
            redirect(resp, req, ATTR_ERROR, INVALID_ID);
            return;
        }

        Shift existing = shiftService.getShiftById(id);
        if (existing == null) {
            redirect(resp, req, ATTR_ERROR, "Khong tim thay ca");
            return;
        }

        String name = trimParam(req, "shiftName");
        if (name == null || name.isEmpty()) {
            redirect(resp, req, ATTR_ERROR, "Ten ca khong duoc de trong");
            return;
        }
        if (shiftService.isShiftNameExists(name, id)) {
            redirect(resp, req, ATTR_ERROR, "Ten ca da ton tai");
            return;
        }

        LocalTime start = parseTime(trimParam(req, "startTime"));
        LocalTime end   = parseTime(trimParam(req, "endTime"));
        if (start == null || end == null) {
            redirect(resp, req, ATTR_ERROR, "Gio bat dau va ket thuc la bat buoc");
            return;
        }

        buildShift(req, existing, name, start, end);
        existing.setCoefficient(parseFloatParam(req, "coefficient", existing.getCoefficient()));

        boolean ok = shiftService.updateShift(existing);
        redirect(resp, req,
                ok ? ATTR_MESSAGE : ATTR_ERROR,
                ok ? "Cap nhat ca thanh cong" : "Cap nhat that bai");
    }

    private void deleteShift(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        Integer id = parseIntParam(req, PARAM_SHIFT_ID);
        if (id == null) {
            redirect(resp, req, ATTR_ERROR, INVALID_ID);
            return;
        }
        boolean ok = shiftService.deleteShift(id);
        redirect(resp, req,
                ok ? ATTR_MESSAGE : ATTR_ERROR,
                ok ? "Xoa ca thanh cong" : "Xoa that bai");
    }

    private void toggleStatus(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        Integer id = parseIntParam(req, PARAM_SHIFT_ID);
        if (id == null) {
            redirect(resp, req, ATTR_ERROR, INVALID_ID);
            return;
        }
        boolean ok = shiftService.toggleShiftStatus(id);
        redirect(resp, req,
                ok ? ATTR_MESSAGE : ATTR_ERROR,
                ok ? "Cap nhat trang thai thanh cong" : "Cap nhat trang thai that bai");
    }

    // ═══════════════════════════════════════════════════════════════
    // Builders
    // ═══════════════════════════════════════════════════════════════

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

    private void redirect(HttpServletResponse resp, HttpServletRequest req,
            String key, String msg) throws IOException {
        resp.sendRedirect(req.getContextPath() + SHIFTS_URL + "?" + key + "=" + encode(msg));
    }

    private void setEncoding(HttpServletRequest req) {
        try {
            req.setCharacterEncoding("UTF-8");
        } catch (Exception e) {
            Thread.currentThread().interrupt();
        }
    }

    private String encode(String s) {
        return URLEncoder.encode(s, StandardCharsets.UTF_8);
    }
}