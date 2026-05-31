package controller.admin;

import dao.ContractTypeDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.ContractType;
import model.User;

public class ContractTypeController extends HttpServlet {

    private final ContractTypeDAO dao = new ContractTypeDAO();

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

        java.util.List<model.ContractType> contractTypeList = dao.getAll();
        java.util.Map<Integer, Integer> empCountMap = new java.util.HashMap<>();
        for (model.ContractType ct : contractTypeList) {
            empCountMap.put(ct.getContractTypeId(), dao.countEmployees(ct.getContractTypeId()));
        }
        request.setAttribute("contractTypeList", contractTypeList);
        request.setAttribute("empCountMap", empCountMap);
        request.getRequestDispatcher("/admin/contract-type.jsp").forward(request, response);
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
            dao.insert(new ContractType(0, name, desc, true));
        } else if ("edit".equals(action) && idStr != null) {
            dao.update(new ContractType(Integer.parseInt(idStr), name, desc, true));
        }
        response.sendRedirect(request.getContextPath() + "/admin/contract-type");
    }
}
