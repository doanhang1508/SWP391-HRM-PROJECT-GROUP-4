package controller.admin;

import dao.AuditLogDAO;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.AuditLog;
import model.User;

@WebServlet(name = "AuditLogController", urlPatterns = {"/admin/audit-log"})
public class AuditLogController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        if (currentUser.getRoleId() != 1) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        // Lọc theo entityType nếu có
        String entityType = request.getParameter("entityType");
        if (entityType != null && entityType.trim().isEmpty()) {
            entityType = null;
        }

        AuditLogDAO dao = new AuditLogDAO();
        List<AuditLog> logs = dao.getAllLogs(entityType);

        request.setAttribute("auditLogs", logs);
        request.setAttribute("entityType", entityType);
        request.getRequestDispatcher("/admin/audit-log.jsp").forward(request, response);
    }
}
