<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="pageTitle" value="Thông tin công việc - Hồ sơ Nhân sự" scope="request" />
<jsp:include page="../header.jsp" />

<style>
    body { background-color: #f0f4f8; font-family: 'Inter', sans-serif; }
    .dashboard-wrapper { display: flex; min-height: calc(100vh - 64px); }
    .main-content { flex: 1; padding: 28px 36px; width: calc(100% - 260px); }

    /* ── Back & header ── */
    .btn-back {
        display: inline-flex; align-items: center; gap: 6px;
        color: #64748b; text-decoration: none; font-weight: 600; font-size: 0.85rem;
        margin-bottom: 14px; transition: color .2s;
    }
    .btn-back:hover { color: #1e293b; }
    .page-header {
        display: flex; justify-content: space-between; align-items: flex-start;
        margin-bottom: 24px;
    }
    .page-title { font-size: 1.3rem; font-weight: 800; color: #0f172a; margin: 0; }
    .page-title span { color: #94a3b8; font-weight: 500; font-size: 1rem; }

    /* ── Hero card ── */
    .hero-card {
        background: linear-gradient(135deg, #1e40af 0%, #3b82f6 100%);
        border-radius: 20px; padding: 28px 32px;
        display: flex; align-items: center; justify-content: space-between;
        margin-bottom: 24px; box-shadow: 0 8px 32px rgba(59,130,246,.25);
        position: relative; overflow: hidden;
    }
    .hero-card::before {
        content: ''; position: absolute; top: -40px; right: -40px;
        width: 200px; height: 200px; border-radius: 50%;
        background: rgba(255,255,255,.07);
    }
    .hero-card::after {
        content: ''; position: absolute; bottom: -60px; right: 120px;
        width: 150px; height: 150px; border-radius: 50%;
        background: rgba(255,255,255,.05);
    }
    .hero-left { display: flex; align-items: center; gap: 20px; }
    .avatar-hero {
        width: 88px; height: 88px; border-radius: 50%;
        background: rgba(255,255,255,.2); border: 3px solid rgba(255,255,255,.4);
        color: #fff; display: flex; align-items: center; justify-content: center;
        font-size: 2.2rem; font-weight: 800; flex-shrink: 0;
    }
    .hero-name { font-size: 1.5rem; font-weight: 800; color: #fff; margin: 0 0 4px; }
    .hero-sub  { color: rgba(255,255,255,.75); font-size: 0.9rem; margin: 0 0 10px; }
    .hero-badges { display: flex; gap: 8px; flex-wrap: wrap; }
    .badge-white {
        background: rgba(255,255,255,.18); color: #fff;
        padding: 4px 12px; border-radius: 20px; font-size: 0.75rem; font-weight: 700;
        border: 1px solid rgba(255,255,255,.3);
    }
    .badge-green { background: #dcfce7; color: #166534; }
    .badge-red   { background: #fee2e2; color: #991b1b; }
    .badge-pill  { padding: 4px 14px; border-radius: 20px; font-size: 0.75rem; font-weight: 700; }

    .btn-edit-hero {
        display: inline-flex; align-items: center; gap: 8px;
        background: rgba(255,255,255,.15); border: 1.5px solid rgba(255,255,255,.35);
        color: #fff; padding: 9px 20px; border-radius: 10px;
        font-weight: 700; font-size: 0.9rem; text-decoration: none;
        transition: all .2s; z-index: 1;
    }
    .btn-edit-hero:hover { background: rgba(255,255,255,.28); color: #fff; }

    /* ── Tabs ── */
    .nav-tabs-custom {
        display: flex; gap: 4px; margin-bottom: 24px;
        background: #fff; border-radius: 12px; padding: 6px;
        box-shadow: 0 1px 4px rgba(0,0,0,.06); width: fit-content;
    }
    .nav-tab {
        padding: 9px 20px; font-size: 0.875rem; font-weight: 600;
        color: #64748b; cursor: pointer; border-radius: 8px;
        transition: all .2s; text-decoration: none; display: inline-flex; align-items: center; gap: 7px;
    }
    .nav-tab:hover { color: #1e293b; background: #f1f5f9; }
    .nav-tab.active { color: #fff; background: #2563eb; box-shadow: 0 2px 8px rgba(37,99,235,.35); }

    /* Content Card */
    .content-card { background: #fff; border-radius: 16px; border: 1px solid #e2e8f0; padding: 24px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); margin-bottom: 24px;}
    .section-title { font-size: 1.1rem; font-weight: 700; color: #0f172a; margin: 0 0 20px; display: flex; align-items: center; gap: 10px; }
    .section-title i { color: #2563eb; }
    
    /* Form Grid */
    .form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 24px; }
    .form-group { display: flex; flex-direction: column; gap: 8px; }
    .form-group.full-width { grid-column: span 2; }
    .form-label { font-size: 0.85rem; font-weight: 700; color: #475569; }
    .form-control-view { background: #f8fafc; border: 1px solid #e2e8f0; padding: 10px 16px; border-radius: 8px; font-size: 0.95rem; color: #0f172a; font-weight: 500; width: 100%; min-height: 42px; display: flex; align-items: center; }

    /* Badges in view */
    .view-badge { display: inline-block; padding: 4px 10px; border-radius: 6px; font-size: 0.85rem; font-weight: 600; }
    .badge-role { background: #e0e7ff; color: #3730a3; }
    .badge-dept { background: #dbeafe; color: #1e40af; }
    .badge-pos { background: #fef3c7; color: #b45309; }
</style>

<div class="dashboard-wrapper">
    <jsp:include page="../shared/sidebar.jsp">
        <jsp:param name="activeMenu" value="${sessionScope.currentUser.roleId == 3 || sessionScope.currentUser.roleId == 6 ? 'my-employees' : 'employees'}" />
    </jsp:include>

    <div class="main-content">
        <!-- Back + title -->
        <a href="javascript:history.back()" class="btn-back">
            <i class="fas fa-arrow-left"></i> Quay lại
        </a>
        <div class="page-header">
            <h1 class="page-title">Hồ sơ Nhân sự <span>/ Thông tin công việc</span></h1>
        </div>

        <!-- Hero Card -->
        <div class="hero-card">
            <div class="hero-left">
                <div class="avatar-hero">${fn:substring(employee.fullName, 0, 1)}</div>
                <div>
                    <h2 class="hero-name">${employee.fullName}</h2>
                    <p class="hero-sub">
                        <i class="fas fa-briefcase me-1"></i>
                        ${empPos != null ? empPos.positionName : 'Chưa cập nhật'}
                        &nbsp;|&nbsp;
                        <i class="fas fa-building me-1"></i>
                        ${empDept != null ? empDept.departmentName : 'Chưa phân bổ'}
                    </p>
                    <div class="hero-badges">
                        <span class="badge-white"><i class="fas fa-id-badge me-1"></i>EMP-${employee.userId}</span>
                        <span class="badge-pill ${employee.status == 1 ? 'badge-green' : 'badge-red'}">
                            <i class="fas ${employee.status == 1 ? 'fa-check-circle' : 'fa-lock'} me-1"></i>
                            ${employee.status == 1 ? 'Đang làm việc' : 'Đã nghỉ / Khóa'}
                        </span>
                    </div>
                </div>
            </div>
            <c:if test="${sessionScope.currentUser.roleId == 1 || sessionScope.currentUser.roleId == 2 || sessionScope.currentUser.roleId == 5}">
                <a href="${pageContext.request.contextPath}/hr/employee-edit?userId=${employee.userId}" class="btn-edit-hero">
                    <i class="fas fa-pencil-alt"></i> Chỉnh sửa
                </a>
            </c:if>
        </div>

        <!-- Tabs -->
        <c:choose>
            <c:when test="${sessionScope.currentUser.roleId == 3 || sessionScope.currentUser.roleId == 6}">
                <c:set var="profilePrefix" value="/manager" />
            </c:when>
            <c:otherwise>
                <c:set var="profilePrefix" value="/hr" />
            </c:otherwise>
        </c:choose>
        <div class="nav-tabs-custom">
            <a href="${pageContext.request.contextPath}${profilePrefix}/employee-detail?userId=${employee.userId}"    class="nav-tab"><i class="fas fa-user"></i> Thông tin cá nhân</a>
            <a href="${pageContext.request.contextPath}${profilePrefix}/employee-job-info?userId=${employee.userId}"  class="nav-tab active"><i class="fas fa-briefcase"></i> Thông tin công việc</a>
            <a href="${pageContext.request.contextPath}${profilePrefix}/employee-work-history?userId=${employee.userId}" class="nav-tab"><i class="fas fa-history"></i> Lịch sử công tác</a>
            <a href="${pageContext.request.contextPath}${profilePrefix}/employee-contracts?userId=${employee.userId}" class="nav-tab"><i class="fas fa-file-contract"></i> Hợp đồng & Lương</a>
        </div>

        <!-- Tab Content: Thông tin công việc -->
        <div class="content-card">
            <h3 class="section-title"><i class="fas fa-briefcase"></i> Vị trí &amp; Tổ chức</h3>
            
            <div class="form-grid">
                <div class="form-group">
                    <label class="form-label">Phòng ban (Department)</label>
                    <div class="form-control-view">
                        <c:choose>
                            <c:when test="${not empty empDept}">
                                <span class="view-badge badge-dept"><i class="fas fa-building me-1"></i> ${empDept.departmentName}</span>
                            </c:when>
                            <c:otherwise>
                                <span style="color: #94a3b8; font-style: italic;">Chưa phân bổ</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Chức vụ chuyên môn (Position)</label>
                    <div class="form-control-view">
                        <c:choose>
                            <c:when test="${not empty empPos}">
                                <span class="view-badge badge-pos"><i class="fas fa-id-badge me-1"></i> ${empPos.positionName}</span>
                            </c:when>
                            <c:otherwise>
                                <span style="color: #94a3b8; font-style: italic;">Chưa cập nhật</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Vai trò hệ thống (Role)</label>
                    <div class="form-control-view">
                        <c:choose>
                            <c:when test="${not empty userRole}">
                                <span class="view-badge badge-role"><i class="fas fa-user-shield me-1"></i> ${userRole.roleName}</span>
                            </c:when>
                            <c:otherwise>
                                <span style="color: #94a3b8; font-style: italic;">Chưa phân quyền</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label">Ngày vào làm</label>
                    <div class="form-control-view">
                        <c:choose>
                            <c:when test="${not empty empProfile and not empty empProfile.hireDate}">
                                <span style="font-weight: 500; color: #334155;"><i class="fas fa-calendar-check me-1" style="color: #0d9488;"></i> <fmt:formatDate value="${empProfile.hireDate}" pattern="dd/MM/yyyy"/></span>
                            </c:when>
                            <c:otherwise>
                                <span style="color: #94a3b8; font-style: italic;">Chưa cập nhật</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label">Trạng thái công việc</label>
                    <div class="form-control-view">
                        <c:choose>
                            <c:when test="${employee.status == 1}">
                                <span style="color: #16a34a; font-weight: 600;"><i class="fas fa-circle me-1" style="font-size: 8px; vertical-align: middle;"></i> Đang làm việc</span>
                            </c:when>
                            <c:otherwise>
                                <span style="color: #dc2626; font-weight: 600;"><i class="fas fa-circle me-1" style="font-size: 8px; vertical-align: middle;"></i> Đã nghỉ việc / Khóa</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </div>
        


    </div>
</div>

<jsp:include page="../footer.jsp" />
