package controller.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import service.PayrollService;
import service.PayrollServiceImpl;
import service.RewardDisciplineService;
import service.RewardDisciplineServiceImpl;

import java.io.IOException;

@WebServlet("/admin/automation")
public class AdminAutomationController extends HttpServlet {

    private static final String ATTR_MESSAGE = "message";
    private static final String ATTR_ERROR   = "error";
    private static final String VIEW_PAGE    = "/admin/automation.jsp";

    private final PayrollService          payrollService = new PayrollServiceImpl();
    private final RewardDisciplineService rdService      = new RewardDisciplineServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        forwardToView(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        processAction(request, action);
        forwardToView(request, response);
    }

    private void processAction(HttpServletRequest request, String action) {
        try {
            if ("attendance".equals(action)) {
                handleAttendance(request);
            } else if ("13th_month".equals(action)) {
                handleThirteenthMonth(request);
            }
        } catch (Exception e) {
            request.setAttribute(ATTR_ERROR, "Failed to execute automation: " + e.getMessage());
        }
    }

    private void handleAttendance(HttpServletRequest request) {
        int userId    = Integer.parseInt(request.getParameter("userId"));
        int month     = Integer.parseInt(request.getParameter("month"));
        int year      = Integer.parseInt(request.getParameter("year"));
        int processed = rdService.generateAttendanceAutomations(userId, month, year);

        if (processed > 0) {
            request.setAttribute(ATTR_MESSAGE,
                    "Thực thi kịch bản chấm công tự động thành công! Đã tạo "
                            + processed + " bản ghi thưởng/phạt cho nhân viên có ID " + userId);
        } else {
            request.setAttribute(ATTR_MESSAGE,
                    "Chạy kịch bản hoàn tất, nhưng không có bản ghi mới nào được tạo cho nhân viên ID "
                            + userId + " (nhân viên đi làm đúng giờ hoặc chưa đủ số ngày hưởng thưởng chuyên cần).");
        }
    }

    private void handleThirteenthMonth(HttpServletRequest request) {
        int userId = Integer.parseInt(request.getParameter("userId"));
        int year   = Integer.parseInt(request.getParameter("year"));
        payrollService.calculate13thMonthBonus(userId, year);
        request.setAttribute(ATTR_MESSAGE, "13th Month Salary processed for User " + userId);
    }

    private void forwardToView(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            request.getRequestDispatcher(VIEW_PAGE).forward(request, response);
        } catch (ServletException | IOException e) {
            try {
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Forward failed");
            } catch (IOException ex) {
                Thread.currentThread().interrupt();
            }
        }
    }
}