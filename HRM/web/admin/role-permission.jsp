<%@page import="java.util.List"%>
<%@page import="model.Role"%>
<%@page import="model.Permission"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

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

<c:set var="pageTitle" value="Xem quyền vai trò - Hệ Thống HRM" scope="request" />
<jsp:include page="../header.jsp" />

<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">

<style>
    :root {
        --primary-color: #4361ee;
        --secondary-color: #3f37c9;
        --success-color: #4cc9f0;
        --danger-color: #f72585;
        --warning-color: #f8961e;
        --info-color: #4895ef;
        --dark-bg: #f4f7fe;
        --card-bg: #ffffff;
        --text-main: #2b2b2b;
        --text-muted: #8f9fbc;
    }

    body {
        background-color: var(--dark-bg);
        font-family: 'Inter', sans-serif;
    }

    .dashboard-wrapper {
        display: flex;
        min-height: calc(100vh - 64px);
    }

    .main-content {
        flex: 1;
        padding: 30px;
        width: calc(100% - 260px);
    }

    .page-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 30px;
    }

    .page-title {
        font-size: 1.5rem;
        font-weight: 700;
        color: var(--text-main);
        margin: 0;
    }

    .breadcrumb {
        font-size: 0.85rem;
        color: var(--text-muted);
        margin-bottom: 0;
    }

    .breadcrumb a {
        color: var(--primary-color);
        text-decoration: none;
    }

    .admin-panel {
        background: var(--card-bg);
        border-radius: 16px;
        padding: 24px;
        box-shadow: 0 5px 20px rgba(0,0,0,0.02);
        margin-bottom: 25px;
        border: 1px solid rgba(0,0,0,0.04);
    }

    .panel-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 20px;
        padding-bottom: 15px;
        border-bottom: 1px solid #f1f5f9;
    }

    .panel-title {
        font-size: 1.15rem;
        font-weight: 700;
        color: var(--text-main);
        margin: 0;
        display: flex;
        align-items: center;
        gap: 10px;
    }

    .role-info {
        background: #f8fafc;
        border: 1px solid #f1f5f9;
        border-radius: 12px;
        padding: 18px;
        margin-bottom: 20px;
    }

    .role-info p {
        margin: 6px 0;
        color: #4a5568;
        font-size: 0.9rem;
    }

    .role-info strong {
        color: var(--text-main);
    }

    .table-custom {
        width: 100%;
        border-collapse: separate;
        border-spacing: 0 8px;
    }

    .table-custom th {
        background: transparent;
        color: var(--text-muted);
        font-weight: 600;
        font-size: 0.85rem;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        padding: 12px 15px;
        border: none;
    }

    .table-custom td {
        background: #fff;
        padding: 15px;
        vertical-align: middle;
        color: #4a5568;
        font-size: 0.9rem;
        border-top: 1px solid #f1f5f9;
        border-bottom: 1px solid #f1f5f9;
    }

    .table-custom tr td:first-child {
        border-left: 1px solid #f1f5f9;
        border-radius: 8px 0 0 8px;
    }

    .table-custom tr td:last-child {
        border-right: 1px solid #f1f5f9;
        border-radius: 0 8px 8px 0;
    }

    .table-custom tr:hover td {
        background: #f8fafc;
    }

    .btn-back {
        height: 38px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        border-radius: 8px;
        border: none;
        background: var(--primary-color);
        color: #fff;
        padding: 0 16px;
        font-size: 0.9rem;
        font-weight: 500;
        text-decoration: none;
        gap: 8px;
        transition: all 0.2s;
    }

    .btn-back:hover {
        background: var(--secondary-color);
        transform: translateY(-2px);
        box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        color: #fff;
    }
</style>

<div class="dashboard-wrapper">
    <jsp:include page="sidebar.jsp">
        <jsp:param name="activeMenu" value="roles" />
    </jsp:include>

    <div class="main-content">
        <div class="page-header">
            <div>
                <h1 class="page-title">Quyền Của Vai Trò</h1>
                <p class="breadcrumb">
                    <a href="${pageContext.request.contextPath}/admin/dashboard">Bảng điều khiển</a>
                    &nbsp;>&nbsp;
                    <a href="role?action=list">Quản lý vai trò</a>
                    &nbsp;>&nbsp; Xem quyền
                </p>
            </div>

            <a href="role?action=list" class="btn-back">
                <i class="fas fa-arrow-left"></i> Quay lại
            </a>
        </div>

        <%
            if (error != null) {
        %>
            <div class="alert alert-danger border-0 shadow-sm" style="border-radius: 10px; background: #fee2e2; color: #991b1b;">
                <i class="fas fa-exclamation-circle me-2"></i> <%= h(error) %>
            </div>
        <%
            } else if (role == null) {
        %>
            <div class="alert alert-danger border-0 shadow-sm" style="border-radius: 10px; background: #fee2e2; color: #991b1b;">
                <i class="fas fa-exclamation-circle me-2"></i>
                Không có dữ liệu role. Vui lòng quay lại danh sách role.
            </div>
        <%
            } else {
        %>

        <div class="admin-panel">
            <div class="panel-header">
                <h3 class="panel-title">
                    <div style="width: 40px; height: 40px; border-radius: 10px; background: rgba(67, 97, 238, 0.1); color: var(--primary-color); display: flex; align-items: center; justify-content: center;">
                        <i class="fas fa-eye"></i>
                    </div>
                    Thông Tin Vai Trò
                </h3>
            </div>

            <div class="role-info">
                <p><strong>Role ID:</strong> #<%= role.getRoleId() %></p>
                <p><strong>Role Name:</strong> <%= h(role.getRoleName()) %></p>
                <p><strong>Description:</strong> <%= h(role.getDescription()) %></p>
            </div>
        </div>

        <div class="admin-panel">
            <div class="panel-header">
                <h3 class="panel-title">
                    <div style="width: 40px; height: 40px; border-radius: 10px; background: rgba(72, 149, 239, 0.1); color: var(--info-color); display: flex; align-items: center; justify-content: center;">
                        <i class="fas fa-key"></i>
                    </div>
                    Danh Sách Quyền
                </h3>
            </div>

            <div class="table-responsive">
                <table class="table-custom">
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
                            <td colspan="3" class="text-center py-4 text-muted">
                                Role này chưa có quyền nào.
                            </td>
                        </tr>
                    <%
                        } else {
                            for (Permission p : permissions) {
                    %>
                        <tr>
                            <td class="fw-bold text-dark">#<%= p.getPermissionId() %></td>
                            <td>
                                <span class="fw-bold" style="color: var(--primary-color);">
                                    <%= h(p.getPermissionName()) %>
                                </span>
                            </td>
                            <td class="text-muted"><%= h(p.getDescription()) %></td>
                        </tr>
                    <%
                            }
                        }
                    %>
                    </tbody>
                </table>
            </div>
        </div>

        <%
            }
        %>
    </div>
</div>

<jsp:include page="../footer.jsp" />