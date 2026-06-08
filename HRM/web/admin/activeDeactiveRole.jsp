<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Role" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Active/Deactive Roles</title>
</head>
<body>
    <h2>Manage Roles (Active/Deactive)</h2>
    <a href="admin_dashboard.jsp">← Quay lại Dashboard</a><br><br>
    
    <% 
       String message = (String) request.getAttribute("message"); 
       if(message != null) out.println("<p class='msg'>" + message + "</p>");
       String error = (String) request.getAttribute("error"); 
       if(error != null) out.println("<p class='err'>" + error + "</p>");
    %>

    <table>
        <tr>
            <th>ID</th>
            <th>Tên Vai Trò (Role)</th>
            <th>Mô tả</th>
            <th>Trạng thái</th>
            <th>Số người dùng</th>
            <th>Hành động</th>
        </tr>
        <%
            List<Role> roleList = (List<Role>) request.getAttribute("roleList");
            if(roleList != null && !roleList.isEmpty()) {
                for(Role r : roleList) {
                    Integer count = (Integer) request.getAttribute("userCount_" + r.getRoleId());
                    if (count == null) count = 0;
        %>
        <tr>
            <td><%= r.getRoleId() %></td>
            <td><%= r.getRoleName() %></td>
            <td><%= r.getDescription() %></td>
            <td class="<%= r.getStatus() == 1 ? "status-active" : "status-deactive" %>">
                <%= r.getStatus() == 1 ? "Active" : "Deactive" %>
            </td>
            <td><%= count %> users</td>
            <td>
                <form action="${pageContext.request.contextPath}/admin/activeDeactiveRole" method="POST" style="margin:0;">
                    <input type="hidden" name="roleId" value="<%= r.getRoleId() %>" />
                    <input type="hidden" name="action" value="toggle" />
                    <% if (r.getStatus() == 1) { %>
                        <button type="submit" class="btn btn-deactivate" onclick="return confirm('Vô hiệu hóa role này sẽ ảnh hưởng <%=count%> người dùng. Tiếp tục?');">Deactivate</button>
                    <% } else { %>
                        <button type="submit" class="btn btn-activate">Activate</button>
                    <% } %>
                </form>
            </td>
        </tr>
        <%      }
            } else {
        %>
            <tr><td colspan="6">Không có dữ liệu Roles. Hãy chạy script SQL để tạo data mẫu.</td></tr>
        <%  } %>
    </table>
</body>
</html>
