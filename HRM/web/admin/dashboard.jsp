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
        --sidebar-width: 260px;
    }

    body {
        background-color: var(--dark-bg);
        font-family: 'Inter', sans-serif;
    }

    /* Layout */
    .dashboard-wrapper {
        display: flex;
        min-height: calc(100vh - 64px); /* Subtract header height */
    }

    .sidebar-link:hover i, .sidebar-link.active i {
        color: var(--primary-color);
    }

    /* Main Content */
    .main-content {
        flex: 1;
        padding: 30px;
        width: calc(100% - var(--sidebar-width));
    }

    /* Page Header */
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

    /* Stat Cards (Colorful style like CodeAstro) */
    .stat-card-wrapper {
        margin-bottom: 25px;
    }
    
    .stat-card {
        border-radius: 12px;
        padding: 24px;
        color: white;
        position: relative;
        overflow: hidden;
        box-shadow: 0 10px 20px rgba(0,0,0,0.05);
        transition: transform 0.3s ease, box-shadow 0.3s ease;
        height: 100%;
        display: flex;
        flex-direction: column;
        justify-content: center;
    }

    .stat-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 15px 30px rgba(0,0,0,0.1);
    }

    .stat-card::after {
        content: '';
        position: absolute;
        top: -20px;
        right: -20px;
        width: 100px;
        height: 100px;
        background: rgba(255,255,255,0.1);
        border-radius: 50%;
    }

    .stat-card-icon {
        position: absolute;
        right: 20px;
        top: 50%;
        transform: translateY(-50%);
        font-size: 3.5rem;
        opacity: 0.2;
    }

    .stat-card-value {
        font-size: 2.2rem;
        font-weight: 800;
        margin-bottom: 5px;
        line-height: 1;
        z-index: 1;
    }

    .stat-card-title {
        font-size: 1rem;
        font-weight: 600;
        opacity: 0.9;
        margin-bottom: 15px;
        z-index: 1;
    }

    .stat-card-link {
        font-size: 0.85rem;
        color: rgba(255,255,255,0.8);
        text-decoration: none;
        display: inline-flex;
        align-items: center;
        gap: 5px;
        z-index: 1;
        transition: color 0.2s;
    }
    .stat-card-link:hover {
        color: white;
    }

    .bg-purple { background: linear-gradient(135deg, #7209b7, #3a0ca3); }
    .bg-blue { background: linear-gradient(135deg, #4361ee, #4895ef); }
    .bg-orange { background: linear-gradient(135deg, #f77f00, #f8961e); }
    .bg-green { background: linear-gradient(135deg, #2b9348, #55a630); }
    .bg-red { background: linear-gradient(135deg, #d00000, #9d0208); }
    .bg-dark-purple { background: linear-gradient(135deg, #3c096c, #240046); }

    /* Panels */
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

    /* Table Styles */
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

    .user-info {
        display: flex;
        align-items: center;
        gap: 12px;
    }

    .avatar-sm {
        width: 40px;
        height: 40px;
        border-radius: 10px;
        background: linear-gradient(135deg, #e0c3fc 0%, #8ec5fc 100%);
        color: #fff;
        display: flex;
        align-items: center;
        justify-content: center;
        font-weight: bold;
        font-size: 1.1rem;
    }

    .badge-soft {
        padding: 6px 12px;
        border-radius: 6px;
        font-weight: 600;
        font-size: 0.75rem;
    }
    .badge-soft-success { background: rgba(76, 201, 240, 0.1); color: #00b4d8; }
    .badge-soft-danger { background: rgba(247, 37, 133, 0.1); color: #f72585; }

    /* Custom Form Elements */
    .form-select-sm {
        border-radius: 6px;
        border: 1px solid #e2e8f0;
        padding: 6px 30px 6px 12px;
        font-size: 0.85rem;
        color: #4a5568;
        background-color: #f8fafc;
    }
    .form-select-sm:focus {
        border-color: var(--primary-color);
        box-shadow: 0 0 0 0.2rem rgba(67, 97, 238, 0.15);
    }

    .btn-action {
        width: 32px;
        height: 32px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        border-radius: 8px;
        transition: all 0.2s;
        border: none;
        color: #fff;
    }
    .btn-save { background: var(--success-color); }
    .btn-save:hover { background: #00b4d8; transform: scale(1.05); }
    
    .btn-toggle-on { background: #fca311; }
    .btn-toggle-off { background: #14213d; }
    .btn-view { background: var(--info-color); }
    
    .btn-action:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 8px rgba(0,0,0,0.1);
    }

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
                <h1 class="page-title">Dashboard</h1>
                <p class="breadcrumb">
                    <a href="${pageContext.request.contextPath}/home">Home</a> &nbsp;>&nbsp; Dashboard
                </p>
            </div>
            <div>
                <button class="btn btn-primary" style="background: var(--primary-color); border: none; border-radius: 8px; padding: 10px 20px; font-weight: 500;">
                    <i class="fas fa-plus me-2"></i> Thêm mới
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

        <!-- Stat Cards Grid -->
        <div class="row g-4 mb-4">
            <div class="col-xl-3 col-lg-6 col-md-6">
                <div class="stat-card bg-purple">
                    <i class="fas fa-users stat-card-icon"></i>
                    <div class="stat-card-value">${totalUsers}</div>
                    <div class="stat-card-title">Tổng Nhân Sự</div>
                    <a href="#users" class="stat-card-link">View Details <i class="fas fa-arrow-right ms-1"></i></a>
                </div>
            </div>
            
            <div class="col-xl-3 col-lg-6 col-md-6">
                <div class="stat-card bg-blue">
                    <i class="fas fa-envelope-open-text stat-card-icon"></i>
                    <div class="stat-card-value">${pendingLeaves}</div>
                    <div class="stat-card-title">Yêu Cầu Nghỉ Phép</div>
                    <a href="#" class="stat-card-link">View Details <i class="fas fa-arrow-right ms-1"></i></a>
                </div>
            </div>

            <div class="col-xl-3 col-lg-6 col-md-6">
                <div class="stat-card bg-orange">
                    <i class="fas fa-building stat-card-icon"></i>
                    <div class="stat-card-value">${totalDepartments}</div>
                    <div class="stat-card-title">Phòng Ban</div>
                    <a href="#" class="stat-card-link">View Details <i class="fas fa-arrow-right ms-1"></i></a>
                </div>
            </div>

            <div class="col-xl-3 col-lg-6 col-md-6">
                <div class="stat-card bg-green">
                    <i class="fas fa-user-shield stat-card-icon"></i>
                    <div class="stat-card-value">${totalRoles}</div>
                    <div class="stat-card-title">Vai Trò Hệ Thống</div>
                    <a href="${pageContext.request.contextPath}/role?action=list" class="stat-card-link">View Details <i class="fas fa-arrow-right ms-1"></i></a>
                </div>
            </div>
        </div>

        <div class="row g-4">
            <!-- Left Column: User Management -->
            <div class="col-xl-12 col-lg-12">
                <div class="admin-panel h-100" id="users">
                    <div class="panel-header">
                        <h3 class="panel-title">
                            <div style="width: 40px; height: 40px; border-radius: 10px; background: rgba(67, 97, 238, 0.1); color: var(--primary-color); display: flex; align-items: center; justify-content: center;">
                                <i class="fas fa-users-cog"></i>
                            </div>
                            Quản lý Người Dùng 
                        </h3>
                        <div class="d-flex gap-2">
                            <input type="text" class="form-control form-control-sm" placeholder="Tìm kiếm nhân viên..." style="border-radius: 8px; width: 200px;">
                            <button type="button" class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#addUserModal" style="border-radius: 8px; background: var(--primary-color); border: none; font-weight: 500; padding: 0 15px;">
                                <i class="fas fa-plus me-1"></i> Thêm Người Dùng
                            </button>
                        </div>
                    </div>

                    <div class="table-responsive">
                        <table class="table-custom">
                            <thead>
                                <tr>
                                    <th>Nhân viên</th>
                                    <th>Vai trò (Role)</th>
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
                                                    <div class="fw-bold text-dark">${u.fullName}</div>
                                                    <div class="small text-muted">${u.email}</div>
                                                </div>
                                            </div>
                                        </td>
                                        <td>
                                            <form method="post" action="${pageContext.request.contextPath}/admin/dashboard" class="d-flex align-items-center gap-2 m-0">
                                                <input type="hidden" name="action" value="updateRole" />
                                                <input type="hidden" name="userId" value="${u.userId}" />
                                                <select name="roleId" class="form-select form-select-sm" style="width: 140px;">
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
                                                    <span class="badge-soft badge-soft-success"><i class="fas fa-circle me-1" style="font-size: 6px; vertical-align: middle;"></i> Active</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge-soft badge-soft-danger"><i class="fas fa-circle me-1" style="font-size: 6px; vertical-align: middle;"></i> Inactive</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-end">
                                            <div class="d-flex justify-content-end gap-2">
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

            <!-- Role Management Panel (Feature 13-16) -->
            <div class="col-8 mt-4">
                <div class="admin-panel h-100" id="roles">
                    <div class="panel-header">
                        <h3 class="panel-title">
                            <div style="width: 40px; height: 40px; border-radius: 10px; background: rgba(76, 201, 240, 0.1); color: var(--success-color); display: flex; align-items: center; justify-content: center;">
                                <i class="fas fa-user-shield"></i>
                            </div>
                            Quản Lý Vai Trò 
                        </h3>
                        <div>
                            <a href="${pageContext.request.contextPath}/editRolePermission" class="btn btn-outline-primary btn-sm" style="border-radius: 8px; font-weight: 500;">
                                <i class="fas fa-key me-1"></i> Phân Quyền Chi Tiết
                            </a>
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
                                <c:forEach var="r" items="${roles}">
                                    <tr>
                                        <td class="fw-bold text-dark">#${r.roleId}</td>
                                        <td>
                                            <span class="fw-bold" style="color: var(--primary-color);">${r.roleName}</span>
                                        </td>
                                        <td class="text-muted">${r.description}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${r.status == 1}">
                                                    <span class="badge-soft badge-soft-success"><i class="fas fa-circle me-1" style="font-size: 6px; vertical-align: middle;"></i> Active</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge-soft badge-soft-danger"><i class="fas fa-circle me-1" style="font-size: 6px; vertical-align: middle;"></i> Deactive</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-end">
                                            <div class="d-flex justify-content-end gap-1">
                                                <!-- Feature 13: View Role Permissions -->
                                                <a href="${pageContext.request.contextPath}/editRolePermission?roleId=${r.roleId}" class="btn-action btn-view" title="Xem & Sửa quyền (Feature 13 & 16)" style="width: 32px; padding: 0;">
                                                    <i class="fas fa-key"></i>
                                                </a>
                                                <!-- Feature 14: Update Role Information -->
                                                <a href="${pageContext.request.contextPath}/role?action=update&roleId=${r.roleId}" class="btn-action btn-update" title="Sửa thông tin vai trò (Feature 14)" style="width: 32px; padding: 0;">
                                                    <i class="fas fa-edit"></i>
                                                </a>
                                                <!-- Feature 15: Active/Deactive Role -->
                                                <form method="post" action="${pageContext.request.contextPath}/activeDeactiveRole" class="m-0" onsubmit="return confirm('Bạn có chắc chắn muốn ${r.status == 1 ? 'VÔ HIỆU HÓA' : 'KÍCH HOẠT'} vai trò ${r.roleName} không?');">
                                                    <input type="hidden" name="action" value="toggle" />
                                                    <input type="hidden" name="roleId" value="${r.roleId}" />
                                                    <input type="hidden" name="source" value="dashboard" />
                                                    <button type="submit" class="btn-action ${r.status == 1 ? 'btn-toggle-on' : 'btn-toggle-off'}" title="${r.status == 1 ? 'Vô hiệu hóa (Feature 15)' : 'Kích hoạt (Feature 15)'}">
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

            <!-- Right Column: Charts & Logs -->
            <div class="col-xl-4 col-lg-12">
                <!-- Chart Panel -->
                <div class="admin-panel mb-4">
                    <div class="panel-header border-0 pb-0">
                        <h3 class="panel-title">
                            <div style="width: 40px; height: 40px; border-radius: 10px; background: rgba(76, 201, 240, 0.1); color: var(--success-color); display: flex; align-items: center; justify-content: center;">
                                <i class="fas fa-chart-bar"></i>
                            </div>
                            Tỉ Lệ Chấm Công
                        </h3>
                    </div>
                    <div style="height: 250px; position: relative;">
                        <canvas id="attendanceChart"></canvas>
                    </div>
                </div>

                <!-- Activity Log Panel -->
                <div class="admin-panel">
                    <div class="panel-header">
                        <h3 class="panel-title">
                            <div style="width: 40px; height: 40px; border-radius: 10px; background: rgba(248, 150, 30, 0.1); color: var(--warning-color); display: flex; align-items: center; justify-content: center;">
                                <i class="fas fa-history"></i>
                            </div>
                            Lịch Sử Hoạt Động
                        </h3>
                    </div>
                    
                    <div class="activity-feed">
                        <div class="d-flex mb-3">
                            <div class="me-3 mt-1">
                                <div style="width: 10px; height: 10px; border-radius: 50%; background: var(--primary-color);"></div>
                                <div style="width: 2px; height: 40px; background: #e2e8f0; margin: 5px auto;"></div>
                            </div>
                            <div>
                                <h6 class="mb-1" style="font-size: 0.9rem; font-weight: 600;">admin@hrm.com</h6>
                                <p class="mb-0 text-muted small">Cập nhật phân quyền cho Role Manager.</p>
                                <span class="small" style="color: #cbd5e1;">10 phút trước</span>
                            </div>
                        </div>
                        
                        <div class="d-flex mb-3">
                            <div class="me-3 mt-1">
                                <div style="width: 10px; height: 10px; border-radius: 50%; background: var(--success-color);"></div>
                                <div style="width: 2px; height: 40px; background: #e2e8f0; margin: 5px auto;"></div>
                            </div>
                            <div>
                                <h6 class="mb-1" style="font-size: 0.9rem; font-weight: 600;">Hệ Thống</h6>
                                <p class="mb-0 text-muted small">Tự động sao lưu Database thành công.</p>
                                <span class="small" style="color: #cbd5e1;">02:00 AM</span>
                            </div>
                        </div>

                        <div class="d-flex">
                            <div class="me-3 mt-1">
                                <div style="width: 10px; height: 10px; border-radius: 50%; background: var(--danger-color);"></div>
                            </div>
                            <div>
                                <h6 class="mb-1" style="font-size: 0.9rem; font-weight: 600;">manager@hrm.com</h6>
                                <p class="mb-0 text-muted small">Duyệt 3 đơn xin nghỉ phép.</p>
                                <span class="small" style="color: #cbd5e1;">Hôm qua</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Cấu hình Chart.js -->
<script>
    document.addEventListener("DOMContentLoaded", function() {
        const ctx = document.getElementById('attendanceChart').getContext('2d');
        
        // Dữ liệu giả lập
        const labels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
        const dataPresent = [240, 245, 238, 242, 248, 120, 10]; // Số người đi làm
        const dataAbsent = [8, 3, 10, 6, 0, 128, 238];          // Số người vắng/nghỉ

        new Chart(ctx, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [
                    {
                        label: 'Đi làm',
                        data: dataPresent,
                        backgroundColor: '#4361ee',
                        borderRadius: 6,
                        barPercentage: 0.6
                    },
                    {
                        label: 'Vắng mặt',
                        data: dataAbsent,
                        backgroundColor: '#e2e8f0',
                        borderRadius: 6,
                        barPercentage: 0.6
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    x: {
                        stacked: true,
                        grid: { display: false }
                    },
                    y: {
                        stacked: true,
                        beginAtZero: true,
                        grid: { borderDash: [5, 5], color: '#f1f5f9' },
                        border: { display: false }
                    }
                },
                plugins: {
                    legend: {
                        display: false
                    },
                    tooltip: {
                        backgroundColor: 'rgba(15, 23, 42, 0.9)',
                        padding: 12,
                        titleFont: { size: 13 },
                        bodyFont: { size: 13 },
                        cornerRadius: 8
                    }
                }
            }
        });
    });
</script>

<!-- Add User Modal -->
<div class="modal fade" id="addUserModal" tabindex="-1" aria-labelledby="addUserModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow" style="border-radius: 16px;">
            <div class="modal-header border-bottom-0 pb-0">
                <h5 class="modal-title fw-bold text-dark" id="addUserModalLabel">
                    <i class="fas fa-user-plus text-primary me-2"></i> Thêm Mới Người Dùng
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form action="${pageContext.request.contextPath}/admin/dashboard" method="post">
                <input type="hidden" name="action" value="addUser">
                <div class="modal-body">
                    <div class="mb-3">
                        <label for="password" class="form-label fw-bold small text-muted mb-1">Mật khẩu (Password) <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="password" name="password" required value="@123456" placeholder="Nhập mật khẩu" style="border-radius: 8px;">
                        <div class="form-text small mt-1">Mặc định là <strong class="text-dark">@123456</strong>, bạn có thể đổi nếu muốn.</div>
                    </div>
                    <div class="mb-3">
                        <label for="fullName" class="form-label fw-bold small text-muted mb-1">Họ và Tên (Full Name) <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="fullName" name="fullName" required placeholder="Nhập họ và tên đầy đủ" style="border-radius: 8px;">
                    </div>
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label for="email" class="form-label fw-bold small text-muted mb-1">Email <span class="text-danger">*</span></label>
                            <input type="email" class="form-control" id="email" name="email" required placeholder="Nhập địa chỉ email" style="border-radius: 8px;">
                        </div>
                        <div class="col-md-6 mb-3">
                            <label for="phone" class="form-label fw-bold small text-muted mb-1">Số điện thoại</label>
                            <input type="text" class="form-control" id="phone" name="phone" placeholder="Nhập số điện thoại" style="border-radius: 8px;">
                        </div>
                    </div>
                    <div class="mb-3">
                        <label for="roleId" class="form-label fw-bold small text-muted mb-1">Vai trò (Role) <span class="text-danger">*</span></label>
                        <select class="form-select" id="roleId" name="roleId" style="border-radius: 8px;">
                            <c:forEach var="r" items="${roles}">
                                <option value="${r.roleId}" ${r.roleId == 3 ? 'selected' : ''}>${r.roleName}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>
                <div class="modal-footer border-top-0 pt-0">
                    <button type="button" class="btn btn-light" data-bs-dismiss="modal" style="border-radius: 8px; font-weight: 500;">Hủy Bỏ</button>
                    <button type="submit" class="btn btn-primary" style="border-radius: 8px; font-weight: 500; background: var(--primary-color); border: none;">
                        <i class="fas fa-save me-1"></i> Lưu Người Dùng
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="../footer.jsp" />
