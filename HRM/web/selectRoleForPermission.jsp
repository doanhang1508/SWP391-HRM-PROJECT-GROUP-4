<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Role" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Select Role to Edit Permissions</title>
</head>
<body>
    <h2>Chọn Role để chỉnh sửa Permission</h2>
    <a href="admin_dashboard.jsp">← Quay lại Dashboard</a><br><br>

    <table>
        <tr>
            <th>ID</th>
            <th>Tên Vai Trò (Role)</th>
            <th>Trạng thái</th>
            <th>Hành động</th>
        </tr>
        <%
            List<Role> roleList = (List<Role>) request.getAttribute("roleList");
            if(roleList != null && !roleList.isEmpty()) {
                for(Role r : roleList) {
        %>
        <tr>
            <td><%= r.getRoleId() %></td>
            <td><%= r.getRoleName() %></td>
            <td style="color: <%= r.getStatus() == 1 ? "green" : "red" %>;">
                <%= r.getStatus() == 1 ? "Active" : "Deactive" %>
            </td>
            <td>
                <a href="editRolePermission?roleId=<%= r.getRoleId() %>" class="btn">Edit Permissions</a>
            </td>
        </tr>
        <%      }
            } else {
        %>
            <tr><td colspan="4">Không có dữ liệu Roles.</td></tr>
        <%  } %>
    </table>
</body>
</html>
