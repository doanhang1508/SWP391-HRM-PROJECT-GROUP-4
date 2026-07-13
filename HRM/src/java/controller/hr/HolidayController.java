package controller.hr;

import dao.HolidayDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;
import java.util.List;
import model.Holiday;
import model.User;

@WebServlet("/hr/holiday")
public class HolidayController extends HttpServlet {

    private static final String ATTR_CURRENT_USER = "currentUser";
    private static final String LOGIN_URL = "/login";
    private static final String DASHBOARD_URL = "/dashboard";
    private static final String REDIRECT_URL = "/hr/holiday";
    private static final String VIEW_PAGE = "/hr/holiday-list.jsp";

    private final HolidayDAO dao = new HolidayDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        if (!isAuthorized(request, response)) {
            return;
        }

        List<Holiday> holidayList = dao.getAll();
        request.setAttribute("holidayList", holidayList);
        forwardToView(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        setEncoding(request);

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute(ATTR_CURRENT_USER) == null) {
            redirect(response, request.getContextPath() + LOGIN_URL);
            return;
        }

        if (!isAuthorized(request, response)) {
            return;
        }

        String action = request.getParameter("action");
        String idStr = request.getParameter("id");
        String name = request.getParameter("name");
        String holidayDateStr = request.getParameter("holidayDate");
        String calendarType = request.getParameter("calendarType");
        String otMultiplierStr = request.getParameter("otMultiplier");
        String description = request.getParameter("description");

        processAction(action, idStr, name, holidayDateStr, calendarType, otMultiplierStr, description);
        redirect(response, request.getContextPath() + REDIRECT_URL);
    }

    private void processAction(String action, String idStr, String name, String holidayDateStr, 
            String calendarType, String otMultiplierStr, String description) {
        if ("delete".equals(action)) {
            if (idStr != null) {
                dao.delete(parseInt(idStr));
            }
        } else if ("deactivate".equals(action)) {
            changeStatusIfIdPresent(idStr, false);
        } else if ("activate".equals(action)) {
            changeStatusIfIdPresent(idStr, true);
        } else if ("add".equals(action)) {
            if (name != null && !name.trim().isEmpty() && holidayDateStr != null && !holidayDateStr.isEmpty()) {
                dao.insert(new Holiday(0, name.trim(), Date.valueOf(holidayDateStr), 
                        parseCalendarType(calendarType), parseOtMultiplier(otMultiplierStr), description, true));
            }
        } else if ("edit".equals(action) && idStr != null) {
            if (name != null && !name.trim().isEmpty() && holidayDateStr != null && !holidayDateStr.isEmpty()) {
                dao.update(new Holiday(parseInt(idStr), name.trim(), Date.valueOf(holidayDateStr), 
                        parseCalendarType(calendarType), parseOtMultiplier(otMultiplierStr), description, true));
            }
        }
    }

    private void changeStatusIfIdPresent(String idStr, boolean active) {
        if (idStr != null) {
            dao.changeStatus(parseInt(idStr), active);
        }
    }

    private String parseCalendarType(String calendarType) {
        if ("LUNAR".equals(calendarType)) {
            return "LUNAR";
        }
        return "SOLAR";
    }

    private BigDecimal parseOtMultiplier(String otMultiplierStr) {
        if (otMultiplierStr == null || otMultiplierStr.trim().isEmpty()) {
            return new BigDecimal("3.00");
        }
        try {
            return new BigDecimal(otMultiplierStr.trim());
        } catch (NumberFormatException e) {
            return new BigDecimal("3.00");
        }
    }

    private int parseInt(String s) {
        try {
            return Integer.parseInt(s);
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    private boolean isAuthorized(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute(ATTR_CURRENT_USER) == null) {
            redirect(response, request.getContextPath() + LOGIN_URL);
            return false;
        }
        User user = (User) session.getAttribute(ATTR_CURRENT_USER);
        if (user.getRoleId() != 2 && user.getRoleId() != 5) { // HR Manager or HR Staff
            redirect(response, request.getContextPath() + DASHBOARD_URL);
            return false;
        }
        return true;
    }

    private void forwardToView(HttpServletRequest request, HttpServletResponse response) {
        try {
            request.getRequestDispatcher(VIEW_PAGE).forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void redirect(HttpServletResponse response, String url) throws IOException {
        response.sendRedirect(url);
    }

    private void setEncoding(HttpServletRequest request) {
        try {
            request.setCharacterEncoding("UTF-8");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
