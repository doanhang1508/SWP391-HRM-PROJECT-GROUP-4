package controller.hr;

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
 * HrShiftScheduleController — Xếp lịch ca.
 *
 * URL : /hr/shift-schedule Role : 5 (HR Staff), 2 (HR Manager) — AuthFilter đã
 * bảo vệ /hr/*
 *
 * - HR Staff (5): xếp ca cho TẤT CẢ quản lý (Quản đốc xưởng + Trưởng phòng ban)
 * trên toàn hệ thống, giống ShiftScheduleController (/manager/shift-schedule)
 * nhưng ở phạm vi rộng hơn Supervisor. - HR Manager (2): CHỈ xếp ca cho nhân
 * viên thuộc phòng ban của chính mình (department_id = phòng Nhân sự), không có
 * quyền xếp ca cho các trưởng phòng/quản đốc khác.
 *
 * GET → hiển thị bảng lịch tuần POST ?action=assign → gán ca (date range) POST
 * ?action=delete → xoá một lịch ca đã gán
 */
@WebServlet(name = "HrShiftScheduleController", urlPatterns = {"/hr/shift-schedule"})
public class HrShiftScheduleController extends HttpServlet {

    private static final int ROLE_HR_STAFF = 5;
    private static final int ROLE_HR_MANAGER = 2;
    private static final int ROLE_DIRECTOR = 4;

    private ShiftDAO shiftService;
    private ShiftAssignmentDAO assignmentService;
    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        shiftService = new ShiftDAOImpl();
        assignmentService = new ShiftAssignmentDAOImpl();
        userDAO = new UserDAO();
    }

    // ════════════════════════════════════════════════════════
    // GET
    // ════════════════════════════════════════════════════════
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = getCurrentUser(req);
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        if (user.getRoleId() != ROLE_HR_STAFF && user.getRoleId() != ROLE_HR_MANAGER && user.getRoleId() != ROLE_DIRECTOR) {
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
    // POST
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
        if (user.getRoleId() != ROLE_HR_STAFF && user.getRoleId() != ROLE_HR_MANAGER && user.getRoleId() != ROLE_DIRECTOR) {
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
                resp.sendRedirect(req.getContextPath() + "/hr/shift-schedule");
        }
    }

    // ════════════════════════════════════════════════════════
    // Business Logic
    // ════════════════════════════════════════════════════════
    /**
     * Hiển thị bảng xếp lịch ca theo tuần. - HR Staff (5) và Director (4): thấy
     * TẤT CẢ quản lý / trưởng phòng trên toàn hệ thống. - HR Manager (2): chỉ
     * thấy nhân viên thuộc phòng ban của chính mình.
     */
    private void showSchedule(HttpServletRequest req, HttpServletResponse resp, User currentHr)
            throws ServletException, IOException {

        // Xác định tuần cần xem
        LocalDate targetDate = parseDate(req.getParameter("week"));
        if (targetDate == null) {
            targetDate = LocalDate.now();
        }
        LocalDate weekStart = targetDate.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));

        // Ma trận lịch tuần
        Map<Integer, Map<Integer, List<ShiftAssignment>>> matrix = assignmentService
                .buildWeeklyScheduleMatrix(weekStart);

        // Danh sách ca đang hoạt động
        List<Shift> activeShifts = shiftService.getActiveShifts();

        // Danh sách nhân viên được phép xếp ca, tuỳ theo vai trò
        List<User> workers;
        if (currentHr.getRoleId() == ROLE_HR_MANAGER) {
            // HR Manager: chỉ xếp ca cho nhân viên thuộc phòng ban của mình
            workers = userDAO.getByDepartment(currentHr.getDepartmentId());
            workers.removeIf(w -> w.getUserId() == currentHr.getUserId());
        } else {
            // HR Staff / Director: xếp ca cho TẤT CẢ quản lý (Factory Manager 3 + Dept Manager 6)
            workers = userDAO.getAllManagers();
        }

        // Build mảng ngày trong tuần
        LocalDate[] weekDates = new LocalDate[7];
        for (int i = 0; i < 7; i++) {
            weekDates[i] = weekStart.plusDays(i);
        }

        req.setAttribute("weekStart", weekStart);
        req.setAttribute("weekDates", weekDates);
        req.setAttribute("matrix", matrix);
        req.setAttribute("activeShifts", activeShifts);
        req.setAttribute("workers", workers);

        req.getRequestDispatcher("/hr/shift-schedule.jsp").forward(req, resp);
    }

    /**
     * Gán ca theo khoảng ngày (fromDate → toDate). HR Manager chỉ được gán cho
     * nhân viên thuộc phòng ban của mình.
     */
    private void assignShift(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        String[] userIdsRaw = req.getParameterValues("userId");
        LocalDate from = parseDate(req.getParameter("fromDate"));
        LocalDate to = parseDate(req.getParameter("toDate"));
        String otType = req.getParameter("otType");

        if (userIdsRaw == null || userIdsRaw.length == 0 || from == null || to == null || otType == null || otType.isEmpty()) {
            redirectSchedule(req, resp, "error", "Vui lòng chọn ít nhất một quản lý và điền đầy đủ thông tin");
            return;
        }

        User currentHr = getCurrentUser(req);

        // HR Manager: chặn gán ca cho người ngoài phòng ban của mình, kể cả khi bị chỉnh sửa request thủ công
        if (currentHr != null && currentHr.getRoleId() == ROLE_HR_MANAGER) {
            java.util.Set<Integer> allowedIds = new java.util.HashSet<>();
            for (User w : userDAO.getByDepartment(currentHr.getDepartmentId())) {
                if (w.getUserId() != currentHr.getUserId()) {
                    allowedIds.add(w.getUserId());
                }
            }
            java.util.List<String> filtered = new java.util.ArrayList<>();
            for (String idStr : userIdsRaw) {
                try {
                    if (allowedIds.contains(Integer.parseInt(idStr.trim()))) {
                        filtered.add(idStr.trim());
                    }
                } catch (NumberFormatException ignored) {
                }
            }
            userIdsRaw = filtered.toArray(new String[0]);
            if (userIdsRaw.length == 0) {
                redirectSchedule(req, resp, "error", "Bạn chỉ có thể xếp ca cho nhân viên thuộc phòng ban của mình");
                return;
            }
        }

        java.time.LocalTime startTime = java.time.LocalTime.of(18, 0);
        java.time.LocalTime endTime;
        java.time.LocalTime breakStart = null;
        java.time.LocalTime breakEnd = null;
        String shiftName;

        if ("2".equals(otType)) {
            endTime = java.time.LocalTime.of(20, 0);
            shiftName = "Ca Đêm 1";
        } else if ("4".equals(otType)) {
            endTime = java.time.LocalTime.of(22, 0);
            breakStart = java.time.LocalTime.of(20, 0);
            breakEnd = java.time.LocalTime.of(20, 30);
            shiftName = "Ca Đêm 2";
        } else {
            redirectSchedule(req, resp, "error", "Loại ca OT không hợp lệ");
            return;
        }

        int shiftId = shiftService.findOrCreateCustomShift(startTime, endTime, breakStart, breakEnd, shiftName);

        if (to.isBefore(from)) {
            redirectSchedule(req, resp, "error", "Ngày kết thúc phải sau ngày bắt đầu");
            return;
        }

        int totalInserted = 0;
        int successUsersCount = 0;
        int failedUsersCount = 0;

        String hrName = currentHr != null ? currentHr.getFullName() : "HR";
        String hrLabel = currentHr != null ? roleLabel(currentHr.getRoleId()) : "HR Staff";

        for (String userIdStr : userIdsRaw) {
            try {
                int userId = Integer.parseInt(userIdStr.trim());
                int inserted = assignmentService.batchAssign(userId, shiftId, from, to);
                if (inserted > 0) {
                    totalInserted += inserted;
                    successUsersCount++;
                    new dao.notificationDAO().create(userId, "shift",
                            "Bạn được xếp lịch làm việc mới",
                            hrName + " (" + hrLabel + ") đã xếp " + inserted + " ca (" + shiftName + ") cho bạn từ "
                            + from + " đến " + to + ".",
                            "/employee/schedule");
                } else {
                    failedUsersCount++;
                }
            } catch (NumberFormatException e) {
                // Ignore invalid ID
            }
        }

        if (successUsersCount > 0) {
            String msg = "Đã xếp lịch thành công cho " + successUsersCount + " người (" + totalInserted + " ca).";
            if (failedUsersCount > 0) {
                msg += " Có " + failedUsersCount + " người bị trùng lịch hoặc đã tồn tại.";
            }
            redirectSchedule(req, resp, "message", msg);
        } else {
            redirectSchedule(req, resp, "error", "Lỗi: Ca mới bị trùng giờ với ca cũ hoặc đã tồn tại cho tất cả người được chọn.");
        }
    }

    /**
     * Xoá một lịch ca đã gán. HR Manager chỉ được xoá lịch của nhân viên phòng
     * ban mình.
     */
    private void deleteAssignment(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        Integer id = parseIntParam(req, "assignmentId");
        if (id == null) {
            redirectSchedule(req, resp, "error", "ID không hợp lệ");
            return;
        }
        Integer assignedUserId = assignmentService.getAssignmentUserId(id);
        if (assignedUserId == null) {
            redirectSchedule(req, resp, "error", "Không tìm thấy lịch ca");
            return;
        }

        User currentHr = getCurrentUser(req);
        if (currentHr != null && currentHr.getRoleId() == ROLE_HR_MANAGER) {
            User assignedUser = userDAO.getUserById(assignedUserId);
            if (assignedUser == null || assignedUser.getDepartmentId() != currentHr.getDepartmentId()) {
                redirectSchedule(req, resp, "error", "Bạn chỉ có thể xóa lịch ca của nhân viên thuộc phòng ban của mình");
                return;
            }
        }

        boolean ok = assignmentService.deleteAssignment(id);
        if (ok) {
            String hrName = currentHr != null ? currentHr.getFullName() : "HR";
            String hrLabel = currentHr != null ? roleLabel(currentHr.getRoleId()) : "HR Staff";
            new dao.notificationDAO().create(assignedUserId, "shift",
                    "Lịch làm việc của bạn đã bị xóa",
                    hrName + " (" + hrLabel + ") đã xóa một lịch làm việc đã xếp cho bạn.",
                    "/employee/schedule");
        }
        redirectSchedule(req, resp, ok ? "message" : "error",
                ok ? "Xóa lịch thành công" : "Xóa lịch thất bại");
    }

    // ════════════════════════════════════════════════════════
    // Helpers
    // ════════════════════════════════════════════════════════
    private User getCurrentUser(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        return s != null ? (User) s.getAttribute("currentUser") : null;
    }

    private String roleLabel(int roleId) {
        if (roleId == ROLE_HR_MANAGER) {
            return "HR Manager";
        }
        if (roleId == ROLE_DIRECTOR) {
            return "Giám đốc";
        }
        return "HR Staff";
    }

    private String getAction(HttpServletRequest req) {
        String a = req.getParameter("action");
        return (a != null && !a.trim().isEmpty()) ? a.trim() : "schedule";
    }

    private Integer parseIntParam(HttpServletRequest req, String name) {
        String raw = req.getParameter(name);
        if (raw == null || raw.trim().isEmpty()) {
            return null;
        }
        try {
            return Integer.parseInt(raw.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private LocalDate parseDate(String s) {
        if (s == null || s.trim().isEmpty()) {
            return null;
        }
        try {
            return LocalDate.parse(s.trim());
        } catch (DateTimeParseException e) {
            return null;
        }
    }

    private void redirectSchedule(HttpServletRequest req, HttpServletResponse resp,
            String key, String msg) throws IOException {
        resp.sendRedirect(req.getContextPath() + "/hr/shift-schedule?"
                + key + "=" + java.net.URLEncoder.encode(msg, java.nio.charset.StandardCharsets.UTF_8));
    }
}
