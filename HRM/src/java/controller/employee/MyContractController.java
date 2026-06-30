package controller.employee;

import dao.EmployeeContractDAO;
import dao.EmployeeProfileDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import model.EmployeeContract;
import model.EmployeeProfile;
import model.User;

@WebServlet(name = "MyContractController", urlPatterns = {"/employee/my-contract"})
public class MyContractController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");
        int userId = currentUser.getUserId();

        EmployeeContractDAO ecDAO = new EmployeeContractDAO();

        // Lịch sử hợp đồng
        List<EmployeeContract> contracts = ecDAO.getByUserId(userId);

        // Hợp đồng đang hiệu lực
        EmployeeContract activeContract = ecDAO.getActiveContract(userId);

        // Tính tổng phụ cấp và lương Gross dự kiến cho hợp đồng hiện tại
        double totalAllowance = 0;
        List<java.util.Map<String, Object>> allowanceList = new java.util.ArrayList<>();
        dao.AllowanceDAO allowanceDAO = new dao.AllowanceDAO();
        if (activeContract != null) {
            allowanceList = allowanceDAO.getAllowancesByContract(userId, activeContract.getContractId());
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
        }
        double grossSalary = (activeContract != null) ? activeContract.getBaseSalary().doubleValue() + totalAllowance : 0;

        // Tính Lương Gross và lấy danh sách Phụ cấp cho TẤT CẢ hợp đồng lịch sử
        if (contracts != null) {
            for (EmployeeContract c : contracts) {
                double cTotalAlw = 0;
                StringBuilder cAlwHtml = new StringBuilder();
                List<java.util.Map<String, Object>> cAlwList = allowanceDAO.getAllowancesByContract(userId, c.getContractId());
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

        // Phụ lục đang chờ ký (nếu có) — hiển thị banner
        EmployeeContract pendingAddendum = ecDAO.getPendingAddendum(userId);

        // Hồ sơ nhân viên
        EmployeeProfileDAO epDAO = new EmployeeProfileDAO();
        EmployeeProfile empProfile = epDAO.getByUserId(userId);

        request.setAttribute("contracts", contracts);
        request.setAttribute("activeContract", activeContract);
        request.setAttribute("totalAllowance", totalAllowance);
        request.setAttribute("allowanceList", allowanceList);
        request.setAttribute("grossSalary", grossSalary);
        request.setAttribute("pendingAddendum", pendingAddendum);
        request.setAttribute("empProfile", empProfile);

        // Thông báo kết quả sau khi ký/từ chối
        String msg = request.getParameter("msg");
        if (msg != null) request.setAttribute("msg", msg);

        request.getRequestDispatcher("/employee/my-contract.jsp").forward(request, response);
    }

    /**
     * Xử lý nhân viên Xác nhận (SIGNED) hoặc Từ chối (REJECTED) phụ lục.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");
        int userId = currentUser.getUserId();

        String action       = request.getParameter("action");       // "SIGNED" | "REJECTED"
        String contractIdStr = request.getParameter("contractId");
        String rejectReason = request.getParameter("rejectReason"); // chỉ khi REJECTED

        if (action == null || contractIdStr == null) {
            response.sendRedirect(request.getContextPath() + "/employee/my-contract?msg=error");
            return;
        }

        try {
            int contractId = Integer.parseInt(contractIdStr);
            EmployeeContractDAO ecDAO = new EmployeeContractDAO();
            boolean ok = ecDAO.updateSignStatus(contractId, userId, action, rejectReason);
            String msg = ok ? (action.equals("SIGNED") ? "signed" : "rejected") : "error";
            response.sendRedirect(request.getContextPath() + "/employee/my-contract?msg=" + msg);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/employee/my-contract?msg=error");
        }
    }
}
