package controller.hr;

import dao.DepartmentDAO;
import dao.EmployeeContractDAO;
import model.Department;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.OutputStream;
import java.sql.Date;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@WebServlet(name = "HrReportController", urlPatterns = {"/hr/report"})
public class HrReportController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");
        
        // Chỉ Admin (1), HR Manager (2), Director (4), HR Staff (5) được xem
        if (currentUser == null || (currentUser.getRoleId() != 1 && currentUser.getRoleId() != 2 
                && currentUser.getRoleId() != 4 && currentUser.getRoleId() != 5)) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }

        // Đọc parameters bộ lọc
        String fromDateStr = request.getParameter("fromDate");
        String toDateStr = request.getParameter("toDate");
        String deptIdStr = request.getParameter("departmentId");

        // Mặc định: không lọc theo ngày (hiển thị tất cả) để các thống kê (Quá hạn, An toàn) tính chính xác
        Date fromDate = (fromDateStr != null && !fromDateStr.isEmpty()) ? Date.valueOf(fromDateStr) : null;
        Date toDate = (toDateStr != null && !toDateStr.isEmpty()) ? Date.valueOf(toDateStr) : null;
        Integer departmentId = (deptIdStr != null && !deptIdStr.isEmpty() && !"-1".equals(deptIdStr)) ? Integer.parseInt(deptIdStr) : null;

        // Load data for dropdown
        DepartmentDAO deptDAO = new DepartmentDAO();
        List<Department> departments = deptDAO.getAll();
        request.setAttribute("departments", departments);

        // Fetch reports data
        EmployeeContractDAO ecDAO = new EmployeeContractDAO();
        List<Map<String, Object>> reportData = ecDAO.getExpiringContracts(fromDate, toDate, departmentId);
        
        request.setAttribute("reportData", reportData);
        request.setAttribute("fromDate", fromDate != null ? fromDate.toString() : "");
        request.setAttribute("toDate", toDate != null ? toDate.toString() : "");
        request.setAttribute("departmentId", departmentId != null ? departmentId : -1);

        request.getRequestDispatcher("/hr/hr-report.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if ("exportExcel".equals(action)) {
            // Đọc lại filter
            String fromDateStr = request.getParameter("fromDate");
            String toDateStr = request.getParameter("toDate");
            String deptIdStr = request.getParameter("departmentId");

            Date fromDate = (fromDateStr != null && !fromDateStr.isEmpty()) ? Date.valueOf(fromDateStr) : null;
            Date toDate = (toDateStr != null && !toDateStr.isEmpty()) ? Date.valueOf(toDateStr) : null;
            Integer departmentId = (deptIdStr != null && !deptIdStr.isEmpty() && !"-1".equals(deptIdStr)) ? Integer.parseInt(deptIdStr) : null;

            EmployeeContractDAO ecDAO = new EmployeeContractDAO();
            List<Map<String, Object>> reportData = ecDAO.getExpiringContracts(fromDate, toDate, departmentId);

            // Xuất ra định dạng CSV (Có thể mở bằng Excel bình thường).
            // Dùng CSV để code chạy được ngay mà không cần add file .jar thư viện Apache POI.
            response.setContentType("text/csv; charset=UTF-8");
            response.setHeader("Content-Disposition", "attachment; filename=\"Bao_Cao_Hop_Dong.csv\"");
            
            try (OutputStream os = response.getOutputStream()) {
                // BOM for UTF-8 Excel compatibility (giúp Excel đọc không bị lỗi font tiếng Việt)
                os.write(239);
                os.write(187);
                os.write(191);
                
                String header = "Mã NV,Tên NV,Phòng ban,Loại hợp đồng,Ngày hết hạn,Số ngày còn lại\n";
                os.write(header.getBytes("UTF-8"));
                
                for (Map<String, Object> row : reportData) {
                    StringBuilder line = new StringBuilder();
                    line.append(row.get("userId")).append(",");
                    line.append("\"").append(row.get("fullName")).append("\",");
                    line.append("\"").append(row.get("departmentName")).append("\",");
                    line.append("\"").append(row.get("typeName")).append("\",");
                    line.append(row.get("endDate")).append(",");
                    line.append(row.get("daysLeft")).append("\n");
                    os.write(line.toString().getBytes("UTF-8"));
                }
            }
        }
    }
}
