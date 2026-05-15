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
    Role role = (Role) request.getAttribute("role");
    String error = (String) request.getAttribute("error");
    String success = (String) request.getAttribute("success");
%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Update Role Information</title>

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
                max-width: 700px;
                margin: auto;
                box-shadow: 0 2px 8px rgba(0,0,0,0.08);
            }

            h2 {
                margin-top: 0;
                color: #222;
            }

            .back {
                display: inline-block;
                margin-bottom: 15px;
                text-decoration: none;
                color: #0984e3;
            }

            .form-group {
                margin-bottom: 16px;
            }

            label {
                display: block;
                font-weight: bold;
                margin-bottom: 7px;
            }

            input[type="text"], textarea {
                width: 100%;
                padding: 10px;
                box-sizing: border-box;
                border: 1px solid #ccc;
                border-radius: 6px;
                font-size: 15px;
            }

            textarea {
                height: 100px;
                resize: vertical;
            }

            .btn {
                padding: 10px 16px;
                border: none;
                border-radius: 6px;
                background: #00b894;
                color: white;
                cursor: pointer;
                font-size: 15px;
            }

            .btn:hover {
                background: #019875;
            }

            .error {
                background: #ffecec;
                color: #d63031;
                padding: 12px;
                border-radius: 6px;
                margin-bottom: 15px;
            }

            .success {
                background: #e9fff3;
                color: #00b894;
                padding: 12px;
                border-radius: 6px;
                margin-bottom: 15px;
            }

            .note {
                color: #666;
                font-size: 14px;
            }
        </style>
    </head>

    <body>
        <div class="container">

            <a class="back" href="role?action=list">← Quay lại danh sách role</a>

            <h2>Update Role Information</h2>
            <p>Feature 14: Update role information</p>

            <%
                if (error != null) {
            %>
            <div class="error"><%= h(error) %></div>
            <%
                }

                if (success != null) {
            %>
            <div class="success"><%= h(success) %></div>
            <%
                }

                if (role == null) {
            %>
            <div class="error">Không có dữ liệu role. Vui lòng quay lại danh sách role.</div>
            <%
                } else {
            %>

            <form action="role?action=update" method="post">
                <input type="hidden" name="roleId" value="<%= role.getRoleId() %>">

                <div class="form-group">
                    <label>Role ID</label>
                    <input type="text" value="<%= role.getRoleId() %>" readonly>
                </div>

                <div class="form-group">
                    <label>Role Name</label>
                    <input type="text" name="roleName" value="<%= h(role.getRoleName()) %>" maxlength="50" required>
                </div>

                <div class="form-group">
                    <label>Description</label>
                    <textarea name="description" maxlength="255"><%= h(role.getDescription()) %></textarea>
                </div>

                <button type="submit" class="btn">Save Changes</button>
            </form>

            <%
                }
            %>

        </div>
    </body>
</html>