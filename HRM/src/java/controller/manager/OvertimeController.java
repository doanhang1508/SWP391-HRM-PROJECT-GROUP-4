package controller.manager;

import dao.UserDAO;
import model.OvertimeAssignment;
import model.OvertimePlan;
import model.User;
import dao.OvertimeAssignmentDAO;
import dao.OvertimeAssignmentDAOImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.Date;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.List;

/**
 * OvertimeController — Supervisor (role 3) Overtime Operations.
 *
 * URL  : /manager/overtime
 * Role : 3 (Factory Manager / Quản đốc)
 *
 * Use Case Diagram — Actor: Supervisor:
 *   - Create Overtime Plan      → POST action=createPlan
 *   - Assign Overtime to Employees → POST action=assign  (<<include>> Validate OT Rules)
 *   - View Department OT List   → GET (default)
 *   - Approve Assigned OT       → POST action=approve   (<<include>> Update OT Status in Attendance)
 *   - Cancel Assigned OT        → POST action=cancel
 */
@WebServlet(name = "OvertimeController", urlPatterns = {"/manager/overtime"})
public class OvertimeController extends HttpServlet {

    private static final int ROLE_SUPERVISOR = 3;
    private static final String OT_URL = "/manager/overtime";

    private OvertimeAssignmentDAO overtimeService;
    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        overtimeService = new OvertimeAssignmentDAOImpl();
        userDAO = new UserDAO();
    }

    // ════════════════════════════════════════════════════════
    //  GET — View Department OT List
    // ════════════════════════════════════════════════════════
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

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
            case "viewPlan":
                viewPlanDetail(req, resp, user);
                break;
            default:
                showOvertimeDashboard(req, resp, user);
                break;
        }
    }

    // ════════════════════════════════════════════════════════
    //  POST — OT Actions
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
            case "createPlan":
                createOvertimePlan(req, resp, user);
                break;
            case "assign":
                assignOvertime(req, resp);
                break;
            case "approve":
                approveOT(req, resp);
                break;
            case "cancel":
                cancelOT(req, resp);
                break;
            case "cancelPlan":
                cancelPlan(req, resp);
                break;
            default:
                resp.sendRedirect(req.getContextPath() + OT_URL);
        }
    }

    // ════════════════════════════════════════════════════════
    //  View Department OT List
    // ════════════════════════════════════════════════════════
    private void showOvertimeDashboard(HttpServletRequest req, HttpServletResponse resp, User supervisor)
            throws ServletException, IOException {

        int deptId = supervisor.getDepartmentId();

        // OT Plans for the department
        List<OvertimePlan> plans = overtimeService.getPlansByDepartment(deptId);

        // All assignments (for the table)
        List<OvertimeAssignment> allAssignments = overtimeService.getAssignmentsByDepartment(deptId);

        // Pending assignments (for approval queue)
        List<OvertimeAssignment> pendingAssignments = overtimeService.getPendingAssignmentsByDepartment(deptId);

        // Workers in department (for assignment dropdown)
        List<User> workers = userDAO.getByDepartment(deptId);
        // Exclude the supervisor themselves from the list
        workers.removeIf(w -> w.getUserId() == supervisor.getUserId());

        req.setAttribute("plans", plans);
        req.setAttribute("allAssignments", allAssignments);
        req.setAttribute("pendingAssignments", pendingAssignments);
        req.setAttribute("workers", workers);

        req.getRequestDispatcher("/manager/overtime-management.jsp").forward(req, resp);
    }

    // ════════════════════════════════════════════════════════
    //  View Plan Detail (assignments within a plan)
    // ════════════════════════════════════════════════════════
    private void viewPlanDetail(HttpServletRequest req, HttpServletResponse resp, User supervisor)
            throws ServletException, IOException {

        Integer planId = parseIntParam(req, "planId");
        if (planId == null) {
            redirectOT(req, resp, "error", "ID kế hoạch không hợp lệ");
            return;
        }

        OvertimePlan plan = overtimeService.getPlanById(planId);
        if (plan == null || plan.getDeptId() != supervisor.getDepartmentId()) {
            redirectOT(req, resp, "error", "Kế hoạch không tồn tại hoặc không thuộc phòng ban");
            return;
        }

        List<OvertimeAssignment> assignments = overtimeService.getAssignmentsByPlan(planId);
        List<User> workers = userDAO.getByDepartment(supervisor.getDepartmentId());
        // Exclude the supervisor themselves from the list
        workers.removeIf(w -> w.getUserId() == supervisor.getUserId());

        req.setAttribute("plan", plan);
        req.setAttribute("assignments", assignments);
        req.setAttribute("workers", workers);

        // Also load dashboard data for the plan detail view
        List<OvertimePlan> plans = overtimeService.getPlansByDepartment(supervisor.getDepartmentId());
        List<OvertimeAssignment> allAssignments = overtimeService.getAssignmentsByDepartment(supervisor.getDepartmentId());
        List<OvertimeAssignment> pendingAssignments = overtimeService.getPendingAssignmentsByDepartment(supervisor.getDepartmentId());

        req.setAttribute("plans", plans);
        req.setAttribute("allAssignments", allAssignments);
        req.setAttribute("pendingAssignments", pendingAssignments);

        req.getRequestDispatcher("/manager/overtime-management.jsp").forward(req, resp);
    }

    // ════════════════════════════════════════════════════════
    //  Create Overtime Plan
    // ════════════════════════════════════════════════════════
    private void createOvertimePlan(HttpServletRequest req, HttpServletResponse resp, User supervisor)
            throws IOException {

        String dateStr = trimParam(req, "targetDate");
        String description = trimParam(req, "description");

        if (dateStr == null || dateStr.isEmpty()) {
            redirectOT(req, resp, "error", "Ngày tăng ca không được để trống");
            return;
        }
        if (description == null || description.isEmpty()) {
            redirectOT(req, resp, "error", "Mô tả kế hoạch không được để trống");
            return;
        }

        LocalDate targetDate;
        try {
            targetDate = LocalDate.parse(dateStr);
        } catch (DateTimeParseException e) {
            redirectOT(req, resp, "error", "Ngày không hợp lệ");
            return;
        }

        OvertimePlan plan = new OvertimePlan();
        plan.setDeptId(supervisor.getDepartmentId());
        plan.setSupervisorId(supervisor.getUserId());
        plan.setTargetDate(Date.valueOf(targetDate));
        plan.setDescription(description);
        plan.setStatus("Active");

        boolean ok = overtimeService.createPlan(plan);
        redirectOT(req, resp,
                ok ? "message" : "error",
                ok ? "Tạo kế hoạch tăng ca thành công" : "Tạo kế hoạch thất bại");
    }

    // ════════════════════════════════════════════════════════
    //  Assign Overtime to Employees
    //  <<include>> Validate OT Rules
    // ════════════════════════════════════════════════════════
    private void assignOvertime(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        Integer planId = parseIntParam(req, "planId");
        Integer userId = parseIntParam(req, "userId");
        String hoursStr = trimParam(req, "assignedHours");

        if (planId == null || userId == null || hoursStr == null) {
            redirectOT(req, resp, "error", "Vui lòng điền đầy đủ thông tin");
            return;
        }

        double hours;
        try {
            hours = Double.parseDouble(hoursStr);
        } catch (NumberFormatException e) {
            redirectOT(req, resp, "error", "Số giờ không hợp lệ");
            return;
        }

        OvertimeAssignment assignment = new OvertimeAssignment();
        assignment.setPlanId(planId);
        assignment.setUserId(userId);
        assignment.setAssignedHours(hours);
        assignment.setStatus("Pending");

        try {
            // <<include>> Validate OT Rules is called inside createAssignment()
            boolean ok = overtimeService.createAssignment(assignment);
            redirectOT(req, resp,
                    ok ? "message" : "error",
                    ok ? "Phân công tăng ca thành công" : "Phân công thất bại");
        } catch (Exception e) {
            redirectOT(req, resp, "error", e.getMessage());
        }
    }

    // ════════════════════════════════════════════════════════
    //  Approve Assigned OT
    //  <<include>> Update OT Status in Attendance (transactional)
    // ════════════════════════════════════════════════════════
    private void approveOT(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        Integer assignmentId = parseIntParam(req, "assignmentId");
        if (assignmentId == null) {
            redirectOT(req, resp, "error", "ID phân công không hợp lệ");
            return;
        }

        try {
            // <<include>> Update OT Status in Attendance is called inside approveOTAssignment()
            boolean ok = overtimeService.approveOTAssignment(assignmentId);
            redirectOT(req, resp,
                    ok ? "message" : "error",
                    ok ? "Duyệt tăng ca thành công — đã cập nhật bảng chấm công" : "Duyệt thất bại");
        } catch (Exception e) {
            redirectOT(req, resp, "error", e.getMessage());
        }
    }

    // ════════════════════════════════════════════════════════
    //  Cancel Assigned OT
    // ════════════════════════════════════════════════════════
    private void cancelOT(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        Integer assignmentId = parseIntParam(req, "assignmentId");
        if (assignmentId == null) {
            redirectOT(req, resp, "error", "ID phân công không hợp lệ");
            return;
        }

        boolean ok = overtimeService.cancelOTAssignment(assignmentId);
        redirectOT(req, resp,
                ok ? "message" : "error",
                ok ? "Hủy tăng ca thành công" : "Hủy thất bại");
    }

    private void cancelPlan(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        Integer planId = parseIntParam(req, "planId");
        if (planId == null) {
            redirectOT(req, resp, "error", "ID kế hoạch không hợp lệ");
            return;
        }

        boolean ok = overtimeService.cancelPlan(planId);
        redirectOT(req, resp,
                ok ? "message" : "error",
                ok ? "Hủy kế hoạch thành công" : "Hủy kế hoạch thất bại");
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

    private void redirectOT(HttpServletRequest req, HttpServletResponse resp,
                            String key, String msg) throws IOException {
        resp.sendRedirect(req.getContextPath() + OT_URL + "?" + key + "="
                + URLEncoder.encode(msg, StandardCharsets.UTF_8));
    }
}
