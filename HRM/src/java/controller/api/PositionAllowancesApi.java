package controller.api;

import dao.AllowanceDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.Map;

@WebServlet("/api/position-allowances")
public class PositionAllowancesApi extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        
        String posIdStr = request.getParameter("positionId");
        if (posIdStr == null || posIdStr.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\": \"Missing positionId\"}");
            return;
        }
        
        try {
            int positionId = Integer.parseInt(posIdStr);
            AllowanceDAO dao = new AllowanceDAO();
            List<Map<String, Object>> allowances = dao.getAllowancesByPosition(positionId);
            
            // Xử lý thêm phụ cấp thâm niên nếu có truyền userId
            String userIdStr = request.getParameter("userId");
            if (userIdStr != null && !userIdStr.trim().isEmpty()) {
                int userId = Integer.parseInt(userIdStr);
                int tenureMonths = dao.getTenureMonths(userId);
                java.math.BigDecimal seniorityAmount = dao.getSeniorityAmount(tenureMonths);
                if (seniorityAmount.compareTo(java.math.BigDecimal.ZERO) > 0) {
                    Map<String, Object> senMap = new java.util.HashMap<>();
                    senMap.put("id", 4); // ID ảo hoặc ID thực tế của phụ cấp thâm niên
                    senMap.put("name", "Phụ cấp thâm niên");
                    senMap.put("amount", seniorityAmount.doubleValue());
                    allowances.add(senMap);
                }
            }
            
            // Basic JSON serialization without extra library to keep it simple
            StringBuilder json = new StringBuilder("[");
            for (int i = 0; i < allowances.size(); i++) {
                Map<String, Object> map = allowances.get(i);
                json.append("{")
                    .append("\"id\": ").append(map.get("id")).append(", ")
                    .append("\"name\": \"").append(map.get("name").toString().replace("\"", "\\\"")).append("\", ")
                    .append("\"amount\": ").append(map.get("amount"))
                    .append("}");
                if (i < allowances.size() - 1) json.append(",");
            }
            json.append("]");
            
            try (PrintWriter out = response.getWriter()) {
                out.write(json.toString());
            }
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\": \"" + e.getMessage() + "\"}");
        }
    }
}
