package controller.hr;

import dao.RewardDisciplineDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;
import java.util.List;
import model.EmployeeRewardDiscipline;
import model.RewardDiscipline;
import service.RewardDisciplineService;
import service.RewardDisciplineServiceImpl;

@WebServlet("/hr/manual-reward-discipline")
public class ManualRewardDisciplineController extends HttpServlet {

    private RewardDisciplineService rdService = new RewardDisciplineServiceImpl();
    private RewardDisciplineDAO rdDAO = new RewardDisciplineDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        List<RewardDiscipline> types = rdDAO.getAllRewardDisciplines();
        req.setAttribute("types", types);
        req.getRequestDispatcher("/hr/manual_reward_discipline.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
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

            boolean success = rdService.insertManualRecord(erd);
            if (success) {
                req.setAttribute("message", "Record inserted successfully.");
            } else {
                req.setAttribute("error", "Failed to insert record.");
            }
        } catch (Exception e) {
            req.setAttribute("error", "Invalid input format.");
        }
        
        doGet(req, resp);
    }
}
