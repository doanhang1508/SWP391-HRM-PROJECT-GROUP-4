package controller.admin;

import dao.LeaveRequestDAOImpl;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import model.LeaveType;

@WebServlet("/admin/leave-types")
public class LeaveTypeController extends HttpServlet {

    private LeaveRequestDAOImpl leaveDAO = new LeaveRequestDAOImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            List<LeaveType> list = leaveDAO.getAllLeaveTypes();
            request.setAttribute("leaveTypes", list);
            System.out.println("[LeaveTypeController] Loaded " + (list != null ? list.size() : 0) + " leave types.");
        } catch (Exception e) {
            System.err.println("[LeaveTypeController] ERROR: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Lỗi tải danh mục nghỉ phép: " + e.getMessage());
        }
        request.getRequestDispatcher("/admin/leave-type.jsp").forward(request, response);
    }
}
