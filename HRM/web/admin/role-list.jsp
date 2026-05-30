<%@page import="java.util.List"%>
<%@page import="model.Role"%>
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
    List<Role> roles = (List<Role>) request.getAttribute("roles");

    Boolean canUpdateRoleObj = (Boolean) request.getAttribute("canUpdateRole");
    boolean canUpdateRole = canUpdateRoleObj != null && canUpdateRoleObj;

    if (roles == null) {
        response.sendRedirect("role?action=list");
        return;
    }
%>

<c:set var="pageTitle" value="Quản lý Vai trò - Hệ Thống HRM" scope="request" />
<jsp:include page="../header.jsp" />

<!-- Google Fonts & Icons -->
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

    .badge-soft {
        padding: 6px 12px;
        border-radius: 6px;
        font-weight: 600;
        font-size: 0.75rem;
    }
    .badge-soft-success { background: rgba(76, 201, 240, 0.1); color: #00b4d8; }
    .badge-soft-danger { background: rgba(247, 37, 133, 0.1); color: #f72585; }

    .btn-action {
        height: 32px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        border-radius: 8px;
        transition: all 0.2s;
        border: none;
        color: #fff;
        padding: 0 12px;
        font-size: 0.85rem;
        font-weight: 500;
        text-decoration: none;
        gap: 6px;
        cursor: pointer;
    }
    .btn-update { background: var(--success-color); }
    .btn-update:hover { background: #00b4d8; transform: translateY(-2px); box-shadow: 0 4px 8px rgba(0,0,0,0.1); color: #fff;}
    
    .btn-toggle-on { background: #fca311; width: 32px; padding: 0; }
    .btn-toggle-off { background: #14213d; width: 32px; padding: 0; }
    .btn-toggle-on:hover, .btn-toggle-off:hover { transform: translateY(-2px); box-shadow: 0 4px 8px rgba(0,0,0,0.1); }
</style>

<div class="dashboard-wrapper">
    <!-- Sidebar -->
    <jsp:include page="sidebar.jsp">
        <jsp:param name="activeMenu" value="roles" />
    </jsp:include>

    <!-- Main Content -->
    <div class="main-content">
        <div class="page-header">
            <div>
                <h1 class="page-title">Quản Lý Vai Trò</h1>
                <p class="breadcrumb">
                    <a href="${pageContext.request.contextPath}/admin/dashboard">Bảng điều khiển</a> &nbsp;>&nbsp; Quản lý vai trò
                </p>
            </div>
            <div>
                <button class="btn btn-primary" style="background: var(--primary-color); border: none; border-radius: 8px; padding: 10px 20px; font-weight: 500;">
                    <i class="fas fa-plus me-2"></i> Thêm Vai Trò Mới
                </button>
            </div>
        </div>

        <!-- System Alerts -->
        <c:if test="${not empty param.message}">
            <div class="alert alert-success alert-dismissible fade show border-0 shadow-sm" role="alert" style="border-radius: 10px; background: #d1fae5; color: #065f46;">
                <i class="fas fa-check-circle me-2"></i> ${param.message}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>
        <c:if test="${not empty param.error}">
            <div class="alert alert-danger alert-dismissible fade show border-0 shadow-sm" role="alert" style="border-radius: 10px; background: #fee2e2; color: #991b1b;">
                <i class="fas fa-exclamation-circle me-2"></i> ${param.error}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>

        <div class="admin-panel h-100">
            <div class="panel-header">
                <h3 class="panel-title">
                    <div style="width: 40px; height: 40px; border-radius: 10px; background: rgba(67, 97, 238, 0.1); color: var(--primary-color); display: flex; align-items: center; justify-content: center;">
                        <i class="fas fa-user-shield"></i>
                    </div>
                    Danh Sách Vai Trò Hệ Thống
                </h3>
                <div>
                    <input type="text" class="form-control form-control-sm" placeholder="Tìm kiếm vai trò..." style="border-radius: 8px; width: 200px;">
                </div>
            </div>

            <div class="table-responsive">
                <table class="table-custom">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Tên Vai Trò</th>
                            <th>Mô Tả</th>
                            <th>Trạng Thái</th>
                            <th class="text-end">Hành Động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            if (roles.isEmpty()) {
                        %>
                        <tr>
                            <td colspan="5" class="text-center py-4 text-muted">Không có role nào trong hệ thống.</td>
                        </tr>
                        <%
                            } else {
                                for (Role r : roles) {
                        %>
                        <tr>
                            <td class="fw-bold text-dark">#<%= r.getRoleId() %></td>
                            <td>
                                <span class="fw-bold" style="color: var(--primary-color);"><%= h(r.getRoleName()) %></span>
                            </td>
                            <td class="text-muted"><%= h(r.getDescription()) %></td>
                            <td>
                                <%
                                    if (r.getStatus() == 1) {
                                %>
                                <span class="badge-soft badge-soft-success"><i class="fas fa-circle me-1" style="font-size: 6px; vertical-align: middle;"></i> Hoạt động</span>
                                <%
                                    } else {
                                %>
                                <span class="badge-soft badge-soft-danger"><i class="fas fa-circle me-1" style="font-size: 6px; vertical-align: middle;"></i> Vô hiệu</span>
                                <%
                                    }
                                %>
                            </td>
                            <td class="text-end">
                                <div class="d-flex justify-content-end gap-2">
                                    <%
                                        if (canUpdateRole) {
                                    %>
                                    <a href="role?action=update&roleId=<%= r.getRoleId() %>" class="btn-action btn-update" title="Chỉnh sửa thông tin">
                                        <i class="fas fa-edit"></i> Sửa
                                    </a>
                                    <form method="post" action="${pageContext.request.contextPath}/activeDeactiveRole" class="m-0" onsubmit="return confirm('Bạn có chắc chắn muốn <%= r.getStatus() == 1 ? "VÔ HIỆU HÓA" : "KÍCH HOẠT" %> vai trò <%= h(r.getRoleName()) %> không?');">
                                        <input type="hidden" name="action" value="toggle" />
                                        <input type="hidden" name="roleId" value="<%= r.getRoleId() %>" />
                                        <input type="hidden" name="source" value="roleList" />
                                        <button type="submit" class="btn-action <%= r.getStatus() == 1 ? "btn-toggle-on" : "btn-toggle-off" %>" title="<%= r.getStatus() == 1 ? "Vô hiệu hóa" : "Kích hoạt" %>">
                                            <i class="fas <%= r.getStatus() == 1 ? "fa-lock" : "fa-unlock" %>"></i>
                                        </button>
                                    </form>
                                    <%
                                        } else {
                                    %>
                                    <span class="text-muted small">No action</span>
                                    <%
                                        }
                                    %>
                                </div>
                            </td>
                        </tr>
                        <%
                                }
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../footer.jsp" />
