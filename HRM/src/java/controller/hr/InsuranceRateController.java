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

        if ("add".equals(action)) {
            // Trim inputs
            String insuranceCode = request.getParameter("insuranceCode");
            insuranceCode = insuranceCode == null ? "" : insuranceCode.trim();
            
            String insuranceName = request.getParameter("insuranceName");
            insuranceName = insuranceName == null ? "" : insuranceName.trim();
            
            String companyRateS = request.getParameter("companyRate");
            companyRateS = companyRateS == null ? "" : companyRateS.trim();
            
            String employeeRateS = request.getParameter("employeeRate");
            employeeRateS = employeeRateS == null ? "" : employeeRateS.trim();
            
            String description = request.getParameter("description");
            description = description == null ? "" : description.trim();
            
            String fromStr = request.getParameter("effectiveFrom");
            fromStr = fromStr == null ? "" : fromStr.trim();
            
            String toStr = request.getParameter("effectiveTo");
            toStr = toStr == null ? "" : toStr.trim();
            
            // Set request attributes to keep values in case of forward
            request.setAttribute("insuranceCode", insuranceCode);
            request.setAttribute("insuranceName", insuranceName);
            request.setAttribute("companyRate", companyRateS);
            request.setAttribute("employeeRate", employeeRateS);
            request.setAttribute("description", description);
            request.setAttribute("effectiveFrom", fromStr);
            request.setAttribute("effectiveTo", toStr);
            
            // Server-side validation
            String errorMsg = null;
            
            // 1. Insurance Code
            if (insuranceCode.isEmpty()) {
                errorMsg = "Mã bảo hiểm không được để trống.";
            } else if (insuranceCode.length() > 20) {
                errorMsg = "Mã bảo hiểm không được vượt quá 20 ký tự.";
            } else if (!insuranceCode.matches("^[\\p{L}0-9_\\- ]+$")) {
                errorMsg = "Mã bảo hiểm chỉ được chứa chữ cái, số, khoảng trắng, gạch ngang và gạch dưới.";
            } else if (dao.isCodeDuplicate(insuranceCode, 0)) {
                errorMsg = "Mã bảo hiểm đã tồn tại.";
            }
            
            // 2. Insurance Name
            if (errorMsg == null) {
                if (insuranceName.isEmpty()) {
                    errorMsg = "Tên loại bảo hiểm không được để trống.";
                } else if (insuranceName.length() > 100) {
                    errorMsg = "Tên loại bảo hiểm không được vượt quá 100 ký tự.";
                } else if (dao.isDuplicate(insuranceName, 0)) {
                    errorMsg = "Tên loại bảo hiểm đã tồn tại.";
                }
            }
            
            // 3. Company Rate
            BigDecimal companyRate = null;
            if (errorMsg == null) {
                if (companyRateS.isEmpty()) {
                    errorMsg = "Tỷ lệ đóng của doanh nghiệp không được để trống.";
                } else {
                    try {
                        companyRate = new BigDecimal(companyRateS);
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
            
            // 4. Employee Rate
            BigDecimal employeeRate = null;
            if (errorMsg == null) {
                if (employeeRateS.isEmpty()) {
                    errorMsg = "Tỷ lệ đóng của nhân viên không được để trống.";
                } else {
                    try {
                        employeeRate = new BigDecimal(employeeRateS);
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
            
            // 5. Effective dates (Strict parsing)
            Date effectiveFrom = null;
            Date effectiveTo = null;
            
            if (errorMsg == null) {
                if (!fromStr.isEmpty()) {
                    try {
                        java.time.format.DateTimeFormatter formatter = java.time.format.DateTimeFormatter
                                .ofPattern("uuuu-MM-dd")
                                .withResolverStyle(java.time.format.ResolverStyle.STRICT);
                        java.time.LocalDate localDate = java.time.LocalDate.parse(fromStr, formatter);
                        effectiveFrom = java.sql.Date.valueOf(localDate);
                    } catch (java.time.format.DateTimeParseException e) {
                        errorMsg = "Ngày bắt đầu không hợp lệ.";
                    }
                }
            }
            
            if (errorMsg == null) {
                if (!toStr.isEmpty()) {
                    try {
                        java.time.format.DateTimeFormatter formatter = java.time.format.DateTimeFormatter
                                .ofPattern("uuuu-MM-dd")
                                .withResolverStyle(java.time.format.ResolverStyle.STRICT);
                        java.time.LocalDate localDate = java.time.LocalDate.parse(toStr, formatter);
                        effectiveTo = java.sql.Date.valueOf(localDate);
                    } catch (java.time.format.DateTimeParseException e) {
                        errorMsg = "Ngày kết thúc không hợp lệ.";
                    }
                }
            }
            
            if (errorMsg == null) {
                if (effectiveFrom != null && effectiveTo != null && effectiveFrom.after(effectiveTo)) {
                    errorMsg = "Ngày bắt đầu không được lớn hơn ngày kết thúc.";
                }
            }
            
            // 6. Description
            if (errorMsg == null) {
                if (description.length() > 255) {
                    errorMsg = "Mô tả không được vượt quá 255 ký tự.";
                }
            }
            
            // Handle error or save
            if (errorMsg != null) {
                request.setAttribute("errorMsg", errorMsg);
                loadList(request);
                request.getRequestDispatcher(LIST_JSP).forward(request, response);
                return;
            }
            
            // Database insert
            InsuranceRate ir = new InsuranceRate(
                0, insuranceCode, insuranceName, companyRate, employeeRate,
                description, effectiveFrom, effectiveTo, null, null, true);
            boolean success = dao.insert(ir);
            if (success) {
                request.getSession().setAttribute("successMsg", "Thêm mức bảo hiểm thành công.");
                response.sendRedirect(request.getContextPath() + LIST_URL);
            } else {
                request.setAttribute("errorMsg", "Lỗi lưu dữ liệu vào cơ sở dữ liệu.");
                loadList(request);
                request.getRequestDispatcher(LIST_JSP).forward(request, response);
            }
            return;
        }

        // ORIGINAL LOGIC for Edit
        if ("edit".equals(action) && idStr != null) {
            String insuranceCode = request.getParameter("insuranceCode");
            String insuranceName = request.getParameter("insuranceName");
            String companyRateS  = request.getParameter("companyRate");
            String employeeRateS = request.getParameter("employeeRate");
            String description   = request.getParameter("description");
            String fromStr       = request.getParameter("effectiveFrom");
            String toStr         = request.getParameter("effectiveTo");

            String errorMsg = null;

            if (insuranceCode == null || insuranceCode.trim().isEmpty()) {
                errorMsg = "Mã bảo hiểm không được trống.";
            } else if (insuranceCode.length() > 20) {
                errorMsg = "Mã bảo hiểm không được vượt quá 20 ký tự.";
            } else if (!insuranceCode.matches("^[\\p{L}0-9_\\- ]+$")) {
                errorMsg = "Mã bảo hiểm chỉ được chứa chữ cái, số, khoảng trắng, gạch ngang và gạch dưới.";
            } else if (insuranceName == null || insuranceName.trim().isEmpty()) {
                errorMsg = "Tên loại bảo hiểm không được trống.";
            } else if (insuranceName.length() > 100) {
                errorMsg = "Tên loại bảo hiểm không được vượt quá 100 ký tự.";
            }

            BigDecimal companyRate = null;
            BigDecimal employeeRate = null;

            if (errorMsg == null) {
                if (companyRateS == null || companyRateS.trim().isEmpty()) {
                    errorMsg = "Tỷ lệ DN không được trống.";
                } else {
                    try {
                        companyRate = new BigDecimal(companyRateS.trim());
                        if (companyRate.compareTo(BigDecimal.ZERO) < 0) {
                            errorMsg = "Tỷ lệ DN không được nhỏ hơn 0.";
                        } else if (companyRate.compareTo(new BigDecimal("100")) > 0) {
                            errorMsg = "Tỷ lệ DN không được lớn hơn 100.";
                        }
                    } catch (NumberFormatException e) {
                        errorMsg = "Tỷ lệ DN phải là một số.";
                    }
                }
            }

            if (errorMsg == null) {
                if (employeeRateS == null || employeeRateS.trim().isEmpty()) {
                    errorMsg = "Tỷ lệ NV không được trống.";
                } else {
                    try {
                        employeeRate = new BigDecimal(employeeRateS.trim());
                        if (employeeRate.compareTo(BigDecimal.ZERO) < 0) {
                            errorMsg = "Tỷ lệ NV không được nhỏ hơn 0.";
                        } else if (employeeRate.compareTo(new BigDecimal("100")) > 0) {
                            errorMsg = "Tỷ lệ NV không được lớn hơn 100.";
                        }
                    } catch (NumberFormatException e) {
                        errorMsg = "Tỷ lệ NV phải là một số.";
                    }
                }
            }

            Date effectiveFrom = null;
            Date effectiveTo = null;

            if (errorMsg == null) {
                try {
                    effectiveFrom = (fromStr != null && !fromStr.isBlank()) ? Date.valueOf(fromStr) : null;
                } catch (IllegalArgumentException e) {
                    errorMsg = "Ngày bắt đầu không hợp lệ.";
                }
            }
            if (errorMsg == null) {
                try {
                    effectiveTo = (toStr != null && !toStr.isBlank()) ? Date.valueOf(toStr) : null;
                } catch (IllegalArgumentException e) {
                    errorMsg = "Ngày kết thúc không hợp lệ.";
                }
            }

            if (errorMsg == null) {
                if (effectiveFrom != null && effectiveTo != null && effectiveFrom.after(effectiveTo)) {
                    errorMsg = "Ngày bắt đầu áp dụng không được lớn hơn ngày kết thúc.";
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
                int editId = Integer.parseInt(idStr);
                if (dao.isDuplicate(insuranceName, editId)) {
                    request.getSession().setAttribute("errorMsg", "Tên loại bảo hiểm đã tồn tại.");
                } else if (dao.isCodeDuplicate(insuranceCode, editId)) {
                    request.getSession().setAttribute("errorMsg", "Mã bảo hiểm đã tồn tại.");
                } else {
                    InsuranceRate ir = new InsuranceRate(
                        editId, insuranceCode, insuranceName, companyRate, employeeRate,
                        description, effectiveFrom, effectiveTo, null, null, true);
                    dao.updateWithHistory(ir, editId);
                    request.getSession().setAttribute("successMsg", "Cập nhật mức bảo hiểm thành công.");
                }
            } catch (Exception e) {
                request.getSession().setAttribute("errorMsg", "Lỗi xử lý dữ liệu.");
            }
            response.sendRedirect(request.getContextPath() + LIST_URL);
            return;
        }

        response.sendRedirect(request.getContextPath() + LIST_URL);
    }
}
