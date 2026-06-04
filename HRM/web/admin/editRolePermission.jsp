<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Role" %>
<%@ page import="model.Permission" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<% Role role = (Role) request.getAttribute("role"); %>

<c:set var="pageTitle" value="Chỉnh Sửa Quyền - Hệ Thống HRM" scope="request" />
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

    /* Checkbox Styles */
    .permission-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
        gap: 20px;
        margin-top: 20px;
    }

    .permission-item {
        background: #f8fafc;
        border: 1px solid #e2e8f0;
        border-radius: 10px;
        padding: 16px;
        transition: all 0.2s ease;
    }

    .permission-item:hover {
        border-color: var(--primary-color);
        box-shadow: 0 4px 12px rgba(67, 97, 238, 0.08);
        background: #fff;
    }

    .permission-label {
        display: flex;
        align-items: flex-start;
        cursor: pointer;
        margin: 0;
        gap: 12px;
    }

    .custom-checkbox {
        position: relative;
        appearance: none;
        width: 22px;
        height: 22px;
        border: 2px solid #cbd5e1;
        border-radius: 6px;
        background: #fff;
        cursor: pointer;
        flex-shrink: 0;
        margin-top: 2px;
        transition: all 0.2s;
    }

    .custom-checkbox:checked {
        background: var(--primary-color);
        border-color: var(--primary-color);
    }

    .custom-checkbox:checked::after {
        content: '\f00c';
        font-family: 'Font Awesome 5 Free';
        font-weight: 900;
        color: white;
        position: absolute;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        font-size: 12px;
    }

    .perm-content {
        display: flex;
        flex-direction: column;
    }

    .perm-name {
        font-weight: 600;
        color: var(--text-main);
        font-size: 0.95rem;
        margin-bottom: 4px;
    }

    .perm-desc {
        font-size: 0.8rem;
        color: var(--text-muted);
        line-height: 1.4;
    }

    .btn-save {
        background: var(--primary-color);
        color: white;
        border: none;
        border-radius: 8px;
        padding: 12px 24px;
        font-weight: 600;
        font-size: 1rem;
        display: inline-flex;
        align-items: center;
        gap: 8px;
        transition: all 0.3s ease;
        margin-top: 30px;
        cursor: pointer;
    }

    .btn-save:hover {
        background: var(--secondary-color);
        transform: translateY(-2px);
        box-shadow: 0 5px 15px rgba(67, 97, 238, 0.3);
    }

    .role-info-card {
        background: linear-gradient(135deg, rgba(67, 97, 238, 0.05), rgba(76, 201, 240, 0.05));
        border: 1px solid rgba(67, 97, 238, 0.1);
        border-radius: 12px;
        padding: 20px;
        margin-bottom: 30px;
    }
</style>

<div class="dashboard-wrapper">
    <!-- Sidebar -->
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="permissions" />
    </jsp:include>

    <!-- Main Content -->
    <div class="main-content">
        <div class="page-header">
            <div>
                <h1 class="page-title">Chi Tiết Phân Quyền</h1>
                <p class="breadcrumb">
                    <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a> &nbsp;>&nbsp; 
                    <a href="${pageContext.request.contextPath}/editRolePermission">Phân quyền hệ thống</a> &nbsp;>&nbsp; 
                    Chỉnh sửa quyền
                </p>
            </div>
            <div>
                <a href="${pageContext.request.contextPath}/editRolePermission" class="btn btn-outline-secondary" style="border-radius: 8px; padding: 10px 20px; font-weight: 500;">
                    <i class="fas fa-arrow-left me-2"></i> Quay Lại
                </a>
            </div>
        </div>

        <c:if test="${not empty requestScope.message}">
            <div class="alert alert-success alert-dismissible fade show border-0 shadow-sm" role="alert" style="border-radius: 10px; background: #d1fae5; color: #065f46;">
                <i class="fas fa-check-circle me-2"></i> ${requestScope.message}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>
        <c:if test="${not empty requestScope.error}">
            <div class="alert alert-danger alert-dismissible fade show border-0 shadow-sm" role="alert" style="border-radius: 10px; background: #fee2e2; color: #991b1b;">
                <i class="fas fa-exclamation-circle me-2"></i> ${requestScope.error}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>

        <% if(role != null) { %>
        <div class="admin-panel">
            <div class="role-info-card d-flex align-items-center gap-4">
                <div style="width: 60px; height: 60px; border-radius: 15px; background: var(--primary-color); color: white; display: flex; align-items: center; justify-content: center; font-size: 1.8rem; flex-shrink: 0;">
                    <i class="fas fa-user-shield"></i>
                </div>
                <div>
                    <h4 class="mb-1 fw-bold" style="color: var(--text-main);"><%= role.getRoleName() %></h4>
                    <p class="mb-0 text-muted"><%= role.getDescription() %></p>
                </div>
                <div class="ms-auto text-end">
                    <span class="d-block small text-muted mb-1">Trạng thái</span>
                    <% if (role.getStatus() == 1) { %>
                        <span class="badge-soft badge-soft-success">Active</span>
                    <% } else { %>
                        <span class="badge-soft badge-soft-danger">Deactive</span>
                    <% } %>
                </div>
            </div>

            <form action="editRolePermission" method="POST">
                <input type="hidden" name="roleId" value="<%= role.getRoleId() %>" />
                
                <div class="panel-header border-0 mb-0 pb-0">
                    <h3 class="panel-title">
                        <i class="fas fa-list-check text-primary"></i> 
                        Danh Sách Quyền Hạn (Permissions)
                    </h3>
                </div>

                <div class="permission-grid">
                <%
                    List<Permission> allPerms = (List<Permission>) request.getAttribute("allPermissions");
                    List<Integer> assignedIds = (List<Integer>) request.getAttribute("assignedPermissionIds");
                    
                    if(allPerms != null && !allPerms.isEmpty()) {
                        for(Permission p : allPerms) {
                            boolean isChecked = assignedIds != null && assignedIds.contains(p.getPermissionId());
                %>
                    <div class="permission-item">
                        <label class="permission-label">
                            <input type="checkbox" class="custom-checkbox" name="permissions" value="<%= p.getPermissionId() %>" <%= isChecked ? "checked" : "" %> />
                            <div class="perm-content">
                                <span class="perm-name"><%= p.getPermissionName() %></span>
                                <span class="perm-desc"><%= p.getDescription() %></span>
                            </div>
                        </label>
                    </div>
                <%      }
                    } else {
                %>
                    <div class="col-12 py-4 text-center text-muted">
                        <i class="fas fa-box-open mb-2" style="font-size: 2rem; opacity: 0.5;"></i>
                        <p>Chưa có quyền hạn nào trong hệ thống.</p>
                    </div>
                <%  } %>
                </div>
                
                <div class="text-end">
                    <button type="submit" class="btn-save">
                        <i class="fas fa-save"></i> Lưu Các Thay Đổi
                    </button>
                </div>
            </form>
        </div>
        <% } %>
    </div>
</div>

<jsp:include page="../footer.jsp" />
