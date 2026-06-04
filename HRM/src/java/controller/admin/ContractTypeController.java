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
        // Chỉ HR Manager (role 2) mới được quản lý loại hợp đồng
        if (user.getRoleId() != 2) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        java.util.List<ContractType> contractTypeList = dao.getAllIncludingInactive();
        java.util.Map<Integer, Integer> empCountMap = new java.util.HashMap<>();
        for (ContractType ct : contractTypeList) {
            empCountMap.put(ct.getContractTypeId(), dao.countEmployees(ct.getContractTypeId()));
        }
        request.setAttribute("contractTypeList", contractTypeList);
        request.setAttribute("empCountMap", empCountMap);
        request.getRequestDispatcher("/hr/contract-type.jsp").forward(request, response);
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
        String durationStr = request.getParameter("duration");
        String durationUnit = request.getParameter("durationUnit");

        Integer duration = null;
        if (durationStr != null && !durationStr.trim().isEmpty()) {
            try {
                duration = Integer.parseInt(durationStr.trim());
            } catch (NumberFormatException e) {
                // Keep it null
            }
        }

        if ("delete".equals(action) && idStr != null) {
            dao.changeStatus(Integer.parseInt(idStr), false);
        } else if ("deactivate".equals(action) && idStr != null) {
            dao.changeStatus(Integer.parseInt(idStr), false);
        } else if ("activate".equals(action) && idStr != null) {
            dao.changeStatus(Integer.parseInt(idStr), true);
        } else if ("add".equals(action)) {
            dao.insert(new ContractType(0, name, desc, duration, durationUnit, true, null, null));
        } else if ("edit".equals(action) && idStr != null) {
            dao.update(new ContractType(Integer.parseInt(idStr), name, desc, duration, durationUnit, true, null, null));
        }
        response.sendRedirect(request.getContextPath() + "/admin/contract-type");
    }
}
