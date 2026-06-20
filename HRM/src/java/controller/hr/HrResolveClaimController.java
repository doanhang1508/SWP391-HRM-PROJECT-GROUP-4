package controller.hr;

import dao.PayrollDAO;
import dao.PayrollClaimDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import model.PayrollClaim;
import model.User;

@WebServlet(name = "HrResolveClaimController", urlPatterns = {"/hr/resolve-claim"})
public class HrResolveClaimController extends HttpServlet {

    private final PayrollDAO payrollDAO = new PayrollDAO();
    private final PayrollClaimDAO claimDAO = new PayrollClaimDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Only Role 2 (HR Manager) or Role 4 (Director) can view claims list
        if (currentUser.getRoleId() != 2 && currentUser.getRoleId() != 4) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        List<PayrollClaim> list = claimDAO.getAllClaims();
        request.setAttribute("claims", list);
        request.getRequestDispatcher("/hr/claim-list.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if (currentUser.getRoleId() != 2 && currentUser.getRoleId() != 4) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        String claimIdStr = request.getParameter("claimId");
        if (claimIdStr == null || claimIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/hr/resolve-claim");
            return;
        }

        try {
            int claimId = Integer.parseInt(claimIdStr);
            PayrollClaim claim = claimDAO.getClaimById(claimId);

            if (claim != null) {
                // Update claim status to Resolved
                if (claimDAO.resolveClaim(claimId)) {
                    // Get user id and period details to regenerate
                    int userId = claim.getPayrollId(); // Wait, in getClaimById query: u.user_id is fetched!
                    // Let's get user_id from database query. Wait, in our getClaimById: u.user_id as user_id.
                    // But in model/PayrollClaim.java, we didn't add userId property!
                    // Let's see: we can query the user_id by joining payroll inside the controller or let's get it.
                    // Oh, in model/PayrollClaim.java, we have getPayrollId(). Since Payroll has user_id, we can get Payroll.
                    model.Payroll payroll = payrollDAO.getById(claim.getPayrollId());
                    if (payroll != null) {
                        // Delete draft payroll and regenerate it
                        payrollDAO.deletePayrollDraft(payroll.getUserId(), payroll.getMonth(), payroll.getYear());
                        payrollDAO.generatePayrollDraft(payroll.getMonth(), payroll.getYear());
                        session.setAttribute("toastSuccess", "Đã duyệt khiếu nại và tự động tính toán lại bảng lương nháp!");
                    } else {
                        session.setAttribute("toastSuccess", "Đã duyệt khiếu nại!");
                    }
                } else {
                    session.setAttribute("errorMessage", "Không thể cập nhật trạng thái khiếu nại.");
                }
            }
        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "Mã khiếu nại không hợp lệ.");
        }

        response.sendRedirect(request.getContextPath() + "/hr/resolve-claim");
    }
}
