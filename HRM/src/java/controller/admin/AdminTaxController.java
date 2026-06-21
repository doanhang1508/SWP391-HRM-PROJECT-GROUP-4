package controller.admin;

import dao.AuditLogDAO;
import dao.TaxBracketDAO;
import dao.TaxDeductionDAO;
import model.AuditLog;
import model.TaxBracket;
import model.TaxDeduction;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Date;
import java.time.LocalDate;
import java.util.List;

@WebServlet(name = "AdminTaxController", urlPatterns = {"/admin/tax"})
public class AdminTaxController extends HttpServlet {

    private TaxBracketDAO bracketDAO;
    private TaxDeductionDAO deductionDAO;
    private AuditLogDAO auditDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        bracketDAO = new TaxBracketDAO();
        deductionDAO = new TaxDeductionDAO();
        auditDAO = new AuditLogDAO();
    }

    private boolean checkAccess(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        User user = (User) req.getSession().getAttribute("currentUser");
        if (user == null || user.getRoleId() != 1) { // 1 = Admin
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return false;
        }
        return true;
    }

    private int getInt(HttpServletRequest req, String param, int defaultVal) {
        try {
            String val = req.getParameter(param);
            if (val != null && !val.isBlank()) {
                return Integer.parseInt(val);
            }
        } catch (NumberFormatException e) {
            // ignore
        }
        return defaultVal;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!checkAccess(req, resp)) return;

        String action = req.getParameter("action");
        if (action == null) action = "rules";

        switch (action) {
            case "auditLog":
                showAuditLog(req, resp);
                break;
            case "rules":
            default:
                showTaxRules(req, resp);
                break;
        }
    }

    private void showTaxRules(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Date today = Date.valueOf(LocalDate.now());
        List<TaxBracket> brackets = bracketDAO.getEffectiveBrackets(today);
        List<TaxDeduction> deductions = deductionDAO.getEffectiveDeductions(today);

        req.setAttribute("brackets", brackets);
        req.setAttribute("deductions", deductions);

        req.getRequestDispatcher("/admin/tax-rules.jsp").forward(req, resp);
    }

    private void showAuditLog(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String entityType = req.getParameter("entityType");
        int limit = getInt(req, "limit", 100);
        List<AuditLog> logs;
        if (entityType != null && !entityType.isBlank()) {
            logs = auditDAO.getByEntityType(entityType, limit);
        } else {
            logs = auditDAO.getRecentLogs(limit);
        }
        req.setAttribute("auditLogs", logs);
        req.setAttribute("entityType", entityType);
        req.getRequestDispatcher("/admin/audit-log.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!checkAccess(req, resp)) return;

        String action = req.getParameter("action");
        if (action == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/tax?action=rules");
            return;
        }

        try {
            switch (action) {
                case "saveBracket":
                    saveBracket(req, resp);
                    break;
                case "saveDeduction":
                    saveDeduction(req, resp);
                    break;
                default:
                    resp.sendRedirect(req.getContextPath() + "/admin/tax?action=rules");
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.getSession().setAttribute("errorMsg", "Có lỗi xảy ra: " + e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/admin/tax?action=rules");
        }
    }

    private void saveBracket(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int bracketId = getInt(req, "bracketId", 0);
        int bracketNo = getInt(req, "bracketNo", 0);
        String incomeFromStr = req.getParameter("incomeFrom");
        String incomeToStr = req.getParameter("incomeTo");
        String rateStr = req.getParameter("rate");
        String effectiveFromStr = req.getParameter("effectiveFrom");
        String effectiveToStr = req.getParameter("effectiveTo");
        String roundingRule = req.getParameter("roundingRule");
        int status = getInt(req, "status", 1);

        TaxBracket tb = bracketId > 0 ? bracketDAO.getById(bracketId) : new TaxBracket();
        if (tb == null) tb = new TaxBracket();

        tb.setBracketNo(bracketNo);
        tb.setIncomeFrom(new java.math.BigDecimal(incomeFromStr));
        if (incomeToStr != null && !incomeToStr.isBlank()) {
            tb.setIncomeTo(new java.math.BigDecimal(incomeToStr));
        } else {
            tb.setIncomeTo(null);
        }
        tb.setRate(new java.math.BigDecimal(rateStr));
        tb.setEffectiveFrom(Date.valueOf(effectiveFromStr));
        if (effectiveToStr != null && !effectiveToStr.isBlank()) {
            tb.setEffectiveTo(Date.valueOf(effectiveToStr));
        } else {
            tb.setEffectiveTo(null);
        }
        tb.setRoundingRule(roundingRule != null && !roundingRule.isBlank() ? roundingRule : "HALF_UP");
        tb.setStatus(status);

        User currentUser = (User) req.getSession().getAttribute("currentUser");
        boolean success;
        if (bracketId > 0) {
            tb.setUpdatedBy(currentUser.getUserId());
            success = bracketDAO.update(tb);
            AuditLog al = new AuditLog();
            al.setEntityType("TaxBracket");
            al.setEntityId(bracketId);
            al.setAction("UPDATE");
            al.setChangedBy(currentUser.getUserId());
            al.setDescription("Cập nhật bậc thuế số " + bracketNo);
            al.setIpAddress(req.getRemoteAddr());
            auditDAO.insert(al);
        } else {
            tb.setCreatedBy(currentUser.getUserId());
            success = bracketDAO.insert(tb);
            AuditLog al = new AuditLog();
            al.setEntityType("TaxBracket");
            al.setEntityId(0);
            al.setAction("CREATE");
            al.setChangedBy(currentUser.getUserId());
            al.setDescription("Tạo bậc thuế mới số " + bracketNo);
            al.setIpAddress(req.getRemoteAddr());
            auditDAO.insert(al);
        }

        if (success) {
            req.getSession().setAttribute("successMsg", "Cập nhật biểu thuế thành công!");
        } else {
            req.getSession().setAttribute("errorMsg", "Không thể cập nhật biểu thuế!");
        }
        resp.sendRedirect(req.getContextPath() + "/admin/tax?action=rules");
    }

    private void saveDeduction(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int deductionId = getInt(req, "deductionId", 0);
        String deductionType = req.getParameter("deductionType");
        String deductionName = req.getParameter("deductionName");
        String amountStr = req.getParameter("amount");
        String effectiveFromStr = req.getParameter("effectiveFrom");
        String effectiveToStr = req.getParameter("effectiveTo");
        int status = getInt(req, "status", 1);

        TaxDeduction td = deductionId > 0 ? deductionDAO.getById(deductionId) : new TaxDeduction();
        if (td == null) td = new TaxDeduction();

        td.setDeductionType(deductionType);
        td.setDeductionName(deductionName);
        td.setAmount(new java.math.BigDecimal(amountStr));
        td.setEffectiveFrom(Date.valueOf(effectiveFromStr));
        if (effectiveToStr != null && !effectiveToStr.isBlank()) {
            td.setEffectiveTo(Date.valueOf(effectiveToStr));
        } else {
            td.setEffectiveTo(null);
        }
        td.setStatus(status);

        User currentUser = (User) req.getSession().getAttribute("currentUser");
        boolean success;
        if (deductionId > 0) {
            td.setUpdatedBy(currentUser.getUserId());
            success = deductionDAO.update(td);
            AuditLog al = new AuditLog();
            al.setEntityType("TaxDeduction");
            al.setEntityId(deductionId);
            al.setAction("UPDATE");
            al.setChangedBy(currentUser.getUserId());
            al.setDescription("Cập nhật mức giảm trừ: " + deductionName);
            al.setIpAddress(req.getRemoteAddr());
            auditDAO.insert(al);
        } else {
            td.setCreatedBy(currentUser.getUserId());
            success = deductionDAO.insert(td);
            AuditLog al = new AuditLog();
            al.setEntityType("TaxDeduction");
            al.setEntityId(0);
            al.setAction("CREATE");
            al.setChangedBy(currentUser.getUserId());
            al.setDescription("Tạo mức giảm trừ: " + deductionName);
            al.setIpAddress(req.getRemoteAddr());
            auditDAO.insert(al);
        }

        if (success) {
            req.getSession().setAttribute("successMsg", "Cập nhật mức giảm trừ thành công!");
        } else {
            req.getSession().setAttribute("errorMsg", "Không thể cập nhật mức giảm trừ!");
        }
        resp.sendRedirect(req.getContextPath() + "/admin/tax?action=rules");
    }
}
