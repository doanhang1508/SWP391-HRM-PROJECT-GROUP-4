package controller.hr;

import dao.TaxDAO;
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
import model.TaxBracket;
import model.TaxDeduction;
import model.User;

@WebServlet(name = "TaxConfigController", urlPatterns = {"/hr/tax-config"})
public class TaxConfigController extends HttpServlet {

    private static final String LIST_JSP = "/hr/tax-config.jsp";
    private static final String LIST_URL = "/hr/tax-config";

    private final TaxDAO taxDAO = new TaxDAO();

    private boolean checkAccess(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return false;
        }
        User user = (User) session.getAttribute("currentUser");
        if (user.getRoleId() != 1 && user.getRoleId() != 2 && user.getRoleId() != 5) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return false;
        }
        return true;
    }

    private void loadList(HttpServletRequest request) {
        List<TaxBracket> brackets = taxDAO.getAllTaxBrackets();
        List<TaxDeduction> deductions = taxDAO.getAllTaxDeductions();
        
        request.setAttribute("taxBracketList", brackets);
        request.setAttribute("taxDeductionList", deductions);
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
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");
        int userId = currentUser != null ? currentUser.getUserId() : 0;

        try {
            if ("add_bracket".equals(action) || "edit_bracket".equals(action)) {
                int bracketNo = Integer.parseInt(request.getParameter("bracketNo"));
                BigDecimal incomeFrom = new BigDecimal(request.getParameter("incomeFrom"));
                String incomeToStr = request.getParameter("incomeTo");
                BigDecimal incomeTo = (incomeToStr != null && !incomeToStr.trim().isEmpty()) ? new BigDecimal(incomeToStr) : null;
                BigDecimal rate = new BigDecimal(request.getParameter("rate"));
                Date effectiveFrom = Date.valueOf(request.getParameter("effectiveFrom"));
                String toStr = request.getParameter("effectiveTo");
                Date effectiveTo = (toStr != null && !toStr.isBlank()) ? Date.valueOf(toStr) : null;

                TaxBracket b = new TaxBracket();
                b.setBracketNo(bracketNo);
                b.setIncomeFrom(incomeFrom);
                b.setIncomeTo(incomeTo);
                b.setRate(rate);
                b.setEffectiveFrom(effectiveFrom);
                b.setEffectiveTo(effectiveTo);
                b.setRoundingRule("HALF_UP");
                b.setStatus(true);
                
                if ("add_bracket".equals(action)) {
                    b.setCreatedBy(userId);
                    taxDAO.insertTaxBracket(b);
                    session.setAttribute("successMsg", "Thêm bậc thuế thành công.");
                } else {
                    int id = Integer.parseInt(request.getParameter("bracketId"));
                    b.setBracketId(id);
                    b.setUpdatedBy(userId);
                    taxDAO.updateTaxBracket(b);
                    session.setAttribute("successMsg", "Cập nhật bậc thuế thành công.");
                }

            } else if ("delete_bracket".equals(action)) {
                int bracketId = Integer.parseInt(request.getParameter("bracketId"));
                taxDAO.deleteTaxBracket(bracketId);
                session.setAttribute("successMsg", "Xóa bậc thuế thành công.");
                
            } else if ("add_deduction".equals(action) || "edit_deduction".equals(action)) {
                String deductionType = request.getParameter("deductionType");
                String deductionName = request.getParameter("deductionName");
                BigDecimal amount = new BigDecimal(request.getParameter("amount"));
                Date effectiveFrom = Date.valueOf(request.getParameter("effectiveFrom"));
                String toStr = request.getParameter("effectiveTo");
                Date effectiveTo = (toStr != null && !toStr.isBlank()) ? Date.valueOf(toStr) : null;

                TaxDeduction d = new TaxDeduction();
                d.setDeductionType(deductionType);
                d.setDeductionName(deductionName);
                d.setAmount(amount);
                d.setEffectiveFrom(effectiveFrom);
                d.setEffectiveTo(effectiveTo);
                d.setStatus(true);

                if ("add_deduction".equals(action)) {
                    d.setCreatedBy(userId);
                    taxDAO.insertTaxDeduction(d);
                    session.setAttribute("successMsg", "Thêm cấu hình giảm trừ thành công.");
                } else {
                    int id = Integer.parseInt(request.getParameter("deductionId"));
                    d.setDeductionId(id);
                    d.setUpdatedBy(userId);
                    taxDAO.updateTaxDeduction(d);
                    session.setAttribute("successMsg", "Cập nhật cấu hình giảm trừ thành công.");
                }

            } else if ("delete_deduction".equals(action)) {
                int id = Integer.parseInt(request.getParameter("deductionId"));
                taxDAO.deleteTaxDeduction(id);
                session.setAttribute("successMsg", "Xóa cấu hình giảm trừ thành công.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMsg", "Lỗi xử lý dữ liệu: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + LIST_URL);
    }
}
