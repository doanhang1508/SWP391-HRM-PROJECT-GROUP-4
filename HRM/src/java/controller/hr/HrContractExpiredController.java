package controller.hr;

import dao.EmployeeContractDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.EmployeeContract;
import model.User;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "HrContractExpiredController", urlPatterns = {"/hr/contract-expired"})
public class HrContractExpiredController extends HttpServlet {

    private EmployeeContractDAO contractDAO;

    @Override
    public void init() throws ServletException {
        contractDAO = new EmployeeContractDAO();
    }

    private boolean checkAccess(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("currentUser") : null;
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return false;
        }
        if (user.getRoleId() != 2 && user.getRoleId() != 5) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return false;
        }
        return true;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!checkAccess(req, resp)) return;

        // Lấy hợp đồng sắp hết hạn trong 30 ngày (và các hợp đồng chưa được gia hạn nhưng đã qua hạn)
        List<EmployeeContract> expiringContracts = contractDAO.getExpiringContracts(30);
        
        req.setAttribute("expiringContracts", expiringContracts);
        req.getRequestDispatcher("/hr/employees/contract-expired.jsp").forward(req, resp);
    }
}
