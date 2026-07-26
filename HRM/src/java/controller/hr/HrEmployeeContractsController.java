package controller.hr;

import dao.DepartmentDAO;
import dao.EmployeeProfileDAO;
import dao.PositionDAO;
import dao.UserDAO;
import model.Department;
import model.EmployeeProfile;
import model.Position;
import model.User;
import model.SalaryGrade;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.io.File;
import java.util.List;
import dao.EmployeeContractDAO;
import dao.ContractTypeDAO;
import dao.InsuranceRateDAO;
import model.EmployeeContract;
import model.ContractType;
import model.InsuranceRate;
import dao.SalaryGradeDAO;
import java.util.stream.Collectors;

/**
 * HrEmployeeContractsController — Xem thông tin hợp đồng và lương của nhân viên (dành cho HR).
 * URL: /hr/employee-contracts?userId=...  (GET)
 */
@WebServlet(name = "HrEmployeeContractsController", urlPatterns = {"/hr/employee-contracts", "/manager/employee-contracts"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
    maxFileSize = 1024 * 1024 * 15,       // 15MB
    maxRequestSize = 1024 * 1024 * 50     // 50MB
)
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

            List<Department> allDepts = deptDAO.getAll();
            List<Position> allPos = posDAO.getAll();
            
            for (Department d : allDepts) {
                if (d.getDepartmentId() == employee.getDepartmentId()) {
                    dept = d;
                    break;
                }
            }

            for (Position p : allPos) {
                if (p.getPositionId() == employee.getPositionId()) {
                    pos = p;
                    break;
                }
            }
            
            request.setAttribute("departments", allDepts);
            request.setAttribute("positions", allPos);

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
            
            // Tìm currentContract ở controller — không để JSP tự lọc (đúng MVC)
            EmployeeContract currentContract = null;
            int currentContractId = -1;
            if (contracts != null) {
                for (EmployeeContract c : contracts) {
                    if ("Active".equals(c.getStatus()) || "Pending".equals(c.getStatus())) {
                        currentContract = c;
                        currentContractId = c.getContractId();
                        break;
                    }
                }
            }
            
            dao.AllowanceDAO aDao = new dao.AllowanceDAO();
            
            // Tính Lương Gross và lấy danh sách Phụ cấp cho TẤT CẢ hợp đồng lịch sử
            if (contracts != null) {
                for (EmployeeContract c : contracts) {
                    double cTotalAlw = 0;
                    StringBuilder cAlwHtml = new StringBuilder();
                    List<java.util.Map<String, Object>> cAlwList = aDao.getAllowancesByContract(userId, c.getContractId());
                    for (java.util.Map<String, Object> map : cAlwList) {
                        Object amtObj = map.get("amount");
                        double amt = 0;
                        if (amtObj != null) {
                            if (amtObj instanceof java.math.BigDecimal) {
                                amt = ((java.math.BigDecimal) amtObj).doubleValue();
                            } else if (amtObj instanceof Number) {
                                amt = ((Number) amtObj).doubleValue();
                            } else {
                                amt = Double.parseDouble(amtObj.toString());
                            }
                        }
                        cTotalAlw += amt;
                        cAlwHtml.append(map.get("name")).append(": ")
                                .append(String.format("%,.0f", amt).replace(',', '.')).append(" đ\n");
                    }
                    if (cAlwHtml.length() == 0) {
                        cAlwHtml.append("Không có phụ cấp");
                    }
                    
                    c.setGrossSalary(c.getBaseSalary() != null ? 
                        c.getBaseSalary().add(java.math.BigDecimal.valueOf(cTotalAlw)) : 
                        java.math.BigDecimal.valueOf(cTotalAlw));
                    c.setAllowanceHtml(cAlwHtml.toString().trim());
                }
            }
            
            // Tính lại riêng cho Hợp đồng hiện tại để hiện ở giao diện Current Contract
            double totalAllowance = 0;
            List<java.util.Map<String, Object>> allowanceList = aDao.getAllowancesByContract(userId, currentContractId);
            for (java.util.Map<String, Object> map : allowanceList) {
                Object amtObj = map.get("amount");
                if (amtObj != null) {
                    if (amtObj instanceof java.math.BigDecimal) {
                        totalAllowance += ((java.math.BigDecimal) amtObj).doubleValue();
                    } else if (amtObj instanceof Number) {
                        totalAllowance += ((Number) amtObj).doubleValue();
                    } else {
                        totalAllowance += Double.parseDouble(amtObj.toString());
                    }
                }
            }
            
            request.setAttribute("contracts", contracts);
            request.setAttribute("currentContract", currentContract);  // Controller tính sẵn, JSP chỉ dùng
            request.setAttribute("contractTypes", contractTypes);
            request.setAttribute("activeRates", activeRates);
            request.setAttribute("totalAllowance", totalAllowance);
            request.setAttribute("allowanceList", allowanceList);

            // Phụ cấp giờ được load động qua AJAX (/api/position-allowances) khi HR chọn chức vụ
            // Không cần load danh sách tĩnh nữa sau khi chuyển sang hệ thống phụ cấp theo chức vụ


            // Load salary grades (active only) for the contract form dropdown
            SalaryGradeDAO sgDAO = new SalaryGradeDAO();
            java.util.List<SalaryGrade> activeSalaryGrades = sgDAO.search(null, "active");
            request.setAttribute("salaryGrades", activeSalaryGrades);

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
                
                // Removed HR Manager block

                if (currentRoleId == 5 && currentUser.getUserId() == userId) {
                    session.setAttribute("errorMsg", "Lỗi: HR Staff không được tự thao tác hợp đồng của chính mình.");
                    response.sendRedirect(request.getContextPath() + "/hr/employee-contracts?userId=" + userId);
                    return;
                }

                int contractTypeId = Integer.parseInt(request.getParameter("contractTypeId"));
                java.sql.Date startDate = java.sql.Date.valueOf(request.getParameter("startDate"));
                
                // Kiểm tra tuổi nhân viên tại thời điểm bắt đầu hợp đồng (phải từ 16 tuổi trở lên)
                dao.EmployeeProfileDAO epDAO = new dao.EmployeeProfileDAO();
                model.EmployeeProfile ep = epDAO.getByUserId(userId);
                if (ep != null && ep.getDob() != null) {
                    java.time.LocalDate birth = ep.getDob().toLocalDate();
                    java.time.LocalDate contractStart = startDate.toLocalDate();
                    if (java.time.Period.between(birth, contractStart).getYears() < 16) {
                        session.setAttribute("errorMsg", "Lỗi: Nhân viên chưa đủ 16 tuổi tại thời điểm bắt đầu hợp đồng!");
                        response.sendRedirect(request.getContextPath() + "/hr/employee-contracts?userId=" + userId);
                        return;
                    }
                }
                
                String endStr = request.getParameter("endDate");
                java.sql.Date endDate = (endStr != null && !endStr.trim().isEmpty()) ? java.sql.Date.valueOf(endStr) : null;
                
                int positionId = Integer.parseInt(request.getParameter("positionId"));
                int departmentId = Integer.parseInt(request.getParameter("departmentId"));
                
                java.math.BigDecimal baseSalary = new java.math.BigDecimal(request.getParameter("baseSalary").replaceAll(",", ""));
                if (contractTypeId == 1) {
                    baseSalary = baseSalary.multiply(new java.math.BigDecimal("0.85"));
                }
                
                int taxCalcType = Integer.parseInt(request.getParameter("taxCalcType"));

                int salaryGradeId = Integer.parseInt(request.getParameter("salaryGradeId"));

                // === FIX 10: Kiểm tra giới hạn loại hợp đồng theo BLLĐ 2019 ===
                EmployeeContractDAO ecDAOCheck = new EmployeeContractDAO();
                if (contractTypeId == 1) { // Thử việc
                    int probCount = ecDAOCheck.countProbationContracts(userId);
                    if (probCount > 0) {
                        session.setAttribute("errorMsg", "Lỗi: Nhân viên này đã có hợp đồng thử việc trước đó. Theo BLLĐ 2019 Điều 25, chỉ được thử việc 1 lần.");
                        response.sendRedirect(request.getContextPath() + "/hr/employee-contracts?userId=" + userId);
                        return;
                    }
                } else if (contractTypeId == 2 || contractTypeId == 3) { // Có thời hạn
                    int fixedCount = ecDAOCheck.countFixedTermContracts(userId);
                    if (fixedCount >= 2) {
                        session.setAttribute("errorMsg", "Lỗi: Nhân viên này đã ký đủ 2 lần hợp đồng có thời hạn. Theo BLLĐ 2019 Điều 20, phải chuyển sang hợp đồng Vô thời hạn (Loại 4).");
                        response.sendRedirect(request.getContextPath() + "/hr/employee-contracts?userId=" + userId);
                        return;
                    }
                }
                // ===================================================================

                EmployeeContract c = new EmployeeContract();
                c.setUserId(userId);
                c.setContractTypeId(contractTypeId);
                c.setPositionId(positionId);
                c.setDepartmentId(departmentId);
                c.setSalaryGradeId(salaryGradeId);
                c.setStartDate(startDate);
                c.setEndDate(endDate);
                c.setBaseSalary(baseSalary);
                c.setTaxCalcType(taxCalcType);
                // role 5 (HR Staff) → Pending (cần HR Manager duyệt)
                // role 2 (HR Manager), 3 (Quản đốc), 6 (Trưởng phòng) → Active ngay
                c.setStatus(currentRoleId == 5 ? "Pending" : "Active");

                EmployeeContractDAO ecDAO = new EmployeeContractDAO();
                ecDAO.insert(c);
                
                // FIX 2: Đảm bảo chỉ có 1 HĐ Active tại một thời điểm
                // Nếu HĐ mới được tạo thẳng Active (không qua Pending), terminate HĐ cũ ngay
                if ("Active".equals(c.getStatus()) && c.getContractId() > 0) {
                    ecDAO.terminateOldActiveContracts(userId, c.getContractId());
                }
                
                // Handle allowance checkboxes
                
                // Đồng thời cập nhật contract_type_id vào bảng employee_profiles
                // để tương thích ngược với các module khác chưa chuyển đổi sang dùng bảng mới
                if(ep != null) {
                    ep.setContractTypeId(contractTypeId);
                    ep.setSalaryGradeId(salaryGradeId);
                    epDAO.update(ep);
                }
                
                // Gửi thông báo cho HR Manager (role 2) nếu người tạo là HR Staff
                if (currentRoleId == 5) {
                    dao.UserDAO uDao = new dao.UserDAO();
                    java.util.List<model.User> managers = uDao.searchUsers("", 2);
                    dao.notificationDAO notifDao = new dao.notificationDAO();
                    for (model.User m : managers) {
                        notifDao.create(m.getUserId(), "contract", "Yêu cầu duyệt hợp đồng mới",
                            "HR Staff " + currentUser.getFullName() + " vừa tạo một hợp đồng mới (Chờ duyệt) cho nhân viên ID " + userId + ".",
                            "/hr/contracts");
                    }
                }
                
                session.setAttribute("successMsg", currentRoleId == 5 ? "Tạo hợp đồng thành công (Đang chờ duyệt)!" : "Thêm hợp đồng mới thành công!");
                response.sendRedirect(request.getContextPath() + "/hr/employee-contracts?userId=" + userId);
            } catch (Exception e) {
                e.printStackTrace();
                session.setAttribute("errorMsg", "Lỗi xử lý dữ liệu hợp đồng!");
                response.sendRedirect(request.getContextPath() + "/hr/employee-contracts?userId=" + request.getParameter("userId"));
            }
        } else if ("createAddendum".equals(action)) {
            try {
                int userId = Integer.parseInt(request.getParameter("userId"));
                
                // Removed HR Manager addendum block

                if (currentRoleId == 5 && currentUser.getUserId() == userId) {
                    session.setAttribute("errorMsg", "Lỗi: HR Staff không được tự tạo phụ lục cho chính mình.");
                    response.sendRedirect(request.getContextPath() + "/hr/employee-contracts?userId=" + userId);
                    return;
                }

                int parentContractId = Integer.parseInt(request.getParameter("parentContractId"));
                String addendumReason = request.getParameter("addendumReason");
                String effectiveDateStr = request.getParameter("effectiveDate");
                java.sql.Date effectiveDate = (effectiveDateStr != null && !effectiveDateStr.trim().isEmpty())
                    ? java.sql.Date.valueOf(effectiveDateStr) : null;
                java.sql.Date startDate = java.sql.Date.valueOf(request.getParameter("startDate"));
                
                // Kiểm tra tuổi nhân viên tại thời điểm bắt đầu phụ lục (phải từ 16 tuổi trở lên)
                dao.EmployeeProfileDAO epDAO = new dao.EmployeeProfileDAO();
                model.EmployeeProfile ep = epDAO.getByUserId(userId);
                if (ep != null && ep.getDob() != null) {
                    java.time.LocalDate birth = ep.getDob().toLocalDate();
                    java.time.LocalDate addendumStart = startDate.toLocalDate();
                    if (java.time.Period.between(birth, addendumStart).getYears() < 16) {
                        session.setAttribute("errorMsg", "Lỗi: Nhân viên chưa đủ 16 tuổi tại thời điểm bắt đầu phụ lục hợp đồng!");
                        response.sendRedirect(request.getContextPath() + "/hr/employee-contracts?userId=" + userId);
                        return;
                    }
                }
                java.math.BigDecimal baseSalary = new java.math.BigDecimal(request.getParameter("baseSalary").replaceAll(",", ""));
                
                // Fields inherited from the parent contract (passed as hidden inputs)
                int contractTypeId = Integer.parseInt(request.getParameter("contractTypeId"));
                String endStr = request.getParameter("endDate");
                java.sql.Date endDate = (endStr != null && !endStr.trim().isEmpty()) ? java.sql.Date.valueOf(endStr) : null;
                int taxCalcType = Integer.parseInt(request.getParameter("taxCalcType"));
                int positionId = Integer.parseInt(request.getParameter("positionId"));
                int departmentId = Integer.parseInt(request.getParameter("departmentId"));

                EmployeeContract addendum = new EmployeeContract();
                addendum.setUserId(userId);
                addendum.setContractTypeId(contractTypeId);
                addendum.setPositionId(positionId);
                addendum.setDepartmentId(departmentId);
                addendum.setStartDate(startDate);
                addendum.setEndDate(endDate);
                addendum.setBaseSalary(baseSalary);
                addendum.setTaxCalcType(taxCalcType);
                addendum.setParentContractId(parentContractId);
                addendum.setAddendumReason(addendumReason);
                addendum.setEffectiveDate(effectiveDate);
                addendum.setDocType("ADDENDUM");
                addendum.setSignStatus("PENDING");
                
                // FIX 3: HR Staff tạo phụ lục → Pending (cần HR Manager duyệt trước khi NV ký)
                // HR Manager/Quản đốc tạo phụ lục → Active ngay (tự phê duyệt)
                addendum.setStatus(currentRoleId == 5 ? "Pending" : "Active");

                EmployeeContractDAO ecDAO = new EmployeeContractDAO();
                ecDAO.insertAddendum(addendum);
                
                // FIX 3: Gửi thông báo cho HR Manager khi HR Staff tạo phụ lục chờ duyệt
                if (currentRoleId == 5) {
                    dao.UserDAO uDao = new dao.UserDAO();
                    java.util.List<model.User> managers = uDao.searchUsers("", 2);
                    dao.notificationDAO notifDao = new dao.notificationDAO();
                    for (model.User m : managers) {
                        notifDao.create(m.getUserId(), "contract", "Yêu cầu duyệt phụ lục hợp đồng",
                            "HR Staff " + currentUser.getFullName() + " vừa tạo phụ lục hợp đồng (Chờ duyệt) cho nhân viên ID " + userId
                            + (addendumReason != null && !addendumReason.isBlank() ? ". Lý do: " + addendumReason : "") + ".",
                            "/hr/contract-approval");
                    }
                }
                
                // Get the generated contractId for the addendum to insert allowances
                
                session.setAttribute("successMsg", currentRoleId == 5
                    ? "Đã tạo phụ lục Hợp đồng (Chờ HR Manager duyệt)!"
                    : "Đã tạo phụ lục Hợp đồng. Vui lòng chờ nhân viên xác nhận!");
                response.sendRedirect(request.getContextPath() + "/hr/employee-contracts?userId=" + userId);
            } catch (Exception e) {
                e.printStackTrace();
                session.setAttribute("errorMsg", "Lỗi khi xử lý dữ liệu tạo Phụ lục!");
                response.sendRedirect(request.getContextPath() + "/hr/employee-contracts?userId=" + request.getParameter("userId"));
            }
        } else if ("approve".equals(action)) {
            try {
                if (currentRoleId != 2 && currentRoleId != 1 && currentRoleId != 4) {
                    session.setAttribute("errorMsg", "Lỗi: Bạn không có quyền phê duyệt hợp đồng.");
                    response.sendRedirect(request.getContextPath() + "/hr/contracts");
                    return;
                }
                int contractId = Integer.parseInt(request.getParameter("contractId"));
                int targetUserId = Integer.parseInt(request.getParameter("userId"));
                
                EmployeeContractDAO ecDAO = new EmployeeContractDAO();
                if (ecDAO.approveContract(contractId, targetUserId, currentUser.getUserId())) {
                    session.setAttribute("successMsg", "Đã phê duyệt hợp đồng thành công!");
                } else {
                    session.setAttribute("errorMsg", "Phê duyệt thất bại. Hợp đồng có thể đã bị xóa.");
                }
                response.sendRedirect(request.getContextPath() + "/hr/contracts");
            } catch (Exception e) {
                e.printStackTrace();
                session.setAttribute("errorMsg", "Lỗi hệ thống khi phê duyệt hợp đồng.");
                response.sendRedirect(request.getContextPath() + "/hr/contracts");
            }
        } else if ("uploadPdf".equals(action)) {
            try {
                if (currentRoleId != 5 && currentRoleId != 2) {
                    session.setAttribute("errorMsg", "Lỗi: Bạn không có quyền tải lên file hợp đồng.");
                    response.sendRedirect(request.getContextPath() + "/hr/contracts");
                    return;
                }
                int contractId = Integer.parseInt(request.getParameter("contractId"));
                int targetUserId = Integer.parseInt(request.getParameter("userId"));
                
                Part filePart = request.getPart("contractFile");
                if (filePart != null && filePart.getSize() > 0) {
                    String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads" + File.separator + "contracts";
                    File uploadDir = new File(uploadPath);
                    if (!uploadDir.exists()) {
                        uploadDir.mkdirs();
                    }
                    
                    String submittedFileName = filePart.getSubmittedFileName();
                    String extension = ".pdf";
                    if (submittedFileName != null && submittedFileName.lastIndexOf(".") > 0) {
                        extension = submittedFileName.substring(submittedFileName.lastIndexOf("."));
                    }
                    
                    String fileName = "contract_" + contractId + "_" + System.currentTimeMillis() + extension;
                    filePart.write(uploadPath + File.separator + fileName);
                    
                    String dbFilePath = "/uploads/contracts/" + fileName;
                    EmployeeContractDAO ecDAO = new EmployeeContractDAO();
                    if (ecDAO.updateFilePath(contractId, dbFilePath)) {
                        session.setAttribute("successMsg", "Đã tải lên bản scan hợp đồng thành công!");
                    } else {
                        session.setAttribute("errorMsg", "Lỗi: Không thể lưu đường dẫn vào database.");
                    }
                } else {
                    session.setAttribute("errorMsg", "Lỗi: Không tìm thấy file hợp đồng tải lên.");
                }
                
                response.sendRedirect(request.getContextPath() + "/hr/employee-contracts?userId=" + targetUserId);
            } catch (Exception e) {
                e.printStackTrace();
                session.setAttribute("errorMsg", "Lỗi hệ thống khi tải lên file.");
                response.sendRedirect(request.getContextPath() + "/hr/contracts");
            }
        }
    }
}
