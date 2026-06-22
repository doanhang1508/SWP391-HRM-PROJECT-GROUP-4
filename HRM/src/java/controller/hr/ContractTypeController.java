package controller.hr;

import dao.ContractTypeDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import model.ContractType;
import model.User;

@WebServlet("/hr/contract-type")
public class ContractTypeController extends HttpServlet {

    private static final String ATTR_CURRENT_USER = "currentUser";
    private static final String LOGIN_URL = "/login";
    private static final String DASHBOARD_URL = "/dashboard";
    private static final String REDIRECT_URL = "/hr/contract-type";
    private static final String VIEW_PAGE = "/hr/contract-type.jsp";

    private final ContractTypeDAO dao = new ContractTypeDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) {
        if (!isAuthorized(request, response)) {
            return;
        }

        List<ContractType> contractTypeList = dao.getAllIncludingInactive();
        Map<Integer, Integer> empCountMap = new HashMap<>();
        for (ContractType ct : contractTypeList) {
            empCountMap.put(ct.getContractTypeId(), dao.countEmployees(ct.getContractTypeId()));
        }

        request.setAttribute("contractTypeList", contractTypeList);
        request.setAttribute("empCountMap", empCountMap);
        forwardToView(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) {
        setEncoding(request);

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute(ATTR_CURRENT_USER) == null) {
            redirect(response, request.getContextPath() + LOGIN_URL);
            return;
        }

        String action = request.getParameter("action");
        String name = request.getParameter("name");
        String desc = request.getParameter("description");
        String idStr = request.getParameter("id");
        String durationStr = request.getParameter("duration");
        String durationUnit = request.getParameter("durationUnit");

        Integer duration = parseDuration(durationStr);
        processAction(action, idStr, name, desc, duration, durationUnit);
        redirect(response, request.getContextPath() + REDIRECT_URL);
    }

    // Ã¢â€â‚¬Ã¢â€â‚¬ Action processing Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
    private void processAction(String action, String idStr,
            String name, String desc,
            Integer duration, String durationUnit) {
        if ("delete".equals(action) || "deactivate".equals(action)) {
            changeStatusIfIdPresent(idStr, false);
        } else if ("activate".equals(action)) {
            changeStatusIfIdPresent(idStr, true);
        } else if ("add".equals(action)) {
            dao.insert(new ContractType(0, name, desc, duration, durationUnit, true, null, null));
        } else if ("edit".equals(action) && idStr != null) {
            dao.update(new ContractType(parseInt(idStr), name, desc, duration, durationUnit, true, null, null));
        }
    }

    private void changeStatusIfIdPresent(String idStr, boolean active) {
        if (idStr != null) {
            dao.changeStatus(parseInt(idStr), active);
        }
    }

    // Ã¢â€â‚¬Ã¢â€â‚¬ Auth Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
    private boolean isAuthorized(HttpServletRequest request, HttpServletResponse response) {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute(ATTR_CURRENT_USER) == null) {
            redirect(response, request.getContextPath() + LOGIN_URL);
            return false;
        }
        User user = (User) session.getAttribute(ATTR_CURRENT_USER);
        if (user.getRoleId() != 2 && user.getRoleId() != 5) {
            redirect(response, request.getContextPath() + DASHBOARD_URL);
            return false;
        }
        return true;
    }

    // Ã¢â€â‚¬Ã¢â€â‚¬ Helpers Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
    private Integer parseDuration(String durationStr) {
        if (durationStr != null && !durationStr.trim().isEmpty()) {
            try {
                return Integer.parseInt(durationStr.trim());
            } catch (NumberFormatException e) {
                // Return null if unparseable
            }
        }
        return null;
    }

    private int parseInt(String value) {
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    private void forwardToView(HttpServletRequest request, HttpServletResponse response) {
        try {
            request.getRequestDispatcher(VIEW_PAGE).forward(request, response);
        } catch (Exception e) {
            try {
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Forward failed");
            } catch (IOException ex) {
                Thread.currentThread().interrupt();
            }
        }
    }

    private void redirect(HttpServletResponse response, String url) {
        try {
            response.sendRedirect(url);
        } catch (IOException e) {
            try {
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Redirect failed");
            } catch (IOException ex) {
                Thread.currentThread().interrupt();
            }
        }
    }

    private void setEncoding(HttpServletRequest request) {
        try {
            request.setCharacterEncoding("UTF-8");
        } catch (Exception e) {
            Thread.currentThread().interrupt();
        }
    }
}
