package controller.hr;

import dao.RewardDisciplineDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;
import java.util.List;
import model.EmployeeRewardDiscipline;
import model.RewardDiscipline;
import model.User;

/**
 * ManualRewardDisciplineController — HR Staff/Manager nhập khen thưởng/kỷ luật thủ công.
 * URL: /hr/manual-reward-discipline
 * Roles: HR Manager (2), HR Staff (5)
 */
@WebServlet("/hr/manual-reward-discipline")
public class ManualRewardDisciplineController extends HttpServlet {

    private final RewardDisciplineDAO rdDAO = new RewardDisciplineDAO();

    private boolean checkAccess(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
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
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!checkAccess(req, resp)) return;
        List<RewardDiscipline> types = rdDAO.getAllRewardDisciplines();
        dao.UserDAO userDAO = new dao.UserDAO();
        List<User> users = userDAO.getAllUsers();
        req.setAttribute("types", types);
        req.setAttribute("users", users);
        req.getRequestDispatcher("/hr/manual_reward_discipline.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!checkAccess(req, resp)) return;
        try {
            int userId = Integer.parseInt(req.getParameter("userId"));
            int rewardDisciplineId = Integer.parseInt(req.getParameter("rewardDisciplineId"));
            BigDecimal amount = new BigDecimal(req.getParameter("amount"));
            String note = req.getParameter("note");
            Date appliedDate = Date.valueOf(req.getParameter("appliedDate"));

            EmployeeRewardDiscipline erd = new EmployeeRewardDiscipline();
            erd.setUserId(userId);
            erd.setRewardDisciplineId(rewardDisciplineId);
            erd.setAmount(amount);
            erd.setNote(note);
            erd.setAppliedDate(appliedDate);

            boolean success = rdDAO.insertManualRecord(erd);
            if (success) {
                req.setAttribute("message", "Đã ghi nhận khen thưởng/kỷ luật thành công.");
            } else {
                req.setAttribute("error", "Ghi nhận thất bại, vui lòng thử lại.");
            }
        } catch (Exception e) {
            req.setAttribute("error", "Dữ liệu nhập không hợp lệ: " + e.getMessage());
        }

        doGet(req, resp);
    }
}
