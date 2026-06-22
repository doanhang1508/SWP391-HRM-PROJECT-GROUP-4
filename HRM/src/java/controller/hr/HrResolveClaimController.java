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
import java.math.BigDecimal;
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

        // Allow HR Manager (2), Director (4), HR Staff (5), Accountant (8)
        int roleId = currentUser.getRoleId();
        if (roleId != 2 && roleId != 4 && roleId != 5 && roleId != 8) {
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

        int roleId = currentUser.getRoleId();
        if (roleId != 2 && roleId != 4 && roleId != 5 && roleId != 8) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        String claimIdStr = request.getParameter("claimId");
        String action = request.getParameter("action");

        if (claimIdStr == null || action == null) {
            response.sendRedirect(request.getContextPath() + "/hr/resolve-claim");
            return;
        }

        try {
            int claimId = Integer.parseInt(claimIdStr);
            PayrollClaim claim = claimDAO.getClaimById(claimId);

            if (claim == null) {
                session.setAttribute("errorMessage", "Không tìm thấy yêu cầu khiếu nại.");
                response.sendRedirect(request.getContextPath() + "/hr/resolve-claim");
                return;
            }

            boolean success = false;

            // HR Staff (Role 5)
            if (roleId == 5) {
                String note = request.getParameter("hrStaffNote");
                claim.setHrStaffNote(note != null ? note.trim() : "");
                claim.setHrStaffId(currentUser.getUserId());
                if ("hrStaffForwardManager".equals(action)) {
                    claim.setStatus("HR Manager Reviewing");
                    success = claimDAO.updateClaimWorkflow(claim);
                } else if ("hrStaffForwardAccountant".equals(action)) {
                    claim.setStatus("Accountant Checking");
                    success = claimDAO.updateClaimWorkflow(claim);
                } else if ("hrStaffClose".equals(action)) {
                    claim.setStatus("Resolved");
                    success = claimDAO.updateClaimWorkflow(claim);
                } else if ("hrStaffReject".equals(action)) {
                    claim.setStatus("Rejected");
                    success = claimDAO.updateClaimWorkflow(claim);
                }
            }
            // Accountant (Role 8)
            else if (roleId == 8) {
                String note = request.getParameter("accountantNote");
                String adjustmentStr = request.getParameter("proposedAdjustment");
                claim.setAccountantNote(note != null ? note.trim() : "");
                claim.setAccountantId(currentUser.getUserId());
                
                BigDecimal proposedAdjustment = BigDecimal.ZERO;
                if (adjustmentStr != null && !adjustmentStr.trim().isEmpty()) {
                    try {
                        proposedAdjustment = new BigDecimal(adjustmentStr.trim());
                    } catch (NumberFormatException e) {
                        // ignore
                    }
                }
                claim.setProposedAdjustment(proposedAdjustment);

                if ("accountantForward".equals(action) || "accountantCheckDone".equals(action)) {
                    claim.setStatus("Pending Close");
                    success = claimDAO.updateClaimWorkflow(claim);
                } else if ("accountantResolvePayment".equals(action)) {
                    claim.setStatus("Resolved");
                    success = claimDAO.updateClaimWorkflow(claim);
                    if (success) {
                        triggerRecalculation(claim.getPayrollId());
                    }
                } else if ("accountantReject".equals(action)) {
                    claim.setStatus("Rejected");
                    success = claimDAO.updateClaimWorkflow(claim);
                }
            }
            // HR Manager (Role 2)
            else if (roleId == 2) {
                String note = request.getParameter("hrManagerNote");
                claim.setHrManagerNote(note != null ? note.trim() : "");
                claim.setHrManagerId(currentUser.getUserId());

                if ("hrManagerResolve".equals(action) || "hrManagerClose".equals(action)) {
                    claim.setStatus("Resolved");
                    success = claimDAO.updateClaimWorkflow(claim);
                    if (success) {
                        triggerRecalculation(claim.getPayrollId());
                    }
                } else if ("hrManagerReject".equals(action)) {
                    claim.setStatus("Rejected");
                    success = claimDAO.updateClaimWorkflow(claim);
                } else if ("hrManagerForwardDirector".equals(action)) {
                    claim.setStatus("Director Reviewing");
                    success = claimDAO.updateClaimWorkflow(claim);
                } else if ("hrManagerRequestRecheck".equals(action)) {
                    claim.setStatus("Accountant Checking");
                    success = claimDAO.updateClaimWorkflow(claim);
                }
            }
            // Director (Role 4)
            else if (roleId == 4) {
                String note = request.getParameter("directorNote");
                claim.setDirectorNote(note != null ? note.trim() : "");
                claim.setDirectorId(currentUser.getUserId());

                if ("directorApprove".equals(action)) {
                    claim.setStatus("Accountant Adjusting");
                    success = claimDAO.updateClaimWorkflow(claim);
                } else if ("directorReject".equals(action)) {
                    claim.setStatus("Rejected");
                    success = claimDAO.updateClaimWorkflow(claim);
                }
            }

            if (success) {
                session.setAttribute("toastSuccess", "Cập nhật tiến trình xử lý khiếu nại thành công!");
            } else {
                session.setAttribute("errorMessage", "Cập nhật tiến trình xử lý thất bại.");
            }

        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "Dữ liệu không hợp lệ.");
        }

        response.sendRedirect(request.getContextPath() + "/hr/resolve-claim");
    }

    private void triggerRecalculation(int payrollId) {
        model.Payroll payroll = payrollDAO.getById(payrollId);
        if (payroll != null) {
            payrollDAO.deletePayrollDraft(payroll.getUserId(), payroll.getMonth(), payroll.getYear());
            payrollDAO.generatePayrollDraft(payroll.getMonth(), payroll.getYear());
        }
    }
}
