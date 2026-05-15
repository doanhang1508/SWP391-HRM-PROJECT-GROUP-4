<%@page import="java.util.List"%>
<%@page import="model.Role"%>
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
    List<Role> roles = (List<Role>) request.getAttribute("roles");

    Boolean canViewPermissionObj = (Boolean) request.getAttribute("canViewPermission");
    Boolean canUpdateRoleObj = (Boolean) request.getAttribute("canUpdateRole");

    boolean canViewPermission = canViewPermissionObj != null && canViewPermissionObj;
    boolean canUpdateRole = canUpdateRoleObj != null && canUpdateRoleObj;

    if (roles == null) {
        response.sendRedirect("role?action=list");
        return;
    }
%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Role List</title>

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
                max-width: 1000px;
                margin: auto;
                box-shadow: 0 2px 8px rgba(0,0,0,0.08);
            }

            h2 {
                margin-top: 0;
                color: #222;
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

            .status-active {
                color: green;
                font-weight: bold;
            }

            .status-deactive {
                color: red;
                font-weight: bold;
            }

            .btn {
                display: inline-block;
                padding: 7px 10px;
                border-radius: 5px;
                text-decoration: none;
                font-size: 14px;
                margin-right: 5px;
            }

            .btn-view {
                background: #0984e3;
                color: white;
            }

            .btn-update {
                background: #00b894;
                color: white;
            }

            .back {
                display: inline-block;
                margin-bottom: 15px;
                text-decoration: none;
                color: #0984e3;
            }

            .no-action {
                color: #888;
            }
        </style>
    </head>

    <body>
        <div class="container">

            <a class="back" href="home.jsp">← Quay lại trang chủ</a>

            <h2>Role Management</h2>
            <p>Feature 12: View role list</p>

            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Role Name</th>
                        <th>Description</th>
                        <th>Status</th>
                        <th style="width: 260px;">Action</th>
                    </tr>
                </thead>

                <tbody>
                    <%
                        if (roles.isEmpty()) {
                    %>
                    <tr>
                        <td colspan="5">Không có role nào trong hệ thống.</td>
                    </tr>
                    <%
                        } else {
                            for (Role r : roles) {
                    %>
                    <tr>
                        <td><%= r.getRoleId() %></td>
                        <td><%= h(r.getRoleName()) %></td>
                        <td><%= h(r.getDescription()) %></td>
                        <td>
                            <%
                                if (r.getStatus() == 1) {
                            %>
                            <span class="status-active">Active</span>
                            <%
                                } else {
                            %>
                            <span class="status-deactive">Deactive</span>
                            <%
                                }
                            %>
                        </td>

                        <td>
                            <%
                                boolean hasAction = false;

                                if (canViewPermission) {
                                    hasAction = true;
                            %>
                            <a class="btn btn-view" href="role?action=permissions&roleId=<%= r.getRoleId() %>">
                                View Permissions
                            </a>
                            <%
                                }

                                if (canUpdateRole) {
                                    hasAction = true;
                            %>
                            <a class="btn btn-update" href="role?action=update&roleId=<%= r.getRoleId() %>">
                                Update Info
                            </a>
                            <%
                                }

                                if (!hasAction) {
                            %>
                            <span class="no-action">No action</span>
                            <%
                                }
                            %>
                        </td>
                    </tr>
                    <%
                            }
                        }
                    %>
                </tbody>
            </table>

        </div>
    </body>
</html>