package controller.hr;

import model.Department;
import model.DepartmentShift;
import model.Shift;
import model.User;
import dao.DepartmentDAO;
import dao.ShiftDAO;
import dao.ShiftDAOImpl;

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
 * ShiftController â€” Manages SHIFT DEFINITIONS and DEPARTMENT-SHIFT MAPPING.
 *
 * URL  : /hr/shifts
 * Role : 2 (HR Manager) â€” HR Manager táº¡o/sá»­a/xoÃ¡/toggle ca; gÃ¡n ca máº·c Ä‘á»‹nh cho phÃ²ng ban.
 *
 * Use Case Diagram:
 *   Actor: HR Manager
 *   - Create Shift         â†’ POST action=create   (<<include>> Validate, <<extend>> AutoDetect)
 *   - Edit Shift           â†’ POST action=update   (<<include>> Validate, <<extend>> AutoDetect)
 *   - Activate/Deactivate  â†’ POST action=toggleStatus
 *   - Assign Default to Dept â†’ POST action=assignDept
 *   - View Shift List      â†’ GET (default)
 *
 * Viá»‡c Xáº¾P CA (gÃ¡n ca cho cÃ´ng nhÃ¢n) thuá»™c vá» Supervisor (role 3),
 * Ä‘Æ°á»£c xá»­ lÃ½ bá»Ÿi controller.manager.ShiftScheduleController (/manager/shift-schedule).
 */
@WebServlet(name = "ShiftController", urlPatterns = {"/hr/shifts"})
public class ShiftController extends HttpServlet {

    private static final String ATTR_ERROR     = "error";
    private static final String ATTR_MESSAGE   = "message";
    private static final String PARAM_SHIFT_ID = "shiftId";
    private static final String INVALID_ID     = "ID không hợp lệ";
    private static final String SHIFTS_URL     = "/hr/shifts";

    private ShiftDAO shiftService;
    private DepartmentDAO departmentDAO;

    @Override
    public void init() throws ServletException {
        shiftService = new ShiftDAOImpl();
        departmentDAO = new DepartmentDAO();
    }

    // 
    // HTTP Handlers
    // 

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = getLoginUser(req);
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // Only HR Manager (role 2), HR Staff (role 5), and Admin (role 1) can define shifts
        if (user.getRoleId() != 2 && user.getRoleId() != 1 && user.getRoleId() != 5) {
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

        // Only HR Manager (role 2), HR Staff (role 5) and Admin (role 1)
        if (user.getRoleId() != 2 && user.getRoleId() != 1 && user.getRoleId() != 5) {
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
            case "assignDept":
                assignDeptShift(req, resp);
                break;
            case "removeDeptShift":
                removeDeptShift(req, resp);
                break;
            default:
                resp.sendRedirect(req.getContextPath() + SHIFTS_URL);
                break;
        }
    }

    // 
    // View Shift List (with Department Shift mapping data)
    // 

    private void listShifts(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        List<Shift> shifts = shiftService.getAllShifts();
        double[]    hours      = new double[shifts.size()];
        boolean[]   nightFlags = new boolean[shifts.size()];

        for (int i = 0; i < shifts.size(); i++) {
            hours[i]      = shiftService.calculateTotalWorkingHours(shifts.get(i));
            nightFlags[i] = shiftService.isNightShift(shifts.get(i));
        }

        // Department Shift mapping data
        List<DepartmentShift> deptShifts = shiftService.getAllDepartmentShifts();
        List<Department> departments = departmentDAO.getAll();
        List<Shift> activeShifts = shiftService.getActiveShifts();

        req.setAttribute("shifts",       shifts);
        req.setAttribute("workingHours", hours);
        req.setAttribute("nightShifts",  nightFlags);
        req.setAttribute("deptShifts",   deptShifts);
        req.setAttribute("departments",  departments);
        req.setAttribute("activeShifts", activeShifts);
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
            redirect(resp, req, ATTR_ERROR, "Không tìm thấy ca");
            return;
        }

        req.setAttribute("editShift", s);
        listShifts(req, resp);
    }

    // 
    // Create Shift
    // Invokes: <<include>> Validate Shift Data
    //          <<extend>>  Auto Detect Night Shift
    // 

    private void createShift(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        Shift s = buildShiftFromRequest(req);
        if (s == null) {
            redirect(resp, req, ATTR_ERROR, "Dữ liệu không hợp lệ");
            return;
        }
        s.setStatus(1);

        // <<include>> Validate Shift Data
        String validationError = shiftService.validateShiftData(s, 0);
        if (validationError != null) {
            redirect(resp, req, ATTR_ERROR, validationError);
            return;
        }

        // <<extend>> Auto Detect Night Shift
        shiftService.autoDetectNightShift(s);

        boolean ok = shiftService.addShift(s);
        redirect(resp, req,
                ok ? ATTR_MESSAGE : ATTR_ERROR,
                ok ? "Thêm ca làm việc thành công" : "Thêm ca thất bại");
    }

    // -------------------------------------------------------------------------
    // Edit Shift
    // Invokes: <<include>> Validate Shift Data
    //          <<extend>>  Auto Detect Night Shift
    // -------------------------------------------------------------------------

    private void updateShift(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        Integer id = parseIntParam(req, PARAM_SHIFT_ID);
        if (id == null) {
            redirect(resp, req, ATTR_ERROR, INVALID_ID);
            return;
        }

        Shift existing = shiftService.getShiftById(id);
        if (existing == null) {
            redirect(resp, req, ATTR_ERROR, "Không tìm thấy ca");
            return;
        }

        // Build updated shift from request
        Shift updated = buildShiftFromRequest(req);
        if (updated == null) {
            redirect(resp, req, ATTR_ERROR, "Dữ liệu không hợp lệ");
            return;
        }
        updated.setShiftId(id);
        updated.setStatus(existing.getStatus());

        // <<include>> Validate Shift Data
        String validationError = shiftService.validateShiftData(updated, id);
        if (validationError != null) {
            redirect(resp, req, ATTR_ERROR, validationError);
            return;
        }

        // <<extend>> Auto Detect Night Shift
        shiftService.autoDetectNightShift(updated);

        boolean ok = shiftService.updateShift(updated);
        redirect(resp, req,
                ok ? ATTR_MESSAGE : ATTR_ERROR,
                ok ? "Cập nhật ca thành công" : "Cập nhật thất bại");
    }

    // -------------------------------------------------------------------------
    // Activate / Deactivate Shift (Toggle status)
    // -------------------------------------------------------------------------

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
                ok ? "Cập nhật trạng thái thành công" : "Cập nhật trạng thái thất bại");
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
                ok ? "Xóa ca thành công" : "Xóa thất bại");
    }

    // -------------------------------------------------------------------------
    // Assign Default Shift to Department
    // -------------------------------------------------------------------------

    private void assignDeptShift(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        Integer deptId = parseIntParam(req, "departmentId");
        Integer shiftId = parseIntParam(req, "shiftId");

        if (deptId == null || shiftId == null) {
            redirect(resp, req, ATTR_ERROR, "Vui lòng chọn phòng ban và ca làm việc");
            return;
        }

        boolean ok = shiftService.assignDefaultShiftToDepartment(deptId, shiftId);
        redirect(resp, req,
                ok ? ATTR_MESSAGE : ATTR_ERROR,
                ok ? "Gán ca mặc định cho phòng ban thành công" : "Ca này đã được gán cho phòng ban hoặc có lỗi xảy ra");
    }

    private void removeDeptShift(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        Integer id = parseIntParam(req, "deptShiftId");
        if (id == null) {
            redirect(resp, req, ATTR_ERROR, INVALID_ID);
            return;
        }
        boolean ok = shiftService.removeDepartmentShift(id);
        redirect(resp, req,
                ok ? ATTR_MESSAGE : ATTR_ERROR,
                ok ? "Xóa ca mặc định thành công" : "Xóa thất bại");
    }

    // -------------------------------------------------------------------------
    // Builders
    // -------------------------------------------------------------------------

    private Shift buildShiftFromRequest(HttpServletRequest req) {
        String name = trimParam(req, "shiftName");
        LocalTime start = parseTime(trimParam(req, "startTime"));
        LocalTime end   = parseTime(trimParam(req, "endTime"));

        if (name == null || start == null || end == null) {
            return null;
        }

        Shift s = new Shift();
        s.setShiftName(name.trim());
        s.setStartTime(start);
        s.setEndTime(end);
        s.setBreakStart(parseTime(trimParam(req, "breakStart")));
        s.setBreakEnd(parseTime(trimParam(req, "breakEnd")));
        s.setNightShift("on".equals(req.getParameter("isNightShift")));
        s.setCoefficient(parseFloatParam(req, "coefficient", 1.0f));
        return s;
    }

    // 
    // Helpers
    // 

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
        req.getSession().setAttribute(key, msg);
        resp.sendRedirect(req.getContextPath() + SHIFTS_URL);
    }

    private void setEncoding(HttpServletRequest req) {
        try {
            req.setCharacterEncoding("UTF-8");
        } catch (java.io.UnsupportedEncodingException e) {
            System.err.println("Encoding error: " + e.getMessage());
        }
    }


}


