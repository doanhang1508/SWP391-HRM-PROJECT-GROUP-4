<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Role" %>
<%@ page import="model.Permission" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Edit Permissions</title>
</head>
<body>
    <% Role role = (Role) request.getAttribute("role"); %>
    <h2>Phân quyền cho Role:<%= role != null ? role.getRoleName() : "" %></h2>
    <a href="editRolePermission">← Quay lại danh sách Role</a><br><br>

    <% 
       String message = (String) request.getAttribute("message"); 
       if(message != null) out.println("<p class='msg'>" + message + "</p>");
       String error = (String) request.getAttribute("error"); 
       if(error != null) out.println("<p class='err'>" + error + "</p>");
    %>

    <% if(role != null) { %>
    <form action="editRolePermission" method="POST">
        <input type="hidden" name="roleId" value="<%= role.getRoleId() %>" />
        
        <div class="permission-list">
            <h4>Danh sách quyền hạn (Permissions)</h4>
        <%
            List<Permission> allPerms = (List<Permission>) request.getAttribute("allPermissions");
            List<Integer> assignedIds = (List<Integer>) request.getAttribute("assignedPermissionIds");
            
            if(allPerms != null && !allPerms.isEmpty()) {
                for(Permission p : allPerms) {
                    boolean isChecked = assignedIds != null && assignedIds.contains(p.getPermissionId());
        %>
            <div class="permission-item">
                <label style="cursor: pointer;">
                    <input type="checkbox" name="permissions" value="<%= p.getPermissionId() %>" <%= isChecked ? "checked" : "" %> />
                    <b><%= p.getPermissionName() %></b> 
                    <span>- <%= p.getDescription() %></span>
                </label>
            </div>
        <%      }
            } else {
        %>
            <p>Chưa có quyền hạn nào trong Database!</p>
        <%  } %>
        </div>
        
        <button type="submit" class="btn-save">Lưu thay đổi</button>
    </form>
    <% } %>
</body>
</html>
