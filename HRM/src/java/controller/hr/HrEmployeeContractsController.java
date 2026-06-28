package controller.hr;

import dao.DepartmentDAO;
import dao.EmployeeProfileDAO;
import dao.PositionDAO;
import dao.UserDAO;
import model.Department;
import model.EmployeeProfile;
import model.Position;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;
import dao.EmployeeContractDAO;
import dao.ContractTypeDAO;
import dao.InsuranceRateDAO;
import model.EmployeeContract;
import model.ContractType;
import model.InsuranceRate;

/**
 * HrEmployeeContractsController — Xem thông tin hợp đồng và lương của nhân viên (dành cho HR).
 * URL: /hr/employee-contracts?userId=...  (GET)
 */
@WebServlet(name = "HrEmployeeContractsController", urlPatterns = {"/hr/employee-contracts", "/manager/employee-contracts"})
public class HrEmployeeContractsController extends HttpServlet {

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

        // HR Manager(2), HR Staff(5), Quản đốc(3), Trưởng phòng(6)
        if (roleId != 2 && roleId != 3 && roleId != 5 && roleId != 6) {
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

            // Load department & position for profile header
            DepartmentDAO deptDAO = new DepartmentDAO();
            PositionDAO posDAO = new PositionDAO();

            Department dept = null;
            Position pos = null;

            for (Department d : deptDAO.getAll()) {
                if (d.getDepartmentId() == employee.getDepartmentId()) {
                    dept = d;
                    break;
                }
            }

            for (Position p : posDAO.getAll()) {
                if (p.getPositionId() == employee.getPositionId()) {
                    pos = p;
                    break;
                }
            }

            // Load employee profile đầy đủ (hợp đồng, lương, bảo hiểm, ngân hàng)
            EmployeeProfileDAO profileDAO = new EmployeeProfileDAO();
            EmployeeProfile empProfile = profileDAO.getByUserId(userId);
            
            // Tải danh sách Hợp đồng lịch sử, Loại hợp đồng và Mức bảo hiểm
            EmployeeContractDAO ecDAO = new EmployeeContractDAO();
            List<EmployeeContract> contracts = ecDAO.getByUserId(userId);
            
            ContractTypeDAO ctDAO = new ContractTypeDAO();
            List<ContractType> contractTypes = ctDAO.getAll();
            
            InsuranceRateDAO irDAO = new InsuranceRateDAO();
            List<InsuranceRate> activeRates = irDAO.search(null, "active");
            
            int currentContractId = -1;
            if (contracts != null) {
                for (EmployeeContract c : contracts) {
                    if ("Active".equals(c.getStatus()) || "Pending".equals(c.getStatus())) {
                        currentContractId = c.getContractId();
                        break;
                    }
                }
            }
            
            double totalAllowance = 0;
            List<java.util.Map<String, Object>> allowanceList = new java.util.ArrayList<>();
            String sqlAllowance = "SELECT a.allowance_name, ea.amount FROM employee_allowances ea JOIN allowances a ON ea.allowance_id = a.allowance_id WHERE ea.user_id = ? AND (ea.contract_id = ? OR ea.contract_id IS NULL)";
            try (java.sql.Connection conn = util.DBContext.getConnection();
                 java.sql.PreparedStatement ps = conn.prepareStatement(sqlAllowance)) {
                ps.setInt(1, userId);
                ps.setInt(2, currentContractId);
                try (java.sql.ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        java.util.Map<String, Object> map = new java.util.HashMap<>();
                        map.put("name", rs.getString("allowance_name"));
                        double amt = rs.getDouble("amount");
                        map.put("amount", amt);
                        allowanceList.add(map);
                        totalAllowance += amt;
                    }
                }
            } catch (Exception e) { e.printStackTrace(); }
            
            request.setAttribute("contracts", contracts);
            request.setAttribute("contractTypes", contractTypes);
            request.setAttribute("activeRates", activeRates);
            request.setAttribute("totalAllowance", totalAllowance);
            request.setAttribute("allowanceList", allowanceList);

            dao.AllowanceDAO allowanceDAO = new dao.AllowanceDAO();
            List<model.Allowance> availableAllowances = allowanceDAO.getActive();
            request.setAttribute("availableAllowances", availableAllowances);

            request.setAttribute("employee", employee);
            request.setAttribute("empDept", dept);
            request.setAttribute("empPos", pos);
            request.setAttribute("empProfile", empProfile);

            request.getRequestDispatcher("/hr/employee-contracts.jsp").forward(request, response);

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
        int currentRoleId = currentUser.getRoleId();

        String action = request.getParameter("action");
        if ("create".equals(action)) {
            try {
                int userId = Integer.parseInt(request.getParameter("userId"));
                
                if (currentRoleId == 5 && currentUser.getUserId() == userId) {
                    session.setAttribute("errorMsg", "Lỗi: HR Staff không được tự thao tác hợp đồng của chính mình.");
                    response.sendRedirect(request.getContextPath() + "/hr/employee-contracts?userId=" + userId);
                    return;
                }

                int contractTypeId = Integer.parseInt(request.getParameter("contractTypeId"));
                java.sql.Date startDate = java.sql.Date.valueOf(request.getParameter("startDate"));
                String endStr = request.getParameter("endDate");
                java.sql.Date endDate = (endStr != null && !endStr.trim().isEmpty()) ? java.sql.Date.valueOf(endStr) : null;
                
                java.math.BigDecimal baseSalary = new java.math.BigDecimal(request.getParameter("baseSalary").replaceAll(",", ""));
                if (contractTypeId == 1) {
                    baseSalary = baseSalary.multiply(new java.math.BigDecimal("0.85"));
                }
                
                java.math.BigDecimal bhxhRate = new java.math.BigDecimal(request.getParameter("bhxhRate"));
                java.math.BigDecimal bhytRate = new java.math.BigDecimal(request.getParameter("bhytRate"));
                java.math.BigDecimal bhtnRate = new java.math.BigDecimal(request.getParameter("bhtnRate"));
                int taxCalcType = Integer.parseInt(request.getParameter("taxCalcType"));

                EmployeeContract c = new EmployeeContract();
                c.setUserId(userId);
                c.setContractTypeId(contractTypeId);
                c.setStartDate(startDate);
                c.setEndDate(endDate);
                c.setBaseSalary(baseSalary);
                c.setBhxhRate(bhxhRate);
                c.setBhytRate(bhytRate);
                c.setBhtnRate(bhtnRate);
                c.setTaxCalcType(taxCalcType);
                c.setStatus(currentRoleId == 5 ? "Pending" : "Active");

                EmployeeContractDAO ecDAO = new EmployeeContractDAO();
                ecDAO.insert(c);
                
                // Handle allowance checkboxes
                String[] allowanceIds = request.getParameterValues("allowanceIds");
                if (allowanceIds != null && allowanceIds.length > 0 && c.getContractId() > 0) {
                    try (java.sql.Connection conn = util.DBContext.getConnection()) {
                        String sqlInsertAlw = "INSERT INTO employee_allowances (user_id, allowance_id, amount, contract_id, effective_date) VALUES (?, ?, (SELECT amount FROM allowances WHERE allowance_id = ?), ?, ?)";
                        try (java.sql.PreparedStatement psAlw = conn.prepareStatement(sqlInsertAlw)) {
                            for (String alwIdStr : allowanceIds) {
                                int alwId = Integer.parseInt(alwIdStr);
                                psAlw.setInt(1, userId);
                                psAlw.setInt(2, alwId);
                                psAlw.setInt(3, alwId);
                                psAlw.setInt(4, c.getContractId());
                                psAlw.setDate(5, c.getStartDate());
                                psAlw.addBatch();
                            }
                            psAlw.executeBatch();
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
                
                // Đồng thời cập nhật contract_type_id vào bảng employee_profiles
                // để tương thích ngược với các module khác chưa chuyển đổi sang dùng bảng mới
                dao.EmployeeProfileDAO epDAO = new dao.EmployeeProfileDAO();
                model.EmployeeProfile ep = epDAO.getByUserId(userId);
                if(ep != null) {
                    ep.setContractTypeId(contractTypeId);
                    epDAO.update(ep);
                }
                
                session.setAttribute("successMsg", currentRoleId == 5 ? "Tạo hợp đồng thành công (Đang chờ duyệt)!" : "Thêm hợp đồng mới thành công!");
                response.sendRedirect(request.getContextPath() + "/hr/employee-contracts?userId=" + userId);
            } catch (Exception e) {
                e.printStackTrace();
                session.setAttribute("errorMsg", "Lỗi xử lý dữ liệu hợp đồng!");
                response.sendRedirect(request.getContextPath() + "/hr/employee-contracts?userId=" + request.getParameter("userId"));
            }
        } else if ("approve".equals(action)) {
            try {
                if (currentRoleId != 2 && currentRoleId != 1 && currentRoleId != 4) {
                    session.setAttribute("errorMsg", "Lỗi: Bạn không có quyền phê duyệt hợp đồng.");
                    response.sendRedirect(request.getContextPath() + "/hr/contract-list");
                    return;
                }
                int contractId = Integer.parseInt(request.getParameter("contractId"));
                int targetUserId = Integer.parseInt(request.getParameter("userId"));
                
                EmployeeContractDAO ecDAO = new EmployeeContractDAO();
                if (ecDAO.approveContract(contractId, targetUserId)) {
                    session.setAttribute("successMsg", "Đã phê duyệt hợp đồng thành công!");
                } else {
                    session.setAttribute("errorMsg", "Phê duyệt thất bại. Hợp đồng có thể đã bị xóa.");
                }
                response.sendRedirect(request.getContextPath() + "/hr/contract-list");
            } catch (Exception e) {
                e.printStackTrace();
                session.setAttribute("errorMsg", "Lỗi hệ thống khi phê duyệt hợp đồng.");
                response.sendRedirect(request.getContextPath() + "/hr/contract-list");
            }
        }
    }
}
