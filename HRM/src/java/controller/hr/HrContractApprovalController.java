package controller.hr;

import dao.EmployeeContractDAO;
import model.EmployeeContract;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "HrContractApprovalController", urlPatterns = {"/hr/contract-approval"})
public class HrContractApprovalController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        User currentUser = (User) session.getAttribute("currentUser");
        // Chỉ HR Manager (2) và Admin (1) được vào
        if (currentUser.getRoleId() != 1 && currentUser.getRoleId() != 2) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        String statusFilter = request.getParameter("status");
        if (statusFilter == null || statusFilter.isEmpty()) statusFilter = "all";
        String search = request.getParameter("search");

        EmployeeContractDAO ecDAO = new EmployeeContractDAO();
        List<EmployeeContract> contracts    = ecDAO.getAllApprovalContracts(statusFilter, search);
        java.util.Map<String, Integer> counts = ecDAO.getApprovalCounts();

        request.setAttribute("contracts",     contracts);
        request.setAttribute("counts",        counts);
        request.setAttribute("currentFilter", statusFilter);
        request.setAttribute("currentSearch", search);

        request.getRequestDispatcher("/hr/contract-approval.jsp").forward(request, response);
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
        if (currentUser.getRoleId() != 1 && currentUser.getRoleId() != 2) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        String action      = request.getParameter("action");
        int    contractId  = Integer.parseInt(request.getParameter("contractId"));
        int    targetUserId = Integer.parseInt(request.getParameter("userId"));

        EmployeeContractDAO ecDAO = new EmployeeContractDAO();

        if ("approve".equals(action)) {
            if (ecDAO.approveContract(contractId, targetUserId)) {
                // Gửi thông báo cho nhân viên
                dao.notificationDAO notifDao = new dao.notificationDAO();
                notifDao.create(targetUserId, "contract",
                    "Hợp đồng của bạn đã được duyệt",
                    "HR Manager " + currentUser.getFullName() + " đã phê duyệt hợp đồng của bạn. Hợp đồng có hiệu lực ngay.",
                    "/employee/my-contract");
                session.setAttribute("successMsg", "Đã phê duyệt hợp đồng thành công!");
            } else {
                session.setAttribute("errorMsg", "Phê duyệt thất bại. Hợp đồng có thể đã bị xóa hoặc thay đổi.");
            }
        } else if ("reject".equals(action)) {
            String rejectReason = request.getParameter("rejectReason");
            if (ecDAO.rejectContract(contractId, rejectReason)) {
                // Gửi thông báo cho nhân viên
                dao.notificationDAO notifDao = new dao.notificationDAO();
                notifDao.create(targetUserId, "contract",
                    "Hợp đồng của bạn đã bị từ chối",
                    "HR Manager " + currentUser.getFullName() + " đã từ chối hợp đồng. Lý do: " + (rejectReason != null ? rejectReason : "Không có lý do"),
                    "/employee/my-contract");
                session.setAttribute("successMsg", "Đã từ chối hợp đồng.");
            } else {
                session.setAttribute("errorMsg", "Từ chối thất bại.");
            }
        }

        response.sendRedirect(request.getContextPath() + "/hr/contract-approval");
    }
}
