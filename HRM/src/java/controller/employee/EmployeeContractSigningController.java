package controller.employee;

import dao.EmployeeContractDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import model.EmployeeContract;
import model.User;

@WebServlet(name = "EmployeeContractSigningController", urlPatterns = {"/employee/contract-signing"})
public class EmployeeContractSigningController extends HttpServlet {

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
        
        // Lấy danh sách hợp đồng/phụ lục đang chờ ký
        List<EmployeeContract> pendingContracts = ecDAO.getPendingSignContracts(userId);

        request.setAttribute("pendingContracts", pendingContracts);

        // Thông báo kết quả sau khi ký/từ chối
        String msg = request.getParameter("msg");
        if (msg != null) request.setAttribute("msg", msg);

        request.getRequestDispatcher("/employee/contract-signing.jsp").forward(request, response);
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
        int userId = currentUser.getUserId();

        String action = request.getParameter("action");       // "SIGNED" | "REJECTED"
        String contractIdStr = request.getParameter("contractId");
        String rejectReason = request.getParameter("rejectReason"); // chỉ khi REJECTED

        if (action == null || contractIdStr == null) {
            response.sendRedirect(request.getContextPath() + "/employee/contract-signing?msg=error");
            return;
        }

        try {
            int contractId = Integer.parseInt(contractIdStr);
            EmployeeContractDAO ecDAO = new EmployeeContractDAO();
            
            // Cập nhật trạng thái ký
            boolean ok = ecDAO.updateSignStatus(contractId, userId, action, rejectReason);
            
            String msg = ok ? (action.equals("SIGNED") ? "signed" : "rejected") : "error";
            response.sendRedirect(request.getContextPath() + "/employee/contract-signing?msg=" + msg);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/employee/contract-signing?msg=error");
        }
    }
}
