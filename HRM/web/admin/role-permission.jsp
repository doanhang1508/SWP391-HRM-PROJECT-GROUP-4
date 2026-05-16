<%@page import="java.util.List"%>
<%@page import="model.Role"%>
<%@page import="model.Permission"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%!
    public String h(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;");
    }
%>

<%
    Role role = (Role) request.getAttribute("role");
    List<Permission> permissions = (List<Permission>) request.getAttribute("permissions");
    String error = (String) request.getAttribute("error");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Role Permissions</title>

    <style>
        body {
            font-family: Arial, sans-serif;
            background: #f4f6f8;
            margin: 0;
            padding: 30px;
        }

        .container {
            background: white;
            padding: 25px;
            border-radius: 10px;
            max-width: 900px;
            margin: auto;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
        }

        h2 {
            margin-top: 0;
            color: #222;
        }

        .role-box {
            background: #f1f2f6;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 18px;
        }

        th, td {
            border: 1px solid #ddd;
            padding: 12px;
            text-align: left;
        }

        th {
            background: #2f3640;
            color: white;
        }

        tr:nth-child(even) {
            background: #f8f8f8;
        }

        .back {
            display: inline-block;
            margin-bottom: 15px;
            text-decoration: none;
            color: #0984e3;
        }

        .error {
            background: #ffecec;
            color: #d63031;
            padding: 12px;
            border-radius: 6px;
            margin-top: 15px;
        }
    </style>
</head>

<body>
<div class="container">

    <a class="back" href="role?action=list">← Quay lại danh sách role</a>

    <h2>Role Permissions</h2>
    <p>Feature 13: View role permissions</p>

    <%
        if (error != null) {
    %>
        <div class="error"><%= h(error) %></div>
    <%
        } else if (role == null) {
    %>
        <div class="error">Không có dữ liệu role. Vui lòng quay lại danh sách role.</div>
    <%
        } else {
    %>

        <div class="role-box">
            <p><strong>Role ID:</strong> <%= role.getRoleId() %></p>
            <p><strong>Role Name:</strong> <%= h(role.getRoleName()) %></p>
            <p><strong>Description:</strong> <%= h(role.getDescription()) %></p>
        </div>

        <table>
            <thead>
                <tr>
                    <th>Permission ID</th>
                    <th>Permission Name</th>
                    <th>Description</th>
                </tr>
            </thead>

            <tbody>
            <%
                if (permissions == null || permissions.isEmpty()) {
            %>
                <tr>
                    <td colspan="3">Role này chưa có quyền nào.</td>
                </tr>
            <%
                } else {
                    for (Permission p : permissions) {
            %>
                <tr>
                    <td><%= p.getPermissionId() %></td>
                    <td><%= h(p.getPermissionName()) %></td>
                    <td><%= h(p.getDescription()) %></td>
                </tr>
            <%
                    }
                }
            %>
            </tbody>
        </table>

    <%
        }
    %>

</div>
</body>
</html>