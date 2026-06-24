package controller.hr;

import dao.DepartmentDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.Department;
import model.User;

public class DepartmentController extends HttpServlet {

    private final DepartmentDAO dao = new DepartmentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        User user = (User) session.getAttribute("currentUser");
        // HR Manager (role 2) và HR Staff (role 5) được quản lý phòng ban
        if (user.getRoleId() != 2 && user.getRoleId() != 5) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        java.util.List<Department> departmentList = dao.getAllIncludingInactive();
        java.util.Map<Integer, Integer> empCountMap = new java.util.HashMap<>();
        for (Department d : departmentList) {
            empCountMap.put(d.getDepartmentId(), dao.countEmployees(d.getDepartmentId()));
        }
        request.setAttribute("departmentList", departmentList);
        request.setAttribute("empCountMap", empCountMap);
        request.getRequestDispatcher("/hr/department.jsp").forward(request, response);
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
         User user = (User) session.getAttribute("currentUser");
        // HR Manager (role 2) và HR Staff (role 5) được quản lý phòng ban
        if (user.getRoleId() != 2 && user.getRoleId() != 5) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        String action = request.getParameter("action");
        String name   = request.getParameter("name");
        String desc   = request.getParameter("description");
        String idStr  = request.getParameter("id");

        if ("toggleStatus".equals(action) && idStr != null) {
            dao.toggleStatus(Integer.parseInt(idStr));
        } else if ("add".equals(action)) {
            dao.insert(new Department(0, name, desc, true));
        } else if ("edit".equals(action) && idStr != null) {
            dao.update(new Department(Integer.parseInt(idStr), name, desc, true));
        }
        response.sendRedirect(request.getContextPath() + "/hr/department");
    }
}


