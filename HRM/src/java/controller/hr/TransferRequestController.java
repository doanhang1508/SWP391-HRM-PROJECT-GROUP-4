package controller.hr;

import dao.DepartmentDAO;
import dao.PositionDAO;
import dao.RoleDAO;
import dao.TransferRequestDAO;
import dao.UserDAO;
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
import java.sql.Date;
import java.time.LocalDate;
import java.util.List;

@WebServlet(name = "TransferRequestController", urlPatterns = {
        "/hr/transfer-request/create",
        "/hr/transfer-requests"
})
public class TransferRequestController extends HttpServlet {

    private final TransferRequestDAO trDAO = new TransferRequestDAO();
    private final UserDAO userDAO = new UserDAO();
    private final DepartmentDAO deptDAO = new DepartmentDAO();
    private final PositionDAO posDAO = new PositionDAO();
    private final RoleDAO roleDAO = new RoleDAO();

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
            // Load lists
            List<User> employees = userDAO.getActiveEmployees();
            List<Department> departments = deptDAO.getAll();
            List<Position> positions = posDAO.getAll();
            List<Role> roles = roleDAO.getAllRoles();

            request.setAttribute("employees", employees);
            request.setAttribute("departments", departments);
            request.setAttribute("positions", positions);
            request.setAttribute("roles", roles);

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
        } else {
            response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
        }
    }

    private void handleCreateRequest(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {

        String employeeIdStr = request.getParameter("employeeId");
        String newDepartmentIdStr = request.getParameter("newDepartmentId");
        String newPositionIdStr = request.getParameter("newPositionId");
        String newRoleIdStr = request.getParameter("newRoleId");
        String reason = request.getParameter("reason");
        String effectiveDateStr = request.getParameter("effectiveDate");

        // Reload data just in case of validation failure
        List<User> employees = userDAO.getActiveEmployees();
        List<Department> departments = deptDAO.getAll();
        List<Position> positions = posDAO.getAll();
        List<Role> roles = roleDAO.getAllRoles();
        request.setAttribute("employees", employees);
        request.setAttribute("departments", departments);
        request.setAttribute("positions", positions);
        request.setAttribute("roles", roles);

        // Validation
        if (employeeIdStr == null || employeeIdStr.isEmpty() ||
            newDepartmentIdStr == null || newDepartmentIdStr.isEmpty() ||
            newPositionIdStr == null || newPositionIdStr.isEmpty() ||
            newRoleIdStr == null || newRoleIdStr.isEmpty() ||
            reason == null || reason.trim().isEmpty() ||
            effectiveDateStr == null || effectiveDateStr.isEmpty()) {
            
            request.setAttribute("errorMessage", "Vui lòng nhập đầy đủ các trường thông tin bắt buộc.");
            request.getRequestDispatcher("/hr/transfer-request-create.jsp").forward(request, response);
            return;
        }

        try {
            int employeeId = Integer.parseInt(employeeIdStr);
            int newDepartmentId = Integer.parseInt(newDepartmentIdStr);
            int newPositionId = Integer.parseInt(newPositionIdStr);
            int newRoleId = Integer.parseInt(newRoleIdStr);
            Date effectiveDate = Date.valueOf(effectiveDateStr);

            User employee = userDAO.getUserById(employeeId);
            
            // 1. Employee must be active
            if (employee == null || employee.getStatus() != 1) {
                request.setAttribute("errorMessage", "Nhân viên không tồn tại hoặc đã nghỉ việc.");
                request.getRequestDispatcher("/hr/transfer-request-create.jsp").forward(request, response);
                return;
            }

            // 2. Employee must NOT be Admin, HR Manager, Department Manager, Factory Manager or Trưởng phòng (positionId = 2)
            int currentRole = employee.getRoleId();
            int currentPos = employee.getPositionId();
            if (currentRole == 1 || currentRole == 2 || currentRole == 3 || currentRole == 6 || currentPos == 2) {
                request.setAttribute("errorMessage", "Nhân viên thuộc nhóm quản lý hoặc có vai trò đặc biệt không được phép điều chuyển bằng phiếu này.");
                request.getRequestDispatcher("/hr/transfer-request-create.jsp").forward(request, response);
                return;
            }

            // Check if effective date is in the past
            LocalDate today = LocalDate.now();
            if (effectiveDate.toLocalDate().isBefore(today)) {
                request.setAttribute("errorMessage", "Ngày hiệu lực không được nhỏ hơn ngày hôm nay.");
                request.getRequestDispatcher("/hr/transfer-request-create.jsp").forward(request, response);
                return;
            }

            // 3. Employee must NOT have another transfer request PENDING
            if (trDAO.hasPendingRequest(employeeId)) {
                request.setAttribute("errorMessage", "Nhân viên đã có một yêu cầu điều chuyển đang chờ duyệt.");
                request.getRequestDispatcher("/hr/transfer-request-create.jsp").forward(request, response);
                return;
            }

            // 4. New department, position, role must exist
            boolean deptExists = false;
            for (Department d : departments) {
                if (d.getDepartmentId() == newDepartmentId) {
                    deptExists = true;
                    break;
                }
            }
            boolean posExists = false;
            for (Position p : positions) {
                if (p.getPositionId() == newPositionId) {
                    posExists = true;
                    break;
                }
            }
            boolean roleExists = false;
            for (Role r : roles) {
                if (r.getRoleId() == newRoleId) {
                    roleExists = true;
                    break;
                }
            }

            if (!deptExists || !posExists || !roleExists) {
                request.setAttribute("errorMessage", "Phòng ban, chức vụ hoặc vai trò mới được chọn không hợp lệ.");
                request.getRequestDispatcher("/hr/transfer-request-create.jsp").forward(request, response);
                return;
            }

            // 5. Department/position/role new must NOT be identical to current
            if (employee.getDepartmentId() == newDepartmentId && employee.getPositionId() == newPositionId && employee.getRoleId() == newRoleId) {
                request.setAttribute("errorMessage", "Thông tin phòng ban, chức vụ và vai trò mới trùng khớp hoàn toàn với hiện tại.");
                request.getRequestDispatcher("/hr/transfer-request-create.jsp").forward(request, response);
                return;
            }

            // 6. New role must NOT be Admin (1), HR Manager (2), Department Manager (6), Factory Manager (3) (and block Director 4 too)
            if (newRoleId == 1 || newRoleId == 2 || newRoleId == 3 || newRoleId == 4 || newRoleId == 6) {
                request.setAttribute("errorMessage", "Không thể phân quyền Admin hoặc Quản lý cho nhân viên qua luồng điều chuyển này.");
                request.getRequestDispatcher("/hr/transfer-request-create.jsp").forward(request, response);
                return;
            }

            // 6b. New position must NOT be Trưởng phòng (2)
            if (newPositionId == 2) {
                request.setAttribute("errorMessage", "Không thể điều chuyển nhân viên lên làm Trưởng phòng.");
                request.getRequestDispatcher("/hr/transfer-request-create.jsp").forward(request, response);
                return;
            }

            // 7. Validate position-role mapping
            boolean isValidMapping = true;
            if (newRoleId == 8) { // Accountant
                if (newDepartmentId != 3 || (newPositionId != 6 && newPositionId != 7 && newPositionId != 8)) {
                    isValidMapping = false;
                }
            } else if (newRoleId == 5) { // HR Staff
                if (newDepartmentId != 2 || (newPositionId != 7 && newPositionId != 8)) {
                    isValidMapping = false;
                }
            } else if (newRoleId == 7) { // Employee
                if (newDepartmentId == 5) { // Xưởng
                    if (newPositionId != 5 && newPositionId != 9) {
                        isValidMapping = false;
                    }
                } else { // Office
                    if (newPositionId != 3 && newPositionId != 7 && newPositionId != 8) {
                        isValidMapping = false;
                    }
                }
            }

            if (!isValidMapping) {
                request.setAttribute("errorMessage", "Vai trò mới được chọn không phù hợp với chức vụ hoặc phòng ban mới.");
                request.getRequestDispatcher("/hr/transfer-request-create.jsp").forward(request, response);
                return;
            }

            // Create request model
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

            boolean success = trDAO.createTransferRequest(req);
            if (success) {
                response.sendRedirect(request.getContextPath() + "/hr/transfer-requests?msg=create_success");
            } else {
                request.setAttribute("errorMessage", "Có lỗi xảy ra khi tạo yêu cầu điều chuyển. Vui lòng thử lại.");
                request.getRequestDispatcher("/hr/transfer-request-create.jsp").forward(request, response);
            }

        } catch (IllegalArgumentException e) {
            request.setAttribute("errorMessage", "Định dạng ngày hiệu lực không hợp lệ.");
            request.getRequestDispatcher("/hr/transfer-request-create.jsp").forward(request, response);
        }
    }
}
