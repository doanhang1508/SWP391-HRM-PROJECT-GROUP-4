<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="pageTitle" value="Chi tiết Hồ sơ Nhân sự" scope="request" />
<jsp:include page="../header.jsp" />

<style>
    body { background-color: #f1f5f9; font-family: 'Inter', sans-serif; }
    .dashboard-wrapper { display: flex; min-height: calc(100vh - 64px); }
    .main-content { flex: 1; padding: 24px 32px; width: calc(100% - 260px); }
    
    /* Breadcrumb & Header */
    .page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; }
    .breadcrumb-title { font-size: 1.25rem; font-weight: 700; color: #0f172a; margin: 0; }
    .breadcrumb-title span { color: #64748b; font-weight: 500; font-size: 1rem; }
    .btn-back { display: inline-flex; align-items: center; gap: 8px; color: #64748b; text-decoration: none; font-weight: 600; font-size: 0.9rem; transition: color 0.2s; }
    .btn-back:hover { color: #0f172a; }

    /* Profile Card */
    .profile-card { background: #fff; border-radius: 16px; border: 1px solid #e2e8f0; padding: 24px; display: flex; align-items: center; justify-content: space-between; margin-bottom: 24px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); }
    .profile-left { display: flex; align-items: center; gap: 20px; }
    .avatar-lg { width: 80px; height: 80px; border-radius: 50%; background: #e0e7ff; color: #3730a3; display: flex; align-items: center; justify-content: center; font-size: 2rem; font-weight: 700; }
    .profile-name { font-size: 1.4rem; font-weight: 800; color: #0f172a; margin: 0 0 4px; }
    .profile-role { color: #64748b; font-size: 0.95rem; margin: 0 0 8px; }
    .status-badge { display: inline-block; padding: 4px 12px; border-radius: 20px; font-size: 0.75rem; font-weight: 700; }
    .status-active { background: #dcfce7; color: #166534; }
    .status-inactive { background: #fee2e2; color: #991b1b; }
    
    .btn-edit { background: #fff; border: 1px solid #cbd5e1; color: #334155; padding: 8px 16px; border-radius: 8px; font-weight: 600; font-size: 0.9rem; cursor: pointer; transition: all 0.2s; display: flex; align-items: center; gap: 8px; text-decoration: none; }
    .btn-edit:hover { background: #f8fafc; border-color: #94a3b8; color: #0f172a; }

    /* Tabs */
    .nav-tabs-custom { display: flex; border-bottom: 2px solid #e2e8f0; margin-bottom: 24px; gap: 32px; }
    .nav-tab { padding: 12px 0; font-size: 0.95rem; font-weight: 600; color: #64748b; cursor: pointer; border-bottom: 2px solid transparent; margin-bottom: -2px; transition: all 0.2s; text-decoration: none; display: inline-block; }
    .nav-tab:hover { color: #0f172a; }
    .nav-tab.active { color: #2563eb; border-bottom-color: #2563eb; }

    /* Content Card */
    .content-card { background: #fff; border-radius: 16px; border: 1px solid #e2e8f0; padding: 24px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); }
    .section-title { font-size: 1.1rem; font-weight: 700; color: #0f172a; margin: 0 0 20px; }
    
    /* Form Grid */
    .form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 24px; }
    .form-group { display: flex; flex-direction: column; gap: 8px; }
    .form-group.full-width { grid-column: span 2; }
    .form-label { font-size: 0.85rem; font-weight: 700; color: #475569; }
    .form-control-view { background: #f8fafc; border: 1px solid #e2e8f0; padding: 10px 16px; border-radius: 8px; font-size: 0.95rem; color: #0f172a; font-weight: 500; width: 100%; min-height: 42px; display: flex; align-items: center; }

</style>

<div class="dashboard-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="${sessionScope.currentUser.roleId == 3 || sessionScope.currentUser.roleId == 6 ? 'my-employees' : 'employees'}" />
    </jsp:include>

    <div class="main-content">
        <!-- Header -->
        <div class="page-header">
            <div>
                <a href="javascript:history.back()" class="btn-back" style="margin-bottom: 12px;">
                    <i class="fas fa-arrow-left"></i> Quay lại
                </a>
                <h1 class="breadcrumb-title">Quản lý Hồ sơ Nhân sự <span>/ Chi tiết</span></h1>
            </div>
        </div>

        <!-- Profile Hero Card -->
        <div class="profile-card">
            <div class="profile-left">
                <div class="avatar-lg">${employee.fullName.substring(0,1)}</div>
                <div>
                    <h2 class="profile-name">${employee.fullName}</h2>
                    <p class="profile-role">
                        ${empPos != null ? empPos.positionName : 'Chưa cập nhật'} | 
                        ${empDept != null ? empDept.departmentName : 'Chưa phân bổ'}
                    </p>
                    <span class="status-badge ${employee.status == 1 ? 'status-active' : 'status-inactive'}">
                        <i class="fas ${employee.status == 1 ? 'fa-check-circle' : 'fa-lock'} me-1"></i>
                        ${employee.status == 1 ? 'Đang làm việc' : 'Đã nghỉ/Khóa'}
                    </span>
                </div>
            </div>
            <c:if test="${sessionScope.currentUser.roleId == 1 || sessionScope.currentUser.roleId == 2 || sessionScope.currentUser.roleId == 5}">
                <div>
                    <button class="btn-edit" onclick="alert('Tính năng chỉnh sửa hồ sơ sẽ ra mắt ở Iteration 2')">
                        <i class="fas fa-pencil-alt"></i> Chỉnh sửa
                    </button>
                </div>
            </c:if>
        </div>

        <!-- Tabs -->
        <div class="nav-tabs-custom">
            <a href="#" class="nav-tab active">Thông tin cá nhân</a>
            <a href="#" class="nav-tab" onclick="alert('Tính năng đang phát triển ở Iteration 2')">Thông tin công việc</a>
            <a href="#" class="nav-tab" onclick="alert('Tính năng đang phát triển ở Iteration 2')">Lịch sử công tác</a>
            <a href="#" class="nav-tab" onclick="alert('Tính năng đang phát triển ở Iteration 2')">Hợp đồng & Lương</a>
        </div>

        <!-- Tab Content: Thông tin cá nhân -->
        <div class="content-card">
            <h3 class="section-title">Thông tin cơ bản</h3>
            
            <div class="form-grid">
                <div class="form-group">
                    <label class="form-label">Họ và tên</label>
                    <div class="form-control-view">${employee.fullName}</div>
                </div>
                <div class="form-group">
                    <label class="form-label">Tên tài khoản (Username)</label>
                    <div class="form-control-view">@${employee.username}</div>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Mã nhân viên (EMP ID)</label>
                    <div class="form-control-view">EMP-${employee.userId}</div>
                </div>
                <div class="form-group">
                    <label class="form-label">Ngày vào làm</label>
                    <div class="form-control-view"><fmt:formatDate value="${employee.createdAt}" pattern="dd/MM/yyyy"/></div>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Số điện thoại</label>
                    <div class="form-control-view">${not empty employee.phone ? employee.phone : '— Chưa cập nhật —'}</div>
                </div>
                <div class="form-group">
                    <label class="form-label">Email</label>
                    <div class="form-control-view">${employee.email}</div>
                </div>

                <!-- Các trường tĩnh (Placeholder for iteration 2) -->
                <div class="form-group">
                    <label class="form-label">Giới tính</label>
                    <div class="form-control-view" style="color: #94a3b8; font-style: italic;">Chưa cập nhật (Iter 2)</div>
                </div>
                <div class="form-group">
                    <label class="form-label">Ngày sinh</label>
                    <div class="form-control-view" style="color: #94a3b8; font-style: italic;">Chưa cập nhật (Iter 2)</div>
                </div>
                
                <div class="form-group">
                    <label class="form-label">CMND/CCCD</label>
                    <div class="form-control-view" style="color: #94a3b8; font-style: italic;">Chưa cập nhật (Iter 2)</div>
                </div>
                <div class="form-group">
                    <label class="form-label">Tình trạng hôn nhân</label>
                    <div class="form-control-view" style="color: #94a3b8; font-style: italic;">Chưa cập nhật (Iter 2)</div>
                </div>
                
                <div class="form-group full-width">
                    <label class="form-label">Địa chỉ hiện tại</label>
                    <div class="form-control-view" style="color: #94a3b8; font-style: italic;">Chưa cập nhật (Iter 2)</div>
                </div>
            </div>
        </div>

    </div>
</div>

<jsp:include page="../footer.jsp" />
