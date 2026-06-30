<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="pageTitle" value="Chi tiết Hồ sơ Nhân sự" scope="request" />
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

    /* ── Section cards ── */
    .info-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
    .info-section {
        background: #fff; border-radius: 16px; padding: 24px;
        box-shadow: 0 1px 4px rgba(0,0,0,.06); border: 1px solid #e2e8f0;
    }
    .info-section.full { grid-column: span 2; }

    .section-header {
        display: flex; align-items: center; gap: 10px;
        margin-bottom: 20px; padding-bottom: 14px;
        border-bottom: 2px solid #f1f5f9;
    }
    .section-icon {
        width: 38px; height: 38px; border-radius: 10px;
        display: flex; align-items: center; justify-content: center;
        font-size: 1rem; flex-shrink: 0;
    }
    .icon-blue   { background: #eff6ff; color: #2563eb; }
    .icon-purple { background: #f5f3ff; color: #7c3aed; }
    .icon-green  { background: #f0fdf4; color: #16a34a; }
    .section-title { font-size: 1rem; font-weight: 700; color: #0f172a; margin: 0; }
    .section-sub   { font-size: 0.78rem; color: #94a3b8; margin: 0; }

    /* ── Info rows ── */
    .info-row {
        display: flex; align-items: flex-start; gap: 12px;
        padding: 10px 0; border-bottom: 1px solid #f8fafc;
    }
    .info-row:last-child { border-bottom: none; padding-bottom: 0; }
    .info-row-icon {
        width: 32px; height: 32px; border-radius: 8px; background: #f8fafc;
        display: flex; align-items: center; justify-content: center;
        color: #64748b; font-size: 0.85rem; flex-shrink: 0; margin-top: 1px;
    }
    .info-row-content { flex: 1; min-width: 0; }
    .info-label { font-size: 0.75rem; font-weight: 600; color: #94a3b8; text-transform: uppercase; letter-spacing: .4px; margin-bottom: 3px; }
    .info-value { font-size: 0.95rem; font-weight: 600; color: #1e293b; word-break: break-word; }
    .info-value.muted { color: #cbd5e1; font-style: italic; font-weight: 400; }

    /* Dependent badge */
    .dep-badge {
        display: inline-flex; align-items: center; gap: 5px;
        background: #eff6ff; color: #1d4ed8; padding: 3px 10px;
        border-radius: 20px; font-size: 0.85rem; font-weight: 700;
    }
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
            <h1 class="page-title">Hồ sơ Nhân sự <span>/ Thông tin cá nhân</span></h1>
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
            <a href="${pageContext.request.contextPath}${profilePrefix}/employee-detail?userId=${employee.userId}"    class="nav-tab active"><i class="fas fa-user"></i> Thông tin cá nhân</a>
            <a href="${pageContext.request.contextPath}${profilePrefix}/employee-job-info?userId=${employee.userId}"  class="nav-tab"><i class="fas fa-briefcase"></i> Thông tin công việc</a>
            <a href="${pageContext.request.contextPath}${profilePrefix}/employee-work-history?userId=${employee.userId}" class="nav-tab"><i class="fas fa-history"></i> Lịch sử công tác</a>
            <a href="${pageContext.request.contextPath}${profilePrefix}/employee-contracts?userId=${employee.userId}" class="nav-tab"><i class="fas fa-file-contract"></i> Hợp đồng & Lương</a>
        </div>

        <!-- Info Grid -->
        <div class="info-grid">

            <!-- Card 1: Thông tin định danh -->
            <div class="info-section">
                <div class="section-header">
                    <div class="section-icon icon-blue"><i class="fas fa-id-card"></i></div>
                    <div>
                        <p class="section-title">Thông tin định danh</p>
                        <p class="section-sub">Tài khoản & mã nhân viên</p>
                    </div>
                </div>

                <div class="info-row">
                    <div class="info-row-icon"><i class="fas fa-hashtag"></i></div>
                    <div class="info-row-content">
                        <div class="info-label">Mã nhân viên</div>
                        <div class="info-value">EMP-${employee.userId}</div>
                    </div>
                </div>
                <div class="info-row">
                    <div class="info-row-icon"><i class="fas fa-user-circle"></i></div>
                    <div class="info-row-content">
                        <div class="info-label">Tên tài khoản</div>
                        <div class="info-value">@${employee.username}</div>
                    </div>
                </div>
                <div class="info-row">
                    <div class="info-row-icon"><i class="fas fa-calendar-check"></i></div>
                    <div class="info-row-content">
                        <div class="info-label">Ngày vào làm</div>
                        <div class="info-value">
                            <c:choose>
                                <c:when test="${empProfile != null && empProfile.hireDate != null}">
                                    <fmt:formatDate value="${empProfile.hireDate}" pattern="dd/MM/yyyy"/>
                                </c:when>
                                <c:otherwise><fmt:formatDate value="${employee.createdAt}" pattern="dd/MM/yyyy"/></c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
                <div class="info-row">
                    <div class="info-row-icon"><i class="fas fa-id-badge"></i></div>
                    <div class="info-row-content">
                        <div class="info-label">CMND / CCCD</div>
                        <div class="info-value">
                            <c:choose>
                                <c:when test="${empProfile != null && not empty empProfile.idCard}">${empProfile.idCard}</c:when>
                                <c:otherwise><span class="muted">Chưa cập nhật</span></c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Card 2: Thông tin cá nhân -->
            <div class="info-section">
                <div class="section-header">
                    <div class="section-icon icon-purple"><i class="fas fa-user"></i></div>
                    <div>
                        <p class="section-title">Thông tin cá nhân</p>
                        <p class="section-sub">Giới tính, ngày sinh, người phụ thuộc</p>
                    </div>
                </div>

                <div class="info-row">
                    <div class="info-row-icon"><i class="fas fa-venus-mars"></i></div>
                    <div class="info-row-content">
                        <div class="info-label">Giới tính</div>
                        <div class="info-value">
                            <c:choose>
                                <c:when test="${empProfile != null && empProfile.gender != null}">${empProfile.genderLabel}</c:when>
                                <c:otherwise><span class="muted">Chưa cập nhật</span></c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
                <div class="info-row">
                    <div class="info-row-icon"><i class="fas fa-birthday-cake"></i></div>
                    <div class="info-row-content">
                        <div class="info-label">Ngày sinh</div>
                        <div class="info-value">
                            <c:choose>
                                <c:when test="${empProfile != null && empProfile.dob != null}">
                                    <fmt:formatDate value="${empProfile.dob}" pattern="dd/MM/yyyy"/>
                                </c:when>
                                <c:otherwise><span class="muted">Chưa cập nhật</span></c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
                <div class="info-row">
                    <div class="info-row-icon"><i class="fas fa-users"></i></div>
                    <div class="info-row-content">
                        <div class="info-label">Số người phụ thuộc</div>
                        <div class="info-value">
                            <c:choose>
                                <c:when test="${empProfile != null}">
                                    <span class="dep-badge">
                                        <i class="fas fa-user-friends"></i>
                                        ${empProfile.dependentCount} người
                                    </span>
                                </c:when>
                                <c:otherwise><span class="muted">Chưa cập nhật</span></c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Card 3: Thông tin liên lạc (full width) -->
            <div class="info-section full">
                <div class="section-header">
                    <div class="section-icon icon-green"><i class="fas fa-address-book"></i></div>
                    <div>
                        <p class="section-title">Thông tin liên lạc</p>
                        <p class="section-sub">Email, điện thoại và địa chỉ</p>
                    </div>
                </div>

                <div style="display:grid; grid-template-columns:1fr 1fr; gap:0 32px;">
                    <div class="info-row">
                        <div class="info-row-icon"><i class="fas fa-envelope"></i></div>
                        <div class="info-row-content">
                            <div class="info-label">Email</div>
                            <div class="info-value">${employee.email}</div>
                        </div>
                    </div>
                    <div class="info-row">
                        <div class="info-row-icon"><i class="fas fa-phone-alt"></i></div>
                        <div class="info-row-content">
                            <div class="info-label">Số điện thoại</div>
                            <div class="info-value">
                                <c:choose>
                                    <c:when test="${not empty employee.phone}">${employee.phone}</c:when>
                                    <c:otherwise><span class="muted">Chưa cập nhật</span></c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>
                    <div class="info-row" style="grid-column:span 2;">
                        <div class="info-row-icon"><i class="fas fa-map-marker-alt"></i></div>
                        <div class="info-row-content">
                            <div class="info-label">Địa chỉ hiện tại</div>
                            <div class="info-value">
                                <c:choose>
                                    <c:when test="${empProfile != null && not empty empProfile.address}">${empProfile.address}</c:when>
                                    <c:otherwise><span class="muted">Chưa cập nhật</span></c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

        </div><!-- /info-grid -->
    </div>
</div>

<jsp:include page="../footer.jsp" />
