package controller.admin;

import dao.RewardDisciplineDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import model.RewardDiscipline;

@WebServlet("/admin/reward-disciplines")
public class RewardDisciplineCategoryController extends HttpServlet {

    private RewardDisciplineDAO rdDAO = new RewardDisciplineDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            List<RewardDiscipline> list = rdDAO.getAllRewardDisciplines();
            request.setAttribute("categories", list);
        } catch (Exception e) {
            request.setAttribute("error", "Error loading categories.");
        }
        request.getRequestDispatcher("/admin/reward-discipline-category.jsp").forward(request, response);
    }
}
