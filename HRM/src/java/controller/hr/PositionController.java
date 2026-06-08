package controller.hr;

import dao.PositionDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.Position;
import model.User;

public class PositionController extends HttpServlet {

    private final PositionDAO dao = new PositionDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        User user = (User) session.getAttribute("currentUser");
        // ChÃ¡Â»â€° HR Manager (role 2) mÃ¡Â»â€ºi Ã„â€˜Ã†Â°Ã¡Â»Â£c quÃ¡ÂºÂ£n lÃƒÂ½ chÃ¡Â»Â©c vÃ¡Â»Â¥
        if (user.getRoleId() != 2) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        java.util.List<Position> positionList = dao.getAllIncludingInactive();
        java.util.Map<Integer, Integer> empCountMap = new java.util.HashMap<>();
        for (Position p : positionList) {
            empCountMap.put(p.getPositionId(), dao.countEmployees(p.getPositionId()));
        }
        request.setAttribute("positionList", positionList);
        request.setAttribute("empCountMap", empCountMap);
        request.getRequestDispatcher("/hr/position.jsp").forward(request, response);
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
        } else if ("toggleStatus".equals(action) && idStr != null) {
            dao.toggleStatus(Integer.parseInt(idStr));
        } else if ("add".equals(action)) {
            dao.insert(new Position(0, name, desc, true));
        } else if ("edit".equals(action) && idStr != null) {
            dao.update(new Position(Integer.parseInt(idStr), name, desc, true));
        }
        response.sendRedirect(request.getContextPath() + "/hr/position");
    }
}


