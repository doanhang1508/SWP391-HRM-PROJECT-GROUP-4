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
    Role role = (Role) request.getAttribute("role");
    String error = (String) request.getAttribute("error");
    String success = (String) request.getAttribute("success");
%>

<c:set var="pageTitle" value="Cập Nhật Vai Trò - Hệ Thống HRM" scope="request" />
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
        padding: 30px;
        box-shadow: 0 5px 20px rgba(0,0,0,0.02);
        margin-bottom: 25px;
        border: 1px solid rgba(0,0,0,0.04);
        max-width: 800px;
    }

    .panel-title {
        font-size: 1.15rem;
        font-weight: 700;
        color: var(--text-main);
        margin-bottom: 20px;
        display: flex;
        align-items: center;
        gap: 10px;
        padding-bottom: 15px;
        border-bottom: 1px solid #f1f5f9;
    }

    .form-label {
        font-weight: 600;
        color: var(--text-main);
        margin-bottom: 8px;
        font-size: 0.95rem;
    }

    .form-control {
        border-radius: 8px;
        border: 1px solid #e2e8f0;
        padding: 12px 16px;
        font-size: 0.95rem;
        transition: all 0.2s;
    }

    .form-control:focus {
        border-color: var(--primary-color);
        box-shadow: 0 0 0 3px rgba(67, 97, 238, 0.1);
    }

    .form-control[readonly] {
        background-color: #f8fafc;
        color: #64748b;
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
        cursor: pointer;
    }

    .btn-save:hover {
        background: var(--secondary-color);
        transform: translateY(-2px);
        box-shadow: 0 5px 15px rgba(67, 97, 238, 0.3);
    }
</style>

<div class="dashboard-wrapper">
    <!-- Sidebar -->
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="roles" />
    </jsp:include>

    <!-- Main Content -->
    <div class="main-content">
        <div class="page-header">
            <div>
                <h1 class="page-title">Cập Nhật Vai Trò</h1>
                <p class="breadcrumb">
                    <a href="${pageContext.request.contextPath}/admin/dashboard">Dashboard</a> &nbsp;>&nbsp; 
                    <a href="${pageContext.request.contextPath}/role?action=list">Quản lý vai trò</a> &nbsp;>&nbsp; 
                    Cập nhật
                </p>
            </div>
            <div>
                <a href="${pageContext.request.contextPath}/role?action=list" class="btn btn-outline-secondary" style="border-radius: 8px; padding: 10px 20px; font-weight: 500;">
                    <i class="fas fa-arrow-left me-2"></i> Quay Lại
                </a>
            </div>
        </div>

        <c:if test="${not empty success}">
            <div class="alert alert-success alert-dismissible fade show border-0 shadow-sm" role="alert" style="border-radius: 10px; background: #d1fae5; color: #065f46; max-width: 800px;">
                <i class="fas fa-check-circle me-2"></i> <%= h(success) %>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>
        <c:if test="${not empty error}">
            <div class="alert alert-danger alert-dismissible fade show border-0 shadow-sm" role="alert" style="border-radius: 10px; background: #fee2e2; color: #991b1b; max-width: 800px;">
                <i class="fas fa-exclamation-circle me-2"></i> <%= h(error) %>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>

        <% if (role != null) { %>
        <div class="admin-panel">
            <h3 class="panel-title">
                <div style="width: 40px; height: 40px; border-radius: 10px; background: rgba(67, 97, 238, 0.1); color: var(--primary-color); display: flex; align-items: center; justify-content: center;">
                    <i class="fas fa-edit"></i>
                </div>
                Thông Tin Vai Trò
            </h3>

            <form action="role?action=update" method="post">
                <input type="hidden" name="roleId" value="<%= role.getRoleId() %>">

                <div class="mb-4">
                    <label class="form-label">Role ID</label>
                    <input type="text" class="form-control" value="<%= role.getRoleId() %>" readonly>
                    <div class="form-text mt-2 text-muted"><i class="fas fa-info-circle me-1"></i> ID vai trò do hệ thống quản lý và không thể chỉnh sửa.</div>
                </div>

                <div class="mb-4">
                    <label class="form-label">Tên Vai Trò (Role Name) <span class="text-danger">*</span></label>
                    <input type="text" class="form-control" name="roleName" value="<%= h(role.getRoleName()) %>" maxlength="50" required placeholder="Nhập tên vai trò...">
                </div>

                <div class="mb-4">
                    <label class="form-label">Mô Tả (Description)</label>
                    <textarea class="form-control" name="description" rows="4" maxlength="255" placeholder="Nhập mô tả ngắn gọn về quyền hạn và trách nhiệm của vai trò này..."><%= h(role.getDescription()) %></textarea>
                </div>

                <div class="text-end mt-4 pt-3 border-top">
                    <button type="submit" class="btn-save">
                        <i class="fas fa-save"></i> Lưu Thay Đổi
                    </button>
                </div>
            </form>
        </div>
        <% } %>
    </div>
</div>

<jsp:include page="../footer.jsp" />
