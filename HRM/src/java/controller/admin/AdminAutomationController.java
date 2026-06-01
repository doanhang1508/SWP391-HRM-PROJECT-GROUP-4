package controller.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDate;
import service.PayrollService;
import service.PayrollServiceImpl;
import service.RewardDisciplineService;
import service.RewardDisciplineServiceImpl;

@WebServlet("/admin/automation")
public class AdminAutomationController extends HttpServlet {

    private PayrollService payrollService = new PayrollServiceImpl();
    private RewardDisciplineService rdService = new RewardDisciplineServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("/admin/automation.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        try {
            if ("attendance".equals(action)) {
                int userId = Integer.parseInt(request.getParameter("userId"));
                int month = Integer.parseInt(request.getParameter("month"));
                int year = Integer.parseInt(request.getParameter("year"));
                int processed = rdService.generateAttendanceAutomations(userId, month, year);
                if (processed > 0) {
                    request.setAttribute("message", "Thực thi kịch bản chấm công tự động thành công! Đã tạo " + processed + " bản ghi thưởng/phạt cho nhân viên có ID " + userId);
                } else {
                    request.setAttribute("message", "Chạy kịch bản hoàn tất, nhưng không có bản ghi mới nào được tạo cho nhân viên ID " + userId + " (nhân viên đi làm đúng giờ hoặc chưa đủ số ngày hưởng thưởng chuyên cần).");
                }
                
            } else if ("13th_month".equals(action)) {
                int userId = Integer.parseInt(request.getParameter("userId"));
                int year = Integer.parseInt(request.getParameter("year"));
                payrollService.calculate13thMonthBonus(userId, year);
                request.setAttribute("message", "13th Month Salary processed for User " + userId);
            }
        } catch (Exception e) {
            request.setAttribute("error", "Failed to execute automation: " + e.getMessage());
        }
        
        doGet(request, response);
    }
}
