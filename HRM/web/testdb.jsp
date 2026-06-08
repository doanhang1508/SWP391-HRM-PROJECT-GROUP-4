<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*, util.DBContext, util.PasswordUtil"%>
<html>
<body>
    <h3>Employee Users (Role = 7)</h3>
    <table border="1">
        <tr><th>ID</th><th>Email</th><th>Password (Hashed)</th><th>Status</th></tr>
        <%
            try (Connection c = DBContext.getConnection();
                 PreparedStatement ps = c.prepareStatement("SELECT user_id, email, password, status FROM Users WHERE role_id = 7")) {
                ResultSet rs = ps.executeQuery();
                while(rs.next()) {
                    out.print("<tr>");
                    out.print("<td>" + rs.getInt("user_id") + "</td>");
                    out.print("<td>" + rs.getString("email") + "</td>");
                    out.print("<td>" + rs.getString("password") + "</td>");
                    out.print("<td>" + rs.getInt("status") + "</td>");
                    out.print("</tr>");
                }
            } catch (Exception e) {
                out.print("<tr><td colspan='4'>Error: " + e.getMessage() + "</td></tr>");
            }
        %>
    </table>
</body>
</html>

