package controller.hr;

import dao.DepartmentDAO;
import dao.PositionDAO;
import dao.TransferRequestDAO;
import dao.UserDAO;
import model.Department;
import model.Position;
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

            request.setAttribute("employees", employees);
            request.setAttribute("departments", departments);
            request.setAttribute("positions", positions);

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
        String reason = request.getParameter("reason");
        String effectiveDateStr = request.getParameter("effectiveDate");

        // Reload data just in case of validation failure
        List<User> employees = userDAO.getActiveEmployees();
        List<Department> departments = deptDAO.getAll();
        List<Position> positions = posDAO.getAll();
        request.setAttribute("employees", employees);
        request.setAttribute("departments", departments);
        request.setAttribute("positions", positions);

        // Validation
        if (employeeIdStr == null || employeeIdStr.isEmpty() ||
            newDepartmentIdStr == null || newDepartmentIdStr.isEmpty() ||
            newPositionIdStr == null || newPositionIdStr.isEmpty() ||
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
            Date effectiveDate = Date.valueOf(effectiveDateStr);

            User employee = userDAO.getUserById(employeeId);
            if (employee == null || employee.getStatus() != 1) {
                request.setAttribute("errorMessage", "Nhân viên không tồn tại hoặc đã nghỉ việc.");
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

            // Check duplicate pending request
            if (trDAO.hasPendingRequest(employeeId)) {
                request.setAttribute("errorMessage", "Nhân viên đã có một yêu cầu điều chuyển đang chờ duyệt.");
                request.getRequestDispatcher("/hr/transfer-request-create.jsp").forward(request, response);
                return;
            }

            // Check identical dept & pos
            if (employee.getDepartmentId() == newDepartmentId && employee.getPositionId() == newPositionId) {
                request.setAttribute("errorMessage", "Phòng ban và chức vụ mới giống hoàn toàn hiện tại.");
                request.getRequestDispatcher("/hr/transfer-request-create.jsp").forward(request, response);
                return;
            }

            // Check if new department and position exist in database
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

            if (!deptExists || !posExists) {
                request.setAttribute("errorMessage", "Phòng ban hoặc chức vụ được chọn không hợp lệ.");
                request.getRequestDispatcher("/hr/transfer-request-create.jsp").forward(request, response);
                return;
            }

            // Create request model
            TransferRequest req = new TransferRequest();
            req.setEmployeeId(employeeId);
            req.setOldDepartmentId(employee.getDepartmentId());
            req.setOldPositionId(employee.getPositionId());
            req.setNewDepartmentId(newDepartmentId);
            req.setNewPositionId(newPositionId);
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
