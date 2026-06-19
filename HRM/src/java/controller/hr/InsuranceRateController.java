package controller.hr;

import dao.InsuranceRateDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;
import java.util.List;
import model.InsuranceRate;
import model.User;

/**
 * InsuranceRateController — HR Staff quản lý mức đóng bảo hiểm.
 * URL: /hr/insurance-rate
 * Roles: HR Manager (2), HR Staff (5)
 */
@WebServlet(name = "InsuranceRateController", urlPatterns = {"/hr/insurance-rate"})
public class InsuranceRateController extends HttpServlet {

    private static final String LIST_JSP = "/hr/insurance-rate.jsp";
    private static final String LIST_URL = "/hr/insurance-rate";

    private final InsuranceRateDAO dao = new InsuranceRateDAO();

    private boolean checkAccess(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return false;
        }
        User user = (User) session.getAttribute("currentUser");
        if (user.getRoleId() != 2 && user.getRoleId() != 5) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return false;
        }
        return true;
    }

    private void loadList(HttpServletRequest request) {
        List<InsuranceRate> list = dao.getAll();

        BigDecimal totalCompany  = BigDecimal.ZERO;
        BigDecimal totalEmployee = BigDecimal.ZERO;
        int activeCount = 0;
        for (InsuranceRate ir : list) {
            if (ir.isStatus()) {
                totalCompany  = totalCompany.add(ir.getCompanyRate());
                totalEmployee = totalEmployee.add(ir.getEmployeeRate());
                activeCount++;
            }
        }
        BigDecimal avgCompany  = activeCount == 0 ? BigDecimal.ZERO
            : totalCompany.divide(new BigDecimal(activeCount), 2, java.math.RoundingMode.HALF_UP);
        BigDecimal avgEmployee = activeCount == 0 ? BigDecimal.ZERO
            : totalEmployee.divide(new BigDecimal(activeCount), 2, java.math.RoundingMode.HALF_UP);

        request.setAttribute("insuranceRateList", list);
        request.setAttribute("avgCompanyRate",    avgCompany);
        request.setAttribute("avgEmployeeRate",   avgEmployee);
        request.setAttribute("activeCount",       activeCount);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!checkAccess(request, response)) return;

        loadList(request);
        request.getRequestDispatcher(LIST_JSP).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        if (!checkAccess(request, response)) return;

        String action = request.getParameter("action");
        String idStr  = request.getParameter("id");

        if ("deactivate".equals(action) && idStr != null) {
            dao.changeStatus(Integer.parseInt(idStr), false);
            request.getSession().setAttribute("successMsg", "Đã vô hiệu hóa mức bảo hiểm.");
            response.sendRedirect(request.getContextPath() + LIST_URL);
            return;
        }
        if ("activate".equals(action) && idStr != null) {
            dao.changeStatus(Integer.parseInt(idStr), true);
            request.getSession().setAttribute("successMsg", "Đã kích hoạt mức bảo hiểm.");
            response.sendRedirect(request.getContextPath() + LIST_URL);
            return;
        }

        String insuranceCode = request.getParameter("insuranceCode");
        String insuranceName = request.getParameter("insuranceName");
        String companyRateS  = request.getParameter("companyRate");
        String employeeRateS = request.getParameter("employeeRate");
        String description   = request.getParameter("description");
        String fromStr       = request.getParameter("effectiveFrom");
        String toStr         = request.getParameter("effectiveTo");

        String errorMsg = null;

        if (insuranceCode == null || insuranceCode.trim().isEmpty()) {
            errorMsg = "Mã bảo hiểm không được để trống.";
        } else if (insuranceCode.trim().length() > 20) {
            errorMsg = "Mã bảo hiểm không được vượt quá 20 ký tự.";
        } else if (!insuranceCode.trim().matches("^[a-zA-Z0-9_\\-\\s]+$")) {
            errorMsg = "Mã bảo hiểm chỉ được chứa chữ cái, số, khoảng trắng, gạch ngang và gạch dưới.";
        }

        if (errorMsg == null) {
            if (insuranceName == null || insuranceName.trim().isEmpty()) {
                errorMsg = "Tên loại bảo hiểm không được để trống.";
            } else if (insuranceName.trim().length() > 100) {
                errorMsg = "Tên loại bảo hiểm không được vượt quá 100 ký tự.";
            }
        }

        BigDecimal companyRate = null;
        if (errorMsg == null) {
            if (companyRateS == null || companyRateS.trim().isEmpty()) {
                errorMsg = "Tỷ lệ đóng của doanh nghiệp không được để trống.";
            } else {
                try {
                    companyRate = new BigDecimal(companyRateS.trim());
                    if (companyRate.compareTo(BigDecimal.ZERO) < 0) {
                        errorMsg = "Tỷ lệ đóng của doanh nghiệp không được nhỏ hơn 0.";
                    } else if (companyRate.compareTo(new BigDecimal("100")) > 0) {
                        errorMsg = "Tỷ lệ đóng của doanh nghiệp không được vượt quá 100.";
                    }
                } catch (NumberFormatException e) {
                    errorMsg = "Tỷ lệ đóng của doanh nghiệp phải là số.";
                }
            }
        }

        BigDecimal employeeRate = null;
        if (errorMsg == null) {
            if (employeeRateS == null || employeeRateS.trim().isEmpty()) {
                errorMsg = "Tỷ lệ đóng của nhân viên không được để trống.";
            } else {
                try {
                    employeeRate = new BigDecimal(employeeRateS.trim());
                    if (employeeRate.compareTo(BigDecimal.ZERO) < 0) {
                        errorMsg = "Tỷ lệ đóng của nhân viên không được nhỏ hơn 0.";
                    } else if (employeeRate.compareTo(new BigDecimal("100")) > 0) {
                        errorMsg = "Tỷ lệ đóng của nhân viên không được vượt quá 100.";
                    }
                } catch (NumberFormatException e) {
                    errorMsg = "Tỷ lệ đóng của nhân viên phải là số.";
                }
            }
        }

        Date effectiveFrom = null;
        Date effectiveTo = null;
        if (errorMsg == null) {
            if (fromStr != null && !fromStr.trim().isEmpty()) {
                try {
                    java.time.LocalDate.parse(fromStr.trim());
                    effectiveFrom = Date.valueOf(fromStr.trim());
                } catch (Exception e) {
                    errorMsg = "Ngày bắt đầu không tồn tại hoặc không đúng định dạng YYYY-MM-DD.";
                }
            }
            if (errorMsg == null && toStr != null && !toStr.trim().isEmpty()) {
                try {
                    java.time.LocalDate.parse(toStr.trim());
                    effectiveTo = Date.valueOf(toStr.trim());
                } catch (Exception e) {
                    errorMsg = "Ngày kết thúc không tồn tại hoặc không đúng định dạng YYYY-MM-DD.";
                }
            }
            if (errorMsg == null && effectiveFrom != null && effectiveTo != null) {
                if (effectiveFrom.after(effectiveTo)) {
                    errorMsg = "Ngày bắt đầu không được lớn hơn ngày kết thúc.";
                }
            }
        }

        if (errorMsg == null) {
            if (description != null && description.length() > 255) {
                errorMsg = "Mô tả không được vượt quá 255 ký tự.";
            }
        }

        if (errorMsg != null) {
            request.getSession().setAttribute("errorMsg", errorMsg);
            response.sendRedirect(request.getContextPath() + LIST_URL);
            return;
        }

        try {
            if ("add".equals(action)) {
                if (dao.isDuplicate(insuranceName, 0)) {
                    request.getSession().setAttribute("errorMsg", "Tên loại bảo hiểm đã tồn tại.");
                } else if (dao.isCodeDuplicate(insuranceCode, 0)) {
                    request.getSession().setAttribute("errorMsg", "Mã bảo hiểm đã tồn tại.");
                } else {
                    InsuranceRate ir = new InsuranceRate(
                        0, insuranceCode.trim(), insuranceName.trim(), companyRate, employeeRate,
                        description != null ? description.trim() : null, effectiveFrom, effectiveTo, null, null, true);
                    dao.insert(ir);
                    request.getSession().setAttribute("successMsg", "Thêm mức bảo hiểm thành công.");
                }
            } else if ("edit".equals(action) && idStr != null) {
                int editId = Integer.parseInt(idStr);
                if (dao.isDuplicate(insuranceName, editId)) {
                    request.getSession().setAttribute("errorMsg", "Tên loại bảo hiểm đã tồn tại.");
                } else if (dao.isCodeDuplicate(insuranceCode, editId)) {
                    request.getSession().setAttribute("errorMsg", "Mã bảo hiểm đã tồn tại.");
                } else {
                    InsuranceRate ir = new InsuranceRate(
                        editId, insuranceCode.trim(), insuranceName.trim(), companyRate, employeeRate,
                        description != null ? description.trim() : null, effectiveFrom, effectiveTo, null, null, true);
                    dao.update(ir);
                    request.getSession().setAttribute("successMsg", "Cập nhật mức bảo hiểm thành công.");
                }
            }
        } catch (Exception e) {
            request.getSession().setAttribute("errorMsg", "Lỗi xử lý dữ liệu: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + LIST_URL);
    }
}
