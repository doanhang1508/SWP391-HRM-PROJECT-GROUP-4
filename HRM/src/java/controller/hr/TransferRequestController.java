package controller.hr;

import dao.DepartmentDAO;
import dao.AllowanceDAO;
import dao.PositionDAO;
import dao.RoleDAO;
import dao.TransferRequestDAO;
import dao.UserDAO;
import model.Allowance;
import model.Department;
import model.Position;
import model.Role;
import model.TransferRequest;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

// ============================================================================
// [FIX #5] Mapping vai trò – chức vụ – phòng ban dưới dạng constant rõ ràng
// Thay thế các if/else hard-code số ID trước đây
//
// Quy tắc: Khi newRoleId thuộc nhóm X, phải thuộc đúng departmentId và positionId tương ứng.
// Danh sách ID phòng ban:
//   1=Hành chính, 2=Nhân sự, 3=Kế toán, 4=Kinh doanh, 5=Xưởng sản xuất
// Danh sách ID chức vụ:
//   1=Giám đốc, 2=Trưởng phòng, 3=Phó phòng, 4=Quản đốc, 5=Tổ trưởng,
//   6=Kế toán trưởng, 7=Chuyên viên, 8=Nhân viên, 9=Công nhân
// Danh sách roleId:
//   1=Admin, 2=HR Manager, 3=Factory Manager, 4=Director, 5=HR Staff,
//   6=Department Manager, 7=Employee, 8=Accountant
// ============================================================================

@WebServlet(name = "TransferRequestController", urlPatterns = {
        "/hr/transfer-request/create",
        "/hr/transfer-request/cancel",  // [FIX #4] Endpoint mới để hủy request
        "/hr/transfer-requests"
})
public class TransferRequestController extends HttpServlet {

    // ── [FIX #5] Mapping constants — rõ tên, dễ bảo trì ────────────────────

    // Role 8 (Accountant): chỉ được ở phòng 3 (Kế toán)
    private static final int ROLE_ACCOUNTANT = 8;
    private static final int DEPT_ACCOUNTANT = 3; // Phòng Kế toán

    // Các positionId hợp lệ cho Accountant: 6=Kế toán trưởng, 7=Chuyên viên, 8=Nhân viên
    private static final int[] POS_ACCOUNTANT_VALID = {6, 7, 8};

    // Role 5 (HR Staff): chỉ được ở phòng 2 (Nhân sự)
    private static final int ROLE_HR_STAFF = 5;
    private static final int DEPT_HR_STAFF = 2; // Phòng Nhân sự

    // Các positionId hợp lệ cho HR Staff: 7=Chuyên viên, 8=Nhân viên
    private static final int[] POS_HR_STAFF_VALID = {7, 8};

    // Role 7 (Employee): tùy phòng ban
    private static final int ROLE_EMPLOYEE = 7;
    private static final int DEPT_XUONG = 5; // Phòng Xưởng sản xuất

    // Employee trong Xưởng: positionId 5=Tổ trưởng, 9=Công nhân
    private static final int[] POS_EMPLOYEE_XUONG_VALID = {5, 9};

    // Employee văn phòng (không phải Xưởng): positionId 3=Phó phòng, 7=Chuyên viên, 8=Nhân viên
    private static final int[] POS_EMPLOYEE_OFFICE_VALID = {3, 7, 8};

    // Các roleId bị cấm gán qua luồng điều chuyển thường:
    // 1=Admin, 2=HR Manager, 3=Factory Manager, 4=Director, 6=Department Manager
    private static final int[] BLOCKED_NEW_ROLE_IDS = {1, 2, 3, 4, 6};

    // roleId quản lý không được là nhân viên bị điều chuyển:
    // 1=Admin, 2=HR Manager, 3=Factory Manager, 6=Department Manager
    private static final int[] BLOCKED_CURRENT_ROLE_IDS = {1, 2, 3, 6};

    // positionId bị cấm điều chuyển: 2=Trưởng phòng
    private static final int POS_TRUONG_PHONG = 2;

    // ── DAO fields ───────────────────────────────────────────────────────────
    private final TransferRequestDAO trDAO = new TransferRequestDAO();
    private final UserDAO userDAO = new UserDAO();
    private final DepartmentDAO deptDAO = new DepartmentDAO();
    private final PositionDAO posDAO = new PositionDAO();
    private final RoleDAO roleDAO = new RoleDAO();
    private final AllowanceDAO allowanceDAO = new AllowanceDAO();

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

        // Admin (1), HR Manager (2), HR Staff (5)
        if (roleId != 1 && roleId != 2 && roleId != 5) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        String path = request.getServletPath();

        if ("/hr/transfer-request/create".equals(path)) {
            loadCreateFormData(request);
            request.getRequestDispatcher("/hr/transfer-request-create.jsp").forward(request, response);
        } else {
            // List view
            List<TransferRequest> list = trDAO.getAllTransferRequests();
            request.setAttribute("transferList", list);
            request.getRequestDispatcher("/hr/transfer-request-list.jsp").forward(request, response);
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

        // Admin (1), HR Manager (2), HR Staff (5)
        if (roleId != 1 && roleId != 2 && roleId != 5) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        String path = request.getServletPath();
        if ("/hr/transfer-request/create".equals(path)) {
            handleCreateRequest(request, response, currentUser);
        } else if ("/hr/transfer-request/cancel".equals(path)) {
            // [FIX #4] Xử lý hủy yêu cầu điều chuyển
            handleCancelRequest(request, response, currentUser);
        } else {
            response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
        }
    }

    /** Load dữ liệu cần thiết cho form tạo request */
    private void loadCreateFormData(HttpServletRequest request) {
        List<User> employees = userDAO.getActiveEmployees();
        request.setAttribute("employees", employees);
        request.setAttribute("departments", deptDAO.getAll());
        request.setAttribute("positions", posDAO.getAll());
        request.setAttribute("roles", roleDAO.getAllRoles());
        // [NEW FLOW] Phụ cấp theo phụ lục thay thế ngạch lương
        request.setAttribute("availableAllowances", allowanceDAO.getActive());
        // Ngày hiệu lực mặc định = ngày 1 của tháng sau
        LocalDate nextMonthFirstDay = LocalDate.now().plusMonths(1).withDayOfMonth(1);
        request.setAttribute("nextMonthFirstDay", nextMonthFirstDay.toString());

        // [NEW] Build JSON map {empId: {salary, allowanceIds}} để JS pre-fill form khi chọn nhân viên
        StringBuilder empSalaryJson = new StringBuilder("{");
        boolean first = true;
        for (User emp : employees) {
            int uid = emp.getUserId();
            BigDecimal salary = allowanceDAO.getActiveBaseSalaryByEmployee(uid);
            List<Integer> aIds = allowanceDAO.getActiveAllowanceIdsByEmployee(uid);

            if (!first) empSalaryJson.append(",");
            first = false;
            empSalaryJson.append("\"").append(uid).append("\": {");
            empSalaryJson.append("\"salary\": ");
            if (salary != null) empSalaryJson.append(salary.toPlainString());
            else empSalaryJson.append("null");
            empSalaryJson.append(", \"allowanceIds\": [");
            for (int i = 0; i < aIds.size(); i++) {
                if (i > 0) empSalaryJson.append(",");
                empSalaryJson.append(aIds.get(i));
            }
            empSalaryJson.append("]}");
        }
        empSalaryJson.append("}");
        request.setAttribute("empSalaryData", empSalaryJson.toString());
    }

    private void handleCreateRequest(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {

        String employeeIdStr      = request.getParameter("employeeId");
        String newDepartmentIdStr = request.getParameter("newDepartmentId");
        String newPositionIdStr   = request.getParameter("newPositionId");
        String newRoleIdStr       = request.getParameter("newRoleId");
        String reason             = request.getParameter("reason");
        // [NEW FLOW] newBaseSalary optional, effectiveDate được backend tự set
        String newBaseSalaryStr    = request.getParameter("newBaseSalary");
        String[] allowanceIdParams = request.getParameterValues("allowanceIds");

        // Reload data để hiển thị lại khi có lỗi validation
        loadCreateFormData(request);

        // ── Validate các trường bắt buộc ─────────────────────────────────────
        if (employeeIdStr == null || employeeIdStr.isEmpty() ||
            newDepartmentIdStr == null || newDepartmentIdStr.isEmpty() ||
            newPositionIdStr == null || newPositionIdStr.isEmpty() ||
            newRoleIdStr == null || newRoleIdStr.isEmpty() ||
            reason == null || reason.trim().isEmpty()) {

            request.setAttribute("errorMessage", "Vui lòng nhập đầy đủ các trường thông tin bắt buộc.");
            request.getRequestDispatcher("/hr/transfer-request-create.jsp").forward(request, response);
            return;
        }

        try {
            int employeeId      = Integer.parseInt(employeeIdStr);
            int newDepartmentId = Integer.parseInt(newDepartmentIdStr);
            int newPositionId   = Integer.parseInt(newPositionIdStr);
            int newRoleId       = Integer.parseInt(newRoleIdStr);

            // [NEW FLOW] Backend tự tính ngày hiệu lực = ngày 1 của tháng sau
            LocalDate nextMonthFirstDay = LocalDate.now().plusMonths(1).withDayOfMonth(1);
            Date effectiveDate = Date.valueOf(nextMonthFirstDay);

            // [NEW FLOW] Parse lương mới — optional (null = giữ nguyên lương hiện tại)
            BigDecimal newBaseSalary = null;
            boolean hasNewSalary = newBaseSalaryStr != null && !newBaseSalaryStr.trim().isEmpty();
            if (hasNewSalary) {
                try {
                    newBaseSalary = new BigDecimal(newBaseSalaryStr.trim());

                    if (newBaseSalary.compareTo(BigDecimal.ZERO) <= 0) {
                        request.setAttribute("errorMessage", "Mức lương cơ bản mới phải lớn hơn 0.");
                        request.getRequestDispatcher("/hr/transfer-request-create.jsp").forward(request, response);
                        return;
                    }
                } catch (NumberFormatException e2) {
                    request.setAttribute("errorMessage", "Lương cơ bản mới không đúng định dạng số.");
                    request.getRequestDispatcher("/hr/transfer-request-create.jsp").forward(request, response);
                    return;
                }
            }

            // [NEW FLOW] Parse allowanceIds — list rỗng nếu không chọn
            List<Integer> allowanceIds = new ArrayList<>();
            if (allowanceIdParams != null) {
                for (String idStr : allowanceIdParams) {
                    try {
                        int aid = Integer.parseInt(idStr.trim());
                        if (aid > 0) allowanceIds.add(aid);
                    } catch (NumberFormatException ignored) {}
                }
            }

            User employee = userDAO.getUserById(employeeId);

            // 1. Nhân viên phải đang active
            if (employee == null || employee.getStatus() != 1) {
                request.setAttribute("errorMessage", "Nhân viên không tồn tại hoặc đã nghỉ việc.");
                request.getRequestDispatcher("/hr/transfer-request-create.jsp").forward(request, response);
                return;
            }

            // 2. Không điều chuyển nhân viên thuộc nhóm quản lý cấp cao
            int currentRole = employee.getRoleId();
            int currentPos  = employee.getPositionId();
            if (containsId(BLOCKED_CURRENT_ROLE_IDS, currentRole) || currentPos == POS_TRUONG_PHONG) {
                request.setAttribute("errorMessage", "Nhân viên thuộc nhóm quản lý hoặc có vai trò đặc biệt không được phép điều chuyển bằng phiếu này.");
                request.getRequestDispatcher("/hr/transfer-request-create.jsp").forward(request, response);
                return;
            }

            // 3. Không có request đang xử lý cho nhân viên này
            if (trDAO.hasPendingOrInProgressRequest(employeeId)) {
                request.setAttribute("errorMessage", "Nhân viên đã có một yêu cầu điều chuyển đang trong quá trình xử lý (chờ xác nhận hoặc duyệt).");
                request.getRequestDispatcher("/hr/transfer-request-create.jsp").forward(request, response);
                return;
            }

            // 4. Phòng ban, chức vụ, vai trò mới phải tồn tại trong DB
            List<Department> departments = deptDAO.getAll();
            List<Position>   positions   = posDAO.getAll();
            List<Role>       roles       = roleDAO.getAllRoles();
            boolean deptExists = false, posExists = false, roleExists = false;
            for (Department d : departments) if (d.getDepartmentId() == newDepartmentId) { deptExists = true; break; }
            for (Position p  : positions)   if (p.getPositionId()   == newPositionId)   { posExists  = true; break; }
            for (Role r      : roles)       if (r.getRoleId()       == newRoleId)       { roleExists = true; break; }
            if (!deptExists || !posExists || !roleExists) {
                request.setAttribute("errorMessage", "Phòng ban, chức vụ hoặc vai trò mới được chọn không hợp lệ.");
                request.getRequestDispatcher("/hr/transfer-request-create.jsp").forward(request, response);
                return;
            }

            // 5. Thông tin mới phải khác với hiện tại (ít nhất 1 trong 3)
            if (employee.getDepartmentId() == newDepartmentId
                    && employee.getPositionId() == newPositionId
                    && employee.getRoleId() == newRoleId) {
                request.setAttribute("errorMessage", "Thông tin phòng ban, chức vụ và vai trò mới trùng khớp hoàn toàn với hiện tại.");
                request.getRequestDispatcher("/hr/transfer-request-create.jsp").forward(request, response);
                return;
            }

            // 6. [FIX #5] Không được gán role cấp cao qua luồng điều chuyển này
            if (containsId(BLOCKED_NEW_ROLE_IDS, newRoleId)) {
                request.setAttribute("errorMessage", "Không thể phân quyền Admin hoặc Quản lý cho nhân viên qua luồng điều chuyển này.");
                request.getRequestDispatcher("/hr/transfer-request-create.jsp").forward(request, response);
                return;
            }

            // 7. [FIX #5] Không điều chuyển lên Trưởng phòng
            if (newPositionId == POS_TRUONG_PHONG) {
                request.setAttribute("errorMessage", "Không thể điều chuyển nhân viên lên làm Trưởng phòng qua luồng này.");
                request.getRequestDispatcher("/hr/transfer-request-create.jsp").forward(request, response);
                return;
            }

            // 8. [FIX #5] Validate mapping role–position–department
            if (!isValidRoleDeptPosMapping(newRoleId, newDepartmentId, newPositionId)) {
                request.setAttribute("errorMessage", "Vai trò mới được chọn không phù hợp với chức vụ hoặc phòng ban mới.");
                request.getRequestDispatcher("/hr/transfer-request-create.jsp").forward(request, response);
                return;
            }

            // Tạo đối tượng request
            TransferRequest req = new TransferRequest();
            req.setEmployeeId(employeeId);
            req.setOldDepartmentId(employee.getDepartmentId());
            req.setOldPositionId(employee.getPositionId());
            req.setOldRoleId(employee.getRoleId());
            req.setNewDepartmentId(newDepartmentId);
            req.setNewPositionId(newPositionId);
            req.setNewRoleId(newRoleId);
            req.setReason(reason.trim());
            req.setEffectiveDate(effectiveDate);
            req.setRequestedBy(currentUser.getUserId());
            // [NEW FLOW] Chỉ set lương mới nếu có; không dùng newSalaryGradeId nữa
            req.setNewBaseSalary(newBaseSalary);

            boolean success = trDAO.createTransferRequestWithAllowances(req, allowanceIds);
            if (success) {
                // [NEW FLOW] Gửi notification cho Nhân viên được điều chuyển
                int newRequestId = trDAO.getLatestRequestIdForEmployee(employeeId);
                if (newRequestId > 0) {
                    trDAO.sendEmployeeNotificationOnCreate(newRequestId, employeeId, employee.getFullName());
                }
                response.sendRedirect(request.getContextPath() + "/hr/transfer-requests?msg=create_success");
            } else {
                request.setAttribute("errorMessage", "Có lỗi xảy ra khi tạo yêu cầu điều chuyển. Vui lòng thử lại.");
                request.getRequestDispatcher("/hr/transfer-request-create.jsp").forward(request, response);
            }

        } catch (IllegalArgumentException e) {
            request.setAttribute("errorMessage", "Định dạng số không hợp lệ.");
            request.getRequestDispatcher("/hr/transfer-request-create.jsp").forward(request, response);
        }
    }



    /**
     * [FIX #4] Xử lý hủy yêu cầu điều chuyển PENDING.
     * Chỉ cho phép:
     *   - Người tạo request (HR Staff/Manager đã tạo) hủy request của mình
     *   - Admin (roleId=1) hoặc HR Manager (roleId=2) hủy bất kỳ request PENDING
     */
    private void handleCancelRequest(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {
        String requestIdStr = request.getParameter("requestId");
        if (requestIdStr == null || requestIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/hr/transfer-requests?msg=cancel_error");
            return;
        }

        try {
            int requestId = Integer.parseInt(requestIdStr);
            boolean success = trDAO.cancelTransferRequest(requestId, currentUser.getUserId(), currentUser.getRoleId());
            if (success) {
                response.sendRedirect(request.getContextPath() + "/hr/transfer-requests?msg=cancel_success");
            } else {
                // Thất bại: có thể request không còn PENDING hoặc không có quyền
                response.sendRedirect(request.getContextPath() + "/hr/transfer-requests?msg=cancel_error");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/hr/transfer-requests?msg=cancel_error");
        }
    }

    // ── [FIX #5] Helper methods thay thế if/else hard-code ──────────────────

    /**
     * Kiểm tra xem một ID có nằm trong mảng không.
     */
    private boolean containsId(int[] arr, int id) {
        for (int v : arr) if (v == id) return true;
        return false;
    }

    /**
     * [FIX #5] Kiểm tra mapping hợp lệ giữa role mới, phòng ban mới, chức vụ mới.
     * Dùng constant có comment tên rõ ràng thay vì hard-code số ID rải rác.
     */
    private boolean isValidRoleDeptPosMapping(int newRoleId, int newDepartmentId, int newPositionId) {
        if (newRoleId == ROLE_ACCOUNTANT) {
            // Accountant chỉ được ở phòng Kế toán với các chức vụ tương ứng
            return newDepartmentId == DEPT_ACCOUNTANT && containsId(POS_ACCOUNTANT_VALID, newPositionId);
        } else if (newRoleId == ROLE_HR_STAFF) {
            // HR Staff chỉ được ở phòng Nhân sự với các chức vụ tương ứng
            return newDepartmentId == DEPT_HR_STAFF && containsId(POS_HR_STAFF_VALID, newPositionId);
        } else if (newRoleId == ROLE_EMPLOYEE) {
            if (newDepartmentId == DEPT_XUONG) {
                // Employee trong Xưởng: Tổ trưởng (5) hoặc Công nhân (9)
                return containsId(POS_EMPLOYEE_XUONG_VALID, newPositionId);
            } else {
                // Employee văn phòng: Phó phòng (3), Chuyên viên (7), Nhân viên (8)
                return containsId(POS_EMPLOYEE_OFFICE_VALID, newPositionId);
            }
        }
        // Nếu roleId không thuộc các nhóm đã kiểm tra → mặc định cho phép
        // (các role bị chặn đã được validate ở bước trước)
        return true;
    }
}
