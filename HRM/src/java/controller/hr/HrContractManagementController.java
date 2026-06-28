package controller.hr;

import dao.EmployeeContractDAO;
import model.EmployeeContract;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet(name = "HrContractManagementController", urlPatterns = {"/hr/contracts"})
public class HrContractManagementController extends HttpServlet {

    private EmployeeContractDAO contractDAO;

    @Override
    public void init() throws ServletException {
        contractDAO = new EmployeeContractDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
            
        String statusFilter = request.getParameter("status");
        if (statusFilter == null || statusFilter.isEmpty()) {
            statusFilter = "all";
        }
        
        String searchQuery = request.getParameter("search");
        
        // Lấy thống kê số lượng
        Map<String, Integer> counts = contractDAO.getContractCounts();
        
        // Lấy danh sách hợp đồng theo filter
        List<EmployeeContract> contracts = contractDAO.getAllContractsWithSearch(statusFilter, searchQuery);
        
        // Lấy danh sách hợp đồng sắp hết hạn cho widget (Cần gia hạn sớm)
        // Lọc trực tiếp từ DB bằng hàm search với bộ lọc 'expiring'
        List<EmployeeContract> expiringSoonList = contractDAO.getAllContractsWithSearch("expiring", null);
        
        // Lấy thống kê phân loại hợp đồng cho widget (Phân loại hợp đồng)
        List<Map<String, Object>> typeStats = contractDAO.getContractTypeStats();

        request.setAttribute("counts", counts);
        request.setAttribute("contracts", contracts);
        request.setAttribute("expiringSoonList", expiringSoonList);
        request.setAttribute("typeStats", typeStats);
        request.setAttribute("currentFilter", statusFilter);
        request.setAttribute("currentSearch", searchQuery);
        
        request.getRequestDispatcher("/hr/contract-list.jsp").forward(request, response);
    }
}
