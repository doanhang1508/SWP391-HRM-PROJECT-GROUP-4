package controller.hr;

import dao.DepartmentDAO;
import dao.EmployeeProfileDAO;
import dao.PositionDAO;
import dao.RoleDAO;
import dao.UserDAO;
import model.Department;
import model.EmployeeProfile;
import model.Position;
import model.Role;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Date;
import java.util.List;

/**
 * HrEmployeeEditController — Chỉnh sửa thông tin nhân viên (dành cho HR).
 * URL: /hr/employee-edit?userId=...  (GET/POST)
 *
 * GET  → load form (users + employee_profiles)
 * POST → lưu thay đổi vào bảng users VÀ employee_profiles
 */
@WebServlet(name = "HrEmployeeEditController", urlPatterns = {"/hr/employee-edit"})
public class HrEmployeeEditController extends HttpServlet {

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

        // Chỉ Admin(1), HR Manager(2), HR Staff(5) được chỉnh sửa
        if (roleId != 1 && roleId != 2 && roleId != 5) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        String userIdParam = request.getParameter("userId");
        if (userIdParam == null || userIdParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/hr/employees");
            return;
        }

        try {
            int userId = Integer.parseInt(userIdParam);

            UserDAO userDAO = new UserDAO();
            User employee = userDAO.getUserById(userId);

            if (employee == null) {
                response.sendRedirect(request.getContextPath() + "/hr/employees");
                return;
            }

            // Load data for dropdowns
            DepartmentDAO deptDAO = new DepartmentDAO();
            PositionDAO posDAO = new PositionDAO();
            RoleDAO roleDAO = new RoleDAO();

            List<Department> deptList = deptDAO.getAll();
            List<Position> posList = posDAO.getAll();
            List<Role> roleList = roleDAO.getAllRoles();

            // Load employee profile (thông tin mở rộng)
            EmployeeProfileDAO profileDAO = new EmployeeProfileDAO();
            EmployeeProfile empProfile = profileDAO.getByUserId(userId);

            // Load dropdown cho Hợp đồng & Lương
            dao.ContractTypeDAO ctDAO = new dao.ContractTypeDAO();
            dao.SalaryGradeDAO sgDAO = new dao.SalaryGradeDAO();

            request.setAttribute("employee", employee);
            request.setAttribute("deptList", deptList);
            request.setAttribute("posList", posList);
            request.setAttribute("roleList", roleList);
            request.setAttribute("empProfile", empProfile);
            request.setAttribute("contractTypeList", ctDAO.getAll());
            request.setAttribute("salaryGradeList", sgDAO.getAll());

            request.getRequestDispatcher("/hr/employee-edit.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/hr/employees");
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
        if (roleId != 1 && roleId != 2 && roleId != 5) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        String userIdParam = request.getParameter("userId");
        if (userIdParam == null || userIdParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/hr/employees");
            return;
        }

        try {
            int userId = Integer.parseInt(userIdParam);

            // ── 1. Cập nhật bảng users ────────────────────────────────────────
            String fullName = request.getParameter("fullName");
            String email    = request.getParameter("email");
            String phone    = request.getParameter("phone");

            String deptIdStr = request.getParameter("departmentId");
            String posIdStr  = request.getParameter("positionId");
            String roleIdStr = request.getParameter("roleId");
            String statusStr = request.getParameter("status");

            int newDeptId   = (deptIdStr != null && !deptIdStr.isEmpty())  ? Integer.parseInt(deptIdStr)  : 0;
            int newPosId    = (posIdStr  != null && !posIdStr.isEmpty())    ? Integer.parseInt(posIdStr)   : 0;
            int newRoleId   = (roleIdStr != null && !roleIdStr.isEmpty())   ? Integer.parseInt(roleIdStr)  : 0;
            int newStatus   = (statusStr != null && !statusStr.isEmpty())   ? Integer.parseInt(statusStr)  : 1;

            UserDAO userDAO = new UserDAO();
            boolean usersOk = userDAO.updateUserFull(userId, fullName, email, phone, newDeptId, newPosId, newRoleId, newStatus);

            // ── 2. Cập nhật bảng employee_profiles ───────────────────────────
            EmployeeProfileDAO profileDAO = new EmployeeProfileDAO();
            EmployeeProfile ep = new EmployeeProfile();
            ep.setUserId(userId);
            ep.setDepartmentId(newDeptId);

            // Thông tin cá nhân mở rộng
            ep.setIdCard(trimOrNull(request.getParameter("idCard")));
            ep.setAddress(trimOrNull(request.getParameter("address")));
            ep.setTaxCode(trimOrNull(request.getParameter("taxCode")));
            ep.setSocialInsuranceNo(trimOrNull(request.getParameter("socialInsuranceNo")));
            ep.setBankAccount(trimOrNull(request.getParameter("bankAccount")));
            ep.setBankName(trimOrNull(request.getParameter("bankName")));

            // Giới tính
            String genderStr = request.getParameter("gender");
            if (genderStr != null && !genderStr.isEmpty()) {
                ep.setGender(Integer.parseInt(genderStr));
            }

            // Ngày sinh
            String dobStr = request.getParameter("dob");
            if (dobStr != null && !dobStr.isEmpty()) {
                ep.setDob(Date.valueOf(dobStr));
            }

            // Ngày vào làm
            String hireDateStr = request.getParameter("hireDate");
            if (hireDateStr != null && !hireDateStr.isEmpty()) {
                ep.setHireDate(Date.valueOf(hireDateStr));
            }

            // Hợp đồng & Lương
            String ctStr = request.getParameter("contractTypeId");
            if (ctStr != null && !ctStr.isEmpty()) {
                ep.setContractTypeId(Integer.parseInt(ctStr));
            }
            String sgStr = request.getParameter("salaryGradeId");
            if (sgStr != null && !sgStr.isEmpty()) {
                ep.setSalaryGradeId(Integer.parseInt(sgStr));
            }

            boolean profileOk = profileDAO.upsert(ep);

            if (usersOk || profileOk) {
                response.sendRedirect(request.getContextPath() + "/hr/employee-detail?userId=" + userId + "&msg=update_success");
            } else {
                response.sendRedirect(request.getContextPath() + "/hr/employee-edit?userId=" + userId + "&error=save_failed");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/hr/employees");
        }
    }

    private String trimOrNull(String s) {
        if (s == null) return null;
        String t = s.trim();
        return t.isEmpty() ? null : t;
    }
}
