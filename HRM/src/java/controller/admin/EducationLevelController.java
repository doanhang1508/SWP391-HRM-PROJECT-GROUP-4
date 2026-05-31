package controller.admin;

import dao.EducationLevelDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.EducationLevel;
import model.User;

public class EducationLevelController extends HttpServlet {

    private final EducationLevelDAO dao = new EducationLevelDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        User user = (User) session.getAttribute("currentUser");
        if (user.getRoleId() != 1) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        String action = request.getParameter("action");
        String idStr  = request.getParameter("id");

        java.util.List<model.EducationLevel> educationLevelList = dao.getAll();
        java.util.Map<Integer, Integer> empCountMap = new java.util.HashMap<>();
        for (model.EducationLevel el : educationLevelList) {
            empCountMap.put(el.getEducationLevelId(), dao.countEmployees(el.getEducationLevelId()));
        }
        request.setAttribute("educationLevelList", educationLevelList);
        request.setAttribute("empCountMap", empCountMap);
        request.getRequestDispatcher("/admin/education-level.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        String name   = request.getParameter("name");
        String desc   = request.getParameter("description");
        String idStr  = request.getParameter("id");

        if ("delete".equals(action) && idStr != null) {
            dao.delete(Integer.parseInt(idStr));
        } else if ("add".equals(action)) {
            dao.insert(new EducationLevel(0, name, desc, true));
        } else if ("edit".equals(action) && idStr != null) {
            dao.update(new EducationLevel(Integer.parseInt(idStr), name, desc, true));
        }
        response.sendRedirect(request.getContextPath() + "/admin/education-level");
    }
}
