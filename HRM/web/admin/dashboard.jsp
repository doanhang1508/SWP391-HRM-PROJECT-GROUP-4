<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="pageTitle" value="Admin Dashboard - Hệ Thống HRM" scope="request" />
<jsp:include page="../header.jsp" />

<!-- Google Fonts & Icons -->
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
<!-- Chart.js -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<style>
    :root {
        --primary-color: #3b82f6;
        --primary-light: #eff6ff;
        --secondary-color: #64748b;
        --success-color: #10b981;
        --danger-color: #ef4444;
        --warning-color: #f59e0b;
        --bg-body: #f8fafc;
        --card-bg: #ffffff;
        --text-main: #0f172a;
        --text-muted: #64748b;
        --border-color: #e2e8f0;
        --sidebar-width: 260px;
    }

    body {
        background-color: var(--bg-body);
        font-family: 'Inter', sans-serif;
        color: var(--text-main);
    }

    /* Layout */
    .dashboard-wrapper {
        display: flex;
        min-height: calc(100vh - 64px);
    }

    .main-content {
        flex: 1;
        padding: 40px;
        width: calc(100% - var(--sidebar-width));
    }

    /* Page Header */
    .page-header {
        display: flex;
        justify-content: space-between;
        align-items: flex-end;
        margin-bottom: 35px;
    }

    .page-title {
        font-size: 1.75rem;
        font-weight: 800;
        color: var(--text-main);
        margin: 0 0 8px 0;
        letter-spacing: -0.5px;
    }

    .breadcrumb {
        font-size: 0.9rem;
        color: var(--text-muted);
        margin-bottom: 0;
        font-weight: 500;
    }
    .breadcrumb a {
        color: var(--primary-color);
        text-decoration: none;
        transition: color 0.2s;
    }
    .breadcrumb a:hover { color: #2563eb; }

    /* Stat Cards (Premium Minimalist Style) */
    .stat-card {
        background: var(--card-bg);
        border-radius: 20px;
        padding: 24px;
        position: relative;
        overflow: hidden;
        box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.03), 0 2px 4px -2px rgba(0, 0, 0, 0.03);
        border: 1px solid rgba(226, 232, 240, 0.8);
        transition: transform 0.3s ease, box-shadow 0.3s ease;
        height: 100%;
        display: flex;
        flex-direction: column;
        justify-content: space-between;
    }

    .stat-card:hover {
        transform: translateY(-4px);
        box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.05), 0 8px 10px -6px rgba(0, 0, 0, 0.01);
    }

    .stat-header {
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        margin-bottom: 20px;
    }

    .stat-title {
        font-size: 0.95rem;
        font-weight: 600;
        color: var(--text-muted);
        text-transform: uppercase;
        letter-spacing: 0.5px;
        margin: 0;
    }

    .stat-icon {
        width: 48px;
        height: 48px;
        border-radius: 14px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.5rem;
    }

    .icon-blue { background: #eff6ff; color: #3b82f6; }
    .icon-green { background: #f0fdf4; color: #10b981; }
    .icon-orange { background: #fff7ed; color: #f97316; }
    .icon-purple { background: #faf5ff; color: #a855f7; }

    .stat-value {
        font-size: 2.5rem;
        font-weight: 800;
        color: var(--text-main);
        line-height: 1;
        margin-bottom: 12px;
        letter-spacing: -1px;
    }

    .stat-footer {
        font-size: 0.85rem;
        font-weight: 500;
    }
    
    .stat-footer a {
        color: var(--primary-color);
        text-decoration: none;
        display: inline-flex;
        align-items: center;
        gap: 6px;
        transition: gap 0.2s;
    }
    .stat-footer a:hover {
        gap: 10px;
    }

    /* Panels */
    .admin-panel {
        background: var(--card-bg);
        border-radius: 20px;
        padding: 30px;
        box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.03), 0 2px 4px -2px rgba(0, 0, 0, 0.03);
        border: 1px solid rgba(226, 232, 240, 0.8);
        margin-bottom: 24px;
    }

    .panel-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 24px;
    }

    .panel-title {
        font-size: 1.25rem;
        font-weight: 700;
        color: var(--text-main);
        margin: 0;
        display: flex;
        align-items: center;
        gap: 12px;
        letter-spacing: -0.3px;
    }
    
    .panel-title-icon {
        width: 32px; height: 32px;
        background: var(--bg-body);
        border-radius: 8px;
        display: flex; align-items: center; justify-content: center;
        color: var(--secondary-color);
        font-size: 0.9rem;
    }

    /* Table Styles */
    .table-responsive {
        border-radius: 12px;
        overflow: hidden;
        border: 1px solid var(--border-color);
    }

    .table-custom {
        width: 100%;
        margin-bottom: 0;
        border-collapse: collapse;
    }

    .table-custom th {
        background: var(--bg-body);
        color: var(--text-muted);
        font-weight: 600;
        font-size: 0.8rem;
        text-transform: uppercase;
        letter-spacing: 0.8px;
        padding: 16px 20px;
        border-bottom: 1px solid var(--border-color);
    }

    .table-custom td {
        background: var(--card-bg);
        padding: 16px 20px;
        vertical-align: middle;
        color: var(--text-main);
        font-size: 0.95rem;
        border-bottom: 1px solid var(--border-color);
        transition: background 0.2s;
    }

    .table-custom tbody tr:last-child td { border-bottom: none; }
    .table-custom tbody tr:hover td { background: #f8fafc; }

    .user-info {
        display: flex;
        align-items: center;
        gap: 16px;
    }

    .avatar-sm {
        width: 44px;
        height: 44px;
        border-radius: 12px;
        background: var(--primary-light);
        color: var(--primary-color);
        display: flex;
        align-items: center;
        justify-content: center;
        font-weight: 700;
        font-size: 1.1rem;
    }

    .badge-soft {
        padding: 6px 12px;
        border-radius: 20px;
        font-weight: 600;
        font-size: 0.75rem;
        display: inline-flex;
        align-items: center;
        gap: 6px;
    }
    .badge-soft-success { background: #dcfce7; color: #16a34a; }
    .badge-soft-danger { background: #fee2e2; color: #dc2626; }
    .badge-soft-gray { background: #f1f5f9; color: #64748b; }

    /* Custom Form Elements */
    .form-select-sm {
        border-radius: 8px;
        border: 1px solid var(--border-color);
        padding: 8px 30px 8px 14px;
        font-size: 0.9rem;
        color: var(--text-main);
        background-color: var(--card-bg);
        font-weight: 500;
        cursor: pointer;
        transition: all 0.2s;
    }
    .form-select-sm:focus {
        border-color: var(--primary-color);
        box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
        outline: none;
    }

    .btn-action {
        width: 36px;
        height: 36px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        border-radius: 10px;
        transition: all 0.2s;
        border: 1px solid transparent;
        color: var(--text-muted);
        background: var(--bg-body);
        cursor: pointer;
    }
    .btn-action:hover {
        background: var(--card-bg);
        border-color: var(--border-color);
        box-shadow: 0 2px 4px rgba(0,0,0,0.05);
        color: var(--primary-color);
    }
    
    .btn-save { color: var(--success-color); }
    .btn-save:hover { color: var(--success-color); border-color: #dcfce7; background: #f0fdf4; }
    
    .btn-toggle-on { color: var(--warning-color); }
    .btn-toggle-on:hover { color: var(--warning-color); border-color: #fef3c7; background: #fffbeb; }
    
    .btn-view { color: var(--info-color); }

    .btn-primary-custom {
        background: var(--primary-color);
        color: white;
        border: none;
        border-radius: 10px;
        padding: 10px 24px;
        font-weight: 600;
        font-size: 0.95rem;
        transition: all 0.2s;
        box-shadow: 0 4px 6px -1px rgba(59, 130, 246, 0.2);
    }
    .btn-primary-custom:hover {
        background: #2563eb;
        transform: translateY(-1px);
        box-shadow: 0 6px 8px -1px rgba(59, 130, 246, 0.3);
    }

    /* Activity Feed */
    .activity-feed {
        position: relative;
        padding-left: 20px;
    }
    .activity-feed::before {
        content: '';
        position: absolute;
        top: 0; bottom: 0; left: 25px;
        width: 2px;
        background: var(--border-color);
    }
    .activity-item {
        position: relative;
        padding-left: 35px;
        margin-bottom: 24px;
    }
    .activity-item:last-child { margin-bottom: 0; }
    
    .activity-dot {
        position: absolute;
        left: -1px;
        top: 4px;
        width: 12px; height: 12px;
        border-radius: 50%;
        background: var(--primary-color);
        border: 2px solid var(--card-bg);
        box-shadow: 0 0 0 3px var(--primary-light);
    }
    .activity-dot.success { background: var(--success-color); box-shadow: 0 0 0 3px #dcfce7; }
    .activity-dot.warning { background: var(--warning-color); box-shadow: 0 0 0 3px #fef3c7; }
    
    .activity-time {
        font-size: 0.75rem;
        color: var(--text-muted);
        font-weight: 600;
        margin-bottom: 4px;
        display: block;
    }
    .activity-text {
        font-size: 0.9rem;
        color: var(--text-main);
        margin: 0;
        line-height: 1.5;
    }
    .activity-user { font-weight: 600; color: #0f172a; }

</style>

<div class="dashboard-wrapper">
    <!-- Sidebar -->
    <jsp:include page="sidebar.jsp">
        <jsp:param name="activeMenu" value="dashboard" />
    </jsp:include>

    <!-- Main Content -->
    <div class="main-content">
        <div class="page-header">
            <div>
                <p class="breadcrumb">
                    <a href="${pageContext.request.contextPath}/home">Home</a> &nbsp;/&nbsp; <span style="color: var(--text-main);">Dashboard</span>
                </p>
                <h1 class="page-title">Admin Dashboard</h1>
            </div>
            <div>
                <button class="btn-primary-custom" data-bs-toggle="modal" data-bs-target="#addUserModal">
                    <i class="fas fa-plus me-2"></i> Thêm Người Dùng
                </button>
            </div>
        </div>

        <!-- System Alerts -->
        <c:if test="${not empty param.message}">
            <div class="alert alert-success alert-dismissible fade show shadow-sm border-0" role="alert" style="border-radius: 12px; background: #f0fdf4; color: #16a34a; border-left: 4px solid #16a34a !important;">
                <i class="fas fa-check-circle me-2"></i> ${param.message}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>
        <c:if test="${not empty param.error}">
            <div class="alert alert-danger alert-dismissible fade show shadow-sm border-0" role="alert" style="border-radius: 12px; background: #fef2f2; color: #dc2626; border-left: 4px solid #dc2626 !important;">
                <i class="fas fa-exclamation-circle me-2"></i> ${param.error}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>

        <!-- Stat Cards Grid -->
        <div class="row g-4 mb-4">
            <div class="col-xl-3 col-lg-6 col-md-6">
                <div class="stat-card">
                    <div class="stat-header">
                        <h3 class="stat-title">Tổng Nhân Sự</h3>
                        <div class="stat-icon icon-blue"><i class="fas fa-users"></i></div>
                    </div>
                    <div>
                        <div class="stat-value">${totalUsers}</div>
                        <div class="stat-footer">
                            <a href="#users">Xem danh sách <i class="fas fa-arrow-right"></i></a>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="col-xl-3 col-lg-6 col-md-6">
                <div class="stat-card">
                    <div class="stat-header">
                        <h3 class="stat-title">Yêu Cầu Nghỉ Phép</h3>
                        <div class="stat-icon icon-orange"><i class="fas fa-envelope-open-text"></i></div>
                    </div>
                    <div>
                        <div class="stat-value">${pendingLeaves}</div>
                        <div class="stat-footer">
                            <a href="#" style="color: var(--warning-color);">Xử lý yêu cầu <i class="fas fa-arrow-right"></i></a>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-xl-3 col-lg-6 col-md-6">
                <div class="stat-card">
                    <div class="stat-header">
                        <h3 class="stat-title">Phòng Ban</h3>
                        <div class="stat-icon icon-green"><i class="fas fa-building"></i></div>
                    </div>
                    <div>
                        <div class="stat-value">${totalDepartments}</div>
                        <div class="stat-footer">
                            <a href="#" style="color: var(--success-color);">Quản lý phòng ban <i class="fas fa-arrow-right"></i></a>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-xl-3 col-lg-6 col-md-6">
                <div class="stat-card">
                    <div class="stat-header">
                        <h3 class="stat-title">Vai Trò Hệ Thống</h3>
                        <div class="stat-icon icon-purple"><i class="fas fa-user-shield"></i></div>
                    </div>
                    <div>
                        <div class="stat-value">${totalRoles}</div>
                        <div class="stat-footer">
                            <a href="${pageContext.request.contextPath}/role?action=list" style="color: #a855f7;">Quản lý phân quyền <i class="fas fa-arrow-right"></i></a>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row g-4">
            <!-- Left Column: User Management -->
            <div class="col-xl-8 col-lg-12">
                <div class="admin-panel h-100 mb-0" id="users">
                    <div class="panel-header">
                        <h3 class="panel-title">
                            <div class="panel-title-icon"><i class="fas fa-users-cog"></i></div>
                            Danh Sách Người Dùng
                        </h3>
                        <div>
                            <div class="input-group" style="width: 250px;">
                                <span class="input-group-text bg-body border-end-0 text-muted" style="border-radius: 8px 0 0 8px;"><i class="fas fa-search"></i></span>
                                <input type="text" class="form-control border-start-0 ps-0" placeholder="Tìm kiếm nhân viên..." style="border-radius: 0 8px 8px 0; background: var(--bg-body); box-shadow: none;">
                            </div>
                        </div>
                    </div>

                    <div class="table-responsive">
                        <table class="table-custom">
                            <thead>
                                <tr>
                                    <th>Nhân viên</th>
                                    <th>Vai trò</th>
                                    <th>Trạng thái</th>
                                    <th class="text-end">Hành động</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="u" items="${users}">
                                    <tr>
                                        <td>
                                            <div class="user-info">
                                                <div class="avatar-sm">
                                                    ${u.fullName.substring(0,1)}
                                                </div>
                                                <div>
                                                    <div class="fw-bold" style="color: #0f172a; font-size: 0.95rem;">${u.fullName}</div>
                                                    <div class="text-muted" style="font-size: 0.85rem;">${u.email}</div>
                                                </div>
                                            </div>
                                        </td>
                                        <td>
                                            <form method="post" action="${pageContext.request.contextPath}/admin/dashboard" class="d-flex align-items-center gap-2 m-0">
                                                <input type="hidden" name="action" value="updateRole" />
                                                <input type="hidden" name="userId" value="${u.userId}" />
                                                <select name="roleId" class="form-select-sm" style="width: 140px;">
                                                    <c:forEach var="r" items="${roles}">
                                                        <option value="${r.roleId}" ${r.roleId == u.roleId ? 'selected' : ''}>${r.roleName}</option>
                                                    </c:forEach>
                                                </select>
                                                <button type="submit" class="btn-action btn-save" title="Lưu phân quyền">
                                                    <i class="fas fa-check"></i>
                                                </button>
                                            </form>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${u.status == 1}">
                                                    <span class="badge-soft badge-soft-success"><i class="fas fa-circle" style="font-size: 8px;"></i> Hoạt động</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge-soft badge-soft-danger"><i class="fas fa-circle" style="font-size: 8px;"></i> Đã khóa</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-end">
                                            <div class="d-flex justify-content-end gap-1">
                                                <form method="post" action="${pageContext.request.contextPath}/admin/dashboard" class="m-0" onsubmit="return confirm('Bạn có chắc chắn muốn ${u.status == 1 ? 'KHÓA' : 'MỞ KHÓA'} tài khoản của ${u.fullName} không?');">
                                                    <input type="hidden" name="action" value="toggleStatus" />
                                                    <input type="hidden" name="userId" value="${u.userId}" />
                                                    <button type="submit" class="btn-action ${u.status == 1 ? 'btn-toggle-on' : 'btn-toggle-off'}" title="${u.status == 1 ? 'Khóa tài khoản' : 'Mở khóa tài khoản'}">
                                                        <i class="fas ${u.status == 1 ? 'fa-lock' : 'fa-unlock'}"></i>
                                                    </button>
                                                </form>
                                                <a href="${pageContext.request.contextPath}/profile?userId=${u.userId}" class="btn-action btn-view" title="Xem chi tiết">
                                                    <i class="fas fa-eye"></i>
                                                </a>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Right Column: Charts & Logs -->
            <div class="col-xl-4 col-lg-12">
                <!-- Activity Log Panel -->
                <div class="admin-panel mb-4">
                    <div class="panel-header mb-4">
                        <h3 class="panel-title">
                            <div class="panel-title-icon"><i class="fas fa-bolt"></i></div>
                            Hoạt Động Gần Đây
                        </h3>
                    </div>
                    
                    <div class="activity-feed">
                        <div class="activity-item">
                            <div class="activity-dot"></div>
                            <span class="activity-time">Vừa xong</span>
                            <p class="activity-text"><span class="activity-user">Bạn</span> đã cập nhật phân quyền cho Role Manager.</p>
                        </div>
                        
                        <div class="activity-item">
                            <div class="activity-dot success"></div>
                            <span class="activity-time">2 giờ trước</span>
                            <p class="activity-text"><span class="activity-user">Hệ Thống</span> tự động sao lưu Database thành công.</p>
                        </div>

                        <div class="activity-item">
                            <div class="activity-dot warning"></div>
                            <span class="activity-time">Hôm qua, 15:30</span>
                            <p class="activity-text"><span class="activity-user">manager@hrm.com</span> đã duyệt 3 đơn xin nghỉ phép.</p>
                        </div>
                        
                        <div class="activity-item">
                            <div class="activity-dot"></div>
                            <span class="activity-time">Hôm qua, 09:15</span>
                            <p class="activity-text"><span class="activity-user">Nguyễn Văn A</span> đã đăng nhập hệ thống lần đầu.</p>
                        </div>
                    </div>
                    
                    <div class="text-center mt-4">
                        <a href="#" class="text-decoration-none" style="font-size: 0.9rem; font-weight: 600; color: var(--primary-color);">Xem tất cả hoạt động</a>
                    </div>
                </div>

                <!-- Chart Panel -->
                <div class="admin-panel mb-0">
                    <div class="panel-header border-0 pb-0">
                        <h3 class="panel-title">
                            <div class="panel-title-icon"><i class="fas fa-chart-line"></i></div>
                            Tỉ Lệ Đi Làm
                        </h3>
                    </div>
                    <div style="height: 220px; position: relative; margin-top: 15px;">
                        <canvas id="attendanceChart"></canvas>
                    </div>
                </div>
            </div>
            
            <!-- Roles Table (Full Width Bottom) -->
            <div class="col-12 mt-4">
                <div class="admin-panel mb-0" id="roles">
                    <div class="panel-header">
                        <h3 class="panel-title">
                            <div class="panel-title-icon"><i class="fas fa-user-shield"></i></div>
                            Quản Lý Vai Trò Hệ Thống
                        </h3>
                        <div>
                            <a href="${pageContext.request.contextPath}/editRolePermission" class="btn btn-outline-secondary btn-sm" style="border-radius: 8px; font-weight: 600; border-color: var(--border-color); color: var(--text-main);">
                                <i class="fas fa-key me-1"></i> Phân Quyền Chi Tiết
                            </a>
                        </div>
                    </div>

                    <div class="table-responsive">
                        <table class="table-custom">
                            <thead>
                                <tr>
                                    <th style="width: 80px;">ID</th>
                                    <th>Tên Vai Trò</th>
                                    <th>Mô Tả</th>
                                    <th>Trạng Thái</th>
                                    <th class="text-end">Hành Động</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="r" items="${roles}">
                                    <tr>
                                        <td class="text-muted fw-bold">#${r.roleId}</td>
                                        <td>
                                            <span class="fw-bold" style="color: var(--text-main); font-size: 0.95rem;">${r.roleName}</span>
                                        </td>
                                        <td class="text-muted" style="font-size: 0.9rem;">${r.description}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${r.status == 1}">
                                                    <span class="badge-soft badge-soft-success"><i class="fas fa-circle" style="font-size: 8px;"></i> Đang bật</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge-soft badge-soft-gray"><i class="fas fa-circle" style="font-size: 8px;"></i> Đã tắt</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-end">
                                            <div class="d-flex justify-content-end gap-1">
                                                <a href="${pageContext.request.contextPath}/editRolePermission?roleId=${r.roleId}" class="btn-action btn-view" title="Phân quyền">
                                                    <i class="fas fa-key"></i>
                                                </a>
                                                <a href="${pageContext.request.contextPath}/role?action=update&roleId=${r.roleId}" class="btn-action btn-view" title="Sửa thông tin">
                                                    <i class="fas fa-edit"></i>
                                                </a>
                                                <form method="post" action="${pageContext.request.contextPath}/activeDeactiveRole" class="m-0" onsubmit="return confirm('Bạn có chắc chắn muốn ${r.status == 1 ? 'VÔ HIỆU HÓA' : 'KÍCH HOẠT'} vai trò ${r.roleName} không?');">
                                                    <input type="hidden" name="action" value="toggle" />
                                                    <input type="hidden" name="roleId" value="${r.roleId}" />
                                                    <input type="hidden" name="source" value="dashboard" />
                                                    <button type="submit" class="btn-action ${r.status == 1 ? 'btn-toggle-on' : ''}" title="${r.status == 1 ? 'Vô hiệu hóa' : 'Kích hoạt'}">
                                                        <i class="fas ${r.status == 1 ? 'fa-lock' : 'fa-unlock'}"></i>
                                                    </button>
                                                </form>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            
        </div>
    </div>
</div>

<!-- Chart.js Setup -->
<script>
    document.addEventListener("DOMContentLoaded", function() {
        const ctx = document.getElementById('attendanceChart').getContext('2d');
        
        const labels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
        const dataPresent = [240, 245, 238, 242, 248, 120, 10]; 
        const dataAbsent = [8, 3, 10, 6, 0, 128, 238];          

        new Chart(ctx, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [
                    {
                        label: 'Đi làm',
                        data: dataPresent,
                        backgroundColor: '#3b82f6',
                        borderRadius: 4,
                        barPercentage: 0.5
                    },
                    {
                        label: 'Vắng/Nghỉ',
                        data: dataAbsent,
                        backgroundColor: '#e2e8f0',
                        borderRadius: 4,
                        barPercentage: 0.5
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    x: {
                        stacked: true,
                        grid: { display: false },
                        border: { display: false },
                        ticks: { font: { family: 'Inter', size: 11 }, color: '#64748b' }
                    },
                    y: {
                        stacked: true,
                        beginAtZero: true,
                        grid: { color: '#f1f5f9' },
                        border: { display: false },
                        ticks: { font: { family: 'Inter', size: 11 }, color: '#94a3b8' }
                    }
                },
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        backgroundColor: '#0f172a',
                        padding: 12,
                        titleFont: { family: 'Inter', size: 13, weight: '600' },
                        bodyFont: { family: 'Inter', size: 12 },
                        cornerRadius: 8,
                        boxPadding: 4
                    }
                }
            }
        });
    });
</script>

<!-- Add User Modal -->
<div class="modal fade" id="addUserModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 20px;">
            <div class="modal-header border-bottom-0 pb-0 pt-4 px-4">
                <h5 class="modal-title fw-bold" style="font-size: 1.25rem;">
                    Thêm Mới Người Dùng
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form action="${pageContext.request.contextPath}/admin/dashboard" method="post">
                <input type="hidden" name="action" value="addUser">
                <div class="modal-body px-4 pt-3">
                    <div class="mb-3">
                        <label class="form-label fw-semibold small text-muted mb-1">Mật khẩu khởi tạo</label>
                        <input type="text" class="form-control" name="password" required value="@123456" style="border-radius: 10px; padding: 10px 15px; border-color: #e2e8f0; font-weight: 500;">
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold small text-muted mb-1">Họ và Tên <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" name="fullName" required placeholder="Ví dụ: Nguyễn Văn A" style="border-radius: 10px; padding: 10px 15px; border-color: #e2e8f0;">
                    </div>
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-semibold small text-muted mb-1">Email <span class="text-danger">*</span></label>
                            <input type="email" class="form-control" name="email" required placeholder="name@company.com" style="border-radius: 10px; padding: 10px 15px; border-color: #e2e8f0;">
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-semibold small text-muted mb-1">Số điện thoại</label>
                            <input type="text" class="form-control" name="phone" placeholder="09xxxxxxx" style="border-radius: 10px; padding: 10px 15px; border-color: #e2e8f0;">
                        </div>
                    </div>
                    <div class="mb-2">
                        <label class="form-label fw-semibold small text-muted mb-1">Cấp quyền ban đầu <span class="text-danger">*</span></label>
                        <select class="form-select" name="roleId" style="border-radius: 10px; padding: 10px 15px; border-color: #e2e8f0; font-weight: 500;">
                            <c:forEach var="r" items="${roles}">
                                <option value="${r.roleId}" ${r.roleId == 3 ? 'selected' : ''}>${r.roleName}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>
                <div class="modal-footer border-top-0 pt-0 pb-4 px-4">
                    <button type="button" class="btn btn-light" data-bs-dismiss="modal" style="border-radius: 10px; font-weight: 600; padding: 10px 20px; color: #64748b; background: #f1f5f9; border: none;">Hủy</button>
                    <button type="submit" class="btn-primary-custom" style="padding: 10px 24px;">Tạo Tài Khoản</button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="../footer.jsp" />
