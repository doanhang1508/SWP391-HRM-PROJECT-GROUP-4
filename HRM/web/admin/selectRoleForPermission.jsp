<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Role" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%
    List<Role> roleList = (List<Role>) request.getAttribute("roleList");
%>

<c:set var="pageTitle" value="Phân Quyền Hệ Thống - Hệ Thống HRM" scope="request" />
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
        padding: 0 16px;
        font-size: 0.85rem;
        font-weight: 500;
        text-decoration: none;
        gap: 8px;
        cursor: pointer;
    }
    .btn-manage { background: var(--info-color); }
    .btn-manage:hover { background: #3a0ca3; transform: translateY(-2px); box-shadow: 0 4px 8px rgba(0,0,0,0.1); color: #fff;}
</style>

<div class="dashboard-wrapper">
    <!-- Sidebar -->
    <jsp:include page="sidebar.jsp">
        <jsp:param name="activeMenu" value="permissions" />
    </jsp:include>

    <!-- Main Content -->
    <div class="main-content">
        <div class="page-header">
            <div>
                <h1 class="page-title">Phân Quyền Hệ Thống</h1>
                <p class="breadcrumb">
                    <a href="${pageContext.request.contextPath}/admin/dashboard">Dashboard</a> &nbsp;>&nbsp; Phân quyền hệ thống
                </p>
            </div>
        </div>

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
                    <div style="width: 40px; height: 40px; border-radius: 10px; background: rgba(247, 37, 133, 0.1); color: var(--danger-color); display: flex; align-items: center; justify-content: center;">
                        <i class="fas fa-key"></i>
                    </div>
                    Chọn Vai Trò Cần Phân Quyền
                </h3>
            </div>

            <div class="table-responsive">
                <table class="table-custom">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Tên Vai Trò</th>
                            <th>Trạng Thái</th>
                            <th class="text-end">Hành Động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            if(roleList != null && !roleList.isEmpty()) {
                                for(Role r : roleList) {
                        %>
                        <tr>
                            <td class="fw-bold text-dark">#<%= r.getRoleId() %></td>
                            <td>
                                <span class="fw-bold" style="color: var(--primary-color);"><%= r.getRoleName() %></span>
                            </td>
                            <td>
                                <%
                                    if (r.getStatus() == 1) {
                                %>
                                <span class="badge-soft badge-soft-success"><i class="fas fa-circle me-1" style="font-size: 6px; vertical-align: middle;"></i> Active</span>
                                <%
                                    } else {
                                %>
                                <span class="badge-soft badge-soft-danger"><i class="fas fa-circle me-1" style="font-size: 6px; vertical-align: middle;"></i> Deactive</span>
                                <%
                                    }
                                %>
                            </td>
                            <td class="text-end">
                                <a href="editRolePermission?roleId=<%= r.getRoleId() %>" class="btn-action btn-manage" title="Quản lý Quyền">
                                    <i class="fas fa-sliders-h"></i> Manage Permissions
                                </a>
                            </td>
                        </tr>
                        <%      }
                            } else {
                        %>
                        <tr>
                            <td colspan="4" class="text-center py-4 text-muted">Không có dữ liệu Roles.</td>
                        </tr>
                        <%  } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../footer.jsp" />
